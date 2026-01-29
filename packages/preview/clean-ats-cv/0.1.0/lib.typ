// clean-ats-cv: A clean, ATS-friendly CV layout for Typst
// https://github.com/NicolaiSchmid/clean-ats-cv
//
// REQUIRED FONTS (install manually):
// - Carlito: https://fonts.google.com/specimen/Carlito
// - DejaVu Sans: https://dejavu-fonts.github.io/
//
// macOS:   brew install --cask font-carlito font-dejavu
// Linux:   sudo apt install fonts-crosextra-carlito fonts-dejavu
// Windows: Download from the URLs above

// Default colors (private)
#let _default-primary-color = rgb("#022359")
#let _default-secondary-color = rgb("#757575")
#let _default-link-color = rgb("#14A4E6")

// Default fonts (private)
#let _default-font = "Carlito"
#let _default-math-font = "DejaVu Sans"

// Default separator (private)
#let _default-separator = text(
  font: "Carlito",
  " \u{007c} ",
)

// Icons bundled with the package (private)
#let _linkedin-icon = image("icons/linkedin.svg", height: 0.8em)
#let _github-icon = image("icons/github.svg", height: 0.8em)
#let _x-icon = image("icons/x.svg", height: 0.8em)

/// Format a dated entry with company name and date
/// - company: The company or organization name
/// - date: The date or date range
#let date(company, date) = {
  [
    #text(weight: "bold", [-])
    #text(size: 10pt, weight: "bold", company)
    #h(1fr)
    #text(weight: "regular", size: 10pt, fill: _default-secondary-color, date)
  ]
}

/// Format a dated entry with company name, date, and location
/// - company: The company or organization name
/// - date: The date or date range
/// - location: The location (city, country, etc.)
#let date-location(company, date, location) = {
  [
    #text(weight: "bold", [-])
    #text(size: 10pt, weight: "bold", company)
    #h(1fr)
    #text(weight: "regular", size: 9pt, fill: _default-secondary-color, location)
    #h(0.1em)
    #text(weight: "regular", size: 11pt, fill: _default-secondary-color, date)
  ]
}

/// Create an indented paragraph
/// - body: The content to indent
#let indent-par(body) = {
  let indent = 5pt
  set par(first-line-indent: indent, hanging-indent: indent)
  par(h(indent) + body)
}

/// Display contact details header (private)
#let _show-details-text(
  alignment: center + horizon,
  icons: none,
  separator: none,
  color: none,
  details,
) = {
  if separator == none {
    separator = _default-separator
  }

  if color == none {
    color = _default-link-color
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
          box(baseline: 0.1em, _linkedin-icon)
          [ ]
          link("https://" + details.at("linkedin"))[#details.at("linkedin_label", default: "/in/profile")]
        }
        if details.at("github", default: none) != none {
          if details.at("linkedin", default: none) != none { [ | ] }
          box(baseline: 0.1em, _github-icon)
          [ ]
          link("https://" + details.at("github"))[#details.at("github_label", default: "/username")]
        }
        if details.at("twitter", default: none) != none {
          if details.at("github", default: none) != none or details.at("linkedin", default: none) != none { [ | ] }
          box(baseline: 0.1em, _x-icon)
          [ ]
          link("https://" + details.at("twitter"))[#details.at("twitter_label", default: "/username")]
        }
      }),
    ),
  )
}

/// Main CV configuration function
/// Apply this with a show rule: #show: conf.with(details: (...))
///
/// - details: Dictionary with contact details (name, email, phonenumber, address, linkedin, github, twitter)
/// - primary-color: Primary color for headings and accents
/// - secondary-color: Secondary color for dates and locations
/// - link-color: Color for links
/// - font: Main font family
/// - math-font: Font for math equations
/// - separator: Separator character between items
/// - list-marker: List bullet point character
/// - doc: The document content
#let conf(
  details: none,
  primary-color: none,
  secondary-color: none,
  link-color: none,
  font: none,
  math-font: none,
  separator: none,
  list-marker: none,
  doc,
) = {
  assert(details != none, message: "details is required: provide at minimum (name: \"Your Name\")")
  
  let primary-color = if primary-color == none { _default-primary-color } else { primary-color }
  let secondary-color = if secondary-color == none { _default-secondary-color } else { secondary-color }
  let link-color = if link-color == none { _default-link-color } else { link-color }
  let font = if font == none { _default-font } else { font }
  let math-font = if math-font == none { _default-math-font } else { math-font }
  let separator = if separator == none {
    text(fill: primary-color, text(font: "Carlito", " \u{007c} "))
  } else { separator }
  let list-marker = if list-marker == none { sym.bullet } else { list-marker }

  // Custom show rules
  show math.equation: set text(font: math-font)
  show heading.where(level: 1): title => grid(
    columns: 2,
    gutter: 1%,
    text(size: 13pt, fill: primary-color, [#title <sectionn>]),
    line(
      start: (0pt, 0.4em),
      length: 100%,
      stroke: (paint: secondary-color, thickness: 0.05em),
    ),
  )
  show heading.where(level: 2): set text(size: 11pt)
  show heading.where(level: 3): set text(weight: "regular")
  show heading.where(level: 2): set block(spacing: 0.7em)
  show heading.where(level: 3): set block(spacing: 0.7em)

  show link: set text(fill: primary-color)
  show list: set text(size: 10pt)

  // Custom set rules
  set text(font: font, ligatures: true)
  set par(justify: true)

  set page(
    margin: (top: 0.8cm, left: 1cm, bottom: 1cm, right: 1cm),
    footer-descent: 0%,
    header-ascent: 0%,
  )

  set list(indent: 5pt, marker: text(fill: primary-color, list-marker))

  _show-details-text(details)

  doc
}
