#let algorithm-figure(content, caption: none, supplement: [算法], label-name: "", breakable: true) = {
  block(stroke: rgb("#0000"))[
    #let new-label = label(label-name)
    #figure(
      [],
      kind: "algorithm",
      supplement: supplement,
    ) #new-label
    #v(-1.25em)

    #context {
      let heading-number = counter(heading).get().at(0)
      let _prefix = "i-figured-"
      let algo-kind = "algorithm"
      let prefix-alog-number = counter(figure.where(kind: _prefix + repr(algo-kind))).get().at(0)
      let numbers = (heading-number, prefix-alog-number)

      block(
        stroke: (y: 1.3pt),
        inset: 0pt,
        breakable: breakable,
        width: 100%,
        {
          set align(left)
          block(
            inset: (y: 5pt),
            width: 100%,
            stroke: (bottom: .8pt),
            {
              strong({
                supplement
                numbering("1-1", ..numbers)
                if caption != none {
                  [: ]
                } else {
                  [.]
                }
              })
              if caption != none {
                caption
              }
            },
          )
          v(-1em)
          block(
            breakable: breakable,
            content,
          )
        },
      )
    }
  ]
}

#import "@preview/codelst:2.0.1": sourcecode, code-frame
#import "../theme/type.typ": 字体, 字号

#let codelst-sourcecode = sourcecode
#let hit-sourcecode = codelst-sourcecode.with(frame: code => {
  set text(font: 字体.代码, size: 字号.五号)
  code-frame(code)
})

#let code-figure(content, caption: [], supplement: [代码], label-name: "") = {
  let fig = figure(
    hit-sourcecode(content),
    caption: caption,
    kind: raw,
    supplement: supplement,
  )
  [
    #if label-name == "" {
      [#fig]
    } else {
      let new-label = label(label-name)
      [#fig #new-label]
    }
  ]
}