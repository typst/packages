// ===========================================================================
//  faboxyst/flagbox.typ — a box whose title hangs from a rod, like a flag.
//
//  After tcolorbox's "flag" style: the title sits in a banner that is wider
//  at the rod than at its foot, painted with a three-stop gradient, and the
//  rod sits astride the top rule and the banner hangs into the box,
//  seated like the sash of an ornate box.
//
//    #flagbox(title: [First box])[…]
//    #flagbox(title: [Roots], tail: "swallow", badge: [3])[…]
//    #flagbox(title: [Warning], colour: red, flag-align: center)[…]
//
//  What is new against the plain port:
//    · the rod has finials and the banner a soft shadow, a gloss line and
//      an optional stitched hem
//    · three feet: "drape" (the original rounded foot), "point", "swallow"
//    · a numbered badge on the rod, an optional finial motif at the far end
//    · flag-align start | center | end, and full RTL: under `dir: rtl` the
//      flag, the badge and the gradient all run from the right
//    · the body block stays breakable
// ===========================================================================

#import "fabox.typ": is-rtl
#import "watermark.typ": paint-watermark, resolve-wm-colour
#import "ornament.typ": resolve-motif, make-palette, disc, poly, ngon-points

#let _cm(x) = if type(x) == length { x } else { x * 1cm }

/// The banner outline, in a local frame whose origin is the rod's leading
/// end at the flag's top. `w` is the width of the words, `h` the drop.
#let _flag-path(w, h, spread, r, tail, notch) = {
  let ops = (
    curve.move((-spread, 0pt)),
    curve.line((w + spread, 0pt)),
    // the trailing edge sweeps in from the rod to the foot
    curve.quad((w + 0.5mm, r * 0.5), (w, h - r)),
  )
  if tail == "point" {
    ops += (
      curve.line((w * 0.5 + r, h + notch * 0.15)),
      curve.line((w * 0.5, h + notch)),
      curve.line((w * 0.5 - r, h + notch * 0.15)),
    )
  } else if tail == "swallow" {
    ops += (
      curve.quad((w - 0.3mm, h), (w - r, h)),
      curve.line((w * 0.5 + r, h)),
      curve.line((w * 0.5, h - notch)),
      curve.line((w * 0.5 - r, h)),
      curve.line((r, h)),
    )
  } else {
    ops += (
      curve.quad((w - 0.3mm, h), (w - r, h)),
      curve.line((r, h)),
    )
  }
  ops += (
    curve.quad((0.3mm, h), (0pt, h - r)),
    curve.quad((-0.5mm, r * 0.5), (-spread, 0pt)),
    curve.close(),
  )
  ops
}

/// A box with a hanging title flag.
///
///   colour        the frame; the body wash and the banner derive from it
///   fill          body background; auto = a light wash of `colour`
///   ribbon        banner colour at its ends; auto = colour lightened
///   ribbon-mid    banner colour at its middle; auto = a shade darker
///   title-colour  the lettering
///   flag-align    start | center | end — where the flag hangs
///   shift         distance from the frame corner (start / end) to the flag
///   spread        how much wider the banner is at the rod than at its foot
///   overhang      how far the rod stands above the top rule it seats on
///   tail          "drape" | "point" | "swallow" — the shape of the foot
///   notch         depth of the point or the swallow's V
///   rod           rod thickness; none = no rod
///   finials       true draws a bead at each end of the rod
///   badge         content in a disc on the rod's leading end
///   end-motif     an ornament hanging at the rod's trailing end
///   gloss         the light line under the rod; stitch the dashed hem
///   shadow        a soft shadow under the banner
///   radius        of the box; flag-radius of the banner's foot
#let flagbox(
  body,
  title: none,
  colour: rgb("#1C5F9C"),
  fill: auto,
  ribbon: auto,
  ribbon-mid: auto,
  title-colour: white,
  title-weight: "bold",
  title-size: 1em,
  title-inset: (x: 0.30cm, y: 0.16cm),
  flag-align: start,
  shift: 1.0cm,
  spread: 0.20cm,
  overhang: 0.05cm,
  tail: "drape",
  notch: 0.22cm,
  rod: 0.10cm,
  rod-colour: auto,
  finials: true,
  badge: none,
  badge-colour: auto,
  end-motif: none,
  end-motif-size: 0.5cm,
  gloss: true,
  stitch: false,
  shadow: true,
  radius: 0.10cm,
  flag-radius: 0.10cm,
  stroke: 0.4mm,
  inset: (top: 0.30cm, left: 0.30cm, right: 0.30cm, bottom: 0.30cm),
  width: 100%,
  breakable: true,
  watermark: none,
  watermark-colour: auto,
  watermark-angle: -18deg,
  watermark-size: 2.1em,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }

  let fill = if fill == auto { colour.lighten(84%) } else { fill }
  let ribbon = if ribbon == auto { colour.lighten(28%) } else { ribbon }
  let ribbon-mid = if ribbon-mid == auto { colour.lighten(10%) } else { ribbon-mid }
  let rod-colour = if rod-colour == auto { colour.darken(18%) } else { rod-colour }
  let badge-colour = if badge-colour == auto { colour.darken(25%) } else { badge-colour }
  let pal = make-palette(ink: colour.darken(18%), gold: ribbon, paper: fill)

  let title-body = if title == none { none } else {
    text(fill: title-colour, weight: title-weight, size: title-size, dir: body-dir, title)
  }
  let t-ins = if type(title-inset) == dictionary {
    (x: _cm(title-inset.at("x", default: 0.3cm)), y: _cm(title-inset.at("y", default: 0.15cm)))
  } else { (x: _cm(title-inset), y: _cm(title-inset)) }
  let tm = if title-body == none { (width: 0pt, height: 0pt) } else { measure(title-body) }
  let has-flag = title != none
  let bsz = if badge == none { 0pt } else { tm.height + 2 * t-ins.y + 0.10cm }
  let lead = if badge == none { 0pt } else { bsz * 0.55 }
  let w = tm.width + 2 * t-ins.x + lead
  let h = tm.height + 2 * t-ins.y
  let sp = _cm(spread)
  let oh = _cm(overhang)
  let nk = if tail == "drape" { 0pt } else { _cm(notch) }
  let rod-t = if rod == none { 0pt } else { _cm(rod) }
  let ins = if type(inset) == dictionary { inset } else { (top: inset, left: inset, right: inset, bottom: inset) }
  // the ribbon seats ON the top rule, like the sash of an ornate box: the
  // rod lies astride the rule and the banner hangs into the box; `overhang`
  // lifts the rod that far above the rule's outer edge
  let flag-h = h + rod-t
  let esz = _cm(end-motif-size)

  // a horizontal gradient, running with the reading direction
  let grad = gradient.linear(
    ..(if rtl { (ribbon, ribbon-mid, ribbon) } else { (ribbon, ribbon-mid, ribbon) }),
    angle: 0deg, relative: "self")

  let flag = if not has-flag { none } else {
    box(width: w + 2 * sp, height: flag-h + nk + rod-t, {
      // the local origin: the leading end of the words, at the flag's top
      let ox = sp
      let oy = rod-t
      // soft shadow: three transparent copies, each a little lower
      if shadow {
        for k in range(3) {
          let t = (k + 1) / 3
          place(top + left, dx: ox + 0.02cm, dy: oy + 0.03cm + 0.03cm * t,
            curve(fill: colour.darken(40%).transparentize(100% - 9% * (1 - t) - 4%),
              stroke: none, .._flag-path(w, h, sp, _cm(flag-radius), tail, nk)))
        }
      }
      // the banner
      place(top + left, dx: ox, dy: oy,
        curve(fill: grad, stroke: none, .._flag-path(w, h, sp, _cm(flag-radius), tail, nk)))
      // the gloss line just under the rod
      if gloss {
        place(top + left, dx: ox - sp + 0.08cm, dy: oy + 0.09cm,
          line(length: w + 2 * sp - 0.16cm, stroke: 0.4pt + white.transparentize(45%)))
      }
      // the stitched hem
      if stitch {
        place(top + left, dx: ox + 0.14cm, dy: oy + 0.16cm,
          rect(width: w - 0.28cm, height: h - 0.30cm, radius: _cm(flag-radius) * 0.6,
            stroke: (paint: white.transparentize(35%), thickness: 0.5pt, dash: (1.2pt, 1.6pt))))
      }
      // the rod, with its rounded ends and finials
      if rod != none {
        place(top + left, dx: ox - sp - rod-t, dy: oy - rod-t / 2,
          rect(width: w + 2 * sp + 2 * rod-t, height: rod-t, radius: rod-t / 2, fill: rod-colour))
        if finials {
          disc((ox - sp - rod-t, oy), rod-t * 0.9, fill: rod-colour, stroke: 0.4pt + fill)
          disc((ox + w + sp + rod-t, oy), rod-t * 0.9, fill: rod-colour, stroke: 0.4pt + fill)
        }
      }
      // the words, after the badge on the leading side
      let tx = if rtl { ox } else { ox + lead }
      place(top + left, dx: tx, dy: oy,
        box(width: w - lead, height: h, align(center + horizon, title-body)))
      // the badge: a disc astride the leading end of the rod
      if badge != none {
        let bx = if rtl { ox + w - bsz * 0.36 } else { ox + bsz * 0.36 }
        let by = oy + h * 0.5
        disc((bx, by), bsz / 2, fill: badge-colour, stroke: 0.7pt + fill)
        place(top + left, dx: bx - bsz / 2, dy: by - bsz / 2,
          box(width: bsz, height: bsz, align(center + horizon,
            text(fill: title-colour, weight: "bold", size: bsz * 0.46,
              number-type: "lining", dir: ltr, badge))))
      }
    })
  }

  let end-m = resolve-motif(end-motif)

  block(
    breakable: breakable,
    width: width,
    fill: fill,
    stroke: stroke + colour,
    radius: _cm(radius),
    inset: ins,
    {
      set text(dir: body-dir)
      set align(start)
      if has-flag {
        // Anchor the flag against the box's top rule. The block's inset is
        // outside the content, so `dy` is measured from the padded top.
        // The rule's centre lies `top-gap` above the content, its outer
        // edge half a stroke further; the rod's top stands `overhang`
        // above that edge, so the rod covers the rule and the banner
        // hangs below it, into the box.
        let top-gap = if type(ins.top) == length { ins.top } else { _cm(ins.top) }
        let swt = if type(stroke) == dictionary {
          stroke.at("thickness", default: 0.4mm)
        } else if type(stroke) == length { stroke } else { 0.4mm }
        let dy = -top-gap - swt / 2 - oh - rod-t / 2
        let fw = w + 2 * sp
        let place-flag = {
          if flag-align == center {
            place(top + center, dy: dy, flag)
          } else if (flag-align == start) != rtl {
            place(top + left, dx: -(if type(ins.left) == length { ins.left } else { _cm(ins.left) }) + _cm(shift) - sp, dy: dy, flag)
          } else {
            place(top + right, dx: (if type(ins.right) == length { ins.right } else { _cm(ins.right) }) - _cm(shift) + sp, dy: dy, flag)
          }
        }
        place-flag
        // an ornament hanging from the rod's trailing end
        if end-m != none {
          let d = (w: esz * end-m.aspect.at(0), h: esz * end-m.aspect.at(1))
          let it = (end-m.draw)(esz, pal)
          if flag-align == center {
            place(top + center, dx: (if rtl { -1 } else { 1 }) * (fw / 2 + d.w / 2 + 0.05cm),
              dy: dy + rod-t - d.h / 2, it)
          } else if (flag-align == start) != rtl {
            place(top + left, dx: -(if type(ins.left) == length { ins.left } else { _cm(ins.left) }) + _cm(shift) + w + sp + rod-t + 0.08cm,
              dy: dy + rod-t - d.h / 2, it)
          } else {
            place(top + right, dx: (if type(ins.right) == length { ins.right } else { _cm(ins.right) }) - _cm(shift) - w - sp - rod-t - 0.08cm - d.w,
              dy: dy + rod-t - d.h / 2, scale(x: -100%, it))
          }
        }
        // room for the part of the flag that reaches into the box
        v(calc.max(0pt, dy + rod-t + h + nk + 0.08cm))
      }
      if watermark != none {
        let wc = resolve-wm-colour(watermark-colour, colour)
        paint-watermark(watermark, colour: wc.transparentize(50%),
          angle: watermark-angle, size: watermark-size)
      }
      set text(dir: body-dir)
      set align(start)
      body
    },
  )
}
