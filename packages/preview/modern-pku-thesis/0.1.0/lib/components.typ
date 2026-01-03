// lib/components.typ - UI 组件
// 目录、图表列表、代码块、三线表等可复用组件

#import "config.typ": (
  appendixcounter, chaptercounter, front-heading, partcounter, 字号, 引用记号,
)
#import "utils.typ": bodytotextwithtrim, chinesenumbering

// 中文目录
// 使用 Typst 原生 outline + show rule 实现
#let chineseoutline(title: "目录", depth: none, indent: false) = {
  front-heading(title)

  // Word 模板中目录的行距为 20pt
  set par(leading: 10.5pt, spacing: 10.5pt, justify: true)

  show outline.entry: it => context {
    let el = it.element
    let el_loc = el.location()

    // 前置部分（part < 2）的无编号章节不出现在目录中
    if partcounter.at(el_loc).first() < 2 and el.numbering == none {
      return
    }

    // 格式化编号
    let maybe_number = if el.numbering != none {
      if el.numbering == chinesenumbering {
        chinesenumbering(
          ..counter(heading).at(el_loc),
          location: el_loc,
        )
      } else {
        numbering(el.numbering, ..counter(heading).at(el_loc))
      }
      h(1em)
    }

    // 缩进
    if indent {
      h(1em * (el.level - 1))
    }

    // Word 模板中目录中一级标题的段前间距为 6pt
    if el.level == 1 {
      v(6pt)
    }

    // 编号
    if maybe_number != none {
      link(el_loc, if el.level == 1 {
        strong(maybe_number)
      } else {
        maybe_number
      })
    }

    // 标题文本
    link(el_loc, if el.level == 1 {
      strong(el.body)
    } else {
      el.body
    })

    // 填充点
    box(width: 1fr, [#h(2pt) #box(width: 1fr, repeat[.]) #h(2pt)])

    // 页码处理：
    // - 正文第一章（counter(heading) == 1 且不是附录）会重置页码为 1
    // - 此时 outline.entry.page() 返回的是重置前的值，需要手动返回 "1"
    // - 附录第一章虽然 counter(heading) 也是 (1,)，但不会重置页码
    // - 其他章节直接使用 outline.entry.page()
    let heading_counter = counter(heading).at(el_loc)
    let is-appendix = appendixcounter.at(el_loc).first() >= 10
    let is-first-body-chapter = (
      el.level == 1
        and el.numbering != none
        and heading_counter == (1,)
        and not is-appendix
    )

    // 页码可点击跳转
    link(el_loc, if is-first-body-chapter {
      // 正文第一章，页码固定为 1
      "1"
    } else {
      it.page()
    })

    linebreak()
  }

  outline(title: none, target: heading.where(outlined: true), depth: depth)
}

// 图表列表（插图、表格、代码）
// 使用 Typst 原生 outline + show rule 实现
#let listoffigures(title: "插图", kind: image, supplements: 引用记号) = {
  front-heading(title)

  show outline.entry: it => context {
    let el = it.element
    let el_loc = el.location()

    // 格式化编号（带前缀：图/表/代码）
    let prefix = if kind == image {
      supplements.图
    } else if kind == table {
      supplements.表
    } else if kind == "code" {
      supplements.代码
    } else {
      ""
    }
    let maybe_number = {
      prefix
      chinesenumbering(
        chaptercounter.at(el_loc).first(),
        counter(figure.where(kind: kind)).at(el_loc).first(),
        location: el_loc,
      )
      h(0.5em)
    }

    // 编号
    link(el_loc, maybe_number)

    // Caption 文本
    link(el_loc, bodytotextwithtrim(el.caption.body))

    // 填充点
    box(width: 1fr, [#h(2pt) #box(width: 1fr, repeat[.]) #h(2pt)])

    // 页码：使用 outline.entry.page() 获取正确的格式化页码
    link(el_loc, it.page())

    linebreak()
    v(-0.2em)
  }

  outline(title: none, target: figure.where(kind: kind))
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
    breakable: true,
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
