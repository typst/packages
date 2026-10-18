// main.typ
// ============================================================================
// NTUST Thesis — Main Document (Typst)
// ============================================================================
// To compile:  typst compile main.typ
// ============================================================================

#import "@preview/ntust-thesis-unofficial:1.0.1": ntust-thesis
#import "frontpages/names.typ": thesis-info

// Choose the language
// Change to "zh" for Chinese mode
#let language = "zh"

// Apply the thesis template
#show: ntust-thesis.with(
  lang: language,
  info: thesis-info,
  abstracts: (
    zh: include "frontpages/abstract.zh.typ",
    en: include "frontpages/abstract.en.typ",
  ),
  acknowledgement: include "frontpages/ackn.typ",
  references: bibliography("cite.bib"),
  // logo: image("logo.png"), // 放入校徽圖片
  // fonts: ("Times New Roman", "DFKai-SB"), // 使用 Window 自帶的字體
  // recommendation-form: image("figures/img.png"), // 放入推薦信圖片
  // committee-form: image("figures/committee-form.png"), // 放入審定書圖片
  // copyright-form: image("figures/copyright-form.png"), // 放入授權書圖片
)

// Main body
#include "sections/ch1-intro.typ"
#include "sections/ch2-related-work.typ"
#include "sections/ch3-method.typ"
#include "sections/ch4-experiment.typ"
#include "sections/conclusion.typ"
