#import "styles/page.typ": with-page
#import "styles/typography.typ": with-typography
#import "styles/headings.typ": with-headings
#import "styles/captions.typ": with-captions
#import "components/cover.typ": make-cover
#import "components/abstract.typ": make-abstract
#import "components/bibliography.typ": make-bibliography
#import "metadata.typ": normalize-metadata
#import "settings.typ": resolve-settings

// Coordinate document composition. Metadata and settings parsing are delegated
// to dedicated modules so the composition layer only orchestrates components.
#let compose-document(
  body,
  metadata: (:),
  settings: (:),
  abstract: none,
  keywords: (),
  bibliography-file: none,
) = {
  let meta = normalize-metadata(metadata)
  let config = resolve-settings(settings)
  let language = config.at("language")
  let page-config = config.at("page")
  let type-config = config.at("typography")
  let cover-config = config.at("cover")
  let bibliography-config = config.at("bibliography")

  let bibliography-title = if language == "en" { [References] } else { [Referencias] }

  // Native PDF metadata uses the same source as the cover.
  set document(
    title: [#meta.title],
    author: meta.authors,
    keywords: keywords,
  )

  with-page(
    with-typography(
      with-headings(
        with-captions([
          #make-cover(
            meta.title,
            authors: meta.authors,
            affiliation: meta.affiliation,
            faculty: meta.faculty,
            institution: meta.institution,
            program: meta.program,
            course: meta.course,
            instructor: meta.instructor,
            date: meta.date,
            laboratory: meta.laboratory,
            practice: meta.practice,
            group: meta.group,
            language: language,
            top-space: cover-config.at("top-space"),
          )

          #pagebreak()

          #if abstract != none [
            #make-abstract(
              abstract,
              keywords: keywords,
              heading-title: if language == "en" { [Abstract] } else { [Resumen] },
              keywords-label: if language == "en" { [Keywords:] } else { [Palabras clave:] },
            )
            #pagebreak()
          ]

          // Typst's semantic title element is distinct from section headings.
          #title()

          #body

          #if bibliography-file != none [
            #make-bibliography(
              bibliography-file,
              style: bibliography-config.at("style"),
              title: bibliography-title,
              full: bibliography-config.at("full"),
            )
          ]
        ]),
        font-size: type-config.at("font-size"),
        heading-leading: type-config.at("heading-leading"),
        heading-spacing: type-config.at("heading-spacing"),
      ),
      font: type-config.at("font"),
      font-size: type-config.at("font-size"),
      math-font: type-config.at("math-font"),
      math-size: type-config.at("math-size"),
      code-font: type-config.at("code-font"),
      code-inline-size: type-config.at("code-inline-size"),
      code-block-size: type-config.at("code-block-size"),
      language: language,
      justify: type-config.at("justify"),
      leading: type-config.at("leading"),
      paragraph-spacing: type-config.at("paragraph-spacing"),
      first-line-indent: type-config.at("first-line-indent"),
      top-edge: type-config.at("top-edge"),
      bottom-edge: type-config.at("bottom-edge"),
    ),
    paper: page-config.at("paper"),
    margin: page-config.at("margin"),
    page-numbers: page-config.at("page-numbers"),
  )
}
