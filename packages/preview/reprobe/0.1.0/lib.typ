// reprobe — MegaProbe Lab computer science technical report.
//
// The template emits every standard section heading for you. In your document
// you only supply the body of each section (and any `==` subsections you need).
//
// Usage:
//   #import "@preview/reprobe:0.1.0": tech-report
//   #show: tech-report.with(
//     title: "Blue",          // renders as "Blue: A Technical Report"
//     authors: ((name: "...", email: "...", affiliation: 1),),
//     affiliations: ("...",),
//     logo: none,             // or drop this line for the UPR–Río Piedras seal
//     abstract: [...],
//     introduction: [...],
//     methods: [...],
//     results: [...],
//     conclusions: [...],
//     future-work: [...],
//     acknowledgments: [...],
//     bibliography: bibliography("refs.bib"),
//   )
//
// Anything written after the show rule is placed at the very end of the
// document (after the references) — use it for appendices.
//
// Note on paths: a plain path string handed to this template would be resolved
// inside the package, not next to your document, so files that live in your
// project must be passed as values built in your own file — `image("...")` and
// `bibliography("...")`.

#let _default-sections = (
  introduction: "Introduction",
  methods: "Methods",
  results: "Results",
  conclusions: "Conclusions",
  future-work: "Future Work",
  acknowledgments: "Acknowledgments",
  references: "References",
  abstract: "Abstract",
  keywords: "Keywords",
)

// Resolves the `logo` argument into an image (or `none`).
//   auto / "seal" / "logo" -> the UPR–Río Piedras seal bundled with the package
//   content                -> used as-is (e.g. `image("mine.png")`)
#let _resolve-logo(logo, height) = {
  if logo == none { return none }
  if logo == auto { return image("assets/logo.svg", height: height) }
  if type(logo) == str {
    if logo in ("seal", "logo", "default") {
      return image("assets/logo.svg", height: height)
    }
    panic(
      "reprobe: unknown logo \"" + logo + "\". Use auto, \"seal\", or none. "
        + "For your own logo pass an image, not a path: "
        + "logo: image(\"mine.png\") — a path would be looked up inside the "
        + "package instead of next to your document.",
    )
  }
  logo
}

// TITLE -> "TITLE: A Technical Report". Already-suffixed titles are left alone,
// and `title-suffix: none` turns the whole thing off.
#let _full-title(title, suffix) = {
  if suffix == none or suffix == "" { return title }
  if type(title) == str {
    if title.trim().ends-with(suffix) { return title }
    return title.trim().trim(":", at: end) + ": " + suffix
  }
  [#title: #suffix]
}

// Superscript markers tying an author to entries of `affiliations`.
#let _affiliation-marks(affiliation) = {
  if affiliation == none { return none }
  let marks = if type(affiliation) == array { affiliation } else { (affiliation,) }
  super(marks.map(m => str(m)).join(","))
}

#let tech-report(
  // Just the name of the work — ": A Technical Report" is appended for you.
  title: "Untitled",
  title-suffix: "A Technical Report",
  subtitle: none,
  // (name: "", email: "", affiliation: 1) — `affiliation` is an index (or an
  // array of indices) into `affiliations`, or plain text if you skip that list.
  authors: (),
  affiliations: (),
  date: datetime.today(),
  lab: "MegaProbe Lab",
  logo: auto,
  logo-height: 2cm,
  // Front matter.
  abstract: none,
  keywords: (),
  // Sections. `none` (the default) drops the section entirely.
  introduction: none,
  methods: none,
  results: none,
  conclusions: none,
  future-work: none,
  acknowledgments: none,
  // The content returned by `bibliography("refs.bib")` — build it in your own
  // file so the path resolves there. `read("refs.bib", encoding: none)` works
  // too. The title and style below are applied to whichever you pass.
  bibliography: none,
  bibliography-style: "ieee",
  // Layout knobs.
  paper: "us-letter",
  columns: 2,
  font: ("Libertinus Serif", "New Computer Modern"),
  mono-font: "DejaVu Sans Mono",
  font-size: 10pt,
  lang: "en",
  section-names: (:),
  doc,
) = {
  let names = _default-sections + section-names
  let accent = rgb("#1b3a6b")
  let title = _full-title(title, title-suffix)

  set document(
    title: title,
    author: authors.map(a => a.at("name", default: "")),
    date: if type(date) == datetime { date } else if date == none { none } else {
      auto
    },
  )

  set page(
    paper: paper,
    columns: columns,
    margin: (x: 1.8cm, y: 2.2cm),
    numbering: "1",
    header: context {
      if counter(page).get().first() > 1 {
        set text(size: 8pt, fill: luma(90))
        align(right, title)
        line(length: 100%, stroke: 0.4pt + luma(190))
      }
    },
  )

  set text(font: font, size: font-size, lang: lang, hyphenate: true)
  set par(
    justify: true,
    leading: 0.58em,
    spacing: 0.9em,
    first-line-indent: (amount: 1em, all: false),
  )

  set heading(numbering: (..n) => {
    let nums = n.pos()
    if nums.len() == 1 { numbering("1.", ..nums) } else { numbering("1.1", ..nums) }
  })
  show heading: set block(above: 1.1em, below: 0.6em)
  show heading.where(level: 1): set text(size: 11pt, weight: "bold")
  show heading.where(level: 2): set text(size: 10pt, weight: "bold", style: "italic")
  show heading.where(level: 3): set text(size: 10pt, weight: "regular", style: "italic")

  show link: set text(fill: accent)
  show cite: set text(fill: accent)
  show raw: set text(font: mono-font, size: 8.5pt)
  show raw.where(block: true): it => block(
    width: 100%,
    fill: luma(249),
    stroke: 0.5pt + luma(220),
    radius: 2pt,
    inset: 7pt,
    it,
  )
  set figure(gap: 0.7em)
  show figure.caption: set text(size: 8.5pt)
  show figure: set block(above: 1.2em, below: 1.2em)
  set table(stroke: 0.5pt + luma(160))
  set math.equation(numbering: "(1)")

  // ── Front matter, spanning every column ────────────────────────────────
  place(
    top + center,
    float: true,
    scope: "parent",
    clearance: 1.8em,
    {
      set par(justify: false, first-line-indent: 0pt)

      let mark = _resolve-logo(logo, logo-height)
      if mark != none { block(below: 0.9em, mark) }

      block(text(size: 18pt, weight: "bold", title))
      if subtitle != none {
        block(above: 0.5em, text(size: 12pt, style: "italic", subtitle))
      }

      block(above: 0.7em, {
        set text(size: 8.5pt, fill: luma(80))
        let parts = ()
        if lab != none { parts.push(lab) }
        if date != none {
          parts.push(
            if type(date) == datetime {
              date.display("[month repr:long] [day], [year]")
            } else { date },
          )
        }
        parts.join(h(0.6em) + sym.dot.c + h(0.6em))
      })

      // Up to three authors per row. Each row is a shrink-to-fit grid centered
      // on the page, so a partial last row stays centered instead of hanging
      // under the first column.
      if authors.len() > 0 {
        let entry(author) = {
          set text(size: 10pt)
          let affil = author.at("affiliation", default: none)
          [
            *#author.name*#if affiliations.len() > 0 {
              _affiliation-marks(affil)
            } \
            #if affiliations.len() == 0 and affil != none [
              #text(size: 8.5pt)[#affil] \
            ]
            #if "email" in author {
              text(size: 8.5pt, link("mailto:" + author.email))
            }
          ]
        }
        block(above: 1.2em, width: 100%, {
          for (i, row) in authors.chunks(calc.min(authors.len(), 3)).enumerate() {
            block(above: if i == 0 { 0em } else { 1em }, width: 100%, align(
              center,
              grid(
                columns: (auto,) * row.len(),
                column-gutter: 2em,
                align: center,
                ..row.map(entry),
              ),
            ))
          }
        })
      }

      if affiliations.len() > 0 {
        block(above: 0.9em, width: 100%, {
          set text(size: 8.5pt)
          for (i, affil) in affiliations.enumerate() {
            block(above: 0.3em, below: 0.3em)[#super(str(i + 1))#h(0.2em)#affil]
          }
        })
      }

      if abstract != none {
        block(above: 1.4em, width: 100%, inset: (x: 4%), {
          set text(size: 9.5pt)
          set par(justify: true)
          align(center, text(size: 10pt, weight: "bold", names.abstract))
          v(0.3em)
          abstract
          if keywords.len() > 0 {
            v(0.6em)
            [*#names.keywords:* #keywords.join(", ")]
          }
        })
      }
    },
  )

  // ── Body ───────────────────────────────────────────────────────────────
  let section(name, body) = if body != none {
    heading(level: 1, name)
    body
  }

  section(names.introduction, introduction)
  section(names.methods, methods)
  section(names.results, results)
  section(names.conclusions, conclusions)
  section(names.future-work, future-work)

  if acknowledgments != none {
    heading(level: 1, numbering: none, names.acknowledgments)
    acknowledgments
  }

  if bibliography != none {
    // These apply to a `bibliography(...)` value built in the user's file too —
    // anything it sets explicitly still wins.
    set std.bibliography(
      title: heading(level: 1, numbering: none, names.references),
      style: bibliography-style,
    )
    show std.bibliography: set text(size: 9pt)
    if type(bibliography) == bytes {
      std.bibliography(bibliography)
    } else if type(bibliography) == str {
      panic(
        "reprobe: pass the bibliography as a value, not a path: "
          + "bibliography: bibliography(\"" + bibliography + "\") — a path "
          + "would be looked up inside the package instead of next to your "
          + "document.",
      )
    } else {
      bibliography
    }
  }

  doc
}
