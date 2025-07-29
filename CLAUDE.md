# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Typst packages repository containing template packages for the Typst typesetting system. The repository follows the Typst package repository structure with packages stored in `packages/preview/{name}/{version}/`.

Currently contains:
- **enseeiht-internship-report**: A French internship report template for ENSEEIHT engineering school

## Repository Structure

```
typst-packages/
├── packages/
│   └── preview/
│       └── enseeiht-internship-report/
│           └── 0.1.0/
│               ├── typst.toml          # Package manifest
│               ├── template.typ        # Main template function
│               ├── main.typ           # Example usage
│               ├── sources.yml        # Bibliography example
│               └── asset/             # Template assets (logos, examples)
├── LICENSE                            # Repository license
└── README.md                         # Repository documentation
```

## Working with Typst Packages

### Compilation Commands

**Compile a Typst file:**
```bash
typst compile filename.typ
```

**Watch for changes (auto-recompile):**
```bash
typst watch filename.typ
```

**Initialize new project from template:**
```bash
typst init @preview/enseeiht-internship-report:0.1.0
```

### Package Development

**Package structure requirements:**
- Each package must have a `typst.toml` manifest at its root
- Template packages require `entrypoint` and `template.path` fields
- Version directories follow semantic versioning (e.g., `0.1.0`)

**Testing template compilation:**
For local testing, the template references `@local/enseeiht-internship-report:0.1.0` which requires installing the package locally in the Typst data directory.

## Package-Specific Information

### enseeiht-internship-report Template

**Purpose:** French internship report template for ENSEEIHT engineering school

**Key files:**
- `template.typ:1-98`: Main template function with cover page and document styling
- `main.typ:1-59`: Example usage showing all template parameters
- `sources.yml:1-14`: Bibliography configuration example

**Template features:**
- Bilingual support (French primary)
- Cover page with dual logos (school + company)
- Automatic heading numbering (I.1.1.1 format)
- Header/footer with logos on all pages
- Bibliography integration
- Multi-tutor support

**Usage pattern:**
```typst
#import "@preview/enseeiht-internship-report:0.1.0": cover
#show: doc => cover(/* parameters */, doc)
```

## File Locations

**Main template logic:** `packages/preview/enseeiht-internship-report/0.1.0/template.typ:12-98`
**Example document:** `packages/preview/enseeiht-internship-report/0.1.0/main.typ:4-33`
**Package metadata:** `packages/preview/enseeiht-internship-report/0.1.0/typst.toml:1-15`