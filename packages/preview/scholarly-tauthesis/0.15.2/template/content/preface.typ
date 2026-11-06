/*** preface.typ
 *
 * Write the preface (alkusanat) of your work here.
 *
 **/

#pdf.embed(
  "preface.typ",
  relationship: "source",
  mime-type: "text/vnd.typst",
  description: "Typst source code for the preface of this thesis.",
)

This #link("https://typst.app/docs/")[Typst] document template is intended to
support writing theses in the technical fields in Tampere University. The
template is based on the earlier one from the Tampere University of Technology,
but it has been updated for use in Tampere University from 2019 onwards.

Versions $>=$ #version(0,13,0) of the Typst compiler required by this template
have the capability of creating PDF/A-3b-compliant PDF documents, when run with
the command
```shell
typst compile --pdf-standard a-3b template/main.typ
```
Before Typst introduces support for the standard PDF/A-2a into the
`typst` compiler, the need for PDF/A-3b comes from it being able to
include arbitrary files as attachments into the PDF file using the
#link("https://typst.app/docs/reference/pdf/embed/")[`pdf.embed`] function of
Typst. This means the source code of each chapter can also be included, _which
you should do_, as it provides an alternative means for visually impaired
consumers of this work to read it. This template shows examples of doing this in
the files corresponding to the chapters in the main matter, as well as the front
matter sections, including this file.

You should make sure that your template actually conforms to the
PDF/A-3b standard, before submitting it to Tampere University archive
*#link("https://trepo.tuni.fi/")[Trepo]*. This can be achieved by installing
the verification program *#link("https://docs.verapdf.org/install/")[veraPDF]*
and running the generated PDF file `main.pdf` through it. *If the verification
program complains that the file does not conform the the PDF/A-3b standard, try
feeding it to the PDF/A converter at https://muuntaja.tuni.fi before submitting
it.*

Acknowledgements to those who contributed to the thesis are generally presented
in the preface. It is not appropriate to criticize anyone in the preface, even
though the preface will not affect your grade. The preface must fit on one
page. Add the date, after which you have not made any revisions to the text, at
the end of the preface.
