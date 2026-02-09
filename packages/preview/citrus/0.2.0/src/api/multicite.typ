// citrus - Multicite API Module
//
// Provides multicite() function for citing multiple sources at once.

#import "../core/mod.typ": (
  _bib-data, _csl-style, cite-marker, get-entry-year, make-cite-ref-label,
)
#import "../core/constants.typ": (
  CITE-FORM, COLLAPSE, STYLE-CLASS, VERTICAL-ALIGN,
)
#import "../core/formatting.typ": apply-formatting
#import "../output/mod.typ": (
  collapse-punctuation, content-to-string, get-punctuation-in-quote,
  render-citation, render-names-for-citation-display, render-names-for-grouping,
  select-layout,
)
#import "../parsing/mod.typ": detect-language
#import "../data/mod.typ": (
  apply-collapse, collapse-numeric-ranges, collapse-suffix-ranges,
  extract-sort-keys, num-to-suffix, process-ranges, sort-entries,
)
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

/// Apply prefix, suffix, vertical alignment, and font formatting from layout
///
/// - content: The content to wrap
/// - prefix: Prefix string
/// - suffix: Suffix string
/// - layout: Layout dictionary with formatting attributes
/// Returns: Formatted content
#let _apply-affixes(content, prefix, suffix, layout: (:)) = {
  let formatted = [#prefix#content#suffix]

  // Apply vertical alignment
  let valign = layout.at("vertical-align", default: none)
  let with-valign = _apply-vertical-align(formatted, valign)

  // Apply font formatting (font-weight, font-style, etc.)
  apply-formatting(with-valign, layout)
}

#let _join-cite-parts(parts, delimiter) = {
  let joined = ()
  for i in range(parts.len()) {
    if i > 0 {
      let next = parts.at(i)
      let text = if type(next) == str { next } else {
        content-to-string(next)
      }
      let trimmed = text.trim()
      if not trimmed.starts-with(",") {
        joined.push(delimiter)
      }
    }
    joined.push(parts.at(i))
  }
  joined.join()
}

/// Create a reference link to the first cited key
///
/// - content: The content to link
/// - first-key: The first citation key (for the reference target)
/// Returns: Linked content
#let _make-ref-link(content, first-key) = {
  link(label(make-cite-ref-label(first-key)), content)
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
    let piq = get-punctuation-in-quote(style)

    // Helper: render citation with punctuation collapsing
    let render-cite(..args) = collapse-punctuation(
      render-citation(..args),
      punctuation-in-quote: piq,
    )

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
    let collapse-mode = style.citation.at("collapse", default: none)

    // Check for citation-number collapse (uses numeric range logic)
    let has-citation-number-collapse = collapse-mode == COLLAPSE.citation-number

    // Note style: only true if NOT using citation-number collapse
    let is-note-style = (
      style.class == STYLE-CLASS.note and not has-citation-number-collapse
    )

    // Use author-date/grouping logic if:
    // 1. Has year/year-suffix collapse (works for any style), OR
    // 2. Explicit author-date style, OR
    // 3. cite-group-delimiter is set
    let raw-cite-group-delim = style.citation.at(
      "cite-group-delimiter",
      default: none,
    )
    let has-cite-group-delim = raw-cite-group-delim != none
    let has-year-collapse = (
      collapse-mode
        in (
          COLLAPSE.year,
          COLLAPSE.year-suffix,
          COLLAPSE.year-suffix-ranged,
        )
    )
    let is-author-date = (
      has-year-collapse
        or (
          style.class == STYLE-CLASS.in-text
            and not has-citation-number-collapse
            and (
              style.citation.at("disambiguate-add-year-suffix", default: false)
                or layout.at("prefix", default: "") == "("
            )
        )
        or has-cite-group-delim
    )

    // Get layout config
    let prefix = layout.at("prefix", default: "")
    let suffix = layout.at("suffix", default: "")
    let delimiter = layout.at("delimiter", default: ", ")

    // Apply citation sort if specified (CSL <citation><sort>...</sort></citation>)
    let citation-sort = style.citation.at("sort", default: ())
    let normalized = if citation-sort.len() > 0 {
      // Sort citations according to CSL sort specification
      let with-entries = normalized.map(item => {
        let entry = bib.at(item.key, default: none)
        if entry == none { return (..item, entry: none, sort-keys: ()) }
        let keys = extract-sort-keys(
          entry,
          citation-sort,
          style,
          citation-context: true,
        )
        (..item, entry: entry, sort-keys: keys)
      })
      // Use sort-entries to apply the sort
      let sorted = sort-entries(with-entries)
      // Return just the normalized items (without sort-keys)
      sorted.map(item => (key: item.key, supplement: item.supplement))
    } else {
      normalized
    }

    // Update first-key after potential sorting
    let first-key = normalized.first().key

    // Check if we should use collapse logic (takes precedence over note-style)
    if is-author-date {
      // Author-date style with proper CSL rendering and collapse support
      let collapse-mode = style.citation.at("collapse", default: none)
      let disambig-states = precomputed.at("disambig-states", default: (:))

      // Get delimiters
      let raw-cite-group-delim = raw-cite-group-delim
      let after-collapse-delim = _get-with-fallback(
        style.citation.at("after-collapse-delimiter", default: none),
        layout.at("delimiter", default: "; "),
      )

      // Determine effective collapse mode
      let has-year-suffix = style.citation.at(
        "disambiguate-add-year-suffix",
        default: "false",
      )
      let effective-collapse-mode = _get-effective-collapse-mode(
        collapse-mode,
        has-year-suffix,
      )
      // cite-group-delimiter defaults to ", " except for year-suffix modes
      // Note styles with year collapse use layout delimiter for year groups.
      let cite-group-delim = if raw-cite-group-delim != none {
        raw-cite-group-delim
      } else if is-note-style and effective-collapse-mode == COLLAPSE.year {
        layout.at("delimiter", default: "; ")
      } else if (
        effective-collapse-mode
          in (COLLAPSE.year-suffix, COLLAPSE.year-suffix-ranged)
      ) {
        layout.at("delimiter", default: "; ")
      } else {
        ", "
      }

      // Build items with author key for grouping
      let cite-items = normalized
        .map(item => {
          let entry = bib.at(item.key, default: none)
          if entry == none { return none }

          let disambig = disambig-states.at(item.key, default: (
            names-expanded: 0,
            givenname-level: 0,
            givenname-levels: (),
            needs-disambiguate: false,
          ))

          // Get author string for grouping comparison
          let author-key = render-names-for-grouping(
            entry,
            style,
            names-expanded: disambig.at("names-expanded", default: 0),
            givenname-level: disambig.at("givenname-level", default: 0),
            givenname-levels: disambig.at("givenname-levels", default: ()),
          )

          // Get year for year-suffix collapse detection
          let year = get-entry-year(entry)

          (
            key: item.key,
            entry: entry,
            author-key: author-key,
            year: year,
            supplement: item.supplement,
            disambig: disambig,
          )
        })
        .filter(x => x != none)

      // Check if cite-group-delimiter is explicitly set (triggers grouping)
      let has-cite-group-delim = has-cite-group-delim

      // Apply grouping/collapse using CSL rendering
      let should-group = (
        effective-collapse-mode
          in (COLLAPSE.year, COLLAPSE.year-suffix, COLLAPSE.year-suffix-ranged)
          or has-cite-group-delim
      )
      let result = if should-group {
        // Group by adjacent author — only merge consecutive items with the same author-key.
        // Non-adjacent items with the same author stay in separate groups.
        let author-groups-list = () // Array of (author-key, items) tuples
        let prev-key = none
        for item in cite-items {
          if item.author-key == prev-key {
            // Same author as previous — append to current group
            let last = author-groups-list.pop()
            author-groups-list.push((
              key: last.key,
              items: last.items + (item,),
            ))
          } else {
            // New author (or first item) — start a new group
            author-groups-list.push((key: item.author-key, items: (item,)))
            prev-key = item.author-key
          }
        }

        // Get year-suffix-delimiter
        // CSL spec: year-suffix-delimiter falls back to cite-group-delimiter, then layout delimiter
        let year-suffix-delim = _get-with-fallback(
          style.citation.at("year-suffix-delimiter", default: none),
          _get-with-fallback(
            style.citation.at("cite-group-delimiter", default: none),
            layout.at("delimiter", default: ", "),
          ),
        )

        // Render each author group, tracking if collapse occurred
        let author-groups = () // Array of (content, collapsed: bool)
        for grp in author-groups-list {
          let items = grp.items
          let collapsed = items.len() > 1 // More than one item means collapse occurred

          // For year-suffix-ranged: group by year first, then collapse suffix ranges
          if effective-collapse-mode == COLLAPSE.year-suffix-ranged {
            // Group items by year within this author
            let by-year = (:)
            let year-order = ()
            for item in items {
              let y = if item.year != none { str(item.year) } else { "" }
              if y not in by-year {
                by-year.insert(y, ())
                year-order.push(y)
              }
              by-year.at(y).push(item)
            }

            let year-group-parts = () // Parts for each year group
            let is-first-in-author = true

            for (year-idx, y) in year-order.enumerate() {
              let year-items = by-year.at(y)
              // Get suffixes for this year group (as numeric indices)
              let year-suffixes = year-items.map(it => suffixes.at(
                it.key,
                default: none,
              ))
              let suffix-ranges = collapse-suffix-ranges(year-suffixes)

              // Parts within this year group (joined with year-suffix-delimiter)
              let suffix-parts = ()
              let is-first-in-year = true

              // If no valid suffixes (e.g., single item without disambiguation),
              // render items directly without range processing
              if suffix-ranges.len() == 0 {
                for item in year-items {
                  let rendered = render-cite(
                    item.entry,
                    style,
                    supplement: item.supplement,
                    year-suffix: suffixes.at(item.key, default: none),
                    suppress-affixes: true,
                    suppress-author: not is-first-in-author,
                    suppress-year: not is-first-in-year,
                    cite-number: citations.order.at(item.key, default: 0),
                    names-expanded: item.disambig.at(
                      "names-expanded",
                      default: 0,
                    ),
                    givenname-level: item.disambig.at(
                      "givenname-level",
                      default: 0,
                    ),
                    givenname-levels: item.disambig.at(
                      "givenname-levels",
                      default: (),
                    ),
                    needs-disambiguate: item.disambig.at(
                      "needs-disambiguate",
                      default: false,
                    ),
                  )
                  suffix-parts.push(rendered)
                  is-first-in-author = false
                  is-first-in-year = false
                }
              } else {
                for r in suffix-ranges {
                  // Only suppress year for subsequent items in same year, not for new years
                  let do-suppress-year = not is-first-in-year

                  if r.start == r.end {
                    // Single item
                    let item = year-items.find(it => (
                      suffixes.at(it.key, default: none) == r.start
                    ))
                    if item != none {
                      let rendered = render-cite(
                        item.entry,
                        style,
                        supplement: item.supplement,
                        year-suffix: r.start,
                        suppress-affixes: true,
                        suppress-author: not is-first-in-author,
                        suppress-year: do-suppress-year,
                        cite-number: citations.order.at(item.key, default: 0),
                        names-expanded: item.disambig.at(
                          "names-expanded",
                          default: 0,
                        ),
                        givenname-level: item.disambig.at(
                          "givenname-level",
                          default: 0,
                        ),
                        givenname-levels: item.disambig.at(
                          "givenname-levels",
                          default: (),
                        ),
                        needs-disambiguate: item.disambig.at(
                          "needs-disambiguate",
                          default: false,
                        ),
                      )
                      suffix-parts.push(rendered)
                      is-first-in-author = false
                      is-first-in-year = false
                    }
                  } else if r.end - r.start >= 2 {
                    // Range of 3+ consecutive suffixes — render as en-dash range
                    let start-item = year-items.find(it => (
                      suffixes.at(it.key, default: none) == r.start
                    ))
                    let end-item = year-items.find(it => (
                      suffixes.at(it.key, default: none) == r.end
                    ))
                    if start-item != none and end-item != none {
                      // Render start with full year+suffix
                      let start-rendered = render-cite(
                        start-item.entry,
                        style,
                        year-suffix: r.start,
                        suppress-affixes: true,
                        suppress-author: not is-first-in-author,
                        suppress-year: do-suppress-year,
                        cite-number: citations.order.at(
                          start-item.key,
                          default: 0,
                        ),
                        names-expanded: start-item.disambig.at(
                          "names-expanded",
                          default: 0,
                        ),
                        givenname-level: start-item.disambig.at(
                          "givenname-level",
                          default: 0,
                        ),
                        givenname-levels: start-item.disambig.at(
                          "givenname-levels",
                          default: (),
                        ),
                        needs-disambiguate: start-item.disambig.at(
                          "needs-disambiguate",
                          default: false,
                        ),
                      )
                      // For end, just use the suffix letter
                      let end-suffix = num-to-suffix(r.end)
                      suffix-parts.push([#start-rendered–#end-suffix])
                      is-first-in-author = false
                      is-first-in-year = false
                    }
                  } else {
                    // Range of exactly 2 consecutive suffixes — render individually
                    for suffix-idx in range(r.start, r.end + 1) {
                      let item = year-items.find(it => (
                        suffixes.at(it.key, default: none) == suffix-idx
                      ))
                      if item != none {
                        let rendered = render-cite(
                          item.entry,
                          style,
                          supplement: item.supplement,
                          year-suffix: suffix-idx,
                          suppress-affixes: true,
                          suppress-author: not is-first-in-author,
                          suppress-year: not is-first-in-year,
                          cite-number: citations.order.at(
                            item.key,
                            default: 0,
                          ),
                          names-expanded: item.disambig.at(
                            "names-expanded",
                            default: 0,
                          ),
                          givenname-level: item.disambig.at(
                            "givenname-level",
                            default: 0,
                          ),
                          givenname-levels: item.disambig.at(
                            "givenname-levels",
                            default: (),
                          ),
                          needs-disambiguate: item.disambig.at(
                            "needs-disambiguate",
                            default: false,
                          ),
                        )
                        suffix-parts.push(rendered)
                        is-first-in-author = false
                        is-first-in-year = false
                      }
                    }
                  }
                }
              }
              // Join suffixes within this year with year-suffix-delimiter
              if suffix-parts.len() > 0 {
                year-group-parts.push(suffix-parts.join(year-suffix-delim))
              }
            }
            // Join different years with layout delimiter
            author-groups.push((
              content: year-group-parts.join(cite-group-delim),
              collapsed: collapsed,
            ))
          } else if effective-collapse-mode == COLLAPSE.year-suffix {
            // year-suffix mode: group by year, use year-suffix-delimiter within year
            let by-year = (:)
            let year-order = ()
            for item in items {
              let y = if item.year != none { str(item.year) } else { "" }
              if y not in by-year {
                by-year.insert(y, ())
                year-order.push(y)
              }
              by-year.at(y).push(item)
            }

            let year-group-parts = ()
            let is-first-in-author = true

            for y in year-order {
              let year-items = by-year.at(y)
              let suffix-parts = ()
              let is-first-in-year = true

              for item in year-items {
                let rendered = render-cite(
                  item.entry,
                  style,
                  supplement: item.supplement,
                  year-suffix: suffixes.at(item.key, default: none),
                  suppress-affixes: true,
                  suppress-author: not is-first-in-author,
                  suppress-year: not is-first-in-year,
                  cite-number: citations.order.at(item.key, default: 0),
                  names-expanded: item.disambig.at(
                    "names-expanded",
                    default: 0,
                  ),
                  givenname-level: item.disambig.at(
                    "givenname-level",
                    default: 0,
                  ),
                  givenname-levels: item.disambig.at(
                    "givenname-levels",
                    default: (),
                  ),
                  needs-disambiguate: item.disambig.at(
                    "needs-disambiguate",
                    default: false,
                  ),
                )
                suffix-parts.push(rendered)
                is-first-in-author = false
                is-first-in-year = false
              }
              if suffix-parts.len() > 0 {
                year-group-parts.push(suffix-parts.join(year-suffix-delim))
              }
            }
            // Join different years with layout delimiter
            author-groups.push((
              content: year-group-parts.join(cite-group-delim),
              collapsed: collapsed,
            ))
          } else {
            // year mode: no suffix grouping
            // Use after-collapse-delimiter after items with locators
            let group-parts = ()
            let prev-had-locator = false
            let same-year = (
              items.len() > 1 and items.map(it => it.year).dedup().len() == 1
            )
            let has-suffixes = items.all(it => (
              suffixes.at(it.key, default: none) != none
            ))
            let ordered-items = if same-year and has-suffixes {
              items.sorted(key: it => suffixes.at(it.key, default: 0))
            } else {
              items
            }

            for (i, item) in ordered-items.enumerate() {
              // Only suppress author when collapse mode is active.
              // cite-group-delimiter alone triggers grouping (adjacent placement)
              // but NOT name suppression — that requires an explicit collapse attribute.
              let do-suppress-author = (
                i > 0 and effective-collapse-mode != none
              )

              let rendered = render-cite(
                item.entry,
                style,
                supplement: item.supplement,
                year-suffix: suffixes.at(item.key, default: none),
                suppress-affixes: true,
                suppress-author: do-suppress-author,
                suppress-year: false,
                cite-number: citations.order.at(item.key, default: 0),
                names-expanded: item.disambig.at("names-expanded", default: 0),
                givenname-level: item.disambig.at(
                  "givenname-level",
                  default: 0,
                ),
                givenname-levels: item.disambig.at(
                  "givenname-levels",
                  default: (),
                ),
                needs-disambiguate: item.disambig.at(
                  "needs-disambiguate",
                  default: false,
                ),
              )

              // Skip items that would render empty (e.g., no date when author is suppressed)
              // Check BEFORE rendering: if author is suppressed and no date, skip
              if do-suppress-author {
                let fields = item.entry.at("fields", default: (:))
                let has-date = (
                  fields.at("year", default: "") != ""
                    or fields.at("date", default: "") != ""
                )
                if not has-date and item.supplement == none {
                  continue
                }
              }

              // Use after-collapse-delimiter after items with locators
              if prev-had-locator and group-parts.len() > 0 {
                let last = group-parts.pop()
                group-parts.push([#last#after-collapse-delim#rendered])
              } else if group-parts.len() > 0 {
                let last = group-parts.pop()
                group-parts.push([#last#cite-group-delim#rendered])
              } else {
                group-parts.push(rendered)
              }

              prev-had-locator = item.supplement != none
            }
            author-groups.push((
              content: group-parts.join(),
              collapsed: collapsed,
            ))
          }
        }

        // Join author groups with appropriate delimiter
        // Use after-collapse-delimiter after groups that had collapse
        let author-parts = ()
        let prev-collapsed = false
        for grp in author-groups {
          if author-parts.len() == 0 {
            author-parts.push(grp.content)
          } else if prev-collapsed {
            // Previous group had collapse, use after-collapse-delimiter
            let last = author-parts.pop()
            author-parts.push([#last#after-collapse-delim#grp.content])
          } else {
            // No collapse in previous group, use layout delimiter
            let last = author-parts.pop()
            author-parts.push([#last#delimiter#grp.content])
          }
          prev-collapsed = grp.collapsed
        }
        author-parts.join()
      } else {
        // No collapse - render each citation fully
        let parts = cite-items.map(item => {
          render-cite(
            item.entry,
            style,
            supplement: item.supplement,
            year-suffix: suffixes.at(item.key, default: none),
            suppress-affixes: normalized.len() > 1,
            cite-number: citations.order.at(item.key, default: 0),
            names-expanded: item.disambig.at("names-expanded", default: 0),
            givenname-level: item.disambig.at("givenname-level", default: 0),
            givenname-levels: item.disambig.at("givenname-levels", default: ()),
            needs-disambiguate: item.disambig.at(
              "needs-disambiguate",
              default: false,
            ),
          )
        })
        _join-cite-parts(parts, delimiter)
      }

      // Apply formatting and link
      let valign = layout.at("vertical-align", default: none)

      if form == CITE-FORM.prose {
        // Prose: no outer parentheses, no vertical-align
        _make-ref-link(result, first-key)
      } else {
        // Normal: with affixes and formatting
        let formatted = _apply-affixes(result, prefix, suffix, layout: layout)
        _make-ref-link(formatted, first-key)
      }
    } else if is-note-style {
      // Note/footnote style without collapse: render each citation fully
      let is-multicite = normalized.len() > 1
      let disambig-states = precomputed.at("disambig-states", default: (:))

      let cite-parts = normalized.map(item => {
        let entry = bib.at(item.key, default: none)
        if entry == none { return [] }
        let disambig = disambig-states.at(item.key, default: (
          names-expanded: 0,
          givenname-level: 0,
          givenname-levels: (),
          year-suffix: none,
          needs-disambiguate: false,
        ))
        render-cite(
          entry,
          style,
          supplement: item.supplement,
          form: if form != none { form } else { "full" },
          suppress-affixes: is-multicite,
          cite-number: citations.order.at(item.key, default: 0),
          year-suffix: disambig.at("year-suffix", default: none),
          names-expanded: disambig.at("names-expanded", default: 0),
          givenname-level: disambig.at("givenname-level", default: 0),
          givenname-levels: disambig.at("givenname-levels", default: ()),
          needs-disambiguate: disambig.at("needs-disambiguate", default: false),
        )
      })

      let filtered = cite-parts.filter(p => p != [])
      let joined = _join-cite-parts(filtered, delimiter)

      // Apply affixes and layout formatting
      let result = if is-multicite {
        let with-affixes = [#prefix#joined#suffix]
        apply-formatting(with-affixes, layout)
      } else {
        // Single citation - render-citation already applied formatting
        joined
      }

      let linked = link(label(make-cite-ref-label(first-key)), result)

      let is-inline-form = (
        form in (CITE-FORM.prose, CITE-FORM.author, CITE-FORM.year)
      )
      let use-footnote = (
        sys.inputs.at("use-footnote", default: "true") == "true"
      )
      if is-inline-form or not use-footnote {
        linked
      } else {
        footnote(linked)
      }
    } else {
      // Numeric style: format as "[1, 2, 3]" or "[1-3]"
      let collapse-mode = style.citation.at("collapse", default: none)

      // Build items with order numbers and entries
      let cite-items = normalized
        .map(item => {
          let entry = bib.at(item.key, default: none)
          let order = citations.order.at(item.key, default: 0)
          (
            key: item.key,
            entry: entry,
            order: order,
            supplement: item.supplement,
          )
        })
        .filter(it => it.entry != none)

      // Render using CSL with collapse support
      let result = if collapse-mode == COLLAPSE.citation-number {
        // Items with locator break collapse - segment by locator presence
        // Each segment without locators can be collapsed, items with locators are standalone
        let segments = ()
        let current-segment = ()

        for item in cite-items {
          if item.supplement != none {
            // Item has locator - flush current segment and add this as standalone
            if current-segment.len() > 0 {
              segments.push((items: current-segment, has-locator: false))
              current-segment = ()
            }
            segments.push((items: (item,), has-locator: true))
          } else {
            current-segment.push(item)
          }
        }
        if current-segment.len() > 0 {
          segments.push((items: current-segment, has-locator: false))
        }

        // Process each segment
        let all-parts = ()
        for seg in segments {
          if seg.has-locator {
            // Single item with locator - render as-is, no collapse
            let item = seg.items.first()
            all-parts.push(render-cite(
              item.entry,
              style,
              supplement: item.supplement,
              cite-number: item.order,
              suppress-affixes: true,
            ))
          } else {
            // Segment without locators - can collapse
            let numbers = seg.items.map(it => it.order)
            let ranges = collapse-numeric-ranges(numbers)

            let parts = process-ranges(
              ranges,
              seg.items,
              it => render-cite(
                it.entry,
                style,
                cite-number: it.order,
                suppress-affixes: true,
              ),
              it => render-cite(
                it.entry,
                style,
                cite-number: it.order,
                suppress-affixes: true,
              ),
              it => render-cite(
                it.entry,
                style,
                cite-number: it.order,
                suppress-affixes: true,
              ),
            )
            all-parts += parts
          }
        }
        _join-cite-parts(all-parts, delimiter)
      } else {
        // No collapse - render each citation fully
        let parts = cite-items.map(item => {
          render-cite(
            item.entry,
            style,
            supplement: item.supplement,
            cite-number: item.order,
            suppress-affixes: normalized.len() > 1,
          )
        })
        _join-cite-parts(parts, delimiter)
      }

      // Apply formatting and link
      let formatted = _apply-affixes(result, prefix, suffix, layout: layout)
      _make-ref-link(formatted, first-key)
    }
  }
}
