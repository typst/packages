#import "/src/constants/document-settings-constants.typ": (
  ALTERNATE-FONT-SIZE-2,
  SINGLE-LINE-PARAGRAPH-LEADING-SIZE,
  DEFAULT-PARAGRAPH-SPACING-SIZE,
)

// Ham/Kod stili. [Raw/Code style.]
#let raw-style(content) = {
  // Yazı boyutunu ayarla. [Set text size.]
  show raw: set text(ALTERNATE-FONT-SIZE-2)

  // Blok ham/kod stilini ayarla. [Set block raw/code style.]
  show raw.where(block: true): it => {
    // Ortaya hizala. [Align center.]
    set align(center)

    // Paragraf ayarlarını ayarla. [Set paragraph settings.]
    set par(
      first-line-indent: 0cm,
      hanging-indent: 0cm,
      justify: false,
      leading: SINGLE-LINE-PARAGRAPH-LEADING-SIZE,
      spacing: DEFAULT-PARAGRAPH-SPACING-SIZE,
    )

    // Ham/Kod satırlarını ayarla. [Set raw/code lines.]
    show raw.line: line => {
      box(
        grid(
          align: (x, y) => if x == 0 { center + horizon } else { start + horizon },
          column-gutter: 1em,
          columns: (0.5em, 100%),
          inset: 0em,
          text(fill: gray, str(line.number)), line.body,
          stroke: 0pt,
        ),
      )
    }

    // Dikdörtgen içerisine koy. [Put inside a rectangle.]
    rect(width: 100%, stroke: gray + 0.5pt, inset: 1em, it)
  }

  content
}
