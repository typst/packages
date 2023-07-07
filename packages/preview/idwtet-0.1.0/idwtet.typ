#let init(body, bcolor: luma(210), inset: 5pt, border: 2pt, radius: 2pt) = {
  show raw.where(block: true, lang: "typst-ex"): it => {
    let code = block(
      width: 100%,
      fill: bcolor,
      stroke: border + bcolor,
      inset: inset,
      radius: (top: 4pt),
      raw(lang: "typst", "#{\n" + it.text + "\n}")
    )
    
    let reg = regex("import (\"[^@](?:[\wäöüÄÖÜß]|[_\-\\/.])(?:[\wäöüÄÖÜß]|[_\-\\/.]| )*\.typ\")(: (?:\*|(?:[\wäöüÄÖÜß](?:[\wäöüÄÖÜß]|[_\-])*, )*[\wäöüÄÖÜß](?:[\wäöüÄÖÜß]|[_\-])*))?")
    let result = eval(it.text.replace(reg, ""))
    let result-type = type(result)
    let result-content = block(
      width: 100%,
      stroke: border + bcolor,
      inset: inset,
      radius: (bottom: radius),
      text(font: "linux libertine", 11pt, if result-type == "content" {
        result
      } else {
        let type-box = box(inset: 3pt, baseline: 3pt, radius: 2pt, fill: bcolor)[`returns:` #result-type]
        place(
          type-box,
          dx: - inset + 2pt,
          dy: - inset + 2pt
        )
        if result-type != "none" {
          style(sty => v(measure(type-box, sty).height))
        } else { v(-3pt) }
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
    raw(lang: "typst", it.text)
  )

  body
}