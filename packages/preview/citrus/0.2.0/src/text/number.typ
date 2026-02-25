// citrus - Number Text Helpers
//
// Shared number formatting helpers used by interpreter and compiler.

#import "../core/mod.typ": zero-pad
#import "../parsing/mod.typ": create-fallback-locale, lookup-term

/// Get ordinal suffix for a number according to CSL spec
///
/// CSL ordinal priority:
/// 1. ordinal-10 through ordinal-99: last-two-digits matching (higher priority)
/// 2. ordinal-00 through ordinal-09: last-digit matching
/// 3. ordinal: generic fallback
///
/// - num: The number to get ordinal for
/// - ctx: Context with locale terms
/// - gender-form: Optional gender form ("masculine" or "feminine")
/// Returns: Ordinal suffix string
#let get-ordinal-suffix(num, ctx, gender-form: none) = {
  let abs-num = calc.abs(num)
  let last-two = calc.rem(abs-num, 100)
  let last-one = calc.rem(abs-num, 10)
  let gender-forms = (:)
  if gender-form != none {
    gender-forms = ctx
      .at("locale", default: (:))
      .at("ordinal-gender-forms", default: (:))
    if gender-forms.len() == 0 {
      let lang = ctx
        .at("style", default: (:))
        .at(
          "default-locale",
          default: "en-US",
        )
      gender-forms = create-fallback-locale(lang).at(
        "ordinal-gender-forms",
        default: (:),
      )
    }
  }

  // Try ordinal-10 through ordinal-99 first (last-two-digits matching by default)
  if last-two >= 10 {
    let key = "ordinal-" + zero-pad(last-two, 2)
    if gender-form != none and key + ":" + gender-form in gender-forms {
      return gender-forms.at(key + ":" + gender-form)
    }
    let suffix = lookup-term(ctx, key, form: "long", plural: false)
    if suffix != none and suffix != "" and suffix != key {
      return suffix
    }
  }

  // Try ordinal-00 through ordinal-09 (last-digit matching by default)
  let single-key = "ordinal-" + zero-pad(last-one, 2)
  if gender-form != none and single-key + ":" + gender-form in gender-forms {
    return gender-forms.at(single-key + ":" + gender-form)
  }
  let single-suffix = lookup-term(ctx, single-key, form: "long", plural: false)
  if (
    single-suffix != none
      and single-suffix != ""
      and single-suffix != single-key
  ) {
    return single-suffix
  }

  // Fallback to generic ordinal term
  let generic = lookup-term(ctx, "ordinal", form: "long", plural: false)
  if generic != none { generic } else { "" }
}
