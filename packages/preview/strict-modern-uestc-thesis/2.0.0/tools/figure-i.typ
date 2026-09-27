#import "../consts.typ": *
#import "../utils/word_spacing.typ": above-leading-space, below-leading-space, 单倍行距
#let figure-kind-code = "figure-kind-code"
#let figure-kind-pic = "figure-kind-pic"
#let figure-kind-tbl = "figure-kind-tbl"
#let figure-kind-algo = "figure-kind-algorithm"
#import "@preview/algorithmic:1.0.7": algorithm, iflike
#import "@preview/algorithmic:1.0.7"

#let figure-numering(_, kind: "figure", element: none, only-sub: false, step: false) = {
  let loc = if element != none { element.location() } else { here() }
  let chapter-num = str(counter(heading.where(level: 1)).at(loc).first())
  if str(kind).starts-with("sub-") {
    let num = figure-numering((), kind: str(kind).replace("sub-", ""), element: element)
    let counter-name = "sub-" + kind + "-" + str(num)
    if step {
      counter(counter-name).step()
    } else {
      let sub-num = counter(counter-name).at(loc).first() + 1
      if not only-sub {
        num + " " + numbering("(a)", sub-num)
      } else {
        numbering("(a)", sub-num)
      }
    }
  } else {
    if step {
      counter(kind + chapter-num).step()
    } else {
      let type-num = counter(kind + chapter-num).at(loc).first() + 1
      numbering("1", counter(heading.where(level: 1)).at(loc).first()) + "-" + str(int(type-num))
    }
  }
}

#let count-step(kind) = {
  figure-numering((), kind: kind, step: true)
}

#let get-counter-name(kind: "figure", element: none) = {
  let num = figure-numering((), kind: kind, element: element)
  let loc = if element != none { element.location() } else { here() }
  let counter-name = "sub-" + kind + "-" + str(num)
  let sub-num = counter(counter-name).at(loc).first() + 1
  (sub-num, num, counter-name)
}

#let subfigure-numering(_, kind: "figure", element: none) = {
  let num = get-counter-name(kind: kind, element: element).first()
  numbering("(a)", num)
}

#let pic-numering = figure-numering.with(kind: figure-kind-pic, element: none)
#let tbl-numering = figure-numering.with(kind: figure-kind-tbl, element: none)
#let code-numering = figure-numering.with(kind: figure-kind-code, element: none)
#let algo-numering = figure-numering.with(kind: figure-kind-algo, element: none)

#let figure-env-set(body) = {
  // subfigure
  show grid: it => {
    show figure: fig => {
      if str(fig.kind).starts-with("sub-") {
        fig
      } else {
        let new-kind = "sub-" + str(fig.kind)
        let fields = fig.fields()
        let body = fields.remove("body")
        let counter = fields.remove("counter")
        let kind = fields.remove("kind")
        let label = fields.remove("label", default: none)
        let bottom = 0pt
        if fields.at("caption", default: none) != none {
          bottom = 6pt
        }
        let meta = context {
          metadata((
            figure-location: fig.location(),
            body-location: here(),
            kind: new-kind,
          ))
        }
        block(inset: (bottom: bottom))[
          #figure(
            meta + fig.body,
            caption: fig.caption,
            kind: new-kind,
            supplement: fig.supplement,
            numbering: figure-numering.with(kind: new-kind, only-sub: true),
            placement: none,
            outlined: false,
            gap: fig.gap / 2,
          )
        ]
        if fig.caption != none {
          count-step(new-kind)
        }
      }
    }
    // 渲染 grid 本身
    it
  }
  set block(breakable: true)

  show figure.where(kind: figure-kind-tbl): set figure.caption(position: top)
  show figure.caption: set text(size: font-size.五号)
  show figure: set figure(gap: 6pt)
  let figure-body(it) = {
    set par(leading: above-leading-space())
    it
  }
  show figure.where(kind: figure-kind-pic): set block(
    above: above-leading-space(space: 6pt, word-space: 单倍行距),
    below: below-leading-space(12pt),
  )
  show figure.where(kind: figure-kind-tbl): set block(
    above: above-leading-space(space: 12pt, word-space: 单倍行距),
    below: below-leading-space(6pt),
  )

  show figure.caption: it => {
    let indent-width = measure(h(4em)).width
    if str(it.kind).starts-with("sub-") {
      indent-width = measure(h(1.5em)).width
    }
    layout(bounds => {
      let full-caption = if it.numbering != none {
        if it.body != [] {
          [#it.supplement#it.counter.display(it.numbering)#h(0.5em)#it.body]
        } else {
          [#it.supplement#it.counter.display(it.numbering)]
        }
      } else {
        it.body
      }
      let size = measure(full-caption)
      if it.kind != figure-kind-algo {
        if size.width > bounds.width - indent-width * 2 {
          set par(justify: true, leading: above-leading-space())
          box(
            width: 100%,
            inset: (x: indent-width), // 左右缩进
            align(left, full-caption), // 两端对齐基于左对齐基础
          )
        } else {
          set par(leading: above-leading-space())
          set align(center)
          full-caption
        }
      } else {
        align(left)[
          #h(2em)
          #full-caption
        ]
      }
    })
  }

  show figure: it => {
    // 修复float布局figure页面不正确的问题：https://github.com/typst/typst/issues/4359

    if it.outlined == true {
      return it
    }

    if str(it.kind).starts-with("sub-") {
      return it
    }

    let new-fig = none
    let content = {
      let fields = it.fields()
      let body = fields.remove("body")
      let _label = none
      if fields.keys().contains("label") {
        _label = fields.remove("label")
      } else {
        _label = figure-numering((), element: it, kind: it.kind)
      }
      let counter = fields.remove("counter")

      let meta = context {
        metadata((
          figure-location: it.location(),
          body-location: here(),
          label: _label,
          kind: it.kind,
        ))

        let info = query(<info>).first().value
        let bottom_figure = info.at(info-keys.浮动表图标题页置底)

        let page = here().page()
        let h1-on-page = query(heading.where(level: 1)).any(h => h.location().page() == page)
        let should-force-bottom = false
        let next-state = should-force-bottom
        if h1-on-page and bottom_figure {
          next-state = true
        }
        let marker-lbl = label("marker-" + str(_label))
        [#metadata(next-state) #marker-lbl]
      }
      // text(num) // Force counter evaluation.
      if it.kind != figure-kind-algo {
        meta
        figure(body, ..fields, placement: none, outlined: true)
      } else {
        set block(breakable: false, below: below-leading-space(6pt), above: above-leading-space(space: 6pt))
        let hlines = (grid.hline(stroke: 1.5pt), grid.hline(stroke: 0.75pt), grid.hline(stroke: 1.5pt))
        let caption-align = start
        let _ = fields.remove("caption")
        let algo = figure(
          meta
            + grid(
              columns: 1,
              stroke: none,
              gutter: 0pt,
              inset: 0pt,
              hlines.at(0),
              pad(y: (0.7cm - 1em) / 2, align(caption-align, it.caption)),
              hlines.at(1),
              align(start, it.body),
              hlines.at(2),
            ),
          ..fields,
          placement: none,
          outlined: true,
        )
        algo
      }
      count-step(it.kind)
    }

    if it.placement == none { return content }

    let fields = it.fields()
    let _label = fields.at("label", default: none)
    if _label == none {
      _label = figure-numering((), element: it, kind: it.kind)
    }
    let should-force-bottom = false
    if _label != none {
      let key-lbl = _label
      let marker-lbl = label("marker-" + str(_label))
      let history = query(marker-lbl)
      if history.len() > 0 {
        should-force-bottom = history.last().value
      }
    }
    let placement = if should-force-bottom { bottom } else { it.placement }

    // clearance目前不支持上下控制。这个实现不能捕捉auto，两张图放在一起的情况也不能完美处理。
    let clearance = below-leading-space(12pt)
    if it.kind == figure-kind-pic {
      if placement == bottom {
        clearance = above-leading-space(space: 6pt, word-space: 单倍行距)
      }
    }
    if it.kind == figure-kind-tbl {
      if placement == bottom {
        clearance = above-leading-space(space: 12pt, word-space: 单倍行距)
      }
      if placement == top {
        clearance = below-leading-space(6pt)
      }
    }
    if it.kind == figure-kind-algo {
      if placement == bottom {
        clearance = above-leading-space(space: 6pt)
      } else {
        clearance = below-leading-space(6pt)
      }
    }

    place(placement, float: true, clearance: clearance, scope: it.scope, block(width: 100%, content))
  }
  body
}

// #let set-placement

#let table-figure(caption, table, placement: none) = {
  figure(
    [
      #set text(size: font-size.五号)
      #table],
    caption: caption,
    supplement: [表],
    numbering: tbl-numering,
    kind: figure-kind-tbl,
    placement: placement,
    outlined: false,
  )
}

#let code-figure(caption, code, placement: none) = {
  figure(
    code,
    caption: caption,
    supplement: [代码],
    numbering: code-numering,
    kind: figure-kind-code,
    placement: placement,
    outlined: false,
  )
}

#let picture-figure(caption, picture, placement: none) = {
  figure(
    picture,
    caption: caption,
    supplement: [图],
    kind: figure-kind-pic,
    numbering: pic-numering,
    placement: placement,
    outlined: false,
  )
}

#let algorithm-figure(
  caption,
  ..bits,
  placement: none,
  supplement: text(font: "SimHei")[算法],
  inset: 0.2em,
  indent: 0.5em,
  vstroke: 0pt,
  line-numbers: true,
  line-numbers-format: x => {
    set align(right)
    [#x:]
  },
  horizontal-offset: 1.63640em,
) = {
  return figure(
    outlined: false,
    supplement: supplement,
    kind: figure-kind-algo,
    placement: placement,
    caption: strong(caption),
    numbering: algo-numering,
    [
      #set text(size: font-size.五号)
      #algorithm(
        indent: indent,
        inset: (
          bottom: above-leading-space() / 2,
          top: above-leading-space() / 2,
          left: 0.2em,
          right: 0.2em,
        ),
        vstroke: vstroke,
        line-numbers: line-numbers,
        line-numbers-format: line-numbers-format,
        horizontal-offset: horizontal-offset,
        ..bits,
      )],
  )
}

#let table = table.with(
  stroke: none,
  align: horizon + center,
  rows: auto,
  gutter: 0pt,
  inset: (bottom: (0.6cm - 1em) / 2, top: (0.6cm - 1em) / 2),
)

#let toprule = table.hline.with(stroke: 1.5pt)
#let bottomrule = table.hline.with(stroke: 1.5pt)
#let midrule = table.hline.with(stroke: 0.75pt)
