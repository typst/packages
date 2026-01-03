// lib/components.typ - UI 组件
// 目录、图表列表、代码块、三线表等可复用组件

#import "config.typ": chaptercounter, front-heading, partcounter, 字号
#import "utils.typ": bodytotextwithtrim, chinesenumbering, lengthceil

// 中文目录
#let chineseoutline(title: "目录", depth: none, indent: false) = {
  front-heading(title)
  context {
    let it = here()
    let elements = query(heading.where(outlined: true).after(it))

    // Word 模板中目录的行距为 20pt
    set par(leading: 10.5pt, spacing: 10.5pt, justify: true)

    for el in elements {
      // 前置部分（part < 2）的无编号章节不出现在目录中
      if partcounter.at(el.location()).first() < 2 and el.numbering == none {
        continue
      }

      // 跳过层级过深的标题
      if depth != none and el.level > depth { continue }

      let maybe_number = if el.numbering != none {
        if el.numbering == chinesenumbering {
          chinesenumbering(
            ..counter(heading).at(el.location()),
            location: el.location(),
          )
        } else {
          numbering(el.numbering, ..counter(heading).at(el.location()))
        }
        h(1em)
      }

      let line = {
        if indent {
          h(1em * (el.level - 1))
        }

        // Word 模板中目录中一级标题的段前间距为 6pt
        if el.level == 1 {
          v(6pt)
        }

        if maybe_number != none {
          context {
            let width = measure(maybe_number).width
            box(
              width: lengthceil(width),
              link(el.location(), if el.level == 1 {
                strong(maybe_number)
              } else {
                maybe_number
              }),
            )
          }
        }

        link(el.location(), if el.level == 1 {
          strong(el.body)
        } else {
          el.body
        })

        // 填充点
        box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))

        // 页码
        let footer = query(selector(<__footer__>).after(el.location()))
        let page_number = if footer == () {
          // 最后一页没有后续 footer，直接使用 heading 位置的页码
          counter(page).at(el.location()).first()
        } else {
          counter(page).at(footer.first().location()).first()
        }

        str(page_number)

        linebreak()
      }

      line
    }
  }
}

// 图表列表（插图、表格、代码）
#let listoffigures(title: "插图", kind: image) = {
  front-heading(title)
  context {
    let it = here()
    let elements = query(figure.where(kind: kind).after(it))

    for el in elements {
      let maybe_number = {
        let el_loc = el.location()
        chinesenumbering(
          chaptercounter.at(el_loc).first(),
          counter(figure.where(kind: kind)).at(el_loc).first(),
          location: el_loc,
        )
        h(0.5em)
      }
      let line = {
        context {
          let width = measure(maybe_number).width
          box(
            width: lengthceil(width),
            link(el.location(), maybe_number),
          )
        }

        link(el.location(), bodytotextwithtrim(el.caption.body))

        // 填充点
        box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))

        // 页码
        let footers = query(selector(<__footer__>).after(el.location()))
        let page_number = if footers == () {
          counter(page).at(el.location()).first()
        } else {
          counter(page).at(footers.first().location()).first()
        }
        link(el.location(), str(page_number))
        linebreak()
        v(-0.2em)
      }

      line
    }
  }
}

// 代码块组件
// 用法: #codeblock(```python ... ```, caption: "示例代码")
#let codeblock(raw, caption: none) = {
  figure(
    {
      set align(left)
      raw
    },
    caption: caption,
    kind: "code",
    supplement: "",
  )
}

// 三线表组件
// 基于 Typst 原生 table，支持所有 table 参数（stroke 除外）
//
// booktab 专用参数:
//   width: 表格外层容器宽度，默认 auto
//   caption: 表格标题（设为 none 且 outlined 为 false 时不使用 figure）
//   outlined: 是否包装在 figure 中（默认 true），设为 false 时生成纯表格
//
// 必须指定 columns 参数（用于分离表头行），其他参数直接传递给 table
// stroke 参数会被忽略（三线表有固定的线条样式）
//
// 用法:
//   // 带标题的表格（出现在表格列表中）
//   #booktab(
//     columns: 3,
//     caption: "示例表格",
//     [表头1], [表头2], [表头3],
//     [内容1], [内容2], [内容3],
//   )
//
//   // 纯表格（不带标题和编号）
//   #booktab(
//     columns: 2,
//     outlined: false,
//     [代码], [结果],
//     [...], [...],
//   )
#let booktab(width: auto, caption: none, outlined: true, ..args) = {
  let table-args = args.named()
  let all-cells = args.pos()

  // 从 columns 推断列数（必须指定）
  let columns = table-args.at("columns", default: 1)
  let col-count = if type(columns) == int { columns } else if (
    type(columns) == array
  ) { columns.len() } else { 1 }

  if all-cells.len() < col-count {
    panic("booktab: not enough cells for header row")
  }

  // 分离表头和内容
  let headers = all-cells.slice(0, col-count)
  let contents = all-cells.slice(col-count)

  // 移除 stroke（三线表固定样式）
  let _ = table-args.remove("stroke", default: none)

  set text(字号.表文, top-edge: "ascender")

  let the-table = block(
    width: width,
    table(
      stroke: none,
      ..table-args,
      // 表头行
      table.hline(stroke: 1.5pt),
      ..headers.map(strong),
      table.hline(stroke: 0.75pt),
      // 内容行
      ..contents,
      table.hline(stroke: 1.5pt),
    ),
  )

  if outlined {
    figure(the-table, caption: caption, kind: table)
  } else {
    the-table
  }
}
