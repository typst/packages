#import "../utils/bilingual-figured.typ"
#import "../utils/custom-figure.typ": thesis-bilingual-caption-style
#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": mainmatter-foreground
#import "../utils/custom-numbering.typ": custom-numbering
#import "../utils/citation-range-hyphen.typ": citation-range-hyphen
#import "../utils/unpairs.typ": unpairs

#let mainmatter(
  // documentclass 传入参数
  twoside: false,
  info: (:),
  fonts: (:),
  fontset: "mac",
  // 其他参数
  // 正文行距：Typst leading 是行盒之间的额外间隙，
  // 取 行距.正文（1.1em）使基线间距约 21.6pt（对齐 LaTeX 参考实现），勿写 1.25em。
  leading: 行距.正文,
  // 正文段前段后 0 磅：Typst 的段间距不含行距（只计额外间隙），
  // Word"0 磅"语义 = 段间基线距与行内一致，故取与 leading 等值，勿写 0pt
  //（0pt 会使段间基线距小于行内，段落粘连偏紧）。
  spacing: 行距.正文,
  justify: true,
  first-line-indent: (amount: 2em, all: true),
  // 章节编号格式
  // 序号与题名间"空一个汉字符"（=1em=1 全角汉字宽）。
  // 用全角空格 U+3000（IDEOGRAPHIC SPACE）实现，其在 CJK 字体下宽度恒为 1em，
  // 均精确等于 1em。半角空格 U+0020 仅约 0.25em，不满足规范。
  numbering: custom-numbering.with(
    first-level: "第1章\u{3000}",
    depth: 4,
    "1.1\u{3000}",
  ),
  // 正文字体与字号参数
  text-args: auto,
  // 标题字体与字号
  heading-font: auto,
  heading-size: (字号.四号, 字号.小四, 字号.小四, 字号.小四),
  heading-weight: ("bold", "regular", "regular", "regular"),
  // 标题段前段后间距（规范值）
  // 一级标题：段前24pt，段后18pt
  // 二级标题：段前24pt，段后6pt
  // 三级标题：段前12pt，段后6pt
  // 四级标题：段前12pt，段后6pt
  heading-above: (24pt, 24pt, 12pt, 12pt),
  heading-below: (18pt, 6pt, 6pt, 6pt),
  heading-pagebreak: (true, false),
  heading-align: (center, auto),
  // 页眉
  display-header: true,
  // 页眉分隔线
  stroke-width: 0.8pt,
  reset-footnote: true,
  // caption 的 separator
  separator: "  ",
  // caption 样式
  caption-style: strong,
  caption-size: 字号.五号,
  ..args,
  it,
) = {
  // 0.  起始三件套（P30）：先清样式（to:"odd" 自动填充页继承无样式而干净），
  // 再换页（双面须奇数页起），最后重申本域样式。
  // reset 必须与 break 同处一个 show 体内：填充页由本体的 break 创建，
  // 样式作用域附着规则下，同体 reset 才能覆盖填充页（v6 高清渲染验证）。
  // 全静态，无运行时判断，布局必然收敛。
  set page(numbering: none, foreground: none)
  pagebreak(weak: true, to: if twoside { "odd" })
  // footer: none 必需（重申）：set page(numbering:) 会自动在页脚渲染一个环境样式的
  // 页码（auto footer），与下方 foreground 定制的页码重影，必须显式关闭。
  set page(numbering: "1", footer: none)

  // 1.  默认参数
  info = (
    (
      title: ("基于 Typst 的", "中国科学院大学学位论文"),
    )
      + info
  )
  fonts = get-fonts(fontset) + fonts
  // 基础文字参数
  // 文字边缘设置，用于控制行高计算基准
  // "cap-height": 大写字母的大致高度
  // "baseline": 字母的基线
  let base-text-args = (top-edge: "cap-height", bottom-edge: "baseline")
  if (text-args == auto) {
    text-args = (font: fonts.宋体, size: 字号.小四) + base-text-args
  } else {
    // 合并用户自定义参数与边缘设置
    text-args = base-text-args + text-args
  }

  // 1.1 字体与字号
  if (heading-font == auto) {
    heading-font = (fonts.黑体,)
  }
  // 1.2 处理 heading- 开头的其他参数
  let heading-text-args-lists = args
    .named()
    .pairs()
    .filter(pair => pair.at(0).starts-with("heading-"))
    .map(pair => (pair.at(0).slice("heading-".len()), pair.at(1)))

  // 2.  辅助函数
  let array-at(arr, pos) = {
    // 如果值是数组，根据位置获取；如果是标量，直接使用该值
    if type(arr) == array {
      arr.at(calc.min(pos, arr.len()) - 1)
    } else {
      arr
    }
  }

  // 3.  设置基本样式
  // 3.1 文本和段落样式
  set text(..text-args)
  set par(
    leading: leading,
    spacing: spacing,
    justify: justify,
    first-line-indent: first-line-indent,
  )
  show raw: set text(font: fonts.等宽)

  // 3.2 脚注样式：五号字；脚注用单倍行距（LaTeX 脚注单倍，不随正文行距）。
  show footnote.entry: set text(font: fonts.宋体, size: 字号.五号)
  show footnote.entry: set par(leading: 行距.单倍)

  // 3.3 设置 figure 的编号
  show heading: bilingual-figured.reset-counters
  show figure: bilingual-figured.show-figure

  let bilingual-caption-style = thesis-bilingual-caption-style(fonts)
  show figure: bilingual-figured.show-bilingual.with(
    figure_style: bilingual-caption-style,
    table_style: bilingual-caption-style,
  )

  // 3.4 设置 equation 的编号和假段落首行缩进
  // 公式编号对齐到最后一行右侧（UCAS 规范：序号编于最后一行右顶格）
  set math.equation(number-align: bottom + end)
  // 公式编号字体：不覆盖。曾用 show math.equation: set text(font: 宋体)
  // 统一编号字体，但实测该规则会迫使公式符号（φ、∫、⌊⌋等）向非数学字体
  // 回退，导致缺字形 tofu（P31 高清渲染验证）；且 Typst 0.15 无独立设置
  // 编号字号的 API。编号内容为纯阿拉伯数字与括号，按规范"英文和阿拉伯
  // 数字用 Times New Roman 体"，默认数学字体（Times 风格衬线）即合规。
  // 字号继承正文小四（规范五号 10.5pt，Typst 固有限制，见 docs/CUSTOMIZE.md）。
  show math.equation.where(block: true): bilingual-figured.show-equation

  // 3.5 表格表头置顶 + 不用冒号用空格分割 + 样式
  show figure.where(
    kind: table,
  ): set figure.caption(position: top)
  set figure.caption(separator: separator)
  show figure.caption: caption-style
  show figure.caption: set text(font: fonts.宋体, size: 字号.五号)

  // 3.6 顺序编码制参考文献引用：连续序号分隔符修正
  //     gb-7714-2015-numeric CSL 默认用 en dash"–"连接连续序号，UCAS 规范要求用 hyphen"-"。
  //     仅对参考文献引用（it.element == none）生效，图表/公式/标题引用原样返回。
  //     序号上标与多篇合并（[1,2]/[1-4]）由 CSL 默认提供，需用 @a@b 紧邻书写触发合并。
  show ref: citation-range-hyphen

  // 3.7 优化列表显示
  // 术语列表 terms 不应该缩进
  show terms: set par(first-line-indent: (amount: 0pt, all: true))

  // 4.  处理标题
  // 4.1 设置标题的 Numbering
  set heading(numbering: numbering)

  // 4.2 设置标题的段前段后间距
  show heading: it => {
    // 段前分两种落实（实测见 layouts/mainmatter 探针：block/below 与显式 v 相加，
    // block/above 与前序 block 间距按 max 折叠——与 TeX \addvspace 语义一致）：
    // - L1 仍用 4.4 中的显式 v：L1 恒另起一页（4.4 换页符），v 在换页符后保留，
    //   保证章标题距正文区上边界；L1 前无须折叠（换页已分隔），此处块上间距取 0。
    // - L2+ 用块上间距：与前序标题的段后（below）按 max 折叠，避免"段后补偿 +
    //   段前 v"双重全额叠加（如章→节 63.8pt，LaTeX 参考仅 34.8pt）；自然换页被
    //   带到页顶时块上间距自动裁剪，同 TeX 丢弃 beforeskip。
    // 段后：规范值 + 13.2pt（一个正文 leading 的绝对值；
    // 增量相对正文行距而非标题字号，故不用 size-relative 的 leading）。
    // TeX 的 afterskip 是叠加在整行行距之上的（LaTeX 实测 L2→正文
    // 27.58pt = 行距 21.6pt + 段后 6pt）；L→标题相邻仍按 max 语义。
    let actual-above = if it.level == 1 { 0pt } else {
      array-at(heading-above, it.level)
    }
    let actual-below = array-at(heading-below, it.level) + 13.2pt
    set block(
      above: actual-above,
      below: actual-below,
    )
    it
  }

  // 4.3 设置标题的字体、字号、行距等样式
  show heading: it => {
    // 标题使用单倍行距：取 行距.单倍（0.5em），勿写 1em
    //（1em 额外间隙远超单倍）。
    set par(leading: 行距.单倍, spacing: 行距.单倍)
    // 设置标题字体、字号、加粗等样式
    set text(
      font: array-at(heading-font, it.level),
      size: array-at(heading-size, it.level),
      weight: array-at(heading-weight, it.level),
      ..unpairs(
        heading-text-args-lists.map(
          pair => (pair.at(0), array-at(pair.at(1), it.level)),
        ),
      ),
      top-edge: "cap-height",
      bottom-edge: "baseline",
    )
    it
  }

  // 4.4 标题居中与自动换页
  show heading: it => {
    if array-at(heading-pagebreak, it.level) {
      // 如果打上了 no-auto-pagebreak 标签，则不自动换页
      if "label" not in it.fields() or str(it.label) != "no-auto-pagebreak" {
        pagebreak(weak: true)
      }
    }
    // L1 段前用显式 v 落实规范值（换页符后保留，见 4.2 注释）。
    // L2+ 段前已由 4.2 的块上间距落实（max 折叠 + 页顶裁剪），此处不再发射 v
    // （v 会与块段后相加，破坏折叠）。
    if it.level == 1 {
      v(array-at(heading-above, it.level))
    }
    if array-at(heading-align, it.level) != auto {
      set align(array-at(heading-align, it.level))
      it
    } else {
      it
    }
  }

  // 5.  处理页眉y页脚：页眉、页脚距页边界 1.5cm）
  //     不使用 page 的 header/footer + header-ascent/footer-descent（语义为"侵入 margin 的量"，
  //     无法精确表达"距边界 1.5cm"且会挤压正文区）。改用 page.foreground + place 绝对定位：
  //       place(top + center, dy: 1.5cm, ...)    —— 页眉锚定到页面顶边下方 1.5cm
  //       place(bottom + center, dy: -1.5cm, ...) —— 页脚锚定到页面底边上方 1.5cm
  //     Typst 的 number-align 不支持奇偶页交替，需自定义 footer 查询页码计数器。
  //     单面打印时居中；双面打印时奇数页(右页)右对齐、偶数页(左页)左对齐。
  //     页眉分隔线用 block(width: 100% - 3.17cm - 3.17cm) 约束到正文区宽度。
  set page(foreground: mainmatter-foreground(
    twoside: twoside,
    info: info,
    fonts: fonts,
    display-header: display-header,
    stroke-width: stroke-width,
    reset-footnote: reset-footnote,
  ))
  // 奇偶对齐已由开头的 to:"odd" 换页保证，此处不再需要运行时判断。
  counter(page).update(1)

  it
}
