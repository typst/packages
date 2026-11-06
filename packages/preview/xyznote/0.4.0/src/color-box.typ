#import "colors.typ": *
// 定义提示框类型的翻译
#let ADMONITION-TRANSLATIONS = (
  "task": ("en": "Task", "zh": "任务"),
  "definition": ("en": "Definition", "zh": "定义"),
  "brainstorming": ("en": "Brainstorming", "zh": "头脑风暴"),
  "question": ("en": "Question", "zh": "问题"),
)

// 通用提示框函数
#let admonition(
  body,
  title: none,
  // time: none,
  primary-color: pink.E,
  secondary-color: pink.E.lighten(90%),
  tertiary-color: pink.E,
  dotted: false,
  figure-kind: none,
  text-color: black,
  emoji: none,
  ..args,
) = {
  let lang = args.named().at("lang", default: "en")
  set text(font: ("libertinus serif", "KaiTi")) // color-box 字体

  // 获取标题文本
  let title = if title == none {
    (ADMONITION-TRANSLATIONS).at(figure-kind).at(lang)
  } else {
    title
  }

  // 创建提示框内容
  block(
    width: 100%,
    height: auto,
    inset: 0.2em,
    outset: 0.2em,
    fill: secondary-color,
    stroke: (
      left: (
        thickness: 5pt,
        paint: primary-color,
        dash: if dotted { "dotted" } else { "solid" },
      ),
    ),
  )[
    #set par(first-line-indent: 0pt)
    #pad(
      left: 0.3em,
      right: 0.3em,
      text(
        size: 1.1em,
        strong(
          text(
            fill: tertiary-color,
            emoji + " " + smallcaps(title),
          ),
        ),
      )
        + block(
          above: 0.8em,
          text(size: 1.2em, fill: text-color, body),
        ),
    )
  ]
}

// 特定类型的提示框函数
#let task(body, ..args) = admonition(
  body,
  primary-color: blue.E,
  secondary-color: blue.E.lighten(90%),
  tertiary-color: blue.E,
  figure-kind: "task",
  emoji: emoji.hand.write,
  ..args,
)

#let definition(body, ..args) = admonition(
  body,
  primary-color: ngreen.C,
  secondary-color: ngreen.C.lighten(90%),
  tertiary-color: ngreen.B,
  figure-kind: "definition",
  emoji: emoji.brain,
  ..args,
)

#let brainstorming(body, ..args) = admonition(
  body,
  primary-color: orange.E,
  secondary-color: orange.E.lighten(90%),
  tertiary-color: orange.E,
  figure-kind: "brainstorming",
  emoji: emoji.lightbulb,
  ..args,
)

#let question(body, ..args) = admonition(
  body,
  primary-color: violet.E,
  secondary-color: violet.E.lighten(90%),
  tertiary-color: violet.E,
  figure-kind: "question",
  emoji: emoji.quest,
  ..args,
)

// Green mark box
#let markbox(body) = {
  block(
    fill: rgb(250, 255, 250),
    width: 100%,
    inset: 8pt,
    radius: 4pt,
    stroke: rgb(31, 199, 31),
    body,
  )
}

// Blue tip box
#let tipbox(cite: none, body) = [
  #set text(size: 10.5pt)
  #pad(left: 0.5em)[
    #block(
      breakable: true,
      width: 100%,
      fill: rgb("#d0f2fe"),
      radius: (left: 1pt),
      stroke: (left: 4pt + rgb("#5da1ed")),
      inset: 1em,
    )[#body]
  ]
]
