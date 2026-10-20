// ============================================================
// booktab.typ — 三线表组件
// 提供学术三线表的创建与装饰：booktab、as-booktab
// 以及依赖 booktab 的代码渲染对比表 code-preview
// ============================================================

#import "../utils/style.typ": style
#import "../utils/counter.typ": continued-caption-state

/// 续表标记状态：表格渲染前重置，跨页续表时在表头显示"续表 X.Y 名称"
#let _booktab-xubiao = state("booktab-xubiao")

/// 计算表格列数：int 直接返回，array 返回长度，否则默认为 1
#let _booktab-column-count(columns) = if type(columns) == int {
  columns
} else if type(columns) == array { columns.len() } else { 1 }

/// 三线表内部构建块：block 包裹的 table
/// 固定顶线 1.5pt、表头线 0.75pt、底线 1.5pt
/// 顶线与表头线放在 table.header 内，跨页时随表头一起重复；
/// 表头前插入跨列"续表"行：首页隐形占位，续表页居中显示完整表题（"续表 X.Y 名称"）
/// 表题取自 figure-show-rule 注入的 continued-caption-state
/// footer: 可选的 table.footer 内容
#let _booktab-block(table-args, header, body, width: auto, footer: none) = block(
  width: width,
  breakable: true,
  {
    _booktab-xubiao.update(false)
    let col-count = _booktab-column-count(table-args.at("columns", default: 1))
    set text(size: style.表单元格.size)
    table(
      stroke: none,
      ..table-args,
      table.header(
        table.cell(colspan: col-count, {
          context {
            if _booktab-xubiao.get() {
              let c = continued-caption-state.get()
              if c != none {
                let num = c.counter.display(c.numbering)
                align(center)[#text(size: style.表序表名.size, "续" + c.supplement + h(0.25em) + num + h(1em) + c.body)]
              } else {
                align(right)[续表]
              }
            } else {
              v(-0.9em)
              _booktab-xubiao.update(true)
            }
          }
        }),
        table.hline(stroke: style.三线表.顶线),
        ..header.children,
        table.hline(stroke: style.三线表.表头线),
      ),
      ..body,
      ..if footer != none { (footer,) } else { () },
      table.hline(stroke: style.三线表.底线),
    )
  },
)

/// 创建并可选包装为 figure 的三线表
/// 第一行位置参数自动作为表头行（strong 加粗）
/// outlined: true 时包装为 figure(kind: table)，支持 caption 和 @ 引用
/// 支持所有 table 的命名参数（除 stroke 被固定为 none）
/// 示例：
///   #booktab(
///     columns: 3,
///     caption: [示例表格],
///     [列1], [列2], [列3],
///     [数据], [数据], [数据],
///   )
#let booktab(width: auto, caption: none, outlined: true, ..args) = {
  let table-args = args.named()
  let all-cells = args.pos()
  let columns = table-args.at("columns", default: 1)
  let col-count = _booktab-column-count(columns)
  if all-cells.len() < col-count {
    panic("booktab: not enough cells for header row")
  }
  let headers = all-cells.slice(0, col-count)
  let contents = all-cells.slice(col-count)
  let _ = table-args.remove("stroke", default: none)
  let the-table = _booktab-block(
    table-args,
    table.header(..headers.map(cell => table.cell[#strong(cell)])),
    contents,
    width: width,
  )
  if outlined {
    figure(the-table, caption: caption, kind: table)
  } else {
    the-table
  }
}

/// 将 table.cell 的内容用 strong 包裹（用于 as-booktab 的表头单元）
#let _booktab-header-cell(cell) = {
  if cell.func() != table.cell {
    cell
  } else {
    let cell-args = cell.fields()
    let body = cell-args.remove("body")
    table.cell(..cell-args)[#strong(body)]
  }
}

/// 不修改 table 结构，仅包裹在 block 中设置表文字号
#let _booktab-unstyled(it, width: auto) = block(
  width: width,
  breakable: true,
  {
    set text(size: style.表单元格.size)
    it
  },
)

/// 将现有原生 table 装饰为三线表样式
/// 自动识别 table.header，或取前 N 个单元格作为表头
/// 若 table 已包含 table.hline，则仅包裹不修改（保留已有样式）
/// 示例：
///   #figure(
///     as-booktab(table(
///       columns: 3,
///       [列1], [列2], [列3],
///       [数据], [数据], [数据],
///     )),
///     caption: [示例表格],
///     kind: table,
///   )
#let as-booktab(it, width: auto) = {
  if it.func() != table { panic("as-booktab: expected a table") }
  let table-args = it.fields()
  let children = table-args.remove("children")
  // 已有 hline 时仅包裹（保留手动样式）
  if children.any(child => child.func() == table.hline) {
    return _booktab-unstyled(it, width: width)
  }
  let _ = table-args.remove("stroke", default: none)
  let header = children.find(child => child.func() == table.header)
  let footer = children.find(child => child.func() == table.footer)
  if header != none {
    let body = children.filter(child => (
      child.func() != table.header and child.func() != table.footer
    ))
    return _booktab-block(
      table-args,
      table.header(..header.children.map(_booktab-header-cell)),
      body,
      width: width,
      footer: footer,
    )
  }
  // 无显式 header 时：取前数个单元格作为表头
  let col-count = _booktab-column-count(table-args.at("columns", default: 1))
  let header-cells = ()
  let body = ()
  for child in children {
    if child.func() == table.cell and header-cells.len() < col-count {
      header-cells.push(_booktab-header-cell(child))
    } else { body.push(child) }
  }
  if header-cells.len() < col-count {
    panic("as-booktab: not enough cells for header row")
  }
  _booktab-block(table-args, table.header(..header-cells), body, width: width)
}

/// 代码渲染对比表：两列三线表，分别显示代码与渲染结果
/// 用于文档编写时的"代码 + 结果"并排示例
/// 示例：
///   #code-preview(
///     ```typ
///     *粗体* 与 _斜体_
///     ```,
///     [*粗体* 与 _斜体_],
///   )
#let code-preview(code, result) = {
  booktab(
    columns: (1fr, 1fr),
    outlined: false,
    align(center)[*代码*],
    align(center)[*渲染结果*],
    code,
    result,
  )
}
