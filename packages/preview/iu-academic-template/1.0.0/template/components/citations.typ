/*
 * ============================================================
 * BEAVERBYTES CITATIONS
 * ============================================================
 *
 * Citation helpers for Citrus 0.2.1.
 *
 * Normal citations use @key or Typst's built-in #cite.
 * Multiple unrelated citations use Citrus #multicite.
 *
 * This module intentionally does not define a function
 * named "cite" so that the native Typst API stays intact.
 *
 * Public functions:
 * - narrative-cite
 * - secondary-cite
 * - cite-same-author
 * - block-quote
 *
 * All citation helpers except block-quote expect the
 * CSL-JSON reference array via their `references` argument.
 *
 * Language is taken from the active document text settings,
 * or supplied explicitly via the `language` parameter.
 * ============================================================
 */

#import "../integrations/citrus.typ": (
  get-cited-entries,
  nocite,
)


// ------------------------------------------------------------
// Language and terminology
// ------------------------------------------------------------

// Resolve the effective document language.
// Call this helper only inside a context expression.
#let _language(language) = {
  let active = if language == none { text.lang } else { language }

  assert(
    active in ("de", "en"),
    message: "Unsupported citation language. Use 'de' or 'en'.",
  )

  active
}

#let _terms = (
  de: (
    conjunction: "und",
    page: "S.",
    secondary: "zitiert nach",
  ),
  en: (
    conjunction: "and",
    page: "p.",
    secondary: "as cited in",
  ),
)


// ------------------------------------------------------------
// Reference and name helpers
// ------------------------------------------------------------

#let _reference(key, references) = {
  assert(
    type(references) == array,
    message: "Expected a CSL-JSON reference array.",
  )

  assert(
    type(key) == label,
    message: "Citation key must be a Typst label.",
  )

  let id = str(key)
  let entry = references.find(
    item => item.at("id", default: "") == id,
  )

  assert(
    entry != none,
    message: "Unknown citation key: " + id,
  )

  entry
}

#let _names(entry) = {
  let authors = entry.at("author", default: ())
  if authors.len() > 0 { return authors }

  // Films without authors are attributed to their directors.
  if entry.at("type", default: "") == "motion_picture" {
    let directors = entry.at("director", default: ())
    if directors.len() > 0 { return directors }
  }

  let editors = entry.at("editor", default: ())
  if editors.len() > 0 { return editors }

  let title = entry.at("title", default: "")

  assert(
    title != "",
    message: "Citation has neither authors, editors, nor a title.",
  )

  ((literal: title),)
}

#let _published-year(entry) = {
  let issued = entry.at("issued", default: none)
  if issued == none { return none }

  let parts = issued.at("date-parts", default: ())

  if parts.len() == 0 or parts.first().len() == 0 {
    return none
  }

  parts.first().first()
}

#let _given-initials(given) = {
  if given == none or given == "" { return "" }

  given
    .split(" ")
    .filter(piece => piece != "")
    .map(piece => {
      piece.split("-").map(part => {
        if part == "" {
          ""
        } else if part.ends-with(".") {
          part
        } else {
          part.at(0) + "."
        }
      }).join("-")
    })
    .join(" ")
}

#let _cited-sources(references, cited-entries) = {
  cited-entries.map(cited =>
    references.find(
      entry => entry.at("id", default: "") == str(cited.key),
    )
  ).filter(entry => entry != none)
}

#let _needs-initial(person, entry, cited-sources) = {
  let family = person.at("family", default: none)
  let given = person.at("given", default: none)

  if family == none or given == none or given == "" {
    return false
  }

  cited-sources.any(other => (
    other.at("id", default: "") != entry.at("id", default: "") and
    _names(other).any(name => (
      name.at("family", default: none) == family and
      name.at("given", default: none) != given
    ))
  ))
}

#let _display-name(person, entry, cited-sources) = {
  let family = person.at("family", default: none)
  let literal = person.at("literal", default: none)

  if family != none and family != "" {
    if _needs-initial(person, entry, cited-sources) {
      _given-initials(
        person.at("given", default: ""),
      ) + " " + family
    } else {
      family
    }
  } else if literal != none and literal != "" {
    literal
  } else {
    panic("Unsupported CSL-JSON author name.")
  }
}


// Expand ambiguous 3+-author groups with the same first two
// authors and publication year, up to four displayed names.
#let _visible-name-count(entry, cited-sources) = {
  let names = _names(entry)

  if names.len() <= 2 {
    return names.len()
  }

  let competitors = cited-sources.filter(other => {
    let other-names = _names(other)

    (
      other.at("id", default: "") != entry.at("id", default: "") and
      _published-year(other) == _published-year(entry) and
      other-names.len() > 2 and
      other-names != names and
      other-names.slice(0, 2) == names.slice(0, 2)
    )
  })

  if competitors.len() == 0 {
    return 1
  }

  let count = 3

  for other in competitors {
    let other-names = _names(other)
    let limit = calc.min(
      4,
      names.len(),
      other-names.len(),
    )

    let common = 0

    while (
      common < limit and
      names.at(common) == other-names.at(common)
    ) {
      common += 1
    }

    count = calc.max(
      count,
      calc.min(4, common + 1),
    )
  }

  count
}

#let _author-text(
  entry,
  cited-sources,
  language,
  narrative: false,
) = {
  let names = _names(entry)
  let count = _visible-name-count(entry, cited-sources)

  let selected = names.slice(0, count).map(name =>
    _display-name(name, entry, cited-sources)
  )

  if names.len() == 1 {
    selected.first()
  } else if names.len() == 2 {
    let separator = if narrative {
      " " + _terms.at(language).conjunction + " "
    } else {
      " & "
    }

    selected.join(separator)
  } else if count == 1 {
    selected.first() + " et al."
  } else {
    selected.join(", ") + (
      if count < names.len() {
        " et al."
      } else {
        ""
      }
    )
  }
}

#let _year-suffix(key, cited-entries) = {
  let cited = cited-entries.find(
    item => str(item.key) == str(key),
  )

  if cited == none { return "" }

  let suffix = cited.at("year-suffix", default: none)

  if suffix == none { return "" }

  if type(suffix) == int {
    return numbering("a", suffix + 1)
  }

  str(suffix)
}


// Register sources with Citrus, including undated works.
#let _cited-year(key, entry, cited-entries) = {
  let year-citation = std.cite(key, form: "year")

  if _published-year(entry) != none {
    return year-citation
  }

  let suffix = _year-suffix(key, cited-entries)

  let hidden-citation = box(
    width: 0pt,
    height: 0pt,
    clip: true,
  )[
    #year-citation
  ]

  if suffix == "" {
    [#hidden-citation#("n.d.")]
  } else {
    [#hidden-citation#("n.d.-")#suffix]
  }
}

#let _location(
  language,
  page: none,
  location: none,
) = {
  assert(
    page == none or location == none,
    message: "Use either page or location, not both.",
  )


  if page != none {
    // Use the APA plural locator for numeric page ranges or lists.
    let multiple-pages = (
      type(page) == str
      and page.contains(regex("[0-9]+\\s*[-–—,]\\s*[0-9]+"))
    )

    let prefix = if language == "en" and multiple-pages {
      "pp."
    } else {
      _terms.at(language).page
    }

    [, #prefix #page]
  } else if location != none {
    [, #location]
  } else {
    []
  }
}


// ============================================================
// NARRATIVE CITATIONS
// ============================================================

/// Cite an author in running text with an optional locator.
/// Register the citation outside contextual metadata queries.
#let narrative-cite(
  key,
  references: none,
  page: none,
  location: none,
  language: none,
) = {
  let entry = _reference(key, references)

  // Register the actual citation outside contextual queries.
  let year = std.cite(key, form: "year")

  // Resolve the author using Citrus disambiguation data.
  let author = context {
    let lang = _language(language)

    let cited = get-cited-entries()
    let sources = _cited-sources(references, cited)

    _author-text(
      entry,
      sources,
      lang,
      narrative: true,
    )
  }

  // Resolve the localized locator independently.
  let locator-text = context {
    let lang = _language(language)

    _location(
      lang,
      page: page,
      location: location,
    )
  }

  [#author (#year#locator-text)]
}


// ============================================================
// SECONDARY CITATIONS
// ============================================================

/// Cite a work consulted through a secondary source.
/// Only the consulted secondary source is registered.
#let secondary-cite(
  original-author,
  original-year,
  secondary-key,
  references: none,
  page: none,
  location: none,
  narrative: false,
  language: none,
) = {
  let secondary = _reference(secondary-key, references)

  // Register the secondary source outside contextual queries.
  let year-citation = std.cite(
    secondary-key,
    form: "year",
  )

  // Preserve the handling of undated sources.
  let secondary-year = if _published-year(secondary) != none {
    year-citation
  } else {
    let hidden-registration = box(
      width: 0pt,
      height: 0pt,
      clip: true,
    )[
      #year-citation
    ]

    let undated-year = context {
      let suffix = _year-suffix(
        secondary-key,
        get-cited-entries(),
      )

      if suffix == "" {
        [n.d.]
      } else {
        [n.d.-#suffix]
      }
    }

    [#hidden-registration#undated-year]
  }

  // Resolve author disambiguation and terminology.
  let secondary-description = context {
    let lang = _language(language)
    let cited = get-cited-entries()
    let sources = _cited-sources(references, cited)

    let author = _author-text(
      secondary,
      sources,
      lang,
    )

    let relation = _terms.at(lang).secondary

    [#relation #author]
  }

  // Resolve the localized locator.
  let locator-text = context {
    _location(
      _language(language),
      page: page,
      location: location,
    )
  }

  if narrative {
    [
      #original-author (#original-year, #secondary-description, #secondary-year#locator-text)
    ]
  } else {
    [
      (#original-author, #original-year, #secondary-description, #secondary-year#locator-text)
    ]
  }
}

// ============================================================
// MULTIPLE WORKS BY THE SAME AUTHORS
// ============================================================


/// Collapse works by identical authors into one citation.
/// Register all sources before querying Citrus metadata.
#let cite-same-author(
  keys,
  references: none,
  language: none,
) = {
  assert(
    type(references) == array,
    message: "Expected a CSL-JSON reference array.",
  )

  assert(
    type(keys) == array and keys.len() > 0,
    message: "Expected a non-empty array of labels.",
  )

  let records = keys.dedup().map(key => (
    key: key,
    entry: _reference(key, references),
  ))

  let names = _names(records.first().entry)

  assert(
    records.all(record =>
      _names(record.entry) == names
    ),
    message: "All cited works must have identical authors.",
  )

  let ordered = records.sorted(key: record => {
    let year = _published-year(record.entry)

    (
      if year == none { -1 } else { year },
      lower(record.entry.at("title", default: "")),
    )
  })

  // Register all bibliography entries before evaluating
  // contextual citation metadata.
  //
  // This prevents the bibliography query from depending
  // on citations that are generated by the query itself.
  let registrations = ordered.map(record =>
    nocite(str(record.key))
  ).join([])

  [
    #registrations

    #context {
      let lang = _language(language)

      let cited = get-cited-entries()
      let sources = _cited-sources(references, cited)

      let author = _author-text(
        records.first().entry,
        sources,
        lang,
      )

      let years = ordered.map(record => {
        let cited-entry = cited.find(item =>
          str(item.key) == str(record.key)
        )

        assert(
          cited-entry != none,
          message: "Citation was not registered: "
            + str(record.key),
        )

        let published-year = _published-year(record.entry)

        let year = if published-year == none {
          "n.d."
        } else {
          str(published-year)
        }

        let suffix = _year-suffix(record.key, cited)

        // Link to the corresponding Citrus bibliography entry.
        link(
          cited-entry.ref-label,
          [#year#suffix],
        )
      }).join([, ])

      [(#author, #years)]
    }
  ]
}



// ============================================================
// BLOCK QUOTATIONS
// ============================================================

/// Apply the IU's 1.27 cm left indent to a long quotation.
/// Include the regular citation inside the supplied body.
#let block-quote(body) = {
  block(inset: (left: 1.27cm))[#body]
}
