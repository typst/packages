#let init(body, bcolor: luma(210), inset: 5pt, border: 2pt, radius: 2pt, content-font: "linux libertine", code-font-size: 9pt, content-font-size: 11pt, code-return-box: true, wrap-code: false) = {
  show raw.where(block: true, lang: "typst-ex"): it => {
    set text(code-font-size)
    let code = block(
      width: 100%,
      fill: bcolor,
      stroke: border + bcolor,
      inset: inset,
      radius: (top: 4pt),
      raw(lang: "typst", it.text)
    )
    
    let reg = regex("#import (\"[^@](?:[\wäöüÄÖÜß]|[_\-\\/.])(?:[\wäöüÄÖÜß]|[_\-\\/.]| )*\.typ\")(: (?:\*|(?:[\wäöüÄÖÜß](?:[\wäöüÄÖÜß]|[_\-])*, )*[\wäöüÄÖÜß](?:[\wäöüÄÖÜß]|[_\-])*))?")
    let result = eval("[" + it.text.replace(reg, "") + "]")
    let result-content = block(
      width: 100%,
      stroke: border + bcolor,
      inset: inset,
      radius: (bottom: radius),
      text(font: content-font, content-font-size, result)
    )

    grid(
      code,
      result-content
    )
  }

  show raw.where(block: true, lang: "typst-ex-code"): it => {
    set text(code-font-size)
    let code = block(
      width: 100%,
      fill: bcolor,
      stroke: border + bcolor,
      inset: inset,
      radius: (top: 4pt),
      if wrap-code { raw(lang: "typst", "#{\n" + it.text + "\n}") } else { raw(lang: "typc", it.text) }
    )
    
    let reg = regex("import (\"[^@](?:[\wäöüÄÖÜß]|[_\-\\/.])(?:[\wäöüÄÖÜß]|[_\-\\/.]| )*\.typ\")(: (?:\*|(?:[\wäöüÄÖÜß](?:[\wäöüÄÖÜß]|[_\-])*, )*[\wäöüÄÖÜß](?:[\wäöüÄÖÜß]|[_\-])*))?")
    let result = eval(it.text.replace(reg, ""))
    let type-box = box(inset: 2pt, radius: 1pt, fill: white, text(code-font-size, "return type: " + raw(type(result))))
    let result-content = block(
      width: 100%,
      stroke: border + bcolor,
      inset: inset,
      radius: (bottom: radius),
      text(font: content-font, content-font-size, {
        if code-return-box {
          style(sty => place(
            type-box,
            dx: inset - 1pt,
            dy: - inset - measure(type-box, sty).height - 1pt,
            right
          ))
        }
        [ #result ]
      })
    )

    grid(
      code,
      result-content
    )
  }

  show raw.where(block: true, lang: "typst"): it => block(
    width: 100%,
    fill: bcolor,
    stroke: border + bcolor,
    inset: inset,
    radius: radius,
    text(code-font-size, raw(lang: "typst", it.text))
  )

  show raw.where(block: true, lang: "typst-code"): it => block(
    width: 100%,
    fill: bcolor,
    stroke: border + bcolor,
    inset: inset,
    radius: radius,
    text(code-font-size, raw(lang: "typc", it.text))
  )

  body
}