#let transit-red = rgb("#c53a2f")
#let metro-blue = rgb("#005f9e")
#let deep-teal = rgb("#0f766e")
#let burnt-orange = rgb("#c96b2c")
#let emerald = rgb("#1f7a4f")
#let deep-violet = rgb("#5a4fcf")

#let metropole(
  // -- Metadata --
  title: none,
  subtitle: none,
  author: none,
  date: none,
  // -- Document --
  paper-size: "a4",
  language: "en",
  date-format: "[day] [month repr:long] [year]",
  cover-page: false,
  // -- Fonts --
  font-size: 11pt,
  leading-ratio: 1.75,
  body-font: "Source Serif 4",
  heading-font: "Source Sans 3",
  raw-font: "Source Code Pro",
  // -- Colors --
  background-color: rgb("#ffffff"),
  foreground-color: rgb("000000"),
  accent-color: transit-red,
  // -- Body --
  body,
) = {
  // ── Type scale (major third × 1.25) --
  let scale = 1.25
  let fine-size = font-size * calc.pow(scale, -2) //  ~7pt
  let caption-size = font-size * calc.pow(scale, -1) //  ~8.8pt
  let lead-size = font-size * calc.pow(scale, 1) //  ~13.75pt
  let heading-size = font-size * calc.pow(scale, 2) //  ~17.2pt
  let display-size = font-size * calc.pow(scale, 3) //  ~21.5pt
  let title-size = font-size * calc.pow(scale, 4) //  ~26.8pt

  // ── Derived colors --
  let secondary-content-color = color.mix(
    (foreground-color, 5),
    (background-color, 3),
    space: oklab,
  )
  let secondary-accent-color = color.mix(
    (accent-color, 2),
    (background-color, 1),
    space: oklab,
  )
  let block-bg-color = color.mix(
    (background-color, 20),
    (foreground-color, 1),
    space: oklab,
  )
  let link-color = color.mix(
    (accent-color, 3),
    (foreground-color, 1),
    space: oklab,
  )

  // ── Baseline grid --
  let line-height = font-size * leading-ratio

  // ── Spatial system (multiples of line-height) --
  let margin-vertical = line-height * 4
  let margin-horizontal = line-height * 5

  // ── Configure metadata --
  set document(title: title, date: date)
  if author != none {
    set document(author: author)
  }

  // ── Configure text --
  set text(
    font: body-font,
    size: font-size,
    fill: foreground-color,
    ligatures: true,
    discretionary-ligatures: true,
    lang: language,
  )
  show raw: set text(font: raw-font)

  // ── Configure paragraphs --
  set par(
    leading: line-height - font-size,
    spacing: line-height,
    justify: true,
    justification-limits: (
      spacing: (
        min: 100% * 2 / 3,
        max: 100% * 3 / 2,
      ),
      tracking: (
        min: -0.01em,
        max: 0.01em,
      ),
    ),
  )

  // ── Configure page --
  set page(
    paper: paper-size,
    fill: background-color,
    margin: (
      x: margin-horizontal,
      top: margin-vertical,
      bottom: margin-vertical,
    ),
    header: context {
      if counter(page).get().first() > 1 {
        v(line-height * 2)
        grid(
          columns: (1fr, 1fr),
          align(left, text(
            font: heading-font,
            size: caption-size,
            fill: secondary-content-color,
            weight: "medium",
            if author != none { author } else { "" },
          )),
          align(right, text(
            font: heading-font,
            size: caption-size,
            fill: secondary-content-color,
            weight: "medium",
            title,
          )),
        )
        v(line-height / 2)
      }
    },
    header-ascent: line-height / 2,
    footer: context {
      v(line-height / 2)
      align(right, text(
        font: heading-font,
        size: caption-size,
        fill: secondary-content-color,
        counter(page).display("1 / 1", both: true),
      ))
    },
    footer-descent: line-height,
  )

  // ── Configure headings --
  show heading.where(level: 1): it => context {
    v(line-height * 2, weak: true)
    text(
      font: heading-font,
      size: heading-size,
      weight: "bold",
      fill: foreground-color,
      it.body,
    )
  }

  show heading.where(level: 2): it => context {
    v(line-height * 2, weak: true)
    text(
      font: heading-font,
      size: lead-size,
      weight: "bold",
      fill: foreground-color,
      it.body,
    )
  }

  show heading.where(level: 3): it => {
    v(line-height, weak: true)
    text(
      font: heading-font,
      size: font-size,
      weight: "bold",
      fill: foreground-color,
      it.body,
    )
    v(line-height / 2, weak: true)
  }

  // ── Configure lists --
  set list(
    indent: 0pt,
    body-indent: line-height / 2,
    marker: (
      text(
        font: heading-font,
        fill: accent-color,
        weight: "bold",
      )[•],
      text(
        font: heading-font,
        fill: accent-color,
        weight: "bold",
      )[‣],
      text(
        font: heading-font,
        fill: accent-color,
        weight: "bold",
      )[–],
    ),
  )
  set enum(
    indent: 0pt,
    body-indent: line-height / 2,
    numbering: (..nums) => text(
      font: heading-font,
      fill: accent-color,
      weight: "medium",
      numbering("1.a.i.", ..nums),
    ),
  )
  set terms(
    indent: 0pt,
    separator: h(0.5em, weak: true),
  )
  show terms.item: it => par({
    text(
      font: heading-font,
      weight: "medium",
      fill: accent-color,
      it.term,
    )
    h(0.5em)
    it.description
  })

  // -- Configure block quotes --
  show quote.where(block: true): it => {
    v(line-height, weak: true)
    block(width: 100%)[
      #place(left + top, dy: -line-height / 2, text(
        font: heading-font,
        size: display-size * 2,
        fill: block-bg-color,
        weight: "bold",
        ["],
      ))
      #pad(left: lead-size)[
        #text(font: body-font, style: "italic", it.body)
        #if it.attribution != none {
          v(line-height / 2, weak: true)
          align(right, text(
            font: heading-font,
            size: caption-size,
            fill: secondary-content-color,
            [— #it.attribution],
          ))
        }
      ]
    ]
    v(line-height, weak: true)
  }

  // -- Configure tables --
  set table(
    stroke: none,
    inset: (x: line-height / 2, y: line-height / 2),
    fill: (x, y) => if y == 0 {
      accent-color
    } else if calc.odd(y) {
      block-bg-color
    } else {
      none
    },
  )
  show table.cell.where(y: 0): it => {
    text(
      font: heading-font,
      weight: "bold",
      size: caption-size,
      fill: background-color,
      it,
    )
  }

  // ── Configure code --
  show raw.where(block: true): block.with(
    inset: (x: line-height, y: line-height / 2),
    width: 100%,
    fill: block-bg-color,
  )
  show raw.where(block: true): set par(justify: false)
  show raw.where(block: false): box.with(
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    fill: block-bg-color,
  )

  // ── Configure links --
  show link: it => {
    if type(it.dest) != str {
      it
    } else {
      text(fill: link-color, it)
    }
  }

  // ── Title --
  if cover-page {
    // Full cover page
    page(
      margin: 0pt,
      header: none,
      footer: none,
    )[
      #place(left + top, rect(
        width: line-height,
        height: 100%,
        fill: accent-color,
      ))
      #pad(
        left: line-height + margin-horizontal,
        right: margin-horizontal,
        top: margin-vertical * 2,
        bottom: margin-vertical,
      )[
        #v(1fr)
        #text(
          font: heading-font,
          size: title-size,
          weight: "bold",
          upper(title),
        )
        #v(line-height)
        #if subtitle != none {
          text(
            font: heading-font,
            size: heading-size,
            weight: "light",
            subtitle,
          )
          v(line-height)
        }
        #v(2fr)
        #if author != none {
          grid(
            columns: (1fr, 1fr),
            text(
              font: heading-font,
              size: caption-size,
              weight: "medium",
              author,
            ),
            align(right, if date != none {
              text(
                font: heading-font,
                size: caption-size,
                fill: secondary-content-color,
                date.display(date-format),
              )
            }),
          )
        } else if date != none {
          text(
            font: heading-font,
            size: caption-size,
            fill: secondary-content-color,
            date.display(date-format),
          )
        }
      ]
    ]
  } else {
    // Inline title block on first page
    // Accent bar bleeding to page edges
    place(
      left + top,
      dx: -margin-horizontal,
      dy: -margin-vertical,
      rect(
        width: line-height,
        height: 100% + margin-vertical * 2,
        fill: accent-color,
      ),
    )
    // Title block
    v(line-height)
    text(
      font: heading-font,
      size: display-size,
      weight: "bold",
      upper(title),
    )
    v(line-height / 2)
    if subtitle != none {
      text(
        font: heading-font,
        size: lead-size,
        weight: "light",
        subtitle,
      )
      v(line-height / 2)
    }
    if author != none {
      grid(
        columns: (1fr, 1fr),
        text(
          font: heading-font,
          size: caption-size,
          weight: "medium",
          author,
        ),
        align(right, if date != none {
          text(
            font: heading-font,
            size: caption-size,
            fill: secondary-content-color,
            date.display("[day] [month repr:long] [year]"),
          )
        }),
      )
    } else if date != none {
      text(
        font: heading-font,
        size: caption-size,
        fill: secondary-content-color,
        date.display("[day] [month repr:long] [year]"),
      )
    }
    v(line-height * 2)
  }

  // ── Body --
  body
}
