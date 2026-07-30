// ============================================================
// headings.typ — 标题系统
// 提供标题渲染的全套机制：
//   - front-heading / back-heading：前置/后置部分标题创建
//   - get-heading-meta：从 heading supplement 提取元数据
//   - sizedheading：按等级和参数渲染标题
//   - heading-show-rule：全局 show rule，处理分页、状态转换、计数器步进
// ============================================================

#import "const.typ": size
#import "utils.typ": partcounter, chaptercounter, footnotecounter, imagecounter, tablecounter, rawcounter, equationcounter

/// 根据标题等级返回对应字号（用于 2–4 级标题）。
#let get-heading-size(level) = {
  if level == 1 {
    size.一级标题
  } else if level == 2 {
    size.二级标题
  } else if level == 3 {
    size.三级标题
  } else {
    size.正文
  }
}

/// 各级标题段前/段后默认间距。
#let default-heading-spacing-before = (17pt, 24pt, 12pt, 6pt)
#let default-heading-spacing-after = (16.5pt, 6pt, 6pt, 6pt)

// Heading supplement 中可嵌入的元数据字段：
//   pagebreak: bool         - 是否在此 heading 前分页（默认 true）
//   part: int | none        - 状态转换目标 (0/1/2/none)
//   reset-page: bool        - 是否重置页码为 1（默认 false）
//   show-header: bool       - 是否显示页眉（默认 true）
//   header: content | none  - 自定义页眉文本（替换标题）
//   spacing-before/after    - 覆盖默认段间距
//   linespacing             - 覆盖默认行距
//   font                    - 覆盖默认字体

/// 创建前置部分的无编号标题（摘要、目录等）。
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
      show-header: true,
      ..extra-meta.named(),
    ))],
  )[#title]
}

/// 创建后置部分的无编号标题（致谢、声明等）。
/// 与 front-heading 不同，默认 outlined: true（出现在目录中）。
#let back-heading(
  title,
  pagebreak: true,
  show-header: true,
  ..extra-meta,
) = {
  heading(
    numbering: none,
    outlined: true,
    supplement: [#metadata((
      pagebreak: pagebreak,
      show-header: show-header,
      ..extra-meta.named(),
    ))],
  )[#title]
}

/// 从 heading 的 supplement 中提取元数据字典。
/// 元数据通过 metadata 嵌入在 supplement 字段中。
#let get-heading-meta(it) = {
  if it.supplement != none and it.supplement.func() == metadata {
    it.supplement.value
  } else {
    (:)
  }
}

/// 渲染标题正文（不重新触发 show heading）。
/// fs: 字号；meta: 通过 ..args 传入的元数据覆盖。
#let sizedheading(it, fs, ..meta) = {
  if it.body == none or it.body == [] { return }

  let spacing-before = meta.at(
    "spacing-before",
    default: default-heading-spacing-before.at(calc.min(it.level - 1, 3)),
  )
  let spacing-after = meta.at(
    "spacing-after",
    default: default-heading-spacing-after.at(calc.min(it.level - 1, 3)),
  )
  let linespacing = meta.at("linespacing", default: size.三号 * 1.3 * 2.41)
  let font = meta.at("font", default: (:))

  show heading: set block(above: 0pt, below: 0pt)
  set par(first-line-indent: 0em, leading: linespacing - 1em, spacing: 0pt)
  v(spacing-before)
  if it.numbering != none {
    strong(counter(heading).display())
    h(1em)
  }
  if font != (:) {
    set text(..font)
    it.body
  } else {
    strong(it.body)
  }
  v(spacing-after)
}

/// heading show rule：处理第 1 级标题的分页、状态转换、计数器步进，
/// 然后委托 sizedheading 渲染。
/// smartpagebreak: 由 config() 传入的分页函数（处理 always-start-odd）。
#let heading-show-rule(it, smartpagebreak) = {
  set par(first-line-indent: 0em)

  if it.level != 1 {
    return sizedheading(it, get-heading-size(it.level))
  }

  let meta = get-heading-meta(it)
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
    footnotecounter.update(())
    imagecounter.update(())
    tablecounter.update(())
    rawcounter.update(())
    equationcounter.update(())
  }

  set align(center)
  sizedheading(it, size.三号, ..meta)
}
