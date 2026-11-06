#import "../utils/bilingual-figured.typ"
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground

// 图表目录
#let list-of-figures-and-tables(
  // documentclass 传入参数
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  title: "图表目录", // 不显示
  fig-title: "图目录",
  tbl-title: "表目录",
  outlined: false,
  title-above: 24pt,
  title-below: 18pt,
  title-text-args: auto,
  // 字体与字号
  font: auto,
  size: 字号.四号,
  // 段前段后间距规范值
  above: 6pt,
  below: 0pt,
) = {
  // 1. 默认参数
  fonts = get-fonts(fontset) + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.四号, weight: "bold")
  }
  if font == auto {
    font = fonts.黑体
  }

  // 2. 正式渲染：起始三件套（P30）——先清样式（填充页干净），
  // 再换页（双面须奇数页起），最后重申前言域样式。全静态。
  set page(numbering: none, foreground: none)
  pagebreak(weak: true, to: if twoside { "odd" })
  set page(
    numbering: "I",
    footer: none,
    foreground: preface-foreground(info: info, fonts: fonts),
  )

  // 默认显示的字体
  set text(font: font, size: size)

  // 图表目录（不显示）
  invisible-heading(level: 1, outlined: outlined, title)

  v(title-above)
  // ——— 插图目录标题 ———（单倍行距）
  {
    set align(center)
    set par(leading: 行距.单倍, spacing: 0pt)
    text(..title-text-args, fig-title)
  }

  v(title-below)

  // 段前段后取规范值：相邻 block 间距取 max 不叠加，
  // 行距由 leading 提供，勿再叠加字号。
  let actual-above = above
  let actual-below = below

  // 自定义 outline entry：双语图表目录仅显示中文标题
  show outline.entry: it => {
    // 条目单倍行距（规范值；多行条目才显现差异）
    set par(leading: 行距.单倍, spacing: 0pt)
    let fig = it.element
    let kind = if fig != none and type(fig) == content and fig.has("kind") {
      fig.kind
    } else {
      none
    }
    let is-bilingual = (
      bilingual-figured.is-kind(kind, "bifigure")
        or bilingual-figured.is-kind(kind, "bitable")
    )

    if is-bilingual {
      bilingual-figured
        .show-bilingual-outline-entry
        .with(
          lang: "zh",
          above: actual-above,
          below: actual-below,
        )(it)
    } else {
      it
    }
  }

  // 渲染图目录
  bilingual-figured.outline(target-kind: "bifigure", title: none)

  v(title-above)

  // ——— 表格目录标题 ———（单倍行距）
  {
    set align(center)
    set par(leading: 行距.单倍, spacing: 0pt)
    text(..title-text-args, tbl-title)
  }

  v(title-below)

  // 渲染表目录
  bilingual-figured.outline(target-kind: "bitable", title: none)

  // 结尾 reset（P30）：function 体内的 set page 会泄漏到后续文档流，
  // 使符号说明起始换页产生的填充页保持干净（旧 `pagebreak() + " "` 会留
  // 带页眉页脚的空内容页，已删除）；本页已有样式不受影响。
  // 标准顺序下由下一部分起始 reset 覆盖，此处幂等、无副作用。
  set page(numbering: none, foreground: none)
}
