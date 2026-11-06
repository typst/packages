#import "components/header.typ": contact-info, default-contact-info, header

// Configures the resume document and renders its header and body.
// Customize the header, visual style, language, and PDF metadata with `resume.with(...)`.
// In the body, use `section(...)` to create sections and the exported components
// `work`, `edu`, `project`, `certificates`, `extracurriculars`, `skills`, and `languages`
// to format common resume entries.

#let resume(
  // Name, headline, and contact details shown in the document header.
  header-info: (
    style: "row",
    contact: (
      show-icons: false,
      show-sensitive-info: true,
      position: left,
      gap: 0.2em,
      // To add a contact field, define it in `src/components/header.typ` under
      // `contact-fields` and provide its value in `header-info.contact.info`.
      info: default-contact-info,
    ),
    author: (
      name: str,
      headline: str,
      position: left,
      uppercase: false,
    ),
  ),
  // Document-wide appearance. Adjust font, page size, accent color, and margins here.
  style: (
    accent-color: "#000000",
    font: "Calibri",
    paper: "us-letter",
    font-size: 10pt,
    margin: (
      top: 0.3in,
      bottom: 0.3in,
      left: 0.4in,
      right: 0.5in,
    ),
  ),
  // Language and regional conventions applied to document text.
  config: (
    lang: "en",
    region: "us",
  ),
  // Metadata embedded in the generated PDF.
  document-metadata: (
    title: "",
    description: "",
    keywords: "cv",
  ),
  // Resume content supplied after `resume.with(...)`.
  body,
) = {
  // Set document metadata from the header and metadata options.
  set document(
    author: header-info.author.name,
    title: document-metadata.title,
    keywords: document-metadata.keywords,
    description: document-metadata.description,
    date: none,
  )

  // Apply document-wide text settings, including font and language.
  set text(
    // LaTeX style font
    font: style.font,
    size: style.font-size,
    lang: config.lang,
    region: config.region,
    // Disable ligatures so ATS systems do not get confused when parsing fonts.
    ligatures: false,
  )

  set page(
    margin: (
      top: style.margin.top,
      bottom: style.margin.bottom,
      right: style.margin.right,
      left: style.margin.left,
    ),
    paper: style.paper,
  )

  // Style links consistently throughout the resume.
  show link: underline
  show link: set text(fill: rgb("#0645AD"))

  // Apply the configured accent color to headings.
  show heading: set text(
    fill: rgb(style.accent-color),
  )

  // Format level-one headings as compact, small-caps section titles.
  show heading.where(
    level: 1,
  ): it => block[
    #set text(style.font-size + 2pt, weight: "bold")
    #smallcaps(it.body)
    #v(-1em)
    #line(length: 100%, stroke: stroke(thickness: 0.4pt))
  ]
  // show heading.where(level: 1): it => block[
  //   #pad(top: 0pt, bottom: -10pt, [#smallcaps(it.body)])
  //   #line(length: 100%, stroke: 1pt)
  // ]

  // Render the configured name, headline, and contact information.
  header(
    config: header-info,
    font-size: style.font-size,
  )

  // Justify and render the resume content passed to this show rule.
  set par(justify: true)
  body
}
