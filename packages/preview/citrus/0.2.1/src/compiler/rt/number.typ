// citrus - Compiler Runtime: Number

#import "../../interpreter/number.typ": handle-number as _handle-number
#import "../../core/mod.typ": (
  finalize, fold-superscripts, is-empty, safe-int, zero-pad,
)
#import "../../parsing/mod.typ": lookup-term
#import "../../text/number.typ": get-ordinal-suffix
#import "../../data/variables.typ": get-variable

/// Format number from a CSL <number> element
#let format-number-numeric-compiled(ctx, attrs) = {
  let var-name = attrs.at("variable", default: "")
  let val = get-variable(ctx, var-name)
  if is-empty(val) {
    ([], "no-var", (), false)
  } else {
    let rendered = if type(val) == str and val.contains("-") {
      val.replace("-", "–")
    } else { val }
    let ends = if type(rendered) == str { rendered.ends-with(".") } else {
      false
    }
    let final-attrs = if type(rendered) == str {
      (..attrs, "_ends-with-period": ends)
    } else { attrs }
    (finalize(rendered, final-attrs), "var", (), ends)
  }
}

#let format-number-ordinal-compiled(ctx, attrs) = {
  let var-name = attrs.at("variable", default: "")
  let val = get-variable(ctx, var-name)
  if is-empty(val) {
    ([], "no-var", (), false)
  } else {
    let gender-form = ctx
      .at("locale", default: (:))
      .at("term-genders", default: (:))
      .at(var-name, default: none)
    let num = safe-int(val)
    let result = if num != none {
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
    let folded = if type(result) == str { fold-superscripts(result) } else {
      result
    }
    let ends = if type(folded) == str { folded.ends-with(".") } else { false }
    let final-attrs = if type(result) == str {
      (..attrs, "_ends-with-period": ends)
    } else { attrs }
    (finalize(folded, final-attrs), "var", (), ends)
  }
}

#let format-number-long-ordinal-compiled(ctx, attrs) = {
  let var-name = attrs.at("variable", default: "")
  let val = get-variable(ctx, var-name)
  if is-empty(val) {
    ([], "no-var", (), false)
  } else {
    let gender-form = ctx
      .at("locale", default: (:))
      .at("term-genders", default: (:))
      .at(var-name, default: none)
    let num = safe-int(val)
    let result = if num != none and num >= 1 and num <= 10 {
      let long-ordinal = lookup-term(
        ctx,
        "long-ordinal-" + zero-pad(num, 2),
        form: "long",
        plural: false,
      )
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
      str(num) + get-ordinal-suffix(num, ctx, gender-form: gender-form)
    } else { val }
    let folded = if type(result) == str { fold-superscripts(result) } else {
      result
    }
    let ends = if type(folded) == str { folded.ends-with(".") } else { false }
    let final-attrs = if type(result) == str {
      (..attrs, "_ends-with-period": ends)
    } else { attrs }
    (finalize(folded, final-attrs), "var", (), ends)
  }
}

#let format-number-roman-compiled(ctx, attrs) = {
  let var-name = attrs.at("variable", default: "")
  let val = get-variable(ctx, var-name)
  if is-empty(val) {
    ([], "no-var", (), false)
  } else {
    let num = safe-int(val)
    let result = if num != none and num > 0 {
      numbering("i", num)
    } else { val }
    let ends = if type(result) == str { result.ends-with(".") } else { false }
    let final-attrs = if type(result) == str {
      (..attrs, "_ends-with-period": ends)
    } else { attrs }
    (finalize(result, final-attrs), "var", (), ends)
  }
}

// Fallback: keep interpreter-based path for unknown forms
#let format-number-compiled(ctx, attrs) = {
  let node = (tag: "number", attrs: attrs, children: ())
  let stub-interpret(children, c) = []
  let content = _handle-number(node, ctx, stub-interpret)
  let var-state = if is-empty(content) { "no-var" } else { "var" }
  let ends = if type(content) == str { content.ends-with(".") } else { false }
  (content, var-state, (), ends)
}
