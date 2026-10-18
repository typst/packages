// ============================================================
// headings.typ — 标题系统
// 提供标题渲染的全套机制：
//   - front-heading / back-heading：前置/后置部分标题创建
//   - get-heading-meta：从 heading supplement 提取元数据
//   - sizedheading：按等级和参数渲染标题
//   - heading-show-rule：全局 show rule，处理分页、状态转换、计数器步进
// ============================================================

#import "../utils/size.typ": size
#import "../utils/counter.typ": partcounter, chaptercounter, reset-chapter-counters
#import "headings-meta.typ": get-heading-meta
#import "../imports.typ": show-cn-fakebold

/// 根据标题等级返回对应字号（level 1 由 heading-show-rule 直接处理）
#let get-heading-size(level, style: none) = {
  if level == 2 {
    style.一级节标题.size
  } else if level == 3 {
    style.二级节标题.size
  } else {
    style.三级节标题.size
  }
}

/// 各级标题段前/段后默认间距
#let default-heading-spacing-before = (17pt, 24pt, 12pt, 6pt)
#let default-heading-spacing-after = (16.5pt, 6pt, 6pt, 6pt)

// 标题元数据字段定义见 headings-meta.typ

/// 创建前置部分的无编号标题（摘要、目录等）
/// enter-front: true 时将 part 切换到 1（前置部分）并重置页码。
#let front-heading(
  title,
  pagebreak: true,
  enter-front: false,
  ..extra-meta,
) = {
  heading(
    numbering: none,
    outlined: false,
    supplement: [#metadata((
      pagebreak: pagebreak,
      part: if enter-front { 1 } else { none },
      reset-page: enter-front,
      show-page-marks: true,
      ..extra-meta.named(),
    ))],
  )[#title]
}

/// 创建后置部分的无编号标题（致谢、声明等）
/// 与 front-heading 不同，默认 outlined: true（出现在目录中）。
#let back-heading(
  title,
  pagebreak: true,
  show-page-marks: true,
  outlined: true,
  ..extra-meta,
) = {
  heading(
    numbering: none,
    outlined: outlined,
    supplement: [#metadata((
      pagebreak: pagebreak,
      show-page-marks: show-page-marks,
      ..extra-meta.named(),
    ))],
  )[#title]
}

/// 渲染标题正文（不重新触发 show heading）
/// fs: 字号；style-font: 标题默认字体；number-spacing: 编号间距；fakebold: 是否使用伪粗体；meta: 通过 ..args 传入的元数据覆盖。
#let sizedheading(it, fs, style-font: (:), number-spacing: 1em, fakebold: false, ..meta) = {
  if it.body == none or it.body == [] { return }

  let spacing-before = meta.at(
    "heading-spacing-before",
    default: meta.at("spacing-before",
    default: default-heading-spacing-before.at(calc.min(it.level - 1, 3))),
  )
  let spacing-after = meta.at(
    "heading-spacing-after",
    default: meta.at("spacing-after",
    default: default-heading-spacing-after.at(calc.min(it.level - 1, 3))),
  )
  let linespacing = meta.at("linespacing", default: size.三号 * 1.3 * 2.41)
  let meta-font = meta.at("font", default: (:))

  show heading: set block(above: 0pt, below: 0pt)
  set par(first-line-indent: 0em, leading: linespacing - 1em, spacing: 0pt)
  v(spacing-before)
  let f = if meta-font != (:) { meta-font } else { (font: style-font.font, weight: style-font.weight, size: fs) }
  let body = if it.numbering != none {
    counter(heading).display() + h(number-spacing) + it.body
  } else {
    it.body
  }
  if fakebold {
    show-cn-fakebold(text(..f, body))
  } else {
    text(..f, body)
  }
  v(spacing-after)
}

/// heading show rule：处理第 1 级标题的分页、状态转换、计数器步进，
/// 然后委托 sizedheading 渲染
/// smartpagebreak: 由 config() 传入的分页函数（处理 always-start-odd）
/// style: 由 style.build(font) 构建的样式字典
#let heading-show-rule(it, smartpagebreak, style: none) = {
  set par(first-line-indent: 0em)

  let h-style = if it.level == 1 { style.章标题 }
    else if it.level == 2 { style.一级节标题 }
    else if it.level == 3 { style.二级节标题 }
    else { style.三级节标题 }

  if it.level != 1 {
    return sizedheading(it, get-heading-size(it.level, style: style), style-font: (font: h-style.font, weight: h-style.weight), number-spacing: h-style.编号间距, fakebold: h-style.fakebold, heading-spacing-before: h-style.spacing-before, heading-spacing-after: h-style.spacing-after, linespacing: style.标题行距)
  }

  let meta = get-heading-meta(it)
  let meta = meta + (heading-spacing-before: h-style.spacing-before, heading-spacing-after: h-style.spacing-after, linespacing: meta.at("linespacing", default: style.标题行距))
  let should-pagebreak = meta.at("pagebreak", default: true)
  let target-part = meta.at("part", default: none)
  let should-reset-page = meta.at("reset-page", default: false)

  if should-pagebreak {
    smartpagebreak()
  }

  context {
    let current-part = partcounter.at(here()).first()

    if target-part != none {
      partcounter.update(target-part)
    } else if it.numbering != none and current-part < 2 {
      partcounter.update(2)
    }

    if should-reset-page or (it.numbering != none and current-part < 2) {
      counter(page).update(1)
    }
  }

  if it.numbering != none {
    chaptercounter.step()
    reset-chapter-counters()
  }

  set align(h-style.align)
  sizedheading(it, style.章标题.size, style-font: (font: h-style.font, weight: h-style.weight), number-spacing: h-style.编号间距, fakebold: h-style.fakebold, ..meta)
}
