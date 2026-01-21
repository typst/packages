/*** preface.typ
 *
 * Write the preface (alkusanat) of your work here.
 *
 **/

This #link("https://typst.app/docs/")[typst] document template is intended to
support writing theses in the technical fields in Tampere University. The
template is based on the earlier one from the Tampere University of Technology,
but it has been updated for use in Tampere University from 2019 onwards.

Versions $>=$ #version(0,12,0) of the typst compiler required by this template
have the capability of creating PDF/A-2b-compliant PDF documents, when run with
the command
```shell
typst compile --pdf-standard a-2b template/main.typ
```
Therefore, the use of the Tampere University Muuntaja-service, used for
transforming PDF documents into PDF/A format, might no longer be required, when
using this template. *However*, you should make sure that your template actually
conforms to the PDF/A-2b standard, before submitting it to Tampere Universty
archive *#link("https://trepo.tuni.fi/")[Trepo]*. This can be achieved by
installing the verification program
*#link("https://docs.verapdf.org/install/")[veraPDF]* and running the generated
PDF file `main.pdf` through it. *If the verification program complains that the
file does not conform the the PDF/A-2b standard, try feeding it to the PDF/A
converter at https://muuntaja.tuni.fi before submitting it.*

Acknowledgements to those who contributed to the thesis are generally presented
in the preface. It is not appropriate to criticize anyone in the preface, even
though the preface will not affect your grade. The preface must fit on one
page. Add the date, after which you have not made any revisions to the text, at
the end of the preface.
