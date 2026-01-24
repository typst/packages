// citeproc-typst - Number and Label Handlers
//
// Handles <number> and <label> CSL elements.

#import "../core/mod.typ": finalize, is-empty, zero-pad
#import "../data/variables.typ": get-variable
#import "../parsing/locales.typ": lookup-term

// Module-level regex pattern
#let _leading-int-pattern = regex("^-?\\d+")

/// Safely parse an integer from a string (returns none on failure)
#let safe-int(s) = {
  let s = str(s)
  // Extract leading digits only
  let m = s.match(_leading-int-pattern)
  if m != none { int(m.text) } else { none }
}

/// Get ordinal suffix for a number according to CSL spec
///
/// CSL ordinal priority:
/// 1. ordinal-10 through ordinal-99: last-two-digits matching (higher priority)
/// 2. ordinal-00 through ordinal-09: last-digit matching
/// 3. ordinal: generic fallback
///
/// Match modes:
/// - whole-number: exact match
/// - last-two-digits: match last two digits (default for 10-99)
/// - last-digit: match last digit (default for 00-09)
///
/// - num: The number to get ordinal for
/// - ctx: Context with locale terms
/// - gender-form: Optional gender form ("masculine" or "feminine")
/// Returns: Ordinal suffix string
#let _get-ordinal-suffix(num, ctx, gender-form: none) = {
  let abs-num = calc.abs(num)
  let last-two = calc.rem(abs-num, 100)
  let last-one = calc.rem(abs-num, 10)

  // Try ordinal-10 through ordinal-99 first (last-two-digits matching by default)
  if last-two >= 10 {
    let key = "ordinal-" + zero-pad(last-two, 2)
    let suffix = lookup-term(ctx, key, form: "long", plural: false)
    if suffix != "" and suffix != key {
      return suffix
    }
  }

  // Try ordinal-00 through ordinal-09 (last-digit matching by default)
  let single-key = "ordinal-" + zero-pad(last-one, 2)
  let single-suffix = lookup-term(ctx, single-key, form: "long", plural: false)
  if single-suffix != "" and single-suffix != single-key {
    return single-suffix
  }

  // Fallback to generic ordinal term
  lookup-term(ctx, "ordinal", form: "long", plural: false)
}

/// Handle <number> element
#let handle-number(node, ctx, interpret) = {
  let attrs = node.at("attrs", default: (:))
  let var-name = attrs.at("variable", default: "")
  let val = get-variable(ctx, var-name)

  if not is-empty(val) {
    let form = attrs.at("form", default: "numeric")
    let num = safe-int(val)

    let result = if form == "ordinal" {
      if num != none {
        let suffix = _get-ordinal-suffix(num, ctx)
        str(num) + suffix
      } else { val }
    } else if form == "long-ordinal" {
      if num != none and num >= 1 and num <= 10 {
        let long-ordinal = lookup-term(
          ctx,
          "long-ordinal-" + zero-pad(num, 2),
          form: "long",
          plural: false,
        )
        // Fall back to ordinal if long-ordinal not defined
        if long-ordinal == "" or long-ordinal.starts-with("long-ordinal-") {
          str(num) + _get-ordinal-suffix(num, ctx)
        } else {
          long-ordinal
        }
      } else if num != none {
        // CSL spec: long-ordinal falls back to ordinal for numbers > 10
        str(num) + _get-ordinal-suffix(num, ctx)
      } else { val }
    } else if form == "roman" {
      if num != none and num > 0 {
        // Use Typst's built-in numbering for roman numerals
        numbering("i", num)
      } else { val }
    } else {
      // numeric (default)
      val
    }

    finalize(result, attrs)
  } else { [] }
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
    // Determine plurality based on value content
    let val-str = if type(val) == str { val } else { "" }
    let plural = (
      val-str.contains("-")
        or val-str.contains(",")
        or val-str.contains("–")
        or val-str.contains(" ")
    )

    let result = lookup-term(ctx, var-name, form: form, plural: plural)
    finalize(result, attrs)
  }
}
