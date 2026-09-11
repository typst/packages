// SZU Typst Slides Template (English Version)
// Choose one theme:
#import "libs/szu-met-theme.typ": *
// #import "libs/szu-uni-theme.typ": *

#import "@preview/touying:0.7.4": *
#import "@preview/numbly:0.1.0": *
#import "@preview/theorion:0.4.0": *

#import "slide-text.typ": zh-font, en-font
#import "slide-functions.typ": *
#import "section-cover_en.typ": cover-section, thesis-title, thesis-subtitle, candidate-name, college-name
#import "section-outline_en.typ": outline-section
#import "section-background_en.typ": background-section
#import "section-work_en.typ": work-section
#import "section-summary_en.typ": summary-section
#import "section-thanks_en.typ": thanks-section
#import "section-appendix_en.typ": appendix-section

// ── Theme & Fonts ────────────────────────────────────────────
#show: show-theorion

#show: szu-theme.with(
  lang: "en",
  title: thesis-title,
  subtitle: thesis-subtitle,
  author: candidate-name,
  date: datetime.today(),
  institution: college-name,
)

#show: apply-slide-fonts

// ── Style Settings ───────────────────────────────────────────
#set heading(numbering: numbly("{1}.", default: "1.1"))
#set par(justify: false)
#show strong: set text(fill: black)

// ── Slides ───────────────────────────────────────────────────
#cover-section
#outline-section
#background-section
#work-section
#summary-section
#thanks-section
#appendix-section
