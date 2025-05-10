# The content of a Typst package

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
  describing one or multiple licenses that are either [OSI-approved][OSI]
  licenses or a version of CC-BY, CC-BY-SA, or CC0. We recommend you do not
  license your package using a Creative Commons license unless it is a
  derivative work of a CC-BY-SA-licensed work or if it is not primarily code,
  but content or data. In most other cases, [a free/open license specific to
  software is better suited for Typst packages](https://creativecommons.org/faq/#can-i-apply-a-creative-commons-license-to-software).
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
  folder of your fork of this repository (see the documentation on [local
  packages][local-packages]).
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


[list]: https://typst.app/universe/search/
[categories]: https://github.com/typst/packages/blob/main/CATEGORIES.md
[disciplines]: https://github.com/typst/packages/blob/main/DISCIPLINES.md
[SemVer]: https://semver.org/
[OSI]: https://opensource.org/licenses/
[oxipng]: https://github.com/shssoichiro/oxipng
[local-packages]: ../README.md#local-packages
