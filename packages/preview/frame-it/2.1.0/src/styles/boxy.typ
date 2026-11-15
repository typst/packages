#import "../styling/export.typ": (
  assert-arg-type, css, direction-info, frame-structure, target-choose,
)

#let body-inset = 0.8em
#let stroke-width = 0.13em
#let corner-radius = 5pt

#let boxy-html(title, tags, body, supplement, number, accent-color) = context {
  let (
    shows-header,
    has-title-text,
    has-body,
    has-header-items,
    header-joins-body,
    header-items,
    ..,
  ) = frame-structure(title, tags, body)
  let (dir, ..) = direction-info()
  let r = corner-radius
  // Logical properties keep the tabs on the start side in right-to-left text
  let tab = (
    padding: "5px 10px",
    border: (stroke-width, "solid", accent-color),
    margin-inline-start: "-2px",
    display: "flex",
    align-items: "center",
  )
  if header-joins-body { tab.border-bottom = none }

  let last = header-items.len() - 1
  let tabs = header-items
    .enumerate()
    .map(((i, content)) => {
      let css-dict = tab
      if i == 0 {
        css-dict += (margin-inline-start: 0, border-start-start-radius: r)
        if not header-joins-body { css-dict.border-end-start-radius = r }
        if has-title-text { css-dict.background-color = accent-color }
      }
      if i == last {
        css-dict.border-start-end-radius = r
        if not header-joins-body { css-dict.border-end-end-radius = r }
      }
      html.span(style: css(..css-dict), content)
    })

  if shows-header {
    html.div(style: css(display: "flex", direction: dir), {
      tabs.join()
      html.span(
        style: css(
          ..tab,
          border-color: "transparent",
          margin-inline-start: if has-header-items { auto } else { 0 },
        ),
        supplement + " " + number,
      )
    })
  }

  if has-body {
    show divider: _ => html.hr(style: css(
      border: 0,
      height: stroke-width,
      background: accent-color,
      margin: (0, -body-inset),
    ))
    html.div(
      style: css(
        border: (stroke-width, "solid", accent-color),
        border-start-start-radius: if has-header-items { 0pt } else { r },
        border-start-end-radius: r,
        border-end-end-radius: r,
        border-end-start-radius: r,
        padding: body-inset,
        direction: dir,
      ),
      body,
    )
  }
}

#let boxy-paged(title, tags, body, supplement, number, accent-color) = context {
  let (start-side, ..) = direction-info()
  let (
    shows-header,
    has-title-text,
    has-body,
    has-header-items,
    header-joins-body,
    ..,
  ) = frame-structure(title, tags, body)
  let stroke = accent-color + stroke-width

  let header() = align(start, {
    let inset = 0.5em
    let tag-elements = tags
    if has-title-text {
      tag-elements.insert(0, grid.cell(fill: accent-color, title))
    }
    let rounded-corners = (top: corner-radius)
    if not header-joins-body { rounded-corners.bottom = corner-radius }

    let rendered-tags = if tag-elements == () { none } else {
      let cells = tag-elements.intersperse(grid.vline(stroke: stroke))
      box(
        clip: true,
        stroke: stroke,
        radius: rounded-corners,
        grid(columns: tag-elements.len(), align: horizon, inset: inset, ..cells),
      )
    }
    // `dir: ltr` keeps "Example 50" in reading order in right-to-left text
    let supplement-str = box(inset: inset, stack(
      dir: ltr,
      supplement,
      [~],
      number,
    ))

    // Tags and supplement share one row, so both are centered vertically
    layout(((width: available-width)) => {
      let fits = (
        rendered-tags == none
          or {
            (
              measure(rendered-tags).width + measure(supplement-str).width
                < available-width
            )
          }
      )
      if not fits {
        [#supplement #number \ #rendered-tags]
      } else if rendered-tags == none {
        supplement-str
      } else {
        grid(
          columns: (auto, 1fr),
          align: (start + horizon, end + horizon),
          rendered-tags, supplement-str,
        )
      }
    })
  })

  let board() = {
    let round-corners = (rest: corner-radius)
    if has-header-items { round-corners.insert("top-" + start-side, 0%) }
    align(start, block(
      width: 100%,
      inset: body-inset,
      radius: round-corners,
      stroke: stroke,
      spacing: 0em,
      outset: (y: 0em),
      {
        // Divider needs the stroke, which only this function knows
        show divider: _ => {
          v(-0.5em + stroke-width)
          line(
            start: (-body-inset, 0em),
            length: 100% + 2 * body-inset,
            stroke: stroke,
          )
          v(-0.5em + stroke-width)
        }
        body
      },
    ))
  }

  stack(
    if shows-header { header() },
    if has-body { board() },
  )
}

#let boxy(title, tags, body, supplement, number, accent-color) = {
  assert-arg-type(accent-color, color, supplement)
  target-choose(
    html: () => boxy-html(title, tags, body, supplement, number, accent-color),
    paged: () => boxy-paged(
      title,
      tags,
      body,
      supplement,
      number,
      accent-color,
    ),
  )
}
