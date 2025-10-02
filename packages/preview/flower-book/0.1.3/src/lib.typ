// 本模板基于lib模板https://github.com/talal/ilm 使用DeepSeek修改而成
// This template is based on the lib template https://github.com/talal/ilm and modified by DeepSeek

// 用于弥补缺少 `std` 作用域的工作区。
// Workaround for missing `std` scope in workspace.
#let std-bibliography = bibliography
#let std-smallcaps = smallcaps
#let std-upper = upper

// 用增加字符间距的函数覆盖默认的 `smallcaps` 和 `upper` 函数。
// Override default `smallcaps` and `upper` functions with increased character spacing.
// 默认的字间距（tracking）是 0pt。
// Default character tracking is 0pt.
#let smallcaps(body) = std-smallcaps(text(tracking: 0.6pt, body))
#let upper(body) = std-upper(text(tracking: 0.6pt, body))

// 模板中使用的颜色 - 更改为深色主题
// Colors used in template - changed to dark theme
#let stroke-color = luma(80)  // 描边颜色 / Stroke color
#let fill-color = luma(30)    // 填充颜色 / Fill color

// 字体设置,改编自zh-kit(https://github.com/ctypst/zh-kit)
// Font settings, adapted from zh-kit(https://github.com/ctypst/zh-kit)
#let setup-fonts(
  // 中文字体家族设置 / Chinese font family settings
  cjk-serif-family: (           // 衬线字体 / Serif font family
    "LXGW WenKai",              // 霞鹜文楷 / LXGW WenKai
    "思源宋体 CN",              // Source Han Serif CN
    "Songti SC",                // 宋体 SC / Songti SC
    "SimSun",                   // 宋体 / SimSun
  ),
  cjk-sans-family: (            // 无衬线字体 / Sans-serif font family
    "思源黑体 CN",              // Source Han Sans CN
    "Inter",                    // Inter font
    "PingFang SC",              // 苹方 SC / PingFang SC
    "SimHei"                    // 黑体 / SimHei
  ),
  cjk-mono-family: (            // 等宽字体 / Monospace font family
    "霞鹜文楷 Mono",            // LXGW WenKai Mono
    "WenQuanYi Zen Hei Mono",   // 文泉驿正黑等宽 / WenQuanYi Zen Hei Mono
    "JetBrains Mono",           // JetBrains Mono
    "Source Code Pro",          // Source Code Pro
    "Noto Sans Mono CJK SC",    // Noto Sans Mono CJK SC
    "Menlo",                    // Menlo
    "Consolas",                 // Consolas
  ),
  cjk-title-family: (           // 标题字体 / Title font family
    "DuanNingMaoBiXiaoKai",     // 段宁毛笔小楷 / DuanNingMaoBiXiaoKai
  ),
  latin-serif-family: (         // 拉丁衬线字体 / Latin serif font family
    "Times New Roman",          // Times New Roman
    "Georgia",                  // Georgia
  ),
  latin-sans-family: (          // 拉丁无衬线字体 / Latin sans-serif font family
    "Times New Roman",          // Times New Roman
    "Georgia",                  // Georgia
  ),
  latin-mono-family: (          // 拉丁等宽字体 / Latin monospace font family
    "JetBrains Mono",           // JetBrains Mono
    "Consolas",                 // Consolas
    "Menlo",                    // Menlo
  ),
  latin-title-family: (         // 拉丁标题字体 / Latin title font family
    "",                         // 空字符串 / Empty string
  ),
  first-line-indent: 0em,       // 首行缩进 / First line indent
  doc                           // 文档内容 / Document content
) = {
  // 合并中英文字体家族 / Merge Chinese and English font families
  let serif-family = latin-serif-family + cjk-serif-family
  let sans-family = latin-sans-family + cjk-sans-family
  let mono-family = latin-mono-family + cjk-mono-family
  let title-font = latin-title-family + cjk-title-family

  // 设置文本语言和字体 / Set text language and font
  set text(
    lang: "zh",                 // 语言设置为中文 / Language set to Chinese
    font: serif-family          // 使用衬线字体家族 / Use serif font family
  )

  // 设置段落首行缩进 / Set paragraph first line indent
  set par(first-line-indent: (amount: first-line-indent, all: true))

  // 显示标题时设置标题字体 / Set title font when displaying headings
  show heading: x => {
    set text(font: title-font)  // 使用标题字体 / Use title font
    x                           // 返回内容 / Return content
  }

  // TODO 显示粗体,时设置无衬线字体 / Set sans-serif font when displaying strong text
  show selector.or(strong, emph, underline, strike, overline): x => {
    set text(font: sans-family) // 使用无衬线字体家族 / Use sans-serif font family
    x                           // 返回内容 / Return content
  }

  // 显示原始代码时设置等宽字体 / Set monospace font when displaying raw code
  show raw: x => {
    set text(font: mono-family) // 使用等宽字体家族 / Use monospace font family
    x                           // 返回内容 / Return content
  }

  doc  // 返回文档内容 / Return document content
}

// 此函数获取整个文档作为其 `body`。
// This function takes the entire document as its `body`.
#let flower-book(
  // 您作品的标题。
  // The title of your work.
  title: [Your Title],
  
  // 作者姓名。
  // Author name.
  author: "Author",
  
  // 使用的纸张尺寸。
  // Paper size used.
  paper-size: "a4",
  
  // 将在封面页显示的日期。
  // Date to be displayed on the cover page.
  // 该值需要是 'datetime' 类型。
  // The value needs to be of type 'datetime'.
  // 更多信息: https://typst.app/docs/reference/foundations/datetime/
  // More info: https://typst.app/docs/reference/foundations/datetime/
  // 示例: datetime(year: 2024, month: 03, day: 17)
  // Example: datetime(year: 2024, month: 03, day: 17)
  date: none,
  
  // 日期在封面页上显示的格式。
  // Format for displaying date on the cover page.
  // 更多信息: https://typst.app/docs/reference/foundations/datetime/#format
  // More info: https://typst.app/docs/reference/foundations/datetime/#format
  // 默认格式将日期显示为: MMMM DD, YYYY
  // Default format displays date as: MMMM DD, YYYY
  date-format: "[month repr:long] [day padding:zero], [year repr:full]",
  
  // 您作品的摘要。如果没有，可以省略。
  // Abstract of your work. Can be omitted if none.
  abstract: none,
  
  // 前言页的内容。这将显示在封面页之后。如果没有，可以省略。
  // Content of the preface page. This will be displayed after the cover page. Can be omitted if none.
  preface: none,
  
  // 调用 `outline` 函数的结果或 `none`。
  // Result of calling the `outline` function or `none`.
  // 如果要禁用目录，请将其设置为 `none`。
  // Set to `none` if you want to disable the table of contents.
  // 更多信息: https://typst.app/docs/reference/model/outline/
  // More info: https://typst.app/docs/reference/model/outline/
  table-of-contents: outline(title: "目录"),  // 目录 / Table of Contents
  
  // 在正文之后、参考文献之前显示附录。
  // Display appendix after main body and before bibliography.
  appendix: (
    enabled: false,             // 是否启用附录 / Whether to enable appendix
    title: "",                  // 附录标题 / Appendix title
    heading-numbering-format: "", // 标题编号格式 / Heading numbering format
    body: none,                 // 附录内容 / Appendix content
  ),
  
  // 参考文献
  // Bibliography
  // 调用 `bibliography` 函数的结果或 `none`。
  // Result of calling the `bibliography` function or `none`.
  // 示例: bibliography("refs.bib")
  // Example: bibliography("refs.bib")
  // 更多信息: https://typst.app/docs/reference/model/bibliography/
  // More info: https://typst.app/docs/reference/model/bibliography/
  bibliographys: none,
  
  // 是否在新页开始章节。
  // Whether to start chapters on a new page.
  chapter-pagebreak: true,
  
  // 是否在外部链接旁边显示一个绛红色圆圈。
  // Whether to display a crimson circle next to external links.
  external-link-circle: true,
  
  // 显示图（图像）的索引。
  // Display index of figures (images).
  figure-index: (
    enabled: true,              // 是否启用 / Whether enabled
    title: "",                  // 标题 / Title
  ),
  
  // 显示表的索引
  // Display index of tables
  table-index: (
    enabled: true,              // 是否启用 / Whether enabled
    title: "",                  // 标题 / Title
  ),
  
  // 显示代码清单（代码块）的索引。
  // Display index of code listings (code blocks).
  listing-index: (
    enabled: true,              // 是否启用 / Whether enabled
    title: "",                  // 标题 / Title
  ),
  
  // 字体配置 TODO 删除
  // Font configuration
  fonts: (
    title-font: "DuanNingMaoBiXiaoKai", // 标题字体 / Title font
    cover-font: (               // 封面字体 / Cover font
      author-font: "新蒂朝露體", // 作者字体 / Author font
      abstract-font: "新蒂龍宮体", // 简介字体 / Abstract font
    ),
    preface-font: "小賴字體 SC", // 前言字体 / Preface font
    contents-font: "小賴字體 SC", // 目录字体 / Contents font
    appendix-font: "WenQuanYi Zen Hei", // 附录字体 / Appendix font
  ),
  
  // 您作品的内容。
  // The content of your work.
  body,
) = {
  // 设置文档的元数据。
  // Set document metadata.
  set document(title: title, author: author)

  // 设置深色主题 - 黑色背景和白色文本
  // Set dark theme - black background and white text
  set page(fill: black)         // 页面填充黑色 / Page fill black
  set text(fill: white, size: 12pt) // 文本填充白色，大小12pt / Text fill white, size 12pt

  // 配置页面尺寸和边距。
  // Configure page size and margins.
  set page(
    paper: paper-size,          // 纸张尺寸 / Paper size
    margin: (bottom: 1.75cm, top: 2.25cm), // 底部和顶部边距 / Bottom and top margins
  )

  // 深色主题的封面页。
  // Cover page for dark theme.
  if abstract == none { // 如果没有摘要，则显示一个有大圆的封面。
    // If there is no abstract, display a cover with a large circle.
    page(
      background: image("/image/cover.svg", width: 100%, height: 100%), // 背景图片 / Background image
      align(
        center + horizon,       // 居中对齐 / Center alignment
        block(width: 90%)[      // 宽度90%的块 / Block with 90% width
          // 日期
          // Date
          #if date != none {
            text(1.4em, fill: white, date.display(date-format)) // 显示日期 / Display date
          } else {
            // 如果没有提供日期，则插入一个空行以保持布局一致。
            // If no date is provided, insert an empty line to maintain consistent layout.
            v(4.6em)           // 垂直间距 / Vertical space
          }

          // 标题居中
          // Center title
          #text(3.3em, fill: white, font: fonts.title-font)[*#title*] // 标题文本 / Title text

          // 作者
          // Author
          #v(1em)               // 垂直间距 / Vertical space
          #text(1.6em, fill: white, font: fonts.cover-font.author-font)[#author] // 作者文本 / Author text
        ],
      ),
    )
  } else { // TODO 如果有摘要，则显示一个标准封面
    // TODO If there is an abstract, display a standard cover
    page(
      background: image("image/preface.svg", width: 100%, height: 100%), // 背景图片 / Background image
      align(
        center + horizon,       // 居中对齐 / Center alignment
        block(width: 50%)[      // 宽度50%的块 / Block with 50% width
          // 摘要内容
          // Abstract content
          // 默认行高是 0.65em。
          // Default line height is 0.65em.
          #text(3.3em, fill: white)[*#title*] // 标题文本 / Title text
          #par(leading: 0.78em, justify: true, linebreaks: "optimized", abstract) // 段落格式 / Paragraph formatting
        ],
      ),
    )
  }

  // 使用深色主题配置段落属性。
  // Configure paragraph properties with dark theme.
  set par(leading: 0.7em, spacing: 1.35em, justify: true, linebreaks: "optimized")

  // 在标题后添加垂直间距。
  // Add vertical spacing after headings.
  show heading: it => {
    it                          // 标题内容 / Heading content
    v(2%, weak: true)           // 弱垂直间距 / Weak vertical space
  }
  
  // 不对标题进行断字。
  // Do not hyphenate headings.
  show heading: set text(hyphenate: false, fill: white)

  // 在外部链接旁边显示一个浅色小圆圈（深色主题）。
  // Display a light small circle next to external links (dark theme).
  show link: it => {
    it                          // 链接内容 / Link content
    // 针对 ctheorems 包的工作区，使其标签保持默认的链接样式。
    // Workaround for ctheorems package to keep its labels with default link style.
    if external-link-circle and type(it.dest) != label {
      sym.wj                    // 符号 / Symbol
      h(1.6pt)                  // 水平间距 / Horizontal space
      sym.wj                    // 符号 / Symbol
      super(box(height: 3.8pt, circle(radius: 1.2pt, stroke: 0.7pt + rgb("#ff6666")))) // 上标圆圈 / Superscript circle
    }
  }

  // 将前言显示为第二或三页（深色主题）。
  // Display preface as second or third page (dark theme).
  {
    set text(font: fonts.preface-font) // 设置前言字体 / Set preface font
    if preface != none {
      page(
        background: image("image/preface.svg", width: 100%, height: 100%), // 背景图片 / Background image
        align(
          center + horizon,     // 居中对齐 / Center alignment
          block(width: 50%)[#preface] // 前言内容块 / Preface content block
        )
      )
    }
  }

  // 显示目录（深色主题）。
  // Display table of contents (dark theme).
  {
    set text(font: fonts.contents-font) // 设置目录字体 / Set contents font
    if table-of-contents != none {
      table-of-contents         // 显示目录 / Display table of contents
    }
  }

  // 配置页码和页脚（深色主题）。
  // Configure page numbers and footer (dark theme).
  set page(
    background: image("image/main-body.svg", width: 100%, height: 100%), // 背景图片 / Background image
    footer: context {           // 页脚上下文 / Footer context
      // 获取当前页码。
      // Get current page number.
      let i = counter(page).at(here()).first()

      // 居中对齐
      // Center alignment
      let is-odd = calc.odd(i)  // 判断是否为奇数页 / Check if odd page
      let aln = center          // 对齐方式 / Alignment

      // 我们是否在开始新章节的页面上？
      // Are we on a page that starts a new chapter?
      let target = heading.where(level: 1) // 一级标题 / Level 1 heading
      if query(target).any(it => it.location().page() == i) {
        return align(aln)[#i]   // 返回页码 / Return page number
      }

      // 查找当前所在部分的章节。
      // Find the chapter of the current section.
      let before = query(target.before(here())) // 当前位置之前的标题 / Headings before current position
      if before.len() > 0 {
        let current = before.last() // 当前章节 / Current chapter
        let gap = 1.75em           // 间距 / Gap
        // 显示章节名称
        // Display chapter name
        let chapter = upper(text(size: 0.7em, fill: white, current.body)) // 章节名称大写 / Chapter name uppercase
        if current.numbering != none {
          align(aln)[#chapter]  // 对齐章节名称 / Align chapter name
          align(aln)[#i]        // 对齐页码 / Align page number
        }
      }
    },
  )

  // 配置公式编号（深色主题）。
  // Configure equation numbering (dark theme).
  set math.equation(numbering: "(1)") // 公式编号格式 / Equation numbering format

  // 在内联代码的小框中显示，并保持正确的基线（深色主题）。
  // Display inline code in small boxes with correct baseline (dark theme).
  show raw.where(block: false): box.with(
    fill: fill-color,           // 填充颜色 / Fill color
    inset: (x: 3pt, y: 0pt),    // 内边距 / Inset
    outset: (y: 3pt),           // 外边距 / Outset
    radius: 2pt,                // 圆角半径 / Radius
  )

  // 显示带内边距的代码块（深色主题）。
  // Display code blocks with padding (dark theme).
  show raw.where(block: true): block.with(inset: (x: 5pt), fill: fill-color)

  // 跨页拆分大表格。
  // Split large tables across pages.
  show figure.where(kind: table): set block(breakable: true) // 设置表格可跨页 / Set tables breakable
  set table(
    // 增加表格单元格的内边距
    // Increase table cell padding
    inset: 7pt,                 // 默认为 5pt / Default is 5pt
    stroke: (0.5pt + stroke-color), // 描边 / Stroke
    fill: black,                // 填充黑色 / Fill black
  )
  
  // 对表头行使用小型大写字母（深色主题）。
  // Use small caps for table header rows (dark theme).
  show table.cell.where(y: 0): smallcaps
  
  // 设置表格文本颜色为白色
  // Set table text color to white
  show table: set text(fill: white)

  // 将 `body` 用花括号包裹，使其拥有自己的上下文。这样 show/set 规则将仅适用于 body。
  // Wrap `body` in curly braces to give it its own context. This way show/set rules will only apply to body.
  {
    // 配置标题编号。
    // Configure heading numbering.
    set heading(numbering: "1.", hanging-indent: 3em) // 编号格式和悬挂缩进 / Numbering format and hanging indent

    // 显示标题时添加缩进
    // Add indentation when displaying headings
    show heading: it => {
      block(inset: (left: 1em * it.level), it) // 根据标题级别缩进 / Indent based on heading level
    }

    // 显示段落和列表时根据对应的标题层级缩进
    // Indent paragraphs based on corresponding heading level
    show selector.or(par, enum): it => context { // 查找标题和段落并传递给it变量
      let h = query(selector(heading).before(here())).at(-1, default: none) // 获取前一个标题 / Get previous heading
      if h == none {
        return it               // 如果没有标题，返回原段落 / Return original paragraph if no heading
      }
      block(inset: (left: 1em * (h.level + 1)), it) // 根据标题级别缩进,额外再缩进一级与标题区分 / Indent based on heading level + 1
    }

    // 显示一级标题时根据设置分页
    // Possibly page break when displaying level 1 headings
    show heading.where(level: 1): it => { 
      if chapter-pagebreak {    // 在新页开始章节 / Start chapters on new page
        pagebreak(weak: true)   // 弱分页 / Weak page break
      }
      it                        // 返回标题内容 / Return heading content
    }
    
    // 显示正文内容
    // Display main body content
    setup-fonts(
      body,                     // 正文内容 / Main body content
    )
  }

  // 在参考文献之前显示附录（深色主题）。
  // Display appendix before bibliography (dark theme).
  {
    if appendix.enabled {       // 如果启用附录 / If appendix is enabled
      pagebreak()               // 分页 / Page break
      heading(level: 1)[#appendix.at("title", default: "附录")] // 附录标题 / Appendix title

      // 重制标题计数器
      // Reset heading counter
      counter(heading).update(0) // 更新计数器为0 / Update counter to 0
      // TODO 对于附录中的标题前缀，标准约定是 A.1.1.
      // TODO For heading prefixes in appendix, standard convention is A.1.1.
      set heading(numbering: "A.1.") // 设置附录标题编号 / Set appendix heading numbering

      appendix.body             // 附录内容 / Appendix content
    }
  }

  // 显示参考文献（深色主题）。
  // Display bibliography (dark theme).
  {
    if bibliographys != none {  // 如果有参考文献 / If bibliography exists
      pagebreak()               // 分页 / Page break
      set text(font: fonts.appendix-font) // 设置附录字体 / Set appendix font
      show std-bibliography: set text(0.85em, fill: white) // 设置参考文献文本样式 / Set bibliography text style
      // 对参考文献使用默认段落属性。
      // Use default paragraph properties for bibliography.
      show std-bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto) // 设置参考文献段落属性 / Set bibliography paragraph properties
      bibliographys             // 显示参考文献 / Display bibliography
    }
  }

  // 显示图、表和代码清单的索引（深色主题）。
  // Display indexes for figures, tables, and listings (dark theme).
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
}

