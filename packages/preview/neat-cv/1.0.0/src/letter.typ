#import "@preview/datify:1.0.1": custom-date-format
#import "state.typ": (
  DOT_SEPARATOR, FOOTER_FONT_SIZE_SCALE, HEADER_BODY_GAP, PAGE_MARGIN,
  __st-author, __st-theme, __stroke_length,
)
#import "components.typ": contact-info


/// Cover Letter layout.
///
/// -> content
#let letter(
  /// Author information dictionary. Available keys: `firstname`, `lastname`, `email`, `phone`, `address`, `position` (string or array).
  /// -> dictionary
  author: (:),
  /// Recipient address
  /// -> content
  recipient: [],
  /// Profile picture
  /// -> image | none
  profile-picture: none,
  /// Accent color for highlights
  /// -> color
  accent-color: rgb("#408abb"),
  /// Main text color
  /// -> color
  font-color: rgb("#333333"),
  /// Color for header text
  /// -> color
  header-text-color: luma(50),
  /// Date string for footer
  /// -> string | auto
  date: auto,
  /// Font for headings
  /// -> string
  heading-font: "Fira Sans",
  /// Font(s) for body text
  /// -> array
  body-font: ("Noto Sans", "Roboto"),
  /// Font size for body text
  /// -> length
  body-font-size: 10.5pt,
  /// Paper size
  /// -> string
  paper-size: "us-letter",
  /// Profile picture size
  /// -> length
  profile-picture-size: 4cm,
  /// Optional custom footer
  /// -> content | auto
  footer: auto,
  /// Main content of the letter
  /// -> content
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
              #set text(fill: header-text-color, font: heading-font)

              #text(size: 2em)[
                #text(weight: "light")[#author.firstname]
                #text(weight: "medium")[#author.lastname]
              ]

              #v(-0.5em)

              #if "position" in author {
                let position = if type(author.position) == array {
                  author.position.join(DOT_SEPARATOR)
                } else {
                  author.position
                }
                text(
                  size: 0.95em,
                  fill: luma(200),
                  weight: "regular",
                )[#smallcaps(position)]
              }

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
