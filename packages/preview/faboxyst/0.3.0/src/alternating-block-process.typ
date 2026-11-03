// Alternating colored process cards inspired by a PowerPoint slide layout.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

// The original PowerPoint chevrons are four separate, filled ribbon shapes,
// not outlined strokes. These path commands reproduce their silhouette.
#let _abp-arrow-paths = (
  (
    ("M", (4897, 3323)), ("L", (1328, 6039)),
    ("C", (1156, 6170), (875, 6170), (703, 6039)),
    ("L", (703, 5967)), ("L", (4176, 3323)),
    ("C", (4348, 3192), (4348, 2978), (4176, 2847)),
    ("L", (703, 204)), ("L", (703, 131)),
    ("C", (875, 0), (1156, 0), (1328, 131)),
    ("L", (4897, 2847)),
    ("C", (5069, 2978), (5069, 3192), (4897, 3323)),
  ),
  (
    ("M", (7626, 2895)), ("L", (4761, 714)),
    ("C", (4625, 611), (4398, 611), (4257, 714)),
    ("L", (4257, 773)), ("L", (7050, 2899)),
    ("C", (7186, 3002), (7186, 3175), (7050, 3282)),
    ("L", (4257, 5408)), ("L", (4257, 5466)),
    ("C", (4393, 5570), (4620, 5570), (4761, 5466)),
    ("L", (7626, 3285)),
    ("C", (7762, 3172), (7762, 2999), (7626, 2895)),
  ),
  (
    ("M", (3255, 3251)),
    ("C", (3373, 3161), (3373, 3013), (3255, 2923)),
    ("L", (789, 1046)),
    ("C", (671, 956), (476, 956), (358, 1046)),
    ("L", (358, 1094)), ("L", (2761, 2923)),
    ("C", (2879, 3013), (2879, 3161), (2761, 3251)),
    ("L", (358, 5080)), ("L", (358, 5128)),
    ("C", (476, 5218), (671, 5218), (789, 5128)),
    ("L", (3255, 3251)),
  ),
  (
    ("M", (1795, 2985)), ("L", (268, 1822)),
    ("C", (195, 1767), (73, 1767), (0, 1822)),
    ("L", (0, 1853)), ("L", (1487, 2985)),
    ("C", (1560, 3040), (1560, 3134), (1487, 3189)),
    ("L", (0, 4321)), ("L", (0, 4352)),
    ("C", (73, 4407), (195, 4407), (268, 4352)),
    ("L", (1795, 3189)),
    ("C", (1868, 3134), (1868, 3040), (1795, 2985)),
  ),
)

#let _abp-cubic(p0, p1, p2, p3, n: 10) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _abp-arrow-points(commands, card-width, card-height, outset,
                       rtl, y-base, move-inner: false) = {
  let out = ()
  let current = (0, 0)
  let sx = card-width / 18608
  let sy = card-height / 21600
  let out-cm = outset / 1cm
  let map-point = point => {
    // Nudge the separated ribbon without changing its pointed silhouette.
    let x = point.at(0) - (if move-inner { 960 } else { 0 })
    let relative-x = if x < 2992 {
      -out-cm * (2992 - x) / 2992
    } else {
      (x - 2992) * sx
    }
    let px = if rtl { card-width - relative-x } else { relative-x + out-cm }
    let py = -(point.at(1) - y-base) * sy
    (px, py)
  }
  for command in commands {
    let kind = command.at(0)
    if kind == "M" {
      current = command.at(1)
      out.push(map-point(current))
    } else if kind == "L" {
      current = command.at(1)
      out.push(map-point(current))
    } else if kind == "C" {
      let end = command.at(3)
      for point in _abp-cubic(current, command.at(1), command.at(2), end) {
        out.push(map-point(point))
      }
      current = end
    }
  }
  out
}

#let _abp-arrow-art(colour, card-width, card-height, outset,
                    rtl: false, y-base: 0) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  for index in range(_abp-arrow-paths.len()) {
    let points = _abp-arrow-points(
      _abp-arrow-paths.at(index), card-width, card-height, outset,
      rtl, y-base, move-inner: index == 1,
    )
    draw.line(..points, close: true, fill: colour, stroke: none)
  }
})

#let _abp-notch-art(card-width, height, colour, rtl: false, is-upper: true) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  // This is the exact inward cutout from the supplied PowerPoint card contour.
  // Its curved point and the two edge contacts come from the custom geometry.
  let sx = card-width / 18608
  let sy = height / 21600
  let start-y = if is-upper { 638 } else { 16068 }
  let shoulder-y = if is-upper { 2792 } else { 18221 }
  let control-a-y = if is-upper { 2954 } else { 18384 }
  let control-b-y = if is-upper { 3216 } else { 18646 }
  let end-shoulder-y = if is-upper { 3379 } else { 18808 }
  let end-y = if is-upper { 5532 } else { 20962 }
  let shoulder = ((5822 - 2992) * sx, -(shoulder-y - start-y) * sy)
  let tip-a = ((6035 - 2992) * sx, -(control-a-y - start-y) * sy)
  let tip-b = ((6035 - 2992) * sx, -(control-b-y - start-y) * sy)
  let far-shoulder = ((5822 - 2992) * sx, -(end-shoulder-y - start-y) * sy)
  let points = ((0, 0), shoulder)
  points += _abp-cubic(shoulder, tip-a, tip-b, far-shoulder, n: 20).slice(1)
  points.push((0, -(end-y - start-y) * sy))
  let depth = (6035 - 2992) * sx
  if rtl { points = points.map(((x, y)) => (depth - x, y)) }
  draw.line(..points, close: true, fill: colour, stroke: none)
})

#let _abp-number(index, step) = if "number" in step {
  step.at("number")
} else if index + 1 < 10 {
  [0#(index + 1)]
} else {
  [#(index + 1)]
}

#let _abp-card(
  step,
  index,
  card-width,
  requested-height,
  arrow-outset,
  radius,
  rtl,
  print-mode,
  colour,
  title-size,
  body-size,
  number-size,
  text-colour,
  number-colour,
  gap-y,
  notch-colour,
) = context {
  let face = if print-mode { white } else if "colour" in step { step.at("colour") } else { colour }
  let face-ink = if print-mode { rgb("#707070") } else { face }
  let title-ink = if print-mode { black } else { text-colour }
  let body-ink = if print-mode { black } else { text-colour.darken(40%) }
  let number-ink = if print-mode { rgb("#707070") }
    else if number-colour == auto { white } else { number-colour }
  let edge = if print-mode { (paint: black, thickness: 0.85pt) } else { none }
  let is-upper = calc.rem(index, 2) == 0
  let pad = 0.24
  let icon-zone = 1.40
  let number-zone = 1.80
  let inner-width = calc.max(0.8, card-width - 2 * pad)
  let title = text(size: title-size, weight: "bold", fill: title-ink,
    step.at("title"))
  let body = text(size: body-size, fill: body-ink, step.at("body"))
  let text-content = box(width: inner-width * 1cm,
    stack(dir: ttb, spacing: gap-y,
      align(if rtl { right } else { left }, title),
      align(if rtl { right } else { left }, body),
    ))
  let measured-content = measure(text-content).height / 1cm
  let min-height = 6.30
  let height = if requested-height == auto {
    calc.max(min-height, measured-content + 2.75)
  } else {
    calc.max(requested-height / 1cm, measured-content + 2.75)
  }
  let icon = if print-mode and "print-icon" in step {
    step.at("print-icon")
  } else if "icon" in step {
    step.at("icon")
  } else { none }
  let number = _abp-number(index, step)
  let logical-leading = if rtl { card-width - pad - icon-zone } else { pad }
  let logical-trailing = if rtl { pad } else { card-width - pad - number-zone }
  let text-x = pad
  let text-top = (height - measured-content) / 2
  let top-y = 0.18
  let bottom-y = height - 1.58
  let icon-y = if is-upper { bottom-y } else { top-y }
  let number-y = if is-upper { top-y } else { bottom-y }
  let number-box = box(width: number-zone * 1cm, height: 1.20cm,
    align(center, text(size: number-size, weight: "bold", fill: number-ink, number)))
  let icon-box = if icon == none { none }
    else { box(width: icon-zone * 1cm, height: icon-zone * 1cm, align(center, icon)) }
  let arrow-outset = if arrow-outset == auto {
    card-width * 2992 / 18608 * 1cm
  } else { arrow-outset }
  let arrow-height = height * 6170 / 21600
  let arrow-y-base = if is-upper { 0 } else { 15430 }
  let arrow-y = if is-upper { 0 } else { height - arrow-height }
  let mask-y = if is-upper { 0.12 } else { height - arrow-height }
  let mask-height = calc.max(0, arrow-height - 0.12)
  let mask-x = if rtl { card-width - 0.09 } else { -0.09 }
  let notch-ink = if print-mode { white }
    else if notch-colour == auto { rgb("#F2EFF1") } else { notch-colour }
  let notch-depth = card-width * (6035 - 2992) / 18608
  let notch-y = if is-upper {
    height * 638 / 21600
  } else {
    height * 16068 / 21600
  }
  let notch-x = if rtl { card-width - notch-depth } else { 0 }
  let face-card = box(width: card-width * 1cm, height: height * 1cm,
    radius: radius,
    fill: face,
    stroke: edge,
    inset: 0pt,
    {
      place(top + left, dx: logical-leading * 1cm, dy: icon-y * 1cm, icon-box)
      place(top + left, dx: logical-trailing * 1cm, dy: number-y * 1cm, number-box)
      place(top + left, dx: text-x * 1cm, dy: text-top * 1cm, text-content)
    })
  // Keep the four filled ribbons in the foreground, matching the source slide.
  // Print uses medium gray, with a white knockout under the frame crossing.
  box(width: card-width * 1cm, height: height * 1cm, inset: 0pt, {
    place(top + left, face-card)
    if print-mode {
      // Knock out the frame segment under the connector so no black line
      // shows through the white gaps between the chevron ribbons.
      place(top + left, dx: mask-x * 1cm, dy: mask-y * 1cm,
        box(width: 0.18cm, height: mask-height * 1cm, fill: white, inset: 0pt))
    }
    // Restore the page-colored negative-space cutout from the source slide.
    // Keep it under the ribbons so their colored tips enter the card intact.
    place(top + left, dx: notch-x * 1cm, dy: notch-y * 1cm,
      _abp-notch-art(card-width, height, notch-ink, rtl: rtl, is-upper: is-upper))
    place(top + left,
      dx: if rtl {
        card-width * (1 - 4770 / 18608) * 1cm
      } else { -arrow-outset },
      dy: arrow-y * 1cm,
      _abp-arrow-art(
        face-ink, card-width, height, arrow-outset,
        rtl: rtl, y-base: arrow-y-base,
      ))
  })
}

/// A horizontal process made of alternating, numbered color blocks.
///
/// Pass an array of step dictionaries. Each step requires `title` and `body`;
/// `icon` is optional Typst content. `print-icon` supplies its monochrome
/// counterpart for print output when the normal icon is an image. `number` and
/// `colour` can override the automatic two-digit numbering and cycling palette.
/// The sequence reverses and the chevrons, text alignment, and icon/number
/// positions mirror in RTL. Chevron ribbons overlay the card faces, matching
/// the source slide. The inward cutout follows the original rounded card
/// contour; `notch-colour:` customizes its background fill (default `#F2EFF1`,
/// white in print). Print mode uses white cards and black outlines/body text;
/// chevrons, numbers and icons are medium gray. Use `print-icon` for gray image
/// counterparts.
///
/// ```typ
/// #alternating-block-process(steps: (
///   (title: [Define], body: [Agree on the goal.], icon: [◎]),
///   (title: [Plan], body: [Choose the next action.], icon: [↗]),
/// ))
/// ```
#let alternating-block-process(
  steps: (),
  width: auto,
  height: 6.30cm,
  gap: 0.72cm,
  arrow-outset: auto,
  radius: 0.12cm,
  direction: auto,
  colours: (
    rgb("#4ABCE6"), rgb("#A5BF6A"), rgb("#F3921B"), rgb("#FFD04A"),
  ),
  title-size: 10.5pt,
  body-size: 7.7pt,
  number-size: 31pt,
  text-colour: rgb("#202020"),
  number-colour: auto,
  notch-colour: auto,
  gap-y: 0.13cm,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })
  if print-mode { set text(fill: black) }

  layout(avail => {
    let count = steps.len()
    if count == 0 { none } else {
      let total-width = if width == auto { avail.width / 1cm }
        else if type(width) == ratio { avail.width * width / 1cm }
        else { width / 1cm }
      let gap-cm = gap / 1cm
      let card-width = calc.max(1.8, (total-width - (count - 1) * gap-cm) / count)
      let cards = range(count).map(index => {
        let source-colour = if "colour" in steps.at(index) {
          steps.at(index).at("colour")
        } else { colours.at(calc.rem(index, colours.len())) }
        _abp-card(
          steps.at(index), index, card-width, height, arrow-outset, radius,
          rtl, print-mode, source-colour, title-size, body-size, number-size,
          text-colour, number-colour, gap-y, notch-colour,
        )
      })
      let columns = range(count).map(_ => card-width * 1cm)
      grid(columns: columns, column-gutter: gap, ..cards)
    }
  })
}
