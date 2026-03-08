# Licensing your package

Packages must be licensed under the terms of an [OSI-approved][OSI] license or a
version of CC-BY, CC-BY-SA, or CC0. We recommend you do not license your package
using a Creative Commons license unless it is a derivative work of a
CC-BY-SA-licensed work or if it is not primarily code, but content or data. In
most other cases, [a free/open license specific to software is better suited for
Typst packages][cc-faq]. If different files in your package are under different
licenses, it should be stated clearly (in your README for example) which license
applies to which file.

In addition to specifying the license in the TOML manifest, a package must
either contain a `LICENSE` file or link to one in its `README.md`.

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

## Copyrighted material

Sometimes you may want to distribute assets which are not under an open-source
license, for example, the logo of a university. Typst Universe allows you to
distribute those assets only if the copyright holder has a policy that clears
distribution of the asset in the package.

If you are including such assets in your package, have your README clearly
indicate which files are not covered by the license given in the manifest file
and include or link to the relevant terms by the copyright holder.

[cc-faq]: https://creativecommons.org/faq/#can-i-apply-a-creative-commons-license-to-software
[OSI]: https://opensource.org/licenses/
