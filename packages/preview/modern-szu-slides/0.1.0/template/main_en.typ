// SZU Typst Slides Template (English Version)
#import "@preview/modern-szu-slides:0.1.0": *

// Choose theme (Metropolis is default):
// #let szu-theme = szu-uni-theme  // Uncomment to switch to University theme

#import "section-cover_en.typ": cover-section, thesis-title, thesis-subtitle, candidate-name, college-name
#import "section-outline_en.typ": outline-section
#import "section-background_en.typ": background-section
#import "section-work_en.typ": work-section
#import "section-summary_en.typ": summary-section
#import "section-thanks_en.typ": thanks-section
#import "section-appendix_en.typ": appendix-section

// ── Theme & Theorems ─────────────────────────────────────────
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

// ── Typography & Numbering ───────────────────────────────────
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
