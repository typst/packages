#import "@preview/ost-thesis:1.0.0": appendix, template, toc
#import "meta.typ": *

#show: template.with(
  title: doc-title,
  subtitle: doc-subtitle,
  authors: doc-authors,
  advisor: doc-advisor,
  co-advisor: doc-co-advisor,
  expert: doc-expert,
  thesis-type: doc-thesis-type,
  lang: "en",
)

// ─────────────────────────────────────────────
//  Preliminary Pages
// ─────────────────────────────────────────────

#include "chapters/00_Preliminary.typ"

// ─────────────────────────────────────────────
//  Table of Contents
// ─────────────────────────────────────────────

#show: toc

// ─────────────────────────────────────────────
//  Main Content
// ─────────────────────────────────────────────

#include "chapters/01_Introduction.typ"
#include "chapters/02_StateOfTheArt.typ"
#include "chapters/03_Requirements.typ"
#include "chapters/04_Design.typ"
#include "chapters/05_Implementation.typ"
#include "chapters/06_QualityAssurance.typ"
#include "chapters/07_Evaluation.typ"
#include "chapters/08_Conclusion.typ"

// ─────────────────────────────────────────────
//  Appendix
// ─────────────────────────────────────────────

#show: appendix

#include "chapters/A_ProjectManagement.typ"
#include "chapters/B_PersonalReflection.typ"

= Figures
#outline(title: none, target: figure.where(kind: image))

= Tables
#outline(title: none, target: figure.where(kind: table))

= Listings
#outline(title: none, target: figure.where(kind: raw))

= Bibliography
#bibliography("refs.yaml", title: none, style: "ieee")

