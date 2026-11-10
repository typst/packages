#import "@preview/awesome-mff-cuni:0.1.0": *
#show: doc => mff-cuni-thesis(
  doc,
  thesis-type: "Master", // Bachelor, Doctoral, Rigorosum
  author: "Awesome Author",
  
  thesis-title: "Thesis Title",
  department: "Department",
  supervisor: "prof. RNDr. Cool Supervisor",
  study-program: "Study Program",
  abstract: "Abstract... long long",
  keywords: "kew, words",

  thesis-title-cs: "Název práce",
  department-cs: "Katedra",
  study-program-cs: "Studijní program",
  abstract-cs: "Abstrakt, ale česky :)",
  keywords-cs: "klíčová, slova",
)

= Introduction

#include("chapter1.typ")
#include("chapter2.typ")

#bibliography("bibliography.yaml")
