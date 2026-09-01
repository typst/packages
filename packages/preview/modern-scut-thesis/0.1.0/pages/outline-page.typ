// SCUT 目录
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/section-break.typ": section-break
#import "../utils/outline-cite.typ": outline-cite
#import "../utils/style.typ": 字号, 字体, 章标题字体, 章标题字号

#let outline-page(
  open-right: false,
  fonts: (:),
  depth: 3,
  title: "目　　录",
  outlined: false,
  title-vspace: 18pt,
  title-text-args: auto,
  reference-font: auto,
  reference-size: 字号.小四,
  font: auto,
  size: auto,
  above: auto,
  below: auto,
  indent: (0pt, 18pt, 28pt, 38pt),
  fill: (repeat([.], gap: 0.15em),),
  gap: .3em,
  ..args,
) = {
  fonts = 字体 + fonts
  if title-text-args == auto {
    title-text-args = (font: 章标题字体, size: 章标题字号, weight: "bold")
  }
  if reference-font == auto {
    reference-font = fonts.宋体
  }
  if font == auto {
    font = (fonts.黑体, fonts.宋体, fonts.宋体, fonts.宋体)
  }
  if size == auto {
    size = (字号.小四, 字号.小四, 字号.小四, 字号.小四)
  }
  if above == auto {
    above = (20pt, 14pt, 14pt, 14pt)
  }
  if below == auto {
    below = (14pt, 10pt, 10pt, 10pt)
  }

  section-break(open-right: open-right)

  set text(font: reference-font, size: reference-size)

  {
    set align(center)
    text(..title-text-args, title)
    invisible-heading(level: 1, outlined: outlined, title)
  }

  v(title-vspace)

  set outline(indent: level => indent.slice(0, calc.min(level + 1, indent.len())).sum())
  show outline.entry: entry => block(
    above: above.at(entry.level - 1, default: above.last()),
    below: below.at(entry.level - 1, default: below.last()),
    link(
      entry.element.location(),
      entry.indented(
        none,
        {
          text(
            font: font.at(entry.level - 1, default: font.last()),
            size: size.at(entry.level - 1, default: size.last()),
            {
              let no-label = "label" in entry.element.fields() and str(entry.element.label) == "no-numbering"
              if entry.prefix() not in (none, []) and not no-label {
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
    ),
  )

  // 目录条目不登记引用：标题中的 @cite 显示为正文顺序编号文本，不参与编号
  show cite: outline-cite

  outline(title: none, depth: depth)
}
