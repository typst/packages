// citrus - Number and Label Handlers
//
// Handles <number> and <label> CSL elements.

#import "../core/mod.typ": (
  finalize, fold-superscripts, is-empty, safe-int, zero-pad,
)
#import "../data/variables.typ": get-variable
#import "../parsing/mod.typ": lookup-term
#import "../text/number.typ": get-ordinal-suffix

// Module-level regex patterns (avoid recompilation)
#let _number-pattern = regex("\\d+")
#let _re-digit-dash-roman = regex("\\d.*-.*[ivxlcdmIVXLCDM]")
#let _re-roman-dash = regex("[ivxlcdmIVXLCDM].*-")
#let _re-digit-range = regex("\\d.*[\\-–—].*[A-Za-z0-9]")
#let _re-roman-range = regex("[ivxlcdm]+[\\-–—][ivxlcdm]+")

/// Check if a value string represents plural content (multiple numbers)
///
/// CSL spec: Content is considered plural when it contains multiple numbers
/// (e.g. "pages 1-3", "volumes 2 & 4"), or for number-of-* variables when > 1.
/// Non-numeric content like "Michaelson-Morely" is NOT plural.
#let _is-plural-value(val-str) = {
  if val-str == "" { return false }

  // Find all numbers in the string
  let matches = val-str.matches(_number-pattern)

  // Plural if there are 2+ distinct number occurrences
  // OR if there's a range separator between numbers
  if matches.len() >= 2 {
    true
  } else if matches.len() == 1 {
    // Single number - check if there's a range indicator after it
    // that would imply a range (like roman numerals: "i-ix")
    let has-range-sep = (
      val-str.contains("–")
        or val-str.contains("—")
        or (
          val-str.contains("-") and val-str.match(_re-digit-dash-roman) != none
        )
        or (
          val-str.contains("-") and val-str.match(_re-roman-dash) != none
        )
        or val-str.match(_re-digit-range) != none
    )
    has-range-sep
  } else {
    // No Arabic numbers - check for Roman numeral ranges
    let lower = val-str.replace(" ", "")
    let has-roman-range = (
      lower.match(_re-roman-range) != none
    )
    has-roman-range
  }
}

/// Handle <number> element
#let handle-number(node, ctx, interpret) = {
  let attrs = node.at("attrs", default: (:))
  let var-name = attrs.at("variable", default: "")
  let val = get-variable(ctx, var-name)

  if not is-empty(val) {
    let form = attrs.at("form", default: "numeric")
    let num = safe-int(val)

    let gender-form = ctx
      .at("locale", default: (:))
      .at("term-genders", default: (:))
      .at(var-name, default: none)
    let result = if form == "ordinal" {
      if num != none {
        let suffix = get-ordinal-suffix(num, ctx, gender-form: gender-form)
        let ordinal = str(num) + suffix
        if type(val) == str and val.contains(",") {
          let parts = val.split(",")
          let rest = parts.slice(1).join(",")
          let rest-trim = rest.trim()
          if (
            rest-trim.starts-with("p.")
              and (rest-trim.contains("-") or rest-trim.contains("–"))
          ) {
            rest = rest.replace("p.", "pp.")
          }
          rest = rest.replace("-", "–")
          ordinal + "," + rest
        } else {
          ordinal
        }
      } else { val }
    } else if form == "long-ordinal" {
      if num != none and num >= 1 and num <= 10 {
        let long-ordinal = lookup-term(
          ctx,
          "long-ordinal-" + zero-pad(num, 2),
          form: "long",
          plural: false,
        )
        // Fall back to ordinal if long-ordinal not defined or empty
        if (
          long-ordinal == none
            or long-ordinal == ""
            or long-ordinal.starts-with("long-ordinal-")
        ) {
          str(num) + get-ordinal-suffix(num, ctx, gender-form: gender-form)
        } else {
          long-ordinal
        }
      } else if num != none {
        // CSL spec: long-ordinal falls back to ordinal for numbers > 10
        str(num) + get-ordinal-suffix(num, ctx, gender-form: gender-form)
      } else { val }
    } else if form == "roman" {
      if num != none and num > 0 {
        // Use Typst's built-in numbering for roman numerals
        numbering("i", num)
      } else { val }
    } else {
      // numeric (default)
      if type(val) == str and val.contains("-") {
        val.replace("-", "–")
      } else {
        val
      }
    }

    let folded = if type(result) == str { fold-superscripts(result) } else {
      result
    }
    finalize(folded, attrs)
  } else { [] }
}

// Known locator term names for embedded label detection
#let _locator-terms = (
  "page",
  "volume",
  "chapter",
  "section",
  "paragraph",
  "folio",
  "opus",
  "line",
  "verse",
  "figure",
  "column",
  "note",
  "number",
  "part",
  "sub verbo",
  "issue",
)

/// Check if locator value starts with an embedded label (from current locale)
#let _has-embedded-label(val-str, ctx, form) = {
  if val-str == "" { return false }
  let lower-val = lower(val-str)

  // Check each locator term in both singular and plural forms
  for term-name in _locator-terms {
    // Get term from locale
    let term-long = lookup-term(ctx, term-name, form: "long", plural: false)
    let term-long-pl = lookup-term(ctx, term-name, form: "long", plural: true)
    let term-short = lookup-term(ctx, term-name, form: "short", plural: false)
    let term-short-pl = lookup-term(ctx, term-name, form: "short", plural: true)

    for term in (term-long, term-long-pl, term-short, term-short-pl) {
      if term != none and term != "" and lower-val.starts-with(lower(term)) {
        return true
      }
    }
  }
  false
}

/// Handle <label> element
#let handle-label(node, ctx, interpret) = {
  let attrs = node.at("attrs", default: (:))
  let var-name = attrs.at("variable", default: "")
  let form = attrs.at("form", default: "long")

  // Only render label if variable has value
  let val = get-variable(ctx, var-name)
  if is-empty(val) {
    []
  } else {
    let val-str = if type(val) == str { val } else { "" }

    // For locator: skip label if value already has embedded label
    // e.g., locator="vol. 1, fol. 186" already contains "vol." label
    if var-name == "locator" and _has-embedded-label(val-str, ctx, form) {
      return []
    }

    // Determine plurality based on value content
    // CSL spec: Content is plural when it contains multiple numbers
    // (e.g. "pages 1-3", "volumes 2 & 4")
    // Non-numeric content like "Michaelson-Morely" is NOT plural
    // Special case: number-of-* variables are plural when value > 1
    let plural = if var-name.starts-with("number-of-") {
      let num = safe-int(val-str)
      num != none and num > 1
    } else {
      _is-plural-value(val-str)
    }
    let plural-attr = attrs.at("plural", default: "contextual")
    let plural = if plural-attr == "always" {
      true
    } else if plural-attr == "never" {
      false
    } else {
      plural
    }

    // CSL spec: for locator variable, use locator-label to determine the term
    // e.g., locator-label="page" → lookup term "page" → "p." or "pp."
    let term-name = if var-name == "locator" {
      let label = ctx.at("locator-label", default: "page")
      if type(label) == str and label.contains(" ") {
        label.replace(" ", "-")
      } else {
        label
      }
    } else {
      var-name
    }

    let result = lookup-term(ctx, term-name, form: form, plural: plural)
    let term-str = if result != none { result } else { "" }
    finalize(term-str, attrs)
  }
}
