#let appendix-content(language, appendices) = {
  let prefix = if language == "ko" { "부록" } else { "Appendix" }

  if type(appendices) == array {
    let multiple = appendices.len() > 1

    [
      #show heading.where(level: 1): it => [
        #block(above: 1.25em, below: 0.65em)[
          #text(size: 16pt, weight: "bold")[#it.body]
        ]
      ]
      #for (index, appendix) in appendices.enumerate() {
        if index > 0 {
          pagebreak()
        }
        let title = appendix.at("title")
        let body = appendix.at("body")
        let letter = numbering("A", index + 1)
        counter(figure.where(kind: image)).update(0)
        counter(figure.where(kind: table)).update(0)
        counter(math.equation).update(0)
        show figure.where(kind: image): set figure(numbering: n => [#letter#n])
        show figure.where(kind: table): set figure(numbering: n => [#letter#n])
        set math.equation(numbering: n => [(#letter#n)])
        let heading-body = if multiple { [#prefix #letter: #title] } else { [#prefix: #title] }
        heading(level: 1)[#heading-body]
        body
      }
    ]
  } else {
    [
      #show heading.where(level: 1): it => [
        #block(above: 1.25em, below: 0.65em)[
          #text(size: 16pt, weight: "bold")[#prefix: #it.body]
        ]
      ]
      #appendices
    ]
  }
}
