#import "@preview/one-liner:0.2.0": fit-to-width // 导入适应宽度模块 / Import fit-to-width module

#import "../themes/index.typ" : * // 导入主题设置模块 / Import theme settings module

#import "fonts.typ" : * // 导入字体模块 / Import fonts module

#let adaptive-title(body) = context { // 自适应标题大小函数 / Adaptive title size function
  let height = 4cm // box size
  let width = 6cm  // box size
  let size = 50pt  // maximum text size

  while measure(text(size: size, weight: 700, body), width: width).height > height {
    size -= 1pt
  }
  
  box(
    width: width,
    height: height,
    fill: green, // for visualization only
    text(size: size, weight: 700, body)
  )
}


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
          block(
            height: 1cm,
            width: 10cm,
            inset: 8pt,
            radius: 4pt,
            align(horizon + center,fit-to-width(date.display(date-format)))
          ) // 摘要块 / Abstract block
        } else {
          // 如果没有提供日期，则插入一个空行以保持布局一致。
          // If no date is provided, insert an empty line to maintain consistent layout.
          v(4.6em)           // 垂直间距 / Vertical space
        }

        // 标题居中
        // Center title
        #block(
          height: 3cm,
          width: 10cm,
          inset: 8pt,
          radius: 4pt,
          align(horizon + center, fit-to-width(title))
        ) // 摘要块 / Abstract block

        // 作者
        // Author
        #v(1em)               // 垂直间距 / Vertical space
        #block(
          height: 1cm,
          width: 10cm,
          inset: 8pt,
          radius: 4pt,
          align(horizon + center,fit-to-width(author))
        ) // 摘要块 / Abstract block
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

#let setup-table-of-contents(
  table-of-contents: none,
) = {
  {
    set text(font: mono-family) // 设置目录字体 / Set contents font
    if table-of-contents != none { // 如果提供了目录，则显示目录 / If table of contents is provided, display it
      table-of-contents         // 显示目录 / Display table of contents
    }
  }
}
