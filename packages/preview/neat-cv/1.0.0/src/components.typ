#import "@preview/fontawesome:0.6.0": fa-icon
#import "state.typ": (
  DOT_SEPARATOR, ENTRY_CONTENT_FONT_SIZE_SCALE, ENTRY_DATE_FONT_SIZE_SCALE,
  ENTRY_LEFT_COLUMN_WIDTH, ITEM_PILLS_FONT_SIZE_SCALE, LEVEL_BAR_BOX_HEIGHT,
  LEVEL_BAR_GAP_SIZE, SIDE_CONTENT_FONT_SIZE_SCALE, __st-author, __st-theme,
  __stroke_length,
)


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
  /// -> float
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
    let accent-color-value = if accent-color == none {
      __st-theme.final().accent-color
    } else {
      accent-color
    }
    let col-width = (width - LEVEL_BAR_GAP_SIZE * (max-level - 1)) / max-level
    let levels = range(max-level).map(l => box(
      height: LEVEL_BAR_BOX_HEIGHT,
      width: 100%,
      stroke: accent-color-value + __stroke_length(0.75),
      rect(
        width: 100%
          * if (level - l < 0) { 0 } else if (level - l > 1) { 1 } else {
            level - l
          },
        height: 100%,
        fill: accent-color-value,
      ),
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
        #text(
          size: ENTRY_DATE_FONT_SIZE_SCALE * 1em,
          fill: theme.font-color.lighten(50%),
          date,
        )
      ],
      [
        #set text(size: ENTRY_CONTENT_FONT_SIZE_SCALE * 1em)

        #text(weight: "semibold", title)

        #text(size: 0.9em, smallcaps([
          #if institution != "" or location != "" [
            #institution
            #h(1fr)
            #if location != "" [
              #fa-icon("location-dot", size: 0.85em, fill: theme.accent-color)
              #location
            ]
          ]
        ]))

        #text(size: 0.9em, description)
      ],
    )
  ]
}

/// Reference entry (person name, role, contact). Semantic alias for `entry`.
///
/// -> content
#let reference(
  /// Person's name
  /// -> string | none
  name: none,
  /// Role or title
  /// -> string
  role: "",
  /// Location
  /// -> string
  location: "",
  /// Contact details or description
  /// -> content
  description,
) = entry(title: name, institution: role, location: location, description)

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
    let social-defs = (
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

    for (key, icon, url-prefix) in social-defs {
      if key in author {
        let url = url-prefix + author.at(key)
        let display = author.at(key)

        if key == "website" {
          display = display.replace(regex("https?://"), "")
        } else if key == "mastodon" {
          url = {
            let parts = display.split("@")
            if parts.len() >= 3 {
              "https://" + parts.at(2) + "/@" + parts.at(1)
            } else {
              url-prefix + display
            }
          }
        }

        __social-link(icon, url, display)
      }
    }

    if "custom-links" in author {
      for link in author.custom-links {
        __social-link(
          if "icon-name" in link and link.icon-name != none {
            link.icon-name
          } else {
            "link"
          },
          link.url,
          link.label,
        )
      }
    }
  }
)

/// Displays the author's contact information (email, phone, address).
///
/// -> content
#let contact-info() = context {
  let author = __st-author.final()
  let accent-color = __st-theme.final().accent-color

  let contact-defs = (
    ("email", "envelope", a => link("mailto:" + a.email, a.email)),
    (
      "matrix",
      "comment",
      a => link("https://matrix.to/#/" + a.matrix, a.matrix),
    ),
    ("phone", "mobile-screen", a => link("tel:" + a.phone, a.phone)),
    ("address", "house", a => a.address),
  )

  let contact-items = ()
  for (key, icon, render) in contact-defs {
    if key in author {
      contact-items += (
        [#v(-0.2em) #fa-icon(icon, fill: accent-color)],
        render(author),
      )
    }
  }

  if contact-items.len() > 0 {
    table(
      columns: (1em, 1fr),
      align: (center, left),
      inset: 0pt,
      column-gutter: 0.5em,
      row-gutter: 1em,
      stroke: none,
      ..contact-items
    )
  }
}


// ---- Thin Sidebar Helpers ----

/// A section label for use in `cv-thin-side` sidebar content.
/// Displays rotated text reading top-to-bottom, styled like sidebar headings.
///
/// -> content
#let thin-label(
  /// Label text
  /// -> string
  label,
) = context {
  let theme = __st-theme.final()
  let content = text(
    font: theme.fonts.heading,
    fill: theme.accent-color,
    size: SIDE_CONTENT_FONT_SIZE_SCALE * 1.3em,
    weight: "regular",
    label,
  )
  rotate(270deg, reflow: true, box(width: measure(content).width, content))
}

/// A metric item for use in `cv-thin-side` sidebar content.
/// Displays all label–value pairs in a single rotated line with dot separators.
///
/// -> content
#let thin-metrics(
  /// Metric array of dictionaries with keys `label` and `value`.
  /// -> array
  metrics,
) = context {
  let theme = __st-theme.final()

  let items = metrics.map(metric => {
    let label = metric.at("label", default: "")
    let value = metric.at("value", default: "")

    set text(size: SIDE_CONTENT_FONT_SIZE_SCALE * 1.2em)

    [
      #text(fill: theme.font-color.lighten(30%), label) #h(0.2em) #text(
        weight: "semibold",
        fill: theme.accent-color,
        value,
      )
    ]
  })

  let separator = DOT_SEPARATOR
  let content = items.join(separator)
  rotate(270deg, reflow: true, box(width: measure(content).width, content))
}
