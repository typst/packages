// ============================================================
// utils.typ — 工具函数与论文组件
// 本文件包含三大部分：
//   1. 状态管理（计数器、附录切换、中文编号）
//   2. 页面排版辅助（文本换行、字段网格、学位类型选择框）
//   3. 论文组件（三线表、代码块）
// ============================================================

#import "const.typ": font, size

// ========== 计数器定义 ==========

// partcounter 状态:
//   0 = 封面区域（无页眉页脚）
//   1 = 前置部分（罗马数字页码，有页眉）
//   2 = 正文部分（阿拉伯数字页码，有页眉）

#let partcounter = counter("part")
#let chaptercounter = counter("chapter")
#let appendixcounter = counter("appendix")
#let footnotecounter = counter(footnote)
#let rawcounter = counter(figure.where(kind: "code"))
#let imagecounter = counter(figure.where(kind: image))
#let tablecounter = counter(figure.where(kind: table))
#let equationcounter = counter(math.equation)

/// 跳过页状态：用于 always-start-odd 时标记被跳过的空白偶数页。
#let skippedstate = state("skipped", false)

// ========== 辅助函数 ==========

/// 附录切换函数：在正文末尾调用，进入附录模式
/// 发射 pkuthss-appendix 元数据标记（用于触发参考文献渲染）
/// 并将附录计数器置为 10（>=10 即表示附录区域），重置章节和标题计数器
#let appendix() = {
  metadata("pkuthss-appendix")
  appendixcounter.update(10)
  chaptercounter.update(0)
  counter(heading).update(0)
}

/// 阿拉伯数字转中文数字（如 3 → "三"）
#let chinesenumber(num) = numbering("一", num)

/// 年份转中文（如 2026 → "二〇二六"）。
#let chineseyear(year) = (
  str(year)
    .clusters()
    .map(it => ("〇", "一", "二", "三", "四", "五", "六", "七", "八", "九").at(
      int(it),
    ))
    .join("")
)

/// 中文章节编号格式化
/// - 正文部分（appendix < 10）：一级标题显示"第X章"，多级显示"X.X"
/// - 附录部分（appendix >= 10）：一级显示"附录 A"，多级显示"A.X"
/// brackets: 是否为公式引用加括号（如"(1.1)"）
#let chinesenumbering(..nums, location: none, brackets: false) = context {
  let actual_loc = if location == none { here() } else { location }
  if appendixcounter.at(actual_loc).first() < 10 {
    if nums.pos().len() == 1 {
      "第" + chinesenumber(nums.pos().first()) + "章"
    } else {
      numbering(if brackets { "(1.1)" } else { "1.1" }, ..nums)
    }
  } else {
    if nums.pos().len() == 1 {
      "附录 " + numbering("A.1", ..nums)
    } else {
      numbering(if brackets { "(A.1)" } else { "A.1" }, ..nums)
    }
  }
}

/// 将用户传入的文件路径解析为可被 `image()` / `read()` 直接使用的路径
/// - `path` 类型：在调用处创建，可穿透包沙箱访问用户项目文件
/// - `str` 类型：按本地开发模式处理，路径相对项目根目录（函数位于 format/ 下，需回溯一层）
#let _resolve-path(p) = if type(p) == path { p } else { ("../" + p) }

/// 校验图片文件不是 eps 格式（Typst 的 `image()` 仅支持 png/jpg/gif/webp/svg/pdf）
/// 通过文件头魔数 `%!PS-Adobe` 识别 eps，避免报出晦涩的 "unknown image format"
/// 返回原路径，以便直接传给 `image()`
#let _ensure-not-eps(p) = {
  let b = read(p, encoding: none)
  assert(
    not (b.len() >= 10 and b.slice(0, 10) == bytes("%!PS-Adobe")),
    message: "图片不支持 eps 格式：Typst 仅支持 png/jpg/gif/webp/svg/pdf，请先转换为支持的格式，或者直接用 CTAN pkuthss 包里的 PDF 文件",
  )
  p
}

// ========== 页面排版工具 ==========

/// 按指定宽度拆分文本，返回字符串数组，每行不超过 max-width。
/// 用于封面页长标题的自动换行。支持中英文混合及空格分词。
#let split-text-by-width(text-content, max-width) = {
  let chars = if type(text-content) == str {
    text-content.clusters()
  } else {
    str(text-content).clusters()
  }

  let is-word-char = (c) => {
    c.len() == 1 and c != " " and c != "\t" and c != "\n"
  }

  let tokens = ()
  let i = 0
  while i < chars.len() {
    let c = chars.at(i)
    if c == "\n" {
      tokens.push(("\n", true))
      i += 1
    } else if c == " " or c == "\t" {
      if i + 1 < chars.len() and is-word-char(chars.at(i + 1)) {
        let word = c
        i += 1
        while i < chars.len() and is-word-char(chars.at(i)) {
          word += chars.at(i)
          i += 1
        }
        tokens.push((word, false))
      } else {
        tokens.push((c, true))
        i += 1
      }
    } else if is-word-char(c) {
      let word = c
      i += 1
      while i < chars.len() and is-word-char(chars.at(i)) {
        word += chars.at(i)
        i += 1
      }
      tokens.push((word, false))
    } else {
      tokens.push((c, false))
      i += 1
    }
  }

  let result = ()
  let current = ""

  for (token, is-space) in tokens {
    if token == "\n" {
      if current.len() > 0 {
        result.push(current.trim())
      }
      current = ""
    } else {
      let next = current + token
      if measure(next).width > max-width {
        if current.len() > 0 {
          result.push(current.trim())
        }
        if is-space {
          current = ""
        } else {
          current = token.trim()
        }
      } else {
        current = next
      }
    }
  }

  if current.len() > 0 {
    result.push(current.trim())
  }

  result
}

/// 未选中复选框（空心方框）
#let sym-box-unchecked(size) = box(width: size, align(
  center + horizon,
  square(size: size),
))

/// 选中复选框（方框内带 ✓）。
#let sym-box-checked(size) = box(width: size, align(
  center + horizon,
  square(size: size)[✓],
))

/// 构建封面页的字段网格（如姓名、学号等），支持自动换行
/// fields: 数组，每项为 (字段名, 字段值) 元组
/// name-width / value-width: 两列宽度
/// row-height: 每行高度
#let build-field-grid(fields, name-width, value-width, row-height, font: font) = context {
  let grid-contents = ()

  for (name, value) in fields {
    let value-parts = split-text-by-width(value, value-width)
    for (i, part) in value-parts.enumerate() {
      if i == 0 {
        grid-contents.push([#strong(name)#v(0.5em)])
      } else {
        grid-contents.push([])
      }
      grid-contents.push([
        #set align(center)
        #set text(size: size.三号, font: font.仿宋)
        #part
        #v(0.5em)
      ])
    }
  }

  grid(
    columns: (name-width, value-width),
    rows: row-height,
    row-gutter: 0.5em,
    stroke: (x, y) => if x == 1 { (bottom: 1pt) } else { none },
    ..grid-contents,
  )
}

/// 学位类型选择框
/// degree-type: "academic"（学术学位）或 "professional"（专业学位）
/// 其他值会触发 assert 报错
#let degree-type-checkbox(degree-type) = {
  assert(
    degree-type == "academic" or degree-type == "professional",
    message: "degree-type 必须是 \"academic\" 或 \"professional\"，当前值: "
      + repr(degree-type),
  )
  let academic-box = if degree-type == "academic" {
    sym-box-checked(12pt)
  } else {
    sym-box-unchecked(12pt)
  }
  let professional-box = if degree-type == "professional" {
    sym-box-checked(12pt)
  } else {
    sym-box-unchecked(12pt)
  }
  set align(center + horizon)
  [#academic-box#h(0.5em)学术学位#h(4 * 0.5em)#professional-box#h(0.5em)专业学位]
}

// ========== 列表符号 ==========

#let sym-circle(size) = box(
  width: 1em,
  align(
    center + horizon,
    circle(radius: size / 2, fill: black)
  ),
)

#let sym-square(size) = box(
  width: 1em,
  align(
    center + horizon,
    square(size: size, fill: black)
  ),
)

#let sym-rhombus(size) = box(
  width: 1em,
  align(
    center + horizon,
    rotate(45deg, square(size: size, fill: black))
  ),
)

// ========== 三线表组件 ==========

/// 计算表格列数：int 直接返回，array 返回长度，否则默认为 1
#let _booktab-column-count(columns) = if type(columns) == int {
  columns
} else if type(columns) == array { columns.len() } else { 1 }

/// 三线表内部构建块：block 包裹的 table
/// 固定顶线 1.5pt、表头线 0.75pt、底线 1.5pt
/// footer: 可选的 table.footer 内容
#let _booktab-block(table-args, header, body, width: auto, footer: none) = block(
  width: width,
  breakable: true,
  {
    set text(size: size.表文)
    table(
      stroke: none,
      ..table-args,
      table.hline(stroke: 1.5pt),
      header,
      table.hline(stroke: 0.75pt),
      ..body,
      ..if footer != none { (footer,) } else { () },
      table.hline(stroke: 1.5pt),
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
    set text(size: size.表文)
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
  // 无显式 header 时：取前列数个单元格作为表头
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

// ========== 代码块组件 ==========

/// 代码块组件
/// raw: 由 ``` 标记的 raw 代码块
/// caption: 代码标题（可选，有标题时可被 @label 引用）
/// 省略 caption 时仅显示代码，不编号、不入列表、不可引用
#let codeblock(raw, caption: none) = {
  if caption != none {
    figure(
      {
        set align(left)
        raw
      },
      caption: caption,
      kind: "code",
      supplement: "",
    )
  } else {
    raw
  }
}
