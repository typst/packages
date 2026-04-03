#import "colors.typ": *

// Global admonition defaults — use `set-admonition-defaults` to override these
#let _admonition-title-size = state("xyznote-admonition-title-size", 1.1em)
#let _admonition-body-size = state("xyznote-admonition-body-size", 1.2em)

// Call this at the top of your document to globally change title/body sizes for all admonitions.
// Example: #set-admonition-defaults(title-size: 0.9em, body-size: 1.0em)
#let set-admonition-defaults(title-size: none, body-size: none) = {
  if title-size != none { _admonition-title-size.update(title-size) }
  if body-size != none { _admonition-body-size.update(body-size) }
}

// 定义提示框类型的翻译
#let ADMONITION-TRANSLATIONS = (
  // Original xyznote types
  "task": ("en": "Task", "zh": "任务"),
  "definition": ("en": "Definition", "zh": "定义"),
  "brainstorming": ("en": "Brainstorming", "zh": "头脑风暴"),
  "question": ("en": "Question", "zh": "问题"),
  // Additional admonition directives
  "note": ("en": "Note", "zh": "注释"),
  "warning": ("en": "Warning", "zh": "警告"),
  "tip": ("en": "Tip", "zh": "提示"),
  "danger": ("en": "Danger", "zh": "危险"),
  "caution": ("en": "Caution", "zh": "注意"),
  "important": ("en": "Important", "zh": "重要"),
  "hint": ("en": "Hint", "zh": "提示"),
  "attention": ("en": "Attention", "zh": "注意"),
  "error": ("en": "Error", "zh": "错误"),
  "seealso": ("en": "See Also", "zh": "另请参阅"),
  "todo": ("en": "Todo", "zh": "待办"),
  "admonition": ("en": "Admonition", "zh": "提醒"),
  "versionadded": ("en": "Added in version", "zh": "新增于版本"),
  "versionchanged": ("en": "Changed in version", "zh": "变更于版本"),
  "deprecated": ("en": "Deprecated since version", "zh": "自版本起弃用"),
)

// 通用提示框函数
#let admonition(
  body,
  title: none,
  primary-color: pink.E,
  secondary-color: pink.E.lighten(90%),
  tertiary-color: pink.E,
  dotted: false,
  figure-kind: "admonition",
  text-color: black,
  emoji: none,
  title-size: auto,
  body-size: auto,
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

  // Resolve sizes: use per-call override if given, otherwise read global state
  context {
    let resolved-title-size = if title-size != auto { title-size } else { _admonition-title-size.get() }
    let resolved-body-size = if body-size != auto { body-size } else { _admonition-body-size.get() }

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
          size: resolved-title-size,
          strong(
            text(
              fill: tertiary-color,
              emoji + " " + smallcaps(title),
            ),
          ),
        )
          + block(
            above: 0.8em,
            text(size: resolved-body-size, fill: text-color, body),
          ),
      )
    ]
  }
}

// ==================== Original xyznote types ====================

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

// ==================== Additional admonition directives ====================

// note - informational, blue tones
#let note(body, ..args) = admonition(
  body,
  primary-color: blue.B,
  secondary-color: rgb("#d9edf7"),
  tertiary-color: blue.A,
  figure-kind: "note",
  emoji: emoji.pencil,
  ..args,
)

// warning - cautionary, orange tones
#let warning(body, ..args) = admonition(
  body,
  primary-color: orange.B,
  secondary-color: rgb("#fcf8e3"),
  tertiary-color: orange.A,
  figure-kind: "warning",
  emoji: sym.triangle.stroked.t,
  ..args,
)

// tip - helpful advice, green tones
#let tip(body, ..args) = admonition(
  body,
  primary-color: ngreen.B,
  secondary-color: rgb("#dff0d8"),
  tertiary-color: ngreen.A,
  figure-kind: "tip",
  emoji: emoji.star,
  ..args,
)

// danger - critical, red tones
#let danger(body, ..args) = admonition(
  body,
  primary-color: red.B,
  secondary-color: rgb("#f2dede"),
  tertiary-color: red.A,
  figure-kind: "danger",
  emoji: emoji.warning,
  ..args,
)

// caution - yellow/amber warning
#let caution(body, ..args) = admonition(
  body,
  primary-color: yellow.A,
  secondary-color: rgb("#fff3cd"),
  tertiary-color: rgb("#856404"),
  figure-kind: "caution",
  emoji: emoji.construction,
  ..args,
)

// important - strong emphasis, deep red
#let important(body, ..args) = admonition(
  body,
  primary-color: pink.B,
  secondary-color: rgb("#fce4ec"),
  tertiary-color: pink.A,
  figure-kind: "important",
  emoji: emoji.excl,
  ..args,
)

// hint - gentle guidance, teal tones
#let hint(body, ..args) = admonition(
  body,
  primary-color: cyan.B,
  secondary-color: rgb("#d1ecf1"),
  tertiary-color: cyan.A,
  figure-kind: "hint",
  emoji: emoji.magnify.r,
  ..args,
)

// attention - amber alert
#let attention(body, ..args) = admonition(
  body,
  primary-color: orange.E,
  secondary-color: rgb("#fff8e1"),
  tertiary-color: orange.A,
  figure-kind: "attention",
  emoji: emoji.bell,
  ..args,
)

// error - red error callout
#let error(body, ..args) = admonition(
  body,
  primary-color: red.E,
  secondary-color: rgb("#fdecea"),
  tertiary-color: red.A,
  figure-kind: "error",
  emoji: emoji.crossmark,
  ..args,
)

// seealso - blue reference
#let seealso(body, ..args) = admonition(
  body,
  primary-color: nblue.B,
  secondary-color: rgb("#e8eaf6"),
  tertiary-color: nblue.A,
  figure-kind: "seealso",
  emoji: emoji.arrow.r,
  ..args,
)

// todo - yellow/gold task marker
#let todo(body, ..args) = admonition(
  body,
  primary-color: yellow.B,
  secondary-color: rgb("#fffde7"),
  tertiary-color: rgb("#f57f17"),
  figure-kind: "todo",
  emoji: sym.checkmark,
  ..args,
)

// admonition - generic, grey neutral
#let generic-admonition(body, ..args) = admonition(
  body,
  primary-color: grey.B,
  secondary-color: rgb("#f5f5f5"),
  tertiary-color: grey.A,
  figure-kind: "admonition",
  emoji: emoji.info,
  ..args,
)

// versionadded - green versioning marker
#let versionadded(version, body, ..args) = admonition(
  body,
  title: (ADMONITION-TRANSLATIONS).at("versionadded").at(args.named().at("lang", default: "en")) + " " + version,
  primary-color: green.B,
  secondary-color: rgb("#e8f5e9"),
  tertiary-color: green.A,
  figure-kind: "versionadded",
  emoji: emoji.seedling,
  ..args,
)

// versionchanged - blue versioning marker
#let versionchanged(version, body, ..args) = admonition(
  body,
  title: (ADMONITION-TRANSLATIONS).at("versionchanged").at(args.named().at("lang", default: "en")) + " " + version,
  primary-color: blue.B,
  secondary-color: rgb("#e3f2fd"),
  tertiary-color: blue.A,
  figure-kind: "versionchanged",
  emoji: sym.arrow.t.b,
  ..args,
)

// deprecated - grey/red deprecation marker
#let deprecated(version, body, ..args) = admonition(
  body,
  title: (ADMONITION-TRANSLATIONS).at("deprecated").at(args.named().at("lang", default: "en")) + " " + version,
  primary-color: grey.E,
  secondary-color: rgb("#efebe9"),
  tertiary-color: grey.A,
  figure-kind: "deprecated",
  emoji: emoji.crossmark,
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
