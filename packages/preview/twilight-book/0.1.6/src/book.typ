#import "../themes/index.typ" : * // 导入主题设置模块 / Import theme settings module

#import "models.typ" : * // 导入模块 / Import models module

// 用于弥补缺少 `std` 作用域的工作区。
// Workaround for missing `std` scope in workspace.
#let std-bibliography = bibliography
#let std-smallcaps = smallcaps
#let std-upper = upper

// A utility function to check if an element is a heading / 判断元素是否为标题
#let is-heading(it) = {
  it.func() == heading
}

// 递归函数 / Wrapper function
#let wrapp-section(
  body, // The body content / 主体内容
  depth: 1, // The heading depth to wrap / 要包装的标题深度
  wrapper: none, // The wrapper function / 包装函数
) = {
  // The heading of the current section / 当前部分的标题
  let heading = none
  // The content of the current section / 当前部分的内容
  let section = ()

  for it in body.at("children", default: ()) { // Iterate through each child element in the body / 遍历正文中的每个子元素, 如果没有则默认为空元组
    let x = it.func(); // Get the function name of the element / 获取元素的函数名称
    
    if (is-heading(it) and it.fields().at("depth") < depth) { // If it's a heading with depth less than the specified depth / 如果是深度小于指定深度的标题
      if heading != none { // 如果标题不为空 / if heading is not none
        wrapper(heading: heading, section: section.join()) // 递归包装当前部分 / Recursively wrap the current section
        heading = none // Reset heading / 重置标题
        section = () // Reset section / 重置章节
      }
      it
    } else if is-heading(it) and it.fields().at("depth") == depth { // If it's a heading with the specified depth / 如果是指定深度的标题
      if heading != none { // 如果标题不为空 / if heading is not none
        // Complete the last section
        wrapper(heading, section.join()) // 递归包装当前部分 / Recursively wrap the current section
        heading = none // Reset heading / 重置标题
        section = () // Reset section / 重置章节
      }
      heading = it
    } else if heading != none {
      // Continue the current section
      section.push(it) // Add the element to the current section / 将元素添加到当前部分
    } else {
      it // if not in any section (before the first heading of the appropriate depth) / 如果不在任何部分内（在适当深度的第一个标题之前)
    }
  }

  // Complete the last section / 完成最后一部分
  if heading != none {
    wrapper(heading, section.join())
  }
}

#let nest-block(body, depth: 1, line-color: white, inset: 1em) = {
  wrapp-section(
    depth: depth,
    wrapper: (heading, content) => {
      block(
        stroke: (left: line-color),
        inset: (left: inset),
      )[
        #heading
        #nest-block(depth: depth + 1, content, line-color: line-color, inset: inset)
      ]
    }
  )[#body]
}

// Main function / 主函数
#let book(
  body,
  title: "晨昏之书", // 文件名 / File name
  author: "跨越晨昏", // 作者 / Author
  theme: "abyss", // 主题名称 / Theme name
  depth: 1, // 目录深度 / Table of contents depth
  wrapper: none, // 
  paper-size: "a4", // 纸张尺寸 / Paper size
  text-size: 12pt, // 文字大小 / Text size
  hanging-indent: 3em, // 悬挂缩进 / Hanging indent
  inset: 1em, // 内容边距 / Content inset
  date: none, // 日期 / Date
  date-format: "[year repr:full]-[month padding:zero]-[day padding:zero]", // 日期格式 / Date format
  abstract: none, // 摘要 / Abstract
  preface: none, // 前言 / Foreword
  table-of-contents: outline(title: "目录"), // 目录设置 / Table of contents settings
  appendix: ( // 附录设置 / Appendix settings
    enabled: false,
    title: "附录",
    body: (),
  ),
  figure-index: ( // 显示图图像的索引 / Figure index settings
    enabled: true,              // 是否启用 / Whether enabled
    title: "",                  // 标题 / Title
  ),
  table-index: ( // 显示表格的索引 / Table index settings
    enabled: true,              // 是否启用 / Whether enabled
    title: "",                  // 标题 / Title
  ),
  listing-index: ( // 代码清单索引设置 / Listing index settings
    enabled: true,              // 是否启用 / Whether enabled
    title: "",                  // 标题 / Title
  ),
  bibliographys: none, // 参考文献 / Bibliography
) = {
  // Load theme settings / 加载主题设置
  let background-color = themes(theme: theme, setting: "background-color")
  let text-color = themes(theme: theme, setting: "text-color")
  let stroke-color = themes(theme: theme, setting: "stroke-color")
  let fill-color = themes(theme: theme, setting: "fill-color")
  let line-color = themes(theme: theme, setting: "line-color")
  let cover-image = themes(theme: theme, setting: "cover-image")
  let preface-image = themes(theme: theme, setting: "preface-image")
  let content-image = themes(theme: theme, setting: "content-image")

  // Apply theme settings to the document / 将主题设置应用于文档
  set document(title: title, author: author) // 设置文档元数据 / Set document metadata
  
  set page( // 页面设置 / Page settings
    fill: background-color, // 页面背景颜色 / Page background color
    paper: paper-size, // 纸张尺寸 / Paper size
    margin: (bottom: 1.75cm, top: 2.25cm), // 底部和顶部边距 / Bottom and top margins
  )

  set text( // 文字设置 / Text settings
    fill: text-color, // 文字颜色 / Text color
    size: text-size, // 文字大小 / Text size
    lang: "zh",                 // 语言设置为中文 / Language set to Chinese
    font: serif-family          // 使用衬线字体家族 / Use serif font family
  )

  // 表格开始
  show table: set text(fill: text-color) // 设置表格文字颜色 / Set table text color

  show table.cell.where(y: 0): smallcaps  // 对表头行使用小型大写字母 / Use small caps for table header rows.

  set table(
    inset: 7pt, // 增加表格单元格的内边距 / Increase table cell padding
    stroke: (0.5pt + themes(theme: theme, setting: "stroke-color")), // 描边 / Stroke
    fill: themes(theme: theme, setting: "background-color"),     // 填充 / Fill
  ) // 表格结束
  
  { // 封面部分 / Cover part
    setup-cover(
    title: title,
    author: author,
    date: date,
    date-format: date-format,
    abstract: abstract,
    cover-style: theme,
    theme: theme
  )
  } // 封面结束 / End of cover part

  // Foreword part / 前言部分
  {
    setup-foreword(
      preface: preface,
      theme: theme
    )
  }
  // 前言部分结束 / End of foreword part
  
  // 目录开始 / Table of contents part
  {
    setup-table-of-contents(
      table-of-contents: table-of-contents
    )
  } // 目录结束 / End of table of contents part

  { // 正文开始 / Start of body part
    set page(
      background: set_background(content-image),  // 背景图片 / Background image
      footer: context {           // 页脚上下文 / Footer context
        // 获取当前页码。
        // Get current page number.
        let i = counter(page).at(here()).first()

        // 获取总页码
        // Get total page count
        let total = counter(page).final().first()

        // 居中对齐
        // Center alignment
        let is-odd = calc.odd(i)  // 判断是否为奇数页 / Check if odd page
        let aln = center          // 对齐方式 / Alignment

        // 我们是否在开始新章节的页面上？
        // Are we on a page that starts a new chapter?
        let target = heading.where(level: 1) // 一级标题 / Level 1 heading
        if query(target).any(it => it.location().page() == i) {
          return align(aln)[#i / #total]   // 返回页码 / Return page number
        }

        // 查找当前所在部分的章节。
        // Find the chapter of the current section.
        let before = query(target.before(here())) // 当前位置之前的标题 / Headings before current position
        if before.len() > 0 {
          let current = before.last() // 当前章节 / Current chapter
          let gap = 1.75em           // 间距 / Gap
          // 显示章节名称
          // Display chapter name
          let chapter = upper(text(size: 0.7em, fill: themes(theme: theme, setting: "text-color"), current.body)) // 章节名称大写 / Chapter name uppercase
          if current.numbering != none {
            align(aln)[#chapter]  // 对齐章节名称 / Align chapter name
            align(aln)[#i / #total]     // 对齐页码 / Align page number
          }
        }
      },
    )

    set heading(numbering: "1.", hanging-indent: hanging-indent) // 编号格式和悬挂缩进 / Numbering format and hanging indent

    // 显示标题时设置标题字体 / Set title font when displaying headings
    show heading: x => {
      set text(font: art-font)  // 使用标题字体 / Use title font
      x                           // 返回内容 / Return content
    }

    // 显示粗体,上下划线,时设置无衬线字体 / Set sans-serif font when displaying strong text
    show selector.or(strong, emph, underline, strike, overline): x => {
      set text(font: sans-family) // 使用无衬线字体家族 / Use sans-serif font family
      x                           // 返回内容 / Return content
    }

    // 显示原始代码时设置等宽字体 / Set monospace font when displaying raw code
    show raw: x => {
      set text(font: mono-family) // 使用等宽字体家族 / Use monospace font family
      x                           // 返回内容 / Return content
    }

    wrapp-section( // 使用wrapp-section递归包装正文 / Wrap the body with wrapp-section
      body,
      depth: 1,
      wrapper: (heading, content) => {
        heading
        nest-block(depth: 2, content, line-color: line-color, inset: inset)
      }
    )
  } // 正文结束 / End of body part

  { // 附录开始 / Appendix part
    if appendix.enabled {       // 如果启用附录 / If appendix is enabled
      pagebreak()               // 分页 / Page break
      heading(level: 1)[#appendix.at("title", default: "附录")] // 附录标题 / Appendix title

      // 重制标题计数器
      // Reset heading counter
      counter(heading).update(0) // 更新计数器为0 / Update counter to 0
      // 对于附录中的标题前缀，标准约定是 A.1.1.
      // For heading prefixes in appendix, standard convention is A.1.1.
      set heading(numbering: "A.1.") // 设置附录标题编号 / Set appendix heading numbering

      appendix.body             // 附录内容 / Appendix content
    }
  } // 附录结束 / End of appendix part

  { // 参考文献开始 / Bibliography part
    if bibliographys != none {  // 如果有参考文献 / If bibliography exists
      pagebreak()               // 分页 / Page break
      set text(font: mono-family) // 设置附录字体 / Set appendix font
      show std-bibliography: set text(0.85em, fill: text-color) // 设置参考文献文本样式 / Set bibliography text style
      // 对参考文献使用默认段落属性。
      // Use default paragraph properties for bibliography.
      show std-bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto) // 设置参考文献段落属性 / Set bibliography paragraph properties
      bibliographys             // 显示参考文献 / Display bibliography
    }
  } // 参考文献结束 / End of bibliography part

  { // 显示图、表和代码清单的索引开始 / Start of figure, table, and listing indexes
    let fig-t(kind) = figure.where(kind: kind) // 根据类型获取图形 / Get figures by kind
    let has-fig(kind) = counter(fig-t(kind)).get().at(0) > 0 // 检查是否有该类型图形 / Check if figures of kind exist
    if figure-index.enabled or table-index.enabled or listing-index.enabled { // 如果启用任何索引 / If any index is enabled
      show outline: set heading(outlined: true) // 设置大纲标题 / Set outline headings
      context {
        let imgs = figure-index.enabled and has-fig(image) // 是否有图片索引 / If figure index exists
        let tbls = table-index.enabled and has-fig(table)  // 是否有表格索引 / If table index exists
        let lsts = listing-index.enabled and has-fig(raw)  // 是否有代码索引 / If listing index exists
        if imgs or tbls or lsts { // 如果有任何索引 / If any index exists
          // 注意，我们只分页一次，而不是为每个单独的索引分页。这是因为对于只有少量图的文档，在每个索引处都开始新页会导致过多的空白。
          // Note: we only page break once, not for each individual index. This is because for documents with only a few figures, starting a new page at each index would result in too much whitespace.
          pagebreak()             // 分页 / Page break
        }

        if imgs {                 // 如果有图片索引 / If figure index exists
          outline(
            title: figure-index.at("title", default: "图表索引"), // 图表索引标题 / Figure index title
            target: fig-t(image), // 目标为图片 / Target is images
          )
        }
        if tbls {                 // 如果有表格索引 / If table index exists
          outline(
            title: table-index.at("title", default: "表格索引"), // 表格索引标题 / Table index title
            target: fig-t(table), // 目标为表格 / Target is tables
          )
        }
        if lsts {                 // 如果有代码索引 / If listing index exists
          outline(
            title: listing-index.at("title", default: "代码索引"), // 代码索引标题 / Listing index title
            target: fig-t(raw),   // 目标为代码 / Target is code listings
          )
        }
      }
    }
  } // 显示图、表和代码清单的索引结束 / End of figure, table, and listing indexes
}
