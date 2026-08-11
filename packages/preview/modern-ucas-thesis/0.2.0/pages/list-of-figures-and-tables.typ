#import "@preview/i-figured:0.2.4"
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": get-fonts, 字号

// 图表目录
#let list-of-figures-and-tables(
  // documentclass 传入参数
  twoside: false,
  fontset: "mac",
  fonts: (:),
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
  ..args,
) = {
  // 1. 默认参数
  fonts = get-fonts(fontset) + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.四号, weight: "bold")
  }
  if font == auto {
    font = fonts.黑体
  }

  // 2. 正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 默认显示的字体
  set text(font: font, size: size)

  // 图表目录（不显示）
  invisible-heading(level: 1, outlined: outlined, title)

  v(title-above)
  // ——— 插图目录标题 ———
  {
    set align(center)
    text(..title-text-args, fig-title)
  }

  v(title-below)

  // 计算段前段后间距：规范值 + 单倍行距（字体大小）
  // 段前不加行距，优化视觉效果 (不知道为什么，不去除会导致间距过大)
  let actual-above = above
  let actual-below = below + size

  // 辅助函数，从 figure caption 中提取中文标题
  let extract-caption-zh(fig, default-supp) = {
    let caption = fig.caption
    let cap-zh = none
    let supp-zh = default-supp

    if caption != none and caption.has("body") and caption.body != none {
      let body = caption.body

      // 检查 body 是否有 value 字段（metadata 特征）
      let is-meta = type(body) == metadata
      if not is-meta and type(body) == content and body.has("value") {
        is-meta = true
      }

      if is-meta {
        let data = body.value
        if type(data) == array and data.len() >= 1 {
          cap-zh = data.at(0)
          supp-zh = if data.len() >= 4 { data.at(3) } else { default-supp }
        }
      }
    }

    return (cap-zh, supp-zh)
  }

  // 自定义 outline entry 显示，使用函数形式检查 kind
  show outline.entry: it => {
    let fig = it.element

    // 检查是否是 figure 且是自定义的 bilingual figure
    let is-bilingual = false
    let kind-str = ""

    if fig != none and type(fig) == content {
      // 检查是否有 kind 字段
      if fig.has("kind") {
        let kind = fig.kind
        kind-str = str(kind)
        is-bilingual = (
          kind-str.contains("bifigure") or kind-str.contains("bitable")
        )
      }
    }

    if is-bilingual {
      let (cap-zh, supp-zh) = if kind-str.contains("bitable") {
        extract-caption-zh(fig, "表")
      } else {
        extract-caption-zh(fig, "图")
      }

      if cap-zh != none {
        return context {
          let page-num = counter(page).at(fig.location()).first()
          // 获取章节编号
          let heading-counter = counter(heading)
          let heading-values = heading-counter.at(fig.location())
          let chapter-num = if heading-values.len() > 0 {
            heading-values.at(0)
          } else { 1 }

          // 查询当前章节内的同类型图表数量，计算相对编号
          let fig-kind = if kind-str.contains("bitable") { "bitable" } else {
            "bifigure"
          }
          let all-figs = query(figure.where(kind: fig-kind))
          let figs-in-chapter = all-figs.filter(f => {
            let f-heading-values = heading-counter.at(f.location())
            let f-chapter = if f-heading-values.len() > 0 {
              f-heading-values.at(0)
            } else { 1 }
            f-chapter == chapter-num
          })

          // 找到当前图表在章节内的位置
          let fig-num = 1
          for (i, f) in figs-in-chapter.enumerate() {
            if f.location() == fig.location() {
              fig-num = i + 1
            }
          }

          block(above: actual-above, below: actual-below)[
            #link(fig.location())[
              #supp-zh #chapter-num.#fig-num #h(1em) #cap-zh
              #box(width: 1fr)[#repeat(".")]
              #page-num
            ]
          ]
        }
      }
    }

    // 默认显示
    it
  }

  // 渲染图目录
  outline(
    target: figure.where(kind: "bifigure"),
    title: none,
  )

  v(title-above)

  // ——— 表格目录标题 ———
  {
    set align(center)
    text(..title-text-args, tbl-title)
  }

  v(title-below)

  // 渲染表目录
  outline(
    target: figure.where(kind: "bitable"),
    title: none,
  )

  // 手动分页：若需要单双面排版，章节结束后对齐到奇数页
  if twoside {
    pagebreak() + " "
  }
}
