// Thesis entry point — edit this file to write your thesis.
//
// Compile with:
//   typst compile main.typ
//
// When published, change the import to:
//   #import "@preview/fubell:0.1.0": thesis

#import "@preview/fubell:0.1.0": thesis

#show: thesis.with(
  university: (zh: "國立臺灣大學", en: "National Taiwan University"),
  college: (zh: "文學院", en: "College of Liberal Arts"),
  institute: (zh: "語言學研究所", en: "Graduate Institute of Linguistics"),
  title: (
    zh: "以 Typst 排版系統撰寫國立臺灣大學論文",
    en: "Writing NTU Thesis with the Typst Typesetting System",
  ),
  author: (zh: "王小明", en: "Xiao-Ming Wang"),
  advisor: (zh: "陳大文 博士", en: "Da-Wen Chen, Ph.D."),
  student-id: "R12345678",
  degree: "master",
  date: (
    year-zh: "115",
    year-en: "2026",
    month-zh: "2",
    month-en: "February",
  ),
  keywords: (
    zh: ("排版", "論文模板", "Typst"),
    en: ("typesetting", "thesis template", "Typst"),
  ),

  abstract-zh: include "sections/abstract-zh.typ",
  abstract-en: include "sections/abstract-en.typ",
  acknowledgement-zh: include "sections/acknowledgement-zh.typ",
  acknowledgement-en: include "sections/acknowledgement-en.typ",

  bibliography-file: bibliography("bibliography/refs.bib"),
  watermark: none, // optional: set to "assets/watermark.png" after adding it locally
  lang: "zh",
)

// Main chapters
#include "sections/chapters/introduction.typ"
