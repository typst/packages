/* Šablona obsahuje také stručný návod a obsáhlý manuál. Jejich zobrazení ovlivňují parametry `guide` a `docs`, které mohou nabývat hodnoty `true` –> Pravda, nebo `false` -> Nepravda. */
#set text(lang: "cs")
#import "@preview/unob-thesis:0.1.0": *
#show: template.with(
  university: (
    faculty: "fvl",
    programme: [],
    specialisation: [],
  ),
  thesis: (
    type: "ing",
    title: [Název práce],
  ),
  author: (
    prefix: "rtm.",
    name: "Jan",
    surname: "Novák",
    suffix: none,
    sex: "M",
  ),
  supervisor: (
    prefix: "pplk. Ing.",
    name: "Jana",
    surname: "Nováková",
    suffix: "Ph.D.",
    sex: "F",
  ),
  first_advisor: (
    prefix: "Mgr.",
    name: "Jan",
    surname: "Novák",
    suffix: none,
  ),
  second_advisor: (
    prefix: "",
    name: "",
    surname: "",
    suffix: none,
  ),
  assignment: (
    front: true,
    back: true,
  ),
  acknowledgement: [],
  abstract: (
    czech: [],
    english: [],
  ),
  keywords: (
    czech: "",
    english: "",
  ),
  declaration: (
    declaration: true,
    ai_used: true,
  ),
  acronyms: (
    "ISO": (
      "International Organization for Standardization",
      "Mezinárodní organizace pro standardizaci",
    ),
    "AČR": "Armáda České republiky",
  ),
  outlines: (
    headings: true,
    acronyms: true,
    figures: true,
    tables: true,
    equations: false,
    listings: false,
  ),
  introduction: [],
  guide: true,
  docs: true,
)

= TEORETICKÁ ČÁST / ANALÝZA SOUČASNÉHO STAVU
= CÍL A OMEZENÍ ZÁVĚREČNÉ PRÁCE

= POUŽITÉ METODY

= PRAKTICKÁ ČÁST / VÝSLEDKY A DISKUSE

#get_bibliography(
  type: "bib", // `bib` – BibLaTeX, nebo `yml` – Hayagriva
  style: "numeric", // `numeric` [1], nebo `harvard` (Novák 2025)
)

#show: annex
= NÁZEV PRVNÍ PŘÍLOHY
== a
=== a
