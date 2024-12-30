#import "@preview/thesist:0.1.0": thesis, set-figure-numbering

/* INIT THESIS */
// Set language to en/pt
// Setup title page
// Hide unused lists
#show: thesis.with(

  lang: "en",

  cover-image: image("Images/default-cover.jpg", width: 95%),
  
  title: "This is the Title of the Thesis and it is a very Big Title covering More than One Line",
  
  subtitle: "This is the Thesis Subtitle if Necessary", // *

  author: "The Full Name of the Author Goes Here",
  
  degree: "Name of the Degree Here",
  
  supervisor: "Prof. Full Name of Supervisor",

  co-supervisor: "Prof. Full Name of Co-supervisor",    // *

  chairperson: "Prof. Full Name of the Chairperson",
  
  committee-members: (
    "Prof. Full Name of First Committee Member",
    "Dr. Full Name of Second Committee Member",         // *
    "Eng. Full Name of Third Committee Member"          // *
  ),
  
  date: "Month 20XX",

  // *- Define as "none" (without quotation marks) if unneeded

  
  // Set to true to hide the pages with the lists of figures, tables, algorithms, code snippets or glossary terms
  // WARNING: Please make sure at the end that you are only hiding the ones that would otherwise be empty!
  hide-figure-list: false,
  hide-table-list: false,
  hide-algorithm-list: false,
  hide-code-list: false,
  hide-glossary: false,

  
  // Don't edit this array. It's used for communication with the package.
  // Don't add chapters here!
  included-content: (
    include("Beginning/Acknowledgments.typ"),
    include("Beginning/Abstract-en.typ"),
    include("Beginning/Keywords-en.typ"),
    include("Beginning/Abstract-pt.typ"),
    include("Beginning/Keywords-pt.typ"),
    include("Beginning/Glossary.typ")
  )
  
)

// Add chapters here
#include("Chapters/0-Quick-guide.typ")
#pagebreak(to: "odd")
#include("Chapters/1-Introduction.typ")
#pagebreak(to: "odd")

// Bibliography (use either .bib or .yaml; style is usually ieee)
#bibliography("refs.bib", style: "ieee")

// Turn this code into a comment if you don't use appendices
#pagebreak(to:"odd")
#set heading(numbering: "A.1")
#counter(heading).update(0)
#show: set-figure-numbering.with(new-format: "A.1")

// Add appendices here
// Notes:
//   1- The pagebreak after the last appendix isn't needed.
//   2- If you want to use subfigures, don't forget to use in-appendix: true
#include("Chapters/Appendix-A.typ")
#pagebreak(to: "odd")
#include("Chapters/Appendix-B.typ")

/* DOCUMENT ENDS HERE */
/* REMEMBER TO HIDE THE LISTS YOU DON'T USE */
