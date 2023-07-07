# Typst Packages
An experimental package repository for Typst. A [searchable list][list] of all
packages that were submitted here is available in the official documentation.

## Package format
A package is a collection of Typst files and assets that can be imported as a
unit. A `typst.toml` manifest with metadata is required at the root of a
package. An example manifest could look like this:

```toml
[package]
name = "example"
version = "0.1.0"
entrypoint = "lib.typ"
authors = ["The Typst Project Developers"]
license = "Unlicense"
description = "An example package."
```

Required by the compiler:
- `name`: The package's identifier in its namespace.
- `version`: The package's version as a full major-minor-patch triple.
  Package versioning should follow [SemVer].
- `entrypoint`: The path to the main Typst file that is evaluated when the
  package is imported.

Required for submissions to this repository:
- `authors`: A list of the package's authors.
- `license`: The package's license. Must contain a valid SPDX-2 expression
  describing one or multiple [OSI-approved][OSI] licenses.
- `description`: A short description of the package. Double check this for
  grammar and spelling mistakes as it will appear in the [package list][list].

Optional:
- `repository`: A link to the repository where this package is developed.
- `exclude`: An array of globs specifying files that should not be part of the
  published bundle that the compiler downloads when importing the package. To be
  used for support files like images or documentation that would otherwise
  unnecessarily increase the bundle size.

Packages always live in folders named as `{name}-{version}`. The name and
version in the folder name and manifest must match. Paths in a package are local
to that package. Absolute paths start in the package root while relative paths
are relative to the file they are used in.

## Published packages
This repository contains a collection of published packages. Due to its early
and experimental nature, all packages in this repository are scoped in a
`preview` namespace. A package that is stored in
`packages/preview/{name}-{version}` in this repository will become availabe in
Typst as `#import "@preview/{name}:{version}"`. You must always specify the full
package version.

### Submission guidelines
To submit a package, simply make a pull request with the package to this
repository. There are a few requirements for getting a package published, which
are detailed below:

- **Naming:** Package names should not be merely descriptive to create level
  grounds for everybody (e.g. `slides` is forbidden, but `sliding` or
  `slitastic` would be ok). Names should not include the word "typst" (as it is
  redundant). If they contain multiple words, names should use `kebab-case`.
  Look at existing packages and PRs to get a feel for what's allowed and what's
  not.
- **Functionality:** Packages should conceivably be useful to other users and
  should expose their capabilities in a reasonable fashion.
- **Documentation:** Packages must contain a `README.md` file documenting (at
  least briefly) what the package does and all definitions intended for usage by
  downstream users. Examples in the README should show how to use the package
  through an `@preview` import. If you have images in your README, you might
  want to check whether they also work in dark mode.
- **Style:** No specific code style is mandated, but two spaces of indent and
  kebab-case for variable and function names are recommended.
- **License:** Packages must be licensed under the terms of an
  [OSI-approved][OSI] license. In addition to specifying the license in the
  TOML manifest, a package must either contain a `LICENSE` file or link to one
  in its `README.md`.
- **Size:** Packages should not contain large files or a large number of files.
  This will be judged on a case-by-case basis, but if it needs more than ten
  files, it should be well-motivated. To keep the package small and fast to
  download, please `exclude` images for the README or PDF files with
  documentation from the bundle. Alternatively, you can link to images hosted on
  a githubusercontent.com URL (just drag the image into an issue).
- **Security:** Packages must not attempt to exploit the compiler or packaging
  implementation, in particular not to exfiltrate user data.
- **Safety:** Names and package contents must be safe for work.

This list may be extended over time as improvements/issues to the process are
discovered. Given a good reason, we reserve the right to reject any package submission.

Once submitted, a package will not be changed or removed without good reason to
prevent breakage for downstream consumers. By submitting a package, you agree
that it is here to stay. If you discover a bug or issue, you can of course
submit a new version of your package.

There is one exception: Minor fixes to the documentation or TOML metadata of a
package are allowed _if_ they can not affect the package in a way that might
break downstream users.

**Note:** Please do not submit templates as packages just yet. We plan to build
infrastructure around this so that they can show up in the web app's template
gallery and be used to scaffold a project through the CLI. Stay tuned!

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


## License
The infrastructure around the package repository is licensed under the terms of
the Apache-2.0 license. Packages in `packages/` are licensed under their
respective license.

[list]: https://typst.app/docs/packages/
[SemVer]: https://semver.org/
[OSI]: https://opensource.org/licenses/
