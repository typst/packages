#import "../styling.typ" as styling
#import "../utils/html.typ": css, span, div

#let body-inset = 0.8em
#let stroke-width = 0.13em
#let line-width = 3.5pt

#let header-suppl(title, tags, body, supplement, number) = {
  if title == none {
    none
  } else {
    if title != [] {
      title = [~~#title~]
    }

    let tag-str = if tags != () {
      [~(#tags.join(", "))~]
    } else {
      []
    }
    let supplement-str = context {
      let header-color = text.fill.mix((text.fill.negate(), 20%))
      text(header-color)[#supplement #number]
    }
    let head-body-separator = if body == [] [] else [:]
    [~#supplement-str~*#(title)*_#(tag-str)_#head-body-separator~]
  }
}

#let hint-html(title, tags, body, supplement, number, accent-color) = {
  let has-body = body != []
  let has-title = title not in ([], "", none)
  let has-headers = int(has-title) + tags.len() > 0
  let body-only = title == none
  show: styling.dividers-as(
    html.elem(
      "hr",
      attrs: (
        style: css(
          background: accent-color,
          height: stroke-width,
          border: 0,
          margin: (body-inset, -body-inset),
        ),
      ),
    ),
  )
  div(
    css(
      border-left: (line-width, "solid", accent-color),
      padding: body-inset,
    ),
    {
      header-suppl(title, tags, body, supplement, number)
      body
    },
  )
}

#let hint-paged(title, tags, body, supplement, number, accent-color) = {
  let stroke = stroke(
    thickness: line-width,
    paint: accent-color,
    cap: "round",
  )

  let header = header-suppl(title, tags, body, supplement, number)
  layout(((width,)) => {
    let text = {
      show: styling.dividers-as({
        v(body-inset - 1em)
        line(
          length: 100% + body-inset,
          start: (-body-inset, 0pt),
          stroke: accent-color + stroke-width,
        )
        v(body-inset - 1em)
      })

      block(
        width: width,
        stroke: (left: stroke),
        inset: (left: 0.7em, y: 0.7em),
        align(left, header + body),
      )
    }

    // At both ends of the line drawn by the border, we overlay lines which
    // extend them by rounded ends. This looks better.
    let length = 0.2em // Arbitrary; if too long, could extend into page margins
    place(line(stroke: stroke, angle: 90deg, length: length))
    text
    place(line(stroke: stroke, angle: 90deg, length: -length))
    // We prefer this setup to only using the block border because we want the
    // rounded edges. We prefer it to one contiguous line because then the
    // line would be missing if the hint breaks across two or more pages.
    // See: https://github.com/marc-thieme/frame-it/issues/1
  })
}

#let hint(title, tags, body, supplement, number, accent-color) = context (
  if target() == "html" {
    hint-html
  } else {
    hint-paged
  }
)(title, tags, body, supplement, number, accent-color)

