# Package submission guidelines

To submit a package, make a pull request with the package to this
repository. Start by cloning the repository (we recommend using a [sparse
checkout][sparse-checkout]), and create a new directory for your package named
`packages/{namespace}/{package-name}/{version}`. For now, the only allowed
namespace is `preview`. You can then [copy your package files][copy] here,
commit your changes and open a pull request.

We have guidelines that you have to follow for your package to be published on
Typst Universe. They ensure that the published packages meet some quality
standards and work properly for everyone. Please note that this list may be
extended over time as improvements/issues to the process are discovered. Given a
good reason, we reserve the right to reject any package submission.

The following links will teach you what to pay attention to when working on:

- your [package manifest][manifest]
- your [Typst files][typst] (including template and example files)
- [images, fonts and other assets][resources]
- the [README file, and documentation in general][documentation]
- the [license] of your package

On top of that, there are some general requirements for getting a package
published:

- **Functionality:** Packages should conceivably be useful to other users and
  should expose their capabilities in a reasonable fashion.

- **Security:** Packages must not attempt to exploit the compiler or packaging
  implementation, in particular not to exfiltrate user data.

- **Safety:** Names and package contents must be safe for work.

- **Size:** Packages should not contain large files or a large number of files.
  This will be judged on a case-by-case basis, but if it needs more than ten
  files, it should be well-motivated. To keep the package small and fast to
  download, please `exclude` images for the README or PDF files with
  documentation from the bundle. Alternatively, you can link to images hosted on
  a githubusercontent.com URL (just drag the image into an issue).

To make sure you are following our guidelines before submission, you can use
[this checklist][checklist]. If you don't meet our requirements, it may take a
bit more time for your package to be published, as we will ask you to make
changes, but it will not prevent your package from being published once the
required changes are made.

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
[copy]: tips.md#what-to-commit-what-to-exclude
[manifest]: manifest.md
[typst]: typst.md
[resources]: resources.md
[documentation]: documentation.md
[license]: licensing.md
[checklist]: checklist.md
[universe]: https://typst.app/universe/
