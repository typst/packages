# Typst packaging guidelines

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


[OSI]: https://opensource.org/licenses/
[typos]: https://github.com/crate-ci/typos
