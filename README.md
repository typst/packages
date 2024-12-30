# Typst Packages
The package repository for Typst, where package authors submit their packages.
The packages submitted here are available on [Typst Universe][universe].

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
license = "MIT"
description = "An example package."
```

Required by the compiler:
- `name`: The package's identifier in its namespace.
- `version`: The package's version as a full major-minor-patch triple.
  Package versioning should follow [SemVer].
- `entrypoint`: The path to the main Typst file that is evaluated when the
  package is imported.

Required for submissions to this repository:
- `authors`: A list of the package's authors. Each author can provide an email
  address, homepage, or GitHub handle in angle brackets. The latter must start
  with an `@` character, and URLs must start with `http://` or `https://`.
- `license`: The package's license. Must contain a valid SPDX-2 expression
  describing one or multiple [OSI-approved][OSI] licenses.
- `description`: A short description of the package. Double-check this for
  grammar and spelling mistakes as it will appear in the [package list][list].

Optional:
- `homepage`: A link to the package's web presence, where there could be more
  details, an issue tracker, or something else. Will be linked to from the
  package list.
- `repository`: A link to the repository where this package is developed. Will
  be linked to from the package list if there is no homepage.
- `keywords`: An array of search keywords for the package.
- `categories`: An array with up to three categories from the
  [list of categories][categories] to help users discover the package.
- `disciplines`: An array of [disciplines] defining the target audience for
  which the package is useful. Should be empty if the package is generally
  applicable.
- `compiler`: The minimum Typst compiler version required for this package to
  work.
- `exclude`: An array of globs specifying files that should not be part of the
  published bundle that the compiler downloads when importing the package. To be
  used for large support files like images or PDF documentation that would
  otherwise unnecessarily increase the bundle size. Don't exclude the README or
  the LICENSE.

Packages always live in folders named as `{name}/{version}`. The name and
version in the folder name and manifest must match. Paths in a package are local
to that package. Absolute paths start in the package root, while relative paths
are relative to the file they are used in.

### Templates
Packages can act as templates for user projects. In addition to the module that
a regular package provides, a template package also contains a set of template
files that Typst copies into the directory of a new project.

In most cases, the template files should not include the styling code for the
template. Instead, the template's entrypoint file should import a function from
the package. Then, this function is used with a show rule to apply it to the
rest of the document.

Template packages (also informally called templates) must declare the
`[template]` key in their `typst.toml` file. A template package's `typst.toml`
could look like this:

```toml
[package]
name = "charged-ieee"
version = "0.1.0"
entrypoint = "lib.typ"
authors = ["Typst GmbH <https://typst.app>"]
license = "MIT-0"
description = "An IEEE-style paper template to publish at conferences and journals for Electrical Engineering, Computer Science, and Computer Engineering"

[template]
path = "template"
entrypoint = "main.typ"
thumbnail = "thumbnail.png"
```

Required by the compiler:
- `path`: The directory within the package that contains the files that should
  be copied into the user's new project directory.
- `entrypoint`: A path _relative to the template's path_ that points to the file
  serving as the compilation target. This file will become the previewed file in
  the Typst web application.

Required for submissions to this repository:
- `thumbnail`: A path relative to the package's root that points to a PNG or
  lossless WebP thumbnail for the template. The thumbnail must depict one of the
  pages of the template **as initialized.** The longer edge of the image must be
  at least 1080px in length. Its file size must not exceed 3MB. Exporting a PNG
  at 250 DPI resolution is usually a good way to generate a thumbnail. You are
  encouraged to use [oxipng] to reduce the thumbnail's file size. The thumbnail
  will automatically be excluded from the package files and must not be
  referenced anywhere in the package.

Template packages must specify at least one category in `package.categories`.

If you're submitting a template, please test that it works locally on your
system. The recommended workflow for this is as follows:

- Add a symlink from `$XDG_DATA_HOME/typst/packages/preview` to the `preview`
  folder of your fork of this repository (see the section on [local
  packages](#local-packages)).
- Run `typst init @preview/mypkg:version`. Note that you must manually specify
  the version as the package is not yet in the index, so the latest version
  won't be detected automatically.
- Compile the freshly instantiated template.

### Third-party metadata
Third-party tools can add their own entry under the `[tool]` section to attach
their Typst-specific configuration to the manifest.

```toml
[package]
# ...

[tool.mytool]
foo = "bar"
```

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

### Submission guidelines
To submit a package, simply make a pull request with the package to this
repository. There are a few requirements for getting a package published, which
are detailed below:

- **Naming:** Package names should not be the obvious or canonical name for a
  package with that functionality (e.g. `slides` is forbidden, but `sliding` or
  `slitastic` would be ok). We have this rule because users will find packages
  with these canonical names first, creating an unfair advantage for the package
  author who claimed that name. Names should not include the word "typst" (as it
  is redundant). If they contain multiple words, names should use `kebab-case`.
  Look at existing packages and PRs to get a feel for what's allowed and what's
  not.

  *Additional guidance for template packages:* It is often desirable for
  template names to feature the name of the organization or publication the
  template is intended for. However, it is still important to us to accommodate
  multiple templates for the same purpose. Hence, template names shall consist
  of a unique, non-descriptive part followed by a descriptive part. For example,
  a template package for the fictitious _American Journal of Proceedings (AJP)_
  could be called `organized-ajp` or `eternal-ajp`. Package names should be
  short and use the official entity abbreviation. Template authors are
  encouraged to add the full name of the affiliated entity as a keyword.

  The unamended entity name (e.g. `ajp`) is reserved for official template
  packages by their respective entities. Please make it clear in your PR if you
  are submitting an official package. We will then outline steps to authenticate
  you as a member of the affiliated organization.

  If you are an author of an original template not affiliated with any
  organization, only the standard package naming guidelines apply to you.

- **Functionality:** Packages should conceivably be useful to other users and
  should expose their capabilities in a reasonable fashion.

- **Documentation:** Packages must contain a `README.md` file documenting (at
  least briefly) what the package does and all definitions intended for usage by
  downstream users. Examples in the README should show how to use the package
  through an `@preview` import. If you have images in your README, you might
  want to check whether they also work in dark mode. Also consider running
  [`typos`][typos] through your package before release.

- **Style:** No specific code style is mandated, but two spaces of indent and
  kebab-case for variable and function names are recommended.

- **License:** Packages must be licensed under the terms of an
  [OSI-approved][OSI] license. In addition to specifying the license in the
  TOML manifest, a package must either contain a `LICENSE` file or link to one
  in its `README.md`.

  *Additional details for template packages:* If you expect the package
  license's provisions to apply to the contents of the template directory (used
  to scaffold a project) after being modified through normal use, especially if
  it still meets the _threshold of originality,_ you must ensure that users of
  your template can use and distribute the modified contents without
  restriction. In such cases, we recommend licensing at least the template
  directory under a license that requires neither attribution nor distribution
  of the license text. Such licenses include MIT-0 and Zero-Clause BSD. You can
  use an SPDX AND expression to selectively apply different licenses to parts of
  your package. In this case, the README or package files must make clear under
  which license they fall. If you explain the license distinction in the README
  file, you must not exclude it from the package.

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

When a package's PR has been merged and CI has completed, the package will be
available for use. However, it can currently take a longer while until the
package will be visible on [Typst Universe][universe]. We'll reduce this delay
in the future.

Once submitted, a package will not be changed or removed without good reason to
prevent breakage for downstream consumers. By submitting a package, you agree
that it is here to stay. If you discover a bug or issue, you can of course
submit a new version of your package.

There is one exception: Minor fixes to the documentation or TOML metadata of a
package are allowed _if_ they can not affect the package in a way that might
break downstream users.

### Downloads
The Typst compiler downloads packages from the `preview` namespace on-demand.
Once used, they are cached in `{cache-dir}/typst/packages/preview` where
`{cache-dir}` is

- `$XDG_CACHE_HOME` or `~/.cache` on Linux
- `~/Library/Caches` on macOS
- `%LOCALAPPDATA%` on Windows

Importing a cached package does not result in network access.

## Local packages
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

## License
The infrastructure around the package repository is licensed under the terms of
the Apache-2.0 license. Packages in `packages/` are licensed under their
respective license.

[list]: https://typst.app/universe/search/
[universe]: https://typst.app/universe/
[categories]: https://github.com/typst/packages/blob/main/CATEGORIES.md
[disciplines]: https://github.com/typst/packages/blob/main/DISCIPLINES.md
[SemVer]: https://semver.org/
[OSI]: https://opensource.org/licenses/
[typos]: https://github.com/crate-ci/typos
[oxipng]: https://github.com/shssoichiro/oxipng
