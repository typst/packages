//! Titlepage definition.


#import "locale.typ" as locale
#import "utils.typ": newpage


/// Prints the titlepage of the document, including its backpage.
///
/// - author (str): Author full name.
/// - date (datetime): Presentation date.
/// - language (str): Language of the cover.
/// - title (str): Thesis title.
/// - type-of-thesis (str): Thesis type.
/// - date-format (str): Format syntax (see https://typst.app/docs/reference/foundations/datetime/#format)
/// - degree (str): Thesis degree/master.
/// - location (str): Presentation location.
/// - advisors (array): Array of advisor names (`str`).
/// - license (bool): Whether to include a CC BY-NC-ND 4.0 license.
/// - accent-color (color): Accent color for the page.
/// - double-sided (bool): Whether to use double-sided pages.
/// - title-font (str, auto): Font of the title.
/// - font-size (lenght): Font size.
/// - logo-type (str): Type of logo (`"old"` or "`new"`).
///
/// -> content
#let titlepage(
  author,
  date,
  language,
  title,
  type-of-thesis,
  date-format,
  degree,
  location,
  advisors,
  accent-color,
  style,
  license: true,
  title-font: auto,
  font-size: 16pt,
  logo-type: "new",
) = {
  // general configuration
  set page(
    margin: (x: if style == "fancy" { 2cm } else { 3cm }, y: 2cm),
    header: [],
    footer: [],
  )
  set par(justify: false, leading: 0.7em)
  show link: set text(black)

  set text(size: font-size, fill: accent-color, hyphenate: false)
  if title-font != auto {
    set text(font: title-font)
  }
  set align(center)

  // logo
  if logo-type == "new" {
    image(
      "img/new_uc3m_logo.svg",
      width: if style == "clean" { 60% } else { 100% },
    )
    v(if style == "fancy" { 3em } else { 2em })
  } else {
    image("img/old_uc3m_logo.svg", width: 35%)
    v(0.5em)
  }

  box(
    width: if style == "fancy" { 80% } else { 100% },
    {
      // degree
      text(size: 1.2em, weight: "regular", degree + parbreak())

      // type-of-thesis
      text(size: 1.2em, style: "italic", type-of-thesis + parbreak())

      // title
      text(
        size: if style == "clean" { 2em } else { 1.6em },
        weight: if style == "clean" { "semibold" } else { "medium" },
        quote(title),
      )
      parbreak()

      // line
      line(length: 70%, stroke: (paint: accent-color, thickness: 0.7pt))
      v(0.7em)

      // author
      text(size: 1.2em, style: "italic", locale.AUTHOR.at(language))
      linebreak()
      text(
        size: 1.3em,
        weight: if style == "clean" { "semibold" } else { "medium" },
        author,
      )
      parbreak()
      v(0.7em)

      // advisors
      text(
        size: 1.2em,
        style: "italic",
        {
          if advisors.len() > 1 {
            locale.ADVISORS.at(language)
          } else { locale.ADVISOR.at(language) }
        },
      )
      linebreak()

      for advisor in advisors {
        text(size: 1.2em, advisor)
        linebreak()
      }

      parbreak()
      v(1em)

      // location
      text(size: 1.1em, location)
      linebreak()

      // date
      text(size: 1.1em, {
        // currently, Typst doesn't support localization for the format syntax
        if (language != "en" and date-format.contains("[month repr:long]")) {
          date-format = date-format.replace(
            "[month repr:long]",
            locale.MONTHS.at(language).at(date.month() - 1),
          )
        }

        date.display(date-format)
      })
    },
  )

  // license
  if license {
    place(
      bottom + left,
      {
        set text(fill: black, size: 0.5em)
        set par(justify: false)
        box(width: 60%, {
          image("img/creativecommons.png", width: 3.5cm)
          v(0.05em)
          locale.CC-LICENSE.at(language)
        })
      },
    )
  }
}
