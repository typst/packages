#import "@preview/thesist:0.1.0": thesis, set-figure-numbering

/* INIT THESIS */
// Set language to en/pt
// Setup title page
// Hide unused lists
#show: thesis.with(

  lang: "en",

  cover_image: image("Images/default_cover.jpg", width: 95%),
  
  title: "This is the Title of the Thesis and it is a very Big Title covering More than One Line",
  
  subtitle: "This is the Thesis Subtitle if Necessary", // *

  author: "The Full Name of the Author Goes Here",
  
  degree: "Name of the Degree Here",
  
  supervisor: "Prof. Full Name of Supervisor",

  co_supervisor: "Prof. Full Name of Co-supervisor",    // *

  chairperson: "Prof. Full Name of the Chairperson",
  
  committee_members: (
    "Prof. Full Name of First Committee Member",
    "Dr. Full Name of Second Committee Member",         // *
    "Eng. Full Name of Third Committee Member"          // *
  ),
  
  date: "Month 20XX",

  // *- Define as "none" (without quotation marks) if unneeded

  
  // Set to true to hide the pages with the lists of figures, tables, algorithms, code snippets or glossary terms
  // WARNING: Please make sure at the end that you are only hiding the ones that would otherwise be empty!
  hide_figure_list: false,
  hide_table_list: false,
  hide_algorithm_list: false,
  hide_code_list: false,
  hide_glossary: false,

  
  // Don't edit this array. It's used for communication with the package.
  // Don't add chapters here!
  included_content: (
    include("Beginning/Acknowledgments.typ"),
    include("Beginning/Abstract_en.typ"),
    include("Beginning/Keywords_en.typ"),
    include("Beginning/Abstract_pt.typ"),
    include("Beginning/Keywords_pt.typ"),
    include("Beginning/Glossary.typ")
  )
  
)

// Add chapters here
#include("Chapters/0_Quick_guide.typ")
#pagebreak(to: "odd")
#include("Chapters/1_Introduction.typ")
#pagebreak(to: "odd")

// Bibliography (use either .bib or .yaml; style is usually ieee)
#bibliography("refs.bib", style: "ieee")

// Turn this code into a comment if you don't use appendices
#pagebreak(to:"odd")
#set heading(numbering: "A.1")
#counter(heading).update(0)
#show: set-figure-numbering.with(new_format: "A.1")

// Add appendices here
// Notes:
//   1- The pagebreak after the last appendix isn't needed.
//   2- If you want to use subfigures, don't forget to use in_appendix: true
#include("Chapters/Appendix_A.typ")
#pagebreak(to: "odd")
#include("Chapters/Appendix_B.typ")

/* DOCUMENT ENDS HERE */
/* REMEMBER TO HIDE THE LISTS YOU DON'T USE */
