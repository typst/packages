# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Brilliant CV is a Typst package for creating modular, multilingual CVs and cover letters. It's published to the Typst Universe at `@preview/brilliant-cv`.

## Development Commands

All commands use `just` (task runner). Run `just` to see available commands.

```bash
just link     # Required before development - registers local package with Typst
just dev      # Watch mode with auto-cleanup on exit
just build    # Compile template/cv.typ to temp/cv.pdf
just open     # Build and open PDF
just unlink   # Restore to using upstream package version
just reset    # Unlink + clean artifacts
```

Manual compilation:
```bash
typst compile template/cv.typ temp/cv.pdf
typst compile cv.typ --input language=fr  # Override language via CLI
```

**Important**: Always run `just link` before local development. Typst cannot resolve `@preview/brilliant-cv` imports without this step.

## Architecture

### Directory Structure

- `src/` - Core package code (this is what gets published)
  - `lib.typ` - Package entry point, exports `cv()` and `letter()` functions
  - `cv.typ` - CV header, footer, sections, and entry components
  - `letter.typ` - Cover letter layout
  - `utils/` - Language detection, styles, keyword injection

- `template/` - User-facing starter project (what users get from `typst init`)
  - `cv.typ`, `letter.typ` - Entry points that import from the package
  - `metadata.toml` - Central configuration (colors, fonts, personal info, language)
  - `modules_<lang>/` - Content files per language (professional.typ, education.typ, etc.)

### Key Patterns

**Configuration-driven**: All customization goes through `metadata.toml`. Document new TOML keys when adding them.

**State management**: `cv-metadata` Typst state variable holds metadata to avoid passing it to every function.

**Backward compatibility**: When renaming parameters, support both old (camelCase) and new (kebab-case) names using the aliasing pattern in `src/lib.typ`. Never remove parameters without deprecation.

**Language handling**: Language is set in `metadata.toml` or overridden via `--input language=xx`. Non-Latin languages (zh, ja, ko, ru) trigger different font handling.

## CI/CD

- `compile.yaml` - Validates template compiles on push/PR
- `release-and-publish.yaml` - Publishes to Typst Universe on version tags (vX.Y.Z)

The CI copies package files to Typst's cache directory to resolve imports. Local development uses `utpm ws link` instead.

## Contribution Guidelines

- Keep `src/` backward compatible - use parameter aliasing for renames
- Update `metadata.toml` comments and README when adding new configuration options
- Use conventional commits
- Run `just build` before committing to verify compilation
- Don't commit PDFs (handled by .gitignore and pre-commit hooks)

## Development Workflow

**Git worktrees**: Use `.worktrees/` directory for isolated feature development. This keeps work separate from the main workspace while sharing the same repository.
