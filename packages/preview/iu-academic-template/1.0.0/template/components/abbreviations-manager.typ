/*
 * ============================================================
 * ABBREVIATIONS COMPONENT
 * ============================================================
 *
 * Provides:
 * - Central abbreviation definitions
 * - Consistent abbreviation usage
 * - Optional full form in the main text
 * - Automatic tracking of used abbreviations
 * - Alphabetically sorted abbreviation list
 *
 * Only abbreviations used through use-abbreviation()
 * appear in the abbreviation list.
 *
 * Common abbreviations should not be registered.
 *
 * Page breaks remain under author control.
 * ============================================================
 */



/*
 * ============================================================
 * USE ABBREVIATION
 * ============================================================
 *
 * Automatically expands an abbreviation on first use.
 *
 * First use:
 * Application Programming Interface (API)
 *
 * Subsequent uses:
 * API
 *
 * The optional "full" parameter supports manual overrides:
 * - "auto": Automatic first-use expansion
 * - true: Always show the full form
 * - false: Always show the short form
 * ============================================================
 */

#let use-abbreviation(
  key,
  definitions,
  full: "auto",
) = {

  // Validate the abbreviation key.
  assert(
    key in definitions,
    message: "Unknown abbreviation: " + key,
  )

  // Validate the display mode.
  assert(
    full == "auto" or full == true or full == false,
    message: "Invalid abbreviation display mode.",
  )

  // Retrieve the abbreviation definition.
  let entry = definitions.at(key)

  // Definition structure is validated by the document factory.
  let short-form = entry.short
  let long-form = entry.long

  /*
   * ----------------------------------------------------------
   * FIRST-USE TRACKING
   * ----------------------------------------------------------
   *
   * Each abbreviation has its own state.
   *
   * The state changes only after the abbreviation
   * has been displayed.
   */

  let usage-state = state(
    "iu-abbreviation-used-" + key,
    false,
  )

  /*
   * ----------------------------------------------------------
   * DISPLAY CONTENT
   * ----------------------------------------------------------
   */

  let rendered = if full == "auto" {

    context {
      if usage-state.get() {
        [#short-form]
      } else {
        [#long-form (#short-form)]
      }
    }

  } else if full == true {

    [#long-form (#short-form)]

  } else {

    [#short-form]

  }

  /*
   * ----------------------------------------------------------
   * REGISTER USAGE
   * ----------------------------------------------------------
   *
   * Metadata is used to generate the abbreviation list.
   *
   * State is updated after rendering so the next
   * occurrence uses the short form.
   */

  [
    #metadata((
      category: "iu-abbreviation-use",
      key: key,
    ))
    #rendered
    #usage-state.update(true)
  ]
}



/*
 * ============================================================
 * COLLECT USED ABBREVIATIONS
 * ============================================================
 *
 * Collects abbreviation usage markers and returns
 * unique abbreviation identifiers.
 *
 * Must be called within a Typst context.
 */

#let used-abbreviation-keys() = {

  // Retrieve document metadata.
  let markers = query(metadata)

  // Keep only abbreviation usage markers.
  let usages = markers.filter(item => {
    let value = item.value

    // Ignore metadata that is not a dictionary.
    if type(value) != dictionary {
      false
    } else {
      // Check whether this is an abbreviation marker.
      value.at(
        "category",
        default: none,
      ) == "iu-abbreviation-use"
    }
  })

  // Extract abbreviation identifiers.
  let keys = usages.map(
    item => item.value.key,
  )

  // Remove duplicate identifiers.
  keys.dedup()
}



/*
 * ============================================================
 * RENDER LIST OF ABBREVIATIONS
 * ============================================================
 *
 * Parameters:
 * - definitions: Abbreviation dictionary.
 * - settings: Abbreviation list configuration.
 * - language: Document language.
 *
 * Features:
 * - Automatically excludes unused definitions.
 * - Sorts entries by their displayed short form.
 * - Uses a two-column layout without table borders.
 * - Adds an unnumbered heading to the table of contents.
 * - Does not display an empty list.
 */

#let render-list-of-abbreviations(
  definitions,
  settings,
  language: "de",
) = context {

  /*
   * ----------------------------------------------------------
   * CONFIGURATION
   * ----------------------------------------------------------
   */

  // This setting is validated by the document factory.
  let enabled = settings.at("enabled")


  /*
   * ----------------------------------------------------------
   * USED ABBREVIATIONS
   * ----------------------------------------------------------
   */

  let used-keys = used-abbreviation-keys()

  // Include only defined and used abbreviations.
  let valid-keys = used-keys.filter(
    key => key in definitions,
  )

  // Sort alphabetically by the displayed abbreviation.
  let sorted-keys = valid-keys.sorted(
    key: key => lower(definitions.at(key).short),
  )


  /*
   * ----------------------------------------------------------
   * LOCALIZED HEADING
   * ----------------------------------------------------------
   */

  let heading-title = if language == "de" {
    [Abkürzungsverzeichnis]
  } else {
    [List of Abbreviations]
  }


  /*
   * ----------------------------------------------------------
   * RENDER ABBREVIATION LIST
   * ----------------------------------------------------------
   */

  if enabled and sorted-keys.len() > 0 [

    // Add an unnumbered entry to the table of contents.
    #heading(
      level: 1,
      numbering: none,
      outlined: true,
    )[
      #heading-title
    ]

    // Use left-aligned text without paragraph indentation.
    #set par(
      justify: false,
      first-line-indent: 0pt,
      spacing: 0pt,
    )

    // Build the two-column content.
    #{
      let cells = ()

      for key in sorted-keys {
        let entry = definitions.at(key)

        cells.push([#(entry.short)])
        cells.push([#(entry.long)])
      }

      grid(
        columns: (3cm, 1fr),
        column-gutter: 0.5cm,
        row-gutter: 6pt,
        align: left,
        ..cells,
      )
    }

  ]
}