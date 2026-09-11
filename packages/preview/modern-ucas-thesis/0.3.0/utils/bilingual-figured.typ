/*
Copyright (c) 2023 RubixDev <silas.groh@t-online.de>
Copyright (c) 2026 modern-ucas-thesis contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#let _prefix = "bilingual-figured-"

// 附录模式标记。附录布局（layouts/appendix.typ）将其置为 true，
// 使图表前缀由"图/表"切换为"附图/附表"。
// bifigure/bitable 经 show-figure 重建时改写 caption metadata；
// auto-table 等不经 show-figure 的工具在构造时读取此 state 自行解析。
#let _appendix-state = state("bilingual-figured-appendix", false)

// 标记进入附录模式，返回不可见内容，须插入文档流生效。
#let enter-appendix-mode() = _appendix-state.update(true)

// 在 context 内查询当前是否处于附录模式。
#let in-appendix() = _appendix-state.get()

#let prefixed-kind(kind) = {
  if type(kind) == str {
    _prefix + kind
  } else {
    _prefix + repr(kind)
  }
}

#let is-kind(kind-value, kind) = {
  (
    type(kind-value) == str
      and (
        kind-value == kind or kind-value == prefixed-kind(kind)
      )
  )
}

#let is-prefixed-kind(kind-value, kind) = {
  type(kind-value) == str and kind-value == prefixed-kind(kind)
}

#let reset-counters(
  it,
  level: 1,
  extra-kinds: (),
  include_bilingual_kinds: true,
  equations: true,
  return-orig-heading: true,
) = {
  if it.level <= level {
    let default-extra = if include_bilingual_kinds {
      ("bifigure", "bitable")
    } else {
      ()
    }
    for kind in (image, table, raw) + default-extra + extra-kinds {
      counter(figure.where(kind: prefixed-kind(kind))).update(0)
    }
    if equations {
      counter(math.equation).update(0)
    }
  }
  if return-orig-heading {
    it
  }
}

#let _typst-numbering = numbering
#let _prepare-dict(it, level, zero-fill, leading-zero, numbering) = {
  let numbers = counter(heading).at(it.location())
  while zero-fill and numbers.len() < level { numbers.push(0) }
  if numbers.len() > level { numbers = numbers.slice(0, level) }
  if not leading-zero and numbers.at(0, default: none) == 0 {
    numbers = numbers.slice(1)
  }

  let dic = it.fields()
  let _ = if "body" in dic { dic.remove("body") }
  let _ = if "label" in dic { dic.remove("label") }
  let _ = if "counter" in dic { dic.remove("counter") }
  dic + (numbering: n => _typst-numbering(numbering, ..numbers, n))
}

// 当原 caption 为双语 metadata 时，用给定 supplement 覆盖其中的
// supplement_zh / supplement_en，返回新的 figure.caption；否则原样返回。
// 供附录等需要改写图表前缀（如"图"→"附图"）的场景使用。
#let _with-supplement(cap, supplement-zh, supplement-en) = {
  if supplement-zh == none and supplement-en == none {
    cap
  } else if cap == none or not cap.has("body") {
    cap
  } else {
    let body = cap.body
    let is-meta = (
      type(body) == metadata or (type(body) == content and body.has("value"))
    )
    if not is-meta or type(body.value) != dictionary {
      cap
    } else {
      let new-value = body.value
      if supplement-zh != none {
        new-value = new-value + (supplement_zh: supplement-zh)
      }
      if supplement-en != none {
        new-value = new-value + (supplement_en: supplement-en)
      }
      figure.caption(metadata(new-value))
    }
  }
}

#let show-figure(
  it,
  level: 1,
  zero-fill: true,
  leading-zero: true,
  numbering: "1-1",
  extra-prefixes: (:),
  fallback-prefix: "fig:",
  // 覆盖双语 caption 的 supplement（如附录用"附图/附表"）。
  // 为 none 时不覆盖，保留调用方（bifigure/bitable）传入的原值。
  supplement-zh: none,
  supplement-en: none,
) = {
  if type(it.kind) == str and it.kind.starts-with(_prefix) {
    it
  } else {
    let figure = figure(
      it.body,
      .._prepare-dict(it, level, zero-fill, leading-zero, numbering),
      kind: prefixed-kind(it.kind),
      caption: _with-supplement(
        it.caption,
        supplement-zh,
        supplement-en,
      ),
    )
    if it.has("label") {
      let kind-key = if type(it.kind) == str { it.kind } else { repr(it.kind) }
      let prefixes = (
        (
          table: "tbl:",
          raw: "lst:",
          bitable: "tbl:",
          bifigure: "fig:",
        )
          + extra-prefixes
      )
      let label-text = str(it.label)
      let prefix = prefixes.at(kind-key, default: fallback-prefix)
      let new-label = label(if label-text.starts-with(prefix) {
        label-text
      } else {
        prefix + label-text
      })
      [#figure #new-label]
    } else {
      figure
    }
  }
}

#let show-equation(
  it,
  level: 1,
  zero-fill: true,
  leading-zero: true,
  numbering: "(1-1)",
  supplement: none,
  prefix: "eqt:",
  only-labeled: false,
  unnumbered-label: "-",
) = {
  if (
    only-labeled and not it.has("label")
      or it.has("label")
        and (
          str(it.label).starts-with(prefix) or str(it.label) == unnumbered-label
        )
      or not it.block
  ) {
    it
  } else {
    let equation-fields = _prepare-dict(
      it,
      level,
      zero-fill,
      leading-zero,
      numbering,
    )
    let equation-fields = if supplement == auto {
      equation-fields
    } else {
      equation-fields + (supplement: supplement)
    }
    let equation = math.equation(
      it.body,
      ..equation-fields,
    )
    if it.has("label") {
      let new-label = label(prefix + str(it.label))
      [#equation #new-label]
    } else {
      let new-label = label(prefix + _prefix + "no-label")
      [#equation #new-label]
    }
  }
}

#let _typst-outline = outline
#let outline(target-kind: image, title: [List of Figures], ..args) = {
  _typst-outline(
    ..args,
    title: title,
    target: figure.where(kind: prefixed-kind(target-kind)),
  )
}

#let display-figure-number(fig) = {
  let numbers = fig.counter.at(fig.location())
  _typst-numbering(fig.numbering, ..numbers)
}

#let _default-supplements(kind) = if is-kind(kind, "bitable") {
  (zh: [表], en: [Table])
} else {
  (zh: [图], en: [Figure])
}

// 按图表种类与当前是否附录，解析 supplement 默认值。
// supp 为 none 时按 kind 与附录状态返回"图/附图"或"表/附表"；
// 非 none 时（用户显式指定）原样返回，尊重用户覆盖。
// 供 auto-table 等不经 show-figure 重建的工具在构造时解析前缀。
#let resolve-supplement(kind, supp, appendix) = {
  if supp != none {
    supp
  } else if appendix {
    if is-kind(kind, "bitable") or is-kind(kind, "table") { [附表] } else {
      [附图]
    }
  } else {
    _default-supplements(kind).zh
  }
}

#let _bilingual-caption-data(
  caption-zh,
  caption-en,
  note,
  supplement-zh,
  supplement-en,
  // 当需要外部自定义渲染（如续表页眉）时可设为 false。
  // 默认 true，保持 bilingual-figured 的原生渲染行为不变。
  render: true,
  // 卧排表（landscape）：true 时整个图表（含标题与注释）逆时针旋转 90°，
  // 使表顶朝页面左侧、表底朝右侧，符合 UCAS 规范"顶左底右"。适用于宽表。
  // 旋转内容不跨页，故卧排表应控制在一页之内。
  landscape: false,
) = (
  zh: caption-zh,
  en: caption-en,
  note: note,
  supplement_zh: supplement-zh,
  supplement_en: supplement-en,
  render: render,
  landscape: landscape,
)

#let extract-bilingual-caption(fig) = {
  if fig == none or type(fig) != content or not fig.has("caption") {
    none
  } else {
    let caption = fig.caption
    if caption == none or not caption.has("body") or caption.body == none {
      none
    } else {
      let body = caption.body
      let is-meta = (
        type(body) == metadata or (type(body) == content and body.has("value"))
      )
      if not is-meta {
        none
      } else {
        let value = body.value
        let default-supp = _default-supplements(if fig.has("kind") {
          fig.kind
        } else {
          none
        })
        if type(value) == dictionary {
          let zh = value.at("zh", default: value.at(
            "caption_zh",
            default: none,
          ))
          if zh == none {
            none
          } else {
            (
              zh: zh,
              en: value.at("en", default: value.at(
                "caption_en",
                default: none,
              )),
              note: value.at("note", default: none),
              supplement_zh: value.at(
                "supplement_zh",
                default: default-supp.zh,
              ),
              supplement_en: value.at(
                "supplement_en",
                default: default-supp.en,
              ),
              render: value.at("render", default: true),
              landscape: value.at("landscape", default: false),
            )
          }
        } else if type(value) == array and value.len() >= 1 {
          (
            zh: value.at(0, default: none),
            en: value.at(1, default: none),
            note: value.at(2, default: none),
            supplement_zh: value.at(3, default: default-supp.zh),
            supplement_en: value.at(4, default: default-supp.en),
            render: value.at(5, default: true),
            landscape: value.at(6, default: false),
          )
        } else {
          none
        }
      }
    }
  }
}

#let bifigure(
  body,
  caption-zh: none,
  caption-en: none,
  note: none,
  kind: "bifigure",
  supplement-zh: [图],
  supplement-en: [Figure],
  numbering: "1-1",
  // 卧排（landscape）：true 时整图逆时针旋转 90°，顶左底右，适用于宽图。
  // 旋转内容不跨页，故卧排图表应控制在一页之内。详见 _render-bilingual。
  landscape: false,
  ..args,
) = {
  figure(
    body,
    supplement: none,
    kind: kind,
    caption: metadata(_bilingual-caption-data(
      caption-zh,
      caption-en,
      note,
      supplement-zh,
      supplement-en,
      landscape: landscape,
    )),
    numbering: numbering,
    ..args,
  )
}

#let bitable(
  body,
  caption-zh: none,
  caption-en: none,
  note: none,
  kind: "bitable",
  supplement-zh: [表],
  supplement-en: [Table],
  numbering: "1-1",
  // 卧排（landscape）：true 时整表逆时针旋转 90°，顶左底右，适用于宽表。
  // 旋转内容不跨页，故卧排表应控制在一页之内。详见 _render-bilingual。
  landscape: false,
  ..args,
) = {
  figure(
    body,
    supplement: none,
    kind: kind,
    caption: metadata(_bilingual-caption-data(
      caption-zh,
      caption-en,
      note,
      supplement-zh,
      supplement-en,
      landscape: landscape,
    )),
    numbering: numbering,
    ..args,
  )
}

#let bilingual-caption-style(
  separator: h(1em),
  caption_align: center,
  caption_par: (:),
  note_par: auto,
  zh_text: (weight: "bold"),
  en_text: (:),
  note_text: (:),
  note_prefix: [注：],
  note_align: left,
  zh_block: (above: 6pt, below: 0pt),
  en_block: (above: 0pt, below: 12pt),
  note_block: (above: 6pt, below: 0pt),
  keep_together: true,
  float_clearance: 1.5em,
  float_align: center,
  float_width: 100%,
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
  keep_together: keep_together,
  float_clearance: float_clearance,
  float_align: float_align,
  float_width: float_width,
)

#let _default-bilingual-style = bilingual-caption-style()

#let _render-bilingual-caption(data, number, style) = {
  let zh-block = style.zh_block
  let en-block = style.en_block
  [
    #set align(style.caption_align)
    #if style.caption_par != none and style.caption_par != (:) {
      set par(..style.caption_par)
    }
    #set text(..style.zh_text)
    #block(..zh-block)[
      #data.supplement_zh #number #style.separator #data.zh
    ]
    #if data.en != none {
      set text(..style.en_text)
      block(..en-block)[
        #data.supplement_en #number #style.separator #data.en
      ]
    }
  ]
}

#let _render-bilingual-note(data, style) = if data.note == none {
  []
} else {
  let note-par = if style.note_par == auto {
    style.caption_par
  } else {
    style.note_par
  }
  let note-block = style.note_block
  [
    #set align(style.note_align)
    #if note-par != none and note-par != (:) {
      set par(..note-par)
    }
    #set text(..style.note_text)
    // 注续行缩进：用 grid 两列把"注："前缀与注释正文分列。前缀列 auto 取自身
    // 宽度，正文列 1fr 填满剩余，换行时续行自然落在前缀之后，几何上保证缩进至
    // "注："后。block 的 inset 仍提供整体左缩进。不用 par(hanging-indent)——
    // block 内纯文本不形成段落（Typst 规定容器需含 block 级内容才包裹段落），
    // 且 inset 会压平 hanging-indent，实测无效。
    #block(..note-block)[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 0pt,
        align: (left, left),
        style.note_prefix, data.note,
      )
    ]
  ]
}

#let _render-bilingual(it, kind, style: (:), title_on_top: false) = {
  let data = extract-bilingual-caption(it)
  if data == none or data.zh == none {
    it
  } else {
    let merged-style = _default-bilingual-style + style
    if data.render == false {
      it
    } else {
      let number = it.counter.display(it.numbering)
      let title = _render-bilingual-caption(data, number, merged-style)
      let note = _render-bilingual-note(data, merged-style)
      let stacked = if title_on_top {
        [#title #it.body #note]
      } else {
        [#it.body #title #note]
      }
      let rendered = if merged-style.keep_together {
        block(breakable: false, stacked)
      } else {
        stacked
      }

      // 卧排（landscape）：整图/表逆时针旋转 90°，使表顶朝页面左侧、表底朝右侧，
      // 符合 UCAS 规范"顶左底右"。caption 与 note 随 stacked 一同旋转，保持整体
      // 方位一致。reflow: true 让旋转后包围盒重算，正确影响布局（Typst 官方 tables
      // 指南方案）。旋转内容不跨页，故 keep_together 默认 true 下 breakable:false
      // 已保证整体不分页；keep_together:false 的卧排由用户自担跨页风险。
      if data.landscape {
        rendered = rotate(-90deg, reflow: true, rendered)
      }

      if it.placement != none {
        place(
          it.placement,
          float: true,
          clearance: merged-style.float_clearance,
        )[
          #align(
            merged-style.float_align,
            block(width: merged-style.float_width, rendered),
          )
        ]
      } else {
        rendered
      }
    }
  }
}

#let show-bifigure(it, style: (:), kind: "bifigure") = {
  if is-kind(it.kind, kind) {
    _render-bilingual(
      it,
      kind,
      style: style,
      title_on_top: false,
    )
  } else {
    it
  }
}

#let show-bitable(it, style: (:), kind: "bitable") = {
  if is-kind(it.kind, kind) {
    _render-bilingual(
      it,
      kind,
      style: style,
      title_on_top: true,
    )
  } else {
    it
  }
}

#let show-bilingual(
  it,
  figure_style: (:),
  table_style: (:),
  figure_kind: "bifigure",
  table_kind: "bitable",
) = {
  if is-prefixed-kind(it.kind, figure_kind) {
    _render-bilingual(
      it,
      figure_kind,
      style: figure_style,
      title_on_top: false,
    )
  } else if is-prefixed-kind(it.kind, table_kind) {
    _render-bilingual(
      it,
      table_kind,
      style: table_style,
      title_on_top: true,
    )
  } else {
    it
  }
}

#let show-bilingual-outline-entry(
  it,
  lang: "zh",
  separator: h(1em),
  above: 0pt,
  below: 0pt,
  gap: 0pt,
  link_entries: true,
) = {
  let fig = it.element
  let data = extract-bilingual-caption(fig)
  if data == none or data.zh == none {
    it
  } else {
    let use-en = lang == "en" and data.en != none
    let supplement = if use-en { data.supplement_en } else {
      data.supplement_zh
    }
    let title = if use-en { data.en } else { data.zh }
    let number = display-figure-number(fig)
    let row = it.indented(
      none,
      {
        [#supplement #number #separator #title]
        box(width: 1fr, it.fill)
        it.page()
      },
      gap: gap,
    )
    block(above: above, below: below)[
      #if link_entries {
        link(fig.location(), row)
      } else {
        row
      }
    ]
  }
}
