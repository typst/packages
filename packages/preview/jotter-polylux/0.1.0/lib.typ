#import "@preview/polylux:0.4.0": *
#import "@preview/suiji:0.4.0"
#import "@preview/umbra:0.1.1"

#let highlight-color-state = state("jotter-highlight-color", red)

#let setup(
  header: none,
  highlight-color: red,
  binding: true,
  dots: true,
  body,
) = {
  highlight-color-state.update(highlight-color)
  set page(
    paper: "presentation-16-9",
    margin: (left: 3cm, top: 2cm, rest: 1cm),
    fill: if dots {
      tiling(
        spacing: (5mm, 5mm),
        {
          place(square(width: 6mm, stroke: none, fill: white))
          circle(radius: 1pt, fill: white.darken(10%))
        },
      )
    },
    background: if binding {
      set align(top + left)
      let gap = 1.5cm
      let color = rgb("8aa")
      place(rect(height: 100%, width: 5mm, stroke: none, fill: black))
      place(dx: 5mm, rect(height: 100%, width: 5mm, stroke: none, fill: white))
      for offset in range(20) {
        let spiral(t, p) = curve(
          stroke: (thickness: t, paint: p),
          curve.move((.5cm, 1cm)),
          curve.quad((-.5cm, 1.1cm), (1cm, 1.2cm)),
        )
        place(dy: offset * gap, spiral(2pt, color))
        place(
          dy: offset * gap - .2mm,
          dx: -.2mm,
          spiral(.5pt, color.darken(50%)),
        )
        place(
          dx: 1cm - .5mm,
          dy: offset * gap + 1.2cm - 1.5mm,
          circle(radius: 1.5mm, stroke: color + .3mm, fill: color.darken(70%)),
        )
      }
    },
    footer: context {
      set align(right)
      set text(size: .6em, fill: text.fill.transparentize(30%))
      context box(
        curve(
          stroke: (thickness: .05em, cap: "round", paint: text.fill),
          curve.quad((.8em, -.9em), (1em, -2em)),
        ),
      )
      toolbox.slide-number
    },
    header: context if header != none {
      set align(right)
      set text(size: .6em, fill: text.fill.transparentize(30%))
      set par(spacing: .5em)
      header
      context {
        let w = measure(header).width
        curve(
          stroke: (thickness: .05em, cap: "round", paint: text.fill),
          curve.quad((.25 * w, -.3em), (1.2 * w, 0em)),
        )
      }
    },
  )
  show emph: it => underline(
    stroke: stroke(
      thickness: .3em,
      paint: highlight-color.transparentize(50%),
      cap: "round",
    ),
    offset: -.1em,
    extent: .1em,
    evade: false,
    background: true,
    it.body,
  )
  show heading.where(level: 1): it => layout(sz => {
    let w = measure(..sz, it).width
    it
    move(
      dy: -.8em,
      curve(
        stroke: (thickness: .04em, cap: "round", paint: text.fill),
        fill: text.fill,
        curve.quad((.75 * w, -.5em), (w, 0em)),
        curve.quad((w + .05em, .03em), (w, .06em)),
        curve.quad((.75 * w, -.495em), (0em, 0em)),
      ),
    )
  })
  set list(marker: text(fill: highlight-color.lighten(10%), sym.bullet))
  set enum(
    numbering: (..n) => text(
      fill: highlight-color.lighten(10%),
      numbering("1.", ..n),
    ),
  )
  body
}

#let title-slide(title, extra) = slide({
  set align(center + horizon)
  set page(footer: none, header: none)

  if title != none {
    set text(1.5em)
    title
    context {
      let w = measure(title).width
      let c(p) = curve(
        stroke: (paint: p, thickness: .1em, cap: "round"),
        curve.cubic((.2 * w, -.4em), (.95 * w, -.5em), (w + 1em, 0em)),
        curve.cubic(auto, (w + .5em, .1em), (w, .3em)),
      )
      v(-.5em)
      let hc = highlight-color-state.get()
      place(center, c(hc.transparentize(20%)))
      place(center, dx: .1em, dy: .1em, c(hc.transparentize(50%)))
    }
  }
  par(hide[42])

  extra
})

#let len2int(l) = int.from-bytes(l.pt().to-bytes())
#let hasher(acc, val) = acc.bit-xor(val)
#let hashed-position() = {
  let (x, y) = here().position()
  let n = counter("logical-slide").get()
  (len2int(x), len2int(y), ..n).reduce(hasher)
}

#let framed-block(
  body,
  sloppiness: .05,
  inset: .5em,
  width: auto,
  height: auto,
) = layout(sz => {
  let blocked-body = block(
    inset: inset,
    width: width,
    height: height,
    fill: none,
    stroke: none,
    body,
  )
  let (width: w, height: h) = measure(..sz, blocked-body)
  let deflect = sloppiness * (w + h) / 2

  let hash = (hashed-position(), len2int(w), len2int(h)).reduce(hasher)
  let rng = suiji.gen-rng-f(hash)
  let (rng, c1) = suiji.random-f(rng)
  let (rng, c2) = suiji.random-f(rng)
  let (rng, c3) = suiji.random-f(rng)
  let (rng, c4) = suiji.random-f(rng)
  let (rng, s1) = suiji.choice-f(rng, (-1, 1))
  let (rng, s2) = suiji.choice-f(rng, (-1, 1))
  let (rng, s3) = suiji.choice-f(rng, (-1, 1))
  let (rng, s4) = suiji.choice-f(rng, (-1, 1))

  let c(p) = curve(
    stroke: stroke(thickness: .1em, cap: "round", paint: p),
    curve.quad((c1 * w, s1 * deflect), (w + deflect / 3, 0pt)),
    curve.move((w - deflect / 3, -deflect / 3)),
    curve.quad((w + s2 * deflect, c2 * h), (w - deflect / 3, h + deflect / 3)),
    curve.move((w + deflect / 3, h - deflect / 3)),
    curve.quad((c3 * w, h + s3 * deflect), (0pt, h)),
    curve.quad((s4 * deflect, c4 * h), (0pt, 0pt)),
  )
  place(dx: .2em, dy: .15em, c(text.fill.transparentize(50%)))
  place(c(text.fill.transparentize(20%)))
  blocked-body
})

#let post-it(
  body,
  fill: rgb("#FDE85F"),
  angle: -10deg,
  sloppiness: .2,
) = context {
  let hash = hashed-position()
  let rng = suiji.gen-rng-f(hash)
  let (rng, angle-deviation) = suiji.uniform-f(rng, low: -1, high: 1)
  let angle = (1 + sloppiness * angle-deviation) * angle
  let (rng, color-deviation) = suiji.uniform-f(rng, low: -1, high: 1)
  let fill = fill.darken(sloppiness * color-deviation * 40%)

  rotate(
    angle,
    reflow: false,
    {
      place(
        dx: .0em,
        dy: .0em,
        umbra.shadow-path(
          (1cm, 1cm),
          (1cm, 5cm),
          (5cm, 5cm),
          (5cm, 4.9cm),
          (4cm, 1cm),
          correction: 10deg,
          closed: false,
        ),
      )
      place(
        curve(
          fill: fill,
          curve.line((5cm, 0cm)),
          curve.quad((5cm, 2.5cm), (5.2cm, 5cm)),
          curve.quad((2.5cm, 5.2cm), (.1cm, 5cm)),
          curve.quad((0cm, 2.5cm), (0cm, 0cm)),
        ),
      )
      box(inset: .5em, width: 5cm, height: 5cm, clip: true, body)
    },
  )
}
