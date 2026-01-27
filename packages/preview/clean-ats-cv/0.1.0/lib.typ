// clean-ats-cv: A clean, ATS-friendly CV layout for Typst
// https://github.com/NicolaiSchmid/typst-cv

// Default colors
#let default_primary_color = rgb("#022359")
#let default_secondary_color = rgb("#757575")
#let default_link_color = rgb("#14A4E6")

// Default fonts (bundled with package)
#let default_font = "Carlito"
#let default_math_font = "DejaVu Sans"

// Default separator
#let default_separator = text(
  font: "Carlito",
  " \u{007c} ",
)

// Icons bundled with the package
#let linkedin_icon = image("icons/linkedin.svg", height: 0.8em)
#let github_icon = image("icons/github.svg", height: 0.8em)
#let x_icon = image("icons/x.svg", height: 0.8em)

/// Format a dated entry with company name and date
/// - company: The company or organization name
/// - date: The date or date range
#let date(company, date) = {
  [
    #text(weight: "bold", [-])
    #text(size: 10pt, weight: "bold", company)
    #h(1fr)
    #text(weight: "regular", size: 10pt, fill: default_secondary_color, date)
  ]
}

/// Format a dated entry with company name, date, and location
/// - company: The company or organization name
/// - date: The date or date range
/// - location: The location (city, country, etc.)
#let dateLocation(company, date, location) = {
  [
    #text(weight: "bold", [-])
    #text(size: 10pt, weight: "bold", company)
    #h(1fr)
    #text(weight: "regular", size: 9pt, fill: default_secondary_color, location)
    #h(0.1em)
    #text(weight: "regular", size: 11pt, fill: default_secondary_color, date)
  ]
}

/// Create an indented paragraph
/// - body: The content to indent
#let indent-par(body) = {
  let indent = 5pt
  set par(first-line-indent: indent, hanging-indent: indent)
  par(h(indent) + body)
}

/// Display contact details header
/// - alignment: Text alignment (default: center + horizon)
/// - icons: Whether to show icons (default: none, meaning auto)
/// - separator: Separator between items
/// - color: Link color
/// - details: Dictionary with contact details
#let show_details_text(
  alignment: center + horizon,
  icons: none,
  separator: none,
  color: none,
  details,
) = {
  let show_line_from_dict(dict, key) = {
    if dict.at(key, default: none) != none [#dict.at(key) \ ]
  }

  if separator == none {
    separator = default_separator
  }

  if color == none {
    color = default_link_color
  }

  grid(
    columns: (1fr, auto),
    [
      *#text(size: 16pt, details.at("name"))*\
      #details.at("address", default: "")
    ],
    align(
      right,
      text(size: 10pt, {
        if details.at("phonenumber", default: none) != none {
          link("tel:" + details.at("phonenumber"))
        }
        if details.at("phonenumber", default: none) != none and details.at("email", default: none) != none {
          [ | ]
        }
        if details.at("email", default: none) != none {
          link("mailto:" + details.at("email"))
        }
        linebreak()
        if details.at("linkedin", default: none) != none {
          box(baseline: 0.1em, linkedin_icon)
          [ ]
          link("https://" + details.at("linkedin"))[#details.at("linkedin_label", default: "/in/profile")]
        }
        if details.at("github", default: none) != none {
          if details.at("linkedin", default: none) != none { [ | ] }
          box(baseline: 0.1em, github_icon)
          [ ]
          link("https://" + details.at("github"))[#details.at("github_label", default: "/username")]
        }
        if details.at("twitter", default: none) != none {
          if details.at("github", default: none) != none or details.at("linkedin", default: none) != none { [ | ] }
          box(baseline: 0.1em, x_icon)
          [ ]
          link("https://" + details.at("twitter"))[#details.at("twitter_label", default: "/username")]
        }
      }),
    ),
  )
}

/// Main CV configuration function
/// Apply this with a show rule: #show: doc => conf(details, doc)
///
/// - primary_color: Primary color for headings and accents
/// - secondary_color: Secondary color for dates and locations
/// - link_color: Color for links
/// - font: Main font family
/// - math_font: Font for math equations
/// - separator: Separator character between items
/// - list_point: List bullet point character
/// - details: Dictionary with contact details (name, email, phonenumber, address, linkedin, github, twitter)
/// - doc: The document content
#let conf(
  primary_color: none,
  secondary_color: none,
  link_color: none,
  font: none,
  math_font: none,
  separator: none,
  list_point: none,
  details,
  doc,
) = {
  if primary_color == none {
    primary_color = default_primary_color
  }

  if secondary_color == none {
    secondary_color = default_secondary_color
  }

  if link_color == none {
    link_color = default_link_color
  }

  if font == none {
    font = default_font
  }

  if math_font == none {
    math_font = default_math_font
  }

  if separator == none {
    separator = text(
      fill: primary_color,
      text(font: "Carlito", " \u{007c} "),
    )
  }

  if list_point == none {
    list_point = sym.bullet
  }

  // Custom show rules
  show math.equation: set text(font: math_font)
  show heading.where(level: 1): title => grid(
    columns: 2,
    gutter: 1%,
    text(size: 13pt, fill: primary_color, [#title <sectionn>]),
    line(
      start: (0pt, 0.4em),
      length: 100%,
      stroke: (paint: secondary_color, thickness: 0.05em),
    ),
  )
  show heading.where(level: 2): set text(size: 11pt)
  show heading.where(level: 3): set text(weight: "regular")
  show heading.where(level: 2): set block(spacing: 0.7em)
  show heading.where(level: 3): set block(spacing: 0.7em)

  show link: set text(fill: primary_color)
  show list: set text(size: 10pt)

  // Custom set rules
  set text(font: font, ligatures: true)
  set par(justify: true)

  set page(
    margin: (top: 0.8cm, left: 1cm, bottom: 1cm, right: 1cm),
    footer-descent: 0%,
    header-ascent: 0%,
  )

  set list(indent: 5pt, marker: text(fill: primary_color, list_point))

  show_details_text(details)

  doc
}
