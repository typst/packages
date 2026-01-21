#let init(
  body,
  bcolor: luma(210),
  inset: 5pt,
  border: 2pt,
  radius: 2pt,
  content-font: "linux libertine",
  code-font-size: 9pt,
  content-font-size: 11pt,
  code-return-box: true,
  wrap-code: false,
  eval-scope: (:),
  escape-bracket: "%"
) = {  
  let eval-scope-values = (:)
  let eval-scope-codes = (:)
   for (k, v) in eval-scope.pairs() {
    if type(v) == dictionary {
      if v.keys().contains("value") {
        eval-scope-values.insert(k, v.value)
      }
      if v.keys().contains("code") {
        eval-scope-codes.insert(k, v.code)
      }
    } else {
      panic("Argument `eval-scope` accepts only a (value?: ..., code?: ...) dictionary for each variable!")
    }
  }

  /// returns two modified versions of text:
  /// - substitute: text without the hidden text by `%ENDHIDDEN%` AND with the replacements given by eval-scope-codes
  ///      produces the code to be displayed
  /// - remove: text with hidden text BUT without the replacements
  ///      produces the code to be evaluated
  let substitute-remove-code(text) = {
    let splitted-text = text.split(escape-bracket + "ENDHIDDEN" + escape-bracket)
    let (hidden-text, shown-text) = if splitted-text.len() == 1 {
      ("", splitted-text.at(0))
    } else {
      splitted-text.slice(0, 2)
    }
    eval-scope-codes.pairs().fold(
      (shown-text, hidden-text + shown-text), (s, a) => (
        s.at(0).replace(
          escape-bracket + a.at(0) + escape-bracket,
          a.at(1)
        ),
        s.at(1).replace(
          escape-bracket + a.at(0) + escape-bracket,
          ""
        )
      )
    )
  }
  
  show raw.where(block: true, lang: "typst-ex"): it => {
    let (substituted-text, removed-text) = substitute-remove-code(it.text)
    
    set text(code-font-size)
    let code = block(
      width: 100%,
      fill: bcolor,
      stroke: border + bcolor,
      inset: inset,
      radius: (top: 4pt),
      raw(lang: "typst", substituted-text)
    )
    
    let result = eval(
      removed-text,
      mode: "markup",
      scope: eval-scope-values
    )
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
    let (substituted-text, removed-text) = substitute-remove-code(it.text)
    
    set text(code-font-size)
    let code = block(
      width: 100%,
      fill: bcolor,
      stroke: border + bcolor,
      inset: inset,
      radius: (top: 4pt),
      if wrap-code { raw(lang: "typst", "#{\n" + substituted-text + "\n}") } else { raw(lang: "typc", substituted-text) }
    )
    
    let result = eval(removed-text, scope: eval-scope-values)
    let type-box = box(inset: 2pt, radius: 1pt, fill: white, text(code-font-size, "return type: " + raw(str(type(result)))))
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