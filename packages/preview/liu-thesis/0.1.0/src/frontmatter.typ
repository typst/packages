#import "strings.typ": get-string

#let frontmatter-footer = context {
  align(center, counter(page).display("i"))
}

// Register in TOC/bookmarks without producing visible output.
#let phantom-heading(title) = {
  show heading.where(level: 1): it => {
    hide(block(height: 0pt, clip: true, it.body))
  }
  heading(level: 1, numbering: none, outlined: true, bookmarked: true, title)
}

#let make-abstract-page(language, abstract-content) = {
  page(
    numbering: "i",
    header: none,
    footer: frontmatter-footer,
    footer-descent: 10pt,
    {
      let title = get-string(language, "abstract-title")

      phantom-heading(title)

      v(2pt)
      pad(left: 25pt, right: 25pt, {
        align(center, text(weight: "bold", size: 9pt, title))
        v(6mm)

        set text(size: 9pt)
        set par(first-line-indent: (amount: 1.5em, all: true), spacing: 0.89em, justify: true)
        abstract-content
      })
    },
  )
}

#let frontmatter-chapter-title(title) = {
  phantom-heading(title)
  v(72pt)
  block(below: 48pt, text(size: 20.2pt, weight: "bold", title))
}

#let make-acknowledgments-page(language, acknowledgments-content, footer-descent: 10pt) = {
  page(
    numbering: "i",
    header: none,
    footer: frontmatter-footer,
    footer-descent: footer-descent,
    {
      let title = get-string(language, "acknowledgments-title")
      frontmatter-chapter-title(title)
      acknowledgments-content
    },
  )
}

// Graduate abstract page. Visible heading is always "ABSTRACT";
// TOC entry uses the localized title.
#let make-graduate-abstract-page(language, abstract-content) = {
  page(
    numbering: "i",
    header: none,
    footer: frontmatter-footer,
    footer-descent: 15pt,
    {
      // TOC entry uses the localized title
      let toc-title = get-string(language, "abstract-title")
      phantom-heading(toc-title)

      v(32pt)
      align(center, text(size: 10pt, "ABSTRACT"))
      v(8pt)

      set text(size: 8pt)
      set par(first-line-indent: 0pt, spacing: 12.5pt, justify: true)
      abstract-content
    },
  )
}

// PhD populärvetenskaplig sammanfattning page.
// Always in Swedish regardless of document language.
#let make-swedish-summary-page(summary-content) = {
  page(
    numbering: "i",
    header: none,
    footer: frontmatter-footer,
    footer-descent: 15pt,
    {
      let title = "POPULÄRVETENSKAPLIG SAMMANFATTNING"

      phantom-heading(title)

      v(32pt)
      {
        set text(lang: "sv")
        align(center, text(size: 10pt, title))
        v(8pt)

        set text(size: 8pt)
        set par(first-line-indent: 0pt, spacing: 12.5pt, justify: true)
        summary-content
      }
    },
  )
}

#let make-toc-page(language, footer-descent: 10pt) = {
  page(
    numbering: "i",
    header: none,
    footer: frontmatter-footer,
    footer-descent: footer-descent,
    {
      let title = get-string(language, "toc-title")
      frontmatter-chapter-title(title)

      show outline.entry.where(level: 1): it => {
        set text(weight: "bold")
        block(above: 1.5em, it)
      }
      show outline.entry.where(level: 1): set outline.entry(fill: none)
      show outline.entry.where(level: 2): set outline.entry(
        fill: repeat(gap: 4.5pt, [.])
      )

      v(12pt)
      outline(
        title: none,
        depth: 2,
        indent: auto,
      )
    },
  )
}
