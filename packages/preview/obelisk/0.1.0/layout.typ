#import "default.typ": default-settings

// A baseline-aligned block.
#let bblock(it, ..args) = context {
  let def = default-settings.get();
  let step = def.texts.step;

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
  let def = default-settings.get();
  let t-width = def.body.width;
  let side-margin = def.side.margin;
  let half-gutter = def.side.half-gutter;
  let e-margin = def.margin.e;
  let text-height = def.texts.ascender;

  let page-num = counter(page).get().first()
  let move = if calc.even(page-num) {
    -e-margin + dx
  } else {
    t-width - side-margin + half-gutter + dx
  }
  let flush = if calc.even(page-num) {
    right
  } else {
    left
  }
  set par(justify: false)
  let boxed = box(
    width: e-margin - half-gutter,
    inset: (
      left: half-gutter + side-margin,
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
  let page-num = counter(page).get().first()
  let width = measure(sym).width
  let dx = if calc.even(page-num) {
    half-gutter + width / 2
  } else {
    -half-gutter - width / 2
  }
  place-side(sym, dx: dx, dy: dy)
}

#let small(it, scale: 2 / 3, size: 0.75em) = {
  let def = default-settings.get()
  let step = def.texts.step * scale
  set par(leading: step)
  text(size, it)
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
  let text-height = def.texts.ascender
  let t-width = def.body.width
  let half-gutter = def.side.half-gutter

  let page-num = counter(page).get().first()
  let side = block(width: margin-w, text(
    fill: color,
    font: sans-font,
    [*#env #numstr*\ #if name != none { name }],
  ))
  let s-height = measure(side).height
  let bottom-out = step - text-height
  let body-stroke = if calc.even(page-num) {
    (
      left: color + 3pt,
    )
  } else {
    (
      right: color + 3pt,
    )
  }
  let body = block(
    [#place-side(side) #it],
    width: t-width,
    breakable: false,
  )
  let b-height = measure(body).height
  block(
    body,
    height: calc.max(b-height, s-height),
    stroke: body-stroke,
    outset: (
      left: half-gutter,
      right: half-gutter,
      top: text-height + bottom-out,
      bottom: bottom-out,
    ),
  )
}

#let sidenote(it, dy: 0pt) = context {
  let def = default-settings.get()
  let page-num = counter(page).get().first()
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

#let blank-page(..args) = {
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
