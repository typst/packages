#import "../utils/style.typ": 字体, 字号
#import "../utils/header.typ": header-render
#import "../layouts/preface.typ": (
  preface-heading-above, preface-heading-below, preface-heading-size, preface-heading-weight,
)

// 目录生成页面
#let bachelor-outline-page(
  // documentclass 传入参数
  twoside: false,
  doctype: "bachelor",
  fonts: (:),
  // 其他参数
  depth: 4,
  title: auto,
  outlined: false,
  title-vspace: 0pt,
  title-text-args: auto,
  // 引用页数的字体，这里用于显示 Times New Roman
  reference-font: auto,
  reference-size: auto,
  // 字体与字号
  font: auto,
  size: auto,
  // 垂直间距
  above: auto,
  below: auto,
  indent: (0pt, 20pt, 20pt),
  // 全都显示点号
  fill: (repeat([.], gap: 0.15em),),
  gap: .3em,
  // 行间距
  leading: 1.0em,
  spacing: 1.0em,
  ..args,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts

  // 研究生和本科生使用不同的默认格式
  let is-graduate = doctype == "master" or doctype == "doctor"

  // 标题默认值
  if title == auto {
    title = if is-graduate { "目　录" } else { "目　　录" }
  }

  if title-text-args == auto {
    title-text-args = if is-graduate {
      (font: fonts.黑体, size: 字号.三号)
    } else {
      (font: fonts.宋体, size: 字号.三号, weight: "bold")
    }
  }
  // 引用页数的字体，这里用于显示 Times New Roman
  if reference-font == auto {
    reference-font = fonts.宋体
  }
  if reference-size == auto {
    reference-size = 字号.小四
  }
  // 字体与字号
  if font == auto {
    font = if is-graduate {
      (fonts.宋体, fonts.宋体)
    } else {
      (fonts.黑体, fonts.宋体)
    }
  }
  if size == auto {
    size = if is-graduate {
      (字号.小四, 字号.小四)
    } else {
      (字号.四号, 字号.小四)
    }
  }
  // 垂直间距
  if above == auto {
    above = if is-graduate {
      (20pt, 6pt)
    } else {
      (25pt, 14pt)
    }
  }
  if below == auto {
    below = if is-graduate {
      (6pt, 6pt)
    } else {
      (14pt, 14pt)
    }
  }
  // 行间距
  if leading == auto {
    leading = if is-graduate {
      14pt
    } else {
      1.5em
    }
  }

  // 2.  正式渲染
  pagebreak(weak: true, to: if is-graduate { "odd" })

  // 页眉


  // 默认显示的字体
  set text(font: reference-font, size: reference-size)

  [
    // 目录标题：字体由 title-text-args 控制，间距使用统一配置
    #show heading.where(level: 1, numbering: none): it => {
      set text(..title-text-args, size: preface-heading-size, weight: preface-heading-weight)
      set block(above: 0pt, below: preface-heading-below)
      align(center, it)
    }
    #v(preface-heading-above)
    #heading(level: 1, outlined: outlined, title)

    #v(title-vspace)

    // 目录样式
    #set par(leading: leading)
    #set outline(indent: level => indent.slice(0, calc.min(level + 1, indent.len())).sum())
    #show outline.entry: entry => {
      // 研究生使用固定行间距，不额外添加 above/below
      let entry-content = link(
        entry.element.location(),
        entry.indented(
          none,
          {
            text(
              font: font.at(entry.level - 1, default: font.last()),
              size: size.at(entry.level - 1, default: size.last()),
              {
                if entry.prefix() not in (none, []) {
                  entry.prefix()
                  h(gap)
                }
                entry.body()
              },
            )
            box(width: 1fr, inset: (x: .25em), fill.at(entry.level - 1, default: fill.last()))
            entry.page()
          },
          gap: 0pt,
        ),
      )
      if is-graduate {
        // 研究生：固定行间距，每条目占一行
        entry-content
      } else {
        // 本科生：使用 above/below 控制间距
        block(
          above: above.at(entry.level - 1, default: above.last()),
          below: below.at(entry.level - 1, default: below.last()),
          entry-content,
        )
      }
    }

    // 显示目录
    #outline(title: none, depth: depth)
  ]

  // 调试信息
  // context { text("目录结束，当前页码: " + str(here().page()) + ", is-graduate: " + str(is-graduate) + ", twoside: " + str(twoside)) }
}
