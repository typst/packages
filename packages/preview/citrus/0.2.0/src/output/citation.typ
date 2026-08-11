// citrus - Citation Rendering Module
//
// Functions for rendering in-text citations.

#import "../core/constants.typ": POSITION, RENDER-CONTEXT, STYLE-CLASS
#import "../core/formatting.typ": apply-formatting
#import "../core/utils.typ": capitalize-first-char, is-empty
#import "../data/collapsing.typ": num-to-suffix
#import "helpers.typ": content-to-string
#import "../interpreter/mod.typ": create-context
#import "../interpreter/stack.typ": interpret-children-stack
#import "../parsing/mod.typ": detect-language
#import "../text/names.typ": format-names
#import "layout.typ": select-layout

// Check if a layout contains any position conditions
#let _layout-has-position(nodes, targets) = {
  for node in nodes {
    if type(node) == dictionary {
      let attrs = node.at("attrs", default: (:))
      if "position" in attrs {
        let positions = if type(attrs.position) == str {
          attrs.position.split(" ")
        } else {
          attrs.position
        }
        if positions.any(p => targets.any(t => t == p)) { return true }
      }
      let kids = node.at("children", default: ())
      if kids.len() > 0 and _layout-has-position(kids, targets) { return true }
    }
  }
  false
}

// =============================================================================
// Citation Rendering
// =============================================================================

/// Render an in-text citation
///
/// - entry: Bibliography entry
/// - style: Parsed CSL style
/// - form: Citation form (none, "normal", "prose", "author", "year")
/// - supplement: Page number or other supplement
/// - cite-number: Citation number (for numeric styles)
/// - year-suffix: Year suffix for disambiguation
/// - position: Citation position ("first", "subsequent", "ibid", "ibid-with-locator")
/// - suppress-affixes: If true, don't apply prefix/suffix (for multi-cite contexts)
/// - first-note-number: Note number where this citation first appeared (for ibid/subsequent)
/// - needs-disambiguate: If true, disambiguate condition returns true (CSL method 3)
/// Returns: Typst content
#let render-citation(
  entry,
  style,
  form: none,
  supplement: none,
  locator-label: "page",
  cite-number: none,
  year-suffix: none,
  position: POSITION.first,
  suppress-affixes: false,
  suppress-author: false,
  suppress-year: false,
  first-note-number: none,
  abbreviations: (:),
  names-expanded: 0,
  givenname-level: 0,
  givenname-levels: (),
  needs-disambiguate: false,
) = {
  let effective-position = if (
    form == "prose"
      and style.class == STYLE-CLASS.in-text
      and position == POSITION.first
  ) {
    POSITION.subsequent
  } else {
    position
  }

  let ctx = create-context(
    style,
    entry,
    cite-number: cite-number,
    abbreviations: abbreviations,
    disambiguate: needs-disambiguate,
  )

  let normalized-year-suffix = if year-suffix == none {
    ""
  } else if type(year-suffix) == int {
    num-to-suffix(year-suffix)
  } else {
    str(year-suffix)
  }

  // Set suppress flags in context for CSL interpreter
  if suppress-author {
    ctx = (..ctx, suppress-author: true)
  }
  if suppress-year {
    ctx = (..ctx, suppress-year: true)
  }

  // Inject locator into fields if provided
  // CSL spec: locator is rendered via <text variable="locator"/>
  // Supports both structured locator (via metadata) and plain content
  // Also extract citation-item prefix/suffix if present
  let cite-item-prefix = ""
  let cite-item-suffix = ""

  if supplement != none {
    let parsed-label = locator-label
    let parsed-value = ""

    let parse-locator-fields(fields) = {
      if "label" in fields and "value" in fields {
        (
          ok: true,
          label: fields.at("label", default: "page"),
          value: fields.at("value", default: ""),
          prefix: fields.at("prefix", default: ""),
          suffix: fields.at("suffix", default: ""),
        )
      } else if "value" in fields {
        let val = fields.value
        if (
          type(val) == dictionary
            and (
              val.at("_citrus-locator", default: false)
                or ("label" in val and "value" in val)
            )
        ) {
          (
            ok: true,
            label: val.at("label", default: "page"),
            value: val.at("value", default: ""),
            prefix: val.at("prefix", default: ""),
            suffix: val.at("suffix", default: ""),
          )
        } else if type(val) == content {
          parse-locator-fields(val.fields())
        } else {
          (ok: false)
        }
      } else {
        (ok: false)
      }
    }

    if type(supplement) == content {
      // Check if it's a structured locator (metadata wrapper)
      let fields = supplement.fields()
      let parsed = parse-locator-fields(fields)
      if parsed.ok {
        parsed-label = parsed.label
        if type(parsed-label) == str and parsed-label.contains(" ") {
          parsed-label = parsed-label.replace(" ", "-")
        }
        parsed-value = str(parsed.value)
        cite-item-prefix = parsed.prefix
        cite-item-suffix = parsed.suffix
      } else {
        let sup-repr = repr(supplement)
        parsed-value = sup-repr
          .replace("\"", "")
          .replace("[", "")
          .replace("]", "")
      }
    } else {
      parsed-value = str(supplement)
    }

    // Trim whitespace from locator value
    let trimmed-value = parsed-value.trim()
    if trimmed-value != "" {
      let new-fields = (..ctx.fields, locator: trimmed-value)
      ctx = (..ctx, fields: new-fields, locator-label: parsed-label)
    }
  }

  let citation = style.citation
  if citation == none or citation.at("layouts", default: ()).len() == 0 {
    return text(fill: red, "[No citation layout]")
  }

  // CSL-M: Set render-context for context condition
  // Also pass et-al-subsequent settings for subsequent cites
  // CSL spec: has-explicit-year-suffix determines if year-suffix is auto-appended to dates
  let ctx = (
    ..ctx,
    year-suffix: normalized-year-suffix,
    position: effective-position,
    first-reference-note-number: if first-note-number != none {
      str(first-note-number)
    } else { "" },
    // Disambiguation state for name rendering
    names-expanded: names-expanded,
    givenname-level: givenname-level,
    givenname-levels: givenname-levels,
    render-context: RENDER-CONTEXT.citation,
    style-class: style.class,
    // Et-al settings for subsequent cites (CSL spec: inheritable name options)
    et-al-subsequent-min: citation.at("et-al-subsequent-min", default: none),
    et-al-subsequent-use-first: citation.at(
      "et-al-subsequent-use-first",
      default: none,
    ),
    citation-et-al-min: citation.at("et-al-min", default: none),
    citation-et-al-use-first: citation.at("et-al-use-first", default: none),
    // Name formatting options (inheritable from citation level)
    citation-and: citation.at("and", default: none),
    citation-name-delimiter: citation.at("name-delimiter", default: none),
    citation-delimiter-precedes-et-al: citation.at(
      "delimiter-precedes-et-al",
      default: none,
    ),
    citation-delimiter-precedes-last: citation.at(
      "delimiter-precedes-last",
      default: none,
    ),
    has-explicit-year-suffix: citation.at(
      "has-explicit-year-suffix",
      default: false,
    ),
  )

  // CSL-M: Select layout based on entry language
  let entry-lang = detect-language(entry.at("fields", default: (:)))
  let layout = select-layout(citation.layouts, entry-lang)

  // CSL-M: Switch locale if layout has explicit locale attribute
  let layout-locale = layout.at("locale", default: none)
  if layout-locale != none {
    let locales = style.at("locales", default: (:))
    let locale-code = layout-locale.split(" ").first()
    let target-locale = locales.at(locale-code, default: none)
    if target-locale == none {
      let prefix = if locale-code.len() >= 2 { locale-code.slice(0, 2) } else {
        locale-code
      }
      target-locale = locales.at(prefix, default: none)
    }
    if target-locale != none {
      ctx = (..ctx, locale: target-locale)
    }
  }

  // If layout has no ibid logic, treat ibid positions as subsequent
  let has-ibid = _layout-has-position(
    layout.children,
    (POSITION.ibid, POSITION.ibid-with-locator),
  )
  if (
    effective-position in (POSITION.ibid, POSITION.ibid-with-locator)
      and not has-ibid
  ) {
    effective-position = POSITION.subsequent
    ctx = (..ctx, position: effective-position)
  }

  // Render citation layout
  // Use compiled function if available, otherwise fall back to interpreter
  let result = {
    let compiled = style.at("compiled", default: none)
    let use-compiler = sys.inputs.at("compiler", default: "false") == "true"
    let missing-issued = (
      ctx.fields.at("year", default: "") == ""
        and ctx.fields.at("month", default: "") == ""
        and ctx.fields.at("day", default: "") == ""
        and ctx.fields.at("date", default: "") == ""
        and ctx.fields.at("season", default: "") == ""
        and ctx.fields.at("literal", default: "") == ""
    )
    if (
      missing-issued
        and citation.at("disambiguate-add-year-suffix", default: false) == true
    ) {
      use-compiler = false
    }
    if compiled != none and use-compiler {
      // Add compiled macros to context for macro calls
      let ctx = (..ctx, compiled-macros: compiled.macros, done-vars: ())
      let (content, _state, _done, _ends) = (compiled.citation)(ctx)
      content
    } else {
      // Fall back to stack-based interpreter
      interpret-children-stack(layout.children, ctx, delimiter: "")
    }
  }

  if is-empty(result) {
    return "[CSL STYLE ERROR: reference with no printed form.]"
  }

  // Apply citation-item level prefix/suffix (from locator metadata)
  // CSL spec: these go INSIDE the layout prefix/suffix
  if cite-item-prefix != "" and type(result) == str {
    let trimmed-prefix = cite-item-prefix.trim()
    let words = trimmed-prefix.split(" ").filter(w => w != "")
    if trimmed-prefix.ends-with(".") and words.len() > 1 {
      result = capitalize-first-char(result)
    }
  }
  if cite-item-prefix != "" or cite-item-suffix != "" {
    result = [#cite-item-prefix#result#cite-item-suffix]
  }

  // Handle form variations
  let final-result = if form == "author" {
    // Extract author only - use standard name formatter
    let names = ctx.parsed-names.at("author", default: ())
    if names.len() > 0 {
      // Use default name formatting attributes
      let name-attrs = (
        form: "long",
        name-as-sort-order: none,
        sort-separator: ", ",
        delimiter: ", ",
        "and": "text",
      )
      format-names(names, name-attrs, ctx)
    } else {
      "?"
    }
  } else if form == "year" {
    let year = ctx.fields.at("year", default: "n.d.")
    str(year) + normalized-year-suffix
  } else if form == "prose" {
    // Prose form: inline text without superscript/subscript
    // Note: locator is now rendered via CSL's <text variable="locator"/>,
    // so we don't manually append supplement here anymore

    // Apply prefix/suffix but NOT vertical-align (unless suppressed for multi-cite)
    let formatted = if suppress-affixes {
      result
    } else {
      let prefix = layout.prefix
      let suffix = layout.suffix
      [#prefix#result#suffix]
    }

    // Apply font formatting only when not suppressed
    // (multicite applies layout formatting at the outer level)
    if suppress-affixes {
      formatted
    } else {
      apply-formatting(formatted, layout)
    }
  } else {
    // Default form: apply all formatting
    // Note: locator is now rendered via CSL's <text variable="locator"/>

    // When suppress-affixes is true, return raw result for multicite to wrap
    if suppress-affixes {
      result
    } else {
      // Apply prefix/suffix
      let prefix = layout.prefix
      let suffix = layout.suffix
      let formatted = [#prefix#result#suffix]

      // Apply vertical-align (superscript/subscript)
      let valign = layout.at("vertical-align", default: none)
      let with-valign = if valign == "sup" {
        super(formatted)
      } else if valign == "sub" {
        sub(formatted)
      } else {
        formatted
      }

      // Apply font formatting (font-weight, font-style)
      apply-formatting(with-valign, layout)
    }
  }

  let final-text = content-to-string(final-result)
  if final-text == "and" {
    return "And"
  }

  if type(final-result) == str and final-result.len() > 0 {
    let trimmed = final-result.trim()
    if (
      trimmed.starts-with("and")
        and (
          trimmed.len() == 3
            or trimmed.at(3) == " "
            or trimmed.at(3) == "."
            or trimmed.at(3) == ","
        )
    ) {
      return capitalize-first-char(final-result)
    }
  }

  final-result
}
