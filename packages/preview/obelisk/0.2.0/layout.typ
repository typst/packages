#import "default.typ": default-settings

#let v-step(size) = context {
  let def = default-settings.get()
  v(size * def.texts.step)
}

// A baseline-aligned block.
#let bblock(it, ..args) = context {
  let def = default-settings.get()
  let step = def.texts.step

  set text(top-edge: "bounds", bottom-edge: "bounds")
  let height = measure({
    set text(top-edge: "bounds", bottom-edge: "bounds")
    it
  }).height
  let desired-height = calc.round(height / step)
  block(v(step * 2 / 3), spacing: 0pt, sticky: true)
  block(
    height: desired-height * step,
    align(horizon, it),
    // stroke: 1pt,
    above: 0pt,
    below: step,
    sticky: true,
    ..args,
  )
  block(v(step / 3), spacing: 0pt, sticky: true)
}

#let place-side(it, dx: 0pt, dy: 0pt, ..args) = context {
  let def = default-settings.get()
  let t-width = def.body.width
  let side-margin = def.side.margin
  let half-gutter = def.side.half-gutter
  let e-margin = def.margin.e
  let text-height = def.texts.ascender

  let page-num = here().page()
  let move = if calc.even(page-num) {
    -e-margin + dx
  } else {
    t-width + half-gutter + dx
  }
  let flush = if calc.even(page-num) {
    right
  } else {
    left
  }
  set par(justify: false)
  let boxed = box(
    width: def.side.width,
    inset: (
      left: half-gutter,
      right: half-gutter,
    ),
    outset: (
      top: half-gutter + text-height,
      bottom: half-gutter,
    ),
    ..args,
    align(flush, it),
  )
  place(dx: move, dy: dy, boxed)
}

#let place-node(sym, dy: 0pt) = context {
  let def = default-settings.get()
  let half-gutter = def.side.half-gutter
  let page-num = here().page()
  let width = measure(sym).width
  let dx = if calc.even(page-num) {
    half-gutter + width / 2
  } else {
    -half-gutter - width / 2
  }
  place-side(sym, dx: dx, dy: dy)
}

#let small(it, scale: 2 / 3, size: 0.75em) = context {
  let def = default-settings.get()
  let step = def.texts.step * scale
  set par(leading: step)
  text(size, it)
}

// automatic stroke side block.
#let init-sblock() = context {
  let def = default-settings.get()
  let width = def.paper.width
  let height = def.paper.height
  let e-margin = def.margin.e
  let t-margin = def.margin.t
  let f-margin = def.margin.f
  let step = def.texts.step
  let ascender = def.texts.ascender

  let page-num = counter(page).get().first()
  let is-odd = calc.odd(page-num)

  // Get the total number of sblocks in the document
  let total-blocks = counter("__obelisk_sblock-id")
    .final()
    .first()

  for id in range(1, total-blocks + 1) {
    let start-elements = query(label(
      "__obelisk_sblock_start-" + str(id),
    ))
    let end-elements = query(label(
      "__obelisk_sblock_end-" + str(id),
    ))

    if start-elements.len() > 0 and end-elements.len() > 0 {
      let start-el = start-elements.first()
      let start-pos = start-el.location().position()
      let end-pos = end-elements
        .first()
        .location()
        .position()

      // If the block exists on the current page...
      if (
        start-pos.page <= page-num
          and end-pos.page >= page-num
      ) {
        // Extract the unique custom style dictionary from the metadata
        let config = start-el.value
        let stroke-style = config.at(
          "stroke",
          default: 1pt + black,
        )
        let offset = config.at("offset", default: 0.2cm)
        let outset = config.at("outset", default: (
          left: 0pt,
          right: 0pt,
          top: 0pt,
          bottom: 0pt,
        ))

        let x-pos = if is-odd {
          width - e-margin + offset
        } else {
          e-margin - offset
        }
        let y-start = (
          if start-pos.page == page-num {
            start-pos.y
          } else {
            t-margin + step
          }
            - outset.top
        )
        let y-end = (
          if end-pos.page == page-num {
            end-pos.y
          } else {
            height - f-margin
          }
            + outset.bottom
        )

        // Render the custom "stroke"
        place(
          top + left,
          dx: x-pos,
          dy: y-start,
          line(
            start: (0pt, 0pt),
            end: (0pt, y-end - y-start),
            stroke: stroke-style,
          ),
        )
      }
    }
  }
}

#let sblock(
  stroke: 1.5pt + black,
  offset: 0.2cm,
  body,
  outset: (
    left: 0pt,
    right: 0pt,
    top: 0pt,
    bottom: 0pt,
  ),
  height: none,
  ..args,
) = {
  counter("__obelisk_sblock-id").step()

  context {
    let id = counter("__obelisk_sblock-id").get().first()

    block(
      width: 100%,
      breakable: true,
      [
        #metadata((
          stroke: stroke,
          offset: offset,
          outset: outset,
        ))
        #label("__obelisk_sblock_start-" + str(id))
        #if height == none {
          block(
            body,
            breakable: true,
          )
        } else {
          block(
            body,
            height: height,
            breakable: true,
          )
        }
        #metadata(none)
        #label("__obelisk_sblock_end-" + str(id))
      ],
      outset: outset,
    )
  }
}

#let theorem-render(
  env,
  name,
  numstr,
  it,
  color: rgb("#A63A2B"),
) = context {
  let def = default-settings.get()
  let margin-w = def.side.width
  let sans-font = def.fonts.sans
  let step = def.texts.step
  let ascender = def.texts.ascender
  let t-width = def.body.width
  let half-gutter = def.side.half-gutter

  let page-num = here().page()
  let side = block(
    width: def.side.width,
    text(
      fill: color,
      font: sans-font,
      [*#env #numstr*\ #if name != none { name }],
    ),
  )
  let s-height = measure(side).height
  let bottom-out = step - ascender
  let body-stroke = color + 3pt
  let body = block(
    [#place-side(side) #it],
    width: t-width,
    breakable: true,
  )
  let b-height = measure(body).height
  sblock(
    body,
    height: if s-height > b-height {
      s-height
    } else {
      none
    },
    stroke: body-stroke,
    offset: half-gutter,
    outset: (
      left: half-gutter,
      right: half-gutter,
      top: ascender + bottom-out,
      bottom: bottom-out,
    ),
  )
}

#let sidenote(it, dy: 0pt) = context {
  let def = default-settings.get()
  let page-num = here().page()
  let posx = here().position().x
  sym.wj
  let dx = if calc.even(page-num) {
    -posx + def.margin.e
  } else {
    -posx + def.margin.s
  }
  box(place-side(small(it), dx: dx, dy: dy))
  h(0pt, weak: true)
}

#let blank-page(..args) = context {
  let mono-font = default-settings.get().fonts.mono
  set page(
    background: {
      v(2fr)
      align(center, text(
        font: mono-font,
        fill: luma(150),
      )[\/\/ This page is intentionally left blank.])
      v(3fr)
    },
    footer: none,
    header: none,
  )
  pagebreak(..args)
}
