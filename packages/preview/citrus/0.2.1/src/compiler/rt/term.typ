// citrus - Compiler Runtime: Term

#import "text.typ": format-text-content
#import "../../core/mod.typ": capitalize-first-char
#import "../../parsing/mod.typ": lookup-term

/// Get term value without formatting/affixes
#let get-term-raw(ctx, attrs, plan) = {
  let term-name = plan.at("term", default: attrs.at("term", default: ""))
  let form = plan.at("form", default: attrs.at("form", default: "long"))
  let plural = plan.at(
    "plural",
    default: attrs.at("plural", default: "false") == "true",
  )

  let term = lookup-term(ctx, term-name, form: form, plural: plural)
  if term != none and term-name == "ibid" {
    let pos = ctx.at("position", default: none)
    if pos in ("ibid", "ibid-with-locator") {
      term = capitalize-first-char(term)
    }
  }
  if term != none {
    let ends = term.ends-with(".")
    (term, "none", (), ends)
  } else {
    ([], "none", (), false)
  }
}

/// Get term value
#let get-term-compiled(ctx, attrs) = {
  let term-name = attrs.at("term", default: "")
  let form = attrs.at("form", default: "long")
  let plural = attrs.at("plural", default: "false") == "true"

  let term = lookup-term(ctx, term-name, form: form, plural: plural)
  if term != none and term-name == "ibid" {
    let pos = ctx.at("position", default: none)
    if pos in ("ibid", "ibid-with-locator") {
      term = capitalize-first-char(term)
    }
  }
  if term != none {
    let content = format-text-content(ctx, term, attrs)
    let ends = if type(content) == str { content.ends-with(".") } else { false }
    (content, "none", (), ends)
  } else {
    ([], "none", (), false)
  }
}
