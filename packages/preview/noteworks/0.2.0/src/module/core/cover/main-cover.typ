#import "../../../core/setup.typ": nw-config, nw-meta, nw-theme

// Main document cover. All parameters default to the document
// configuration set by #show: noteworthy.with(...); pass values
// only to override for this cover.
#let cover(
  title: auto,
  subtitle: auto,
  authors: auto,
  affiliation: auto,
  logo: auto,
  date: none,
) = {
  page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
  )[
    #context {
      let theme = nw-theme()
      let c = nw-config()
      let m = nw-meta()
      let pick(v, d) = if v == auto { d } else { v }
      let title = pick(title, m.title)
      let subtitle = pick(subtitle, m.subtitle)
      let authors = pick(authors, m.authors)
      let affiliation = pick(affiliation, m.affiliation)
      let logo = pick(logo, m.logo)

      [
        #line(length: 100%, stroke: 1pt + theme.text-muted)

        #v(1cm)

        // Main Title
        #text(
          size: 36pt,
          weight: "bold",
          tracking: 1pt,
          font: c.title-font,
          fill: theme.text-heading,
        )[
          #title
        ]

        #v(1cm)

        // Subtitle
        #if subtitle != "" {
          text(
            size: 18pt,
            fill: theme.text-accent,
            font: c.title-font,
            style: "italic",
          )[
            #subtitle
          ]
        }
        #if c.show-solution {
          text(
            size: 18pt,
            fill: theme.text-accent,
            font: c.title-font,
            style: "italic",
          )[
            (#c.solutions-text)
          ]
        } else {
          text(
            size: 18pt,
            fill: theme.text-accent,
            font: c.title-font,
            style: "italic",
          )[
            (#c.problems-text)
          ]
        }

        #v(1cm)

        #line(length: 100%, stroke: 1pt + theme.text-muted)

        #v(3cm)

        #text(fill: theme.text-main, size: 14pt, font: c.title-font, style: "italic")[Written by :]

        #text(fill: theme.text-main, font: c.title-font, style: "italic", size: 16pt)[
          #if type(authors) == array {
            authors.join("   /   ")
          } else {
            authors
          }
        ]

        #v(2cm)
        #if logo != none and logo != "" {
          // We use a box to ensure it doesn't break weirdly across pages (unlikely here but safe)
          box(image(logo, width: 3cm))
          v(0.5em) // Small gap between logo and affiliation text
        }
        #text(fill: theme.text-main, size: 14pt, font: c.title-font, style: "italic")[
          #upper(affiliation)
        ]

        #v(1fr)

        // Date Section
        #text(font: c.font, fill: theme.text-muted)[
          #if date == none {
            datetime.today().display()
          } else {
            date
          }
        ]
      ]
    }
  ]
  counter(page).update(1)
}
