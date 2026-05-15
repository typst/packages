// Document template: cover page, table of contents, page layout.

#import "theme.typ": colors, fonts
#import "i18n.typ": translate, user-dicts

#let cookbook(
  title: "Recipe Collection",
  author: "Chef",
  date: datetime.today(),
  paper: "a4",
  accent-color: colors.accent,
  cover-image: none,
  lang: "en",
  custom-dicts: (:),
  body,
) = {
  set document(title: title, author: author)
  set page(
    paper: paper,
    margin: (x: 2cm, top: 2.5cm, bottom: 2.5cm),
    header: context {
      let p = counter(page).get().first()
      if p > 1 {
        set text(font: fonts.header, size: 9pt, fill: colors.muted)
        grid(
          columns: (1fr, auto, 1fr),
          align(left, title), align(center)[— #p —], align(right, author),
        )
        v(-0.8em)
        line(length: 100%, stroke: 0.5pt + colors.line)
      }
    },
    footer: none,
  )

  set text(
    font: fonts.body,
    size: 11pt,
    fill: colors.text,
    lang: lang,
    features: (onum: 1),
  )

  // Store the user's custom dictionary in state
  show: it => {
    user-dicts.update(custom-dicts)
    it
  }

  // Headings
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set align(center + horizon)
    block(width: 100%)[
      #text(
        font: fonts.header,
        weight: "bold",
        size: 0.9em,
        tracking: 2pt,
        fill: colors.accent,
        upper(
          translate("chapter"),
        ),
      )
      #v(0.5em)
      #text(
        font: fonts.header,
        weight: "black",
        size: 3.5em,
        fill: colors.text,
        it.body,
      )
    ]
  }

  show heading.where(level: 2): it => {
    pagebreak(weak: true)
    v(1em)
    text(
      font: fonts.header,
      weight: "bold",
      size: 2.2em,
      fill: colors.text,
      it.body,
    )
    v(0.5em)
  }

  // Cover
  if title != none {
    page(margin: 0pt, header: none)[
      // Optional Background Image
      #if cover-image != none {
        place(top, image(cover-image, width: 100%, height: 60%, fit: "cover"))
      }

      #place(center + horizon)[
        #block(
          width: 75%,
          stroke: (
            top: 4pt + accent-color,
            bottom: if cover-image == none { 4pt + accent-color } else { none },
          ),
          inset: (y: 3em),
          fill: if cover-image != none { colors.bg-ing.lighten(10%) } else {
            none
          },
          outset: if cover-image != none { 1cm } else { 0cm },
        )[
          #par(leading: 0.35em)[
            #text(
              font: fonts.header,
              weight: "black",
              size: 4.5em,
              fill: colors.text,
              title,
            )
          ]
          #v(1.5em)
          #text(
            font: fonts.body,
            style: "italic",
            size: 1.5em,
            fill: colors.muted,
            translate("collection") + " " + author,
          )
        ]
      ]

      #place(bottom + center)[
        #pad(bottom: 3cm, text(
          font: fonts.header,
          size: 0.8em,
          tracking: 3pt,
          fill: colors.muted,
          upper(
            date.display("[month repr:long] [year]"),
          ),
        ))
      ]
    ]
  }

  // TOC
  page(header: none)[
    #v(3cm)
    #align(center)[
      #text(
        font: fonts.header,
        weight: "bold",
        size: 1.2em,
        tracking: 2pt,
        fill: colors.accent,
        upper(
          translate("contents"),
        ),
      )
      #v(1em)
      #line(length: 3cm, stroke: 0.5pt + colors.muted)
    ]
    #v(1.5cm)

    #show outline.entry: it => {
      if it.level == 1 {
        // Section / Chapter Header
        v(1.5em)
        link(it.element.location())[
          #text(
            font: fonts.header,
            weight: "black",
            size: 1.3em,
            fill: colors.text,
            upper(it.element.body),
          )
        ]
        h(1fr)
        // No page number for chapters, looks cleaner
      } else {
        // Recipe Entry
        v(0.5em)
        link(it.element.location(), box(width: 100%)[
          #text(
            font: fonts.body,
            size: 1.1em,
            fill: colors.text,
            it.element.body,
          )
          #box(width: 1fr, repeat[ #h(0.3em) #text(
              fill: colors.line.darken(20%),
              size: 0.6em,
            )[.] #h(0.3em) ])
          #text(
            font: fonts.header,
            weight: "bold",
            fill: colors.muted,
            context it.element.location().page(),
          )
        ])
      }
    }

    #outline(title: none, indent: 0pt, depth: 2)
  ]

  body
}
