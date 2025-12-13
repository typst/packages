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

    let op-match = it.text.matches(western-open-punc-regex).last(default: none)
    if op-match != none and op-match.start > 0 {
      let text1 = text(it.text.slice(0, op-match.start))
      let text2 = text(it.text.slice(op-match.start))
      return text1 + text2
    }
    let cp-match = it.text.match(western-close-punc-regex)
    if cp-match != none and cp-match.end < it.text.len() {
      let text1 = text(it.text.slice(0, cp-match.end))
      let text2 = text(it.text.slice(cp-match.end))
      return text1 + text2
    }

    let pre = if op-match != none {
      // Insert latin ghost character before western opening punctuasion marks.
      pre-latin-ghost
    } else if it.text.starts-with(cjk-regex) {
      // Remove spaces after text that start with cjk character.
      h(0em, weak: true)
    }
    let post = if cp-match != none {
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
