// 前言 / 正文页眉页脚 foreground 工厂。
//
// 原实现分别内联于 layouts/preface.typ 与 layouts/mainmatter.typ，
// 此处逐字搬运（仅缩进与自由变量参数化），行为完全一致。
// 抽取目的（P30）：各部分起始处重申页面样式（assert），使 to:"odd"
// 自动填充页继承无样式而保持干净；且全为静态 set/break，
// 无运行时奇偶判断，布局必然收敛。
// 标定（P20）：页眉/页脚距页边界 1.5cm 由 place 绝对定位实现，
// 字体宋体小五（数字走 Times fallback），见各函数内注释。

#import "style.typ": 字号

// 前言 foreground：页码大写罗马数字居中；奇数页章名、偶数页题目
//（英文摘要偶数页用英文题目）。
#let preface-foreground(
  info: (:),
  fonts: (:),
  display-header: true,
  stroke-width: 0.8pt,
  reset-footnote: true,
) = context {
  // 重置 footnote 计数器
  if reset-footnote {
    counter(footnote).update(0)
  }

  // 获取当前页码
  let current-page = counter(page).get().first()

  // 判断是否为奇数页
  let is-odd-page = calc.odd(current-page)

  // 初始化页眉
  let header-content = ""

  if is-odd-page {
    // 奇数页：显示当前页的一级标题
    let current-page = here().page()
    let current-headings = query(heading.where(level: 1)).filter(
      h => h.location().page() == current-page,
    )
    let filtered-headings = if current-headings.len() > 0 {
      current-headings
    } else {
      query(selector(heading.where(level: 1)).before(here()))
    }
    let current-heading = if filtered-headings.len() > 0 {
      filtered-headings.last()
    } else { none }
    if current-heading != none {
      if (
        current-heading.has("numbering") and current-heading.numbering != none
      ) {
        let counter-values = counter(heading).at(
          current-heading.location(),
        )
        // 直接调用 heading 自身的 numbering 渲染章序号，
        // 而非硬编码"第1章"——附录等 first-level 为空的场景下
        // 页眉不会错误显示"第1章"。序号与章名间的"一个汉字符"
        // 由 numbering 模板内的全角空格 U+3000 提供。
        header-content = (current-heading.numbering)(..counter-values)
      }
      header-content += current-heading.body
    } else {
      header-content = "没有找到章标题"
    }
  } else {
    // 偶数页：显示论文标题
    // 规范：英文摘要偶数页标明英文题目，其余前置部分标明中文题目。
    // 判断方法：查询当前位置之前最近的一级标题（与奇数页分支同源 query 模式），
    // 若其文本含 "Abstract" 则当前处于英文摘要部分，用 info.title-en；否则用 info.title。
    let current-page-num = here().page()
    let current-headings = query(heading.where(level: 1)).filter(
      h => h.location().page() == current-page-num,
    )
    let recent-heading = if current-headings.len() > 0 {
      current-headings.last()
    } else {
      let before-headings = query(
        selector(heading.where(level: 1)).before(here()),
      )
      if before-headings.len() > 0 { before-headings.last() } else {
        none
      }
    }

    // 递归把 content 转为 str（复用 bilingual-bibliography.typ:38-50 的 to-string 模式）
    let content-to-str(c) = {
      if c == none { "" } else if type(c) == str { c } else if c.has("text") {
        c.text
      } else if c.has("children") {
        c.children.map(content-to-str).join("")
      } else if c.has("child") { content-to-str(c.child) } else if c.has(
        "body",
      ) { content-to-str(c.body) } else if c.has("supplement") {
        content-to-str(c.supplement)
      } else { "" }
    }

    let heading-text = content-to-str(
      if recent-heading != none { recent-heading.body } else { none },
    )
    let thesis-title = if heading-text.contains("Abstract") {
      info.title-en
    } else {
      info.title
    }

    if thesis-title != none {
      header-content = if type(thesis-title) == array {
        thesis-title.join("")
      } else {
        str(thesis-title)
      }
    }
    if header-content == "" {
      header-content = "没有找到标题"
    }
  }

  // 渲染页眉：距页面顶边 1.5cm，宋体小五号，居中，下方 0.5em 处加正文区宽度的分隔线。
  // display-header 为 false 时省略页眉（仅保留 footnote 重置与页脚页码）。
  if display-header {
    place(
      top + center,
      dy: 1.5cm,
      {
        set text(
          font: fonts.宋体,
          size: 字号.小五,
          top-edge: "bounds",
          bottom-edge: "bounds",
        )
        // 行距段距清零：默认 par spacing（1.2em）会盖掉 v(0.5em) 并把分隔线（旧 v(0.5em)，现 v(2pt)，见下）
        // 顶到 16pt 开外（LaTeX 参考仅约 4pt）；清零后由显式 v(2pt) 精确定位。
        set par(leading: 0pt, spacing: 0pt)
        // 页眉盒顶定位于距页边界 1.5cm（与 LaTeX headheight 盒模型一致，
        // 盒高 12pt，文字底对齐，基线约 1.5cm+12pt；分隔线在盒下 0.5em）。
        block(width: 100% - 3.17cm - 3.17cm, height: 12pt)[
          #align(center + bottom, header-content)
        ]
        v(2pt)
        line(length: 100%, stroke: stroke-width + black)
      },
    )
  }

  // 渲染页脚（页码）：距页面底边 1.5cm，宋体小五号居中，大写罗马数字
  place(
    bottom + center,
    dy: -1.5cm,
    {
      set text(
        font: fonts.宋体,
        size: 字号.小五,
        top-edge: "bounds",
        bottom-edge: "bounds",
      )
      counter(page).display("I")
    },
  )
}

// 正文 foreground：页码阿拉伯数字（单面居中，双面奇右偶左）；
// 奇数页章名、偶数页论文题目。
#let mainmatter-foreground(
  twoside: false,
  info: (:),
  fonts: (:),
  display-header: true,
  stroke-width: 0.8pt,
  reset-footnote: true,
) = context {
  // 重置 footnote 计数器
  if reset-footnote {
    counter(footnote).update(0)
  }

  // 获取当前页码
  let current-page = counter(page).get().first()

  // 判断是否为奇数页
  let is-odd-page = calc.odd(current-page)

  // 初始化页眉
  let header-content = ""

  if is-odd-page {
    // 奇数页：显示当前页的一级标题

    // 查询当前页的一级标题；当前页没有则取当前位置之前最近的一级标题
    let current-page = here().page()
    let current-headings = query(heading.where(level: 1)).filter(
      h => h.location().page() == current-page,
    )
    let filtered-headings = if current-headings.len() > 0 {
      current-headings
    } else {
      query(selector(heading.where(level: 1)).before(here()))
    }
    let current-heading = if filtered-headings.len() > 0 {
      filtered-headings.last()
    } else { none }

    // 页眉渲染
    if current-heading != none {
      // 构造章节标题显示内容
      if (
        current-heading.has("numbering") and current-heading.numbering != none
      ) {
        let counter-values = counter(heading).at(
          current-heading.location(),
        )
        // 直接调用 heading 自身的 numbering 渲染章序号，
        // 而非硬编码"第1章"——这样附录（first-level 为空）的页眉
        // 不会错误显示"第1章"，而显示纯标题（如"附录"）。
        // 序号与章名间的"一个汉字符"由 numbering 模板内的全角空格
        // U+3000 提供，与正文标题保持一致。
        header-content = (current-heading.numbering)(..counter-values)
      }
      header-content += current-heading.body
    } else {
      header-content = "没有找到章标题"
    }
  } else {
    // 偶数页：显示论文标题
    let thesis-title = info.title
    if thesis-title != none {
      header-content = if type(thesis-title) == array {
        thesis-title.join("")
      } else {
        str(thesis-title)
      }
    }
    if header-content == "" {
      header-content = "没有找到标题"
    }
  }

  // 渲染页眉：距页面顶边 1.5cm，宋体小五号，居中，下方 0.5em 处加正文区宽度的分隔线。
  // display-header 为 false 时省略页眉（仅保留 footnote 重置与页脚页码）。
  if display-header {
    place(
      top + center,
      dy: 1.5cm,
      {
        set text(
          font: fonts.宋体,
          size: 字号.小五,
          top-edge: "bounds",
          bottom-edge: "bounds",
        )
        // 行距段距清零：默认 par spacing（1.2em）会盖掉 v(0.5em) 并把分隔线（旧 v(0.5em)，现 v(2pt)，见下）
        // 顶到 16pt 开外（LaTeX 参考仅约 4pt）；清零后由显式 v(2pt) 精确定位。
        set par(leading: 0pt, spacing: 0pt)
        // 页眉盒顶定位于距页边界 1.5cm（与 LaTeX headheight 盒模型一致，
        // 盒高 12pt，文字底对齐，基线约 1.5cm+12pt；分隔线在盒下 0.5em）。
        block(width: 100% - 3.17cm - 3.17cm, height: 12pt)[
          #align(center + bottom, header-content)
        ]
        v(2pt)
        line(length: 100%, stroke: stroke-width + black)
      },
    )
  }

  // 渲染页脚（页码）：距页面底边 1.5cm，宋体小五号。
  // 单面居中；双面奇数页(右页)右对齐、偶数页(左页)左对齐。
  place(
    bottom + center,
    dy: -1.5cm,
    {
      set text(
        font: fonts.宋体,
        size: 字号.小五,
        top-edge: "bounds",
        bottom-edge: "bounds",
      )
      block(width: 100% - 3.17cm - 3.17cm)[
        #align(
          if twoside and calc.even(current-page) { left } else if twoside {
            right
          } else { center },
          counter(page).display("1"),
        )
      ]
    },
  )
}
