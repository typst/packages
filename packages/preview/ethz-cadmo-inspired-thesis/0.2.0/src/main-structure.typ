// Contains the code which is responsible for the main structure of the thesis, including the title page, table of contents, and chapter headings.
#import "@preview/wordometer:0.1.5": total-words, word-count
#import "theorem.typ": *

// Unnumbered chapter-style heading for front matter (Abstract, Acknowledgments, …)
#let frontchapter(title) = heading(level: 1, numbering: none, title)

// Apply as `#show: mainmatter` to start the main body:
// resets page and chapter counters and switches to arabic page numbers.
// The weak pagebreak ensures the counter update lands on the new page,
// not the last front-matter page (which would corrupt its roman numeral).
#let mainmatter(doc) = {
  pagebreak(weak: true)
  counter(page).update(1)
  counter(heading).update(0)
  set page(numbering: "1")
  doc
}

// Apply as `#show: appendix` to switch to lettered appendix numbering:
//   level 1 → no number (use frontchapter for the title)
//   level 2 → A, B, C, …
//   level 3 → A.1, A.2, …
#let appendix(doc) = {
  set heading(
    numbering: (..nums) => {
      let levels = nums.pos()
      // Level 1 is the unnumbered "Appendix" title; deeper levels get letters
      if levels.len() == 1 { none } else { numbering("A.1", ..levels.slice(1)) }
    },
    supplement: [Appendix],
  )
  counter(heading).update(0)
  doc
}

// Main setup

#let setup(
  title,
  author,
  advisors,
  department: "Department of Computer Science",
  thesis-type: "Bachelor Thesis",
  date: datetime.today(),
  bib: none,
  dev: false,
  doc,
) = {
  // WiP / dev mode is active when `dev: true` is passed or any TODO is present.
  // Must be called from within a `context` block.
  let is-wip() = dev or query(<TODO>).len() > 0

  set document(author: author, title: title, date: date)
  set text(size: 11pt, lang: "en", font: "TeX Gyre Pagella")
  set par(justify: true, spacing: 1em, first-line-indent: 0pt)
  set heading(numbering: "1.1")
  show heading.where(level: 1): set heading(supplement: [Chapter])
  set page(
    paper: "a4",
    margin: (x: 3.5cm, y: 3cm),
    numbering: "i",

    // Running header: "Chapter N - N.M Section Title" with a rule below.
    // Hidden on pages that start a new chapter.
    header: context {
      // Suppress on chapter-start pages
      let current-page = here().page()
      let chapters-on-page = query(heading.where(level: 1)).filter(h => h.location().page() == current-page)
      if chapters-on-page.len() > 0 { return none }

      // Find the most recent chapter heading
      let preceding-chapters = query(heading.where(level: 1).before(here()))
      if preceding-chapters.len() == 0 { return none }
      let current-chapter = preceding-chapters.last()

      // Build the chapter label: "Chapter N" for numbered chapters, body text for unnumbered
      let chapter-label = if current-chapter.numbering != none {
        let chapter-num = counter(heading).at(current-chapter.location()).first()
        [Chapter #chapter-num]
      } else {
        current-chapter.body
      }

      // If a section heading exists after the chapter start, append it
      let preceding-sections = query(heading.where(level: 2).before(here()))
      let header-text = if (
        preceding-sections.len() > 0
          and preceding-sections.last().location().page() >= current-chapter.location().page()
      ) {
        let current-section = preceding-sections.last()
        let section-counter = counter(heading).at(current-section.location())
        [#chapter-label - #numbering("1.1", ..section-counter) #current-section.body]
      } else {
        chapter-label
      }

      set text(size: 0.85em)
      block(width: 100%, {
        header-text
        if is-wip() { place(horizon + right, text(fill: red, [WIP #sym.dot.c #total-words words])) }
      })
      v(2pt)
      line(length: 100%, stroke: 0.5pt)
    },

    // Footer: rule above centered page number
    footer: context {
      line(length: 100%, stroke: 0.5pt)
      v(2pt)
      align(center, text(size: 0.85em, counter(page).display()))
    },
  )

  // Chapter headings:
  //   "Chapter N"  (large, regular weight)      <- only for numbered chapters
  //   ------------------------------------------
  //   Title  (huge, bold)
  //   ------------------------------------------
  //
  // NOTE: `align(center, { ... })` keeps us in code mode so that function
  // calls like `block()` and `text()` are not treated as literal markup.
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5em)
    align(center, {
      if it.numbering != none {
        text(size: 1.2em, weight: "regular", [Chapter #counter(heading).display("1")])
        v(2em)
      }
      // Wrap lines in block to suppress implicit spacing around them
      block(above: 0pt, below: 0pt, line(length: 100%))
      v(1em)
      text(size: 1.7em, weight: "bold", it.body)
      v(1em)
      block(above: 0pt, below: 0pt, line(length: 100%))
    })
    v(1em)
    thm-counter.update(0)
  }

  // Section headings (level 2)
  show heading.where(level: 2): it => {
    v(1em)
    if it.numbering != none {
      text(size: 1.15em, weight: "bold", counter(heading).display(it.numbering) + [ ] + it.body)
    } else {
      text(size: 1.15em, weight: "bold", it.body)
    }
    v(0.4em)
  }

  // Subsection headings (level 3)
  show heading.where(level: 3): it => {
    v(0.8em)
    if it.numbering != none {
      // numbering can be a string or a function (e.g. in the appendix),
      // so we only append ".1" when it is a plain string
      let fmt = if type(it.numbering) == str { it.numbering + ".1" } else { it.numbering }
      text(size: 1em, weight: "bold", counter(heading).display(fmt) + [ ] + it.body)
    } else {
      text(size: 1em, weight: "bold", it.body)
    }
    v(0.3em)
  }

  show figure.caption: set text(size: 0.9em)
  // Only color external URL links; keep cross-references in the default text color
  show link: it => if type(it.dest) == str {
    text(fill: rgb("#0645AD"), it)
  } else {
    it
  }

  // Title page
  page(
    margin: (x: 3.5cm, y: 3cm),
    numbering: none,
    header: none,
    footer: none,
    {
      image("../assets/eth-logo.png", width: 2in)
      context {
        if is-wip() {
          v(1fr)
          align(center, text("Work in Progress", size: 2em, weight: "bold", fill: red))
        }
      }
      v(1fr)
      align(center, {
        text(size: 2em, weight: "bold", title)
        v(8em)
        text(size: 1.3em, thesis-type)
        v(0.8em)
        text(size: 1.3em, author)
        v(0.4em)
        text(size: 1.3em, date.display("[month repr:long] [year]"))
      })
      v(1fr)
      align(right)[
        Advisors: #advisors.join(", ", last: " and ") \
        #department, ETH Zürich
      ]
    },
  )

  // Count words for the header; skip non-prose and the end matter.
  show: word-count.with(exclude: (raw, heading, outline, <TODO>, <no-wc>))

  doc

  if bib != none {
    set page(numbering: "1")
    heading(level: 1, numbering: none)[References]

    bib
  }
}

