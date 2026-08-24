// exercise-boxes.typ
// Arabic exercise-card primitives inspired by the numbered worksheet supplied
// by the user. Every physical value is derived from the measured card.

#import "../vendor/scrawl/lib.typ": scrawl, circle-pts, rounded-rect-pts

#let ex-palette = (
  one: rgb("#8CCFC6"),
  two: rgb("#F07869"),
  three: rgb("#B48BD0"),
  four: rgb("#F2BE4B"),
  five: rgb("#E4C64A"),
  six: rgb("#B9D447"),
  seven: rgb("#BED86A"),
  eight: rgb("#A89BD5"),
  nine: rgb("#A35685"),
  ink: rgb("#18232A"),
  paper: rgb("#FFFEF8"),
  fold: rgb("#C9A95A"),
)

// `number:` is optional. When omitted, each exercise keeps its natural
// number (1…10); when provided, it is spread into a box through `..style`.
#let exercise-style(mode: "normal", roughness: 1.0, dir: rtl,
                    color_mode: "color", seed: 1, number: auto) = {
  if number == auto {
    return (
      mode: mode, roughness: roughness, dir: dir,
      color_mode: color_mode, seed: seed,
    )
  }
  (
    mode: mode, roughness: roughness, dir: dir,
    color_mode: color_mode, seed: seed, number: number,
  )
}

#let _ex-resolve-width(width, available) = {
  if type(width) == ratio { available * width } else if width == auto { available } else { width }
}

#let _ex-start(dir) = if dir == rtl { right } else { left }
#let _ex-flow(body, dir) = align(_ex-start(dir), text(dir: dir)[#body])

// A heading is always geometrically centred, while its own BiDi direction
// remains the component's global `dir`: Arabic titles run RTL, Latin titles
// run LTR. This is shared by every numbered exercise card.
#let _ex-centered-title(title, dir, size: 1.10em, weight: "bold",
                        fill: ex-palette.ink) = align(center)[
  #text(dir: dir, size: size, weight: weight, fill: fill)[#title]
]

// Add a geometry-aware safe margin to any user inset. This keeps prose,
// equations and dotted answer lines safely inside every irregular outline.
#let _ex-safe-inset(inset, left_extra: 0pt, right_extra: 0pt,
                    top_extra: 0pt, bottom_extra: 0pt) = {
  if type(inset) == length {
    (left: inset + left_extra, right: inset + right_extra,
     top: inset + top_extra, bottom: inset + bottom_extra)
  } else if type(inset) == dictionary {
    let x = inset.at("x", default: 0pt)
    let y = inset.at("y", default: 0pt)
    (left: inset.at("left", default: x) + left_extra,
     right: inset.at("right", default: x) + right_extra,
     top: inset.at("top", default: y) + top_extra,
     bottom: inset.at("bottom", default: y) + bottom_extra)
  } else { inset }
}

#let _ex-smooth(points, radius: .12, samples: 4) = {
  let n = points.len()
  if n < 3 or radius <= 0 { return points }
  let out = ()
  for i in range(n) {
    let a0 = points.at(calc.rem(i - 1 + n, n))
    let p = points.at(i)
    let b0 = points.at(calc.rem(i + 1, n))
    let da = calc.sqrt(calc.pow(a0.at(0) - p.at(0), 2)
      + calc.pow(a0.at(1) - p.at(1), 2))
    let db = calc.sqrt(calc.pow(b0.at(0) - p.at(0), 2)
      + calc.pow(b0.at(1) - p.at(1), 2))
    let d = calc.min(radius, da * .28, db * .28)
    if d <= .001 { out.push(p); continue }
    let a = (p.at(0) + (a0.at(0) - p.at(0)) * d / da,
             p.at(1) + (a0.at(1) - p.at(1)) * d / da)
    let b = (p.at(0) + (b0.at(0) - p.at(0)) * d / db,
             p.at(1) + (b0.at(1) - p.at(1)) * d / db)
    out.push(a)
    for j in range(1, samples + 1) {
      let t = j / samples
      let u = 1 - t
      out.push((u * u * a.at(0) + 2 * u * t * p.at(0) + t * t * b.at(0),
                u * u * a.at(1) + 2 * u * t * p.at(1) + t * t * b.at(1)))
    }
  }
  out
}

// A sampled cubic Bézier remains compatible with the point-based Scrawl API.
// It is used where a visible, genuinely curved contour is needed rather than
// a polygonal corner merely softened by a small rounding radius.
#let _ex-cubic(p0, p1, p2, p3, samples: 16) = {
  let out = ()
  for i in range(samples + 1) {
    let t = i / samples
    let u = 1 - t
    out.push((
      calc.pow(u, 3) * p0.at(0) + 3 * calc.pow(u, 2) * t * p1.at(0)
        + 3 * u * calc.pow(t, 2) * p2.at(0) + calc.pow(t, 3) * p3.at(0),
      calc.pow(u, 3) * p0.at(1) + 3 * calc.pow(u, 2) * t * p1.at(1)
        + 3 * u * calc.pow(t, 2) * p2.at(1) + calc.pow(t, 3) * p3.at(1),
    ))
  }
  out
}

#let _ex-color(kind) = {
  if kind == "1" { return ex-palette.one }
  if kind == "2" { return ex-palette.two }
  if kind == "3" { return ex-palette.three }
  if kind == "4" { return ex-palette.four }
  if kind == "5" { return ex-palette.five }
  if kind == "6" { return ex-palette.six }
  if kind == "7" { return ex-palette.seven }
  if kind == "8" { return ex-palette.eight }
  ex-palette.nine
}

#let _ex-outline(kind, w, h) = if kind == "1" {
  ((.04 * w, .10 * h), (.14 * w, .02 * h), (.83 * w, .02 * h),
   (.98 * w, .17 * h), (.98 * w, .80 * h), (.85 * w, .98 * h),
   (.18 * w, .98 * h), (.02 * w, .82 * h), (.02 * w, .24 * h))
} else if kind == "2" {
  ((.08 * w, .05 * h), (.78 * w, .05 * h), (.98 * w, .23 * h),
   (.95 * w, .77 * h), (.80 * w, .97 * h), (.18 * w, .97 * h),
   (.03 * w, .76 * h), (.10 * w, .28 * h))
} else if kind == "3" {
  ((.10 * w, .04 * h), (.80 * w, .04 * h), (.98 * w, .17 * h),
   (.94 * w, .63 * h), (w, .82 * h), (.76 * w, .80 * h),
   (.58 * w, .96 * h), (.15 * w, .96 * h), (.03 * w, .78 * h),
   (.04 * w, .20 * h))
} else if kind == "4" {
  ((.08 * w, .06 * h), (.82 * w, .06 * h), (.98 * w, .24 * h),
   (.96 * w, .74 * h), (.75 * w, .96 * h), (.28 * w, .96 * h),
   (.03 * w, .77 * h), (.03 * w, .20 * h))
} else if kind == "5" {
  ((.10 * w, .03 * h), (.84 * w, .03 * h), (.98 * w, .18 * h),
   (.92 * w, .78 * h), (.66 * w, .98 * h), (.25 * w, .96 * h),
   (.03 * w, .76 * h), (.03 * w, .22 * h))
} else if kind == "6" {
  ((.08 * w, .05 * h), (.80 * w, .05 * h), (.96 * w, .18 * h),
   (.94 * w, .72 * h), (.99 * w, .90 * h), (.76 * w, .90 * h),
   (.65 * w, .98 * h), (.15 * w, .98 * h), (.02 * w, .80 * h),
   (.03 * w, .18 * h))
} else if kind == "7" {
  ((.06 * w, .05 * h), (.82 * w, .05 * h), (.98 * w, .18 * h),
   (.92 * w, .62 * h), (.74 * w, .78 * h), (.72 * w, .98 * h),
   (.13 * w, .98 * h), (.02 * w, .82 * h), (.02 * w, .18 * h))
} else if kind == "8" {
  ((.06 * w, .06 * h), (.78 * w, .06 * h), (.97 * w, .20 * h),
   (.93 * w, .70 * h), (.80 * w, .96 * h), (.28 * w, .96 * h),
   (.04 * w, .78 * h), (.03 * w, .20 * h))
} else {
  ((.08 * w, .05 * h), (.82 * w, .05 * h), (.98 * w, .22 * h),
   (.95 * w, .72 * h), (w, .88 * h), (.75 * w, .88 * h),
   (.60 * w, .98 * h), (.15 * w, .98 * h), (.03 * w, .80 * h),
   (.04 * w, .18 * h))
}


#let _ex-badge(shape, label, w, h, r, fill, ink, dir, seed) = {
  let cx = if dir == rtl { w - r * 1.25 } else { r * 1.25 }
  let cy = h - r * 1.22
  shape(circle-pts((cx, cy), r), fill: fill, paint: ink, weight: .9pt,
    seed: seed + 1)
  shape(circle-pts((cx, cy), r * .78), fill: none,
    paint: if fill == white { ink } else { white }, weight: .35pt,
    seed: seed + 2)
}


// Generic measured card behind exercises 1, 2, 3, 5, 6 and 7.
#let _exercise-card(kind, body, number: auto, title: none,
                    title_size: 1.10em, title_weight: "bold",
                    title_gap: .34em, width: 100%,
                    // Public baseline inset: 3 mm on every side. Shape- and
                    // badge-aware clearance is added internally only where needed.
                    inset: 3mm,
                    color_mode: "color", dir: rtl, mode: "normal",
                    roughness: 1.0, seed: 1) = layout(area => {
  let card_w = _ex-resolve-width(width, area.width)
  let label = if number == auto { kind } else { number }
  // Extra room on the badge side and around the irregular shape.
  let side_clear = card_w * 4.5%
  let badge_clear = card_w * 13%
  let safe_inset = if dir == rtl {
    _ex-safe-inset(inset, left_extra: side_clear,
      right_extra: side_clear + badge_clear,
      top_extra: card_w * 3.2%, bottom_extra: card_w * 3.2%)
  } else {
    _ex-safe-inset(inset, left_extra: side_clear + badge_clear,
      right_extra: side_clear,
      top_extra: card_w * 3.2%, bottom_extra: card_w * 3.2%)
  }
  // `title:` is optional for backwards compatibility: callers may still put
  // their own heading in `body`. When used, it gets one consistent centred
  // treatment without losing the global RTL/LTR text direction.
  let content = if title == none { body } else {
    [
      #_ex-centered-title(title, dir, size: title_size, weight: title_weight)
      #v(title_gap)
      #body
    ]
  }
  let inner = block(width: card_w, inset: safe_inset, _ex-flow(content, dir))
  let m = measure(inner)
  let w = m.width / 1cm
  let h = m.height / 1cm
  let base = if color_mode == "plain" { white } else { _ex-color(kind) }
  let ink = ex-palette.ink
  let badge_fill = if color_mode == "plain" { white } else { _ex-color(kind).darken(18%) }
  let badge_ink = if color_mode == "plain" { ink } else { white }
  let radius = calc.min(w, h) * .075
  let badge_r = calc.min(w, h) * .145
  let stroke = m.width * .18%
  let hand = mode == "rough"
  let points = _ex-smooth(_ex-outline(kind, w, h), radius: radius)
  let canvas = scrawl(width: m.width, height: m.height, hand: hand,
    roughness: roughness, seed: seed,
    (shape, ..) => {
      shape(points, fill: base, paint: ink, weight: stroke, seed: seed)
      _ex-badge(shape, label, w, h, badge_r, badge_fill, badge_ink,
        dir, seed)
    },
  )
  let badge = text(dir: dir, size: badge_r * 1cm * .72, weight: "bold",
    fill: badge_ink)[#label]
  block(width: m.width, height: m.height, {
    place(top + left, canvas)
    // Number is positioned over the decorative circle.
    let badge_x = if dir == rtl { w - badge_r * 1.25 } else { badge_r * 1.25 }
    let badge_y = h - badge_r * 1.22
    place(top + left, dx: (badge_x - badge_r) * 1cm,
      dy: (h - badge_y - badge_r) * 1cm,
      box(width: badge_r * 2cm, height: badge_r * 2cm,
        align(center + horizon, badge)))
    place(top + left, inner)
  })
})

#let exercise-1 = _exercise-card.with("1")
#let exercise-2 = _exercise-card.with("2")
#let exercise-3 = _exercise-card.with("3")
#let exercise-4 = _exercise-card.with("4")
#let exercise-5 = _exercise-card.with("5")
#let exercise-6 = _exercise-card.with("6")
#let exercise-7 = _exercise-card.with("7")
#let exercise-8 = _exercise-card.with("8")
#let exercise-9 = _exercise-card.with("9")

// Wide exercise-10 applications box. By default it is one uninterrupted
// panel; pass `columns: 2` (or more) and optional `cells:` only when divisions
// are deliberately wanted.
#let exercise-10(body, number: "10", title: [تطبيقات مركبة], columns: 1,
                 cells: none, column_gutter: 5mm,
                 width: 100%, inset: (x: 1.1em, top: 2.25em, bottom: 1em),
                 title_band_fill: auto, title_band_width: 56%,
                 // Absolute or relative extension added to title_band_width.
                 // It makes a precise +3mm adjustment possible at any page size.
                 title_band_extra: 0mm,
                 // `auto` follows the title's natural height; a ratio is
                 // relative to the whole box and a length is an exact height.
                 title_band_height: auto,
                 title_band_extra_height: 0mm,
                 title_band_position: "center",
                 color_mode: "color", dir: rtl, mode: "normal",
                 roughness: 1.0, seed: 10) = layout(area => {
  let card_w = _ex-resolve-width(width, area.width)
  let column_count = calc.max(1, int(columns))
  let content = if cells == none { body } else {
    grid(columns: column_count, column-gutter: column_gutter, ..cells)
  }
  let band_fill = if title_band_fill == auto {
    if color_mode == "plain" { white } else { ex-palette.eight }
  } else { title_band_fill }
  let band_ink = if color_mode == "plain" { ex-palette.ink } else { white }
  let safe_inset = if dir == rtl {
    _ex-safe-inset(inset, left_extra: card_w * 4%,
      right_extra: card_w * 12%, top_extra: card_w * 2%)
  } else {
    _ex-safe-inset(inset, left_extra: card_w * 12%,
      right_extra: card_w * 4%, top_extra: card_w * 2%)
  }
  let inner = block(width: card_w, inset: safe_inset, _ex-flow(content, dir))
  let m = measure(inner)
  let w = m.width / 1cm
  let h = m.height / 1cm
  let ink = ex-palette.ink
  let base = white
  let br = calc.min(w, h) * .13
  // `title_band_width` accepts a ratio (the responsive default) or a length.
  // `title_band_extra` accepts the same forms and is useful for exact changes,
  // e.g. `title_band_extra: 3mm`.
  let requested_band_w = if type(title_band_width) == ratio {
    w * title_band_width / 100%
  } else { title_band_width / 1cm }
  let extra_band_w = if type(title_band_extra) == ratio {
    w * title_band_extra / 100%
  } else { title_band_extra / 1cm }
  let max_band_w = if title_band_position == "left" { .88 * w }
    else if title_band_position == "right" { .85 * w }
    else { .92 * w }
  let band_w = calc.min(max_band_w, requested_band_w + extra_band_w)
  // Measure the title at the actual banner width. This lets a longer LTR
  // label wrap before the banner height is calculated, rather than clipping.
  let title_side = .055 * band_w * 1cm
  let title_width = band_w * 1cm - 2 * title_side
  let title_style = block(width: title_width,
    _ex-centered-title(title, dir, size: 1.15em, weight: "bold", fill: band_ink))
  let title_m = measure(title_style)
  let header_padding = calc.max(h * .09, title_m.height / 1cm * .20)
  // Keep the former natural title fit as the minimum, then allow either a
  // declared height or an exact physical extension (e.g. +3mm) to enlarge it.
  let natural_band_h = .92 * (title_m.height / 1cm + header_padding)
  let requested_band_h = if title_band_height == auto { natural_band_h }
    else if type(title_band_height) == ratio { h * title_band_height / 100% }
    else { title_band_height / 1cm }
  let extra_band_h = if type(title_band_extra_height) == ratio {
    h * title_band_extra_height / 100%
  } else { title_band_extra_height / 1cm }
  let band_h = calc.max(natural_band_h, requested_band_h + extra_band_h)
  // The reserved header remains slightly taller than the coloured face, which
  // keeps optional column rules safely below the title band.
  let header_h = band_h / .92
  let band_x = if title_band_position == "left" {
    .10 * w
  } else if title_band_position == "right" {
    w - band_w - .15 * w
  } else {
    (w - band_w) / 2
  }
  // The cuvette hangs from the upper frame: both curved ends touch y = h.
  let band_y = h - band_h
  let stroke = m.width * .20%
  let hand = mode == "rough"
  let canvas = scrawl(width: m.width, height: m.height, hand: hand,
    roughness: roughness, seed: seed,
    (shape, ..) => {
      shape(rounded-rect-pts((0, 0), (w, h), radius: calc.min(w, h) * .06),
        fill: base, paint: ink, weight: stroke, seed: seed)
      // Centered violet band. Its two sides are mirrored cubic curves:
      // they leave and rejoin the upper frame tangentially, so the contact
      // with the frame is rounded instead of forming two abrupt corners.
      let end_inset = .11 * band_w
      let curve_handle = .30 * end_inset
      let right_curve = _ex-cubic(
        (band_x + band_w, h),
        (band_x + band_w - curve_handle, h),
        (band_x + band_w - end_inset + curve_handle, band_y),
        (band_x + band_w - end_inset, band_y),
      )
      let left_curve = _ex-cubic(
        (band_x + end_inset, band_y),
        (band_x + end_inset - curve_handle, band_y),
        (band_x + curve_handle, h),
        (band_x, h),
      )
      let violet_band = ((band_x, h), (band_x + band_w, h))
      for i in range(1, right_curve.len()) {
        violet_band.push(right_curve.at(i))
      }
      violet_band.push((band_x + end_inset, band_y))
      for i in range(1, left_curve.len()) {
        violet_band.push(left_curve.at(i))
      }
      shape(violet_band, fill: band_fill, paint: ink, weight: stroke * .60,
        seed: seed + 1)
      // The header is deliberately clean: no horizontal side rules compete
      // with the violet title band. Only the requested column divisions stay.
      for i in range(1, column_count) {
        let x = i * w / column_count
        shape(((x, .08 * h), (x, h - header_h)), closed: false,
          paint: ink, weight: stroke * .50, seed: seed + 10 + i)
      }
      _ex-badge(shape, number, w, h, br,
        if color_mode == "plain" { white } else { rgb("#27486D") },
        if color_mode == "plain" { ink } else { white }, dir, seed + 50)
    },
  )
  let badge_fill = if color_mode == "plain" { ink } else { white }
  block(width: m.width, height: m.height, {
    place(top + left, canvas)
    place(top + left, dx: band_x * 1cm,
      dy: (h - band_y - band_h) * 1cm,
      box(width: band_w * 1cm, height: band_h * 1cm,
        align(center + horizon, title_style)))
    let badge_x = if dir == rtl { w - br * 1.25 } else { br * 1.25 }
    let badge_y = h - br * 1.22
    place(top + left, dx: (badge_x - br) * 1cm,
      dy: (h - badge_y - br) * 1cm,
      box(width: br * 2cm, height: br * 2cm,
        align(center + horizon, text(dir: dir, size: br * .72cm,
          weight: "bold", fill: badge_fill)[#number])))
    place(top + left, inner)
  })
})
