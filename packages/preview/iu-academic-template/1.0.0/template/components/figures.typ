/*
 * ============================================================
 * FIGURES COMPONENT
 * ============================================================
 *
 * Provides reusable figures and an automatic list of figures.
 *
 * Main text:
 * - Automatic figure numbering
 * - Caption above the visual
 * - Optional notes and source below
 * - Inclusion in the list of figures
 *
 * Appendix:
 * - Configurable numbering: none, per-appendix, or continuous
 * - An optional title without a number in "none" mode
 * - Optional notes and source below
 * - Numbered appendix figures appear in the list of figures
 *
 * The visual defines the width of the entire figure.
 * All text aligns with the visual's left edge.
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
 * INSERT FIGURE
 * ============================================================
 *
 * Parameters:
 * - visual: Image, diagram, or other graphical content.
 * - title: Figure title; may be none in the appendix.
 * - source: Optional source information.
 * - note: Optional explanatory note.
 * - label: Optional reference label.
 * - language: Document language.
 * - show-own-work: Display the automatic source for own figures.
 * - appendix-numbering-mode: Numbering of figures inside appendices.
 * - appendix-numbering-pattern: Numbering pattern of the appendix hierarchy.
 *
 * Appendix mode is detected automatically.
 * ============================================================
 */

#let insert-figure(
  visual,
  title: none,
  source: none,
  note: none,
  label: none,
  language: "de",
  show-own-work: true,
  appendix-numbering-mode: "none",
  appendix-numbering-pattern: none,
) = {

  /*
   * ----------------------------------------------------------
   * LOCALIZED CONTENT
   * ----------------------------------------------------------
   */

  let figure-prefix = if language == "de" {
    [Abb.]
  } else {
    [Figure]
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
   * DYNAMIC FIGURE LAYOUT
   * ----------------------------------------------------------
   *
   * The layout context provides the current appendix state
   * and the available width.
   */


  block(
    width: 100%,
    above: 18pt,
    below: 18pt,
  )[
    #layout(size => {


    let is-appendix = appendix-mode.get()

    let available-width = size.width

    // Measure the actual width of the visual.
    let visual-width = measure(
      visual,
      width: available-width,
    ).width

    // Center the visual within the available space.
    let side-inset = if visual-width < available-width {
      (available-width - visual-width) / 2
    } else {
      0pt
    }


    /*
     * --------------------------------------------------------
     * SHARED FIGURE BODY
     * --------------------------------------------------------
     *
     * Both main text and appendix figures use the same
     * visual, note, and source layout.
     */

    let figure-body = block(
      width: available-width,
    )[

      // Center the visual at its configured width.
      #align(center)[
        #visual
      ]

      // Render the notes area only if there is something to show.
      #if note != none or show-source [
        #v(6pt)

        // Align additional information with the visual.
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
            #block(below: if show-source { note-source-gap } else { 0pt }
            )[
              #set par(
                leading: caption-leading,
                spacing: 0pt,
              )
              #note
            ]
          ]

          // Explicit sources always appear. Own-work notes are optional.
          #if show-source [
            #block[
              #(source-label): #source-content
            ]
          ]
        ]
      ]

    ]


    /*
     * --------------------------------------------------------
     * APPENDIX FIGURE BODY
     * --------------------------------------------------------
     *
     * The appendix title is displayed without a figure
     * number or prefix.
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
          #align(left)[
            #title
          ]
        ]

        #v(6pt)

      ]

      // Shared visual, note, and source.
      #figure-body

    ]


    /*
     * --------------------------------------------------------
     * SELECT FIGURE TYPE AND NUMBERING
     * --------------------------------------------------------
     *
     * "none": Keep the existing unnumbered appendix appearance.
     * "continuous": Use the main-text image figure counter.
     * "per-appendix": Use a separate counter, reset at each
     * main appendix by appendix.typ.
     */

    let rendered-figure = if is-appendix and appendix-numbering-mode == "none" {
      figure(
        appendix-body,
        kind: "iu-appendix-image",
        supplement: none,
        numbering: none,
        caption: none,
        outlined: false,
      )
    } else {
      let caption-body = if title == none { [] } else { title }
      let caption-separator = if title == none { [] } else { h(0.35em) }

      let per-appendix = is-appendix and appendix-numbering-mode == "per-appendix"

      // Typst evaluates the numbering function in the figure's
      // own context, including when it renders an outline or ref.
      // The appendix prefix always comes from the main appendix.
      let figure-numbering = if per-appendix {
        n => numbering(
          appendix-numbering-pattern,
          appendix-counter.get().first(),
          n,
        )
      } else {
        "1"
      }

      figure(
        figure-body,
        kind: if per-appendix { "iu-appendix-image" } else { image },
        supplement: figure-prefix,
        numbering: figure-numbering,
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

    let labelled-figure = if label == none {
      [#rendered-figure]
    } else {
      [#rendered-figure#label]
    }


    /*
     * --------------------------------------------------------
     * COMPLETE FIGURE LAYOUT
     * --------------------------------------------------------
     *
     * The complete block remains centered.
     *
     * Numbered captions, appendix titles, notes, and
     * sources align with the measured visual width.
     */

    block(
      width: available-width,
      above: 0pt,
      below: 0pt,
    )[
      #show figure.caption: set par(
        leading: caption-leading,
        spacing: 0pt,
      )
      // Align numbered captions with the visual.
      #show figure.caption: caption => block(
        width: available-width,
      )[
        #pad(
          left: side-inset,
          right: side-inset,
        )[
          #align(left)[
            #caption
          ]
        ]
      ]

      // Disable justification within figures.
      #set par(
        justify: false,
        first-line-indent: 0pt,
        spacing: 0pt,
      )

      // Apply the figure text size.
      #text(size: caption-font-size)[
        #labelled-figure
      ]

    ]

  })
  ]
}


/*
 * ============================================================
 * LIST OF FIGURES
 * ============================================================
 *
 * Supported configuration values:
 *
 * - true: Show when at least one numbered figure exists.
 * - false: Never show.
 * - "auto": Show when at least three numbered figures exist.
 *
 * Numbered appendix figures are included; unnumbered ones
 * are excluded by their outlined: false setting.
 * ============================================================
 */

#let render-list-of-figures(
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
    [Abbildungsverzeichnis]
  } else {
    [List of Figures]
  }


  /*
   * ----------------------------------------------------------
   * GENERATE LIST
   * ----------------------------------------------------------
   */

  context {

    // Combine ordinary figures with numbered appendix figures.
    // Unnumbered appendix figures are not included.
    let figure-target = figure.where(kind: image).or(
      figure.where(kind: "iu-appendix-image", outlined: true),
    )

    let figure-count = query(figure-target).len()

    let show-list = if enabled == "auto" {
      figure-count >= 3
    } else {
      enabled and figure-count > 0
    }

    if show-list [

      // Consistent spacing between entries.
      #show outline.entry: set block(
        below: 6pt,
      )


      // Include the list title in the main table of contents.
      #show outline: set heading(outlined: true)

      // Generate the native list of figures.
      #outline(
        title: title,
        target: figure-target,
        indent: auto,
      )
    ]
  }
}