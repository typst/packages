#import "@preview/fancy-cookbook:3.0.0": *

#let valid-custom-language = (
  en: (
      appendices: "Appendices",
      author: "AUTHOR",
      authors: "AUTHORS",
      index: "Thematic Index",
      ingredients: "INGREDIENTS",
      notes: "CHEF'S NOTES",
      preparation: "PREPARATION",
      toc: "Table of Contents",
      page-numbering: "1",
      page-ref-numbering: "p. 1", 
      step-numbering: "1"
    )
)


#show: cookbook.with(
   // cover-image: none, // valid
   cover-image: [], // valid
   // cover-image: 1, // invalid
   // cover-image: "1", // invalid
   custom-i18n: valid-custom-language, // valid
   // custom-i18n: "test", // invalid
   // custom-i18n: "test", // invalid
   // custom-i18n: (test: "test"), // invalid
   // custom-i18n: (test: (test:"test")), // invalid
  // fonts: (test:1), // not valid
  // fonts: 1, // not valid
  // fonts: (body:"Toto", header: "Titi", mono: "Tata"), // valid
  fonts: (body:"Linux Libertine", header: "New Computer Modern", mono: "DejaVu Sans Mono"), // valid
  // fonts: (body:("Toto", "Libertinus Serif"), header: "Toto", mono: "Toto"), // valid
  style: style.flat,  // valid
  // style: "test" // invalid
  // palette: "top" // invalid
  // palette: (dark: "rien", medium: "rien", light: "rien") //invalid
  palette: (dark: rgb("#8c510a"),medium: rgb("#bf812d"),light: rgb("#f6e8c3"), // valid
  )
)
