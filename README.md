# Typst Packages
An experimental package repository for Typst. Packages from this repository can
be imported (or included) in Typst with `#import "@preview/{name}:{version}`.
You must always specify the full package version.

## Package format
A package is a collection of Typst files and assets that can be imported as a
unit. A `typst.toml` manifest with metadata is required at the root of a
package. The manifest format is as follows:

```toml
[package]
name = "example"
version = "0.1.0"
entrypoint = "lib.typ"
description = "An example package."
```

Keys:
- `name`: The package's identifier in its namespace.
- `version`: The package's version as a full major-minor-patch triple.
  Package versioning should follow [SemVer].
- `entrypoint`: The path to the main Typst file that is evaluated when the
  package is imported.
- `description`: A short description of the package.

Packages always live in folders named as `{name}-{version}`. The name and
version in the folder name and manifest must match.

Paths in a package are local to that package. Absolute paths start in the
package root while relative paths are relative to the file they are used in.

## Published packages
This repository contains a collection of published packages. Due to its early
and experimental nature, all packages in this repository are scoped in a
`preview` namespace. A package that is stored in
`packages/preview/{name}-{version}` in this repository becomes availabe in Typst
as `#import "@preview/{name}:{version}"`.

### Submission guidelines
There are a few requirements for getting a package published, which are
detailed below:

- **Naming:** Names should not include the word "typst" (as it is redundant).
  They should also not be merely descriptive to create level grounds for
  everybody (e.g. not just `slides`).
- **Documentation:** Packages should contain a `README.md` file documenting (at
  least briefly) what the package does and what definitions it exports.
- **Size:** Packages should not contain large files or a large number of files.
  This will be judged on a case-by-case basis, but if it needs more than ten
  files, it should be well-motivated.
- **License:** Packages must be licensed under the terms of an OSI-approved
  license.
- **Safety:** Names and package contents must be safe for work.

This list may be extended over time as improvements/issues to the process are
discovered. Given a good reason, we reserve the right to reject any package submission.

Once submitted, a package will not be changed or removed without good reason to
prevent breakage for downstream consumers. By submitting a package, you agree
that it is here to stay. If you discover a bug or issue, you can of course
submit a new version of your package.

### Downloads
The Typst compiler downloads packages from the `preview` namespace on-demand.
Once used, they are cached in `{cache-dir}/typst/packages/preview` where
`{cache-dir}` is

- `$XDG_CACHE_HOME` or `~/.cache` on Linux
- `~/Library/Caches` on macOS
- `%LOCALAPPDATA%` on Windows

Importing a cached package does not result in a network access.

## Local packages
Want to install a package locally on your system without publishing it or
experiment with it before publishing? You can store packages in
`{data-dir}/typst/packages/{namespace}/{name}-{version}` to make them available
locally on your system. Here, `{data-dir}` is

- `$XDG_DATA_HOME` or `~/.local/share` on Linux
- `~/Library/Application Support` on macOS
- `%APPDATA%` on Windows

Packages in the data directory have precedence over ones in the cache directory.
While you can create arbitrary namespaces with folders, a good namespace for
system packages is `local`:

- Store a package in `~/.local/share/typst/packages/local/mypkg-1.0.0`
- Import from it with `#import "@local/mypkg:1.0.0": *`

Note that future iterations of Typst's package management may change/break this
local setup.

[SemVer]: https://semver.org/lang/de/
