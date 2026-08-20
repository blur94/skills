# react-doc-viewer Reference

Full type surface and troubleshooting for `react-doc-viewer@0.1.5`. Consult this when the steps in [SKILL.md](SKILL.md) don't cover the specific prop, loader, or failure you're looking at.

## Full type surface

```ts
interface DocViewerProps {
  documents: IDocument[];
  className?: string;
  style?: CSSProperties;
  config?: IConfig;
  theme?: ITheme;
  pluginRenderers?: DocRenderer[];
}

interface IDocument {
  uri: string;
  fileType?: string;                // MIME type or bare extension
  fileData?: string | ArrayBuffer;  // pre-loaded content; skips the internal fetch when present
}

interface IConfig {
  header?: IHeaderConfig;
}

interface IHeaderConfig {
  disableHeader?: boolean;
  disableFileName?: boolean;
  retainURLParams?: boolean;
  overrideComponent?: (
    state: IMainState,
    previousDocument: () => void,
    nextDocument: () => void,
  ) => ReactElement | null;
}

interface ITheme {
  primary?: string;
  secondary?: string;
  tertiary?: string;
  text_primary?: string;
  text_secondary?: string;
  text_tertiary?: string;
  disableThemeScrollbar?: boolean;
}

interface DocRendererProps {
  mainState: IMainState;
}

interface DocRenderer extends FC<DocRendererProps> {
  fileTypes: string[];
  weight: number;
  fileLoader?: FileLoaderFunction | null;
}

type IMainState = {
  currentFileNo: number;
  documents: IDocument[];
  documentLoading?: boolean;
  currentDocument?: IDocument;
  rendererRect?: DOMRect;
  config?: IConfig;
  pluginRenderers?: DocRenderer[];
};
```

No `ThemeProvider`/context is required — `theme` is an optional flat prop on `DocViewer` itself; `styled-components` handles propagation internally. If you don't set it, `defaultTheme` applies. It's only worth setting if you re-enable the header (`disableHeader: false`), since with the header hidden its color tokens are barely visible anyway.

## File loading strategies

`IDocument.uri` is fetched by the matched renderer's `fileLoader` (falls back to `defaultFileLoader`, an `XMLHttpRequest` with `responseType: "arraybuffer"`). Four loader functions ship with the package — `arrayBufferFileLoader`, `dataURLFileLoader`, `textFileLoader`, `binaryStringFileLoader` — and a custom renderer can assign one of them (or write its own matching the `FileLoaderFunction` signature) via its static `fileLoader` property to change the underlying `FileReader` operation used before the renderer receives the data.

| Source | How to feed it |
|---|---|
| Remote URL (public or signed) | `uri: "https://…"` — the common case, covers everything in SKILL.md step 6 |
| A local `File`/`Blob` (e.g. upload preview before persisting) | `uri: URL.createObjectURL(file)` — revoke it (`URL.revokeObjectURL`) on close/unmount or the blob URL leaks for the tab's lifetime |
| Already-fetched bytes (avoid a second network round-trip) | Set `fileData` (base64 string or `ArrayBuffer`) alongside `uri`; `CustomImageRenderer` in SKILL.md step 4 reads `fileData` first for exactly this reason, falling back to `uri` if absent |

## Renderer resolution algorithm

For the current document's `fileType`, DocViewer filters `pluginRenderers` down to those whose `fileTypes` array contains it — matching is literal string inclusion, so a renderer wanting to match both `"pdf"` and `"application/pdf"` must list both forms explicitly, not just one. Among the matches, it picks the highest `weight`; ties break by array order (earlier entry wins). All built-in renderers default to `weight: 0`, so any custom renderer with `weight: 1` or higher takes priority without needing to reason about a ceiling.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| PDF renders as old, unstyled scrolling pages instead of a toolbar | `CustomPDFRenderer` defined but not passed into `pluginRenderers` | Add it to the array (SKILL.md step 5) |
| PDF viewer throws a worker version mismatch, or shows a blank page | `workerUrl` CDN version ≠ the `pdfjs-dist` version actually installed | Pin both to the identical version string |
| Image renderer throws `Invalid src prop... hostname is not configured` | `next/image` host missing from `next.config.ts` `images.remotePatterns` | Add the host, or don't use the `next/image`-based renderer for that source |
| Signed/authenticated file URL 401s inside the viewer | DocViewer's internal fetch can't attach an `Authorization` header | Use a pre-signed URL, or proxy through a same-origin route that attaches credentials server-side |
| PDF displays fine but other file types collapse to zero height in a given container | That container's `style` override doesn't give non-PDF renderers an explicit `height` | Give `DocumentViewer` a resolved height for every file type you support in that placement — see the modal example's height ternary (SKILL.md step 6) for the pattern |
| `.docx`/`.xlsx`/`.pptx` shows blank or fails to load in its iframe | `MSDocRenderer` embeds Microsoft's Office Online Viewer, which fetches `uri` from its own servers — the URL isn't publicly reachable (private network, or a signed URL that expired before the embed loaded) | Extend the signed URL's lifetime, or convert to PDF server-side and let the PDF renderer handle it |
| `.csv`, video, or audio shows "no renderer available" | Not covered by any bundled renderer | Convert to PDF server-side, or write and register a custom renderer |
| Tests hang or throw worker errors under Jest | `pdfjs-dist` tries to initialize a real worker under `jsdom` | Mock `pdfjs-dist` and `react-doc-viewer` in test setup (SKILL.md step 9) |
| Query-string auth token disappears from the file URL before the renderer receives it | `retainURLParams` not set (defaults to stripping the query string when deriving the extension) | Set `config.header.retainURLParams: true` |
| Custom renderer registered, but the default one still runs | Custom renderer's `weight` not set, or set below the default's `0` | Explicitly set `weight: 1` (or higher) on the custom renderer |

## Peer/companion packages actually required vs. merely present

A `package.json` that's been carrying this integration for a while may also list `@react-pdf-viewer/default-layout`. It is not required by the pattern in SKILL.md — the PDF override there uses only `@react-pdf-viewer/core`'s bare `Worker`/`Viewer`, with no toolbar plugin layer. Only add `default-layout` if you specifically want its prebuilt toolbar (zoom controls, page navigation, search) instead of a bare, chromeless PDF canvas.
