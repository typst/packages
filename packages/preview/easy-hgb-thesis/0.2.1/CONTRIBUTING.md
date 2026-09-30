# Contributing

Issues and pull requests are welcome.

- Open an issue for bugs, feature requests, or campus-specific adjustments.
- Open a pull request for fixes, style improvements, localization updates, and documentation improvements.

Feedback from real thesis usage is especially valuable to keep the template robust and practical.

End-user documentation (installing and using the published package) lives in [README.md](README.md).

## Project setup

You need [git](https://git-scm.com/) and [mise](https://mise.jdx.dev/) (recommended; it pins Typst and Typstyle versions from this repository).

Clone the repository:

```bash
git clone https://github.com/TimerErTim/hagenberg-thesis-typst.git
cd hagenberg-thesis-typst
```

Install the tools configured at the repository root:

```bash
mise install
```

From the root, useful tasks include:

- `mise run fmt:typst` — format Typst sources under the root, `components/`, and `template/`
- `mise run build:thumbnail` — rebuild package thumbnails (see root `mise.toml` for dependencies)

The root `mise.toml` sets `TYPST_ROOT`, font paths, and optional local package paths for development and publishing workflows.

## Example project and PDF export

The publishable example thesis lives in `template/`. That directory has its own `mise.toml` (Typst/Typstyle versions, `TYPST_ROOT`, and font path for the example).

Build the example PDF:

```bash
cd template
mise install
mise run export
```

By default, `template/main.typ` imports the published package (`@preview/easy-hgb-thesis`). To exercise your local changes instead, point the import at the workspace library:

```typ
#import "../lib.typ": full-thesis
```

Alternatively you can setup local package registry, that simulates the published package locally. This is useful for development and testing:

```bash
mise run setup:local-packages
```

## Repository layout

- `lib.typ` — package entrypoint re-exported by the published template
- `components/` — template API, sections, i18n, and default styles
- `template/` — `typst init` scaffold and runnable example
- `typst.toml` — package name, version, compiler requirement, and template metadata
