# Images, fonts and other resources

Typst packages can ship more than just code. This document explains how to
properly handle resource files and avoid common mistakes.

## Paths are package scoped

When reading external files, the path that is given to the function
(like `image`, `json` or `read`) is relative to the current file
and can only access files in the current package. This means it can't
access files from other packages. But more importantly, in case your package
is a template, it can't access files in the user's project.

For instance, let's say you have the following file hierarchy:

```
preview/my-template/1.0.0/
  README.md
  LICENSE
  typst.toml
  thumbnail.png
  src/
    lib.typ
  template/
    main.typ
    logo.png
```

In `lib.typ`, calling `image("../template/logo.png")` will seem to work.
But this won't refer to the copy of `logo.png` in the users project: if they
were to replace the provided logo with their own, your package would still use
the original one.

It also means that allowing for customization using a string parameter called `logo-path`
that is passed to `image` in your package won't work either: the file
access is made relatively to where the `image` function is called, not to where
the path string is created.

The proper way to let the people using your template overwrite the file to use
is to take `content` as an argument directly, not a `string`. For example, you should
replace this:

```typ
#let cover-page(logo-path: "logo.png", title) = {
  image(logo-path)
  heading(title)
}
```

With something like:

```typ
#let cover-page(logo: image("logo.png"), title) = {
  logo
  heading(title)
}
```

It is still possible to customize define some default values to configure how
the image is displayed (its width for example), using a `set image(..)` rule.

It will be possible to take paths as arguments directly, [once a dedicated
type exists][path-type].

## Fonts are not supported in packages

As of now, it is not possible to ship font files within a package. Fonts need to
be present in the user's project to be detected in the web app, or be included
with the `--font-path` argument on the command line, and a package can't
interfere with either of these.

Technically, it would be possible to ship fonts with templates by putting them into
the template directory and asking command line users to specify the correct
directory when compiling. But this experience would be suboptimal, and would
result in a lot of large font files being duplicated both in this repository and
in user projects. For these reasons, it is not allowed.

The current solution if your package requires specific fonts is simply to
document how to download them and use them in the web app or on the command
line.

This is not a perfect solution either. The situation will be improved in future Typst
versions.

## Licensing non-code assets

We have [specific guidelines][license] for licensing assets distributed in your
packages.

[path-type]: https://github.com/typst/typst/issues/971
[license]: licensing.md
