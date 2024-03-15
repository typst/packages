///////////////////////////////
#import "@preview/general-paper-template:0.4.7": *
///////////////////////////////


#show: thmrules
#set page(numbering: "1")

#show: paper.with(
  font: "PT Serif", // "Times New Roman"
  fontsize: 12pt, // 12pt
  maketitle: true, // whether to add new page for title
  title: [#lorem(5)], // title 
  subtitle: "A work in progress", // subtitle
  authors: (
    (
      name: "Theresa Tungsten",
      affiliation: "Artos Institute",
      email: "tung@artos.edu",
      note: "123",
    ),
  ),
  date: "July 2023",
  abstract: lorem(80), // replace lorem(80) with [ Your abstract here. ]
  keywords: [
    Imputation,
    Multiple Imputation,
    Bayesian,],
  JEL: [G11, G12],
  acknowledgments: "This paper is a work in progress. Please do not cite without permission.", 
  // bibliography: bibliography("bib.bib", title: "References", style: "apa"),
)

// your main text goes here
#set heading(numbering: "1.")
#set text(spacing: 100%)
#set par(
  leading: 1.2em,
  first-line-indent: 2em,
  justify: true,
)


= Introduction
#lorem(50)
