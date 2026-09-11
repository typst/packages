// SZU Typst Slides Template (Chinese Version / 中文版)
// Choose one theme:
#import "libs/szu-met-theme.typ": *
// #import "libs/szu-uni-theme.typ": *

#import "@preview/touying:0.7.4": *
#import "@preview/numbly:0.1.0": *
#import "@preview/theorion:0.4.0": *

#import "slide-text.typ": zh-font, en-font
#import "slide-functions.typ": *
#import "section-cover_zh.typ": cover-section, thesis-title, thesis-subtitle, candidate-name, college-name
#import "section-outline_zh.typ": outline-section
#import "section-background_zh.typ": background-section
#import "section-work_zh.typ": work-section
#import "section-summary_zh.typ": summary-section
#import "section-thanks_zh.typ": thanks-section
#import "section-appendix_zh.typ": appendix-section

// ── Theme & Fonts ────────────────────────────────────────────
#show: show-theorion

#show: szu-theme.with(
  lang: "zh",
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
