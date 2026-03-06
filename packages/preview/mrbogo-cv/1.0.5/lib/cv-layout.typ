// Main CV and Letter layout templates
// Internalized from neat-cv with customizations

#import "@preview/datify:1.0.0": custom-date-format
#import "@preview/fontawesome:0.6.0": fa-icon

#import "theme.typ": (
  __st-theme, __st-author,
  color-dark, color-primary,
  SIDE_CONTENT_FONT_SIZE_SCALE, FOOTER_FONT_SIZE_SCALE,
  HEADER_BODY_GAP, HORIZONTAL_PAGE_MARGIN, PAGE_MARGIN,
  __stroke_length,
)
#import "contact.typ": contact-info

// === Main CV Layout ===
#let cv(
  author: (:),
  profile-picture: none,
  accent-color: color-primary,
  font-color: rgb("#333333"),
  header-color: color-dark,
  date: auto,
  heading-font: "Fira Sans",
  body-font: ("Noto Sans", "Roboto"),
  body-font-size: 10.5pt,
  paper-size: "us-letter",
  side-width: 4cm,
  gdpr: false,
  footer: auto,
  body,
) = {
  context {
    __st-theme.update((
      font-color: font-color,
      accent-color: accent-color,
      header-color: header-color,
      fonts: (heading: heading-font, body: body-font),
    ))

    __st-author.update(author)
  }

  show: body => (
    context {
      set document(
        title: "Curriculum Vitae",
        author: (
          author.at("firstname", default: "")
            + " "
            + author.at("lastname", default: "")
        ),
      )

      body
    }
  )

  set text(
    font: body-font,
    size: body-font-size,
    weight: "light",
    fill: font-color,
  )

  set page(
    paper: paper-size,
    margin: PAGE_MARGIN,
    footer: if footer == auto {
      [
        #set text(
          size: FOOTER_FONT_SIZE_SCALE * 1em,
          fill: font-color.lighten(50%),
        )

        #grid(
          columns: (side-width, 1fr),
          align: center,
          gutter: HORIZONTAL_PAGE_MARGIN,
          inset: 0pt,
          [
            #context if counter(page).final().first() > 1 {
              counter(page).display("1 / 1", both: true)
            }
          ],
          [
            #author.firstname #author.lastname CV
            #box(inset: (x: 0.3em / FOOTER_FONT_SIZE_SCALE), sym.dot.c)
            #if date == auto {
              context custom-date-format(
                datetime.today(),
                pattern: "MMMM, yyyy",
                lang: text.lang,
              )
            } else {
              date
            }

            #if gdpr {
              [
                I authorise the processing of personal data contained within my CV,
                according to GDPR (EU) 2016/679, Article 6.1(a).
              ]
            }
          ],
        )
      ]
    } else {
      footer
    },
  )

  set par(spacing: 0.75em, justify: true)

  let head = {
    context {
      block(
        width: 100%,
        fill: header-color,
        outset: (
          left: page.margin.left,
          right: page.margin.right,
          top: page.margin.top,
        ),
        inset: (bottom: page.margin.top),
      )[
        #align(center)[
          #let position = if type(author.position) == array {
            author.position.join(box(inset: (x: 0.5em), sym.dot.c))
          } else {
            author.position
          }

          #set text(fill: white, font: heading-font)

          #text(size: 3em)[
            #text(weight: "light")[#author.firstname]
            #text(weight: "medium")[#author.lastname]
          ]

          #v(-0.5em)

          #text(
            size: 0.95em,
            fill: luma(200),
            weight: "regular",
          )[
            #smallcaps(position)
          ]
        ]
      ]
    }
  }

  let side-content-block = context {
    set text(size: SIDE_CONTENT_FONT_SIZE_SCALE * 1em)

    show heading.where(level: 1): it => block(width: 100%, above: 2em)[
      #set text(
        font: heading-font,
        fill: accent-color,
        weight: "regular",
        size: 0.95em,
      )

      #grid(
        columns: (0pt, 1fr),
        align: horizon,
        box(
          fill: accent-color,
          width: -0.29em / SIDE_CONTENT_FONT_SIZE_SCALE,
          height: 0.86em / SIDE_CONTENT_FONT_SIZE_SCALE,
          outset: (left: 0.43em / SIDE_CONTENT_FONT_SIZE_SCALE),
        ),
        it.body,
      )
    ]

    if profile-picture != none {
      block(
        clip: true,
        stroke: accent-color + __stroke_length(1),
        radius: side-width / 2,
        width: 100%,
        profile-picture,
      )
    }

    state("side-content").final()
  }

  let body-content-block = {
    show heading.where(level: 1): it => block(width: 100%)[
      #text(
        fill: accent-color,
        weight: "regular",
        font: heading-font,
        size: 0.9em,
      )[#smallcaps(it.body)]
      #box(width: 1fr, line(length: 100%, stroke: accent-color))
    ]

    body

    v(1fr)
  }

  head

  v(HEADER_BODY_GAP)

  grid(
    columns: (side-width + (HORIZONTAL_PAGE_MARGIN / 2), auto),
    align: (left, left),
    inset: (col, _) => {
      if col == 0 {
        (right: (HORIZONTAL_PAGE_MARGIN / 2), y: 1mm)
      } else {
        (left: (HORIZONTAL_PAGE_MARGIN / 2), y: 1mm)
      }
    },
    side-content-block,
    grid.vline(stroke: luma(180) + __stroke_length(0.5)),
    body-content-block,
  )
}

// === Cover Letter Layout ===
#let letter(
  author: (:),
  recipient: [],
  profile-picture: none,
  accent-color: color-primary,
  font-color: rgb("#333333"),
  header-text-color: color-dark,
  date: auto,
  heading-font: "Fira Sans",
  body-font: ("Noto Sans", "Roboto"),
  body-font-size: 10.5pt,
  paper-size: "us-letter",
  profile-picture-size: 4cm,
  footer: auto,
  body,
) = {
  context {
    __st-theme.update((
      font-color: font-color,
      accent-color: accent-color,
      header-color: header-text-color,
      fonts: (heading: heading-font, body: body-font),
    ))

    __st-author.update(author)
  }

  show: body => (
    context {
      set document(
        title: "Cover Letter",
        author: (
          author.at("firstname", default: "")
            + " "
            + author.at("lastname", default: "")
        ),
      )

      body
    }
  )

  set text(
    font: body-font,
    size: body-font-size,
    weight: "light",
    fill: font-color,
  )

  set page(
    paper: paper-size,
    margin: PAGE_MARGIN,
    footer: if footer == auto {
      [
        #set text(
          size: FOOTER_FONT_SIZE_SCALE * 1em,
          fill: font-color.lighten(50%),
        )
        #align(
          center,
          [
            #author.firstname #author.lastname Cover Letter
            #box(inset: (x: 0.3em / FOOTER_FONT_SIZE_SCALE), sym.dot.c)
            #if date == auto {
              context custom-date-format(
                datetime.today(),
                pattern: "MMMM, yyyy",
                lang: text.lang,
              )
            } else {
              date
            }
          ],
        )
      ]
    } else {
      footer
    },
  )

  set par(spacing: 0.75em, justify: true)

  let head = {
    context {
      block(
        inset: (
          left: page.margin.left,
          right: page.margin.right,
          top: page.margin.top,
          bottom: page.margin.top,
        ),
        grid(
          columns: (profile-picture-size, auto),
          gutter: page.margin.left,
          if profile-picture != none {
            block(
              clip: true,
              stroke: accent-color + __stroke_length(1),
              radius: profile-picture-size / 2,
              profile-picture,
            )
          },
          block(width: 100%)[
            #align(left)[
              #let position = if type(author.position) == array {
                author.position.join(box(inset: (x: 0.5em), sym.dot.c))
              } else {
                author.position
              }

              #set text(fill: header-text-color, font: heading-font)

              #text(size: 2em)[
                #text(weight: "light")[#author.firstname]
                #text(weight: "medium")[#author.lastname]
              ]

              #v(-0.5em)

              #text(
                size: 0.95em,
                fill: luma(200),
                weight: "regular",
              )[
                #smallcaps(position)
              ]

              #text(size: 0.8em)[
                #contact-info()
              ]
            ]

            #align(right, text(size: 0.8em, recipient))
          ],
        ),
      )
    }
  }

  head

  v(HEADER_BODY_GAP)

  set par(spacing: 1.20em, justify: true)

  block(
    width: 100%,
    inset: (left: 2cm, right: 2cm, top: 1cm),
    body,
  )
}
