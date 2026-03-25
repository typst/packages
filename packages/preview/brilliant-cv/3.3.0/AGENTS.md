# Project Instructions

Brilliant CV is a **Typst package** (`@preview/brilliant-cv`) for creating modular, multilingual CVs and cover letters. Published to Typst Universe.

## Before You Start

Run `just link` before any local development. This registers the local package with Typst's resolver. Without it, all imports fail. Run `just` to see all available commands.

## Critical Architecture

**`src/` is the published package. `template/` is the user-facing starter project.** They are separate concerns:
- `src/lib.typ` — Package entry point, exports `cv()` and `letter()`
- `template/metadata.toml` — Central configuration file, drives all customization
- `template/modules_<lang>/` — Content files per language

Changes to `src/` affect all downstream users. Never break backward compatibility without a deprecation path.

## Things You Will Get Wrong Without Reading This

### Deprecated parameters use panic(), not silent aliasing
In `src/lib.typ`, deprecated parameters trigger `panic()` with migration instructions. This is **intentional** — do not "fix" these panics. Example: `profilePhoto` → `profile-photo`.

### Some files are auto-generated — do not edit manually
- `docs/web/docs/api-reference.md` ← generated from `src/` doc-comments
- `docs/web/docs/configuration.md` ← generated from `template/metadata.toml` comments

Regenerate with `just docs-generate`. Edit the **source comments**, not the output files.

### metadata.toml is the single source of truth
All user configuration flows through `template/metadata.toml`. Its comments drive docs generation. When adding config options, update the comments in metadata.toml — the rest is derived.

### Language handling has a non-Latin branch
Languages zh, ja, ko, ru trigger different font handling via `_is-non-latin()` in src/. Test with at least one non-Latin language when touching font or layout code.

## Conventions

- Conventional commits (`feat:`, `fix:`, `docs:`, etc.)
- Run `just build` before committing to verify compilation
- Don't commit PDFs (handled by .gitignore and pre-commit hooks)
- Use `just compare` for visual regression testing before public-facing changes
- Read `CONTRIBUTING.md` for the full contribution workflow
