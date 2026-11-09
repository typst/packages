#import "../styling/export.typ": (
  assert-arg-type, css, direction-info, frame-structure, target-choose,
)

#let bar-width = 3pt
#let body-inset = 1em
#let text-color(accent-color) = (
  accent-color.mix((text.fill.lighten(80%), 100%)).saturate(60%)
)


#let thmbox-html(
  title,
  tags,
  body,
  supplement,
  number,
  accent-color,
) = context {
  let (dir, start-side, ..) = direction-info()
  let (shows-header, has-title-text, has-header-items, ..) = frame-structure(
    title,
    tags,
    body,
  )

  let frame-css = (padding: body-inset, direction: dir)
  frame-css.insert("border-" + start-side, (bar-width, "solid", accent-color))

  // The flex row follows `direction`, so the title starts on the start side
  let header-layout = if has-header-items {
    (
      display: "flex",
      justify-content: "space-between",
      align-items: center,
    )
  } else {
    (:)
  }

  html.div(style: css(frame-css), {
    if shows-header {
      html.div(style: css(..header-layout, color: text-color(accent-color)), {
        if has-title-text {
          html.div(
            style: css(flex: "1.7 1 1", text-align: start),
            strong(title),
          )
        }
        for tag in tags {
          html.div(style: css(flex: "1 1 1", text-align: center), tag)
        }
        html.div(
          style: css(
            flex: "1.7 1 1",
            text-align: if has-header-items { end } else { start },
          ),
          strong(supplement + " " + number),
        )
      })
    }
    show divider: _ => html.hr(style: css(
      background: accent-color,
      height: 0.18em,
      border: 0,
      margin-block: 0,
      margin-inline-start: -body-inset,
    ))
    body
  })
}

// Credits to https://github.com/s15n/typst-thmbox
#let thmbox-paged(
  title,
  tags,
  body,
  supplement,
  number,
  accent-color,
) = context {
  let (is-ltr, start-side, end-side, dir, ..) = direction-info()
  let (
    shows-header,
    has-title-text,
    has-tags,
    has-header-items,
    has-body,
    ..,
  ) = frame-structure(title, tags, body)
  let bar = stroke(paint: accent-color, thickness: bar-width)

  show divider: _ => {
    let rule = line(
      length: 100% + 1em,
      start: (-1em, 0pt),
      stroke: accent-color + bar-width * 0.8,
    )
    // RTL lines are anchored at their end, so shift them to overshoot the border side like LTR
    if is-ltr { rule } else { move(dx: 1em, rule) }
    v(-0.2em)
  }

  // Typst does not reorder Latin runs inside RTL text, so the title bar is built as an explicit row
  let title-bar() = {
    let items = ()
    if has-title-text { items.push(title) }
    if has-header-items { items.push(h(3fr)) }
    if has-tags {
      for tag in tags {
        items.push(text(tag, weight: "regular"))
        items.push(h(1fr))
      }
      items.push(h(2fr))
    }
    items.push(supplement + " " + number)
    if is-ltr { items.join() } else { stack(dir: dir, ..items) }
  }

  block(
    stroke: ((start-side): bar),
    inset: ((start-side): 1em, top: 0.6em, bottom: 0.6em),
    spacing: 1.2em,
  )[
    #set align(start)
    #if shows-header {
      block(above: 0em, below: 1.2em, {
        set text(text-color(accent-color), weight: "bold")
        title-bar()
      })
    }
    #if has-body {
      block(inset: ((end-side): 1em), spacing: 0em, width: 100%, body)
    }
  ]
}

#let thmbox(title, tags, body, supplement, number, accent-color) = {
  assert-arg-type(accent-color, color, supplement)
  target-choose(
    html: () => thmbox-html(
      title,
      tags,
      body,
      supplement,
      number,
      accent-color,
    ),
    paged: () => thmbox-paged(
      title,
      tags,
      body,
      supplement,
      number,
      accent-color,
    ),
  )
}
