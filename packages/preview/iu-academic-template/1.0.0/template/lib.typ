// Reusable academic template entry point.
// Project resources are bound through make-document().

// Document controller

#import "core/document.typ" as document-controller

// Document components

#import "components/figures.typ" as figures
#import "components/tables.typ" as tables
#import "components/appendix.typ" as appendices
#import "components/abbreviations-manager.typ" as abbreviations-manager
#import "components/citations.typ" as citations
#import "components/bibliography.typ" as bibliography-component

// Citation integrations

#import "integrations/citrus.typ" as citrus
#import "integrations/native.typ" as native
#import "integrations/citation-engine.typ" as citation-engine

// Configuration validation

#let _require-section(config, name) = {
  assert(
    name in config,
    message: "Missing configuration section: " + name,
  )

  let section = config.at(name)
  assert(
    type(section) == dictionary,
    message: "Configuration section '" + name + "' must be a dictionary.",
  )

  section
}

#let _require-field(section, section-name, name) = {
  assert(
    name in section,
    message: "Missing configuration field: " + section-name + "." + name,
  )

  section.at(name)
}

#let _is-text(value) = {
  type(value) == str or type(value) == content
}

#let _is-nonempty-text(value) = {
  _is-text(value) and (type(value) != str or value.trim() != "")
}

#let _is-numbering(value) = {
  value == none or type(value) == str or type(value) == function
}

#let _validate-document-inputs(
  config,
  abbreviations,
  bibliography-source,
  bibliography-style,
) = {
  // Project inputs

  assert(
    type(config) == dictionary,
    message: "Document configuration must be a dictionary.",
  )
  assert(
    type(abbreviations) == dictionary,
    message: "Abbreviations must be a dictionary.",
  )
  assert(
    type(bibliography-source) == path,
    message: "Bibliography source must be a project-bound path.",
  )
  assert(
    type(bibliography-style) == path or (
      type(bibliography-style) == str and bibliography-style.trim() != ""
    ),
    message: "Bibliography style must be a path or a nonempty style name.",
  )

  let language = _require-field(config, "config", "language")
  assert(
    language == "de" or language == "en",
    message: "Unsupported language. Use 'de' or 'en'.",
  )

  // Formatting

  let formatting = _require-section(config, "formatting")
  let f = (name) => _require-field(formatting, "formatting", name)

  let paper = f("paper")
  assert(
    type(paper) == str and paper.trim() != "",
    message: "formatting.paper must be a nonempty paper size name.",
  )

  let margin = f("margin")
  assert(
    type(margin) == length or type(margin) == dictionary,
    message: "formatting.margin must be a length or margin dictionary.",
  )

  let font = f("font")
  assert(
    (type(font) == str and font.trim() != "") or type(font) == array,
    message: "formatting.font must be a font name or a font family array.",
  )
  if type(font) == array {
    assert(font.len() > 0, message: "formatting.font must not be empty.")
    for family in font {
      assert(
        type(family) == str and family.trim() != "",
        message: "Each formatting.font family must be a nonempty string.",
      )
    }
  }

  let font-size = f("font-size")
  assert(
    type(font-size) == length and font-size > 0pt,
    message: "formatting.font-size must be a positive length.",
  )

  let line-spacing = f("line-spacing")
  assert(
    (type(line-spacing) == int or type(line-spacing) == float)
      and line-spacing >= 1,
    message: "formatting.line-spacing must be a number of at least 1.",
  )

  let paragraph-spacing = f("paragraph-spacing")
  assert(
    type(paragraph-spacing) == length and paragraph-spacing >= 0pt,
    message: "formatting.paragraph-spacing must be a nonnegative length.",
  )

  for name in ("justify", "hyphenate") {
    assert(
      type(f(name)) == bool,
      message: "formatting." + name + " must be a boolean.",
    )
  }

  let heading-sizes = f("heading-sizes")
  assert(
    type(heading-sizes) == array and heading-sizes.len() == 3,
    message: "formatting.heading-sizes must contain exactly three sizes.",
  )
  for size in heading-sizes {
    assert(
      type(size) == length and size > 0pt,
      message: "Each formatting.heading-sizes entry must be a positive length.",
    )
  }

  assert(
    _is-numbering(f("heading-numbering")),
    message: "formatting.heading-numbering must be a pattern, function, or none.",
  )

  let footnote-size = f("footnote-size")
  assert(
    type(footnote-size) == length and footnote-size > 0pt,
    message: "formatting.footnote-size must be a positive length.",
  )

  // Page and appendix numbering

  let page-numbering = _require-section(formatting, "page-numbering")
  let p = (name) => _require-field(
    page-numbering, "formatting.page-numbering", name,
  )

  for name in ("front-matter", "main-matter") {
    assert(
      _is-numbering(p(name)),
      message: "formatting.page-numbering." + name
        + " must be a pattern, function, or none.",
    )
  }

  let main-start = p("main-start")
  assert(
    type(main-start) == int and main-start >= 1,
    message: "formatting.page-numbering.main-start must be a positive integer.",
  )

  assert(
    type(p("position")) == alignment,
    message: "formatting.page-numbering.position must be an alignment.",
  )
  assert(
    type(p("show-on-title-page")) == bool,
    message: "formatting.page-numbering.show-on-title-page must be a boolean.",
  )

  let appendix-numbering = _require-section(formatting, "appendices-numbering")
  let numbering-pattern = _require-field(
    appendix-numbering, "formatting.appendices-numbering", "numbering",
  )
  assert(
    type(numbering-pattern) == str and numbering-pattern.trim() != "",
    message: "formatting.appendices-numbering.numbering must be a pattern string.",
  )

  // Validate figure and table numbering modes in appendices.
  for name in ("figures", "tables") {
    let mode = _require-field(
      appendix-numbering,
      "formatting.appendices-numbering",
      name,
    )

    assert(
      type(mode) == str and mode in (
        "none",
        "per-appendix",
        "continuous",
      ),
      message: "formatting.appendices-numbering." + name
        + " must be 'none', 'per-appendix', or 'continuous'.",
    )
  }


  // Title page

  let title-page = _require-section(config, "title-page")

  for name in ("university", "document-type", "title") {
    let value = _require-field(title-page, "title-page", name)
    assert(
      _is-nonempty-text(value),
      message: "title-page." + name + " must be nonempty text or content.",
    )
  }

  let author = _require-field(title-page, "title-page", "author")
  assert(
    type(author) == str and author.trim() != "",
    message: "title-page.author must be a nonempty string.",
  )

  for name in (
    "faculty", "degree-program", "course", "course-number",
    "semester", "subtitle", "student-id", "supervisor", "location",
  ) {
    if name in title-page {
      let value = title-page.at(name)
      assert(
        value == none or _is-nonempty-text(value),
        message: "title-page." + name + " must be text, content, or none.",
      )
    }
  }

  if "submission-date" in title-page {
    let value = title-page.at("submission-date")
    assert(
      value == none or type(value) == datetime,
      message: "title-page.submission-date must be a datetime or none.",
    )
  }

  if "logo" in title-page {
    let value = title-page.at("logo")
    assert(
      value == none or type(value) == content,
      message: "title-page.logo must be image content or none.",
    )
  }

  // Document lists

  for name in (
    "table-of-contents", "list-of-figures", "list-of-tables",
    "abbreviation-list", "list-of-appendices",
  ) {
    let settings = _require-section(config, name)
    let enabled = _require-field(settings, name, "enabled")

    if name in (
      "list-of-figures",
      "list-of-tables",
      "list-of-appendices",
    ) {
      assert(
        type(enabled) == bool or enabled == "auto",
        message: name + ".enabled must be a boolean or 'auto'.",
      )
    } else {
      assert(
        type(enabled) == bool,
        message: name + ".enabled must be a boolean.",
      )
    }

    if name == "table-of-contents" {
      let depth = _require-field(settings, name, "depth")
      assert(
        type(depth) == int and depth >= 1,
        message: "table-of-contents.depth must be a positive integer.",
      )
    }
  }

  // Figure and table source notes

  let source-notes = _require-section(config, "source-notes")
  let show-own-work = _require-field(
    source-notes,
    "source-notes",
    "show-own-work",
  )
  assert(
    type(show-own-work) == bool,
    message: "source-notes.show-own-work must be a boolean.",
  )

  // Abbreviations

  for (key, entry) in abbreviations.pairs() {
    assert(
      type(entry) == dictionary,
      message: "Abbreviation '" + key + "' must be a dictionary.",
    )

    let short = _require-field(entry, "abbreviations." + key, "short")
    let long = _require-field(entry, "abbreviations." + key, "long")

    assert(
      type(short) == str and short.trim() != "",
      message: "Abbreviation '" + key + "' requires a nonempty short form.",
    )
    assert(
      _is-nonempty-text(long),
      message: "Abbreviation '" + key + "' requires a nonempty long form.",
    )
  }

  // Bibliography settings

  let settings = _require-section(config, "bibliography")
  let b = (name) => _require-field(settings, "bibliography", name)

  assert(
    type(b("enabled")) == bool,
    message: "bibliography.enabled must be a boolean.",
  )

  let engine = b("engine")
  assert(
    engine == "citrus" or engine == "native",
    message: "bibliography.engine must be 'citrus' or 'native'.",
  )

  let file = b("file")
  assert(
    type(file) == str and file.trim() != "",
    message: "bibliography.file must be a nonempty filename.",
  )

  let style = b("style")
  assert(
    type(style) == path or (
      type(style) == str and style.trim() != ""
    ),
    message: "bibliography.style must be a path or a nonempty style name.",
  )

  let is-json = file.ends-with(".json")
  let is-bib = file.ends-with(".bib")
  let is-yaml = file.ends-with(".yaml") or file.ends-with(".yml")

  assert(
    (engine == "citrus" and (is-json or is-bib))
      or (engine == "native" and (is-yaml or is-bib)),
    message: "Unsupported citation engine and bibliography format combination.",
  )
}

// Document factory

#let make-document(
  config: none,
  abbreviations: none,
  bibliography-source: none,
  bibliography-style: none,
) = {

  _validate-document-inputs(
    config,
    abbreviations,
    bibliography-source,
    bibliography-style,
  )

  // Document settings

  let language = config.language
  let bibliography-settings = config.bibliography
  let engine = bibliography-settings.engine

  let appendix-numbering = (
    config.formatting.appendices-numbering.numbering
  )

  let advanced-citations-enabled = (
    engine == "citrus"
      and bibliography-settings.file.ends-with(".json")
  )

  // Bibliography resources

  let resolved-style = citation-engine.resolve-bibliography-style(
    bibliography-style,
    engine,
  )

  let citation-references = if advanced-citations-enabled {
    json(bibliography-source)
  } else {
    ()
  }

  // Citation initialization

  let citation-initializer = (
    citation-engine.initialize-citations.with(
      settings: bibliography-settings,
      bibliography-source: bibliography-source,
      bibliography-style: resolved-style,
      language: language,
    )
  )

  // Bind document functions

  let setup-document = (
    document-controller.setup-document.with(
      config,
      citation-initializer,
    )
  )

  let render-front-matter = (
    document-controller.render-front-matter.with(
      config,
      abbreviations,
    )
  )

  let start-main-matter = (
    document-controller.start-main-matter.with(
      config,
    )
  )

  let render-appendices = (
    document-controller.render-appendices.with(
      config,
    )
  )

  // Bibliography rendering

  let render-bibliography() = {

    if not bibliography-settings.enabled {
      return []
    }

    let rendered = if engine == "native" {

      native.render-native-bibliography(
        bibliography-settings,
        bibliography-source,
        resolved-style,
        language,
      )

    } else {

      bibliography-component.render-bibliography(
        settings: bibliography-settings,
        language: language,
        bibliography-engine: citrus.csl-bibliography,
      )

    }

    [
      #pagebreak(weak: true)
      #rendered
    ]
  }

  // Abbreviation helper

  let abbr(key, full: "auto") = {
    abbreviations-manager.use-abbreviation(
      key,
      abbreviations,
      full: full,
    )
  }

  // Advanced citation helpers

  let require-advanced-citations() = {
    assert(
      advanced-citations-enabled,
      message: "Advanced citation helpers require Citrus with CSL-JSON.",
    )
  }

  let narrative-cite(
    key,
    page: none,
    location: none,
  ) = {

    require-advanced-citations()

    citations.narrative-cite(
      key,
      references: citation-references,
      page: page,
      location: location,
      language: language,
    )
  }

  let secondary-cite(
    original-author,
    original-year,
    secondary-key,
    page: none,
    location: none,
    narrative: false,
  ) = {

    require-advanced-citations()

    citations.secondary-cite(
      original-author,
      original-year,
      secondary-key,
      references: citation-references,
      page: page,
      location: location,
      narrative: narrative,
      language: language,
    )
  }

  let cite-same-author(keys) = {

    require-advanced-citations()

    citations.cite-same-author(
      keys,
      references: citation-references,
      language: language,
    )
  }

  // Public document API

  (

    setup-document: setup-document,
    render-front-matter: render-front-matter,
    start-main-matter: start-main-matter,
    render-bibliography: render-bibliography,
    render-appendices: render-appendices,

    insert-figure: figures.insert-figure.with(
      language: language,
      show-own-work: config.source-notes.show-own-work,
      appendix-numbering-mode: config.formatting.appendices-numbering.figures,
      appendix-numbering-pattern: appendix-numbering,
    ),

    insert-table: tables.insert-table.with(
      language: language,
      show-own-work: config.source-notes.show-own-work,
      appendix-numbering-mode: config.formatting.appendices-numbering.tables,
      appendix-numbering-pattern: appendix-numbering,
    ),

    insert-appendix: appendices.insert-appendix.with(
      language: language,
      numbering-pattern: appendix-numbering,
    ),

    insert-appendix-section: appendices.insert-appendix-section.with(
      language: language,
    ),

    abbr: abbr,

    narrative-cite: narrative-cite,
    secondary-cite: secondary-cite,
    cite-same-author: cite-same-author,
    block-quote: citations.block-quote,

    multicite: citrus.multicite,
    nocite: citrus.nocite,
    locator: citrus.locator,
  )
}