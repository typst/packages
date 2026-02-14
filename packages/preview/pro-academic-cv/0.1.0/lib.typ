#import "@preview/cuti:0.4.0": fakesc

#let cv_section_parse_heading(text) = {
  let m = text.match(regex("^\\s*(.+?)\\s*\\(\\s*note\\s*:\\s*(.+?)\\s*\\)\\s*$"))
  if m == none {
    (title: text, note: none)
  } else {
    let caps = m.captures
    let title = caps.at(caps.len() - 2, default: text)
    let note = caps.at(caps.len() - 1, default: none)
    (title: title, note: note)
  }
}

// Two-column row: left-aligned content + right-aligned content
#let row2col(left, rhs) = [#left #h(1fr) #rhs #h(0.5em)]

#let link-svg = ```<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon icon-tabler icons-tabler-outline icon-tabler-link"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9 15l6 -6" /><path d="M11 6l.463 -.536a5 5 0 0 1 7.071 7.072l-.534 .464" /><path d="M13 18l-.397 .534a5.068 5.068 0 0 1 -7.127 0a4.972 4.972 0 0 1 0 -7.071l.524 -.463" /></svg>```.text
#let link-icon(color: rgb("#1a405d"), height: 0.9em, baseline: 20%) = {
  box(height: height, baseline: baseline, image(bytes(link-svg.replace("currentColor", color.to-hex()))))
}

#let resume(
  margin: (left: 1.4cm, right: 1.2cm, top: 0.8cm, bottom: 1cm),
  font-settings: (
    font-family: "Palatino",
    font-size: 10pt,
    author-font-size: 25pt,
    lang: "en",
  ),
  par-settings: (
    leading: 0.5em,
    spacing: 0.5em,
  ),
  list-settings: (
    bullet-list-spacing: 0.7em,
    numbered-list-spacing: 0.7em,
  ),
  link-line-settings: (
    stroke: 0.5pt + luma(200),
    offset: 2pt,
  ),
  heading-settings: (
    above-spacing: 1.2em,
    below-spacing: 0.6em,
    section-title-size: 1.1em,
    section-title-weight: "semibold",
    section-note-size: 0.8em,
    section-note-weight: "light",
    section-line-above-spacing: -0.85em,
    line-length: 100%,
    line-stroke: 0.04em + black,
  ),
  author-info: (
    name: "John Doe",
    primary-info: [
      +1-234-567-8900 | #link("mailto:john.doe@example.com")[john.doe\@example.com] | #link("https://www.john-doe.com/")[john-doe.com]
    ],
    secondary-info: [
      #link("https://www.linkedin.com/in/john-doe-linkedin")[linkedin] | #link("https://github.com/john-doe-github")[github] | #link("https://scholar.google.com/citations?user=john-doe-google-scholar")[google-scholar] | #link("https://orcid.org/john-doe-orcid")[orcid]
    ],
    tertiary-info: "Your City, Your State - Your ZIP, Your Country",
  ),
  author-position: center,
  body,
) = {
  set document(author: author-info.name, title: author-info.name)
  set page(
    paper: "a4",
    margin: margin,
  )
  set text(
    font: font-settings.font-family,
    size: font-settings.font-size,
    lang: font-settings.lang,
    ligatures: false
  )
  set par(
    leading: par-settings.leading,
    spacing: par-settings.spacing,
  )
  
  let list_marker1 = text(size: 0.6em, baseline: 0.1em)[#sym.circle.filled]
  let list_marker2 = text(size: 1.4em, baseline: -0.15em)[#sym.compose]
  set list(spacing: list-settings.bullet-list-spacing, marker: (list_marker1, list_marker2))
  set enum(spacing: list-settings.numbered-list-spacing)

  show list.item: it => block(breakable: false, it)

  show link: it => {underline(stroke: link-line-settings.stroke, offset: link-line-settings.offset, it)}

  // Small caps for section titles
  show heading.where(level: 2): it => [
    #block(breakable: false, above: heading-settings.above-spacing, below: heading-settings.below-spacing)[
      #show: it => fakesc[#text(tracking: 0.05em, it)]
      #let content_to_string(x) = {
        if x == none { "" }
        else if type(x) == str { x }
        else if x.has("text") { x.text }
        else if x.has("body") { content_to_string(x.body) }
        else if x.has("children") { x.children.map(x => content_to_string(x)).join("") }
        else { "" }
      }
      #let heading_text = content_to_string(it.body)
      #let parsed = cv_section_parse_heading(heading_text)
      #let section_note = parsed.note
      #row2col(text(size: heading-settings.section-title-size, weight: heading-settings.section-title-weight)[#parsed.title], if section_note != none { text(size: heading-settings.section-note-size, weight: heading-settings.section-note-weight)[#section_note] } else { [] })
      #v(heading-settings.section-line-above-spacing)
      #line(length: heading-settings.line-length, stroke: heading-settings.line-stroke)
    ]
  ]

  align(author-position)[
    #text(size: font-settings.author-font-size, weight: "bold")[#author-info.name] \
    #v(1em)
    #par(leading: 0.6em)[
      #text[#author-info.primary-info \ #author-info.secondary-info \ #author-info.tertiary-info]
    ]
  ]

  body
}

// ============================================================
// Layout Primitives
// ============================================================

// Style: Single-Line Entry (label + inline text + right-aligned content) \
// Use for: memberships, certifications, simple dated items
#let single_line_entry(label, value, rcontent, label-args: (:), rc-args: (:)) = {
  let default-label-args = (weight: "bold")
  let default-rc-args = (size: 0.9em, style: "italic")
  let merged-label-args = default-label-args + label-args
  let merged-rc-args = default-rc-args + rc-args
  [#row2col([#text(..merged-label-args)[#label] #value], text(..merged-rc-args)[#rcontent])]
}

// Style: Multi-Line List
#let multi_line_list(list-type: "list", list-args: (:), enum-args: (:), ..lines) = {
  if list-type == "enum" {
    enum(..enum-args, ..lines)
  } else {
    list(..list-args, ..lines)
  }
}

// Style: Multi-Line Text
#let multi_line_text(..lines) = [
  #for line in lines.pos() {
    line + linebreak()
  }
]

// Style: Two-by-Two Entry Header (two-row header) \
// Use for: education, experience, research, honors
#let r2c2_entry_header(
  top-left: "",
  top-right: "",
  bottom-left: "",
  bottom-right: "",
  top-left-args: (:),
  top-right-args: (:),
  bottom-left-args: (:),
  bottom-right-args: (:),
) = [
    #let default-tl-args = (weight: "bold")
    #let default-tr-args = (size: 0.9em, style: "italic")
    #let default-bl-args = (size: 0.9em, style: "italic")
    #let default-br-args = (size: 0.9em)
    #let merged-tl-args = default-tl-args + top-left-args
    #let merged-tr-args = default-tr-args + top-right-args
    #let merged-bl-args = default-bl-args + bottom-left-args
    #let merged-br-args = default-br-args + bottom-right-args
    
    #row2col([#text(..merged-tl-args)[#top-left]], [#text(..merged-tr-args)[#top-right]]) \ 
    #row2col([#text(..merged-bl-args)[#bottom-left]], [#text(..merged-br-args)[#bottom-right]])
]

// Style: R2C2 Entry with list items (entry header + bullet list) \
#let r2c2_entry(
  entry-header-args: (:),
  list-args: (:),
  enum-args: (:),
  list-items: (),
  list-type: "list",
) = {
  set list(body-indent: 0.3em)
  set enum(body-indent: 0.3em)

  let default-list-args = (spacing: 0.5em)
  let default-enum-args = (spacing: 0.5em)
  let merged-list-args = default-list-args + list-args
  let merged-enum-args = default-enum-args + enum-args

  let entry-header = r2c2_entry_header(..entry-header-args)

  if list-type == "list" {
    list([
      #entry-header 
      #list(..merged-list-args, ..list-items)
    ])
  } else {
    enum([
      #entry-header 
      #enum(..merged-enum-args, ..list-items)
    ])
  }
}

// Style: Personal Info Content \
// Use for: references, contact cards
#let personal_info(name, title, org, email, phone, note) = [
  #multi_line_text(
    text(weight: "bold")[#name],
    if title != none {[#title]},
    if org != none {[#org]},
    if email != none {[Email: #email]},
    if phone != none {[Phone: #phone]},
    if note != none {text(style: "italic")[#note]},
  )
]

// ============================================================
// Layout Templates
// ============================================================

// Style: R2C2 Entry List \
// Use for: experience, projects, awards, leadership, volunteer
#let r2c2_entry_list(
  spacing: 0.8em,
  ..entries,
) = {
  stack(
    spacing: spacing,
    ..entries.pos().map(entry => r2c2_entry(..entry)),
  )
}

// Style: Publication Entry List (auto-numbered by category) \
// entries: array of dicts with keys: \
//   - category: str — category prefix for numbering (e.g., "C", "J", "P") \
//   - value: content — publication text (mutually exclusive with bib-key) \
// spacing: vertical spacing between entries \
// number-style: "descending" (default) — first entry (most recent) gets highest number \
//               "ascending" — first entry gets number 1 \
// label-width: width of the label column (auto = fit widest label) \
#let publication_entry_list(
  entries,
  column-gutter: 1.3em,
  row-gutter: 0.9em,
  number-style: "descending",
  label-width: auto,
) = {
  // Count entries per category
  let cat_counts = (:)
  for entry in entries {
    let cat = entry.category
    let current = if cat in cat_counts { cat_counts.at(cat) } else { 0 }
    cat_counts.insert(cat, current + 1)
  }

  // Build grid children with auto-generated labels
  let children = ()
  let cat_seen = (:)
  for entry in entries {
    let cat = entry.category
    let seen = if cat in cat_seen { cat_seen.at(cat) } else { 0 }
    cat_seen.insert(cat, seen + 1)

    let num = if number-style == "descending" {
      cat_counts.at(cat) - seen
    } else {
      seen + 1
    }

    children.push(text(weight: "bold")[[#cat.#str(num)]])
    children.push(entry.value)
  }

  grid(
    columns: (label-width, 1fr),
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    ..children,
  )
}

// Style: Personal Info List \
// Use for: references, contact cards
#let personal_info_list(items, spacing: 1em, list-type: "enum") = [
  #if list-type == "enum" {
    set enum(spacing: spacing)
    enum(..items.map(item => personal_info(item.name, item.title, item.org, item.email, item.phone, item.note)))
  } else {
    set list(spacing: spacing)
    list(..items.map(item => personal_info(item.name, item.title, item.org, item.email, item.phone, item.note)))
  }
]
