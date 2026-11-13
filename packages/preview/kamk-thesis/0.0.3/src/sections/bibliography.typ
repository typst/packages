// Load the translations
#let lang-data = toml("../data/lang.toml")

// `source` must be a resolved `path` value (e.g. path("references.bib")) built by the caller,
// since relative path strings resolve relative to the file where they are ultimately used.
#let render-bibliography(
  language: "fi",
  source: none,
  style: "ieee",
  cover_image_source: none,
) = {
  let d = lang-data.at(language)

  bibliography(source, title: d.references_heading, style: "../data/kamk-vancouver.csl")

  if cover_image_source != none and cover_image_source != "" {
    // Add some visual spacing after the bibliography
    v(2em)

    // outlined: false prevents this heading from appearing in the ToC
    heading(level: 2, outlined: false, numbering: none)[#d.cover_image_source_heading]

    cover_image_source
  }
}
