/// Cover (Title Page) module for APA 7th Edition.
///
/// Implements Student Paper and Professional Paper title pages adhering to
/// Sections 2.3 through 2.8 of the APA Publication Manual (7th ed.) and
/// ensuring strict conformance with Typst's Universal Access / PDF/UA-1 rules.

/// Formats a datetime object into standard APA date string according to language.
#let format-apa-date(date, lang: "en") = {
  if type(date) == datetime {
    if lang == "es" {
      date.display("[day] de [month repr:long] de [year]")
    } else {
      date.display("[month repr:long] [day], [year]")
    }
  } else if date != none and date != auto {
    date
  } else {
    none
  }
}

/// Helper to join author names according to APA 7 rules for English and Spanish.
/// - In English: Uses serial (Oxford) comma before 'and' for 3+ authors: "A, B, and C".
/// - In Spanish: RAE / APA Spanish strictly forbids the Oxford comma: "A, B y C".
#let join-author-names(names, lang: "en") = {
  let count = names.len()
  if count == 0 {
    none
  } else if count == 1 {
    names.at(0)
  } else if count == 2 {
    let conj = if lang == "es" { [ y ] } else { [ and ] }
    [#names.at(0)#conj#names.at(1)]
  } else {
    let all-but-last = names.slice(0, count - 1).join(", ")
    if lang == "es" {
      [#all-but-last y #names.last()]
    } else {
      [#all-but-last, and #names.last()]
    }
  }
}

/// Renders the author byline and affiliations according to APA 7 rules.
#let render-authors(authors, lang: "en") = {
  if type(authors) == str or type(authors) == content {
    return authors
  }
  if type(authors) != array or authors.len() == 0 {
    return none
  }

  // Check if authors have individual affiliations
  let has-dict = authors.any(a => type(a) == dictionary)
  if not has-dict {
    // Array of string names
    join-author-names(authors, lang: lang)
  } else {
    // Array of dictionaries: (name: "...", affiliation: "...")
    let entries = ()
    for author in authors {
      if type(author) == dictionary {
        let name = author.at("name", default: "")
        let affil = author.at("affiliation", default: none)
        entries.push((name: name, affiliation: affil))
      } else {
        entries.push((name: str(author), affiliation: none))
      }
    }

    // Check if all affiliations are identical
    let first-affil = entries.at(0).affiliation
    let all-same-affil = entries.all(e => e.affiliation == first-affil)

    if all-same-affil and first-affil != none {
      let names = entries.map(e => e.name)
      let byline = join-author-names(names, lang: lang)
      [#byline \ #first-affil]
    } else {
      // Different affiliations: each author followed by their affiliation
      let blocks = ()
      for entry in entries {
        if entry.affiliation != none {
          blocks.push([#entry.name \ #entry.affiliation])
        } else {
          blocks.push([#entry.name])
        }
      }
      blocks.join([\ ])
    }
  }
}

/// Renders an APA 7 title page (Student or Professional).
///
/// Parameters:
/// - title: Title of the paper (string or content).
/// - authors: Author list (array of strings or dicts with 'name' and 'affiliation').
/// - paper-type: "student" | "professional" (default: "student").
/// - course: Course name and number (student papers).
/// - instructor: Instructor name with honorifics (student papers).
/// - due-date: Assignment due date (datetime or string).
/// - author-note: Author Note content (professional papers).
/// - lang: ISO 639-1 language code (default: "en").
#let render-cover(
  paper-title: [Untitled Document],
  authors: (),
  paper-type: "student",
  course: none,
  instructor: none,
  due-date: none,
  author-note: none,
  lang: "en",
) = {
  // APA 7 Section 2.4: Title is bold, centered, placed 3-4 double-spaced lines down.
  // Using native Typst #title for semantic PDF/UA-1 tagging.
  show title: set text(weight: "bold")

  // Ensure title page elements are centered with no first-line indent
  set par(first-line-indent: 0pt, justify: false)

  align(center)[
    #v(3em)
    #title[#paper-title]
    #v(1em)

    #let author-block = render-authors(authors, lang: lang)
    #if author-block != none [
      #author-block
    ]

    #if paper-type == "student" [
      #if course != none [
        \ #course
      ]
      #if instructor != none [
        \ #instructor
      ]
      #let formatted-date = format-apa-date(due-date, lang: lang)
      #if formatted-date != none [
        \ #formatted-date
      ]
    ]
  ]

  // Professional Paper: Author Note in the lower half of the title page
  if paper-type == "professional" and author-note != none {
    v(1fr)

    align(center)[
      #strong(if lang == "es" [Nota del Autor] else [Author Note])
    ]

    // Author Note paragraphs use standard 0.5-inch indent
    block[
      #set par(first-line-indent: 0.5in)
      #author-note
    ]
  }

  pagebreak()
}
