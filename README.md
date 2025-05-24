# Typst Packages
The package repository for Typst, where package authors submit their packages.
The packages submitted here are available on [Typst Universe][universe].

## Published packages
This repository contains a collection of published packages. Due to its early
and experimental nature, all packages in this repository are scoped in a
`preview` namespace. A package that is stored in
`packages/preview/{name}/{version}` in this repository will become available in
Typst as `#import "@preview/{name}:{version}"`. You must always specify the full
package version.

You can use template packages to create new Typst projects with the CLI with
the `typst init` command or the web application by clicking the _Start from
template_ button.

### Downloads
The Typst compiler downloads packages from the `preview` namespace on-demand.
Once used, they are cached in `{cache-dir}/typst/packages/preview` where
`{cache-dir}` is

- `$XDG_CACHE_HOME` or `~/.cache` on Linux
- `~/Library/Caches` on macOS
- `%LOCALAPPDATA%` on Windows

Importing a cached package does not result in network access.

### Local packages
Want to install a package locally on your system without publishing it or
experiment with it before publishing? You can store packages in
`{data-dir}/typst/packages/{namespace}/{name}/{version}` to make them available
locally on your system. Here, `{data-dir}` is

- `$XDG_DATA_HOME` or `~/.local/share` on Linux
- `~/Library/Application Support` on macOS
- `%APPDATA%` on Windows

Packages in the data directory have precedence over ones in the cache directory.
While you can create arbitrary namespaces with folders, a good namespace for
system-local packages is `local`:

- Store a package in `~/.local/share/typst/packages/local/mypkg/1.0.0`
- Import from it with `#import "@local/mypkg:1.0.0": *`

Note that future iterations of Typst's package management may change/break this
local setup.


## Documentation for authors of Typst packages
If you want to write your own Typst packages and share them on this repository.
please see our more detailed documentation pages:

- [Packaging guidelines](doc/packaging-guidelines.md): the rules that Typst packages should follow. You should
  start with this, in particular there are guidelines on the choice of package name.
- [Package content](doc/package-content.md): the layout and content of Typst packages, and the format of `typst.toml`.
- [Submitting a package](doc/submitting-a-package.md): the concrete process to submit a package to this repository.


## License
The infrastructure around the package repository is licensed under the terms of
the Apache-2.0 license. Packages in `packages/` are licensed under their
respective license.

[universe]: https://typst.app/universe/
