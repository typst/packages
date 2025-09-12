// =================================
// Document Layout Configuration
// =================================

#import "../utils/style.typ": thesis-style

// =================================
// Front Matter Layout
// =================================

#let front-matter-layout(body) = {
  set page(
    paper: "a4",
    margin: (
      top: 2.5cm,
      bottom: 2.5cm,
      left: 2.5cm,
      right: 2.5cm,
    ),
    numbering: none,
  )

  // Font setup
  set text(
    font: thesis-style.fonts.serif,
    size: 12pt,
    lang: "en",
  )

  // Heading styles for front matter
  show heading: it => {
    set text(weight: "bold", fill: thesis-style.colors.primary)
    if it.level == 1 {
      v(2em)
      text(size: 16pt, it)
      v(1em)
    } else if it.level == 2 {
      v(1.5em)
      text(size: 14pt, it)
      v(0.8em)
    } else {
      v(1em)
      text(size: 12pt, it)
      v(0.5em)
    }
  }

  // Paragraph spacing
  set par(
    leading: thesis-style.spacing.paragraph-leading,
    first-line-indent: 1.5em,
    justify: true,
  )

  body
}

// =================================
// Main Matter Layout
// =================================

#let main-matter-layout(
  title: none,
  double-sided: false,
  body
) = {
  // Page setup
  set page(
    paper: "a4",
    margin: if double-sided {
      (
        top: 2.5cm,
        bottom: 2.5cm,
        left: 3cm,
        right: 2.5cm,
        inside: 3cm,
        outside: 2.5cm,
      )
    } else {
      (
        top: 2.5cm,
        bottom: 2.5cm,
        left: 2.5cm,
        right: 2.5cm,
      )
    },
    numbering: "1",
    number-align: center,
  )

  // Font setup
  set text(
    font: thesis-style.fonts.serif,
    size: 12pt,
    lang: "en",
  )

  // Heading styles
  set heading(numbering: "1.1.1")

  show heading: it => {
    set text(weight: "bold", fill: thesis-style.colors.primary)
    if it.level == 1 {
      if double-sided {
        pagebreak(to: "odd")
      } else {
        pagebreak(weak: true)
      }
      v(thesis-style.spacing.heading-above.at("1", default: 2em))
      text(size: 16pt, it)
      v(thesis-style.spacing.heading-below.at("1", default: 1em))
    } else if it.level == 2 {
      v(thesis-style.spacing.heading-above.at("2", default: 1.5em))
      text(size: 14pt, it)
      v(thesis-style.spacing.heading-below.at("2", default: 0.8em))
    } else {
      v(thesis-style.spacing.heading-above.at("3", default: 1em))
      text(size: 12pt, it)
      v(thesis-style.spacing.heading-below.at("3", default: 0.5em))
    }
  }

  // Paragraph spacing
  set par(
    leading: thesis-style.spacing.paragraph-leading,
    first-line-indent: 1.5em,
    justify: true,
  )

  // List styling
  set list(indent: 1.5em)
  set enum(indent: 1.5em)

  // Figure and table styling
  show figure: set block(breakable: true)

  // Code styling
  show raw: set text(font: thesis-style.fonts.mono)

  // Link styling
  show link: set text(fill: thesis-style.colors.primary)

  // Math styling
  show math.equation: set block(spacing: 1.5em)

  // Header and footer
  set page(
    header: context {
      let current = counter(page).get().first()
      if current > 1 {
        grid(
          columns: (1fr, 1fr),
          align(left)[#smallcaps(title)],
          align(right)[#counter(page).display()],
        )
        line(length: 100%, stroke: 0.5pt)
      }
    },
    footer: context {
      let current = counter(page).get().first()
      if current > 1 {
        line(length: 100%, stroke: 0.5pt)
      }
    }
  )

  // Reset page counter for main content
  counter(page).update(1)

  body
}

// =================================
// Appendix Layout
// =================================

#let appendix-layout(body) = {
  // Reset heading counter for appendices
  counter(heading).update(0)

  // Set appendix numbering
  set heading(numbering: "A.1.1")

  show heading: it => {
    set text(weight: "bold", fill: thesis-style.colors.primary)
    if it.level == 1 {
      pagebreak(weak: true)
      v(thesis-style.spacing.heading-above.at(1, default: 2em))
      text(size: 16pt, [Appendix #counter(heading).display(): #it.body])
      v(thesis-style.spacing.heading-below.at(1, default: 1em))
    } else if it.level == 2 {
      v(thesis-style.spacing.heading-above.at(2, default: 1.5em))
      text(size: 14pt, it)
      v(thesis-style.spacing.heading-below.at(2, default: 0.8em))
    } else {
      v(thesis-style.spacing.heading-above.at(3, default: 1em))
      text(size: 12pt, it)
      v(thesis-style.spacing.heading-below.at(3, default: 0.5em))
    }
  }

  body
}
