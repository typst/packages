// TU Dortmund PhD Thesis Template
// A Typst template for PhD theses at TU Dortmund University

#let tu-green = rgb("#84b819")

// State tracking which part of the document we're in
#let matter = state("matter", "front")

// Transition to main matter: Arabic page numbers, reset heading counter
#let mainmatter = {
  pagebreak()
  counter(page).update(1)
  counter(heading).update(0)
  matter.update("main")
}

// Transition to appendix: lettered chapters, reset heading counter
#let appendix = {
  pagebreak()
  counter(heading).update(0)
  matter.update("appendix")
}

// Transition to back matter: unnumbered headings
#let backmatter = {
  pagebreak()
  matter.update("back")
}

#let thesis(
  title: "",
  author: "",
  birthdate: "",
  birthplace: "",
  date: "",
  faculty: "Fakultät Physik",
  university: "Technische Universität Dortmund",
  city: "Dortmund",
  degree: "Dr. rer. nat.",
  first-corrector: "",
  second-corrector: "",
  examination-committee-chair: "",
  phd-representative: "",
  submission-date: "",
  defense-date: "",
  tucolor: false,
  binding-correction: 12mm,
  two-sided: false,
  logo: none,
  body,
) = {
  let accent = if tucolor { tu-green } else { black }

  set document(title: title, author: author)

  // ── Page setup ──────────────────────────────────────────────
  // For double-sided printing, the binding correction is added to the
  // inner side (towards the spine) and the running heading / page number
  // are placed on the outer side. For single-sided printing, the binding
  // correction is always on the left and the heading / page number are
  // centered.
  let page-margin = if two-sided {
    (
      inside: 25mm + binding-correction,
      outside: 25mm,
      top: 30mm,
      bottom: 35mm,
    )
  } else {
    (
      left: 25mm + binding-correction,
      right: 25mm,
      top: 30mm,
      bottom: 35mm,
    )
  }

  // Outer alignment: right on odd pages, left on even pages (binding: left)
  let outer-side(p) = if calc.odd(p) { right } else { left }

  set page(
    paper: "a4",
    binding: if two-sided { left } else { auto },
    margin: page-margin,
    header: context {
      let p = here().page()
      if p <= 2 { return }
      let all = query(heading.where(level: 1))
      if all.any(h => h.location().page() == p) { return }
      let before = query(heading.where(level: 1).before(here()))
      if before.len() > 0 {
        let ch = before.last()
        let nums = counter(heading).at(ch.location())
        let num = if ch.numbering == none { none } else {
          numbering(ch.numbering, ..nums.slice(0, ch.level))
        }
        let label = if num == none { ch.body } else { [#num #ch.body] }
        set text(size: 9pt)
        let h-align = if two-sided { outer-side(p) } else { center }
        block(width: 100%)[
          #align(h-align)[#label]
          #v(2pt)
          #line(length: 100%, stroke: 0.5pt + accent)
        ]
      }
    },
    footer: context {
      let p = here().page()
      if p <= 1 { return }
      let m = matter.get()
      let n = counter(page).get().first()
      let display = if m == "front" {
        numbering("i", n)
      } else {
        str(n)
      }
      set text(fill: accent)
      let f-align = if two-sided { outer-side(p) } else { center }
      align(f-align)[#display]
    },
  )

  // ── Text and paragraph setup ────────────────────────────────
  set text(font: "New Computer Modern", size: 11pt, lang: "en")
  set par(leading: 0.7em, justify: true, spacing: 1.1em)

  // ── Heading numbering ──────────────────────────────────────
  set heading(numbering: "1.1.1")

  // ── Heading show rules ─────────────────────────────────────
  show heading.where(level: 1): it => {
    counter(figure).update(0)
      counter(math.equation).update(0)
    if it.outlined { pagebreak(weak: true) }
    v(2em)
    set text(size: 18pt, weight: "bold", fill: accent)
    it
    v(1em)
  }

  show heading.where(level: 2): it => {
    v(0.5em)
    set text(size: 14pt, weight: "bold", fill: accent)
    it
    v(0.25em)
  }

  show heading.where(level: 3): it => {
    v(0.25em)
    set text(size: 12pt, weight: "bold", fill: accent)
    it
  }

  // ── Figure and table numbering ──────────────────────────────
  set figure(numbering: (..n) => context {
    let m = matter.get()
    let ch = counter(heading).get().first()
    if m == "appendix" {
      numbering("A.1", ch, ..n)
    } else {
      numbering("1.1", ch, ..n)
    }
  })

  show figure.where(kind: table): set figure(supplement: [Table])
  show figure.where(kind: image): set figure(supplement: [Figure])

  // ── Caption styling ─────────────────────────────────────────
    show figure.caption: it => {
      set text(size: 10pt)
      block(width: 90%, spacing: 0.5em)[#it]
    }

  // ── Equation font ─────────────────────────────────────
  show math.equation: set text(font: "New Computer Modern Math")

  // ── Equation numbering ─────────────────────────────────────
  set math.equation(numbering: (..n) => context {
    let m = matter.get()
    let ch = counter(heading).get().first()
    if m == "appendix" {
      numbering("(A.1)", ch, ..n)
    } else {
      numbering("(1.1)", ch, ..n)
    }
  })

  // ── Outline (table of contents) styling ─────────────────────
  set outline(depth: 2)

  // ── Title page ─────────────────────────────────────────────
  page(
    margin: (top: 25mm, bottom: 25mm, left: 25mm, right: 25mm),
    header: none,
    footer: none,
  )[
    #if logo != none [
      #image(logo, height: 1.5cm)
    ]

    #v(3em)

    #align(center)[
      #text(size: 20pt, weight: "bold")[#title]

      #v(3em)

      #text(size: 12pt)[
        Dissertation zur Erlangung des akademischen Grades \
        #degree

        #v(3em)

        vorgelegt von \
        #author \
        geboren am #birthdate in #birthplace

        #v(3em)

        #faculty \
        #university

        #v(1em)

        #city, #date
      ]
    ]
  ]

  // ── Assessment page ────────────────────────────────────────
  page(header: none)[
    #v(35em)

    Der #faculty der #university zur Erlangung des akademischen Grades eines Doktors der Naturwissenschaften vorgelegte Dissertation.

    #v(1em)

    Gutachter: \
    #first-corrector \
    #second-corrector

    #v(1em)

    Vorsitzender der Prüfungskommission \
    #examination-committee-chair

    #v(1em)

    Vertreter:in der wissenschaftlichen Mitarbeiter*innen \
    #phd-representative

    #v(1em)

    Datum des Einreichens der Dissertation \
    #submission-date

    #v(1em)

    Datum der mündlichen Prüfung \
    #defense-date
  ]

  // ── Front matter starts here (Roman numeral pages) ──────────
  body
}
