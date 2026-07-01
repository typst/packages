#let bibliography-literature() = [
  /*
  for converting .ris to .bib:
  https://www.bruot.org/ris2bib/ 

   .nbib to .bib:
  https://www.bibtex.com/c/pmid-to-bibtex-converter/
  */
  #heading(numbering: none, [Bibliography])
  #bibliography("bibliography.bib", title: none,
                style: "../nature_squarebrackets.csl")
                
]