#import "@preview/awesome-mff-cuni:0.1.0": *
#show: doc => mff_cuni_thesis(
  doc,
  thesis_type: "Master", // Bachelor, Doctoral, Rigorosum
  author: "Awesome Author",
  
  thesis_title: "Thesis Title",
  department: "Department",
  supervisor: "prof. RNDr. Cool Supervisor",
  study_program: "Study Program",
  abstract: "Abstract... long long",
  keywords: "kew, words",

  thesis_title_cs: "Název práce",
  department_cs: "Katedra",
  study_program_cs: "Studijní program",
  abstract_cs: "Abstrakt, ale česky :)",
  keywords_cs: "klíčová, slova",
)

= Introduction

#include("chapter1.typ")
#include("chapter2.typ")

#bibliography("bibliography.yaml")
