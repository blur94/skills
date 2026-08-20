---
name: react-doc-viewer-integration
description: Use when adding react-doc-viewer (DocViewer) to a React or Next.js project to preview PDFs, images, or office files — covers installation, building a single reusable `<DocumentViewer>` component, the PDF/image renderer override pattern, custom renderer registration, authenticated file URLs, and Jest mocking.
---

# react-doc-viewer Integration

Portable recipe for a single, reusable `<DocumentViewer>` component: `react-doc-viewer` renders a document by URL, and a **renderer override** replaces its bundled (aging) PDF and image renderers with modern equivalents. The component itself has no opinion about *where* it's placed — inline on a page, inside a modal, inside a drawer, wherever — that's the caller's job. Steps below are drawn from a working Next.js 16 + Mantine 8 + React 19 integration; deviate only where your stack differs.

## 1. Install

```
npm install react-doc-viewer@^0.1.5 @react-pdf-viewer/core@^3.12.0 pdfjs-dist@^3.4.120
```

- `react-doc-viewer` bundles its own `pdfjs-dist@2.4.456` and `react-pdf@5.0.0` as transitive dependencies — these power its *default* PDF renderer. They stay installed regardless of step 3; you're not replacing them, you're outranking them.
- No `react`/`react-dom` peer dependency is declared, so it runs fine on React 19 despite the package's own devDependencies pinning React 16 — nothing to reconcile.
- `styled-components` ships as a transitive dependency of `react-doc-viewer`; don't install or configure it separately.
- Skip `@react-pdf-viewer/default-layout` unless you specifically want its prebuilt toolbar (zoom controls, page nav, search) — the bare `Worker`/`Viewer` combo in step 3 needs only `@react-pdf-viewer/core`.

## 2. Build the reusable component — no modal, no assumptions about placement

`DocViewer` itself has no dialog/overlay and no default sizing — that's exactly what makes it safe to wrap once and drop anywhere. Build a bare `DocumentViewer` that only knows about the document, never about a modal, drawer, or page layout:

```tsx
// DocumentViewer.tsx
"use client";

import { CSSProperties } from "react";
import DocViewer, { DocViewerRenderers } from "react-doc-viewer";
import CustomPDFRenderer from "./CustomPDFRenderer";
import CustomImageRenderer from "./CustomImageRenderer";

interface DocumentViewerProps {
  fileUrl: string;
  fileType?: string;
  className?: string;
  style?: CSSProperties;
}

export default function DocumentViewer({ fileUrl, fileType, className, style }: DocumentViewerProps) {
  return (
    <DocViewer
      documents={[{ uri: fileUrl, fileType }]}
      pluginRenderers={[CustomPDFRenderer, CustomImageRenderer, ...DocViewerRenderers]}
      config={{
        header: {
          disableHeader: true,
          disableFileName: true,
          retainURLParams: true,
        },
      }}
      className={className}
      style={{ width: "100%", height: "100%", ...style }}
    />
  );
}
```

Key decisions baked into this component — carry them over as-is unless you have a specific reason not to:

- **`documents` is always a single-item array.** DocViewer supports multi-document carousels (prev/next navigation), but this component renders exactly one file per mount — whatever's showing next is a prop change driven by the *caller's* state, not DocViewer's own multi-doc state. Keeps the component dumb and trivially reusable.
- **`config.header.disableHeader: true` + `disableFileName: true`.** DocViewer's own toolbar (filename, prev/next, download) is switched off entirely, because a bare reusable component shouldn't assume it owns the surrounding chrome — a caller embedding it inline may want no header at all, and a caller embedding it in a modal already has the modal's own close button. If a specific placement needs a header/close affordance, add it in that caller, not here.
- **`retainURLParams: true`.** Without this, DocViewer strips the query string off `uri` when deriving the file extension — which breaks signed/expiring URLs (S3, GCS) that carry auth tokens as query params.
- **No intrinsic size — `width: 100%, height: 100%` by default, overridable via `style`.** The component fills whatever box it's placed in; it does not reach outside itself to size that box. This is what makes it safe to drop into a modal, a drawer, or an inline page section without editing the component each time — see step 6 for what each of those callers needs to provide.
- **`fileType` accepts a MIME type (`"application/pdf"`) or a bare extension (`"pdf"`)** — DocViewer falls back to sniffing one from `uri` if `fileType` is omitted, but pass it explicitly whenever you have it; extension-sniffing a signed URL with query params is unreliable.

## 3. Override the PDF renderer (recommended)

The bundled PDF renderer runs `pdfjs-dist@2.4.456` + `react-pdf@5.0.0`, both several majors behind current. Override it with `@react-pdf-viewer/core` on a separately-installed, current `pdfjs-dist`:

```tsx
// CustomPDFRenderer.tsx
import React from "react";
import { DocRendererProps } from "react-doc-viewer";
import { Worker, Viewer } from "@react-pdf-viewer/core";
import "@react-pdf-viewer/core/lib/styles/index.css";

const CustomPDFRenderer = ({ mainState }: { mainState: DocRendererProps["mainState"] }) => {
  const { currentDocument } = mainState;
  if (!currentDocument) return null;

  return (
    <div style={{ width: "100%", height: "100%" }}>
      <Worker workerUrl="https://unpkg.com/pdfjs-dist@3.4.120/build/pdf.worker.min.js">
        {currentDocument.uri && <Viewer fileUrl={currentDocument.uri} />}
      </Worker>
    </div>
  );
};

CustomPDFRenderer.fileTypes = ["pdf", "application/pdf"];
CustomPDFRenderer.weight = 1; // must exceed the built-in PDFRenderer's weight (0) to win

export default CustomPDFRenderer;
```

The `workerUrl` version **must match** the `pdfjs-dist` version installed as a direct dependency (`3.4.120` here) — a mismatched worker/library pair fails silently or throws a version-mismatch error at runtime. Pin the CDN URL's version string to whatever you installed; don't leave it floating on `@latest`.

Don't skip `@react-pdf-viewer/core/lib/styles/index.css` — the package renders with no toolbar layout and no borders without it, and nothing else in a typical app pulls it in automatically.

## 4. Override the image renderer (optional)

Only worth doing if you want `next/image` (lazy loading, automatic `srcset`) instead of the built-in `<img>`-based renderer. Skip this step entirely on non-Next.js stacks.

```tsx
// CustomImageRenderer.tsx
import Image from "next/image";
import { DocRendererProps } from "react-doc-viewer";

const CustomImageRenderer = ({ mainState }: { mainState: DocRendererProps["mainState"] }) => {
  const { currentDocument } = mainState;
  if (!currentDocument) return null;

  return (
    <div style={{ position: "relative", height: "100%", width: "100%" }}>
      <Image
        src={(currentDocument.fileData as string) ?? currentDocument.uri}
        alt="Image"
        fill
        style={{ objectFit: "contain" }}
      />
    </div>
  );
};

CustomImageRenderer.fileTypes = [
  "png", "image/png", "jpg", "image/jpeg", "jpeg",
  "gif", "image/gif", "bmp", "image/bmp", "webp", "image/webp",
];
CustomImageRenderer.weight = 1;

export default CustomImageRenderer;
```

- `next/image` requires the source host to be allow-listed in `next.config.ts` under `images.remotePatterns` (or the deprecated `images.domains`) — if file URLs come from S3/GCS/a CDN, add that host or the renderer throws at runtime. If URLs come from many/unpredictable hosts (multi-tenant storage), skip `next/image` and render a plain `<img>` instead.
- `fill` requires the parent element to be positioned (`relative`/`absolute`/`fixed`) with a resolved height — that's what the wrapping `div` provides.

## 5. Wire both overrides into `pluginRenderers` — don't just create the files

This is the step it's easiest to silently skip: defining `CustomPDFRenderer`/`CustomImageRenderer` does nothing on its own. They only take effect once passed into `pluginRenderers`:

```tsx
<DocViewer
  documents={[{ uri: fileUrl, fileType }]}
  pluginRenderers={[CustomPDFRenderer, CustomImageRenderer, ...DocViewerRenderers]}
  // ...rest unchanged
/>
```

If `pluginRenderers` is left as bare `[...DocViewerRenderers]`, every custom renderer file in the project is dead code — DocViewer falls back to the bundled (old) PDF/image renderers with no error and no warning, just the wrong renderer silently running. Verify by opening a PDF: `@react-pdf-viewer/core`'s toolbar (zoom %, page counter, a light-grey control bar) looks distinctly different from the bundled `react-pdf` viewer (no toolbar, plain scrolling pages) — if you see the latter after wiring in the override, the array wasn't updated correctly, or a build cache is stale.

## 6. Place it anywhere you need a document preview

`DocumentViewer` takes a plain `{ fileUrl, fileType }` pair and fills its parent — no context provider, no global state, no assumption about a modal. Every placement is the same component; only the surrounding container and how you source `fileUrl`/`fileType` changes.

**Inline on a page** (a document detail view, a card, a side-by-side split view) — the parent must give it a resolved height, since the component itself only fills whatever box it's in:
```tsx
<div style={{ height: 600 }}>
  <DocumentViewer fileUrl={file.fileUrl} fileType={file.mimeType} />
</div>
```

**Inside a modal** (the common "preview on double-click" case) — the modal owns the open/close state and its own close button; `DocumentViewer` doesn't know it's in a modal at all:
```tsx
function FileViewer({ fileUrl, fileType, opened, onClose }: FileViewerProps) {
  return (
    <Modal opened={opened} onClose={onClose} fullScreen centered>
      <DocumentViewer
        fileUrl={fileUrl}
        fileType={fileType}
        style={{ height: fileType !== "application/pdf" ? "calc(100dvh - 5rem)" : undefined }}
      />
    </Modal>
  );
}
```
The `height` override here is specific to *this* caller's fullscreen-modal layout — inside a Mantine `Modal.Body`, the PDF renderer sizes itself fine with `height` left unset, but every other bundled renderer collapses to zero height without an explicit value. That's a quirk of this particular container, not a rule about `DocumentViewer` itself; a different container (a fixed-height `div`, a drawer) may not need the ternary at all — give it a resolved height and check that every file type you support actually renders at that placement before assuming one fits-all.

**Inside a drawer/side panel** — same component, different container:
```tsx
<Drawer opened={opened} onClose={onClose} size="xl">
  <DocumentViewer fileUrl={fileUrl} fileType={fileType} style={{ height: "calc(100vh - 4rem)" }} />
</Drawer>
```

**Sourcing `fileUrl`/`fileType`** — three patterns cover most cases regardless of where the component is placed:

- *A file already in hand* (list/grid row, menu action): pass `file.fileUrl` / `file.mimeType` straight through.
- *A file loaded by ID* (e.g. a `?fileId=` deep link): resolve it first (`const { data: { fileUrl, mimeType } } = useFetchFile(fileId ?? "")`), then pass the resolved values down.
- *An attachment URL with no separate MIME type field*: derive a bare extension from the URL string — `selectedAttachment?.split(".").slice(-1)[0] ?? ""`. This only works because renderers match on file *extension* as well as MIME type (see each renderer's `fileTypes` array); it breaks silently if the URL has no extension or a query string obscures the trailing segment. Prefer a real MIME type field whenever the backend provides one.

**Authenticated URLs**: DocViewer fetches `uri` directly from the browser (`XMLHttpRequest`/`fetch`) with no way to attach an `Authorization` header, regardless of where `DocumentViewer` is placed. If file storage requires auth, the URL itself must already be authenticated — a signed/expiring URL with a token in the query string (this is why `retainURLParams: true` in step 2 matters) or a same-origin proxy route that attaches credentials server-side and streams the bytes back. A bearer-token-gated URL passed directly will 401 inside the renderer with no error surfaced to your own component.

## 7. Supported file types out of the box

`DocViewerRenderers` (the spread import) covers: PDF, PNG, JPG, BMP, TIFF, TXT, HTML, Outlook `.msg`, and — via `MSDocRenderer` — `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`. That last group isn't rendered locally: `MSDocRenderer` embeds an iframe pointed at `https://view.officeapps.live.com/op/embed.aspx?src=<encoded uri>` (Microsoft's public Office Online Viewer) and does no local fetch of its own — its `fileLoader` is a no-op.

Because Microsoft's servers fetch `uri` themselves, **the URL must be publicly reachable from the internet**, not just from the end user's browser. This breaks the same way an authenticated URL breaks DocViewer's own fetch (step 6): a short-lived signed URL may expire before Microsoft's viewer loads it, and a URL on a private network or behind auth headers won't resolve at all from their servers. If your files aren't publicly fetchable, either generate a signed URL with enough lifetime for the embed to load, or convert the file to PDF server-side and let the PDF renderer (which *does* run entirely client-side) handle it instead.

**Not covered by any bundled renderer**: `.csv`, video, or audio — passing one of these as `fileType` renders DocViewer's built-in "no renderer available" fallback. Write and register a custom renderer for these if needed.

## 8. Performance and browser notes

- When `DocumentViewer` is placed inside a modal/drawer rather than rendered inline, make sure that container actually unmounts it when closed — most modal libraries (Mantine's `Modal` included) do this by default, but if yours doesn't, wrap it in your own conditional render (`{opened && <DocumentViewer .../>}`). Otherwise every previewed file stays resident in memory/DOM, and the PDF worker/image fetch fires on every file selection instead of only while the viewer is actually visible.
- The `unpkg` CDN `workerUrl` in step 3 is an external network dependency at runtime. For offline/intranet/air-gapped deployments, self-host `pdf.worker.min.js` (copy from `node_modules/pdfjs-dist/build/` into `/public`, or import it as a bundler asset) and point `workerUrl` at that path instead.
- The PDF.js worker requires Web Worker support — fine on all evergreen browsers, unsupported on IE11 (not a concern unless you have IE11 traffic).
- `next/image` with `fill` needs a parent with a non-static, resolved size in every browser you target — re-verify explicitly in Safari, which is stricter about implicit height inside flex/grid containers than Chromium.

## 9. Tests: mock the module, don't render it

`react-doc-viewer` pulls in `pdfjs-dist`, which tries to spin up a real PDF.js worker and breaks under `jsdom`. Mock both at the test-setup level rather than per-test:

```ts
// jest.setup.ts
import React from "react";

jest.mock("pdfjs-dist", () => ({
  __esModule: true,
  GlobalWorkerOptions: { workerSrc: "" },
}));

jest.mock("react-doc-viewer", () => ({
  __esModule: true,
  default: React.forwardRef(() => React.createElement("div", { "data-testid": "doc-viewer" })),
  DocViewerRenderers: [],
}));
```
Assert against the `data-testid="doc-viewer"` mount, not against DocViewer's internals — its rendering runs through `styled-components` and `pdfjs-dist` internals that `jsdom` can't execute anyway.

---

For the full prop/type reference (`IConfig`, `ITheme`, `DocRenderer`, file loader functions, renderer resolution algorithm) and a troubleshooting table, see [REFERENCE.md](REFERENCE.md).
