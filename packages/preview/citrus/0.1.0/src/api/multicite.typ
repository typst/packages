// citrus - Multicite API Module
//
// Provides multicite() function for citing multiple sources at once.

#import "../core/mod.typ": _bib-data, _csl-style, cite-marker, get-entry-year
#import "../core/constants.typ": (
  CITE-FORM, COLLAPSE, STYLE-CLASS, VERTICAL-ALIGN,
)
#import "../output/mod.typ": (
  collapse-punctuation, render-citation, render-names-for-citation-display,
  render-names-for-grouping, select-layout,
)
#import "../parsing/locales.typ": detect-language
#import "../data/mod.typ": apply-collapse
#import "../init/core.typ": _get-precomputed

// =============================================================================
// Formatting Helpers
// =============================================================================

/// Apply vertical alignment (superscript/subscript) to content
///
/// - content: The content to format
/// - valign: VERTICAL-ALIGN.sup, VERTICAL-ALIGN.sub, or none
/// Returns: Formatted content
#let _apply-vertical-align(content, valign) = {
  if valign == VERTICAL-ALIGN.sup {
    super(content)
  } else if valign == VERTICAL-ALIGN.sub {
    sub(content)
  } else {
    content
  }
}

/// Apply prefix, suffix, and optionally vertical alignment
///
/// - content: The content to wrap
/// - prefix: Prefix string
/// - suffix: Suffix string
/// - valign: Optional vertical alignment ("sup" or "sub")
/// Returns: Formatted content
#let _apply-affixes(content, prefix, suffix, valign: none) = {
  let formatted = [#prefix#content#suffix]
  _apply-vertical-align(formatted, valign)
}

/// Create a reference link to the first cited key
///
/// - content: The content to link
/// - first-key: The first citation key (for the reference target)
/// Returns: Linked content
#let _make-ref-link(content, first-key) = {
  link(label("citeproc-ref-" + first-key), content)
}

/// Get effective delimiter with fallback
///
/// - value: The value to check
/// - fallback: The fallback value if value is none
/// Returns: value or fallback
#let _get-with-fallback(value, fallback) = {
  if value == none { fallback } else { value }
}

/// Determine effective collapse mode with year-suffix fallback
///
/// CSL spec: "year-suffix" and "year-suffix-ranged" fall back to "year"
/// when disambiguate-add-year-suffix is "false"
///
/// - collapse-mode: The original collapse mode
/// - has-year-suffix: Whether year-suffix disambiguation is enabled
/// Returns: The effective collapse mode
#let _get-effective-collapse-mode(collapse-mode, has-year-suffix) = {
  if (
    collapse-mode in (COLLAPSE.year-suffix, COLLAPSE.year-suffix-ranged)
      and has-year-suffix != "true"
      and has-year-suffix != true
  ) {
    COLLAPSE.year // Fallback to year mode
  } else {
    collapse-mode
  }
}

// =============================================================================
// Main API
// =============================================================================

/// Create multiple citations at once
///
/// - keys: Citation keys (strings or dicts with key and supplement)
/// - form: Citation form ("prose" for narrative style)
/// Returns: Combined citation content
#let multicite(..args) = {
  let raw-list = args.pos()
  let form = args.named().at("form", default: none)

  if raw-list.len() == 0 { return [] }

  // Normalize: convert strings to dicts
  let normalized = raw-list.map(item => {
    if type(item) == str {
      (key: item, supplement: none)
    } else {
      (key: item.at("key"), supplement: item.at("supplement", default: none))
    }
  })

  // Place markers for all keys
  for item in normalized {
    cite-marker(item.key, locator: item.supplement, form: form)
  }

  context {
    let bib = _bib-data.get()
    let style = _csl-style.get()

    // Use precomputed data (O(1) lookup)
    let precomputed = _get-precomputed()
    let citations = precomputed.citations
    let suffixes = precomputed.suffixes

    let first-key = normalized.first().key

    // CSL-M: Select layout based on first entry's language (for global formatting)
    let first-entry = bib.at(first-key, default: none)
    let first-entry-lang = if first-entry != none {
      detect-language(first-entry.at("fields", default: (:)))
    } else { "en" }
    let layout = select-layout(
      style.citation.at("layouts", default: ()),
      first-entry-lang,
    )

    // Detect style class
    let is-note-style = style.class == STYLE-CLASS.note
    let is-author-date = (
      style.class == STYLE-CLASS.in-text
        and (
          style.citation.at("disambiguate-add-year-suffix", default: false)
            or layout.at("prefix", default: "") == "("
        )
    )

    // Get layout config
    let prefix = layout.at("prefix", default: "")
    let suffix = layout.at("suffix", default: "")
    let delimiter = layout.at("delimiter", default: ", ")

    if is-note-style {
      // Note/footnote style: render each citation fully and join with delimiter
      // Wrap in footnote unless using prose/author/year form
      let is-multicite = normalized.len() > 1

      let cite-parts = normalized.map(item => {
        let entry = bib.at(item.key, default: none)
        if entry == none { return [] }
        // Apply punctuation collapsing to each citation
        collapse-punctuation(render-citation(
          entry,
          style,
          supplement: item.supplement,
          form: if form != none { form } else { "full" },
          // Suppress affixes for individual citations in multi-cite context
          // (affixes applied once at the end)
          suppress-affixes: is-multicite,
        ))
      })

      let joined = cite-parts.filter(p => p != []).join(delimiter)

      // For multi-cite, apply suffix once at the end
      let result = if is-multicite {
        [#prefix#joined#suffix]
      } else {
        joined
      }

      let linked = link(label("citeproc-ref-" + first-key), result)

      // Wrap in footnote unless using inline forms
      let is-inline-form = (
        form in (CITE-FORM.prose, CITE-FORM.author, CITE-FORM.year)
      )
      if is-inline-form {
        linked
      } else {
        footnote(linked)
      }
    } else if is-author-date {
      // Author-date style: format as "(Author1, Year1; Author2, Year2)"
      // Get collapse mode from citation style
      let collapse-mode = style.citation.at("collapse", default: none)

      // Get disambiguation states for proper name rendering
      let disambig-states = precomputed.at("disambig-states", default: (:))

      // Build items with rendered author (for grouping), year, suffix
      // CSL spec: "The comparison is limited to the output of the (first) cs:names element"
      let cite-items = normalized
        .map(item => {
          let entry = bib.at(item.key, default: none)
          if entry == none { return none }

          // Get disambiguation state for this entry
          let disambig = disambig-states.at(item.key, default: (
            names-expanded: 0,
            givenname-level: 0,
          ))

          // Render names for grouping comparison (string, uses first cs:names output)
          let author = render-names-for-grouping(
            entry,
            style,
            names-expanded: disambig.at("names-expanded", default: 0),
            givenname-level: disambig.at("givenname-level", default: 0),
          )

          // Render names for display (content, uses full macro rendering)
          let author-display = render-names-for-citation-display(
            entry,
            style,
            names-expanded: disambig.at("names-expanded", default: 0),
            givenname-level: disambig.at("givenname-level", default: 0),
          )

          let year = get-entry-year(entry)
          let suffix = suffixes.at(item.key, default: "")

          (
            key: item.key,
            author: author,
            author-display: author-display,
            year: year,
            suffix: suffix,
            supplement: item.supplement,
            order: citations.order.at(item.key, default: 0),
          )
        })
        .filter(x => x != none)

      // Get delimiters from style (with fallbacks)
      let cite-group-delim = style.citation.at(
        "cite-group-delimiter",
        default: ", ",
      )
      let year-suffix-delim = _get-with-fallback(
        style.citation.at("year-suffix-delimiter", default: none),
        layout.at("delimiter", default: ", "),
      )
      let after-collapse-delim = _get-with-fallback(
        style.citation.at("after-collapse-delimiter", default: none),
        layout.at("delimiter", default: "; "),
      )

      // Check if cite-group-delimiter is explicitly set (triggers grouping)
      let has-cite-group-delim = (
        style.citation.at("cite-group-delimiter", default: none) != none
      )

      // Determine effective collapse mode (year-suffix falls back to year)
      let has-year-suffix = style.citation.at(
        "disambiguate-add-year-suffix",
        default: "false",
      )
      let effective-collapse-mode = _get-effective-collapse-mode(
        collapse-mode,
        has-year-suffix,
      )

      // Enable grouping if collapse is set OR cite-group-delimiter is set
      let enable-grouping = (
        effective-collapse-mode != none or has-cite-group-delim
      )

      // Apply collapsing/grouping
      let result = if (
        effective-collapse-mode
          in (COLLAPSE.year, COLLAPSE.year-suffix, COLLAPSE.year-suffix-ranged)
          or enable-grouping
      ) {
        apply-collapse(
          cite-items,
          effective-collapse-mode,
          enable-grouping: enable-grouping,
          delimiter: "; ",
          cite-group-delimiter: cite-group-delim,
          year-suffix-delimiter: year-suffix-delim,
          after-collapse-delimiter: after-collapse-delim,
        )
      } else {
        // No collapsing or grouping - format each citation separately
        let parts = cite-items.map(it => {
          let year-str = str(it.year) + it.suffix
          // Use author-display for display (fall back to author string)
          let display-author = it.at("author-display", default: it.author)
          if it.supplement != none {
            [#display-author, #year-str: #it.supplement]
          } else {
            [#display-author, #year-str]
          }
        })
        parts.join("; ")
      }

      // Apply formatting and link
      let valign = layout.at("vertical-align", default: none)

      if form == CITE-FORM.prose {
        // Prose: no outer parentheses, no vertical-align
        _make-ref-link(result, first-key)
      } else {
        // Normal: with affixes and vertical-align
        let formatted = _apply-affixes(result, prefix, suffix, valign: valign)
        _make-ref-link(formatted, first-key)
      }
    } else {
      // Numeric style: format as "[1, 2, 3]" or "[1-3]"
      let collapse-mode = style.citation.at("collapse", default: none)

      // Build items with order numbers
      let cite-items = normalized.map(item => {
        let order = citations.order.at(item.key, default: 0)
        (
          key: item.key,
          order: order,
          supplement: item.supplement,
        )
      })

      // Apply collapsing
      let result = apply-collapse(
        cite-items,
        collapse-mode,
        delimiter: delimiter,
        cite-group-delimiter: style.citation.at(
          "cite-group-delimiter",
          default: ", ",
        ),
        year-suffix-delimiter: style.citation.at(
          "year-suffix-delimiter",
          default: ", ",
        ),
        after-collapse-delimiter: style.citation.at(
          "after-collapse-delimiter",
          default: none,
        ),
      )

      // Apply formatting and link
      let valign = layout.at("vertical-align", default: none)
      let formatted = _apply-affixes(result, prefix, suffix, valign: valign)
      _make-ref-link(formatted, first-key)
    }
  }
}
