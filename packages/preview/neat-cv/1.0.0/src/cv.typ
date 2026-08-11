#import "@preview/datify:1.0.1": custom-date-format
#import "state.typ": (
  DOT_SEPARATOR, FOOTER_FONT_SIZE_SCALE, HEADER_BODY_GAP,
  HORIZONTAL_PAGE_MARGIN, PAGE_MARGIN, SIDE_CONTENT_FONT_SIZE_SCALE,
  THIN_SIDE_WIDTH, __st-author, __st-profile-picture, __st-side-width,
  __st-theme, __stroke_length,
)


// ---- Main CV Template ----

/// Main CV layout. Sets up theme, fonts, page, and structure.
///
/// -> content
#let cv(
  /// Author information dictionary. Available keys: `firstname`, `lastname`, `email`, `phone`, `address`, `position` (string or array), `website`, `twitter`, `mastodon`, `matrix`, `github`, `gitlab`, `linkedin`, `researchgate`, `scholar`, `orcid`, `custom-links` (array of dictionaries with `icon-name` (optional), `label`, and `url`).
  /// -> dictionary
  author: (:),
  /// Profile picture
  /// -> image | none
  profile-picture: none,
  /// Accent color for highlights
  /// -> color
  accent-color: rgb("#408abb"),
  /// Main text color
  /// -> color
  font-color: rgb("#333333"),
  /// Color for header background
  /// -> color
  header-color: luma(50),
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
  /// Sidebar width
  /// -> length
  side-width: 4cm,
  /// Add GDPR data usage in the footer
  /// -> boolean
  gdpr: false,
  /// Optional custom footer
  /// -> content | auto
  footer: auto,
  /// Main content of the CV
  /// -> content
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
    __st-side-width.update(side-width)
    __st-profile-picture.update(profile-picture)
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
    }
  )

  set text(
    font: body-font, // if you see a warning here, your font was not found/loaded
    size: body-font-size,
    weight: "light",
    fill: font-color,
  )

  set page(
    paper: paper-size,
    margin: PAGE_MARGIN,
    footer: if footer == auto {
      set align(center)
      set text(
        size: FOOTER_FONT_SIZE_SCALE * 1em,
        fill: font-color.lighten(50%),
      )

      context {
        let footer-items = (
          [#author.firstname #author.lastname CV],
          if date == auto {
            custom-date-format(
              datetime.today(),
              pattern: "MMMM, yyyy",
              lang: text.lang,
            )
          } else {
            date
          },
        )

        if counter(page).final().first() > 1 {
          footer-items.push(
            counter(page).display("1 / 1", both: true),
          )
        }

        footer-items.join(DOT_SEPARATOR)
      }

      if gdpr {
        [
          #linebreak()
          I authorise the processing of personal data contained within my CV,
          according to GDPR (EU) 2016/679, Article 6.1(a).
        ]
      }
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
        #set align(center)
        #set text(fill: white, font: heading-font) // if you see a warning here, your font was not found/loaded

        #text(size: 3em)[
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
          text(size: 0.95em, fill: luma(200), weight: "regular")[#smallcaps(
            position,
          )]
        }
      ]
    }
  }

  head

  v(HEADER_BODY_GAP)

  body
}


// ---- CV Layout Sections ----

/// Layout section with a full sidebar. Equivalent to the old global `side()` + body approach.
/// A single call wrapping all content produces the same result as before.
///
/// -> content
#let cv-with-side(
  /// Content for the sidebar
  /// -> content
  side-content,
  /// Main body content
  /// -> content
  body,
) = context {
  let theme = __st-theme.final()
  let side-width = __st-side-width.final()
  let profile-picture = __st-profile-picture.final()

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
    {
      set text(size: SIDE_CONTENT_FONT_SIZE_SCALE * 1em)

      show heading.where(level: 1): it => block(width: 100%, above: 2em)[
        #set text(
          font: theme.fonts.heading,
          fill: theme.accent-color,
          weight: "regular",
          size: 0.95em,
        )

        #grid(
          columns: (0pt, 1fr),
          align: horizon,
          box(
            fill: theme.accent-color,
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
          stroke: theme.accent-color + __stroke_length(1),
          radius: side-width / 2,
          width: 100%,
          profile-picture,
        )
      }

      side-content
      v(1fr)
    },
    grid.vline(stroke: theme.accent-color.lighten(40%) + __stroke_length(0.5)),
    {
      body
      v(1fr)
    },
  )
}

/// Layout section with a thin decorative sidebar.
/// Use `thin-label` and `thin-metric` helpers to build the side content.
/// Useful for supplementary sections (publications, appendices, etc.).
///
/// -> content
#let cv-thin-side(
  /// Content for the thin sidebar (use thin-label / thin-metric helpers)
  /// -> content
  side-content,
  /// Main body content
  /// -> content
  body,
) = context {
  let theme = __st-theme.final()

  grid(
    columns: (THIN_SIDE_WIDTH, auto),
    align: (top + center, top + left),
    inset: (col, _) => if col == 0 { (x: 0pt, y: 4mm) } else {
      (left: HORIZONTAL_PAGE_MARGIN / 2, y: 1mm)
    },
    {
      side-content
      v(1fr)
    },
    grid.vline(stroke: theme.accent-color.lighten(40%) + __stroke_length(0.5)),
    {
      body
      v(1fr)
    },
  )
}
