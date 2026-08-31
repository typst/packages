#import "../utils/placeholder.typ": placeholder

/// -> content
#let insert-abstract(abstract, lang: "en") = {
  heading(
    level: 1,
    numbering: none,
    outlined: true,
    if lang == "en" { "Abstract" } else { "Samenvatting" },
  )
  if abstract != none {
    abstract
  } else {
    // NOTE: keep each string on ONE line. Inside a `{}` code block a newline
    // ends the expression, so a continuation line starting with `+` is parsed
    // as unary plus applied to a string -- "cannot apply unary '+' to string".
    placeholder(if lang == "nl" {
      "Plaatshouder. Vul deze samenvatting in via de parameter `abstract` (of `dutch-summary` voor de Nederlandse samenvatting van een Engelstalige thesis)."
    } else {
      "Placeholder. Supply this text through the `abstract` parameter."
    })
  }
}
