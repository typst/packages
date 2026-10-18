#import "bilingual-figured.typ"
#import "style.typ": 字号, 行距

#let _typst-numbering = numbering

#let continuation-style(
  separator: h(1em),
  caption_align: center,
  // 1.25 倍行距：Typst leading 是额外间隙，取 行距.正文，勿写 1.25em。
  caption_par: (leading: 行距.正文),
  note_par: auto,
  zh_text: (size: 字号.五号, weight: "bold"),
  en_text: (size: 字号.五号, weight: "bold"),
  note_text: (size: 字号.五号),
  note_prefix: [*注：* ],
  note_align: left,
  // 块外间距：取规范值，但中英标题之间需保留一行行距（与 custom-figure
  // 同口径）。Typst leading 只在段落内部生效，两个单行 block 之间基线距
  // 不含 leading，其实测见 docs/CUSTOMIZE.md，故英文题段前取一个 leading。
  // 仅 _render-caption（手动续表）使用 zh_block/en_block；
  // _render-auto-header-caption 用显式 v(caption_gap) 分隔。
  zh_block: (above: 6pt, below: 0pt),
  en_block: (above: 行距.正文, below: 12pt),
  note_block: (above: 6pt, below: 0pt, inset: (left: 2em)),
  continued_mark_zh: [（续表）],
  continued_mark_en: [(continued)],
  // 续表表头中英文标题间距：同上，取一个 leading 使中英题基线距约 1.25×字号。
  caption_gap: 行距.正文,
  header_cell: (stroke: none, inset: (x: 0pt, top: 0pt, bottom: 0.6em)),
  // 表题与表体间距：规范未定量，取 8pt（与 LaTeX 模板 caption skip 一致）。
  auto_header_gap: 8pt,
  table_align: center,
  cell_align: center,
  continued_block: (above: 1.25em, below: 1em),
) = (
  separator: separator,
  caption_align: caption_align,
  caption_par: caption_par,
  note_par: note_par,
  zh_text: zh_text,
  en_text: en_text,
  note_text: note_text,
  note_prefix: note_prefix,
  note_align: note_align,
  zh_block: zh_block,
  en_block: en_block,
  note_block: note_block,
  continued_mark_zh: continued_mark_zh,
  continued_mark_en: continued_mark_en,
  caption_gap: caption_gap,
  header_cell: header_cell,
  auto_header_gap: auto_header_gap,
  table_align: table_align,
  cell_align: cell_align,
  continued_block: continued_block,
)

#let _default-continuation-style = continuation-style()

#let _auto-caption-style(style) = (
  style
    + (
      zh_block: (above: 0pt, below: 0pt),
      en_block: (above: 0pt, below: 0pt),
    )
)

#let _render-auto-header-caption(
  number,
  caption_zh,
  caption_en,
  supplement_zh,
  supplement_en,
  style,
  continued: false,
) = [
  #set align(style.caption_align)
  #set text(..style.zh_text)
  // 中文表题段前 6pt（规范值；表头首行内渲染，以上边距实现）。
  #block(above: 6pt, below: 0pt)[
    #supplement_zh #number #style.separator #caption_zh
    #if continued { [#style.continued_mark_zh] }
  ]
  #if caption_en != none {
    v(style.caption_gap)
    set text(..style.en_text)
    block(above: 0pt, below: 0pt)[
      #supplement_en #number #style.separator #caption_en
      #if continued { [#h(0.4em) #style.continued_mark_en] }
    ]
  }
  #v(style.auto_header_gap)
]

#let _render-caption(
  number,
  caption_zh,
  caption_en,
  supplement_zh,
  supplement_en,
  style,
  continued: false,
) = [
  #set align(style.caption_align)
  #if style.caption_par != none and style.caption_par != (:) {
    set par(..style.caption_par)
  }
  #set text(..style.zh_text)
  #block(..style.zh_block)[
    #supplement_zh #number #style.separator #caption_zh
    #if continued { [#style.continued_mark_zh] }
  ]
  #if caption_en != none {
    set text(..style.en_text)
    block(..style.en_block)[
      #supplement_en #number #style.separator #caption_en
      #if continued { [#h(0.4em) #style.continued_mark_en] }
    ]
  }
]

#let _render-note(note, style) = if note == none {
  []
} else {
  let note-par = if style.note_par == auto {
    style.caption_par
  } else {
    style.note_par
  }
  [
    #set align(style.note_align)
    #if note-par != none and note-par != (:) {
      set par(..note-par)
    }
    #set text(..style.note_text)
    // 注续行缩进：grid 两列分置"注："前缀与注释正文，续行几何对齐至前缀之后。
    // 与 bilingual-figured._render-bilingual-note 同构，详见该处说明。
    #block(..style.note_block)[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 0pt,
        align: (left, left),
        style.note_prefix, note,
      )
    ]
  ]
}

#let _prepare-heading-prefix(
  loc,
  level: 1,
  zero-fill: true,
  leading-zero: true,
) = {
  let numbers = counter(heading).at(loc)
  while zero-fill and numbers.len() < level {
    numbers.push(0)
  }
  if numbers.len() > level {
    numbers = numbers.slice(0, level)
  }
  if not leading-zero and numbers.at(0, default: none) == 0 {
    numbers = numbers.slice(1)
  }
  numbers
}

#let _table-index-at(loc, kind: "bitable") = {
  let prefixed-index = counter(
    figure.where(kind: bilingual-figured.prefixed-kind(kind)),
  )
    .at(loc)
    .at(0, default: 0)
  if prefixed-index > 0 {
    prefixed-index
  } else {
    counter(figure.where(kind: kind)).at(loc).at(0, default: 1)
  }
}

#let _display-table-number(
  loc,
  numbering: "1-1",
  level: 1,
  zero-fill: true,
  leading-zero: true,
  kind: "bitable",
) = {
  let heading-prefix = _prepare-heading-prefix(
    loc,
    level: level,
    zero-fill: zero-fill,
    leading-zero: leading-zero,
  )
  let index = _table-index-at(loc, kind: kind)
  _typst-numbering(numbering, ..heading-prefix, index)
}

#let _source-caption-data(source) = {
  let extracted = bilingual-figured.extract-bilingual-caption(source)
  if extracted == none {
    (
      zh: none,
      en: none,
      supplement_zh: [表],
      supplement_en: [Table],
    )
  } else {
    (
      zh: extracted.zh,
      en: extracted.en,
      supplement_zh: extracted.supplement_zh,
      supplement_en: extracted.supplement_en,
    )
  }
}

#let _resolve-columns(columns) = {
  if type(columns) == int {
    let resolved = ()
    for _i in range(0, columns) {
      resolved.push(auto)
    }
    resolved
  } else {
    columns
  }
}

#let auto-table(
  caption-zh: none,
  caption-en: none,
  note: none,
  columns: auto,
  header: (),
  label: none,
  numbering: "1-1",
  // auto：按当前是否附录自动选"表/附表"。
  supplement-zh: auto,
  supplement-en: auto,
  level: 1,
  zero-fill: true,
  leading-zero: true,
  style: (:),
  // 卧排（landscape）：true 时整表逆时针旋转 90°，顶左底右，适用于宽表。
  // 旋转内容不跨页，故强制 breakable:false 保证整体不分页。与 bifigure/bitable
  // 的 landscape 同语义，但 auto-table 不经 show-figure，须在此自行包裹 rotate。
  landscape: false,
  ..args,
) = {
  if caption-zh == none {
    panic("auto-table 需要提供 caption-zh")
  }
  if columns == auto {
    panic("auto-table 需要显式提供 columns")
  }

  let col-count = if type(columns) == int {
    columns
  } else if type(columns) == array {
    columns.len()
  } else {
    panic("auto-table 的 columns 需为整数或列宽数组")
  }

  let merged-style = _default-continuation-style + style
  let resolved-columns = _resolve-columns(columns)
  let table-named = args.named()

  context {
    // 解析 supplement：附录中自动用"附表/Appendix Table"，正文用"表/Table"，
    // 用户显式传参时尊重其选择。与 show-figure 对 bifigure/bitable 的改写保持一致，
    // 使 auto-table 的正文标题、图表目录、续表页眉前缀全部统一。
    let appendix = bilingual-figured.in-appendix()
    let supp-zh = if supplement-zh == auto {
      bilingual-figured.resolve-supplement("bitable", none, appendix)
    } else {
      supplement-zh
    }
    let supp-en = if supplement-en == auto {
      if appendix { [Appendix Table] } else { [Table] }
    } else {
      supplement-en
    }

    let anchor-figure = figure(
      block(width: 0pt, height: 0pt)[],
      kind: "bitable",
      supplement: none,
      numbering: numbering,
      caption: metadata((
        zh: caption-zh,
        en: caption-en,
        note: note,
        supplement_zh: supp-zh,
        supplement_en: supp-en,
        render: false,
      )),
    )

    let anchor = if label != none {
      [#anchor-figure #label]
    } else {
      anchor-figure
    }

    // 表块（含续表表头 caption 与 note）。卧排时强制不分页——旋转内容不跨页，
    // breakable:false 保证整体在一页内；非卧排保持 breakable:true 支持长表跨页。
    let table-block = block(
      breakable: not landscape,
      width: 100%,
      above: 0pt,
      below: 0.9em,
      {
        set align(merged-style.table_align)
        table(
          columns: resolved-columns,
          ..table-named,
          table.header(
            table.cell(
              colspan: col-count,
              ..merged-style.header_cell,
              context {
                let number = _display-table-number(
                  here(),
                  numbering: numbering,
                  level: level,
                  zero-fill: zero-fill,
                  leading-zero: leading-zero,
                )
                let current-page = here().position().page
                let anchors = query(
                  selector(
                    figure.where(
                      kind: bilingual-figured.prefixed-kind("bitable"),
                    ),
                  ).before(here()),
                )
                let anchor-page = if anchors.len() > 0 {
                  anchors.last().location().page()
                } else {
                  current-page
                }
                let auto-style = _auto-caption-style(merged-style)
                _render-auto-header-caption(
                  number,
                  caption-zh,
                  caption-en,
                  supp-zh,
                  supp-en,
                  auto-style,
                  continued: current-page > anchor-page,
                )
              },
            ),
            ..header,
          ),
          ..args.pos(),
        )
        _render-note(note, merged-style)
      },
    )

    // 卧排（landscape）：整表逆时针旋转 90°，使表顶朝页面左侧、表底朝右侧，
    // 符合 UCAS 规范"顶左底右"。reflow: true 让旋转后包围盒重算，正确影响布局
    // （Typst 官方 tables 指南方案）。auto-table 的 caption 在表头内渲染（非
    // figure.caption），随 table-block 一同旋转，方位一致。旋转内容不跨页，
    // 上方已 breakable:false。
    if landscape {
      [#anchor #rotate(-90deg, reflow: true, table-block)]
    } else {
      [#anchor #table-block]
    }
  }
}

#let continued-table(
  source,
  caption-zh: auto,
  caption-en: auto,
  supplement-zh: auto,
  supplement-en: auto,
  note: none,
  numbering: "1-1",
  level: 1,
  zero-fill: true,
  leading-zero: true,
  kind: "bitable",
  style: (:),
  body,
) = context {
  let matched = query(source)
  if matched.len() == 0 {
    panic("continued-table 未找到源表标签: " + repr(source))
  }

  let origin = matched.first()
  let source-data = _source-caption-data(origin)
  let zh = if caption-zh == auto { source-data.zh } else { caption-zh }
  let en = if caption-en == auto { source-data.en } else { caption-en }
  let supp-zh = if supplement-zh == auto {
    source-data.supplement_zh
  } else {
    supplement-zh
  }
  let supp-en = if supplement-en == auto {
    source-data.supplement_en
  } else {
    supplement-en
  }

  if zh == none {
    panic("continued-table 需要 caption-zh，或确保源表具有双语标题元数据")
  }

  // 续表编号必须与原表一致（章节号 + 表序号），故沿用 auto-table 的
  // _display-table-number，而非 display-figure-number——后者只取 figure
  // 计数器单值，会把章节号位错填成表序号，渲染成「表 1」而非「表 1-1」。
  let number = _display-table-number(
    origin.location(),
    numbering: numbering,
    level: level,
    zero-fill: zero-fill,
    leading-zero: leading-zero,
    kind: kind,
  )
  let merged-style = _default-continuation-style + style

  // 外层 block 必须占满正文宽度（width: 100%），否则 block 按内容收缩后
  // 被置于页面左侧，_render-caption 内部的 set align(center) 只能让标题在
  // 收缩后的小 block 内居中，整体仍偏左。auto-table 同样以 width: 100% 解决。
  block(width: 100%, ..merged-style.continued_block)[
    #_render-caption(
      number,
      zh,
      en,
      supp-zh,
      supp-en,
      merged-style,
      continued: true,
    )
    #align(merged-style.table_align)[
      #body
    ]
    #_render-note(note, merged-style)
  ]
}
