// Copyright (C) 2023  Andrew Voynov
// AGPL-3.0-only license is in the LICENSE file in the root of the project
// or at https://www.gnu.org/licenses/agpl-3.0.txt

#let _ruby(rt, rb, size, pos, dy, alignment, delimiter, auto-spacing) = {
  if not ("center", "start", "between", "around").contains(alignment) {
    panic("'" + repr(alignment) + "' is not a valid ruby alignment")
  }

  if not (top, bottom).contains(pos) {
    panic("pos can be either top or bottom but '" + repr(pos) + "'")
  }

  let extract-content(content, fn: it => it) = {
    let func = content.func()
    return if func == text or func == raw {
      (content.text, fn)
    } else {
      extract-content(content.body, fn: it => func(fn(it)))
    }
  }

  let add-spacing-if-enabled(text) = {
    if auto-spacing != true { return text }
    return (
      if text.first() != delimiter { delimiter }
      + text
      + if text.last() != delimiter { delimiter }
    )
  }

  let rt-array = if type(rt) == content {
    let (inner, func) = extract-content(rt)
    add-spacing-if-enabled(inner).split(delimiter).map(func)
  } else if type(rt) == str {
    add-spacing-if-enabled(rt).split(delimiter)
  } else {(rt,)}
  assert(type(rt-array) == array)

  let rb-array = if type(rb) == content {
    let (inner, func) = extract-content(rb)
    add-spacing-if-enabled(inner).split(delimiter).map(func)
  } else if type(rb) == str {
    add-spacing-if-enabled(rb).split(delimiter)
  } else {(rb,)}
  assert(type(rb-array) == array)

  if rt-array.len() != rb-array.len() {
    rt-array = (rt,)
    rb-array = (rb,)
  }

  let gutter = if (alignment == "center" or alignment == "start") {
    h(0pt)
  } else if (alignment == "between" or alignment == "around") {
    h(1fr)
  }

  box(layout(((width, height)) => {
    let sum-body = []
    let sum-width = 0pt
    let i = 0
    while i < rb-array.len() {
      let (body, ruby) = (rb-array.at(i), rt-array.at(i))
      let bodysize = measure(body, width: width, height: height)
      let rt-plain-width = measure(
        text(size: size, ruby),
        width: width,
        height: height,
      ).width
      let width = if rt-plain-width > bodysize.width {
        rt-plain-width
      } else {
        bodysize.width
      }
      let chars = if(alignment == "around") {
          h(0.5fr) + ruby.clusters().join(gutter) + h(0.5fr)
      } else {
          ruby.clusters().join(gutter)
      }
      let rubytext = box(
        width: width,
        align(
          if (alignment == "start") { left } else { center },
          text(size: size, chars)
        )
      )
      let textsize = measure(rubytext, width: width, height: height)
      let dx = textsize.width - bodysize.width
      let (t-dx, l-dx, r-dx) = if (alignment == "start") {
        (0pt, 0pt, dx)
      } else {
        (-dx/2, dx/2, dx/2)
      }
      let (l, r) = (i != 0,  i != rb-array.len() - 1)
      sum-width += if l { 0pt } else { t-dx }
      let dy = if pos == top {
        -1.5 * textsize.height - dy
      } else {
        bodysize.height + textsize.height/2 + dy
      }
      place(
        top + left,
        dx: sum-width,
        dy: dy,
        rubytext
      )
      sum-width += width
      sum-body += if l { h(l-dx) } + body + if r { h(r-dx) }
      i += 1
    }
    sum-body
  }))
}

#let get-ruby(
  size: 0.5em,
  dy: 0pt,
  pos: top,
  alignment: "center",
  delimiter: "|",
  auto-spacing: true
) = (rt, rb, alignment: alignment) => (
  _ruby(rt, rb, size, pos, dy, alignment, delimiter, auto-spacing)
)
