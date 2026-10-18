#import "@preview/theorion:0.4.1": *

#import "../template/custom/parameter.typ": *

// ----------------------------------------------------------------------------------------
/* 定义样式 */
// 公理
#let axiom-sty = (
  name: [公理], // 显示名称
  head-text: (size: 10.5pt, font: sans-font, weight: "regular"), // 标题字体样式，除字体颜色
  body-text: (size: 10.5pt, font: serif-font, weight: "regular", fill: black), // 文字字体样式
  head-color: (rainbow: rgb("f03752"), showy: black), // 标题字体颜色
  main-color: rgb("f03752"), // 颜色风格
)
// 定义
#let definition-sty = (
  name: [定义], // 显示名称
  head-text: (size: 10.5pt, font: sans-font, weight: "regular"), // 标题字体样式，除字体颜色
  body-text: (size: 10.5pt, font: serif-font, weight: "regular", fill: black), // 文字字体样式
  head-color: (rainbow: rgb("f19790"), showy: black), // 标题字体颜色
  main-color: rgb("f19790"), // 颜色风格
)
// 定律
#let law-sty = (
  name: [定律], // 显示名称
  head-text: (size: 10.5pt, font: sans-font, weight: "regular"), // 标题字体样式，除字体颜色
  body-text: (size: 10.5pt, font: serif-font, weight: "regular", fill: black), // 文字字体样式
  head-color: (rainbow: rgb("#d276a3"), showy: black), // 标题字体颜色
  main-color: rgb("#d276a3"), // 颜色风格
)
// 定理
#let theorem-sty = (
  name: [定理], // 显示名称
  head-text: (size: 10.5pt, font: sans-font, weight: "regular"), // 标题字体样式，除字体颜色
  body-text: (size: 10.5pt, font: serif-font, weight: "regular", fill: black), // 文字字体样式
  head-color: (rainbow: rgb("619ac3"), showy: black), // 标题字体颜色
  main-color: rgb("619ac3"), // 颜色风格
)
// 引理
#let lemma-sty = (
  name: [引理], // 显示名称
  head-text: (size: 10.5pt, font: sans-font, weight: "regular"), // 标题字体样式，除字体颜色
  body-text: (size: 10.5pt, font: serif-font, weight: "regular", fill: black), // 文字字体样式
  head-color: (rainbow: rgb("63bbd0"), showy: black), // 标题字体颜色
  main-color: rgb("63bbd0"), // 颜色风格
)
// 假设
#let postulate-sty = (
  name: [假设], // 显示名称
  head-text: (size: 10.5pt, font: sans-font, weight: "regular"), // 标题字体样式，除字体颜色
  body-text: (size: 10.5pt, font: serif-font, weight: "regular", fill: black), // 文字字体样式
  head-color: (rainbow: rgb("b4a992"), showy: black), // 标题字体颜色
  main-color: rgb("b4a992"), // 颜色风格
)
// 推论
#let corollary-sty = (
  name: [推论], // 显示名称
  head-text: (size: 10.5pt, font: sans-font, weight: "regular"), // 标题字体样式，除字体颜色
  body-text: (size: 10.5pt, font: serif-font, weight: "regular", fill: black), // 文字字体样式
  head-color: (rainbow: rgb("fba414"), showy: black), // 标题字体颜色
  main-color: rgb("fba414"), // 颜色风格
)
// 命题
#let proposition-sty = (
  name: [命题], // 显示名称
  head-text: (size: 10.5pt, font: sans-font, weight: "regular"), // 标题字体样式，除字体颜色
  body-text: (size: 10.5pt, font: serif-font, weight: "regular", fill: black), // 文字字体样式
  head-color: (rainbow: rgb("fbda41"), showy: black), // 标题字体颜色
  main-color: rgb("fbda41"), // 颜色风格
)
// 例子
#let example-sty = (
  name: [例子], // 显示名称
  head-text: (size: 10.5pt, font: sans-font, weight: "regular"), // 标题字体样式，除字体颜色
  body-text: (size: 10.5pt, font: serif-font, weight: "regular", fill: black), // 文字字体样式
  head-color: (rainbow: rgb("bec936"), showy: black), // 标题字体颜色
  main-color: rgb("bec936"), // 颜色风格
)
// 练习
#let exercise-sty = (
  name: [练习], // 显示名称
  head-text: (size: 10.5pt, font: sans-font, weight: "regular"), // 标题字体样式，除字体颜色
  body-text: (size: 10.5pt, font: serif-font, weight: "regular", fill: black), // 文字字体样式
  head-color: (rainbow: rgb("9eccab"), showy: black), // 标题字体颜色
  main-color: rgb("9eccab"), // 颜色风格
)

// --------------------------------------------
/* 盒子函数前置 */
// 魔改版 showybox
#let my-fancy-box(
  border-color: red, title-color: red,
  body-color: red.lighten(95%), end-symbol: none,
  head-text: (size: 1em, weight: "regular", font: sans-font, fill: black),
  body-text: (size: 1em, weight: "regular", font: serif-font, fill: black),
  prefix: none,
  title: "",
  full-title: auto,
  body,
) = context showybox(
  frame: (
    thickness: .05em,
    radius: .3em,
    inset: (x: 1.2em, top: .7em, bottom: 1.2em),
    border-color: border-color,
    title-color: title-color,
    body-color: body-color,
    title-inset: (x: 1em, y: .5em),
  ),
  title-style: (
    boxed-style: (
      anchor: (x: left, y: horizon),
      radius: 0em,
    ),
  ),
  breakable: true,
  title: {
    if full-title == auto {
      if prefix != none {
        text(..head-text)[#prefix (#title)]
      } else {
        text(..head-text, title)
      }
    } else {
      text(..head-text, full-title)
    }
  },
  {
    text(..body-text, body)
    if end-symbol != none {
      place(
        right + bottom,
        dy: .8em,
        dx: .9em,
        text(size: .6em, fill: bordercolor, end-symbol),
      )
    }
  },
)
// 魔改版 rainbow
#let my-rainbow(
  fill: red,
  head-text: (size: 1em, weight: "regular", font: sans-font, fill: red),
  body-text: (size: 1em, weight: "regular", font: serif-font, fill: black),
  prefix: none,
  title: "",
  full-title: auto,
  ..args,
  body,
) = context block(
  stroke: language-aware-start(.25em + fill),
  inset: language-aware-start(1em) + (y: .75em),
  width: 100%,
  breakable: true,
  ..args,
  [
    #if full-title != "" {
      block(sticky: true, text(..head-text, full-title))
    }
    #text(..body-text, body)
  ]
)
// 魔改版 notebox
#let my-notebox-rainbow(
  head-text: (size: 1em, weight: "regular", font: sans-font),
  body-text: (size: 1em, weight: "regular", font: serif-font, fill: black),
  fill: blue,
  title: "注意",
  icon-name: "info",
  body,
) = context block(
  stroke: language-aware-start(.25em + fill),
  inset: language-aware-start(1em) + (top: .5em, bottom: .75em),
  width: 100%,
  breakable: true,
  {
    block(
      sticky: true,
      text(
        ..head-text + (fill: fill),
        octique-inline(..(height: 1.2em, width: 1.2em, baseline: .2em, color: fill), icon-name)
        + h(.5em) + title
      ),
    )
    text(..body-text, body)
  },
)
// 魔改版 quotebox
#let my-quotebox-rainbow(
  body-text: (size: 1em, weight: "regular", font: serif-font, fill: luma(100)),
  fill: luma(100),
  body
) = context block(
  stroke: language-aware-start(.25em + fill),
  inset: language-aware-start(1em) + (y: .75em),
  breakable: true,
  text(..body-text, body)
)

// --------------------------------------------
/* 各种盒子函数-showybox */
// 公理
#let (axiom-counter, axiombox-showy, axiom-showy, show-axiom-showy) = make-frame(
  "axiom",
  axiom-sty.name,
  inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: axiom-sty.main-color, title-color: axiom-sty.main-color,
    body-color: axiom-sty.main-color.lighten(95%), end-symbol: none,
    head-text: axiom-sty.head-text + (fill: axiom-sty.head-color.showy),
    body-text: axiom-sty.body-text,
  ),
)
// 定义
#let (definition-counter, definitionbox-showy, definition-showy, show-definition-showy) = make-frame(
  "definition",
  definition-sty.name,
  inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: definition-sty.main-color, title-color: definition-sty.main-color,
    body-color: definition-sty.main-color.lighten(95%), end-symbol: none,
    head-text: definition-sty.head-text + (fill: definition-sty.head-color.showy),
    body-text: definition-sty.body-text,
  ),
)
// 定律
#let (law-counter, lawbox-showy, law-showy, show-law-showy) = make-frame(
  "law",
  law-sty.name,
  inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: law-sty.main-color, title-color: law-sty.main-color,
    body-color: law-sty.main-color.lighten(95%), end-symbol: none,
    head-text: law-sty.head-text + (fill: law-sty.head-color.showy),
    body-text: law-sty.body-text,
  ),
)
// 定理
#let (theorem-counter, theorembox-showy, theorem-showy, show-theorem-showy) = make-frame(
  "theorem",
  theorem-sty.name,
  inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: theorem-sty.main-color, title-color: theorem-sty.main-color,
    body-color: theorem-sty.main-color.lighten(95%), end-symbol: none,
    head-text: theorem-sty.head-text + (fill: theorem-sty.head-color.showy),
    body-text: theorem-sty.body-text,
  ),
)
// 引理
#let (lemma-counter, lemmabox-showy, lemma-showy, show-lemma-showy) = make-frame(
  "lemma",
  lemma-sty.name,
  inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: lemma-sty.main-color, title-color: lemma-sty.main-color,
    body-color: lemma-sty.main-color.lighten(95%), end-symbol: none,
    head-text: lemma-sty.head-text + (fill: lemma-sty.head-color.showy),
    body-text: lemma-sty.body-text,
  ),
)
// 假设
#let (postulate-counter, postulatebox-showy, postulate-showy, show-postulate-showy) = make-frame(
  "postulate",
  postulate-sty.name,
  inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: postulate-sty.main-color, title-color: postulate-sty.main-color,
    body-color: postulate-sty.main-color.lighten(95%), end-symbol: none,
    head-text: postulate-sty.head-text + (fill: postulate-sty.head-color.showy),
    body-text: postulate-sty.body-text,
  ),
)
// 推论
#let (corollary-counter, corollarybox-showy, corollary-showy, show-corollary-showy) = make-frame(
  "corollary",
  corollary-sty.name,
  inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: corollary-sty.main-color, title-color: corollary-sty.main-color,
    body-color: corollary-sty.main-color.lighten(95%), end-symbol: none,
    head-text: corollary-sty.head-text + (fill: corollary-sty.head-color.showy),
    body-text: corollary-sty.body-text,
  ),
)
// 命题
#let (proposition-counter, propositionbox-showy, proposition-showy, show-proposition-showy) = make-frame(
  "proposition",
  proposition-sty.name,
  inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: proposition-sty.main-color, title-color: proposition-sty.main-color,
    body-color: proposition-sty.main-color.lighten(95%), end-symbol: none,
    head-text: proposition-sty.head-text + (fill: proposition-sty.head-color.showy),
    body-text: proposition-sty.body-text,
  ),
)
// 例子
#let (example-counter, examplebox-showy, example-showy, show-example-showy) = make-frame(
  "example",
  example-sty.name,
  inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: example-sty.main-color, title-color: example-sty.main-color,
    body-color: example-sty.main-color.lighten(95%), end-symbol: none,
    head-text: example-sty.head-text + (fill: example-sty.head-color.showy),
    body-text: example-sty.body-text,
  ),
)
// 练习
#let (exercise-counter, exercisebox-showy, exercise-showy, show-exercise-showy) = make-frame(
  "exercise",
  exercise-sty.name,
  inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: exercise-sty.main-color, title-color: exercise-sty.main-color,
    body-color: exercise-sty.main-color.lighten(95%), end-symbol: none,
    head-text: exercise-sty.head-text + (fill: exercise-sty.head-color.showy),
    body-text: exercise-sty.body-text,
  ),
)



/* 各种盒子函数-rainbow */
// 公理
#let (axiom-counter, axiombox-rainbow, axiom-rainbow, show-axiom-rainbow) = make-frame(
  "axiom",
  axiom-sty.name,
  inherited-levels: 1,
  render: my-rainbow.with(
    fill: axiom-sty.main-color,
    head-text: axiom-sty.head-text + (fill: axiom-sty.head-color.rainbow),
    body-text: axiom-sty.body-text,
  ),
)
// 定义
#let (definition-counter, definitionbox-rainbow, definition-rainbow, show-definition-rainbow) = make-frame(
  "definition",
  definition-sty.name,
  inherited-levels: 1,
  render: my-rainbow.with(
    fill: definition-sty.main-color,
    head-text: definition-sty.head-text + (fill: definition-sty.head-color.rainbow),
    body-text: definition-sty.body-text,
  ),
)
// 定律
#let (law-counter, lawbox-rainbow, law-rainbow, show-law-rainbow) = make-frame(
  "law",
  law-sty.name,
  inherited-levels: 1,
  render: my-rainbow.with(
    fill: law-sty.main-color,
    head-text: law-sty.head-text + (fill: law-sty.head-color.rainbow),
    body-text: law-sty.body-text,
  ),
)
// 定理
#let (theorem-counter, theorembox-rainbow, theorem-rainbow, show-theorem-rainbow) = make-frame(
  "theorem",
  theorem-sty.name,
  inherited-levels: 1,
  render: my-rainbow.with(
    fill: theorem-sty.main-color,
    head-text: theorem-sty.head-text + (fill: theorem-sty.head-color.rainbow),
    body-text: theorem-sty.body-text,
  ),
)
// 引理
#let (lemma-counter, lemmabox-rainbow, lemma-rainbow, show-lemma-rainbow) = make-frame(
  "lemma",
  lemma-sty.name,
  inherited-levels: 1,
  render: my-rainbow.with(
    fill: lemma-sty.main-color,
    head-text: lemma-sty.head-text + (fill: lemma-sty.head-color.rainbow),
    body-text: lemma-sty.body-text,
  ),
)
// 假设
#let (postulate-counter, postulatebox-rainbow, postulate-rainbow, show-postulate-rainbow) = make-frame(
  "postulate",
  postulate-sty.name,
  inherited-levels: 1,
  render: my-rainbow.with(
    fill: postulate-sty.main-color,
    head-text: postulate-sty.head-text + (fill: postulate-sty.head-color.rainbow),
    body-text: postulate-sty.body-text,
  ),
)
// 推论
#let (corollary-counter, corollarybox-rainbow, corollary-rainbow, show-corollary-rainbow) = make-frame(
  "corollary",
  corollary-sty.name,
  inherited-levels: 1,
  render: my-rainbow.with(
    fill: corollary-sty.main-color,
    head-text: corollary-sty.head-text + (fill: corollary-sty.head-color.rainbow),
    body-text: corollary-sty.body-text,
  ),
)
// 命题
#let (proposition-counter, propositionbox-rainbow, proposition-rainbow, show-proposition-rainbow) = make-frame(
  "proposition",
  proposition-sty.name,
  inherited-levels: 1,
  render: my-rainbow.with(
    fill: proposition-sty.main-color,
    head-text: proposition-sty.head-text + (fill: proposition-sty.head-color.rainbow),
    body-text: proposition-sty.body-text,
  ),
)
// 例子
#let (example-counter, examplebox-rainbow, example-rainbow, show-example-rainbow) = make-frame(
  "example",
  example-sty.name,
  inherited-levels: 1,
  render: my-rainbow.with(
    fill: example-sty.main-color,
    head-text: example-sty.head-text + (fill: example-sty.head-color.rainbow),
    body-text: example-sty.body-text,
  ),
)
// 练习
#let (exercise-counter, exercisebox-rainbow, exercise-rainbow, show-exercise-rainbow) = make-frame(
  "exercise",
  exercise-sty.name,
  inherited-levels: 1,
  render: my-rainbow.with(
    fill: exercise-sty.main-color,
    head-text: exercise-sty.head-text + (fill: exercise-sty.head-color.rainbow),
    body-text: exercise-sty.body-text,
  ),
)


// 引入所有盒子
#let my-show-theorion(body) = {
  show: show-axiom-showy
  show: show-definition-showy
  show: show-law-showy
  show: show-theorem-showy
  show: show-lemma-showy
  show: show-postulate-showy
  show: show-corollary-showy
  show: show-proposition-showy
  show: show-exercise-showy
  show: show-example-showy

  show: show-axiom-rainbow
  show: show-definition-rainbow
  show: show-law-rainbow
  show: show-theorem-rainbow
  show: show-lemma-rainbow
  show: show-postulate-rainbow
  show: show-corollary-rainbow
  show: show-proposition-rainbow
  show: show-exercise-rainbow
  show: show-example-rainbow

  show: show-theorion
  body
}