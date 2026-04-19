#import "@preview/fontawesome:0.5.0": fa-icon

// Global state for theme and author information
#let __st-theme = state("theme")
#let __st-author = state("author")


// ---- Icon & Visual Helpers ----

/// Draws a circular FontAwesome icon.
/// - icon (string): FontAwesome icon name
/// - size (length): Icon size
#let __fa-icon-outline(icon, size: 1.5em) = (
  context {
    let theme = __st-theme.final()

    box(
      fill: theme.accent-color.lighten(10%),
      width: size,
      height: size,
      radius: size / 2,
      align(center + horizon, fa-icon(icon, fill: white, size: size - .5em)),
    )
  }
)

/// Displays a social link with icon and text.
/// - icon (string): FontAwesome icon name
/// - url (string): Link URL
/// - display (string): Display text
/// - size (length): Icon size
#let __social-link(icon, url, display, size: 1.5em) = (
  context {
    let theme = __st-theme.final()

    set text(size: 0.95em)

    block(width: 100%, height: size, radius: 0.6em, align(horizon, [
      #__fa-icon-outline(icon, size: size)
      #box(inset: (left: 1pt), height: 100%, link(url)[#display])
    ]))
  }
)


// ---- Visual Elements ----

/// Draws a horizontal level bar (for skills/languages).
/// - level (int): Filled level
/// - max-level (int): Maximum level (default: 5)
/// - width (length): Total width
/// - accent-color (color): Bar color (optional)
#let level-bar(
  level,
  max-level: 5,
  width: 3.5cm,
  accent-color: none,
) = {
  context {
    let _accent-color = if accent-color == none {
      __st-theme.final().accent-color
    } else {
      accent-color
    }
    let col-width = (width - 2pt * (max-level - 1)) / max-level
    let levels = range(max-level).map(l => box(
      height: 3.5pt,
      width: 100%,
      fill: if (l < level) {
        _accent-color
      },
      stroke: _accent-color + 0.75pt,
    ))
    grid(
      columns: (col-width,) * max-level,
      gutter: 2pt,
      ..levels
    )
  }
}

/// Displays a list of items as "pills" (tags).
/// - items (array): List of items to display as pills
#let item-pills(items) = (
  context {
    let theme = __st-theme.final()

    set text(size: 0.85em)
    set par(spacing: 0.5em)

    items
      .map(item => box(
        inset: (x: 3pt, y: 3pt),
        stroke: theme.accent-color + 0.5pt,
        item,
      ))
      .join([ ])
  }
)


// ---- Entry Blocks ----

/// Generic entry for education, experience, etc.
/// - title (string): Entry title
/// - date (string): Date or range
/// - institution (string): Institution or company
/// - location (string): Location
/// - description (content): Description/details
#let entry(
  title: none,
  date: "",
  institution: "",
  location: "",
  description,
) = {
  context block(above: 1em, below: 0.65em)[
    #let theme = __st-theme.final()

    #grid(
      columns: (2cm, auto),
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
          #fa-icon(
            "location-dot",
            size: 0.85em,
            fill: theme.accent-color,
          ) #location
        ]))

        #text(size: 0.9em, description)
      ],
    )
  ]
}

/// Entry with a level bar (e.g., for skills).
/// - title (string): Item name
/// - level (int): Level value
/// - subtitle (string): Optional subtitle
#let item-with-level(title, level, subtitle: "") = (
  context {
    let theme = __st-theme.final()

    block()[
      #text(title)
      #h(1fr)
      #text(fill: theme.font-color.lighten(40%), subtitle)
      #level-bar(level, width: 100%)
    ]
  }
)


// ---- Social & Contact Info ----

/// Displays all available social links for the author.
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
#let contact-info() = (
  context [
    #let author = __st-author.final()
    #let theme = __st-theme.final()
    #let accent-color = theme.accent-color
    #let contact-items = ()

    #if "email" in author {
      contact-items += (
        fa-icon("at", fill: accent-color),
        link("mailto:" + author.email)[#text(author.email)],
      )
    }

    #if "phone" in author {
      contact-items += (
        fa-icon("mobile-screen", fill: accent-color),
        link("tel:" + author.phone)[#text(author.phone)],
      )
    }

    #if "address" in author {
      contact-items += (
        fa-icon("envelope", fill: accent-color),
        author.address,
      )
    }

    #if contact-items.len() > 0 {
      table(
        columns: (1em, 1fr),
        align: (left, left),
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
/// - pub (dictionary): Publication data
/// - highlight-authors (array): Authors to highlight
/// - max-authors (int): Max authors to display before "et al."
#let __format-publication-entry(pub, highlight-authors, max-authors) = {
  set text(size: 0.7em)

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
/// - yaml-data (dictionary): Data loaded from YAML file
/// - highlight-authors (array): Authors to highlight
/// - max-authors (int): Max authors to display per entry
#let publications(yaml-data, highlight-authors: (), max-authors: 10) = (
  context {
    let theme = __st-theme.final()
    let publication-data = yaml-data.values()
    let publications-by-year = (:)

    set block(above: 0.7em)

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
        columns: (2cm, auto),
        align: (right, left),
        column-gutter: .8em,
        [
          #text(size: 0.8em, fill: theme.font-color.lighten(50%), year)
        ],
        [
          #for publication in publications-by-year.at(year) {
            block(__format-publication-entry(
              publication,
              highlight-authors,
              max-authors,
            ))
          }
        ],
      )
    }
  }
)


// ---- Main CV Template ----

/// Main CV layout. Sets up theme, fonts, page, and structure.
/// - author (dictionary): Author information (firstname, lastname, etc.)
/// - profile-picture (image): Profile picture
/// - accent-color (color): Accent color for highlights
/// - font-color (color): Main text color
/// - header-color (color): Color for header background
/// - date (string): Date string for footer
/// - heading-font (string): Font for headings
/// - body-font (array): Font(s) for body text
/// - paper-size (string): Paper size
/// - side-width (length): Sidebar width
/// - gdpr (boolean): Add GDPR data usage in the footer
/// - footer (content): Optional custom footer
/// - body (content): Main content of the CV
#let cv(
  author: (:),
  profile-picture: none,
  accent-color: rgb("#408abb"),
  font-color: rgb("#333333"),
  header-color: luma(50),
  date: datetime.today().display("[month repr:long] [year]"),
  heading-font: "Fira Sans",
  body-font: ("Noto Sans", "Roboto"),
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
            + author.at(
              "lastname",
              default: "",
            )
        ),
      )

      body
    }
  )

  set text(font: body-font, size: 10pt, weight: "light", fill: font-color)

  set page(
    paper: paper-size,
    margin: (left: 12mm, right: 12mm, top: 10mm, bottom: 12mm),
    footer: if footer == auto {
      [
        #set text(size: 0.7em, fill: font-color.lighten(50%))

        #grid(
          columns: (side-width, 1fr),
          align: center,
          gutter: 2mm,
          inset: (col, _) => {
            if col == 0 {
              (right: 4mm)
            } else {
              (left: 4mm)
            }
          },
          [
            #context counter(page).display("1 / 1", both: true)
          ],
          [
            #author.firstname #author.lastname CV #box(inset: (x: 3pt), sym.dot.c) #text(date)
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
            author.position.join(box(inset: (x: 5pt), sym.dot.c))
          } else {
            author.position
          }

          #set text(fill: white, font: heading-font)

          #text(size: 3em)[
            #text(weight: "light")[#author.firstname] #text(
              weight: "medium",
            )[#author.lastname]
          ]

          #v(-0.5em)

          #text(
            size: 0.95em,
            fill: luma(200),
            weight: "regular",
          )[#smallcaps(position)]
        ]
      ]
    }
  }

  let side-content = context {
    set text(size: 0.72em)

    show heading.where(level: 1): it => block(width: 100%, above: 2em)[
      #set text(font: heading-font, fill: accent-color, weight: "regular")

      #grid(
        columns: (0pt, 1fr),
        align: horizon,
        box(fill: accent-color, width: -4pt, height: 12pt, outset: (left: 6pt)),
        it.body,
      )
    ]

    if profile-picture != none {
      block(
        clip: true,
        stroke: accent-color + 1pt,
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

  v(2mm)

  grid(
    columns: (side-width + 6mm, auto),
    align: (left, left),
    inset: (col, _) => {
      if col == 0 {
        (right: 6mm, y: 1mm)
      } else {
        (left: 6mm, y: 1mm)
      }
    },
    side-content,
    grid.vline(stroke: luma(180) + 0.5pt),
    body-content,
  )
}

/// Defines sidebar content for the CV.
/// - content (content): Content to display in the sidebar
#let side(content) = {
  context state("side-content").update(content)
}
