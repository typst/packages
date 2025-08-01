#import "@preview/fontawesome:0.6.0": fa-icon

// Global state for theme and author information
#let __st-theme = state("theme")
#let __st-author = state("author")

// ---- Constants ----
/// Scaling factor to apply to the body font size to obtain the side-content font size.
#let SIDE_CONTENT_FONT_SIZE_SCALE = 0.72
/// Scaling factor to apply to the body font size to obtain the item-pills font size.
#let ITEM_PILLS_FONT_SIZE_SCALE = 0.85
/// Scaling factor to apply to the body font size to obtain the footer font size.
#let FOOTER_FONT_SIZE_SCALE = 0.7
/// Gap between the header (colored block at the top) and body
#let HEADER_BODY_GAP = 2mm
/// Horizontal page margin
#let HORIZONTAL_PAGE_MARGIN = 12mm
/// All page margins, defined explicitly
#let PAGE_MARGIN = (
  left: HORIZONTAL_PAGE_MARGIN,
  right: HORIZONTAL_PAGE_MARGIN,
  top: HORIZONTAL_PAGE_MARGIN - HEADER_BODY_GAP,
  bottom: HORIZONTAL_PAGE_MARGIN,
)
/// Length of the gap between individual sections of the level bar
#let LEVEL_BAR_GAP_SIZE = 2pt
/// Height of the box of each individual section in the level bar
#let LEVEL_BAR_BOX_HEIGHT = 3.5pt
/// Width of the left column in an `entry()` or `publication()`
#let ENTRY_LEFT_COLUMN_WIDTH = 5.7em

// ---- Utility ----
/// Calculate/scale the length of stroke elements, as strokes are visual
/// elements and should have a constant length.
///
/// -> length
#let __stroke_length(x) = x * 1pt


// ---- Icon & Visual Helpers ----

/// Draws a circular FontAwesome icon.
///
/// -> content
#let __fa-icon-outline(
  /// FontAwesome icon name
  /// -> string
  icon,
  /// Icon size
  /// -> length
  size: 1.5em,
) = (
  context {
    let theme = __st-theme.final()

    box(
      fill: theme.accent-color.lighten(10%),
      width: size,
      height: size,
      radius: size / 2,
      align(
        center + horizon,
        [
          // Adjust vertical position slightly to center the icon
          #v(-0.15 * size)
          #fa-icon(icon, fill: white, size: size - .55em)
        ],
      ),
    )
  }
)

/// Displays a social link with icon and text.
///
/// -> content
#let __social-link(
  /// FontAwesome icon name
  /// -> string
  icon,
  /// Link URL
  /// -> string
  url,
  /// Display text
  /// -> string
  display,
  /// Icon size
  /// -> length
  size: 1.5em,
) = (
  context {
    let theme = __st-theme.final()

    set text(size: 0.95em)

    block(width: 100%, height: size, radius: 0.6em, align(horizon, [
      #__fa-icon-outline(icon, size: size)
      #box(inset: (left: 0.2em), height: 100%, link(url)[#display])
    ]))
  }
)


// ---- Visual Elements ----

/// Draws a horizontal level bar (for skills/languages).
///
/// -> content
#let level-bar(
  /// Filled level
  /// -> int
  level,
  /// Maximum level (default: 5)
  /// -> int
  max-level: 5,
  /// Total width
  /// -> length
  width: 3.5cm,
  /// Bar color (optional)
  /// -> color | none
  accent-color: none,
) = {
  context {
    let _accent-color = if accent-color == none {
      __st-theme.final().accent-color
    } else {
      accent-color
    }
    let col-width = (width - LEVEL_BAR_GAP_SIZE * (max-level - 1)) / max-level
    let levels = range(max-level).map(l => box(
      height: LEVEL_BAR_BOX_HEIGHT,
      width: 100%,
      fill: if (l < level) {
        _accent-color
      },
      stroke: _accent-color + __stroke_length(0.75),
    ))
    grid(
      columns: (col-width,) * max-level,
      gutter: LEVEL_BAR_GAP_SIZE,
      ..levels
    )
  }
}

/// Displays a list of items as "pills" (tags).
///
/// -> content
#let item-pills(
  /// List of items to display as pills
  /// -> array
  items,
  /// Whether to justify the pills (default: true)
  /// -> boolean
  justify: true,
) = (
  context {
    let theme = __st-theme.final()

    set text(size: ITEM_PILLS_FONT_SIZE_SCALE * 1em, spacing: 0.5em)
    set par(justify: justify)

    block(
      items
        .map(item => box(
          inset: (
            x: 0.45em / ITEM_PILLS_FONT_SIZE_SCALE,
            y: 0.45em / ITEM_PILLS_FONT_SIZE_SCALE,
          ),
          stroke: theme.accent-color + __stroke_length(0.5),
          item,
        ))
        .join(" "),
    )
  }
)

/// Displays an email link.
///
/// -> content
#let email-link(
  /// Email address
  /// -> string
  email,
) = {
  link("mailto:" + email, email)
}


// ---- Entry Blocks ----

/// Generic entry for education, experience, etc.
///
/// -> content
#let entry(
  /// Entry title
  /// -> string | none
  title: none,
  /// Date or range
  /// -> string
  date: "",
  /// Institution or company
  /// -> string
  institution: "",
  /// Location
  /// -> string
  location: "",
  /// Description/details
  /// -> content
  description,
) = {
  context block(above: 1em, below: 0.65em)[
    #let theme = __st-theme.final()

    #grid(
      columns: (ENTRY_LEFT_COLUMN_WIDTH, auto),
      align: (right, left),
      column-gutter: .8em,
      [
        #text(size: 0.8em, fill: theme.font-color.lighten(50%), date)
      ],
      [
        #set text(size: 0.85em)

        #text(weight: "semibold", title)

        #text(size: 0.9em, smallcaps([
          #institution
          #h(1fr)
          #fa-icon("location-dot", size: 0.85em, fill: theme.accent-color)
          #location
        ]))

        #text(size: 0.9em, description)
      ],
    )
  ]
}

/// Entry with a level bar (e.g., for skills).
///
/// -> content
#let item-with-level(
  /// Item name
  /// -> string
  title,
  /// Level value
  /// -> int
  level,
  /// Optional subtitle
  /// -> string
  subtitle: "",
) = (
  context {
    let theme = __st-theme.final()

    block[
      #text(title)
      #h(1fr)
      #text(fill: theme.font-color.lighten(40%), subtitle)
      #level-bar(level, width: 100%)
    ]
  }
)


// ---- Social & Contact Info ----

/// Displays all available social links for the author.
///
/// -> content
#let social-links() = (
  context {
    let author = __st-author.final()
    let social_defs = (
      ("website", "globe", ""),
      ("twitter", "twitter", "https://twitter.com/"),
      ("mastodon", "mastodon", "https://mastodon.social/"),
      ("github", "github", "https://github.com/"),
      ("gitlab", "gitlab", "https://gitlab.com/"),
      ("linkedin", "linkedin", "https://www.linkedin.com/in/"),
      ("researchgate", "researchgate", "https://www.researchgate.net/profile/"),
      (
        "scholar",
        "google-scholar",
        "https://scholar.google.com/citations?user=",
      ),
      ("orcid", "orcid", "https://orcid.org/"),
    )

    set text(size: 0.95em, fill: luma(100))

    for (key, icon, url_prefix) in social_defs {
      if key in author {
        let url = url_prefix + author.at(key)
        let display = author.at(key)

        if key == "website" {
          display = display.replace(regex("https?://"), "")
        } else if key == "mastodon" {
          url = {
            let parts = display.split("@")
            if parts.len() >= 3 {
              "https://" + parts.at(2) + "/@" + parts.at(1)
            } else {
              url_prefix + display
            }
          }
        }

        __social-link(icon, url, display)
      }
    }
  }
)

/// Displays the author's contact information (email, phone, address).
///
/// -> content
#let contact-info() = (
  context [
    #let author = __st-author.final()
    #let theme = __st-theme.final()
    #let accent-color = theme.accent-color
    #let contact-items = ()

    #if "email" in author {
      contact-items += (
        [#v(-0.2em) #fa-icon("envelope", fill: accent-color)],
        link("mailto:" + author.email, author.email),
      )
    }

    #if "phone" in author {
      contact-items += (
        [#v(-0.2em) #fa-icon("mobile-screen", fill: accent-color)],
        link("tel:" + author.phone, author.phone),
      )
    }

    #if "address" in author {
      contact-items += (
        [#v(-0.2em) #fa-icon("map", fill: accent-color)],
        author.address,
      )
    }

    #if contact-items.len() > 0 {
      table(
        columns: (1em, 1fr),
        align: (center, left),
        inset: 0pt,
        column-gutter: 0.5em,
        row-gutter: 1em,
        stroke: none,
        ..contact-items
      )
    } else {
      []
    }
  ]
)


// ---- Publications ----

/// Formats a publication entry (article, conference, etc.).
///
/// -> content
#let __format-publication-entry(
  /// Publication data
  /// -> dictionary
  pub,
  /// Authors to highlight
  /// -> array
  highlight-authors,
  /// Max authors to display before "et al."
  /// -> int
  max-authors,
) = {
  for (i, author) in pub.author.enumerate() {
    if i < max-authors {
      let author-display = {
        let author_parts = author.split(", ")
        let last_name = author_parts.at(0, default: author)
        let first_names_str = author_parts.at(1, default: "")

        let initials_content = first_names_str
          .split(" ")
          .filter(p => p.len() > 0)
          .map(p => [#p.at(0).])

        let joined_initials = if initials_content.len() > 0 {
          initials_content.join(" ")
        } else {
          []
        }

        if first_names_str == "" {
          [#last_name]
        } else {
          [#last_name, #joined_initials]
        }
      }

      if author in highlight-authors {
        text(weight: "medium", author-display)
      } else {
        author-display
      }

      if i < max-authors - 1 and i < pub.author.len() - 1 {
        if i == pub.author.len() - 2 {
          [ and ]
        } else {
          [, ]
        }
      }
    } else if i == max-authors {
      [_ et al_]
      break
    }
  }

  [. #pub.title.]

  let parent = pub.parent

  if parent.type == "proceedings" {
    [ in ]
  }

  [ #text(style: "italic", parent.title)]

  if "volume" in parent and parent.volume != none {
    [ #text(style: "italic", str(parent.volume)), ]
  }

  [ #pub.at("page-range", default: "")]

  if "date" in pub {
    [ (#pub.date).]
  }

  if "serial-number" in pub and "doi" in pub.serial-number {
    [
      doi: #link("https://doi.org/" + pub.serial-number.doi)[#text(style: "italic", str(pub.serial-number.doi))]
    ]
  }
}

/// Displays publications grouped by year from a Hayagriva YAML file.
///
/// -> content
#let publications(
  /// Data loaded from YAML file
  /// -> dictionary
  yaml-data,
  /// Authors to highlight
  /// -> array
  highlight-authors: (),
  /// Max authors to display per entry
  /// -> int
  max-authors: 10,
) = (
  context {
    let theme = __st-theme.final()
    let publication-data = yaml-data.values()
    let publications-by-year = (:)

    set block(above: 0.7em, width: 100%)

    for pub in publication-data {
      let year = str(pub.at("date", default: ""))

      if year == "" {
        continue
      }

      if year in publications-by-year {
        publications-by-year.at(year) += (pub,)
      } else {
        publications-by-year.insert(year, (pub,))
      }
    }

    for year in publications-by-year.keys().sorted().rev() {
      grid(
        columns: (ENTRY_LEFT_COLUMN_WIDTH, auto),
        align: (right, left),
        column-gutter: .8em,
        [
          #text(size: 0.8em, fill: theme.font-color.lighten(50%), year)
        ],
        [
          #for publication in publications-by-year.at(year) {
            block([
              #set text(size: 0.68em)
              #__format-publication-entry(
                publication,
                highlight-authors,
                max-authors,
              )
            ])
          }
        ],
      )
    }
  }
)


// ---- Main CV Template ----

/// Main CV layout. Sets up theme, fonts, page, and structure.
///
/// -> content
#let cv(
  /// Author information (firstname, lastname, etc.)
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
  /// -> string
  date: datetime.today().display("[month repr:long] [year]"),
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
            #context counter(page).display("1 / 1", both: true)
          ],
          [
            #author.firstname #author.lastname CV
            #box(inset: (x: 0.3em / FOOTER_FONT_SIZE_SCALE), sym.dot.c)
            #text(date)
          ],

          [],
          if gdpr {
            [
              I authorise the processing of personal data contained within my CV,
              according to GDPR (EU) 2016/679, Article 6.1(a).
            ]
          },
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

  let side-content = context {
    set text(size: SIDE_CONTENT_FONT_SIZE_SCALE * 1em)

    show heading.where(level: 1): it => block(width: 100%, above: 2em)[
      #set text(font: heading-font, fill: accent-color, weight: "regular")

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

  let body-content = {
    show heading.where(level: 1): it => block(width: 100%)[
      #set block(above: 1em)

      #text(
        fill: accent-color,
        weight: "regular",
        font: heading-font,
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
    side-content,
    grid.vline(stroke: luma(180) + __stroke_length(0.5)),
    body-content,
  )
}

/// Defines sidebar content for the CV.
///
/// -> content
#let side(
  /// Content to display in the sidebar
  /// -> content
  content,
) = {
  context state("side-content").update(content)
}
