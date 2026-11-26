# Sources and third-party components

Checked on 24 November 2026. No third-party template code is vendored or adapted.
The implementation was written for this project using Typst's public API and
general academic document conventions. The standard MIT licence text is from
the [Open Source Initiative](https://opensource.org/license/mit). The public
repository's existing MIT licence and its 2026 Cyberl-ty02 copyright notice are
retained unchanged.

The package implementation and files outside `template/` are under this MIT
licence. The editable scaffold under `template/` is separately MIT-0, as stated in
`template/LICENSE` and its source headers. The manifest's `MIT AND MIT-0`
expression describes that file-by-file split. The scaffold contains this
project's original illustrative prose, diagram, data and manually entered
bibliographic facts; it does not grant rights to the publications themselves.

| Component | Version / source | Licence and handling |
| --- | --- | --- |
| Typst CLI | 0.15.1; [official source](https://github.com/typst/typst) | Apache-2.0; separately installed tool, not redistributed here |
| Typst public APIs | [Template tutorial](https://typst.app/docs/tutorial/making-a-template/), [page](https://typst.app/docs/reference/layout/page/), [figure](https://typst.app/docs/reference/model/figure/), [table](https://typst.app/docs/reference/model/table/), [bibliography](https://typst.app/docs/reference/model/bibliography/) | API reference consulted; no tutorial or third-party template implementation copied |
| Libertinus Serif | Compiler-bundled regular, bold and italic faces; [upstream](https://github.com/alerque/libertinus) | SIL OFL 1.1; family referenced, no standalone font files supplied; PDF uses embedded subsets |
| New Computer Modern Math | Compiler-bundled NewCMMath-Book; Typst 0.15.1 bundles NewCM 8.1.1 | GUST Font Licence for this math face; no standalone font files supplied; PDF uses an embedded subset |
| New Computer Modern | Optional alternate-layout acceptance fixture; compiler-bundled | The NewCM family has face-specific terms: GUST, and GPL-3.0-or-later with font/distribution exceptions for NewCM10-Regular; not relicensed under this project's MIT licence |
| Built-in IEEE citation style | Provided by installed Typst 0.15.1 | Referenced through the compiler; no separate CSL file copied or repackaged |
| pypdf | 7.1.1; [project](https://github.com/py-pdf/pypdf), [licence](https://github.com/py-pdf/pypdf/blob/main/LICENSE) | BSD-3-Clause; optional validation dependency, not vendored; retain its notices if redistributing the dependency |
| Two bibliography records | `references.bib`; publisher and Microsoft Research pages linked in README | Only manually entered factual bibliographic records; no abstracts, book/paper text, figures or attachment exports |

The [Typst assets NOTICE](https://raw.githubusercontent.com/typst/typst-assets/main/NOTICE)
maps the bundled faces to their licences. See also the
[Libertinus OFL](https://raw.githubusercontent.com/alerque/libertinus/master/OFL.txt)
and [NewCM licence text](https://ctan.math.illinois.edu/fonts/newcomputermodern/License.txt).
The [Typst 0.15.1 release notes](https://typst.app/docs/changelog/0.15.1/)
identify the bundled NewCM version. Font licences remain separate from this
template's licence; producing a PDF does not transfer those font rights to the
template maintainer. If distributing font files or a compiler, comply with their
own licences and accompanying notices. The current source candidate distributes
neither.

No CeTZ or other Universe package is required. No school-provided source,
institutional visual asset, unpublished declaration, original dissertation
chapter, dataset, research screenshot or private bibliography is included.

## Optional local rendering tool

The development-only long-document validator can use PyMuPDF 2.1, published by
Artifex under AGPL-3.0 or a commercial licence. It is installed separately and is
not included in this repository or the Universe package. See
[PyMuPDF licensing](https://pymupdf.readthedocs.io/en/latest/about.html#license-and-copyright).
The Universe thumbnail is generated directly by the Typst CLI from the synthetic
initialized document, rather than extracted from a reference dissertation.
