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
    + "\uFF00-\uFFEF" // Halfwidth and Fullwidth Forms
    + "]",
)


#let cjk-spacer(
  body,
  lang: "ja",
  cjk-regex: default-cjk-regex,
) = {
  set text(lang: lang, cjk-latin-spacing: auto)
  show math.equation: set text(lang: "en")

  // Inserts zero horizontal spaces before/after CJK text.
  show text.where(lang: lang): it => {
    let clusters = it.text.clusters()
    if clusters.len() == 0 {
      return it
    }

    let pre = if clusters.first().match(cjk-regex) != none {
      h(0em, weak: true)
    }
    let post = if clusters.last().match(cjk-regex) != none {
      h(0em, weak: true)
    }
    return pre + it + post
  }

  // Inserts zero-width hidden [a] before/after inline math equations.
  show math.equation.where(block: false): it => {
    let a = [a]
    context {
      let w = measure(a).width
      hide(a)
      sym.wj
      h(-w, weak: false)
      sym.wj
      it
      sym.wj
      h(-w, weak: false)
      sym.wj
      hide(a)
    }
  }

  body
}
