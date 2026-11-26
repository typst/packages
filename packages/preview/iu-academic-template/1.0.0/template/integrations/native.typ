/*
 * ============================================================
 * NATIVE CITATION INTEGRATION
 * ============================================================
 *
 * Provides bibliography rendering using Typst's built-in
 * citation system.
 *
 * Supported formats:
 * - Hayagriva (.yaml, .yml)
 * - BibTeX / BibLaTeX (.bib)
 *
 * Responsibilities:
 * - Render the native bibliography
 * - Apply the resolved citation style
 * - Provide a localized bibliography heading
 *
 * All project-specific resources and settings are supplied
 * by the caller.
 *
 * Citation style resolution and configuration validation
 * are handled by the public template API.
 * ============================================================
 */


// ============================================================
// NATIVE BIBLIOGRAPHY
// ============================================================

#let render-native-bibliography(
  settings,
  bibliography-source,
  bibliography-style,
  language,
) = {

  // ----------------------------------------------------------
  // BIBLIOGRAPHY VISIBILITY
  // ----------------------------------------------------------

  if settings.enabled {

    // --------------------------------------------------------
    // LOCALIZED HEADING
    // --------------------------------------------------------

    let title = if language == "de" {
      [Literaturverzeichnis]
    } else {
      [References]
    }


    // --------------------------------------------------------
    // RENDER BIBLIOGRAPHY
    // --------------------------------------------------------

    bibliography(
      bibliography-source,
      title: title,
      style: bibliography-style,
    )

  }
}
