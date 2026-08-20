---
name: prisma-v7-workflow
description: Guides Prisma v7 schema changes, migrations, and client generation. Use this skill whenever you need to add models, enums, or fields to schema.prisma, run a migration, or regenerate the Prisma client. Essential for Prisma v7 projects — this version has breaking changes from v5/v6 around datasource config, migration commands, driver adapters, and import paths that will silently fail if done the old way. Invoke this any time the words "schema", "migrate", "prisma generate", "model", "enum", or "field" come up in a Prisma context.
---

# Prisma v7 — Schema, Migration, and Generation Workflow

## What's different in v7 (vs v5/v6)

These are the breaking changes that will bite you if you assume the old behavior:

| Thing | Old (v5/v6) | New (v7) |
|-------|-------------|----------|
| DB URL location | `datasource db { url = env("DATABASE_URL") }` | Only `provider` in schema; URL lives in `prisma.config.ts` |
| PrismaClient init | `new PrismaClient()` | Requires a driver adapter (e.g. `PrismaPg`) |
| Generated client path | `node_modules/@prisma/client` | `generated/prisma` (set in generator block) |
| Type import path | `import { X } from '@prisma/client'` | `import { X } from '../../../generated/prisma/client'` |
| Config file | None | `prisma.config.ts` using `defineConfig` from `prisma/config` |

## Step 1: Edit `prisma/schema.prisma`

The datasource block will look like this — **do not add a `url` field**:
```prisma
datasource db {
  provider = "postgresql"
}
```

The generator block outputs to `generated/prisma`:
```prisma
generator client {
  provider = "prisma-client"
  output   = "../generated/prisma"
}
```

### Adding a new enum
```prisma
enum WorkflowType {
  CHECKROOM
  LOST_AND_FOUND
}
```

### Adding fields to an existing model
```prisma
model Item {
  // existing fields...
  workflowType      WorkflowType    @default(LOST_AND_FOUND)
  ownerCongregation String?
  ownerAddress      String?
  escalationDueDate DateTime?
}
```

### Adding a new model
```prisma
model MissingReport {
  id          String   @id @default(cuid())
  description String
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}
```

## Step 2: Run the migration

```bash
DATABASE_URL='<your-connection-url>' pnpm prisma migrate dev --name <descriptive-name>
```

**Why you must pass `DATABASE_URL` explicitly:** Even though `prisma.config.ts` defines the connection, the Prisma CLI reads `DATABASE_URL` from the process environment at migration time. The `.env` file is not auto-loaded by the CLI. Pass the URL inline on the same command or export it first.

```bash
# Option A — inline (preferred, no side effects)
DATABASE_URL='postgresql://user:pass@host:5432/dbname' pnpm prisma migrate dev --name add_item_workflow_fields

# Option B — export first
export DATABASE_URL='postgresql://user:pass@host:5432/dbname'
pnpm prisma migrate dev --name add_item_workflow_fields
```

**Naming conventions for migrations** — be descriptive:
- `add_workflow_type_enum`
- `add_missing_report_model`
- `add_congregation_address_to_item`
- `add_person_case_escalation_fields`

## Step 3: Regenerate the Prisma client

```bash
pnpm prisma generate
```

Run this after every schema change. The `generated/` directory is gitignored — always regenerate after:
- Your own schema edits
- Pulling a branch that includes schema changes
- Any migration that ran successfully

If you skip this, TypeScript will have stale types and you'll see "property does not exist" errors on Prisma query results.

## Step 4: Update TypeScript imports

After adding new enums or models, import them from the correct path:

```typescript
// Correct for Prisma v7 — relative path from your file to generated/prisma/client
import type { WorkflowType, ItemCategory, ValueTier } from '../../../../generated/prisma/client'

// Wrong — this package doesn't exist in Prisma v7
import type { WorkflowType } from '@prisma/client'
```

The relative path (`../../../../`) depends on how deep your file is from the project root. Check the depth and adjust accordingly.

## Step 5: Wire up new fields end-to-end

When adding fields, trace them all the way through:

1. **Zod schema** (`src/lib/zod/*.ts`) — add the field as `z.string().optional()` or appropriate type
2. **Server action** (`src/app/actions/*/index.ts`) — read from validated data and pass to `prisma.model.create/update`
3. **Form UI** — add the input field and include it in `FormData`
4. **Type cast** — for enum fields, cast with `as EnumType` since Zod returns `string`

Example for an enum field:
```typescript
import type { WorkflowType } from '../../../../generated/prisma/client'

// In the action:
const workflowType: WorkflowType = validated.zone === 'CHECKROOM' ? 'CHECKROOM' : 'LOST_AND_FOUND'

await prisma.item.create({
  data: {
    workflowType,
    // ...
  }
})
```

## Common errors and fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `datasource.url property is required` | `DATABASE_URL` not in environment at migration time | Pass inline: `DATABASE_URL='...' pnpm prisma migrate dev ...` |
| `Cannot find module '@prisma/client'` | Wrong import path | Change to `generated/prisma/client` |
| `Module not found: generated/prisma` | Client not generated | Run `pnpm prisma generate` |
| Type errors after schema change | Stale generated types | Run `pnpm prisma generate`, then restart TS server |
| `Property 'X' does not exist on type` after adding field | Client not regenerated | Run `pnpm prisma generate` |

## Full checklist for a schema change

- [ ] Edit `prisma/schema.prisma` (model, enum, or field)
- [ ] Run `DATABASE_URL='...' pnpm prisma migrate dev --name <name>`
- [ ] Run `pnpm prisma generate`
- [ ] Update TypeScript imports for new types
- [ ] Update Zod validation schema if new fields need validation
- [ ] Update server actions to include new fields in create/update calls
- [ ] Update form UI to collect new fields if user-facing
- [ ] Cast enum fields to their Prisma type explicitly
