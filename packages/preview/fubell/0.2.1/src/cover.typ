// Cover page layout for NTU thesis.
// Per thesissample.doc (附件1):
//   - Top margin 4cm, bottom 3cm, left/right 3cm
//   - All lines centered, 1.5x line height
//   - Chinese: 18pt 楷書; English: sizes vary (see below)

#let cover-page(
  university: (zh: "", en: ""),
  college: (zh: "", en: ""),
  institute: (zh: "", en: ""),
  title: (zh: "", en: ""),
  author: (zh: "", en: ""),
  advisor: (zh: "", en: ""),
  degree: "master",
  date: (year-zh: "", year-en: "", month-zh: "", month-en: ""),
  doi: none,
) = {
  let degree-label-zh = if degree == "phd" { "博士" } else { "碩士" }
  let degree-label-en = if degree == "phd" { "Doctoral Dissertation" } else { "Master Thesis" }

  page(numbering: none, margin: (top: 4cm, bottom: 3cm, left: 3cm, right: 3cm), footer: none)[
    #set align(center)
    #set par(leading: 1.5em)

    // Line 1: 國立臺灣大學○○學院○○系(所) — 18pt 楷書
    #text(size: 18pt)[#university.zh#college.zh#institute.zh]

    // Line 2: 碩(博)士論文 — 18pt 楷書
    #text(size: 18pt)[#(degree-label-zh)論文]

    // Line 3: Department or Graduate Institute of ○○ — 14pt TNR
    #text(size: 14pt)[#institute.en]

    // Line 4: College of ○○ — 14pt TNR
    #text(size: 14pt)[#college.en]

    // Line 5: National Taiwan University — 16pt TNR
    #text(size: 16pt)[#university.en]

    // Line 6: master thesis / doctoral dissertation — 16pt TNR
    #text(size: 16pt)[#degree-label-en]

    #v(1fr)

    // Title (Chinese) — 18pt 楷書
    #text(size: 18pt)[#title.zh]

    // Title (English) — 18pt TNR
    #text(size: 18pt)[#title.en]

    #v(1fr)

    // Author (Chinese) — 18pt 楷書
    #text(size: 18pt)[#author.zh]

    // Author (English) — 18pt TNR
    #text(size: 18pt)[#author.en]

    #v(1fr)

    // Advisor (Chinese) — 18pt 楷書
    #text(size: 18pt)[指導教授：#advisor.zh]

    // Advisor (English) — 18pt TNR
    #text(size: 18pt)[Advisor: #advisor.en]

    #v(1fr)

    // Date (Chinese ROC) — 18pt 楷書
    #text(size: 18pt)[中華民國 #date.year-zh 年 #date.month-zh 月]

    // Date (English) — 18pt TNR
    #text(size: 18pt)[#date.month-en, #date.year-en]

    // DOI
    #if doi != none {
      place(bottom + right, dx: 2cm, dy: 2cm, text(size: 10pt)[#doi])
    }
  ]
}
