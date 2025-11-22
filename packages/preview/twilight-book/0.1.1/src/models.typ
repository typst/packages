#import "../themes/index.typ" : * // 导入主题设置模块 / Import theme settings module

#import "fonts.typ" : * // 导入字体模块 / Import fonts module

#let setup-cover( // 封面设置函数 / Cover setup function
  title: [晨昏之书],
  author: "跨越晨昏",
  date: none,
  date-format: "[month repr:long] [day padding:zero], [year repr:full]",
  abstract: none,
  cover-style: "sunflower",
  theme: "abyss",
) = {
  // Load theme settings / 加载主题设置
  let background-color = themes(theme: theme, setting: "background-color")
  let text-color = themes(theme: theme, setting: "text-color")
  let stroke-color = themes(theme: theme, setting: "stroke-color")
  let fill-color = themes(theme: theme, setting: "fill-color")
  let cover-image = themes(theme: theme, setting: "cover-image")
  let preface-image = themes(theme: theme, setting: "preface-image")
  let content-image = themes(theme: theme, setting: "content-image")

  page(
    background: image(cover-image, width: 100%, height: 100%), // 背景图片 / Background image
    align(
      center + horizon,       // 居中对齐 / Center alignment
      block(width: 90%)[      // 宽度90%的块 / Block with 90% width
        // 日期
        // Date
        #if date != none {
          text(1.4em, fill: themes(theme: theme, setting: "text-color"), date.display(date-format)) // 显示日期 / Display date
        } else {
          // 如果没有提供日期，则插入一个空行以保持布局一致。
          // If no date is provided, insert an empty line to maintain consistent layout.
          v(4.6em)           // 垂直间距 / Vertical space
        }

        // 标题居中
        // Center title
        #text(3.3em, fill: themes(theme: theme, setting: "text-color"), font: title-font)[*#title*] // 标题文本 / Title text

        // 作者
        // Author
        #v(1em)               // 垂直间距 / Vertical space
        #text(1.6em, fill: themes(theme: theme, setting: "text-color"), font: sans-family)[#author] // 作者文本 / Author text
      ],
    ),
  )
}

#let setup-foreword( // 前言设置函数 / Foreword setup function
  preface: none,
  theme: "abyss",
) = {
  // 将前言显示为第二或三页。
  // Display preface as second or third page.
  {
    set text(font: mono-family) // 设置前言字体 / Set preface font
    if preface != none {
      page(
        background: image(themes(theme: theme, setting: "preface-image"), width: 100%, height: 100%), // 背景图片 / Background image
        align(
          center + horizon, // 居中对齐 / Center alignment
          block(width: 50%)[#preface] // 前言内容块 / Preface content block
        )
      )
    }
  }
}
