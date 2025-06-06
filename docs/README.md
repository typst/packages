# Package submission guidelines

Before creating and submitting your package, you must be aware of the rules we
are applying to packages on Typst Universe. These rules ensure that the
published packages meet some quality standards and work properly for everyone.
Please note that this list may be extended over time as improvements/issues to
the process are discovered. Given a good reason, we reserve the right to reject
any package submission. These rules are the following.

- **Functionality:** Packages should conceivably be useful to other users and
  should expose their capabilities in a reasonable fashion.
- **Security:** Packages must not attempt to exploit the compiler or packaging
  implementation, in particular not to exfiltrate user data.
- **Safety:** Names and package contents must be safe for work.
- **Size:** Packages should not contain large files or a large number of files.
  This will be judged on a case-by-case basis, but any exception should be
  well-motivated. To keep the package small and fast to download, please
  `exclude` images for the README or PDF files with documentation from the
  bundle. For more detailed guidelines, please refer to [the "What to commit?
  What to exclude?"][exclusion] section.
- **Correctness:** Typst files and the manifest should not contain any syntax
  error. More generally, your package can be imported without errors. This does
  not mean that the package must be flawless; it's always possible for bugs to
  slip in. If you find a mistake or bug after the package is accepted, you can
  simply submit a patch release. If your package includes a template, it should
  compile out-of-the-box. In particular, it should use the "absolute" package
  import and not a relative one (i.e `@preview/my-package:0.1.0` and not
  `../lib.typ`).
- **Name:** Package names should be unique enough to be easily distinguishable
  from alternative implementations. Even if your package currently is the only
  available for its purpose, its name should not be canonical, to leave room for
  potential future alternatives. Some exceptions exists, and are detailed in
  our [Naming rules].
- **Licensing:** The license provided in the package manifest should match the
  contents of the license file. The authors and copyright year in the license file should
  be correct. Your package should not contain any copyrighted material for
  which you don't have distribution rights.
- **Documentation:** Your package must include a `README.md` file, documenting
  its purpose succintly. This README should include examples, and may contain
  illustrations. Examples in the README and other documentation files should be
  up-to-date and compile. In particular, version numbers in package imports should
  be updated with each release.

If you don't meet our requirements, it may take a bit more time for your package
to be published, as we will ask you to make changes, but it will not prevent
your package from being published once the required changes are made.

## Package submission in practice

Once you checked that your package meets all the above criteria, make a pull
request with the package to this repository. Start by cloning the repository (we
recommend using a [sparse checkout][sparse-checkout]), and create a new
directory for your package named
`packages/{namespace}/{package-name}/{version}`. For now, the only allowed
namespace is `preview`. You can then [copy your package files][exclusion] here,
commit your changes and open a pull request.

> [!NOTE]
> The author of a package update should be the same person as the one
> who submitted the previous version. If not, the previous author will be asked
> before approving and publishing the new version.

We have collected tips to make your experience as a package author easier and to
avoid common pitfalls. They are split in the following categories:

- your [package manifest][manifest]
- your [Typst files][typst] (including template and example files)
- [images, fonts and other assets][resources]
- the [README file, and documentation in general][documentation]
- the [license] of your package

When a package's PR has been merged and CI has completed, the package will be
available for use. However, it can currently take a longer while until the
package will be visible on [Typst Universe][universe]. We'll reduce this delay
in the future.

## Fixing or removing a package

Once submitted, a package will not be changed or removed without good reason to
prevent breakage for downstream consumers. By submitting a package, you agree
that it is here to stay. If you discover a bug or issue, you can of course
submit a new version of your package.

[sparse-checkout]: tips.md#sparse-checkout-of-the-repository
[exclusion]: tips.md#what-to-commit-what-to-exclude
[manifest]: manifest.md
[typst]: typst.md
[resources]: resources.md
[documentation]: documentation.md
[license]: licensing.md
[universe]: https://typst.app/universe/
[Naming rules]: manifest.md#naming-rules