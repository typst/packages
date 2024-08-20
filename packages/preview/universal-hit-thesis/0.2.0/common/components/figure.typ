#let algorithm-figure(content, caption: [], supplement: [算法], label-name: "") = {
  let fig = figure(
    [#line(length: 100%, stroke: 0.05mm)
      #v(0.5em, weak: true)
      #align(left)[
        #content
      ]
    ],
    kind: "algorithm",
    supplement: supplement,
    caption: caption,
  )
  [
    #if label-name == "" {
      [
        #line(length: 100%, stroke: 0.3mm)
        #fig
        #line(length: 100%, stroke: 0.3mm)]
    } else {
      let new-label = label(label-name)
      box[
        #line(length: 100%, stroke: 0.3mm)
        #v(0.75em, weak: true)
        #fig
        #new-label
        #v(0.5em, weak: true)
        #line(length: 100%, stroke: 0.3mm)
      ]
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