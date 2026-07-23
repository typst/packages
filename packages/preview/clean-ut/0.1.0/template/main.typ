//===========Exporting!!
// PDF version 1.7 and standard A-3b for attachments
// to word https://www.ilovepdf.com/de/pdf_zu_word
// pandoc online for single files
//==========================imports======================

#import "@preview/clean-ut:0.1.0" : * //imports the styling, show-outlines and show-header functions

#show: template

#include "chapters/01 title page.typ"

#include "chapters/02 declaration.typ"

#include "chapters/03 abstract.typ"

#include "chapters/04 acknowledgements.typ"

#show: outlines //shows table of contents, list of figures, list of tables

#include "chapters/05 abbreviations.typ"

#show: page-header //shows the header from now on

= #text(fill: red)[How to use this template and general typst tips] <tips>

- make label: \<label_name>, mostly used to tag figures (special syntax and headings, see this heading). IMPORTANT: text can not be labeled (or needs some workaround, check the forum if you want this)

- reference label: works for labels \@label_name and publication identifiers \@publication_name Heading reference: @tips, Publication reference: @Abida2021 (Publication automatically get added to the two-column bibliography after the discussion)

- Lists can be made by adding a \- before a new text line, enumerated lists can be made by adding a \+ likewise 

- Making figures: see next pages for examples 

- Making tables: if you find it too tedious to input your data in the (weird) table syntax and want to upload from excel, word or some other format; there are online converters: https://www.latex-tables.com/

#todo("you should delete this chapter or move it to somewhere where it is not visible")

#include "chapters/06 introduction.typ"

#include "chapters/07 materials and methods.typ"

#include "chapters/08 results.typ"

#include "chapters/09 summary.typ"

#include "chapters/10 bibliography.typ"

#include "chapters/11 attachements.typ"


