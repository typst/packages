#import "@preview/simple-unimi-thesis:0.2.0": *

#show: unimi-thesis.with(
  title: "Titolo della Tesi",
  author: "Nome Cognome",
  serial-number: "123456",
  faculty: [Facoltà di Scienze e Tecnologie],
  department: [Dipartimento di Informatica \ Giovanni degli Antoni],
  course: [Corso di Laurea Triennale in \ Corso di Laurea],
  supervisors: (
    "Prof. Primo Relatore",
  ),
  cosupervisors: "Prof. Primo Correlatore",
  thesis-type: "Elaborato Finale",
  // academic-year: [2026 --- 2027],
)

#show: frontmatter

// dedication

#dedication[
  #lorem(20)

  --- Anonimo
]

// acknowledgements

#show: acknowledgements

= Riconoscimenti

#lorem(100)

#toc // table of contents

#list-of-figures

#list-of-tables

#show: mainmatter

// main section of the thesis

= Primo capitolo

#lorem(100)

#lorem(100)

= Secondo capitolo

#lorem(100)

#lorem(100)

// appendix

#show: appendix

= Appendice

#lorem(100)

#show: backmatter

// bibliography

// associated laboratory
#closingpage()
