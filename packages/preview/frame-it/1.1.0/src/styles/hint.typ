#import "../styling.typ" as styling

#let body-inset = 0.8em
#let stroke-width = 0.13em

#let hint(title, tags, body, supplement, number, accent-color) = {
  let stroke = stroke(
    thickness: 3.5pt,
    paint: accent-color,
    cap: "round",
  )

  let header = if title == none {
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


