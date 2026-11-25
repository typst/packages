/*
 * ============================================================
 * TABLE OF CONTENTS COMPONENT
 * ============================================================
 *
 * Generates the document's table of contents.
 *
 * Features:
 * - Automatic heading collection
 * - Configurable heading depth
 * - Hierarchical indentation
 * - Bold first-level entries
 * - Dotted leaders and page numbers
 * - Clickable entries
 * - Localized title
 *
 * Page numbering and page breaks are managed separately
 * in the main document.
 * ============================================================
 */


/*
 * ------------------------------------------------------------
 * TABLE OF CONTENTS FUNCTION
 * ------------------------------------------------------------
 *
 * Parameters:
 * - settings: Table of contents configuration dictionary.
 * - language: Document language ("de" or "en").
 *
 * Usage:
 * #render-table-of-contents(
 *   config.at("table-of-contents"),
 *   language: config.language,
 * )
 */

#let render-table-of-contents(
  settings,
  language: "de",
) = {

  /*
   * ----------------------------------------------------------
   * CONFIGURATION
   * ----------------------------------------------------------
   *
   * Settings are validated centrally in template/lib.typ.
   */

  let enabled = settings.at("enabled")
  let depth = settings.at("depth")


  /*
   * ----------------------------------------------------------
   * LOCALIZED TITLE
   * ----------------------------------------------------------
   */

  let title = if language == "de" {
    [Inhaltsverzeichnis]
  } else {
    [Table of Contents]
  }


  /*
   * ----------------------------------------------------------
   * TABLE OF CONTENTS LAYOUT
   * ----------------------------------------------------------
   *
   * Only render the table of contents when enabled.
   *
   * The default outline formatting provides:
   * - Heading numbers
   * - Hierarchical indentation
   * - Dotted leaders
   * - Page numbers
   * - Clickable links
   */

  if enabled [

    /*
     * --------------------------------------------------------
     * ENTRY SPACING
     * --------------------------------------------------------
     *
     * Apply consistent spacing below every entry.
     */

    #show outline.entry: set block(
      below: 6pt,
    )


    /*
     * --------------------------------------------------------
     * FIRST-LEVEL ENTRIES
     * --------------------------------------------------------
     *
     * Display top-level headings in bold.
     *
     * Nested entries retain the default font weight.
     */

    #show outline.entry.where(level: 1): set text(
      weight: "bold",
    )


    /*
     * --------------------------------------------------------
     * GENERATE OUTLINE
     * --------------------------------------------------------
     *
     * Collect all outlined headings up to the configured
     * maximum depth.
     */

    #outline(
      title: title,
      target: heading,
      depth: depth,
      indent: auto,
    )
  ]
}
