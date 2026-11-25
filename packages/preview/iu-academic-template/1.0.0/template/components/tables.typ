/*
 * ============================================================
 * TABLES COMPONENT
 * ============================================================
 *
 * Provides reusable tables and an automatic list of tables.
 *
 * Main text:
 * - Automatic table numbering
 * - Caption above the table
 * - Optional note and source below
 * - Inclusion in the list of tables
 *
 * Appendix:
 * - Configurable numbering: none, per-appendix, or continuous
 * - Optional unnumbered title in "none" mode
 * - Optional note and source below
 * - Numbered appendix tables appear in the list of tables
 *
 * The table determines the width of the entire component.
 * Titles, notes, and sources align with its left edge.
 * ============================================================
 */

#import "../core/base.typ": (
  caption-font-size,
  caption-leading,
  note-source-gap,
)

#import "appendix.typ": appendix-mode, appendix-counter


/*
 * ============================================================
 * INSERT TABLE
 * ============================================================
 *
 * Parameters:
 * - table-content: Native Typst table.
 * - title: Table title; may be none in the appendix.
 * - source: Optional source information.
 * - note: Optional explanatory note.
 * - label: Optional cross-reference label.
 * - border-style: "all" for a full grid or "horizontal" for interior row separators.
 * - language: Document language.
 * - show-own-work: Display the automatic source for own tables.
 * - appendix-numbering-mode: Numbering of tables inside appendices.
 * - appendix-numbering-pattern: Numbering pattern of the appendix hierarchy.
 *
 * Appendix mode is detected automatically.
 * ============================================================
 */

#let insert-table(
  table-content,
  title,
  source: none,
  note: none,
  label: none,
  border-style: "all",
  language: "de",
  show-own-work: true,
  appendix-numbering-mode: "none",
  appendix-numbering-pattern: none,
) = {

  /*
   * ----------------------------------------------------------
   * TABLE BORDER STYLE
   * ----------------------------------------------------------
   */

  // Validate the requested border style.
  if border-style not in ("all", "horizontal") {
    panic("Invalid table border-style: " + repr(border-style) + ". Expected \"all\" or \"horizontal\".")
  }

  // Apply the selected border style to this table.
  // Horizontal mode draws only interior row separators.
  let styled-table = if border-style == "horizontal" {
    [
      #set table(stroke: (x, y) => (
        top: if y > 0 { 0.5pt + black } else { none },
        bottom: none,
        left: none,
        right: none,
      ))
      #table-content
    ]
  } else {
    table-content
  }

  /*
   * ----------------------------------------------------------
   * LOCALIZED CONTENT
   * ----------------------------------------------------------
   */

  let table-prefix = if language == "de" {
    [Tab.]
  } else {
    [Table]
  }

  let source-label = if language == "de" {
    "Quelle"
  } else {
    "Source"
  }

  let show-source = source != none or show-own-work

  let source-content = if source != none {
    source
  } else if language == "de" {
    [Eigene Darstellung.]
  } else {
    [Author's own work.]
  }


  /*
   * ----------------------------------------------------------
   * DYNAMIC TABLE LAYOUT
   * ----------------------------------------------------------
   *
   * The current appendix state is read in layout context.
   *
   * The table is measured within the available text width.
   * Its actual layout width determines the alignment of
   * the title, note, and source.
   */


    block(
      width: 100%,
      above: 18pt,
      below: 18pt,
    )[
      #layout(size => {


      let is-appendix = appendix-mode.get()

      let available-width = size.width

      // Measure the actual table width.
      let table-width = measure(
        styled-table,
        width: available-width,
      ).width

      // Calculate the inset needed to center the table.
      let side-inset = if table-width < available-width {
        (available-width - table-width) / 2
      } else {
        0pt
      }


    /*
     * --------------------------------------------------------
     * SHARED TABLE BODY
     * --------------------------------------------------------
     *
     * Main-text and appendix tables use the same layout.
     *
     * The table is centered.
     * Notes and sources align with its left edge.
     */

    let table-body = block(
      width: available-width,
    )[

      // Render the table at its configured width.
      #align(center)[
        #styled-table
      ]

      // Show the note area only when it has content.
      #if note != none or show-source [
        #v(6pt)

        // Align additional information with the table.
        #pad(
          left: side-inset,
          right: side-inset,
        )[
          #set align(left)

          #set par(
            justify: false,
            leading: caption-leading,
            first-line-indent: 0pt,
            spacing: 0pt,
          )

          // Optional explanatory note.
          #if note != none [
            #text(size: caption-font-size)[
              #note
            ]
          ]

          // Separate note and source only when both exist.
          #if note != none and show-source [
            #v(note-source-gap)
          ]

          // Explicit sources always appear. Own-work notes are optional.
          #if show-source [
            #text(size: caption-font-size)[
              #(source-label): #source-content
            ]
          ]
        ]
      ]

    ]


    /*
     * --------------------------------------------------------
     * APPENDIX TABLE BODY
     * --------------------------------------------------------
     *
     * Appendix tables may display a title without a
     * table number or prefix.
     *
     * Passing none as the title hides it completely.
     */

    let appendix-body = block(
      width: available-width,
    )[

      // Optional unnumbered title.
      #if title != none [

        #pad(
          left: side-inset,
          right: side-inset,
        )[
          #set par(
            leading: caption-leading,
            spacing: 0pt,
          )
          #align(left)[
            #text(size: caption-font-size)[
              #title
            ]
          ]
        ]

        #v(6pt)

      ]

      // Shared table, note, and source.
      #table-body

    ]


    /*
     * --------------------------------------------------------
     * SELECT TABLE TYPE AND NUMBERING
     * --------------------------------------------------------
     *
     * "none": Keep the existing unnumbered appendix appearance.
     * "continuous": Use the main-text table figure counter.
     * "per-appendix": Use a separate counter, reset at each
     * main appendix by appendix.typ.
     */

    let rendered-table = if is-appendix and appendix-numbering-mode == "none" {
      figure(
        appendix-body,
        kind: "iu-appendix-table",
        supplement: none,
        numbering: none,
        caption: none,
        outlined: false,
      )
    } else {
      // Keep numbering even when the title is omitted.
      let caption-body = if title == none { [] } else { title }
      let caption-separator = if title == none { [] } else { h(0.35em) }

      let per-appendix = is-appendix and appendix-numbering-mode == "per-appendix"

      // Use the main appendix number as the prefix of a
      // dedicated per-appendix table counter.
      let table-numbering = if per-appendix {
        n => numbering(
          appendix-numbering-pattern,
          appendix-counter.get().first(),
          n,
        )
      } else {
        "1"
      }

      figure(
        table-body,
        kind: if per-appendix { "iu-appendix-table" } else { table },
        supplement: table-prefix,
        numbering: table-numbering,
        caption: figure.caption(
          position: top,
          separator: caption-separator,
          caption-body,
        ),
        gap: 6pt,
        outlined: true,
      )
    }


    /*
     * --------------------------------------------------------
     * OPTIONAL REFERENCE LABEL
     * --------------------------------------------------------
     */

    let labelled-table = if label == none {
      [#rendered-table]
    } else {
      [#rendered-table#label]
    }


    /*
     * --------------------------------------------------------
     * COMPLETE TABLE LAYOUT
     * --------------------------------------------------------
     *
     * Both table types occupy the available layout width.
     *
     * The table itself is centered.
     *
     * Numbered captions, appendix titles, notes,
     * and sources align with its measured left edge.
     */

    block(
      width: available-width,
      above: 0pt,
      below: 0pt,
    )[

      // Align numbered captions with the table's edge.
      #show figure.caption: caption => block(
        width: available-width,
      )[
        #pad(
          left: side-inset,
          right: side-inset,
        )[
          #set par(
            leading: caption-leading,
            spacing: 0pt,
          )
          #align(left)[
            #text(size: caption-font-size)[
              #caption
            ]
          ]
        ]
      ]

      // Disable justification outside table cells.
      #set par(
        justify: false,
        first-line-indent: 0pt,
        spacing: 0pt,
      )

      // Render the selected table type.
      #labelled-table

    ]

  })
]
}



/*
 * ============================================================
 * LIST OF TABLES
 * ============================================================
 *
 * Supported configuration values:
 *
 * - true: Show when at least one numbered table exists.
 * - false: Never show.
 * - "auto": Show when at least three numbered tables exist.
 *
 * Numbered appendix tables are included.
 * Unnumbered appendix tables are excluded.
 * ============================================================
 */

#let render-list-of-tables(
  settings,
  language: "de",
) = {

  /*
   * ----------------------------------------------------------
   * CONFIGURATION
   * ----------------------------------------------------------
   */

  let enabled = settings.at("enabled")


  /*
   * ----------------------------------------------------------
   * LOCALIZED TITLE
   * ----------------------------------------------------------
   */

  let title = if language == "de" {
    [Tabellenverzeichnis]
  } else {
    [List of Tables]
  }


  /*
   * ----------------------------------------------------------
   * GENERATE LIST
   * ----------------------------------------------------------
   */

  context {

    // Include main-text tables and numbered appendix tables.
    // Unnumbered appendix tables are excluded.
    let table-target = figure.where(kind: table).or(
      figure.where(kind: "iu-appendix-table", outlined: true),
    )

    let table-count = query(table-target).len()

    let show-list = if enabled == "auto" {
      table-count >= 3
    } else {
      enabled and table-count > 0
    }

    if show-list [

      // Apply consistent spacing between entries.
      #show outline.entry: set block(
        below: 6pt,
      )

      // Include the list title in the main table of contents.
      #show outline: set heading(outlined: true)

      // Generate the native table outline.
      #outline(
        title: title,
        target: table-target,
        indent: auto,
      )
    ]
  }
}