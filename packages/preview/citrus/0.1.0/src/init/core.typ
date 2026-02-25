// citrus - Core Initialization Module
//
// Shared initialization logic for CSL processing.

#import "../core/constants.typ": CITE-FORM, POSITION, STYLE-CLASS
#import "../parsing/mod.typ": parse-csl, parse-locale-file
#import "../output/mod.typ": (
  collapse-punctuation, get-rendered-entries, process-entries, render-citation,
)
#import "../parsing/locales.typ": detect-language
#import "../core/mod.typ": (
  _abbreviations, _bib-data, _cite-global-idx, _config, _csl-style, cite-marker,
  collect-citations,
)

// =============================================================================
// Precomputation Cache
// =============================================================================

/// Query precomputed citation data
/// Returns: (citations: ..., suffixes: ...) or none if not yet computed
#let _get-precomputed() = {
  let results = query(<citeproc-precomputed>)
  if results.len() > 0 {
    results.first().value
  } else {
    none
  }
}

// =============================================================================
// Loading Functions
// =============================================================================

/// Load and parse an external CSL locale file
///
/// - locale-content: Locale XML content (use `read("locales-en-US.xml")`)
/// Returns: Parsed locale object
#let load-locale(locale-content) = {
  parse-locale-file(locale-content)
}

/// Load and parse a CSL style file
///
/// - csl-content: CSL file content (use `read("style.csl")`)
/// - locales: Optional dict of lang -> locale content for external locales
///            e.g., (en-US: read("locales-en-US.xml"))
/// Returns: Parsed CSL style object
#let load-csl(csl-content, locales: (:)) = {
  // Parse external locales
  let parsed-locales = (:)
  for (lang, content) in locales.pairs() {
    parsed-locales.insert(lang, parse-locale-file(content))
  }

  let xml-tree = xml(bytes(csl-content))
  parse-csl(xml-tree, external-locales: parsed-locales)
}

// =============================================================================
// Core Initialization
// =============================================================================

/// Shared CSL initialization logic
///
/// Assumes _bib-data has already been populated.
#let _init-csl-core(
  style,
  locales: (:),
  show-url: true,
  show-doi: true,
  show-accessed: true,
  auto-links: true,
  doc,
  bib-bytes,
) = {
  // Parse CSL style with external locales
  let csl-style = load-csl(style, locales: locales)
  _csl-style.update(csl-style)

  // Set display config
  _config.update((
    show-url: show-url,
    show-doi: show-doi,
    show-accessed: show-accessed,
    auto-links: auto-links,
  ))

  // Intercept cite elements
  show cite: it => {
    let key = str(it.key)

    // Place citation marker for collection (uses complex label)
    cite-marker(key, locator: it.supplement, form: it.form)

    // Render citation using precomputed data (O(1) lookup via global counter)
    context {
      let precomputed = _get-precomputed()
      let style = _csl-style.get()
      let rendered-citations = precomputed.at("rendered-citations", default: ())

      // Get citation index (0-based) from global counter
      let cite-idx = _cite-global-idx.get().first() - 1

      if cite-idx >= 0 and cite-idx < rendered-citations.len() {
        let cite-data = rendered-citations.at(cite-idx)
        let result = cite-data.content
        let cite-key = cite-data.key
        let form = cite-data.form

        // Add footnote/link wrapper
        let is-note-style = style.class == STYLE-CLASS.note
        let is-inline-form = (
          form in (CITE-FORM.prose, CITE-FORM.author, CITE-FORM.year)
        )

        if is-note-style and not is-inline-form {
          footnote(link(label("citeproc-ref-" + cite-key), result))
        } else {
          link(label("citeproc-ref-" + cite-key), result)
        }
      } else {
        // Fallback for edge cases
        text(fill: red, "[??" + key + "??]")
      }
    }
  }

  doc

  // Hidden bibliography for @key syntax (at end to avoid blank page)
  {
    set bibliography(title: none)
    show bibliography: none
    bibliography(bytes(bib-bytes))
  }

  // Precompute citation data ONCE at document end
  // This is queried by each @key citation via _get-precomputed()
  // Performance: O(N) once instead of O(N²) across all citations
  context {
    let bib = _bib-data.get()
    let style = _csl-style.get()
    let citations = collect-citations()

    // Process entries through the full IR pipeline (sort + disambiguate)
    // This ensures year-suffixes are assigned according to CSL spec:
    // "The assignment of year-suffixes follows the order of the bibliographies entries"
    let processed = process-entries(bib, citations, style)

    // Extract suffixes, disambiguation state, and sorted order from processed entries
    let suffixes = (:)
    let disambig-states = (:)
    let sorted-keys = () // Preserve sorted order to avoid re-sorting
    for e in processed {
      sorted-keys.push(e.key)
      let disambig = e.disambig
      let suffix = disambig.at("year-suffix", default: "")
      if suffix != "" {
        suffixes.insert(e.key, suffix)
      }
      // Store full disambiguation state for citation rendering
      disambig-states.insert(e.key, disambig)
    }

    // Get abbreviations for rendering
    let abbrevs = _abbreviations.get()

    // Pre-render ALL citations for O(1) lookup in show rule
    // This eliminates the need for query(selector.before(here())) which causes layout iterations
    // Note: Only render content, NOT footnote/link wrappers (those are added in show rule)
    let rendered-citations = citations.by-location.map(cite-info => {
      let key = cite-info.key
      let entry = bib.at(key, default: none)
      if entry == none {
        (key: key, content: text(fill: red, "[??" + key + "??]"), form: none)
      } else {
        let cite-number = citations.order.at(key, default: citations.count + 1)
        let positions-key = cite-info.positions-key
        let occurrence = cite-info.occurrence
        let locator = cite-info.at("locator", default: none)
        let form = cite-info.at("form", default: none)

        // Get position from precomputed positions
        let all-positions = citations.positions.at(positions-key, default: ())
        let pos-info = all-positions.find(p => (
          p.at("occurrence", default: -1) == occurrence
        ))
        let position = if pos-info != none {
          pos-info.at("position", default: POSITION.first)
        } else {
          POSITION.first
        }

        let year-suffix = suffixes.at(key, default: "")
        let disambig = disambig-states.at(key, default: (
          names-expanded: 0,
          givenname-level: 0,
        ))
        let first-note-number = citations.first-note-numbers.at(
          key,
          default: none,
        )

        let result = collapse-punctuation(render-citation(
          entry,
          style,
          form: form,
          supplement: locator,
          cite-number: cite-number,
          year-suffix: year-suffix,
          position: position,
          first-note-number: first-note-number,
          abbreviations: abbrevs,
          names-expanded: disambig.at("names-expanded", default: 0),
          givenname-level: disambig.at("givenname-level", default: 0),
        ))

        (key: key, content: result, form: form)
      }
    })

    // Store as queryable metadata (including pre-rendered citations)
    [#metadata((
      citations: citations,
      suffixes: suffixes,
      disambig-states: disambig-states,
      sorted-keys: sorted-keys,
      rendered-citations: rendered-citations, // Pre-rendered for O(1) lookup
    ))<citeproc-precomputed>]

    // Pre-render bibliography entries to avoid convergence issues
    // This is done ONCE here instead of in csl-bibliography context
    let rendered-entries = get-rendered-entries(
      bib,
      citations,
      style,
      abbreviations: abbrevs,
      precomputed: (
        sorted-keys: sorted-keys,
        disambig-states: disambig-states,
      ),
    )

    // Build pre-rendered entry data
    let pre-rendered = rendered-entries.map(e => (
      key: e.ir.key,
      order: e.ir.order,
      year-suffix: e.ir.disambig.year-suffix,
      lang: detect-language(e.ir.entry.at("fields", default: (:))),
      entry-type: e.ir.entry.at("entry_type", default: "misc"),
      fields: e.ir.entry.at("fields", default: (:)),
      parsed-names: e.ir.entry.at("parsed_names", default: (:)),
      rendered: e.rendered,
      rendered-body: e.rendered-body,
      rendered-number: e.rendered-number,
      ref-label: e.label,
      labeled-rendered: [#e.rendered #e.label],
    ))

    // Get bibliography settings for csl-bibliography
    let bib-settings = style.at("bibliography", default: (:))
    let second-field-align = bib-settings.at(
      "second-field-align",
      default: none,
    )

    // Get references term for title
    let references-term = style.locale.terms.at("references", default: none)
    let references-text = if references-term != none {
      if type(references-term) == dictionary {
        references-term.at("multiple", default: "References")
      } else {
        references-term
      }
    } else {
      "References"
    }

    // Pre-render complete bibliography content
    let bib-content = {
      if second-field-align == "flush" {
        let max-order = pre-rendered.fold(0, (acc, e) => calc.max(acc, e.order))
        let digit-count = str(max-order).len()
        let num-width = 2em + digit-count * 0.6em
        let indent = num-width + 0.5em

        set par(first-line-indent: 0em, hanging-indent: indent, spacing: 0.65em)
        for e in pre-rendered {
          box(width: num-width, align(right, e.rendered-number))
          h(0.5em)
          [#e.rendered-body #e.ref-label]
          parbreak()
        }
      } else if second-field-align == "margin" {
        let max-order = pre-rendered.fold(0, (acc, e) => calc.max(acc, e.order))
        let digit-count = str(max-order).len()
        let num-width = 2em + digit-count * 0.6em + 0.5em

        set par(
          first-line-indent: -num-width,
          hanging-indent: 0em,
          spacing: 0.65em,
        )
        pad(left: num-width)[
          #for e in pre-rendered {
            box(width: num-width, align(right, e.rendered-number))
            [#e.rendered-body #e.ref-label]
            parbreak()
          }
        ]
      } else {
        set par(hanging-indent: 2em, first-line-indent: 0em)
        for e in pre-rendered {
          e.labeled-rendered
          parbreak()
        }
      }
    }

    [#metadata((
      entries: pre-rendered,
      second-field-align: second-field-align,
      references-text: references-text,
      rendered-content: bib-content,
    ))<citeproc-bibliography>]
  }
}
