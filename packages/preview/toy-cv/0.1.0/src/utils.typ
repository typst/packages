// Utility Functions in Typst

// Author: Pierre GUYOT (@toyhugs - pierre.guyot@toyhugs.fr)
// Main repository: https://github.com/ToyHugs/toy-cv
// Date: 2025-07-18
// License: MIT License

// Utility function to create a underline for recipient names
#let recipient-line(body, color) = {
  set text(size: 1.7em, weight: 700)
  set par(spacing: 0.5em)
  body
  context {
    let size = measure(body)
    line(stroke: 2pt + color, length: size.width)
  }
}

// Function to translate text based on the provided language
#let translate(key, lang) = {
  let dict = toml("i18n/" + lang + ".toml")
  let translate-value = dict.lang.at(key, default: none)

  if translate-value != none {
    return translate-value
  }
  panic("Translation key '" + key + "' not found in language '" + lang + "'.")
}

// Function to handle prompt injection for AI systems
// From brilliant-CV @yunanwg : https://github.com/yunanwg/brilliant-CV
#let prompt-injection-function(prompt-injection, keywords-injection, i18n) = {
  let prompt-ai = ""

  if prompt-injection {
    prompt-ai = translate("prompt-injection", i18n)
  }

  if keywords-injection != none {
    prompt-ai = prompt-ai + " " + keywords-injection.join(" ")
  }

  place(text(prompt-ai, size: 1pt, fill: white), dx: 0pt, dy: 0pt)
}

// Function for creating subtitle text in CV left column
#let left-column-subtitle(body) = {
  set par(spacing: 0.4em)
  text(size: 1.5em, weight: 300)[~#body]
  rect(radius: 100%, width: 100%, height: 1.5pt, fill: black)
  v(-0.5em) // Add a vertical space after the subtitle
}

// Function to create the contact section in the CV
// TODO/FIXME : Icons aren't the same size, need to fix this with a grid
#let contact-section(
  i18n: "en",
  main-color: black,
  contact-entries: none, // Array of dictionaries
) = {
  left-column-subtitle(translate("contact", i18n))

  for value in contact-entries {
    // Ensure the logo-name, and logo-text are defined
    if (
      value.at("logo-name", default: none) == none or value.at("logo-text", default: none) == none
    ) {
      panic("Contact entry must contain 'logo-name' and 'logo-text'. It can also contain 'logo-font' and 'logo-link'.")
    }

    // If a font is provided, use it; otherwise, default to "Font Awesome 6 Free Solid"
    let logo-font = value.at("logo-font", default: "Font Awesome 6 Free Solid")

    // Create the icon with the specified font and color
    let text-display = [
      #text(fill: main-color, font: logo-font, value.logo-name)
      #value.logo-text
    ]

    // If a link is provided, wrap the icon and text in a link
    if value.at("logo-link", default: none) != none {
      link(value.logo-link, text-display)
    } else {
      // Otherwise, just display the icon and text
      text-display
    }

    parbreak()
  }
}

#let left-section(
  title: none,
  body,
) = {
  left-column-subtitle(title)
  body
}

#let right-column-subtitle(body) = {
  set par(spacing: 0.7em)
  text(size: 1.6em, weight: 800)[~#body]
}

#let cv-entry(
  title: none,
  date: none,
  subtitle: none,
  body,
) = {
  set par(spacing: 0.7em)
  grid(
    columns: (auto, 1fr, auto),
    row-gutter: 0.7em,

    column-gutter: 1em,
    [
      #set text(size: 1em)
      #title
    ],
    [],
    grid.cell(rowspan: 2)[
      *#date*
    ],
    grid.cell()[#emph()[#subtitle]],
  )
  body
}
