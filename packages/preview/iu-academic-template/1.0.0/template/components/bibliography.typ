/*
 * ============================================================
 * BIBLIOGRAPHY COMPONENT
 * ============================================================
 *
 * Renders the Citrus bibliography with IU-compliant typography.
 *
 * - Unnumbered first-level heading included in the outline
 * - Left-aligned references without list markers
 * - Exact 1.27 cm hanging indent for continuation lines
 * - CSL formatting and reference sorting remain with Citrus
 *
 * Citrus must be initialized in the document before this
 * component is used. The citation engine is supplied by lib.typ.
 * ============================================================
 */


/*
 * ============================================================
 * BIBLIOGRAPHY SORTING
 * ============================================================
 *
 * Normalizes accented characters for alphabetical sorting.
 * Original reference names remain unchanged.
 */

// Normalize names for sorting.
#let bibliography-sort-normalize(value) = {
  let result = lower(value).normalize(form: "nfd")

  result = result.replace(
    regex("[\u{0300}-\u{036f}]"),
    "",
  )

  result.replace("ß", "ss")
}

// Generate a sort key from authors or editors.


#let bibliography-sort-key(entry) = {
  let fields = entry.fields
  let parsed = entry.at("parsed-names", default: (:))

  let authors = parsed.at("author", default: ())
  let editors = parsed.at("editor", default: ())
  let directors = parsed.at("director", default: ())

  let names = if authors.len() > 0 {
    authors
  } else if (
    fields.at("csl-type", default: "") == "motion_picture"
    and directors.len() > 0
  ) {
    directors
  } else {
    editors
  }

  let sort-text = if names.len() > 0 {
    names.map(person => {
      let literal = person.at("literal", default: "")

      if literal != "" {
        literal
      } else {
        let family = person.at("family", default: "")
        let given = person.at("given", default: "")

        // Include name particles in alphabetical sorting.
        let particle = person.at(
          "non-dropping-particle",
          default: "",
        )

        if particle == "" {
          particle = person.at(
            "dropping-particle",
            default: "",
          )
        }

        if particle == "" {
          particle = person.at(
            "prefix",
            default: "",
          )
        }

        // Avoid duplicating particles already in family.
        let sort-family = if (
          particle != "" and
          not lower(family).starts-with(lower(particle))
        ) {
          (particle, family).join(" ")
        } else {
          family
        }

        (sort-family, given).join(", ")
      }
    }).join(" / ")
  } else {
    fields.at("title", default: "")
  }

  bibliography-sort-normalize(sort-text)
}



/*
 * ============================================================
 * RENDER BIBLIOGRAPHY
 * ============================================================
 *
 * Parameters:
 * - settings: Validated project bibliography settings dictionary.
 *             Supported keys: enabled, title.
 * - language: Language used for the default heading.
 * - bibliography-engine: Citrus csl-bibliography function,
 *                        provided by template/lib.typ.
 *
 * Examples:
 *
 * Called by the document-bound API in template/lib.typ.
 * ============================================================
 */

#let render-bibliography(
  settings: none,
  language: "de",
  bibliography-engine: none,
) = {
  // The citation renderer is a runtime dependency, not project configuration.
  assert(
    type(bibliography-engine) == function,
    message: "A Citrus bibliography function is required.",
  )

  // Project settings are validated by make-document() in template/lib.typ.
  let enabled = settings.at("enabled")

  if enabled {
    let heading-title = settings.at(
      "title",
      default: if language == "de" {
        [Literaturverzeichnis]
      } else {
        [References]
      },
    )

    // Use the document's normal level-one heading formatting.
    // Set title to none to omit the heading, e.g. in regression tests.
    if heading-title != none {
      heading(
        level: 1,
        numbering: none,
        outlined: true,
      )[#heading-title]
    }

    // Keep Citrus-generated reference text and link labels intact.
    // Override only the paragraph formatting of the reference list.

    bibliography-engine(
      title: none,
      full-control: entries => {
        set par(
          justify: false,
          first-line-indent: 0pt,
          hanging-indent: 1.27cm,
        )

        let sorted-entries = entries.sorted(
          key: bibliography-sort-key,
        )

        for entry in sorted-entries [
          // Protect hashtags in social-media references.
          #if entry.fields.at("csl-type", default: "") == "post" [
            #show regex("#[\\p{L}\\p{N}_]+"): hashtag => box(hashtag)
            #entry.labeled-rendered
          ] else [
            #entry.labeled-rendered
          ]
          #parbreak()
        ]
      },
    )
  }
}
