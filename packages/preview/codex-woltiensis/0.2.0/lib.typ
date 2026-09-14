// ================================
// CONFIGURATION
// ================================

#let CONFIG = (
  MARGIN: (
    top: 1.3cm, 
    bottom: 0.6cm, 
    inside: 1cm, 
    outside: 0.5cm
  ),
  
  LAYOUTS: (
    "a6": (height: 14.8cm, width: 10.5cm, space: 1.4cm),
    "a4": (height: 29.7cm, width: 21cm, space: 1.6cm),
  ),
  
  TYPOGRAPHY: (
    CHAPTER: (font: "Noto Serif Display", size: 20pt),
    SONG-TITLE: (font: "Noto Serif Display", size: 14pt),
    GENERAL: (font: "Noto Serif", size: 7pt),
    ATTRIBUTION: (size: 5pt),
    COMMENT: (size: 5pt)
  )
)

#let current-layout = CONFIG.LAYOUTS.at("a6")

// ================================
// UTILITY FUNCTIONS
// ================================

/// Cleans body text by moving articles to the end
/// @param body -> str: The text to clean
/// @return str: Cleaned text with articles moved to parentheses
#let clean-body-text(body) = {
  let articles = (
    ("Le ", " (Le)"),
    ("La ", " (La)"),
    ("Les ", " (Les)"),
    ("Het ", " (Het)"),
    ("De ", " (De)")
  )
  
  for (prefix, suffix) in articles {
    if body.starts-with(prefix) {
      return body.slice(prefix.len()) + suffix
    }
  }
  return body
}

/// Gets the formatted repetition indicator
/// @param n -> int: Number of repetitions
/// @return content: Formatted repetition text
#let get-repetition-indicator(n) = {
  if n == 2 { [(_bis_)] }
  else if n == 3 { [(_ter_)] }
  else if n == 4 { [(_quater_)] }
  else if n > 4 { [(x#n)] }
  else { panic("Positive number ranging from 2 to inf required") }
}

// ================================
// ATTRIBUTION FUNCTIONS
// ================================

/// Creates a generic attribution line
/// @param type -> str: Attribution type
/// @param body -> content: Main attribution text
/// @param info -> content: Optional additional information
/// @return content: Formatted attribution
#let create-attribution(type, body, info: none) = {
  text(size: CONFIG.TYPOGRAPHY.ATTRIBUTION.size)[
    #type: #body
    #if info != none { [(#info)] }
    #linebreak()
  ]
}

/// Creates an air attribution
/// @param body -> content: The air text
/// @param auteur -> content: Optional author information
/// @return content: Formatted air attribution
#let air(body, auteur: none) = {
  create-attribution("Air", body, info: auteur)
}

/// Creates a paroles attribution
/// @param body -> content: The lyrics text
/// @param date -> content: Optional date information
/// @return content: Formatted paroles attribution
#let paroles(body, date: none) = {
  create-attribution("Paroles", body, info: date)
}

// ================================
// CONTENT FORMATTING FUNCTIONS
// ================================

/// Creates a small comment
/// @param body -> content: The comment text
/// @return content: Formatted comment
#let com(body) = text(CONFIG.TYPOGRAPHY.COMMENT.size)[#body]

/// Creates a header with air, paroles, and optional comment
/// @param air -> content: Optional air attribution
/// @param paroles -> content: Optional paroles attribution
/// @param commentaire -> content: Optional comment text
/// @return content: Formatted header
#let header(air: none, paroles: none, commentaire: none) = context {
  if air != none and paroles != none {
    let width = measure([#air #paroles]).at("width")
    if width < current-layout.at("width") {
      columns(2)[#air #colbreak() #paroles]
    } else {
      air
      paroles
    }
    if commentaire != none {
      commentaire + linebreak()
    }
  }
}

/// Formats text for repetitions (bis, ter, etc.)
/// @param n -> int: Number of repetitions (default: 2)
/// @param ..args: Optional content to format
/// @return content: Formatted repetition
#let bis(n: 2, ..args) = {
  let content = if args.pos().len() != 0 { args.pos().at(0) } else { none }
  
  if content == none {
    get-repetition-indicator(n)
  } else {
    context {
      let m = measure(content)
      let l = line(angle: 90deg, length: m.height, stroke: 0.5pt)
      box(grid(
        gutter: 0pt,
        columns: (m.width + 10pt, 0.1fr, 3fr),
        content, 
        l, 
        move(get-repetition-indicator(n), dy: m.height - CONFIG.TYPOGRAPHY.GENERAL.size)
      ))
    }
  }
}

/// Creates a footnote with specific styling
/// @param body -> content: The footnote content
/// @return content: Formatted footnote
#let note(body) = {
  let font = CONFIG.TYPOGRAPHY.GENERAL.font
  let size = CONFIG.TYPOGRAPHY.COMMENT.size
  if body != none {
    footnote[#text(font: font, size: size)[#body]]
  }
}

// ================================
// INDEX AND OUTLINE FUNCTIONS
// ================================

#let letters-viewed = state("letters", ())

/// Creates an alphabetically ordered outline
/// @return content: Formatted outline with alphabetical headers
#let ordered-outline() = context {
  let headings = query(selector(heading.where(level: 2)))
  let sorted-headings = headings.sorted(
    key: heading => {
      if heading.body.has("text") { 
        clean-body-text(heading.body.text) 
      } else { 
        "" 
      }
    }
  )
  
  sorted-headings.map(entry => {
    let body-text = if entry.body.has("text") { 
      entry.body.text 
    } else { 
      panic("Title should have text") 
    }
    
    let cleaned-text = clean-body-text(body-text)
    let first-letter = cleaned-text.first()
    let font = CONFIG.TYPOGRAPHY.CHAPTER.font
    let size = CONFIG.TYPOGRAPHY.SONG-TITLE.size
    
    if entry.numbering != none {
      numbering(entry.numbering, ..counter(heading).at(entry.location()))
    }
    
    [ ]
    context if first-letter not in letters-viewed.get() {
      text(font: font, size: size, first-letter) + linebreak()
      letters-viewed.update(current => current + (first-letter,))
    }
    
    h(8pt) + cleaned-text + " " + box(width: 1fr, repeat[.]) + [ ] + [#entry.location().page()]
  }).join([ \ ])
}

// ================================
// PAGE BACKGROUND FUNCTIONS
// ================================

/// Creates the page background with section indicators
/// @param current-page -> int: Current page number
/// @param total-section -> int: Total number of sections
/// @return content: Page background
#let create-page-background(current-page, total-section) = {
  let section = query(selector(heading.where(level: 1)).before(here())).len()
  let has-l1-heading = query(heading.where(level: 1))
    .any(it => it.location().page() == current-page)
  
  if not has-l1-heading {
    let r-height = current-layout.height / total-section
    let offset = (section - 1) * r-height
    let r = rect(fill: black, width: 0.3cm, height: r-height)
    let side = if calc.odd(current-page) { right } else { left }
    place(side, r, dy: offset)
  }
}

// ================================
// HEADER AND FOOTER FUNCTIONS
// ================================

/// Creates the page header with current song title
/// @return content: Formatted header
#let create-page-header() = context {
  let current-page = here().page()
  let headings = query(selector(heading.where(level: 2)))
  let heading = headings.rev().find(x => x.location().page() <= current-page)
  
  if heading != none {
    let heading-page = heading.location().page()
    if heading-page == current-page {
      set text(
        CONFIG.TYPOGRAPHY.SONG-TITLE.size, 
        weight: "bold", 
        font: CONFIG.TYPOGRAPHY.SONG-TITLE.font
      )
      set align(top)
      v(0.7cm)
      heading.body
    }
  }
}

/// Creates the page footer with page numbers
/// @return content: Formatted footer
#let create-page-footer() = context {
  let current-page = here().page()
  let alignment = if calc.odd(current-page) { right } else { left }
  align(alignment)[#current-page]
}

// ================================
// HEADING STYLES
// ================================

/// Formats refrain headings based on language
/// @param body-content -> str: The heading content
/// @return content: Formatted refrain heading
#let format-refrain-heading(body-content) = {
  let french-options = ("fr", "fr.", "")
  let dutch-options = ("nl", "nl.")
  let all-options = french-options + dutch-options
  
  set align(left)
  set text(CONFIG.TYPOGRAPHY.GENERAL.size, weight: "bold")
  
  if body-content in french-options {
    [_Refrain_]
  } else if body-content in dutch-options {
    [_Refrein_]
  } else if body-content not in all-options {
    [_#body-content _]
  }
  
  if body-content.ends-with(".") {
    v(weak: true, 0.65em)
  }
}

// ================================
// MAIN CODEX FUNCTION
// ================================

/// Main function to create a codex document
/// @param content -> content: The main document content
/// @param title -> str: Optional document title
/// @param subtitle -> str: Optional document subtitle
/// @param author -> str: Optional document author
/// @param lang -> str: Document language (default: "fr")
/// @param total-section -> int: Total number of sections (default: 10)
/// @return content: Complete formatted document
#let codex(
  content,
  title: none,
  subtitle: none,
  author: none,
  lang: "fr",
  total-section: 10,
) = {
  set text(lang: lang)
  
  // Set default text style
  show: text.with(
    font: CONFIG.TYPOGRAPHY.GENERAL.font, 
    size: CONFIG.TYPOGRAPHY.GENERAL.size
  )
  
  // Setup page format
  set page(
    paper: "a6",
    margin: CONFIG.MARGIN,
    number-align: left,
    background: context {
      let current-page = here().page()
      create-page-background(current-page, total-section)
    },
    header: create-page-header(),
    footer: create-page-footer()
  )
  
  // Heading styles
  show heading.where(level: 1): it => {
    set page(margin: CONFIG.MARGIN, numbering: none, footer: none, header: none)
    set align(horizon + center)
    text(
      CONFIG.TYPOGRAPHY.CHAPTER.size, 
      weight: "bold", 
      font: CONFIG.TYPOGRAPHY.CHAPTER.font
    )[#it]
  }
  
  show heading.where(level: 2): pagebreak(weak: true)
  
  show heading.where(level: 3): it => {
    let body-content = if "text" in it.body.fields() { it.body.text } else { "" }
    format-refrain-heading(body-content)
  }
  
  // Configure outline settings
  set outline(depth: 2, indent: auto)
  show outline: set heading(level: 2)
  
  // Main content
  content
  
  // Index section
  heading(level: 1)[INDEX]
  set page(margin: (top: 0.5cm, inside: 1cm, outside: 0.5cm))
  ordered-outline()
}