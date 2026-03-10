// Certification / oral defense approval page (口試委員會審定書).
// Matches the LaTeX ntu-thesis \makeverification layout:
//   - Title: 24pt/36pt leading, 口試委員會審定書: 26pt/39pt leading
//   - Thesis titles: 20pt/30pt leading
//   - Body paragraph: 16pt/24pt leading, single spaced
//   - Signature table: 16pt/24pt leading, double spaced

// Helper: an underline blank of a given width, aligned to text baseline.
#let sig-line(width) = box(width: width, stroke: (bottom: 0.5pt), outset: (bottom: 3pt))[#hide[X]]

#let certification-page(
  university: (zh: "", en: ""),
  author: (zh: "", en: ""),
  title: (zh: "", en: ""),
  institute: (zh: "", en: ""),
  student-id: "",
  degree: "master",
  date: (year-zh: "", year-en: "", month-zh: "", month-en: ""),
  committee-count: 4,
) = {
  let degree-label = if degree == "phd" { "博士" } else { "碩士" }
  // Number of additional committee signature rows below advisor.
  // Each row renders two signature lines.
  let committee-signature-rows = committee-count

  page(numbering: "i", margin: (top: 3cm, bottom: 2cm, left: 3cm, right: 3cm))[
    #show heading.where(level: 1): _ => []
    #heading(level: 1, numbering: none)[口試委員會審定書]

    #align(center)[
      #text(size: 24pt)[
        #(university.zh)#(degree-label)學位論文
      ]
      #v(-1em)
      #text(size: 26pt, weight: "bold")[
        口試委員會審定書
      ]
    ]

    #v(1fr)

    #align(center)[
      #set par(leading: 0.5em)
      #text(size: 20pt)[#title.zh]
      #v(0.3em)
      #text(size: 20pt)[#title.en]
    ]

    #v(1fr)


    #set text(size: 16pt)
    #set par(first-line-indent: 2em, leading: 0.5em, justify: true)
    本論文係#(author.zh)君（#student-id）在#(university.zh)#(institute.zh)完成之#(degree-label)學位論文，於民國#date.year-zh 年#date.month-zh 月承下列考試委員審查通過及口試及格，特此證明

    #v(1fr)


    #set par(first-line-indent: 0em)


    口試委員：#h(1fr)#sig-line(11.5cm)

    #v(0.2em)
    #align(center)[#h(4em)（指導教授）]

    #v(0.5em)

    #for _ in range(committee-signature-rows) {
      v(0.5em)
      h(1fr)
      sig-line(5cm)
      h(1.5cm)
      sig-line(5cm)
    }

    #v(1em)

    // Department chair
    所#h(1em)長：#h(1fr)#sig-line(11.5cm)

    #v(2em)
  ]
}
