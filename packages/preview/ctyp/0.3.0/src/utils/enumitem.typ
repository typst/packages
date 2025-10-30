#import "@preview/elembic:1.1.1" as e: field, element, types

#let mod(x, y) = {
  if x < y {
    x
  } else {
    int(calc.round(calc.fract(x / y) * y))
  }
}

#let is-elem-item(elem) = elem.func() == enum.item or elem.func() == list.item

#let default-block-args = (
  above: 1em,
  below: 1em,
  inset: (left: 0em)
)

#let ItemLabel = element.declare(
  "ItemLabel",
  prefix: "@preview/ctyp,v0.3.0",
  fields: (
    field("symbol", content, required: true),
    field("width", length, default: 1em),
    field("sep", length, default: 0em),
    field("alignment", alignment, default: left),
    field("stroke", types.option(stroke), default: none)
  ),
  display: it => box(
    width: it.width,
    inset: (right: it.sep),
    stroke: it.stroke,
    align(it.alignment, it.symbol)
  ),
)

#let EnumLabel = element.declare(
  "EnumLabel",
  prefix: "@preview/ctyp,v0.3.0",
  fields: (
    field("numbering", str, required: true),
    field("width", length, default: 1em),
    field("sep", length, default: 0em),
    field("alignment", alignment, default: left),
    field("stroke", types.option(stroke), default: none),
    field("body", content)
  ),
  display: it => box(
    width: it.width,
    inset: (right: it.sep),
    stroke: it.stroke,
    align(it.alignment, it.body)
  ),
)

#let convert-content-to-marker(it) = {
  let casted = e.types.cast(it, ItemLabel)
  if casted.first() {
    it
  } else {
    ItemLabel(it, width: 0.5em, sep: 0em, alignment: right)
  }
}

#let convert-str-to-numberer(it) = {
  if type(it) == str {
    EnumLabel(it, width: 1.5em, sep: 0em, alignment: right)
  } else {
    it
  }
}

#let default-list-markers = (sym.circle.filled, sym.triangle.r.filled, sym.square.filled).map(it => text(it, baseline: -.1em)).map(convert-content-to-marker)

#let default-enum-numberers = ("1)", "a)", "i.").map(convert-str-to-numberer)

/// 自定义列表和枚举布局，修复符号和文字不对齐的问题。
#let enumitem(
  /// 符号列表可选用的符号。将循环使用。
  /// -> array
  marker: default-list-markers,
  /// 编号列表可选用的编号格式。将循环使用。
  /// -> array
  numberer: default-enum-numberers,
  /// 是否使用紧凑布局。
  /// 紧凑布局会使用 `par.leading` 作为列表项目之间的间隔，
  /// 否则使用 `par.spacing`。
  /// -> bool
  tight: true,
  /// 列表整体缩进。表现为左侧的边距。
  /// -> length
  indent: 0em,
  /// 列表内容缩进。
  /// -> length
  body-indent: 0.5em,
  /// 列表项目之间的间隔。
  /// -> auto | length
  spacing: auto,
  /// 列表符号/编号与内容之间的间隔。
  /// -> length
  label-sep: 0em,
  /// 符号的宽度。
  /// -> length
  marker-width: 0.5em,
  /// 编号的宽度。
  /// -> length
  number-width: 1.5em,
  /// 是否开启调试模式。
  /// 调试模式会在列表项目的边框上显示红色和绿色的边框，
  /// 以便于调试列表布局。
  /// -> bool
  debug: false,
  /// 捕获所有其他传递到 `block` 函数的参数。
  /// -> arguments
  ..block-args,
  /// 列表的子元素。
  /// -> array
  children
) = context {
  let block-args = (:..default-block-args, ..block-args.named())
  let marker = marker.map(convert-content-to-marker)
  let numberer = numberer.map(convert-str-to-numberer)
  show: block.with(..block-args)
  let spacing = if spacing == auto {
    if tight {
      par.leading
    } else {
      par.spacing
    }
  }
  let item-template(
    label,
    body: []
  ) = {
    let label-width = e.fields(label).width
    block(
      inset: (left: indent + label-width + body-indent),
      stroke: if (debug) { green + 1pt } else { none },
      above: spacing,
      below: spacing,
      {
        set par(first-line-indent: (amount: 0em, all: true), hanging-indent: 0em)
        box(
          width: 0em,
          move(label, dx: - label-width - body-indent)
        ) + body
      }
    )
  }
  let queue = ((
    marker: none,
    body: []
  ),)
  let cur = (0,)
  let cur-max = (children.len(),)
  let cur-number = ()
  let cur-type = ()
  let cur-marker = 0
  let cur-numberer = 0
  let depth = 0
  let elem = children
  let elem-last = none
  while cur.at(0) < cur-max.at(0) {
    if cur.at(depth) >= cur-max.at(depth) {
      let qe = queue.pop()
      queue.last().body += item-template(qe.label, body: qe.body)
      let _ = cur.pop()
      let _ = cur-max.pop()
      if cur-type.len() > 0 {
        let _ = cur-type.pop()
      }
      depth -= 1
      cur.last() += 1
      continue
    }
    // Deep-first search current element
    let c = 0
    elem = children
    while c <= depth {
      elem = if type(elem) == array {
        elem.at(cur.at(c))
      } else if elem.func() == list.item {
        elem.body.children.at(cur.at(c))
      } else if elem.func() == enum.item {
        elem.body.children.at(cur.at(c))
      } else {
        elem
      }
      c += 1
    }
    if elem.func() == list.item {
      if cur-number.len() <= depth {
        cur-number.push(none)
      }
      // Find marker
      if cur-type.len() == 0 {
        cur-type.push("list")
      } 
      if depth == 0 {
        cur-marker = 0
      } else if cur-type.len() <= depth {
        cur-type.push("list")
        if cur-type.at(depth - 1) == "enum" {
          cur-marker = 0
        } else {
          cur-marker = mod(cur-marker + 1, marker.len())
        }
      }
      let label = marker.at(cur-marker)
      if "children" in elem.body.fields() and elem.body.children.any(is-elem-item) {
        queue.push((
          label: label,
          body: []
        ))
        depth += 1
        cur.push(0)
        cur-max.push(elem.body.children.len())
      } else {
        queue.push((
          label: label,
          body: elem.body
        ))
        cur.at(depth) += 1
        let qe = queue.pop()
        queue.last().body += item-template(qe.label, body: qe.body)
      }
    } else if elem.func() == enum.item {
      if cur-type.len() == 0 {
        cur-type.push("enum")
      }
      if depth == 0 {
        cur-numberer = 0
      } else if cur-type.len() <= depth {
        cur-type.push("enum")
        if cur-type.at(depth - 1) == "list" {
          cur-numberer = 0
        } else {
          cur-numberer = mod(cur-numberer + 1, numberer.len())
        }
      }
      if cur-number.len() <= depth {
        cur-number.push(1)
      } else if cur-number.at(depth) == none {
        cur-number.at(depth) = 1
      }
      let number = cur-number.at(depth)
      cur-number.at(depth) += 1
      let cur-numberer-fields = e.fields(numberer.at(cur-numberer))
      let cur-numberer-template = cur-numberer-fields.remove("numbering")
      let label-number = numbering(cur-numberer-template, number)
      let label = EnumLabel(cur-numberer-template, ..cur-numberer-fields, body: label-number)
      if "children" in elem.body.fields() and elem.body.children.any(is-elem-item) {
        queue.push((
          label: label,
          body: []
        ))
        depth += 1
        cur.push(0)
        cur-max.push(elem.body.children.len())
      } else {
        queue.push((
          label: label,
          body: elem.body
        ))
        cur.at(depth) += 1
        let qe = queue.pop()
        queue.last().body += item-template(qe.label, body: qe.body)
      }
    } else {
      queue.last().body += elem
      cur.at(depth) += 1
    }
    elem-last = elem
  }
  queue.pop().body
}