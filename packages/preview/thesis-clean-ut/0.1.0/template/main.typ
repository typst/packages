
//===========Exporting!!
// PDF version 1.7 and standard A-3b for attachments
// to word https://www.ilovepdf.com/de/pdf_zu_word
// pandoc online for single files
//==========================imports======================

#import "lib.typ": *

#import "chapters/1 official title n declar.typ": titlepage, declaration
#import "chapters/2 abstract.typ": abstract
#import "chapters/3 acknowledgements.typ": acknowledgements
#import "chapters/4 abbreviations.typ": abbreviations
#import "chapters/5 introduction.typ": introduction
#import "chapters/6 materials and methods.typ": methods 
#import "chapters/7 results.typ": results
#import "chapters/8 summary.typ": summary
#import "chapters/9 bibliography.typ": bibliography-literature
#import "chapters/10 attachements.typ": attachements


#show: template.with(title-page: titlepage(), 
declaration: declaration(),
acknowledgements: acknowledgements(), abstract: abstract(), abbreviations: abbreviations())


= #text(fill: red)[How to use this template and general typst tips] <tips>

- make label: \<label_name>, mostly used to tag figures (special syntax and headings, see this heading). IMPORTANT: text can not be labeled (or need some workaround, check the forum if you want this)

- reference label: works for labels \@label_name and publication identifiers \@publication_name Heading reference: @tips, Publication reference: @Abida2021 (Publication automatically get added to the two-column bibliography after the discussion)

- Lists can be made by adding a \- before a new text line, enumberated lists can be made by adding a \+ likewise 

- Making figures: see next pages for exampels 

- Making tables: if you find it too tedious to input the weird table syntax and want to upload from excel, word or some other format; there are online converters: https://www.latex-tables.com/


#todo("you should delete this chapter")

= Introduction 

#introduction()
// #pagebreak()

= Materials and Methods

#methods()
#pagebreak()


= Results

#results()
// #pagebreak()

= Discussion

#summary()

#pagebreak()

#bibliography-literature()

#heading([Supplementary information], numbering: none, depth: 1)


#attachements()


