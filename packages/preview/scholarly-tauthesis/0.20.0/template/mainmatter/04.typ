/** 04.typ
 *
 * This is an example chapter in a multi-file typst project.
 *
***/

#pdf.attach(
  "04.typ",
  relationship: "source",
  mime-type: "text/vnd.typst",
  description: "The Typst source code for the example conclusions chapter 4 of this thesis.",
)

#import "../preamble.typ": *

= Conclusions <conclusions>

This template and the writing guidelines should help
achieving consistently formatted and clear documents.
Every writing and presentation must have a conclusion. This
fact is here emphasized by having this short and rather
artificial summary also in this template. The purpose of
this chapter is to discuss how the things we set out to do
in the introduction succeeded, and compare our results to
other literature on the same topic.

As a last reminder, remember to make sure that your
document is _accessible_~@typst-accessibility-guide before
submitting it to the Tampere University archive Trepo. See
the university library guidelines~@tuni-lib-pdfa-ohjeet
regarding this. Use veraPDF~@verapdf,
showtags~@texlive-showtags, PAC~@axes4-pac-software (if
you have access to Windows#sym.trademark.registered)
or some other software listed by the PDF Association
@pdf-association-accessibility-checkers to verify the
thesis PDF document accessibility, before your thesis
submission.

If your thesis PDF file is not accessible and you have
no way of making it so, you should attach both the
unaccessible PDF file at least in PDF/A-2b format, and
your _thesis source code_ as a ZIP file to the Trepo
submission. Be sure to clean up any personal comments from
the source code before doing so. Also make sure that the
final submitted source code works, meaning a PDF file can
be compiled from it.

Note that you are allowed to attach the source code and
a permissive license such as CC BY 4.0 @cc-by-webpage to
your thesis, even if it is accessible. This is _the_ ideal
way of publishing your thesis, unless you are restricted
from doing so by a company or other entity tied to your
thesis process, that migth require secrecy from you. The
authors of this template and the Tampere University Library
recommend CC-licensing as the ideal licensing option
@tuni-lib-cc-ohjeet, in the name of promoting open science.
