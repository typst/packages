#import "../styling.typ" as styling
#import "../utils/html.typ": css, span, div

#let body-inset = 0.8em
#let stroke-width = 0.13em
#let corner-radius = 5pt

#let boxy-html(title, tags, body, supplement, number, accent-color) = {
  let has-body = body != []
  let has-title = title not in ([], "", none)
  let has-headers = int(has-title) + tags.len() > 0
  let body-only = title == none
  let header-contents = tags
  if has-title {
    header-contents.insert(0, title)
  }

  let header-styles = (
    padding: "5px 10px",
    border: (stroke-width, "solid", accent-color),
    margin-left: "-2px",
  )
  if has-body {
    header-styles.border-bottom = none
  }
  let first-header-elem-css-overlay = {
    (
      margin-left: 0,
      border-top-left-radius: corner-radius,
    )
    if not has-body {
      (border-bottom-left-radius: corner-radius)
    }
  }
  let last-header-elem-css-overlay = {
    (
      border-top-right-radius: corner-radius,
    )
    if not has-body {
      (border-bottom-right-radius: corner-radius)
    }
  }
  let html-suppl = span(
    css(
      ..header-styles,
      border-color: "transparent",
      margin-left: if has-headers { auto } else { 0 },
      mragin-right: body-inset,
    ),
    supplement + " " + number,
  )
  let headers-html() = {
    let header-contents = if has-title {
      (title, ..tags)
    } else {
      tags
    }
    let header-css = (header-styles,) * header-contents.len()
    header-css.first() += first-header-elem-css-overlay
    header-css.last() += last-header-elem-css-overlay

    if has-title {
      header-css.first() += (background-color: accent-color)
    }
    for (content, css-dict) in header-contents.zip(header-css) {
      span(css(..css-dict), content)
    }
  }
  if not body-only {
    div(
      css(display: "flex", align-items: center),
      {
        if has-headers {
          headers-html()
        }
        html-suppl
      },
    )
  }
  if has-body {
    show: styling.dividers-as({
      let css-dict = (
        border: 0,
        height: stroke-width,
        background: accent-color,
        margin: (0, -body-inset),
      )
      html.elem("hr", attrs: (style: css(css-dict)))
    })
    let css-dict = (
      border: (stroke-width, "solid", accent-color),
      border-radius: (0, corner-radius, corner-radius, corner-radius),
      padding: body-inset,
    )
    if not has-headers {
      css-dict.border-top-left-radius = corner-radius
    }
    div(
      css(css-dict),
      body,
    )
  }
}

#let boxy-paged(title, tags, body, supplement, number, accent-color) = {
  assert(
    type(accent-color) == color,
    message: "Please provide a color as argument for the frame instance"
      + supplement,
  )

  let stroke = accent-color + stroke-width

  let round-bottom-corners-of-tags = body == []
  let display-title = title not in ([], "")
  let round-top-left-body-corner = title in ([], none) and tags == ()

  let header() = align(
    left,
    {
      let inset = 0.5em

      let tag-elements = tags
      if display-title {
        let title-cell = grid.cell(fill: accent-color, title)
        tag-elements.insert(0, title-cell)
      }

      let rounded-corners = (top: corner-radius)
      if round-bottom-corners-of-tags {
        rounded-corners.bottom = corner-radius
      }

      let rendered-tags = if tag-elements == () [] else {
        let grid-cells = tag-elements.intersperse(grid.vline(stroke: stroke))
        let tag-grid = grid(columns: tag-elements.len(), align: horizon, inset: inset, ..grid-cells)
        box(clip: true, stroke: stroke, radius: rounded-corners, tag-grid)
        h(1fr)
      }

      let supplement-str = box(inset: inset)[#supplement #number]

      layout(((width: available-width)) => {
        if measure(rendered-tags + supplement-str).width < available-width {
          rendered-tags
          supplement-str
        } else [
          #supplement #number \
          #rendered-tags
        ]
      })
    },
  )

  let board() = {
    let round-corners = (bottom: corner-radius, top-right: corner-radius)
    if round-top-left-body-corner {
      round-corners.top-left = corner-radius
    }
    align(
      left,
      block(
        width: 100%,
        inset: body-inset,
        radius: round-corners,
        stroke: stroke,
        spacing: 0em,
        outset: (y: 0em),
        {
          // Divide constructs a line where we need to inject the stroke style because we only have access to the color here
          show: styling.dividers-as({
            v(body-inset - 1em)
            line(length: 100% + 2 * body-inset, stroke: stroke)
            v(body-inset - 1em)
          })
          body
        },
      ),
    )
  }

  let parts = ()

  let rounded-corners = (bottom: corner-radius)

  if title != none {
    parts.push(header())
  }

  if body != [] {
    parts.push(board())
  }

  stack(..parts)
}

#let boxy(title, tags, body, supplement, number, accent-color) = context (
  if target() == "html" {
    boxy-html
  } else {
    boxy-paged
  }
)(title, tags, body, supplement, number, accent-color)
