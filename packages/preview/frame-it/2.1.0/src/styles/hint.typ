#import "../styling/export.typ": (
  assert-arg-type, css, direction-info, frame-structure, target-choose,
  wants-html,
)

#let body-inset = 0.8em
#let stroke-width = 0.13em
#let bar-width = 3.5pt

#let header-line(title, tags, body, supplement, number) = context {
  let (shows-header, has-title-text, has-tags, has-body, ..) = frame-structure(
    title,
    tags,
    body,
  )
  let (is-ltr, ..) = direction-info()
  if shows-header {
    let title-str = if has-title-text { [~~#title~] }
    let tag-str = if has-tags { [~(#tags.join(", "))~] }
    let supplement-str = text(text.fill.mix((
      text.fill.negate(),
      20%,
    )))[#supplement #number]
    let separator = if has-body [:]

    if is-ltr or wants-html() {
      [~#supplement-str~*#(title-str)*_#(tag-str)_#separator~]
    } else {
      // Typst does not reorder Latin runs inside RTL text, so lay out the pieces explicitly.
      // HTML export drops `box`/`stack`, so it keeps the logical order (the browser handles bidi).
      let pieces = (
        supplement-str,
        if has-title-text { strong(title-str) },
        if has-tags { emph(tag-str) },
      ).filter(piece => piece != none)
      [~#box(stack(dir: rtl, spacing: 0.5em, ..pieces))~#separator~]
    }
  }
}

#let hint-html(title, tags, body, supplement, number, accent-color) = context {
  let (dir, start-side, ..) = direction-info()
  show divider: _ => html.hr(style: css(
    background: accent-color,
    height: stroke-width,
    border: 0,
    margin: (body-inset, -body-inset),
  ))
  let css-dict = (padding: body-inset, direction: dir)
  css-dict.insert("border-" + start-side, (bar-width, "solid", accent-color))
  html.div(style: css(css-dict), {
    header-line(title, tags, body, supplement, number)
    body
  })
}

#let hint-paged(title, tags, body, supplement, number, accent-color) = context {
  let (is-ltr, start-side, ..) = direction-info()
  let bar = stroke(thickness: bar-width, paint: accent-color, cap: "round")
  let header = header-line(title, tags, body, supplement, number)

  layout(((width,)) => {
    let framed = {
      show divider: _ => {
        v(body-inset - 1em)
        let rule = line(
          length: 100% + body-inset,
          start: (-body-inset, 0pt),
          stroke: accent-color + stroke-width,
        )
        // RTL lines are anchored at their end, so shift them to overshoot the border side like LTR
        if is-ltr { rule } else { move(dx: body-inset, rule) }
        v(body-inset - 1em)
      }

      block(
        width: width,
        stroke: ((start-side): bar),
        inset: ((start-side): 0.7em, y: 0.7em),
        align(start, header + body),
      )
    }

    // Lines at both ends of the border give it rounded ends. A single line would be missing
    // when the hint breaks across pages, see: https://github.com/marc-thieme/frame-it/issues/1
    let length = 0.2em // Arbitrary; if too long, could extend into page margins
    place(line(stroke: bar, angle: 90deg, length: length))
    framed
    place(line(stroke: bar, angle: 90deg, length: -length))
  })
}

#let hint(title, tags, body, supplement, number, accent-color) = {
  assert-arg-type(accent-color, color, supplement)
  target-choose(
    html: () => hint-html(title, tags, body, supplement, number, accent-color),
    paged: () => hint-paged(
      title,
      tags,
      body,
      supplement,
      number,
      accent-color,
    ),
  )
}
