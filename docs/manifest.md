# Writing a package manifest

A Typst package should contain a file named `typst.toml`. It is called the
"package manifest" or "manifest" for short. This file contains metadata about
the package, such as its name, version or the names of its authors.

As suggested by the extension, manifest are written in [TOML].

## Package metadata

The only required section ("table" in TOML lingo) is named `package`
and contains most of the metadata about your package. Here is an example
of what it can look like.

```toml
[package]
name = "example"
version = "0.1.0"
entrypoint = "lib.typ"
authors = ["The Typst Project Developers"]
license = "MIT"
description = "Calculate elementary arithemtics with functions."
```

The following fields are required by the compiler:

- `name`: The package's identifier in its namespace. We have some specific rules
  for packages submitted to Typst Universe, detailed [below].
- `version`: The package's version as a full major-minor-patch triple.
  Package versioning should follow [SemVer].
- `entrypoint`: The path to the main Typst file that is evaluated when the
  package is imported.

If you plan to use your package only on your machine or to distribute
it by your own means, you don't have to include more than these three fields.
However, for your package to be published on Typst Universe, a few more fields
are required.

Required for submissions to this repository:

- `authors`: A list of the package's authors. Each author can provide an email
  address, homepage, or GitHub handle in angle brackets. The latter must start
  with an `@` character, and URLs must start with `http://` or `https://`.
- `license`: The package's license. Must contain a valid SPDX-2 expression
  describing one or multiple licenses. Please make sure to meet our [licensing
  requirements][license] if you want to submit your package to Typst Universe.
- `description`: A short description of the package. Double-check this for
  grammar and spelling mistakes as it will appear in the [package list][list].
  If you want some tips on how to write a great description, you can refer to
  [the dedicated section below][description].

Optional:

- `homepage`: A link to the package's web presence, where there could be more
  details, an issue tracker, or something else. Will be linked to from the
  package list. If there is no dedicated web page for the package, don't link to
  its repository here. Omit this field and prefer `repository`.
- `repository`: A link to the repository where this package is developed. Will
  be linked to from Typst Universe if there is no homepage.
- `keywords`: An array of search keywords for the package.
- `categories`: An array with up to three categories from the
  [list of categories][categories] to help users discover the package.
- `disciplines`: An array of [disciplines] defining the target audience for
  which the package is useful. Should be empty if the package is generally
  applicable.
- `compiler`: The minimum Typst compiler version required for this package to
  work.
- `exclude`: An array of globs specifying files that should not be part of the
  published bundle that the compiler downloads when importing the package. These
  files will still be available on typst universe to link to from the README.\
  To be used for large support files like images or PDF documentation that would
  otherwise unnecessarily increase the bundle size. Don't exclude the README or
  the LICENSE, see [what to exclude].

Packages always live in folders named as `{name}/{version}`. The name and
version in the folder name and manifest must match. Paths in a package are local
to that package. Absolute paths start in the package root, while relative paths
are relative to the file they are used in.

### Naming rules

Package names should not be the obvious or canonical name for a package with
that functionality (e.g. `slides` is forbidden, but `sliding` or `slitastic`
would be ok). We have this rule because users will find packages with these
canonical names first, creating an unfair advantage for the package author who
claimed that name. Names should not include the word "typst" (as it is
redundant). If they contain multiple words, names should use `kebab-case`. Look
at existing packages and PRs to get a feel for what's allowed and what's not.

*Additional guidance for template packages:* It is often desirable for template
names to feature the name of the organization or publication the template is
intended for. However, it is still important to us to accommodate multiple
templates for the same purpose. Hence, template names shall consist of a unique,
non-descriptive part followed by a descriptive part. For example, a template
package for the fictitious _American Journal of Proceedings (AJP)_ could be
called `organized-ajp` or `eternal-ajp`. Package names should be short and use
the official entity abbreviation. Template authors are encouraged to add the
full name of the affiliated entity as a keyword.

The unamended entity name (e.g. `ajp`) is reserved for official template
packages by their respective entities. Please make it clear in your PR if you
are submitting an official package. We will then outline steps to authenticate
you as a member of the affiliated organization.

If you are an author of an original template not affiliated with any
organization, only the standard package naming guidelines apply to you.

These rules also apply to names in other languages, including transliterations
for languages that are not generally written using the Latin alphabet.

### Writing a good description

A good package description is simple, easily understandable and succinct. Here
are some rules to follow to write great descriptions:

- Keep it short. Try to maximize the content to length ratio and weigh your words
  thoughtfully. Ideally, it should be 40 to 60 characters long.

- Terminate your description with a full stop.

- Avoid the word "Typst", which is redundant unless your package or template
  actually has to do with Typst itself or its ecosystem (like in the case of
  [mantys] or [t4t]).

- Avoid the words "package" for packages and "template" for templates; instead:
  - Packages allow the user to *do* things; use the imperative mood. For
    example, `Draw Venn diagrams.` is better than `A package for drawing Venn
    diagrams.`.
  - Templates allow the user to write certain *types* of documents; clearly
    indicate the type of document your template allows. For example, `Master’s
    thesis at the Unseen University.` is better than `A template for writing a
    master’s thesis at the Unseen University.`. Omit the indefinite article ("A
    …", "An …") at the beginning of the description for conciseness.

## Templates

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
description = "IEEE-style paper to publish at conferences and journals."

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
  at least 1080 px in length. Its file size must not exceed 3 MiB. Exporting a
  PNG at 250 PPI resolution is usually a good way to generate a thumbnail. You
  can use the following command for that: `typst compile -f png --pages 1 --ppi
  250 main.typ thumbnail.png`. You are encouraged to use [oxipng] to reduce the
  thumbnail's file size. The thumbnail will automatically be excluded from the
  package files and must not be referenced anywhere in the package.

Template packages must specify at least one category in `categories` (under the
`[package]` section).

If you're submitting a template, please test that it works locally on your
system. The recommended workflow for this is as follows:

- Add a symlink from `$XDG_DATA_HOME/typst/packages/preview` to the `preview`
  folder of your fork of this repository (see the documentation on [local
  packages]).
- Run `typst init @{namespace}/{name}:{version}`. Note that you must manually specify
  the version as the package is not yet in the index, so the latest version
  won't be detected automatically.
- Compile the freshly instantiated template.

## Third-party metadata

Third-party tools can add their own entry under the `[tool]` section to attach
their Typst-specific configuration to the manifest.

```toml
[package]
# ...

[tool.mytool]
foo = "bar"
```

[TOML]: https://toml.io/
[below]: #naming-rules
[list]: https://typst.app/universe/search/
[categories]: CATEGORIES.md
[disciplines]: DISCIPLINES.md
[mantys]: https://typst.app/universe/package/mantys/
[t4t]: https://typst.app/universe/package/t4t
[local packages]: ../README.md#local-packages
[SemVer]: https://semver.org/
[oxipng]: https://github.com/shssoichiro/oxipng
[license]: licensing.md
[description]: #writing-a-good-description
[what to exclude]: tips.md#what-to-commit-what-to-exclude
