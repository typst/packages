/*** preface.typ
 *
 * Write the preface (alkusanat) of your work here.
 *
 **/

#pdf.attach(
  "preface.typ",
  relationship: "source",
  mime-type: "text/vnd.typst",
  description: "Typst source code for the preface of this thesis.",
)

This #link("https://typst.app/docs/")[Typst] document
template is intended to support writing academic theses in
Tampere University.
#link("https://gitlab.com/tuni-official/thesis-templates/tau-typst-thesis-template")[The template]
is based on the earlier one from Tampere University of
Technology, but it has been updated for use in Tampere
University from 2019 onwards.

Versions
#math.equation(
  alt: "greater than or equal to",
  $>=$
)
#version(0,14,0) of the Typst compiler required by this
template have the capability of creating PDF/A-3a- and
PDF/UA1-compliant PDF documents:
```sh
typst compile --pdf-standard S template/main.typ
```
Here `S` is either `ua-1` or `a-3a`. The need for these
_accessible_ standards comes from standard-compliant files
containing accessibility tags, that screen readers utilized
by visually impaired people can use to read your thesis.
This requirement comes from the European Union directive
2016/2102, which Finnish public institutions should comply
with, according to
#link("https://www.finlex.fi/en/legislation/translations/2019/eng/306")[the law].
Compliant files can also
contain arbitrary files as attachments, using the
#link("https://typst.app/docs/reference/pdf/attach/")[`pdf.attach`]
function of Typst. This means the source code of each
chapter can also be included, _which you should do_, as
it provides an alternative means for visually impaired
consumers of this work to read it. Note that a
#link("https://en.wikipedia.org/wiki/ZIP_(file_format)")[separate ZIP archive]
might still be the best source code attachment format,
as embedded PDF attachments can only be opened by certain
PDF readers.

You should make sure that your template actually
conforms to the PDF/UA-1 or PDF/A-3a standard, before
submitting it to Tampere University archive
*#link("https://trepo.tuni.fi/")[Trepo]*. This can
be achieved by installing the verification program
*#link("https://docs.verapdf.org/install/")[veraPDF]*.
*If the verification program complains that the file does
not conform at least to the PDF/A-3a standard, try feeding
it to the PDF/A converter at https://muuntaja.tuni.fi
before submitting it to Trepo.*

Acknowledgements to those who contributed to the thesis are
generally presented in the preface. It is not appropriate
to criticize anyone in the preface, even though the preface
will not affect your grade. The preface must fit on one
page. Add the date, after which you have not made any
revisions to the text, at the end of the preface.
