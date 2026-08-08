# Exp Resume

<div align="center">Version 0.0.2</div>

This is a simple Typst resume package designed as a practical starting point
for an ATS-friendly resume. The repository contains only reusable package code
and fictional John Doe example content. Keep real resume documents outside the
repository.

## Sample Resume

![example resume](https://raw.githubusercontent.com/tahzeer/exp-resume-template/main/example-resume.png)

## Repository Layout

- `src/` contains the reusable implementation and public helpers.
- `template/main.typ` is the John Doe starter copied by `typst init`.
- `tests/` contains regression documents for the implementation.
- `docs/architecture.md` explains the Typst package structure and release flow.
- `typst.toml` defines the package and template entrypoints.

Personal data is intentionally not stored here. A private document can live
next to the clone, for example `../main.typ`, and import the local package with:

```typst
#import "exp-resume-template/src/lib.typ": *
```

## Quick Start

Create a document from the published template:

```sh
typst init @preview/exp-resume:0.0.2
```

The generated `main.typ` contains the complete John Doe placeholder and the
available component functions. Replace its values and content with your own
information in your private document.

The central pattern is:

```typst
#import "@preview/exp-resume:0.0.2": *

#show: resume.with(
  author: "John Doe",
  email: "john.doe@example.com",
  accent-color: "#26428b",
)

== Experience

#work(
  title: "Software Engineer",
  company: "Example Corporation",
  location: "Example City, EX",
  dates: dates-helper(start-date: "Jun 2024", end-date: "Present"),
)
- Replace this placeholder with an accomplishment.
```

## Local Development

Install the package locally before compiling the package template against the
working tree:

```sh
just install-preview
typst compile template/main.typ /tmp/exp-resume-example.pdf
```

Run the repository checks with:

```sh
just ci
```

Package a release candidate with `just package out`. Generated build and test
artifacts are ignored by Git and excluded from package output.

## Versioning

The package follows [Semantic Versioning 2.0.0](https://semver.org/) and
Typst's requirement for a full `MAJOR.MINOR.PATCH` manifest version:

- `0.0.1` is the initial development release.
- Increment the patch number for backward-compatible bug fixes, such as `0.0.2`.
- Increment the minor number for backward-compatible public features, such as `0.1.0`, and reset patch to `0`.
- While the major version is `0`, breaking changes should use the next minor version because the API is still unstable, such as `0.1.0` to `0.2.0`.
- After the API stabilizes at `1.0.0`, increment the major number for breaking changes, such as `1.0.0` to `2.0.0`, and reset minor and patch to `0`.
- Never modify a released package version; publish a new version instead.

Git tags must exactly match the manifest version with a `v` prefix, for example
`v0.0.2`. The release workflow checks this before packaging.

## Publishing

The release workflow runs for a tag matching the package version, for example
`v0.0.2`. It packages the project and pushes a branch containing
`packages/preview/exp-resume/<version>` to `tahzeer/typst-packages`.

The repository needs a `REGISTRY_TOKEN` secret with permission to push to that
package-registry repository. The package can then be submitted to the official
Typst package repository following its publishing process.

## Footer

Based on and inspired by:

- [basic-typst-resume-template](https://github.com/stuxf/basic-typst-resume-template) (`@preview/basic-resume`)
- [Jake's Resume](https://github.com/sb2nov/resume) (Jake Gutierrez / sb2nov LaTeX resume)
