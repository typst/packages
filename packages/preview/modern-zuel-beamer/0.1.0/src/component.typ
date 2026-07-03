// ============================================================================
// 补充组件 —— 多栏布局 / 图片题注 / 金句块 / 编号定理环境
// ============================================================================

#import "theme.typ": color, font, size, layout

// ---------------------------------------------------------------------------
// 外观参数（置顶）
// ---------------------------------------------------------------------------
#let col-gutter = 1.2em // 多栏默认间距
#let quote-bar-width = 3pt // 金句块左侧竖条宽
#let quote-inset = (x: 1em, y: 0.75em) // 金句块内边距
#let quote-tint = 94% // 金句块底色 = 主色 lighten
#let thm-title-inset = (x: 0.8em, y: 0.4em) // 定理标题栏内边距
#let thm-body-inset = (x: 0.8em, top: 0.55em, bottom: 0.7em) // 定理正文内边距
#let thm-body-tint = 88% // 定理正文底色 lighten
#let block-below = 0.9em // 组件与下文间距

// ---------------------------------------------------------------------------
// 多栏布局：#cols[左][右]  或  #cols(widths: (2fr, 1fr))[宽][窄]
// ---------------------------------------------------------------------------
#let cols(..bodies, gutter: col-gutter, widths: none) = {
  let items = bodies.pos()
  let cw = if widths == none { items.map(_ => 1fr) } else { widths }
  grid(columns: cw, column-gutter: gutter, align: top, ..items)
}

// ---------------------------------------------------------------------------
// 图片 + 统一题注：#fig(image("x.png", width: 70%), caption: [说明])
// 题注样式（“图 N / 表 N”、字号、颜色）由 setup.typ 的 show 规则统一控制
// ---------------------------------------------------------------------------
#let fig(body, caption: none) = figure(body, caption: caption)

// ---------------------------------------------------------------------------
// 金句 / 引用块：#quote-block[内容][来源]
// ---------------------------------------------------------------------------
#let quote-block(body, by: none) = block(
  width: 100%,
  below: block-below,
  fill: color.primary.lighten(quote-tint),
  inset: quote-inset,
  stroke: (left: quote-bar-width + color.gold), // 左侧金色竖条（高度自动贴合内容）
  {
    set text(fill: color.primary-dark, style: "italic")
    body
    if by != none {
      v(0.3em)
      align(right, text(size: size.small, fill: color.muted, style: "normal", [—— #by]))
    }
  },
)

// ---------------------------------------------------------------------------
// 编号定理环境：#theorem(title: "可选")[内容] -> “定理 1（可选）”
// theorem / lemma / corollary / definition-thm，各类独立编号
// ---------------------------------------------------------------------------
#let _thm-counter(name) = counter("zuel-thm-" + name)

#let _thm-env(name, fill, title, body) = {
  let c = _thm-counter(name)
  c.step()
  block(
    width: 100%,
    below: block-below,
    radius: layout.block-radius,
    clip: true,
    stroke: 0.6pt + fill,
    {
      block(width: 100%, below: 0pt, fill: fill, inset: thm-title-inset, context {
        let n = c.get().first()
        text(
          fill: white, font: font.sans, weight: "bold", size: size.small,
          [#name #n#if title != none [（#title）]],
        )
      })
      block(width: 100%, fill: fill.lighten(thm-body-tint), inset: thm-body-inset, body)
    },
  )
}

#let theorem(title: none, body) = _thm-env("定理", color.block-theorem, title, body)
#let lemma(title: none, body) = _thm-env("引理", color.block-theorem, title, body)
#let corollary(title: none, body) = _thm-env("推论", color.block-theorem, title, body)
#let definition-thm(title: none, body) = _thm-env("定义", color.block-definition, title, body)
