// citrus - Compiler Runtime: Text/Variable

#import "../../core/mod.typ": (
  apply-text-case, finalize, fold-superscripts, is-empty,
)
#import "../../text/quotes.typ": apply-quotes, transform-quotes-at-level
#import "../../output/punctuation.typ": get-punctuation-in-quote

// Module-level regex patterns (avoid recompilation)
#let _re-quote-chars = regex("[\"\u{201C}\u{201D}]")
#let _re-single-quotes = regex("[\u{2018}\u{2019}']")
#let _re-double-quotes = regex("[\u{201C}\u{201D}\"]")
#let _re-rsq-rdq-end = regex("\u{2019}\u{201D}$")
#let _re-rdq-end = regex("\u{201D}$")

#let _fix-inner-quotes(text, ctx, quote-level, has-quotes) = {
  if not has-quotes { return text }
  if type(text) != str {
    let fields = text.fields()
    if text.func() == text {
      let body = fields.at("text", default: fields.at("body", default: none))
      if (
        type(body) == str and body.match(_re-quote-chars) != none
      ) {
        let normalized = transform-quotes-at-level(body, ctx, 1)
        return text(normalized)
      }
    }
    return text
  }
  if text.match(_re-quote-chars) == none { return text }
  transform-quotes-at-level(text, ctx, 1)
}
#import "../../text/ranges.typ": format-number-range, format-page-range
#import "../../data/variables.typ": get-variable

/// Get raw text variable without formatting/affixes
///
/// - plan: Dictionary with cached fields (var, form)
#let get-text-variable-raw(ctx, attrs, plan) = {
  let var-name = plan.at("var", default: attrs.at("variable", default: ""))
  let form = plan.at("form", default: attrs.at("form", default: "long"))

  // Check if already rendered (done-vars quashing)
  if var-name in ctx.at("done-vars", default: ()) {
    return ([], "none", (), false)
  }

  // Special handling for year-suffix - it's in ctx, not ctx.fields
  if var-name == "year-suffix" {
    let suffix = ctx.at("year-suffix", default: none)
    if suffix != none and suffix != "" {
      import "../../data/collapsing.typ": num-to-suffix
      let suffix-str = if type(suffix) == int {
        num-to-suffix(suffix)
      } else {
        str(suffix)
      }
      let ends = suffix-str.ends-with(".")
      return (suffix-str, "var", (), ends)
    } else {
      return ([], "var", (), false)
    }
  }

  // CSL form="short": try variable-short first, fallback to variable
  let val = if form == "short" {
    let short-name = var-name + "-short"
    let short-val = get-variable(ctx, short-name)
    if short-val != "" { short-val } else { get-variable(ctx, var-name) }
  } else {
    get-variable(ctx, var-name)
  }

  if val != "" {
    let normalized = if type(val) == str and "style" in ctx {
      let quote-level = ctx.at("quote-level", default: 0)
      let fixed = transform-quotes-at-level(val, ctx, quote-level)
      fixed.replace(
        regex(
          "(^|[\\s\\(\\[])[\u{2018}\u{2019}']([^'\u{2018}\u{2019}]+)[\u{2018}\u{2019}']",
        ),
        m => (
          m.captures.at(0) + "\"" + m.captures.at(1) + "\""
        ),
      )
    } else {
      val
    }
    let ends = if type(normalized) == str { normalized.ends-with(".") } else {
      false
    }
    (normalized, "var", (), ends)
  } else {
    ([], "no-var", (), false)
  }
}

/// Get text variable value using a precomputed plan
///
/// - plan: Dictionary with cached fields (var, form, is-page-like, has-quotes)
#let get-text-variable-planned(ctx, attrs, plan) = {
  let var-name = plan.at("var", default: attrs.at("variable", default: ""))
  let form = plan.at("form", default: attrs.at("form", default: "long"))
  let is-page-like = plan.at("is-page-like", default: false)
  let has-quotes = plan.at(
    "has-quotes",
    default: attrs.at("quotes", default: "false") == "true",
  )

  // Check if already rendered (done-vars quashing)
  if var-name in ctx.at("done-vars", default: ()) {
    return ([], "none", (), false)
  }

  // Special handling for year-suffix - it's in ctx, not ctx.fields
  if var-name == "year-suffix" {
    let suffix = ctx.at("year-suffix", default: none)
    if suffix != none and suffix != "" {
      import "../../data/collapsing.typ": num-to-suffix
      let suffix-str = if type(suffix) == int {
        num-to-suffix(suffix)
      } else {
        str(suffix)
      }
      let ends = suffix-str.ends-with(".")
      let final-attrs = (..attrs, "_ends-with-period": ends)
      return (finalize(suffix-str, final-attrs), "var", (), ends)
    } else {
      return ([], "var", (), false)
    }
  }

  // CSL form="short": try variable-short first, fallback to variable
  let val = if form == "short" {
    let short-name = var-name + "-short"
    let short-val = get-variable(ctx, short-name)
    if short-val != "" { short-val } else { get-variable(ctx, var-name) }
  } else {
    // Get value using get-variable which handles field name mapping
    get-variable(ctx, var-name)
  }

  if val != "" {
    // Format page ranges for page/page-first; locator uses expanded
    let formatted = if is-page-like {
      if var-name == "locator" {
        format-page-range(val, format: "expanded", ctx: ctx)
      } else {
        let page-format = if "style" in ctx {
          ctx.style.at("page-range-format", default: none)
        } else { none }
        format-page-range(val, format: page-format, ctx: ctx)
      }
    } else { val }

    // Apply text-case FIRST while content is still a string
    let cased = if plan.at("has-text-case", default: false) {
      apply-text-case(formatted, attrs, ctx: ctx)
    } else {
      formatted
    }

    // Handle quotes (CSL quote flipflopping)
    let quote-level = ctx.at("quote-level", default: 0)
    let has-single = cased.match(_re-single-quotes) != none
    let has-double = cased.match(_re-double-quotes) != none
    let effective-level = if (
      not has-quotes and quote-level == 1 and has-single and not has-double
    ) { 0 } else { quote-level }

    // Normalize embedded quotes in content (only if ctx.style is available)
    let normalized = if type(cased) == str and "style" in ctx {
      if has-quotes {
        transform-quotes-at-level(cased, ctx, effective-level + 1)
      } else {
        transform-quotes-at-level(cased, ctx, effective-level)
      }
    } else { cased }
    let normalized = if type(normalized) == str {
      normalized.replace(
        regex(
          "(^|[\\s\\(\\[])[\u{2018}\u{2019}']([^'\u{2018}\u{2019}]+)[\u{2018}\u{2019}']",
        ),
        m => (
          m.captures.at(0) + "\"" + m.captures.at(1) + "\""
        ),
      )
    } else { normalized }

    let fixed = _fix-inner-quotes(normalized, ctx, quote-level, has-quotes)
    // Apply quotes if requested (only if ctx.style is available)
    let quoted = if has-quotes and "style" in ctx {
      apply-quotes(fixed, ctx, level: quote-level)
    } else { fixed }

    let ends = if type(quoted) == str { quoted.ends-with(".") } else { false }
    if (
      not plan.at("has-affixes", default: false)
        and not plan.at("has-strip-periods", default: false)
        and not plan.at("has-formatting", default: false)
    ) {
      (quoted, "var", (), ends)
    } else {
      let final-attrs = if type(quoted) == str {
        (..attrs, "_ends-with-period": ends)
      } else { attrs }
      (finalize(quoted, final-attrs), "var", (), ends)
    }
  } else {
    ([], "no-var", (), false)
  }
}

/// Format <text value="..."> without formatting/affixes
#let format-text-value-raw(ctx, attrs, plan) = {
  let value = attrs.at("value", default: "")
  if value == "" { return ([], "none", (), false) }
  let folded = fold-superscripts(value)
  if type(folded) != str {
    return (folded, "none", (), false)
  }
  let ends = if type(folded) == str { folded.ends-with(".") } else { false }
  (folded, "none", (), ends)
}

/// Get text variable value
///
/// - ctx: Context dictionary with fields and done-vars
/// - attrs: Dictionary of CSL attributes (variable, form, etc.)
/// Returns: (content, var-state, done-vars) tuple
#let get-text-variable(ctx, attrs) = {
  let var-name = attrs.at("variable", default: "")
  let form = attrs.at("form", default: "long")

  // Check if already rendered (done-vars quashing)
  if var-name in ctx.at("done-vars", default: ()) {
    return ([], "none", (), false)
  }

  // Special handling for year-suffix - it's in ctx, not ctx.fields
  if var-name == "year-suffix" {
    let suffix = ctx.at("year-suffix", default: none)
    if suffix != none and suffix != "" {
      import "../../data/collapsing.typ": num-to-suffix
      let suffix-str = if type(suffix) == int {
        num-to-suffix(suffix)
      } else {
        str(suffix)
      }
      let ends = suffix-str.ends-with(".")
      let final-attrs = (..attrs, "_ends-with-period": ends)
      return (finalize(suffix-str, final-attrs), "var", (), ends)
    } else {
      return ([], "no-var", (), false)
    }
  }

  // CSL form="short": try variable-short first, fallback to variable
  let val = if form == "short" {
    let short-name = var-name + "-short"
    let short-val = get-variable(ctx, short-name)
    if short-val != "" { short-val } else { get-variable(ctx, var-name) }
  } else {
    // Get value using get-variable which handles field name mapping
    get-variable(ctx, var-name)
  }

  if val != "" {
    // Format page ranges for page/page-first; locator uses expanded
    let formatted = if var-name == "page" or var-name == "page-first" {
      let page-format = if "style" in ctx {
        ctx.style.at("page-range-format", default: none)
      } else { none }
      format-page-range(val, format: page-format, ctx: ctx)
    } else if var-name == "locator" {
      format-page-range(val, format: "expanded", ctx: ctx)
    } else if var-name == "issue" {
      format-number-range(val, ctx: ctx)
    } else { val }

    // Apply text-case FIRST while content is still a string
    let cased = apply-text-case(formatted, attrs, ctx: ctx)
    let folded = fold-superscripts(cased)

    // Handle quotes (CSL quote flipflopping)
    let quote-level = ctx.at("quote-level", default: 0)
    let quotes-attr = attrs.at("quotes", default: "false")
    let has-quotes = if type(quotes-attr) == bool {
      quotes-attr
    } else {
      quotes-attr == "true"
    }

    // Normalize embedded quotes in content (only if ctx.style is available)
    if type(folded) != str {
      let final-attrs = attrs
      return (finalize(folded, final-attrs), "var", (), false)
    }

    let normalized = if type(cased) == str and "style" in ctx {
      if has-quotes {
        transform-quotes-at-level(cased, ctx, quote-level + 1)
      } else {
        transform-quotes-at-level(cased, ctx, quote-level)
      }
    } else { cased }

    let fixed = _fix-inner-quotes(normalized, ctx, quote-level, has-quotes)
    // Apply quotes if requested (only if ctx.style is available)
    let quoted = if has-quotes and "style" in ctx {
      apply-quotes(fixed, ctx, level: quote-level)
    } else { fixed }

    let ends = if type(quoted) == str { quoted.ends-with(".") } else { false }
    let final-attrs = if type(quoted) == str {
      (..attrs, "_ends-with-period": ends)
    } else { attrs }
    (finalize(quoted, final-attrs), "var", (), ends)
  } else {
    ([], "no-var", (), false)
  }
}

/// Apply text-case and quotes to generic text content
#let format-text-content(ctx, content, attrs) = {
  if is-empty(content) { return ([], false) }

  let quote-level = ctx.at("quote-level", default: 0)
  let quotes-attr = attrs.at("quotes", default: "false")
  let has-quotes = if type(quotes-attr) == bool {
    quotes-attr
  } else {
    quotes-attr == "true"
  }

  let suffix = attrs.at("suffix", default: "")
  let punctuation-in-quote = if "style" in ctx {
    get-punctuation-in-quote(ctx.style)
  } else { false }

  let quote-punct = if (
    has-quotes
      and punctuation-in-quote
      and suffix.len() > 0
      and suffix.first() in (".", ",", "!", "?")
  ) {
    suffix.first()
  } else { "" }

  let adjusted-attrs = if quote-punct != "" {
    (..attrs, suffix: suffix.slice(1))
  } else {
    attrs
  }

  let processed = if type(content) == str {
    let value = if (
      quote-punct != "" and not content.ends-with(quote-punct)
    ) {
      content + quote-punct
    } else { content }
    let cased = apply-text-case(value, adjusted-attrs, ctx: ctx)
    let folded = fold-superscripts(cased)
    let normalized = if type(folded) == str and has-quotes {
      transform-quotes-at-level(folded, ctx, quote-level + 1)
    } else if type(folded) == str {
      transform-quotes-at-level(folded, ctx, quote-level)
    } else {
      folded
    }
    let fixed = _fix-inner-quotes(normalized, ctx, quote-level, has-quotes)
    let quoted = if has-quotes and type(fixed) == str {
      apply-quotes(fixed, ctx, level: quote-level)
    } else { fixed }
    quoted
  } else {
    let quoted = if has-quotes {
      apply-quotes(content, ctx, level: quote-level)
    } else {
      content
    }
    if type(quoted) != str and quoted.func() == text {
      let body = quoted
        .fields()
        .at(
          "text",
          default: quoted.fields().at("body", default: ""),
        )
      if type(body) == str and body != "" {
        quoted = body
      }
    }
    if quote-punct != "" and quoted.func() == text {
      let fields = quoted.fields()
      let body = fields.at("text", default: fields.at("body", default: none))
      if type(body) == str and body.ends-with("\u{201D}") {
        let updated = if (
          quote-punct == "." and body.ends-with("\u{2019}\u{201D}")
        ) {
          body.replace(_re-rsq-rdq-end, ".\u{2019}\u{201D}")
        } else {
          body.replace(_re-rdq-end, quote-punct + "\u{201D}")
        }
        quoted = text(updated)
      }
    }
    quoted
  }

  let ends = if type(processed) == str { processed.ends-with(".") } else {
    false
  }
  let adjusted-attrs = if type(processed) == str {
    (..adjusted-attrs, "_ends-with-period": ends)
  } else { adjusted-attrs }

  (finalize(processed, adjusted-attrs), ends)
}

/// Format <text value="..."> with quotes/text-case
#let format-text-value(ctx, attrs) = {
  let value = attrs.at("value", default: "")
  let (content, ends) = format-text-content(ctx, value, attrs)
  (content, "none", (), ends)
}
