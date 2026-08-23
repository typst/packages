#let default-cjk-regex = regex(
  "["
    + "\p{scx:Hira}\p{scx:Kana}\p{scx:Han}\p{scx:Hang}\p{scx:Bopo}"
    + "\u3000-\u303F" // CJK Symbols and Punctuation
    + "\u3190-\u319F" // Kanbun
    + "\u31C0-\u31EF" // CJK Strokes
    + "\u3200-\u32FF" // Enclosed CJK Letters and Months
    + "\u3300-\u33FF" // CJK Compatibility
    + "\uFE10-\uFE1F" // Vertical Forms
    + "\uFE30-\uFE4F" // CJK Compatibility Forms
    + "\uFE50-\uFE6F" // Small Form Variants
    + "\uFF00-\uFFEF" // Halfwidth and Fullwidth Forms
    + "]",
)
#let default-western-open-punc-regex = regex(
  "[\p{Pi}\p{Ps}--["
    + "\u3000-\u303F" // CJK Symbols and Punctuation
    + "\uFE10-\uFE1F" // Vertical Forms
    + "\uFE30-\uFE4F" // CJK Compatibility Forms
    + "\uFE50-\uFE6F" // Small Form Variants
    + "\uFF00-\uFFEF" // Halfwidth and Fullwidth Forms
    + "]]",
)
#let default-western-close-punc-regex = regex(
  "[\p{Pf}\p{Pe}\p{Term}--["
    + "\u3000-\u303F" // CJK Symbols and Punctuation
    + "\uFE10-\uFE1F" // Vertical Forms
    + "\uFE30-\uFE4F" // CJK Compatibility Forms
    + "\uFE50-\uFE6F" // Small Form Variants
    + "\uFF00-\uFFEF" // Halfwidth and Fullwidth Forms
    + "]]",
)

#let pre-latin-ghost = {
  context {
    let a = [a]
    let w = measure(a).width
    hide(a)
    hide(sym.wj)
    h(-w, weak: false)
    hide(sym.wj)
  }
}
#let post-latin-ghost = {
  context {
    let a = [a]
    let w = measure(a).width
    hide(sym.wj)
    h(-w, weak: false)
    hide(sym.wj)
    hide(a)
  }
}

#let cjk-spacer(
  body,
  cjk-regex: default-cjk-regex,
  western-open-punc-regex: default-western-open-punc-regex,
  western-close-punc-regex: default-western-close-punc-regex,
) = {
  set text(cjk-latin-spacing: auto)

  show text: it => {
    if it.text.len() == 0 {
      return it
    }

    let op-matches = it.text.matches(western-open-punc-regex)
    let cp-matches = it.text.matches(western-close-punc-regex)
    let matches = op-matches.map(m => m.start) + cp-matches.map(m => m.end)
    matches.push(0)
    matches.push(it.text.len())
    matches = matches.dedup().sorted()
    if matches.len() > 2 {
      return matches.windows(2).map(m => text(it.text.slice(m.at(0), m.at(1)))).sum()
    }

    let pre = if op-matches.len() > 0 {
      // Insert latin ghost character before western opening punctuasion marks.
      pre-latin-ghost
    } else if it.text.starts-with(cjk-regex) {
      // Remove spaces after text that start with cjk character.
      h(0em, weak: true)
    }
    let post = if cp-matches.len() > 0 {
      // Insert latin ghost character after western closing punctuasion marks.
      post-latin-ghost
    } else if it.text.ends-with(cjk-regex) {
      // Remove spaces after text that ends with cjk character.
      h(0em, weak: true)
    }
    return pre + it + post
  }

  // Apply cjk-latin-spacing to inline math equations.
  show math.equation.where(block: false): it => {
    return pre-latin-ghost + it + post-latin-ghost
  }

  body
}
