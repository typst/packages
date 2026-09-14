// lib/styles.typ - 样式规则
// 页眉页脚、heading、figure、ref 等 show/set 规则

#import "config.typ": (
  appendixcounter, chaptercounter, equationcounter, footnotecounter,
  imagecounter, partcounter, rawcounter, skippedstate, tablecounter, 字体, 字号,
  引用记号,
)
#import "utils.typ": chinesenumbering

#let default-heading-spacing-before = (17pt, 24pt, 12pt, 6pt)
#let default-heading-spacing-after = (16.5pt, 6pt, 6pt, 6pt)
#let sym-box-unchecked(size) = box(width: size, align(
  center + horizon,
  square(size: size),
))
#let sym-box-checked(size) = box(width: size, align(center + horizon, square(
  size: size,
)[✓]))

// 列表 marker：使用 itemize 的 label-baseline: "center" 对齐
// 高度设为字号大小以避免撑开行距
#let sym-square-filled(size) = box(
  width: 1em,
  align(center + horizon, square(size: size, fill: black)),
)
#let sym-square-filled-rotated(size) = box(
  width: 1em,
  align(center + horizon, rotate(45deg, square(size: size, fill: black))),
)
#let sym-bullet(size) = box(
  width: 1em,
  align(center + horizon, circle(radius: size / 2, fill: black)),
)

// 从 heading 提取元数据（从 supplement 中的 metadata 获取）
#let get-heading-meta(it) = {
  if it.supplement != none and it.supplement.func() == metadata {
    it.supplement.value
  } else {
    (:)
  }
}

// 生成页眉内容
#let make-header(cheader: none) = context {
  let part = partcounter.at(here()).first()

  // 使用逻辑页码进行奇偶判断
  let logical-page = counter(page).at(here()).first()

  // 查找当前页面之后的第一个 heading（用于处理页眉在 heading 之前渲染的情况）
  let headings-after = query(selector(heading.where(level: 1)).after(here()))
  let headings-before = query(selector(heading.where(level: 1)).before(here()))
  let current-physical-page = here().page()

  // 检查当前页面是否有 heading
  let current-page-heading = if headings-after.len() > 0 {
    let next-heading = headings-after.first()
    if next-heading.location().page() == current-physical-page {
      next-heading
    } else {
      none
    }
  } else {
    none
  }

  // 检查当前页面是否是前置部分第一页（摘要页，会将 part 更新为 1）
  let is-front-first-page = if current-page-heading != none {
    let meta = get-heading-meta(current-page-heading)
    meta.at("part", default: none) == 1
  } else {
    false
  }

  // 检查当前页面是否是正文第一页（包含第一个带编号的一级标题）
  let is-body-first-page = (
    current-page-heading != none
      and current-page-heading.numbering != none
      and part < 2
  )

  // 封面区域无页眉（但如果当前页是前置部分第一页则显示）
  if part == 0 and not is-front-first-page { return }

  // 如果是正文第一页，强制视为奇数页（页码将被重置为1）
  // 如果是前置部分第一页，也强制视为奇数页
  let is-odd = if is-body-first-page or is-front-first-page { true } else {
    calc.odd(logical-page)
  }
  let is-even = if is-body-first-page or is-front-first-page { false } else {
    calc.even(logical-page)
  }

  // 跳过的空白页不显示页眉
  if skippedstate.at(here()) and is-even { return }

  // 确定使用哪个 heading
  let el = if current-page-heading != none {
    current-page-heading
  } else if headings-before.len() > 0 {
    headings-before.last()
  } else {
    return
  }

  // 检查是否显示页眉
  let meta = get-heading-meta(el)
  if not meta.at("show-header", default: true) { return }

  let header-gap = 3pt

  set text(字号.五号)
  set par(spacing: 0pt)
  set align(center)

  // 对应 Word 模板中页眉上边距
  place(top + center, dy: 2cm)[
    #block(width: 100%)[
      #stack(
        dir: ttb,
        spacing: 3pt,
        if is-even {
          // 偶数页：论文标题
          cheader
        } else {
          // 奇数页：章节标题
          let header-text = meta.at("header", default: none)
          if header-text == none { header-text = el.body }

          // 编号（如果有）
          if el.numbering != none {
            chinesenumbering(
              ..counter(heading).at(el.location()),
              location: el.location(),
            )
            h(0.5em)
          }
          header-text
        },
        line(stroke: 0.75pt, length: 100%),
      )
    ]
  ]
}

// 生成页脚内容
#let make-footer() = context {
  let part = partcounter.at(here()).first()

  // 封面区域无页脚
  if part == 0 { return }

  // 使用逻辑页码进行奇偶判断
  let logical-page = counter(page).at(here()).first()
  if skippedstate.at(here()) and calc.even(logical-page) { return }

  // 封面和版权声明页没有页码
  if query(selector(heading).before(here())).len() < 2 { return }

  // 当存在 <__clean_declaration__> 元素时，不显示原创性声明页的页码
  if (
    query(selector(heading).after(here())).len() == 0
      and query(selector(<__clean_declaration__>)).len() > 0
  ) { return }

  set text(字号.页码)
  set align(center)

  let page-num = counter(page).at(here()).first()

  place(bottom + center)[
    #set align(bottom)
    #if part == 1 {
      numbering("I", page-num)
    } else {
      str(page-num)
    }
    // 对应 Word 模板中页脚下边距
    #v(1.75cm)
  ]
}

// heading 尺寸计算
// 注意：一级标题直接使用 字号.一级标题，在 heading-show-rule 中处理
#let get-heading-size(level) = {
  if level == 1 {
    字号.一级标题
  } else if level == 2 {
    字号.二级标题
  } else if level == 3 {
    字号.三级标题
  } else {
    字号.小四
  }
}

// heading 渲染（只渲染标题内容，不重新渲染整个 heading 元素）
#let sizedheading(it, size, ..meta) = {
  // 如果 heading 内容为空，跳过渲染
  if it.body == none or it.body == [] { return }

  // Word 模板中默认标题的段前间距为 17pt，段后间距为 16.5pt
  let spacing-before = meta.at(
    "spacing-before",
    default: default-heading-spacing-before.at(calc.min(it.level - 1, 3)),
  )
  let spacing-after = meta.at(
    "spacing-after",
    default: default-heading-spacing-after.at(calc.min(it.level - 1, 3)),
  )
  // Word 模板中默认标题的行距为 2.41 倍行距
  // 在黑体三号字情况下，对应行距为 16pt * 1.3 * 2.41
  let linespacing = meta.at("linespacing", default: 字号.三号 * 1.3 * 2.41)
  let font = meta.at("font", default: (:))

  // 清除 Typst 标题自带的前后间距
  show heading: set block(above: 0pt, below: 0pt)
  set par(first-line-indent: 0em, leading: linespacing - 1em, spacing: 0pt)
  v(spacing-before)
  if it.numbering != none {
    strong(counter(heading).display())
    // 标题编号和标题之间间距为 1em
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

// heading 样式规则
#let heading-show-rule(it, smartpagebreak) = {
  // 取消标题的首行缩进
  set par(first-line-indent: 0em)

  if it.level != 1 {
    return sizedheading(it, get-heading-size(it.level))
  }

  // 提取元数据
  let meta = get-heading-meta(it)
  let should-pagebreak = meta.at("pagebreak", default: true)
  let target-part = meta.at("part", default: none)
  let should-reset-page = meta.at("reset-page", default: false)

  // 1. 分页
  if should-pagebreak {
    smartpagebreak()
  }

  // 2. 状态更新
  context {
    let current-part = partcounter.at(here()).first()

    if target-part != none {
      // 显式指定 part
      partcounter.update(target-part)
    } else if it.numbering != none and current-part < 2 {
      // 第一个带编号章节自动进入正文
      partcounter.update(2)
    }

    // 重置页码
    if should-reset-page or (it.numbering != none and current-part < 2) {
      counter(page).update(1)
    }
  }

  // 3. 计数器重置（仅正文章节）
  if it.numbering != none {
    chaptercounter.step()
    footnotecounter.update(())
    imagecounter.update(())
    tablecounter.update(())
    rawcounter.update(())
    equationcounter.update(())
  }

  // 4. 渲染
  set align(center)
  sizedheading(it, 字号.三号, ..meta)
}

// figure 样式规则
#let figure-show-rule(it, supplements: 引用记号) = [
  #set align(center)
  #if not it.has("kind") {
    it
  } else if it.kind == image {
    it.body
    [
      #set text(字号.五号)
      #it.caption
    ]
  } else if it.kind == table {
    [
      #set text(字号.五号)
      #it.caption
    ]
    it.body
  } else if it.kind == "code" {
    [
      #set text(字号.五号)
      #context { supplements.代码 + it.counter.display(it.numbering) + "   " }
      #it.caption.body
    ]
    it.body
  } else {
    // 未知类型的 figure 保持原样
    it
  }
]

// ref 样式规则
#let ref-show-rule(it, supplements: 引用记号) = {
  if it.element == none {
    // 参考文献引用保持原样
    it
  } else {
    // 移除前后空白
    h(0em, weak: true)

    let el = it.element
    let el_loc = el.location()
    if el.func() == math.equation {
      // 公式引用
      link(el_loc, [
        #supplements.公式
        #chinesenumbering(
          chaptercounter.at(el_loc).first(),
          equationcounter.at(el_loc).first(),
          location: el_loc,
          brackets: true,
        )
      ])
      h(0.25em, weak: true)
    } else if el.func() == figure {
      // 图表引用
      if el.kind == image {
        link(el_loc, [
          #supplements.图
          #chinesenumbering(
            chaptercounter.at(el_loc).first(),
            imagecounter.at(el_loc).first(),
            location: el_loc,
          )
        ])
      } else if el.kind == table {
        link(el_loc, [
          #supplements.表
          #chinesenumbering(
            chaptercounter.at(el_loc).first(),
            tablecounter.at(el_loc).first(),
            location: el_loc,
          )
        ])
      } else if el.kind == "code" {
        link(el_loc, [
          #supplements.代码
          #chinesenumbering(
            chaptercounter.at(el_loc).first(),
            rawcounter.at(el_loc).first(),
            location: el_loc,
          )
        ])
      } else {
        // 未知类型的 figure，使用 kind 名称或默认使用原始引用
        link(el_loc, [
          #if type(el.kind) == str { el.kind } else { supplements.图表 }
          #counter(figure.where(kind: el.kind)).display(el.numbering)
        ])
      }
    } else if el.func() == heading {
      // 章节引用
      if el.level == 1 {
        link(el_loc, chinesenumbering(
          ..counter(heading).at(el_loc),
          location: el_loc,
        ))
      } else {
        link(el_loc, [
          #supplements.节
          #chinesenumbering(..counter(heading).at(el_loc), location: el_loc)
        ])
      }
    } else {
      it
    }

    h(0em, weak: true)
  }
}

// bibliography 样式规则
// Word 模板：行距 16pt，段前 3pt，悬挂缩进 1.66 字符
#let bibliography-show-rule(it) = {
  set text(字号.五号)
  set par(
    leading: 6.5pt,
    spacing: 6.5pt + 3pt,
    hanging-indent: 1.66em,
    first-line-indent: 0em,
  )
  show regex("\\[\\d+\\]"): it => {
    box[
      #it
      // 手工对齐编号和文字
      #v(-8.5pt)
    ]
  }
  it
}
