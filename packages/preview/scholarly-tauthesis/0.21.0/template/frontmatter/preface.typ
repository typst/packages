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
template have the capability of creating PDF/UA-1-compliant
PDF documents:
```sh
typst compile --pdf-standard ua-1 template/main.typ
```
The need for this _accessible_ standard comes from
standard-compliant files containing accessibility tags,
that screen readers utilized by visually impaired people
can use to read your thesis. These tags can be viewed with
utilities such as the Lua program
#link("https://github.com/latex3/pdf_structure/tree/develop/show-pdf-tags")[pdf-structure].
The requirement for PDF tags comes from the European Union
directive 2016/2102, which Finnish public institutions
should comply with, according to
#link("https://www.finlex.fi/en/legislation/translations/2019/eng/306")[the law].

You should make sure that your thesis actually
conforms to the PDF/UA-1 standard, before
submitting it to Tampere University archive
*#link("https://trepo.tuni.fi/")[Trepo]*. This can
be achieved by installing the verification program
*#link("https://docs.verapdf.org/install/")[veraPDF]*.
There are also
#link("https://typst.app/docs/guides/accessibility/#testing-for-accessibility")[other software]
available if one wishes to inspect accessibility properties
in more detail. *Note* that the PDF/A converter service
at https://muuntaja.tuni.fi cannot automatically generate
accessible PDF files for you.

If producing an accessible PDF file does not work for some
reason, the source code of your thesis can be attached to
the Trepo submission as a
#link("https://en.wikipedia.org/wiki/ZIP_(file_format)")[separate ZIP archive].
This provides visually impaired people at least some means
of accessing your work, as plain text is rather accessible.

Acknowledgements to those who contributed to the thesis are
generally presented in the preface. It is not appropriate
to criticize anyone in the preface, even though the preface
will not affect your grade. The preface must fit on one
page. Add the date, after which you have not made any
revisions to the text, at the end of the preface.
