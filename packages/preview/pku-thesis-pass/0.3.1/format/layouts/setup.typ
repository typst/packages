// ============================================================
// setup.typ — 页面基础设置
// 封装 set page / set text / set figure / 脚注 / show rule 等
// 全局排版基础设施，供 config.typ 编排时调用
// ============================================================

#import "../imports.typ": itemize, codly-init, codly, codly-languages
#import "../utils/bold.typ": bold

#import "../utils/style.typ": style as _style
#import "../utils/number.typ": in-appendix, chinesenumbering
#import "../utils/counter.typ": chaptercounter
#import "../utils/util.typ": show-latexref
#import "headings.typ": heading-show-rule
#import "header.typ": make-header
#import "footer.typ": make-footer
#import "show.typ": figure-show-rule, ref-show-rule

// ========== 列表符号 ==========
// 无序列表用的实心符号：圆形、方形、菱形，供列表分层循环使用

/// 实心圆符号，边长按 size 控制
#let sym-circle(size) = box(
  width: 1em,
  align(
    center + horizon,
    circle(radius: size / 2, fill: black)
  ),
)

/// 实心方符号，按 size 控制大小
#let sym-square(size) = box(
  width: 1em,
  align(
    center + horizon,
    square(size: size, fill: black)
  ),
)

/// 实心菱符号（旋转 45° 的方），按 size 控制大小
#let sym-rhombus(size) = box(
  width: 1em,
  align(
    center + horizon,
    rotate(45deg, square(size: size, fill: black))
  ),
)

/// 页面基础设置函数
/// 在 #show: setup 处被 config() 调用，作用于全文
/// 参数全部由 config() 传入，保持关注点分离
#let page-setup(
  font: none,
  header-text: none,
  preview: true,
  first-line-indent: 2em,
  smartpagebreak: none,
  merged-supplements: (:),
  codly-args: (:),
  document-title: none,
  document-author: none,
  use-latexref: false,
  latexref-prefixes: ("fig:", "tbl:", "eqt:", "lst:", "img:", "alg:"),
  body: none,
  style: _style,
) = {
  // ========== 页面尺寸与页眉页脚 ==========
  // A4 纸 + 学校规定的页边距；页眉页脚由 header.typ / footer.typ 按部分自动生成
  set page(
    paper: "a4",
    margin: (top: style.页边距.top, bottom: style.页边距.bottom, left: style.页边距.left, right: style.页边距.right),
    header: make-header(header-text: header-text, style: style),
    footer: make-footer(style: style),
  )
  // 正文默认字体：宋体小四、中文断行
  set text(font: style.正文.font, size: style.正文.size, lang: "zh")

  // ========== PDF 元数据 ==========
  // 盲审时 document-author 为 none，跳过作者字段，避免在文件属性中泄露作者信息
  set document(
    title: document-title,
  )
  if document-author != none {
    set document(author: document-author)
  }

  // 正文标题统一使用中文章节编号（chinesenumbering）
  set heading(numbering: chinesenumbering)

  // ========== 图/表编号 ==========
  // 编号随章重置（如 "图 3.1"），进入附录后切换为 "图 A.1"
  set figure(
    numbering: (..nums) => context {
      if not in-appendix(here()) {
        numbering("1.1", chaptercounter.at(here()).first(), ..nums)
      } else {
        numbering("A.1", chaptercounter.at(here()).first(), ..nums)
      }
    },
  )

  // ========== 公式编号 ==========
  // 与 figure 同理：随章编号、附录切换 "A.1"；编号中的中文用宋体渲染
  set math.equation(
    numbering: (..nums) => context {
      set text(font: style.公式编号.font)
      if not in-appendix(here()) {
        numbering("(1.1)", chaptercounter.at(here()).first(), ..nums)
      } else {
        numbering("(A.1)", chaptercounter.at(here()).first(), ..nums)
      }
    },
  )

  // ========== 脚注 ==========
  // "①"式编号、上标缩小、悬挂缩进排版
  set footnote(numbering: "①")
  show footnote: set super(size: style.脚注.super-size)
  show footnote.entry: it => {
    let loc = it.note.location()
    set text(font: style.脚注.font, size: style.脚注.size)
    set par(
      justify: true,
      leading: style.脚注.leading,
      spacing: 0pt,
      hanging-indent: style.脚注.悬挂缩进,
      first-line-indent: 0pt,
    )
    numbering(it.note.numbering, ..counter(footnote).at(loc))
    h(style.脚注.编号间距)
    it.note.body
  }

  // ========== 正文强调样式 ==========
  // 加粗统一入口：有真粗体走 weight:bold，无真粗体走 cuti 描边（正文为宋体）
  show strong: it => bold(it.body, style.正文.fakebold)
  // 斜体用楷体（pkuthss 惯例）
  show emph: it => text(font: style.强调.font, style: style.强调.style, it.body)
  // 代码用等宽字体
  show raw: set text(font: style.代码样式.font, size: style.代码样式.size, top-edge: "ascender")

  // ========== 代码块高亮 ==========
  // codly 渲染代码块（行号、语言图标等由 codly-args 控制）
  show: codly-init.with()
  codly(languages: codly-languages, ..codly-args)

  // ========== 链接样式 ==========
  // 预览模式（preview=true）下链接显示为蓝色，打印版关闭以保持纯黑
  show link: it => if type(it.dest) == str and preview {
    text(fill: blue)[#it]
  } else { it }

  // ========== 列表符号 ==========
  // 三级无序列表符号依次循环为 圆/方/菱
  show: itemize.default-enum-list.with(
    indent: (first-line-indent, 0.5em),
    label-baseline: "center",
    list-config: (
      label-format: it => [#(
        sym-circle(style.列表.符号尺寸), sym-square(style.列表.符号尺寸), sym-rhombus(style.列表.符号尺寸),
      ).at(calc.rem(it.level - 1, 3))],
    ),
  )

  // ========== 跨元素 show 委托 ==========
  // 标题、图/表/代码块、交叉引用分别委托 headings.typ / show.typ 渲染
  show heading: it => heading-show-rule(it, smartpagebreak, style: style)
  show figure: set block(breakable: true)
  show figure: it => figure-show-rule(it, merged-supplements, style: style)
  show ref: it => ref-show-rule(it, merged-supplements)

  // ========== LaTeX 引用兼容 ==========
  // use-latexref=true 时：@fig:xxx 等带前缀引用解析失败时，剥离前缀重试 @xxx，
  // 方便从 LaTeX 迁移的文档沿用 \ref{fig:xxx} 写法。
  // 注意：若 use-latexref 预置的剥离前缀不覆盖实际前缀，可自行把前缀加入 latexref-prefixes。
  // 注意：show: 不能写在 if 块内部，否则不会作用于函数体返回的内容，故先用变量收拢再 show
  let latexref-wrapper = if use-latexref {
    show-latexref.with(latexref-prefixes)
  } else {
    it => it
  }
  show: latexref-wrapper

  body
}
