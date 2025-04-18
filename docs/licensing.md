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

It is sometimes desirable to distribute copyrighted files, that are not under an
open-source license in your package (for instance, a university logo if you are
making a template for your university). However, this is not allowed on Typst
Universe in general. It is only possible if it is clearly stated by the
copyright holder under which terms their file can be distributed and if the
package respect these terms. In that case, this information should be
explicitely stated again in the package. A good place for that is a dedicated
section the end of the README.

[cc-faq]: https://creativecommons.org/faq/#can-i-apply-a-creative-commons-license-to-software
[OSI]: https://opensource.org/licenses/
