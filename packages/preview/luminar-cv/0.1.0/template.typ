// This is a CV template created using Typst, a modern typesetting system. The template is designed to be clean and professional, with a focus on readability and clear organization of information. It includes sections for the candidate's name and positions, contact information, bio, education, experience, skills, languages, and publications. The template also uses FontAwesome icons to enhance the visual appeal of the contact information and other sections. The colors for skill highlights and links can be customized through state variables, allowing for easy personalization of the CV.

// Import FontAwesome icons
#import "@preview/fontawesome:0.6.1": *

#let header(
  name: none,
  positions: (),
) = {
  // The header component displays the candidate's name prominently at the top of the CV, along with a list of positions or titles held by the candidate. The name is styled in a larger font size and bold weight to make it stand out, while the positions are displayed in a smaller font size below the name. The positions are separated by a dash for clarity. This component serves as the main introduction to the candidate and sets the tone for the rest of the CV.
  text(size: 20pt, weight: "bold")[#name]

  // Compensate for linebreak size of large font size
  v(-14pt)

  for position in positions {
    text(size: 10pt)[#position]
    if position != positions.last() {
      text(size: 10pt)[ \- ]
    }
  }
}

#let contact-header(
  phone: none,
  email: none,
  website: none,
  linkedin: none,
  github: none,
  location: none,
) = {
  // The contact header displays various contact information such as phone number, email, website, LinkedIn, GitHub, and location. Each piece of information is accompanied by a corresponding FontAwesome icon for visual clarity. The contact items are displayed in a horizontal layout with some spacing between them.
  let items = ()

  if phone != none {
    items.push(text(size: 9pt)[#fa-phone(solid: true) #h(2pt) #link("tel:" + phone)[#phone]])
  }

  if email != none {
    items.push(text(size: 9pt)[#fa-envelope(solid: true) #h(2pt) #link("mailto:" + email)[#email]])
  }

  if website != none {
    items.push(text(size: 9pt)[#fa-globe(solid: true) #h(2pt) #link("https://" + website)[#website]])
  }

  if linkedin != none {
    items.push(text(size: 9pt)[#fa-linkedin(solid: true) #h(2pt) #link(
        "https://www.linkedin.com/in/" + linkedin,
      )[linkedin.com/in/#linkedin]])
  }

  if github != none {
    items.push(text(size: 9pt)[#fa-github(solid: true) #h(2pt) #link(
        "https://github.com/" + github,
      )[github.com/#github]])
  }

  if location != none {
    items.push(text(size: 9pt)[#fa-location-dot(solid: true) #h(2pt) #location])
  }

  linebreak()

  for item in items {
    box(item)
    if item != items.last() {
      h(16pt)
    }
  }
}

// Define colors as state variables to allow for dynamic updates and consistent styling across the document
#let SKILL-HIGHLIGHT-COLOR = state("skill-highlight-color", rgb("#135b8f"))
#let LINK-COLOR = state("link-color", rgb("#135b8f"))

#let cv(
  name: none,
  positions: (),
  contact: (:),
  bio: none,
  page-numbering: true,
  skill-highlight-color: rgb("#135b8f"),
  link-color: rgb("#135b8f"),
  doc,
) = {
  // The main CV component sets up the overall styling and layout of the document. It takes in various parameters for the header, contact information, bio, and styling options. The page is formatted with A4 paper size and custom margins, and the text is set to use the Calibri font. The header and contact information are displayed at the top of the page, followed by an optional bio section. The rest of the document content is passed in as a child component (doc) that can include sections for education, experience, skills, publications, etc.

  // The skill-highlight-color and link-color parameters allow for customization of the colors used for highlighted skills and links throughout the document. These colors are stored in state variables that can be accessed by child components to ensure consistent styling across the entire CV.
  SKILL-HIGHLIGHT-COLOR.update(skill-highlight-color)
  LINK-COLOR.update(link-color)

  set page(
    paper: "a4",
    margin: (x: 1.5cm, y: 1.5cm),
    numbering: if page-numbering { "-1-" } else { none },
  )

  set text(
    font: "Calibri",
    size: 10pt,
    lang: "en",
  )

  set par(justify: false)

  header(name: name, positions: positions)
  contact-header(..contact)

  if bio != none {
    v(1pt)
    text(size: 9.5pt, fill: luma(100))[
      #fa-quote-left(solid: true, size: 7pt)
      #text(style: "italic")[#bio]
      #fa-quote-right(solid: true, size: 7pt)
    ]
    v(1pt)
  }

  line(length: 100%, stroke: 1.5pt)

  doc
}

#let body-link(url, label) = context {
  // Body links are styled with a small external link icon and a custom color. The link is displayed in the same font size as the surrounding text to create a seamless integration with the body content.
  let link-color = LINK-COLOR.get()
  show link: it => box(text(fill: link-color)[#fa-external-link-alt(solid: true) #h(2pt) #it])
  link(url)[#label]
}

#let section(
  title: none,
  body,
) = {
  // Sections are separated by a title in a larger font size and a horizontal line. The section body is displayed below the title with some vertical spacing to create a clear separation between sections.
  text(size: 9pt, fill: luma(129))[#upper(title)]
  v(-6pt)
  body
  v(2pt)
  line(length: 100%, stroke: 0.5pt + luma(200))
  v(2pt)
}

#let entry(
  title: none,
  subtitle: none,
  date: none,
  body,
) = {
  // Entries are formatted in a compact style, with the title on the left and the date on the right. The title is followed by an optional subtitle in a smaller font size and a lighter color. The body of the entry is displayed below the title and subtitle, with a smaller font size to create a visual hierarchy.
  v(4pt)
  grid(
    columns: (1fr, auto),
    column-gutter: 12pt,
    {
      text(size: 10pt, weight: "bold")[#title]
      if subtitle != none {
        linebreak()
        text(size: 9.5pt, fill: luma(100))[#subtitle]
      }
    },
    align(right)[
      #text(size: 9pt, fill: luma(130))[#date]
    ],
  )
  v(-4pt)
  text(size: 9.5pt)[#body]
}

#let skill(body, highlight: false) = context {
  // Skills are displayed as rounded boxes with a light background color. Highlighted skills have a different background color and a stronger border to make them stand out. The skill name is displayed in a smaller font size to create a visual hierarchy.
  let highlight-color = SKILL-HIGHLIGHT-COLOR.get()
  let bg = if highlight { highlight-color.lighten(85%) } else { luma(240) }
  let fg = if highlight { highlight-color } else { luma(90) }
  box(
    fill: bg,
    stroke: 0.5pt + if highlight { highlight-color } else { luma(90) },
    radius: 999pt,
    inset: (x: 8pt, y: 3pt),
  )[
    #text(size: 9pt, fill: fg)[#body]
  ]
  h(4pt)
}

#let languages(languages, num-columns: 3) = {
  // Languages are displayed in a compact grid format, with the language name on the left and the proficiency level on the right. The proficiency level is displayed in a smaller font size and a lighter color to create a visual hierarchy.
  v(6pt)
  grid(
    columns: num-columns,
    column-gutter: 1fr,
    row-gutter: 8pt,
    ..languages.map(lang => [#lang.name #text(fill: luma(100))[ \- #lang.level]])
  )
}

#let publication(
  title: none,
  authors: none,
  journal: none,
  year: none,
  doi: none,
  note: none,
) = {
  // Publications are formatted in a compact style, with the title on the left and the year on the right. The title is followed by the authors, journal, and an optional note (e.g., "under review"). If a DOI is provided, a link to the publication is included.
  v(4pt)
  grid(
    columns: (1fr, auto),
    {
      text(style: "italic")[#title]
      linebreak()
      if authors != none {
        text(size: 9pt, fill: luma(100))[#authors]
        linebreak()
      }
      if journal != none {
        text(size: 9pt, fill: luma(100))[#journal]
      }
      if note != none {
        text(size: 9pt, fill: luma(100))[ \- #note]
      }
      if doi != none {
        text(size: 9pt)[ \- #body-link("https://doi.org/" + doi)[doi: #doi]]
      }
    },
    align(right)[
      #text(size: 9pt, fill: luma(130))[#year]
    ],
  )
}
