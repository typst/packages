// ===========================================================================
//  faboxyst/cover.typ — full-page book covers, after the TikZ originals.
//
//    #book-cover(style: "guilloche", …)  royal navy: spiralling lace, diagonal
//                                       grid, rosette seal, silver edge strip
//    #book-cover(style: "wedges",   …)   Boussaada: checker ground, big paper
//                                       wedges, white rounded title cards
//    #book-cover(style: "spine",    …)   a coloured spine band with rings and
//                                       a double-ruled panel for the title
//    #book-cover(style: "scatter",  …)   night teal: ghost rosettes, star dust,
//                                       a gold rule and a cloud of 3D dice
//
//  A cover paints the WHOLE page: drop it on a fresh page (pagebreak first if
//  needed). It reads the page size and the margins from the context, so it
//  bleeds to the paper edge whatever the margins are. Under RTL every
//  anchored element — series line, title block, seal, footer, spine band —
//  moves to the mirrored edge.
// ===========================================================================

#import "fabox.typ": is-rtl
#import "lace.typ": lace as lace-pattern

#let _cm(x) = if type(x) == length { x } else { x * 1cm }

/// polar helper: degrees, maths orientation, centimetres out
#let _pol(cx, cy, r, deg) = (
  cx + r * calc.cos(deg * 1deg),
  cy - r * calc.sin(deg * 1deg),
)

/// A full-page book cover.
///
///   title       the book's title
///   subtitle    a line under the title (the pill on "spine")
///   author      the author line
///   series      the collection line (top corner on "guilloche")
///   level       a second small line (spine / wedges cards)
///   year        a third small line (the seal on "guilloche")
///   publisher   the footer's bold line ("guilloche")
///   place-line  the footer's small line (town, press, …)
///   badge       a short glyph for the corner seal ("medallion", "compass")
///   badge-label a tiny line over it ("medallion", "compass")
///   badge-note  a tiny line under it ("compass")
///   lead-in     a small line above the title ("compass"), or under the
///               subtitle in the dark band ("openbook")
///   page-a      the open book's leading page header ("openbook")
///   page-b      its trailing page header ("openbook")
///   topics      the footer's trailing list ("compass")
///   formula     the line under the inset graph ("compass")
///   note        a last italic line at the foot ("medallion")
///   author-label the small line over the author; auto follows the direction
///   lace        the guilloche's line family: "spiral" (the banknote
///               whirl), "engine" (barleycorn circles and spokes),
///               "braid" (woven cubic waves) or "moire" (interfering rings)
///   style       "guilloche" | "wedges" | "spine" | "medallion" |
///               "compass" | "openbook" | "sunburst" | "dice" |
///               "scatter"
///   colour      the dominant paint; auto = a per-style default
///   accent      the second paint; auto = a per-style default
///   direction   auto follows the document; force with ltr / rtl
/// Pip layouts for one die face, 1 to 6, in (u, v) face coordinates.
#let _pips6(n) = if n == 1 { ((0.5, 0.5),) } else if n == 2 {
  ((0.3, 0.3), (0.7, 0.7))
} else if n == 3 {
  ((0.28, 0.28), (0.5, 0.5), (0.72, 0.72))
} else if n == 4 {
  ((0.3, 0.3), (0.7, 0.3), (0.3, 0.7), (0.7, 0.7))
} else if n == 5 {
  ((0.28, 0.28), (0.72, 0.28), (0.5, 0.5), (0.28, 0.72), (0.72, 0.72))
} else {
  ((0.3, 0.25), (0.7, 0.25), (0.3, 0.5), (0.7, 0.5), (0.3, 0.75),
    (0.7, 0.75))
}

/// One 3D die: top, left and right faces in three tones, round pips
/// mapped bilinearly onto each face, and a ground shadow when asked.
#let _die3d(dx, dy, w, h, rot, tc, lc, rc, nt, nl, nr, pipc,
            shadow: none) = place(top + left,
  dx: dx, dy: dy, rotate(rot, box(width: w, height: h, {
    let edge = (paint: lc.darken(35%), thickness: 0.6pt)
    if shadow != none {
      place(top + left, dx: w * 0.14, dy: h * 0.98,
        ellipse(width: w * 0.88, height: h * 0.17, fill: shadow))
    }
    place(top + left, polygon(fill: tc, stroke: edge,
      (w * 0.5, 0cm), (w, h * 0.25), (w * 0.5, h * 0.5), (0cm, h * 0.25)))
    place(top + left, polygon(fill: lc, stroke: edge,
      (0cm, h * 0.25), (w * 0.5, h * 0.5), (w * 0.5, h), (0cm, h * 0.75)))
    place(top + left, polygon(fill: rc, stroke: edge,
      (w * 0.5, h * 0.5), (w, h * 0.25), (w, h * 0.75), (w * 0.5, h)))
    for p in _pips6(nt) {
      place(top + left,
        dx: w * 0.5 + (p.at(0) - 0.5) * w * 0.5 - (p.at(1) - 0.5) * w * 0.5 - w * 0.055,
        dy: h * 0.25 + (p.at(0) - 0.5) * h * 0.25 + (p.at(1) - 0.5) * h * 0.25 - h * 0.055,
        circle(radius: w * 0.055, fill: pipc))
    }
    for p in _pips6(nl) {
      place(top + left,
        dx: p.at(0) * w * 0.5 - w * 0.055,
        dy: h * 0.25 + p.at(0) * h * 0.25 + p.at(1) * h * 0.5 - w * 0.055,
        circle(radius: w * 0.055, fill: pipc))
    }
    for p in _pips6(nr) {
      place(top + left,
        dx: w * 0.5 + p.at(0) * w * 0.5 - w * 0.055,
        dy: h * 0.5 - p.at(0) * h * 0.25 + p.at(1) * h * 0.5 - w * 0.055,
        circle(radius: w * 0.055, fill: pipc))
    }
  })))

#let book-cover(
  title: none,
  subtitle: none,
  author: none,
  series: none,
  level: none,
  year: none,
  publisher: none,
  place-line: none,
  badge: none,
  badge-label: none,
  badge-note: none,
  lead-in: none,
  page-a: none,
  page-b: none,
  topics: none,
  formula: none,
  note: none,
  author-label: auto,
  style: "guilloche",
  lace: "spiral",
  colour: auto,
  accent: auto,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let dir = if rtl { std.rtl } else { ltr }
  let pw = page.width
  let ph = page.height
  let mg = page.margin
  // margins arrive as relative lengths (0% + Xpt) or a dictionary of them
  let rel(v, whole, d) = if type(v) == relative { v.length + v.ratio * whole }
    else if type(v) == length { v } else { d }
  let ml = if type(mg) == dictionary { rel(mg.at("left", default: 1.5cm), pw, 1.5cm) }
    else { rel(mg, pw, 1.5cm) }
  let mt = if type(mg) == dictionary { rel(mg.at("top", default: 1.5cm), ph, 1.5cm) }
    else { rel(mg, ph, 1.5cm) }
  // per-style palettes
  let col = if colour != auto { colour }
    else if style == "wedges" { rgb("#0D6C58") }
    else if style == "spine" { rgb("#0E7A5F") }
    else if style == "medallion" { rgb("#4A2A18") }
    else if style == "compass" { rgb("#3830AD") }
    else if style == "openbook" { rgb("#173740") }
    else if style == "sunburst" { rgb("#317F24") }
    else if style == "dice" { rgb("#122035") }
    else if style == "scatter" { rgb("#081D2C") }
    else { rgb("#0F2341") }
  let acc = if accent != auto { accent }
    else if style == "wedges" { rgb("#F6C324") }
    else if style == "spine" { rgb("#FBBF24") }
    else if style == "medallion" { rgb("#E8891D") }
    else if style == "compass" { rgb("#A02272") }
    else if style == "openbook" { rgb("#DF6A25") }
    else if style == "sunburst" { rgb("#FFE557") }
    else if style == "dice" { rgb("#C2AE7D") }
    else if style == "scatter" { rgb("#C4B47F") }
    else { rgb("#C9A227") }
  let lead = if rtl { right } else { left }
  let trail = if rtl { left } else { right }

  // =========================================================================
  if style == "guilloche" {
    place(top + left, dx: -ml, dy: -mt, block(width: pw, height: ph, clip: true, {
      set text(dir: dir)
      place(top + left, rect(width: pw, height: ph, fill: col))
      // 1. the lace: one of the four guilloche line families. The spiral
      //    whirl is dense enough at a hairline; the other three need a
      //    firmer hand to read at all.
      let lp = if lace == "spiral" { (white.transparentize(85%), 0.1pt) }
               else { (white.transparentize(76%), 0.35pt) }
      place(top + left,
        lace-pattern(lace, pw, ph, lp.at(0), thickness: lp.at(1)))
      // 2. the diagonal guilloche grid
      let gops = ()
      for p in range(0, 101, step: 2) {
        gops += (
          curve.move((0pt, -p * 0.3cm), ),
          curve.line((pw + p * 0.2cm, ph)),
          curve.move((pw, -p * 0.3cm)),
          curve.line((-p * 0.2cm, ph)),
        )
      }
      place(top + left,
        curve(stroke: (paint: white.transparentize(90%), thickness: 0.3pt), ..gops))
      // 3. a radial wash for the paper's depth
      place(top + left, dx: pw / 2 - 7.5cm, dy: ph / 2 - 7.5cm,
        circle(radius: 7.5cm, fill: gradient.radial(
          (white.transparentize(93%), 0%), (white.transparentize(100%), 100%))))
      // 4. the silver strip along the leading edge
      place(top + left, dx: if rtl { pw - 0.9cm } else { 0.8cm },
        rect(width: 0.1cm, height: ph, fill: gradient.linear(
          (white.transparentize(40%), 0%), (col.transparentize(60%), 100%),
          angle: if rtl { 180deg } else { 0deg })))
      // 5. the texts
      if series != none {
        place(top + lead, dx: if rtl { -1.5cm } else { 1.5cm }, dy: 1.5cm,
          text(size: 13pt, fill: white.transparentize(20%), tracking: 1.2pt, series))
      }
      let ty = ph / 2 - 4.5cm
      place(top + lead, dx: if rtl { -2cm } else { 2cm }, dy: ty,
        block(width: pw * 0.78, {
          set text(dir: dir)
          set align(start)
          text(size: 44pt, weight: "bold", fill: white, title)
          if subtitle != none {
            linebreak()
            text(size: 22pt, fill: white.transparentize(15%), style: "italic", subtitle)
          }
          v(0.5cm)
          line(length: 8cm, stroke: (paint: white.transparentize(20%), thickness: 3pt))
        }))
      if author != none {
        place(top + lead, dx: if rtl { -2cm } else { 2cm }, dy: ty + 4.6cm,
          text(size: 26pt, fill: white, author))
      }
      // the rosette seal at the trailing corner
      if year != none {
        place(top + trail, dx: if rtl { 1.5cm } else { -1.5cm }, dy: 1.5cm,
          box(width: 2.6cm, height: 2.6cm, {
            for a in range(0, 360, step: 20) {
              place(center + horizon,
                rotate(a * 1deg, ellipse(width: 1.7cm, height: 0.42cm,
                  stroke: (paint: white.transparentize(70%), thickness: 0.4pt),
                  fill: none)))
            }
            place(center + horizon, align(center, stack(dir: ttb,
              text(size: 8pt, weight: "bold", fill: white, year),
              text(size: 6pt, fill: white.transparentize(15%), [EDITION]))))
          }))
      }
      // the footer
      if publisher != none or place-line != none {
        place(bottom + trail, dx: if rtl { 1.5cm } else { -1.5cm }, dy: -1.5cm,
          block(width: 8cm, {
            set text(dir: dir)
            set align(end)
            line(length: 5cm, stroke: (paint: white, thickness: 0.8pt))
            v(0.3cm)
            if publisher != none {
              text(size: 15pt, weight: "bold", fill: white, publisher)
            }
            if place-line != none {
              v(0.1cm)
              text(size: 10pt, fill: white.transparentize(15%), place-line)
            }
          }))
      }
    }))
  } else if style == "wedges" {
    place(top + left, dx: -ml, dy: -mt, block(width: pw, height: ph, clip: true, {
      set text(dir: dir)
      place(top + left, rect(width: pw, height: ph, fill: luma(247)))
      place(top + left, rect(width: pw, height: ph, fill: tiling(
        size: (1.1cm, 1.1cm),
        box(width: 1.1cm, height: 1.1cm, {
          place(top + left, rect(width: 0.55cm, height: 0.55cm, fill: luma(238)))
          place(top + left, dx: 0.55cm, dy: 0.55cm,
            rect(width: 0.55cm, height: 0.55cm, fill: luma(238)))
        }))))
      // the paper wedges, in page-centred centimetres (tikz y up -> y down)
      let U = 2.1cm
      let P = (x, y) => (x * U, -y * U)
      let wedge(fill, shadow-dx, pts) = {
        let q = pts.map(p => P(p.at(0), p.at(1)))
        place(top + left, dx: shadow-dx, dy: 0.25cm,
          polygon(fill: luma(60).transparentize(86%), stroke: none, ..q))
        place(top + left,
          polygon(fill: fill, stroke: none, ..q))
      }
      place(top + left, dx: pw / 2, dy: ph / 2, {
        wedge(acc, -0.2cm, ((-1.5, -9), (10, 2.5), (10, -9)))
        wedge(white, 0.2cm, ((1.5, -9), (-10, 2.5), (-10, -9)))
        wedge(acc, 0.2cm, ((-10, -4), (2, 8), (-2, 8), (-10, 0)))
        wedge(white, 0.2cm, ((-10, 0), (-2, 8), (-10, 8)))
        wedge(col, 0pt, ((0, 3.5), (-7.5, 11), (7.5, 11)))
        wedge(white, -0.2cm, ((-1.5, 8), (10, -3.5), (10, 8)))
      })
      // the cards: a soft white rounded block with a blurred shadow
      let card(w, body) = {
        // measure first: a placed shadow cannot size itself off the card
        let m = measure(block(width: w, fill: white.transparentize(6%),
          radius: 16pt, inset: (x: 0.7cm, y: 0.55cm), body))
        block(width: w, height: m.height, {
          place(top + left, dx: 0pt, dy: 0.30cm,
            rect(width: w, height: m.height, radius: 16pt,
              fill: luma(50).transparentize(80%)))
          place(top + left,
            block(width: w, fill: white.transparentize(6%), radius: 16pt,
              inset: (x: 0.7cm, y: 0.55cm), body))
        })
      }
      let row(icon, txt) = grid(columns: (auto, 1fr), column-gutter: 0.6cm,
        align(center + horizon, text(fill: col, size: 1.2em, icon)),
        { set text(dir: dir); set align(start); txt })
      let cards = ()
      if author != none {
        cards += (card(9.5cm, row([✎], text(size: 14pt, weight: "bold",
          fill: luma(30), author))),)
      }
      if level != none {
        cards += (card(9.5cm, row([◆], text(size: 14pt,
          fill: luma(30), level))),)
      }
      if year != none {
        cards += (card(9.5cm, row([▦], text(size: 14pt,
          fill: luma(30), year))),)
      }
      place(top + left, dx: (pw - 12.5cm) / 2, dy: ph / 2 - 5.5cm,
        block(width: 12.5cm, {
          set align(center)
          card(12.5cm, {
            set text(dir: dir)
            set align(start)
            grid(columns: (auto, 1fr), column-gutter: 0.7cm,
              align(center + horizon, text(fill: col, size: 1.6em, [❖])),
              {
                set text(dir: dir)
                set align(start)
                text(size: 28pt, weight: "bold", fill: col, title)
              },
            )
            if subtitle != none {
              v(0.25cm)
              set align(start)
              text(size: 15pt, fill: luma(40), subtitle)
            }
          })
          if cards.len() > 0 {
            v(0.5cm)
            stack(dir: ttb, spacing: 0.45cm, ..cards)
          }
        }))
    }))
  } else if style == "medallion" {
    // a cream medallion on a brown ground, ringed in orange, carrying the
    // title and a schoolyard of instruments on a gold pedestal
    let cream = rgb("#F5E7C8")
    let brown = col
    let orng = acc
    place(top + left, dx: -ml, dy: -mt, block(width: pw, height: ph, clip: true, {
      set text(dir: dir)
      place(top + left, rect(width: pw, height: ph, fill: brown))
      place(top + left, dy: ph - 7cm, rect(width: pw, height: 7cm,
        fill: gradient.linear((brown.transparentize(100%), 0%),
          (brown.darken(35%), 100%), angle: 90deg)))
      let R = calc.min(pw * 0.46, ph * 0.30)
      let cx = pw / 2
      let cy = ph * 0.42
      // the orange ring peeks out under the cream disc
      place(top + left, dx: cx - R - 0.30cm, dy: cy - R + 0.30cm,
        circle(radius: R + 0.30cm, fill: orng))
      place(top + left, dx: cx - R, dy: cy - R,
        circle(radius: R, fill: cream))
      // faint chalk doodles on the brown
      let doodle(dx, dy, rot, body) = place(top + left, dx: dx, dy: dy,
        rotate(rot, text(size: 11pt, fill: cream.transparentize(72%), body)))
      doodle(0.9cm, 3.4cm, -16deg, [= −1])
      doodle(0.7cm, cy - 0.5cm, 10deg, [√−1])
      doodle(pw - 1.6cm, cy - 1.2cm, -8deg, [π])
      doodle(pw - 2.6cm, cy + 0.6cm, 12deg, [x + iy])
      doodle(pw - 1.8cm, ph - 8.5cm, -10deg, [%])
      place(top + left, dx: pw - 3.4cm, dy: cy - 0.2cm,
        curve(stroke: (paint: cream.transparentize(70%), thickness: 0.8pt),
          curve.move((0cm, 0cm)), curve.line((1.2cm, 0cm)),
          curve.line((1.2cm, 1.2cm)), curve.line((0cm, 1.2cm)), curve.close(),
          curve.move((0.35cm, -0.35cm)), curve.line((1.55cm, -0.35cm)),
          curve.line((1.55cm, 0.85cm)), curve.line((1.2cm, 1.2cm)),
          curve.move((1.55cm, -0.35cm)), curve.line((1.2cm, 0cm)),
          curve.move((0cm, 0cm)), curve.line((0.35cm, -0.35cm))))
      // the series line and the corner seal
      if series != none {
        place(top + left, dy: 1.0cm, box(width: pw, align(center,
          text(size: 15pt, weight: "bold", fill: cream, series))))
      }
      if badge != none {
        place(top + lead,
          dx: if rtl { -1.1cm } else { 1.1cm }, dy: 1.1cm,
          box(width: 2.3cm, height: 2.3cm, {
            place(top + left, circle(radius: 1.15cm, fill: white,
              stroke: (paint: cream, thickness: 1.2pt)))
            place(top + left, dx: 0.25cm, dy: 0.25cm,
              circle(radius: 0.9cm, fill: none,
                stroke: (paint: orng, thickness: 0.8pt)))
            place(center + horizon, align(center, stack(dir: ttb,
              text(size: 20pt, fill: orng, style: "italic", badge),
              if badge-label != none {
                text(size: 6.5pt, fill: brown, badge-label)
              })))
          }))
      }
      // title, subtitle and the notched ribbon
      place(top + left, dx: cx - R + 1.2cm, dy: cy - R + 1.5cm,
        block(width: 2 * R - 2.4cm, {
          set text(dir: dir)
          set align(center)
          text(size: 38pt, weight: "bold", fill: brown.darken(25%), title)
          if subtitle != none {
            v(0.15cm)
            text(size: 28pt, weight: "bold", fill: orng, subtitle)
          }
          v(0.5cm)
          if level != none or year != none {
            let rw = calc.min(11cm, 2 * R - 3cm)
            let rh = 1.05cm
            let nk = 0.35cm
            box(width: rw, height: rh, {
              place(top + left, polygon(fill: brown.darken(15%),
                (0cm, 0cm), (rw, 0cm), (rw - nk, rh / 2), (rw, rh),
                (0cm, rh), (nk, rh / 2)))
              place(top + left, box(width: rw, height: rh,
                align(center + horizon, text(size: 12.5pt, weight: "bold",
                  fill: cream, [#if level != none { level }#if level != none and year != none { h(0.7cm) }#if year != none { year }]))))
            })
          }
        }))
      // the gold pedestal and the instruments
      let py = cy + R * 0.80
      let ped-w = calc.min(pw - 1.2cm, R * 1.9)
      place(top + left, dx: cx - ped-w / 2, dy: py + 0.22cm,
        ellipse(width: ped-w, height: 1.4cm, fill: rgb("#B8862E")))
      place(top + left, dx: cx - ped-w / 2, dy: py,
        ellipse(width: ped-w, height: 1.4cm, fill: rgb("#D9A441")))
      // every instrument rests ON the pedestal, feet at `base`
      let base = py + 0.55cm
      let tool(dx, dy, rot, body) = place(top + left, dx: dx, dy: dy,
        rotate(rot, body))
      let cross(c) = box(width: 1.05cm, height: 1.05cm, {
        place(top + left, dx: 0.38cm,
          rect(width: 0.30cm, height: 1.05cm, fill: c, radius: 0.08cm))
        place(top + left, dy: 0.38cm,
          rect(width: 1.05cm, height: 0.30cm, fill: c, radius: 0.08cm))
      })
      // the ruler
      tool(cx - 5.9cm, base - 7.0cm, 7deg, box(width: 1.7cm, height: 7cm, {
        place(top + left, rect(width: 1.7cm, height: 7cm,
          fill: rgb("#F2A03D"), stroke: (paint: rgb("#C97F1F"), thickness: 0.8pt),
          radius: 0.15cm))
        place(top + left, dx: 0.55cm, dy: 0.45cm,
          circle(radius: 0.18cm, fill: rgb("#C97F1F")))
        for i in range(0, 13) {
          let w = if calc.rem(i, 2) == 0 { 0.55cm } else { 0.35cm }
          place(top + left, dx: 1.62cm - w, dy: 1.15cm + i * 0.44cm,
            line(length: w, stroke: (paint: rgb("#8A5A10"), thickness: 0.6pt)))
        }
      }))
      // the pencil
      tool(cx - 7.6cm, base - 5.4cm, 13deg, box(width: 0.52cm, height: 5.4cm, {
        place(top + left, rect(width: 0.52cm, height: 0.45cm,
          fill: rgb("#D96A6A"), radius: (top: 0.12cm)))
        place(top + left, dy: 0.45cm, rect(width: 0.52cm, height: 4.1cm,
          fill: rgb("#F2A03D"), stroke: (paint: rgb("#C97F1F"), thickness: 0.6pt)))
        place(top + left, polygon(fill: rgb("#E8C79A"),
          (0cm, 4.55cm), (0.52cm, 4.55cm), (0.26cm, 5.4cm)))
        place(top + left, polygon(fill: rgb("#5A4632"),
          (0.16cm, 5.08cm), (0.36cm, 5.08cm), (0.26cm, 5.4cm)))
      }))
      // the compass
      tool(cx - 1.7cm, base - 7.6cm, 0deg, box(width: 3.4cm, height: 7.6cm, {
        place(top + left, dx: 1.40cm,
          rect(width: 0.3cm, height: 0.8cm, fill: rgb("#6E747A"), radius: 0.1cm))
        place(top + left, polygon(fill: rgb("#C7CBCF"),
          stroke: (paint: rgb("#6E747A"), thickness: 0.5pt),
          (1.5cm, 0.9cm), (1.8cm, 0.95cm), (2.7cm, 6.9cm), (2.4cm, 7.0cm)))
        place(top + left, polygon(fill: rgb("#C7CBCF"),
          stroke: (paint: rgb("#6E747A"), thickness: 0.5pt),
          (1.6cm, 0.9cm), (1.3cm, 0.95cm), (0.4cm, 6.9cm), (0.7cm, 7.0cm)))
        place(top + left,
          line(start: (0.95cm, 3.6cm), end: (2.15cm, 3.6cm),
            stroke: (paint: rgb("#6E747A"), thickness: 0.7pt)))
        place(top + left, polygon(fill: rgb("#5A4632"),
          (2.4cm, 7.0cm), (2.7cm, 6.9cm), (2.6cm, 7.5cm)))
        place(top + left, polygon(fill: rgb("#5A4632"),
          (0.7cm, 7.0cm), (0.4cm, 6.9cm), (0.5cm, 7.5cm)))
        // the hinge, drawn last so it sits IN FRONT of the arms it joins
        place(top + left, dx: 1.13cm, dy: 0.63cm,
          circle(radius: 0.42cm, fill: rgb("#9AA0A6"),
            stroke: (paint: rgb("#6E747A"), thickness: 0.7pt)))
        place(top + left, dx: 1.43cm, dy: 0.93cm,
          circle(radius: 0.12cm, fill: rgb("#6E747A")))
      }))
      // the protractor
      tool(cx + 1.9cm, base - 3.1cm, -5deg, box(width: 5.6cm, height: 3.1cm, {
        let pts = ()
        for i in range(0, 19) {
          let a = 180 - i * 10
          pts += ((2.8cm + 2.8cm * calc.cos(a * 1deg),
                   2.8cm - 2.8cm * calc.sin(a * 1deg)),)
        }
        for i in range(0, 19).rev() {
          let a = 180 - i * 10
          pts += ((2.8cm + 1.5cm * calc.cos(a * 1deg),
                   2.8cm - 1.5cm * calc.sin(a * 1deg)),)
        }
        place(top + left, polygon(fill: rgb("#2E9BD6"), stroke: none, ..pts))
        for i in range(0, 13) {
          let a = 180 - i * 15
          place(top + left,
            line(start: (2.8cm + 2.75cm * calc.cos(a * 1deg),
                         2.8cm - 2.75cm * calc.sin(a * 1deg)),
                 end: (2.8cm + 2.35cm * calc.cos(a * 1deg),
                       2.8cm - 2.35cm * calc.sin(a * 1deg)),
                 stroke: (paint: white, thickness: 0.5pt)))
        }
        place(top + left, dx: 2.55cm, dy: 2.55cm,
          circle(radius: 0.25cm, fill: rgb("#1F7BAD")))
        // the straight edge the half-disc sits on
        place(top + left, dy: 2.62cm,
          rect(width: 5.6cm, height: 0.48cm, fill: rgb("#2E9BD6"),
            radius: (bottom: 0.10cm)))
        place(top + left, dy: 2.62cm,
          rect(width: 5.6cm, height: 0.14cm, fill: rgb("#1F7BAD")))
      }))
      // the cylinder
      tool(cx + 6.1cm, base - 2.7cm, 0deg, box(width: 1.9cm, height: 2.7cm, {
        place(top + left, dy: 0.35cm,
          rect(width: 1.9cm, height: 1.95cm, fill: rgb("#5BC8C0")))
        place(top + left, dy: 1.95cm,
          ellipse(width: 1.9cm, height: 0.72cm, fill: rgb("#3FA8A0")))
        place(top + left,
          ellipse(width: 1.9cm, height: 0.72cm, fill: rgb("#8FE0D8")))
      }))
      // two little crosses adrift
      tool(cx + 0.85cm, base - 4.5cm, 14deg, cross(orng))
      tool(cx + 5.0cm, base - 4.7cm, 45deg, cross(rgb("#2E9BD6")))
      // the author band with its pi pastille
      if author != none {
        let lbl = if author-label != auto { author-label }
          else if rtl { [إعداد الأستاذ] } else { [Par] }
        place(top + left, dx: (pw - 14cm) / 2, dy: ph - 4.7cm,
          block(width: 14cm, height: 1.75cm, {
            place(top + left, rect(width: 14cm, height: 1.75cm,
              radius: 0.45cm, fill: cream,
              stroke: (paint: brown.darken(25%), thickness: 0.8pt)))
            place(top + left, dx: if rtl { 12.35cm } else { 0.55cm }, dy: 0.22cm,
              box(width: 1.3cm, height: 1.3cm, {
                place(top + left, circle(radius: 0.65cm, fill: white,
                  stroke: (paint: brown, thickness: 1pt)))
                place(center + horizon,
                  text(size: 13pt, fill: brown, [π]))
              }))
            place(top + left, dx: 2.3cm, dy: 0.28cm, block(width: 9.4cm, {
              set text(dir: dir)
              set align(center)
              text(size: 9pt, fill: brown, lbl)
              v(0.02cm)
              text(size: 15pt, weight: "bold", fill: brown.darken(25%), author)
            }))
          }))
      }
      if place-line != none {
        place(top + left, dy: ph - 2.35cm, box(width: pw, align(center,
          text(size: 9.5pt, fill: cream, place-line))))
      }
      if note != none {
        place(top + left, dy: ph - 1.6cm, box(width: pw, align(center,
          text(size: 9pt, style: "italic", fill: orng, note))))
      }
    }))
  } else if style == "compass" {
    // indigo ground, diagonal light streaks, a magenta header card, a year
    // badge, an inset graph and a great compass standing on its ellipse
    let ink = white
    place(top + left, dx: -ml, dy: -mt, block(width: pw, height: ph, clip: true, {
      set text(dir: dir)
      place(top + left, rect(width: pw, height: ph,
        fill: gradient.linear(rgb("#3830AD"), rgb("#4C2395"))))
      // diagonal streaks of light
      place(top + left, dx: -3cm, dy: ph * 0.28,
        rotate(-24deg, rect(width: pw * 1.7, height: 2.8cm,
          fill: rgb("#4434AE"))))
      place(top + left, dx: -3cm, dy: ph * 0.66,
        rotate(-24deg, rect(width: pw * 1.7, height: 1.5cm,
          fill: rgb("#4434AE"))))
      place(top + left,
        line(start: (0pt, ph * 0.78), end: (pw, ph * 0.34),
          stroke: (paint: white.transparentize(70%), thickness: 0.7pt)))
      // the header card, hung from the top on the leading side
      let cw = pw * 0.62
      let cdx = if rtl { pw - cw } else { 0pt }
      place(top + left, dx: cdx,
        block(width: cw, radius: (bottom: 14pt), fill: acc,
          inset: (x: 0.6cm, y: 0.45cm), {
            set text(dir: dir)
            set align(center)
            if series != none {
              text(size: 19pt, weight: "bold", fill: ink, series)
            }
            if note != none {
              v(0.12cm)
              text(size: 9.5pt, fill: ink.transparentize(15%), note)
            }
          }))
      // the year badge at the trailing top corner
      if badge != none {
        place(top + trail, dx: if rtl { 1.2cm } else { -1.2cm }, dy: 2.4cm,
          box(width: 3cm, height: 3cm, {
            place(top + left, circle(radius: 1.5cm,
              fill: gradient.radial((acc.lighten(30%), 0%), (acc, 55%),
                (acc.darken(30%), 100%)),
              stroke: (paint: white.transparentize(30%), thickness: 1.2pt)))
            place(top + left, dx: 0.28cm, dy: 0.28cm,
              circle(radius: 1.22cm, fill: none,
                stroke: (paint: white.transparentize(40%), thickness: 0.8pt)))
            place(center + horizon, align(center, stack(dir: ttb,
              if badge-label != none {
                text(size: 7.5pt, fill: ink.transparentize(10%), badge-label)
              },
              text(size: 24pt, weight: "bold", fill: ink, badge),
              if badge-note != none {
                text(size: 7.5pt, fill: ink.transparentize(10%), badge-note)
              })))
          }))
      }
      // lead-in, title, subtitle, rule, level — all centred
      place(top + left, dy: ph * 0.165, block(width: pw, {
        set text(dir: dir)
        set align(center)
        if lead-in != none {
          text(size: 14pt, fill: ink.transparentize(10%), lead-in)
          v(0.55cm)
        }
        text(size: 46pt, weight: "bold", fill: ink, title)
        if subtitle != none {
          v(0.35cm)
          text(size: 21pt, weight: "bold", fill: ink, subtitle)
        }
        v(0.5cm)
        align(center, line(length: 9cm,
          stroke: (paint: white.transparentize(40%), thickness: 0.8pt)))
        v(0.35cm)
        if level != none {
          text(size: 10.5pt, fill: ink.transparentize(15%), level)
        }
      }))
      // the inset graph at the trailing side
      let gx = if rtl { 1.3cm } else { pw - 8.3cm }
      let gy = ph * 0.565
      let xa = gx + 4.2cm
      place(top + left, dx: gx, dy: gy, box(width: 7cm, height: 6.4cm, {
        let w60 = rgb("#C8EFCF").transparentize(30%)
        // a faint square grid, like graph paper
        for gi in range(0, 13) {
          place(top + left, line(start: (0.5cm + gi * 0.5cm, 0.4cm),
            end: (0.5cm + gi * 0.5cm, 5.6cm),
            stroke: (paint: w60.transparentize(72%), thickness: 0.4pt)))
        }
        for gj in range(0, 11) {
          place(top + left, line(start: (0.5cm, 0.4cm + gj * 0.52cm),
            end: (6.7cm, 0.4cm + gj * 0.52cm),
            stroke: (paint: w60.transparentize(72%), thickness: 0.4pt)))
        }
        // axes with arrowheads
        place(top + left,
          line(start: (0.5cm, 3.4cm), end: (6.7cm, 3.4cm),
            stroke: (paint: w60, thickness: 0.8pt)))
        place(top + left, polygon(fill: w60,
          (6.7cm, 3.28cm), (6.7cm, 3.52cm), (6.95cm, 3.4cm)))
        place(top + left,
          line(start: (3.4cm, 5.6cm), end: (3.4cm, 0.5cm),
            stroke: (paint: w60, thickness: 0.8pt)))
        place(top + left, polygon(fill: w60,
          (3.28cm, 0.5cm), (3.52cm, 0.5cm), (3.4cm, 0.25cm)))
        // the dashed asymptote and the two branches
        place(top + left,
          line(start: (xa - gx, 0.7cm), end: (xa - gx, 5.4cm),
            stroke: (paint: white.transparentize(55%), thickness: 0.6pt,
              dash: (2.5pt, 2.5pt))))
        place(top + left,
          curve(stroke: (paint: w60, thickness: 1.1pt),
            curve.move((xa - gx + 0.35cm, 0.8cm)),
            curve.cubic((xa - gx + 0.55cm, 1.7cm), (xa - gx + 1.3cm, 2.3cm),
              (xa - gx + 2.5cm, 2.75cm))))
        place(top + left,
          curve(stroke: (paint: w60, thickness: 1.1pt),
            curve.move((xa - gx - 0.35cm, 5.3cm)),
            curve.cubic((xa - gx - 0.55cm, 4.4cm), (xa - gx - 1.3cm, 3.8cm),
              (xa - gx - 2.5cm, 3.5cm))))
        place(top + left, dx: xa - gx + 1.35cm, dy: 1.75cm,
          circle(radius: 0.10cm, fill: white))
        if formula != none {
          place(top + left, dx: 0.9cm, dy: 5.85cm,
            text(size: 9.5pt, fill: ink.transparentize(10%), formula))
        }
      }))
      // the great compass, standing on its magenta ellipse
      let cxp = if rtl { pw * 0.70 } else { pw * 0.30 }
      let phy = ph * 0.80
      // one plateau ellipse — its top face — riding on its rim; the
      // steel points of the compass stand exactly at its two foci
      place(top + left, dx: cxp - 3.6cm, dy: phy + 0.34cm,
        ellipse(width: 7.2cm, height: 1.7cm, fill: acc.darken(22%)))
      place(top + left, dx: cxp - 3.6cm, dy: phy,
        ellipse(width: 7.2cm, height: 1.7cm, fill: acc.lighten(4%)))
      let L = 9.6cm
      // the steel points stand on the foci of the plateau's top face:
      // for that ellipse (semi-axes 3.6cm and 0.85cm),
      // c = sqrt(a*a - b*b) = 3.50cm, so the half-spread of the arms is c
      let sp = calc.sqrt(3.6 * 3.6 - 0.85 * 0.85) * 1cm
      // hang the compass from the plateau so that the tips of the points
      // land on the top face's major axis, exactly at the two foci
      let hy = phy + 0.85cm - L - 1.55cm
      // everything hangs off one axis: hx, the centre of the box, of the
      // arms' apex, of the hinge circle and of its handle embout — and the
      // box itself is centred on the plateau ellipse below
      let hx = 3.4cm
      let metal = gradient.linear(rgb("#EAF6EE"), rgb("#6E9C86"), angle: 90deg)
      place(top + left, dx: cxp - hx, dy: hy,
        box(width: 2 * hx, height: L + 1.2cm, {
          // the handle embout, centred on the hinge axis
          place(top + left, dx: hx - 0.17cm,
            rect(width: 0.34cm, height: 1.0cm, fill: rgb("#5E8C7A"),
              radius: 0.12cm))
          // the two arms, symmetric about hx, tapering to their points
          place(top + left, polygon(fill: metal,
            stroke: (paint: rgb("#4E7A68"), thickness: 0.5pt),
            (hx - 0.32cm, 1.0cm), (hx + 0.06cm, 1.15cm),
            (hx - sp + 0.17cm, 1.0cm + L), (hx - sp - 0.17cm, 1.0cm + L - 0.12cm)))
          place(top + left, polygon(fill: metal,
            stroke: (paint: rgb("#4E7A68"), thickness: 0.5pt),
            (hx + 0.32cm, 1.0cm), (hx - 0.06cm, 1.15cm),
            (hx + sp - 0.17cm, 1.0cm + L), (hx + sp + 0.17cm, 1.0cm + L - 0.12cm)))
          // the crossbar
          place(top + left, dx: hx - sp * 0.55, dy: 1.0cm + L * 0.55,
            rect(width: sp * 1.1, height: 0.30cm, radius: 0.12cm,
              fill: rgb("#8FB8A4"), stroke: (paint: rgb("#4E7A68"), thickness: 0.5pt)))
          // the hinge circle, centred on the arms' apex, in front
          place(top + left, dx: hx - 0.46cm, dy: 0.62cm,
            circle(radius: 0.46cm, fill: rgb("#BFDCCB"),
              stroke: (paint: rgb("#4E7A68"), thickness: 0.7pt)))
          place(top + left, dx: hx - 0.14cm, dy: 0.94cm,
            circle(radius: 0.14cm, fill: rgb("#4E7A68")))
          // the steel points, under the feet centres
          place(top + left, polygon(fill: rgb("#3E3E46"),
            (hx - sp - 0.17cm, 1.0cm + L - 0.12cm),
            (hx - sp + 0.17cm, 1.0cm + L),
            (hx - sp, 1.0cm + L + 0.55cm)))
          place(top + left, polygon(fill: rgb("#3E3E46"),
            (hx + sp + 0.17cm, 1.0cm + L - 0.12cm),
            (hx + sp - 0.17cm, 1.0cm + L),
            (hx + sp, 1.0cm + L + 0.55cm)))
        }))
      // the author block on the leading side
      if author != none {
        place(top + lead, dx: if rtl { -1.5cm } else { 1.5cm }, dy: ph * 0.795,
          block(width: pw * 0.40, {
            set text(dir: dir)
            set align(start)
            if author-label != auto and author-label != none {
              text(size: 10pt, fill: ink.transparentize(15%), author-label)
              v(0.1cm)
            }
            text(size: 17pt, weight: "bold", fill: ink, author)
            if place-line != none {
              v(0.18cm)
              text(size: 9.5pt, fill: ink.transparentize(15%), place-line)
            }
          }))
      }
      // the footer band
      place(top + left, dy: ph - 1.5cm,
        rect(width: pw, height: 1.5cm, fill: col.darken(22%)))
      if publisher != none {
        place(top + lead, dx: if rtl { -1.5cm } else { 1.5cm }, dy: ph - 1.05cm,
          text(size: 12.5pt, weight: "bold", fill: ink, publisher))
      }
      if topics != none {
        place(top + trail, dx: if rtl { 1.5cm } else { -1.5cm }, dy: ph - 1.0cm,
          text(size: 9.5pt, fill: ink.transparentize(15%), topics))
      }
    }))
  } else if style == "openbook" {
    // a dark band carrying the title, then a cream ground with an open
    // book: two graphed pages, a bookmark, a formula panel, a footer band
    let body-c = rgb("#F8FAF6")
    let teal = rgb("#187986")
    let mint = rgb("#8DCED6")
    let gold = rgb("#EBD447")
    let pale = rgb("#EAF4F3")
    let band-h = ph * 0.335
    place(top + left, dx: -ml, dy: -mt, block(width: pw, height: ph, clip: true, {
      set text(dir: dir)
      place(top + left, rect(width: pw, height: ph, fill: body-c))
      // the dark band and its accent rule
      place(top + left, rect(width: pw, height: band-h, fill: col))
      place(top + left, dy: band-h, rect(width: pw, height: 0.32cm, fill: acc))
      // outline rings bleeding off the leading top and trailing middle
      place(top + lead, dx: if rtl { 0.9cm } else { -0.9cm }, dy: -0.7cm,
        circle(radius: 2.4cm, fill: none,
          stroke: (paint: teal.transparentize(45%), thickness: 1pt)))
      place(top + trail, dx: if rtl { 1.5cm } else { -1.5cm }, dy: band-h + 1.6cm,
        circle(radius: 1.8cm, fill: none,
          stroke: (paint: teal.transparentize(45%), thickness: 1pt)))
      // the trailing stripe down the ground
      place(top + left, dx: if rtl { 0cm } else { pw - 0.45cm },
        dy: band-h + 0.32cm,
        rect(width: 0.45cm, height: ph - band-h - 2.62cm, fill: teal))
      // band texts, centred
      place(top + left, dy: 1.1cm, block(width: pw, {
        set text(dir: dir)
        set align(center)
        if series != none {
          text(size: 9.5pt, fill: white.transparentize(25%), series)
        }
        v(0.75cm)
        text(size: 40pt, weight: "bold", fill: white, title)
        if subtitle != none {
          v(0.35cm)
          text(size: 17pt, weight: "bold", fill: gold, subtitle)
        }
        if lead-in != none {
          v(0.45cm)
          text(size: 10pt, fill: white.transparentize(15%), lead-in)
        }
      }))
      // the tagline over the book
      if note != none {
        place(top + left, dy: band-h + 0.95cm, block(width: pw, {
          set text(dir: dir)
          set align(center)
          text(size: 10pt, weight: "bold", fill: teal, note)
        }))
      }
      // ---- the open book ----
      let cx = pw / 2
      let pwid = 6.3cm
      let phh = 7.0cm
      let bw = 13.4cm
      let bh = phh + 0.9cm
      let by = band-h + 2.2cm
      // the ground shadow stays flat on the paper
      place(top + left, dx: cx - 7.3cm, dy: by + bh * 0.94 - 0.45cm,
        ellipse(width: 14.6cm, height: 1.5cm, fill: luma(55).transparentize(76%)))
      // one leaf of the book: top and bottom edges arched, so the open
      // pages read as curved surfaces seen in perspective
      let sheet(w, h, fill: none, stroke: none, dy: 0cm) = curve(
        fill: fill, stroke: stroke,
        curve.move((0cm, dy + 0.9cm)),
        curve.cubic((w * 0.25, dy + 0.25cm), (w * 0.75, dy + 0.25cm),
          (w, dy + 0.9cm)),
        curve.line((w, dy + h - 0.15cm)),
        curve.cubic((w * 0.75, dy + h - 1.02cm), (w * 0.25, dy + h - 1.02cm),
          (0cm, dy + h - 0.15cm)),
      )
      let page(dx, header, graph, hcol) = place(top + left, dx: dx, dy: 0.15cm,
        box(width: pwid, height: phh, {
          place(top + left, sheet(pwid, phh, fill: white,
            stroke: (paint: col.transparentize(75%), thickness: 0.6pt),
            dy: 0.15cm))
          if header != none {
            place(top + left, dy: 0.55cm, box(width: pwid, {
              set text(dir: dir)
              set align(center)
              text(size: 8.5pt, weight: "bold", fill: hcol, header)
            }))
          }
          // the graph: axes, one curve, one extra line, a point
          place(top + left, dx: 0.55cm, dy: 1.5cm,
            box(width: 5.2cm, height: 4.6cm, graph))
        }))
      let graph-left = {
        let inkc = teal.transparentize(25%)
        place(top + left, line(start: (0.4cm, 3.6cm), end: (5.0cm, 3.6cm),
          stroke: (paint: inkc, thickness: 0.7pt)))
        place(top + left, line(start: (1.1cm, 4.4cm), end: (1.1cm, 0.4cm),
          stroke: (paint: inkc, thickness: 0.7pt)))
        place(top + left, curve(stroke: (paint: inkc, thickness: 1pt),
          curve.move((1.2cm, 3.9cm)),
          curve.cubic((2.6cm, 3.7cm), (3.6cm, 2.6cm), (4.7cm, 0.9cm))))
        place(top + left, line(start: (2.0cm, 3.35cm), end: (4.5cm, 1.35cm),
          stroke: (paint: acc, thickness: 0.8pt)))
        place(top + left, dx: 3.05cm, dy: 2.4cm,
          circle(radius: 0.10cm, fill: acc))
      }
      let graph-right = {
        let inkc = teal.transparentize(25%)
        place(top + left, line(start: (0.4cm, 3.6cm), end: (5.0cm, 3.6cm),
          stroke: (paint: inkc, thickness: 0.7pt)))
        place(top + left, line(start: (1.1cm, 4.4cm), end: (1.1cm, 0.4cm),
          stroke: (paint: inkc, thickness: 0.7pt)))
        place(top + left, curve(stroke: (paint: inkc, thickness: 1pt),
          curve.move((1.5cm, 0.8cm)),
          curve.cubic((1.8cm, 2.3cm), (2.6cm, 3.0cm), (4.8cm, 3.2cm))))
        place(top + left, line(start: (1.1cm, 3.3cm), end: (4.9cm, 3.3cm),
          stroke: (paint: acc, thickness: 0.7pt, dash: (2.5pt, 2.5pt))))
      }
      // the whole book in one body, then laid down: foreshortened,
      // skewed and slightly rotated so it reads as lying on a surface
      let book-body = box(width: bw, height: bh, {
        // the cover, one leaf per page so its arcs stay parallel to the
        // pages' and peek out as an even rim all around
        for side in (0.2cm, bw - 0.2cm - pwid) {
          place(top + left, dx: side - 0.2cm,
            sheet(pwid + 0.4cm, phh + 0.62cm, fill: col.darken(14%)))
        }
        // the page bulk at the fore-edges: a band under the bottom arc,
        // with two hairlines for the stacked leaves
        for side in (0.2cm, bw - 0.2cm - pwid) {
          place(top + left, curve(fill: luma(238),
            curve.move((side, phh)),
            curve.cubic((side + pwid * 0.25, phh - 0.87cm),
              (side + pwid * 0.75, phh - 0.87cm), (side + pwid, phh)),
            curve.line((side + pwid, phh + 0.34cm)),
            curve.cubic((side + pwid * 0.75, phh - 0.53cm),
              (side + pwid * 0.25, phh - 0.53cm), (side, phh + 0.34cm))))
          for ly in (0.11cm, 0.22cm) {
            place(top + left, curve(fill: none,
              stroke: (paint: luma(195), thickness: 0.4pt),
              curve.move((side, phh + ly)),
              curve.cubic((side + pwid * 0.25, phh - 0.87cm + ly),
                (side + pwid * 0.75, phh - 0.87cm + ly),
                (side + pwid, phh + ly))))
          }
        }
        if rtl {
          page(bw / 2 + 0.2cm, page-a, graph-right, teal)
          page(bw / 2 - 0.2cm - pwid, page-b, graph-left, acc)
        } else {
          page(bw / 2 - 0.2cm - pwid, page-a, graph-left, teal)
          page(bw / 2 + 0.2cm, page-b, graph-right, acc)
        }
        // the gutter shadow and the bookmark
        place(top + left, dx: bw / 2 - 0.35cm, dy: 0.8cm,
          rect(width: 0.7cm, height: phh - 1.6cm, fill: gradient.linear(
            white.transparentize(100%), luma(50).transparentize(80%),
            white.transparentize(100%))))
        place(top + left,
          polygon(fill: acc,
            (bw / 2 - 0.32cm, phh - 1.2cm), (bw / 2 + 0.32cm, phh - 1.2cm),
            (bw / 2 + 0.32cm, phh + 0.75cm), (bw / 2, phh + 0.38cm),
            (bw / 2 - 0.32cm, phh + 0.75cm)))
      })
      place(top + left, dx: cx - bw / 2, dy: by,
        rotate(-3deg, scale(y: 88%, skew(ax: -6deg, book-body))))
      // the formula panel
      if formula != none {
        place(top + left, dx: cx - 6.5cm, dy: by + phh + 1.45cm,
          block(width: 13cm, radius: 6pt, fill: pale,
            stroke: (paint: teal.transparentize(45%), thickness: 0.7pt),
            inset: (x: 0.5cm, y: 0.42cm), {
              set text(dir: dir)
              set align(center)
              formula
            }))
      }
      // the footer band
      place(top + left, dy: ph - 2.7cm,
        rect(width: pw, height: 2.7cm, fill: col))
      place(top + left, dy: ph - 2.35cm, block(width: pw, {
        set text(dir: dir)
        set align(center)
        align(center, line(length: 1.4cm,
          stroke: (paint: gold, thickness: 3pt)))
        v(0.22cm)
        if author != none {
          text(size: 15pt, weight: "bold", fill: white, author)
        }
        if place-line != none {
          v(0.10cm)
          text(size: 8.5pt, fill: mint, place-line)
        }
      }))
    }))
  } else if style == "sunburst" {
    // a green field with radial rays, a gold motto, a yellow level band,
    // a bulleted topic list, an open book ringed by instruments
    let gold = rgb("#ECAE37")
    let ink-g = rgb("#355632")
    let orange = rgb("#E8791E")
    let blue = rgb("#198AD0")
    let band-y = 5.6cm
    let band-h = 2.5cm
    let foot-y = ph - 2.7cm
    let zone-y = band-y + band-h
    let zone-h = foot-y - zone-y
    // one leaf of the book, arched top and bottom like the open book's
    let sheet(w, h, fill: none, stroke: none, dy: 0cm) = curve(
      fill: fill, stroke: stroke,
      curve.move((0cm, dy + 0.7cm)),
      curve.cubic((w * 0.25, dy + 0.2cm), (w * 0.75, dy + 0.2cm),
        (w, dy + 0.7cm)),
      curve.line((w, dy + h - 0.15cm)),
      curve.cubic((w * 0.75, dy + h - 0.85cm), (w * 0.25, dy + h - 0.85cm),
        (0cm, dy + h - 0.15cm)),
    )
    place(top + left, dx: -ml, dy: -mt, block(width: pw, height: ph, clip: true, {
      set text(dir: dir)
      place(top + left, rect(width: pw, height: ph, fill: col))
      // the radial rays, clipped to the field between the two bands
      place(top + left, dy: zone-y,
        block(width: pw, height: zone-h, clip: true, {
          let rcx = pw / 2
          let rcy = zone-h * 0.80
          let R = pw * 1.2
          for k in range(0, 20, step: 2) {
            let a0 = calc.pi * 2 * k / 20
            let a1 = calc.pi * 2 * (k + 1) / 20
            place(top + left,
              polygon(fill: rgb("#4C8E2D"),
                (rcx, rcy),
                (rcx + R * calc.cos(a0), rcy + R * calc.sin(a0)),
                (rcx + R * calc.cos(a1), rcy + R * calc.sin(a1))))
          }
        }))
      // the series line and the gold motto
      place(top + left, dy: 0.95cm, block(width: pw, {
        set text(dir: dir)
        set align(center)
        if series != none {
          text(size: 9.5pt, fill: white.transparentize(20%), series)
        }
      }))
      place(top + left, dy: 2.0cm, block(width: pw, {
        set text(dir: dir)
        set align(center)
        if note != none {
          text(size: 38pt, weight: "bold", fill: gold, note)
        }
      }))
      // the yellow band with the level
      place(top + left, dy: band-y, rect(width: pw, height: band-h, fill: acc))
      place(top + left, dy: band-y + 0.55cm, block(width: pw, {
        set text(dir: dir)
        set align(center)
        if level != none {
          text(size: 21pt, weight: "bold", fill: ink-g, level)
        }
        if lead-in != none {
          v(0.18cm)
          text(size: 9pt, fill: col.darken(5%), lead-in)
        }
      }))
      // the bulleted topic list at the leading side
      if topics != none {
        place(top + lead, dx: if rtl { -1.6cm } else { 1.6cm }, dy: zone-y + 0.9cm,
          block(width: pw * 0.62, {
            set text(dir: dir)
            set align(start)
            let items = if type(topics) == array { topics } else { (topics,) }
            for (i, t) in items.enumerate() {
              if i > 0 { v(0.42cm) }
              box(width: 100%, {
                place(top + left, dx: if rtl { 100% - 0.3cm } else { 0.06cm },
                  dy: 0.14cm, circle(radius: 0.09cm, fill: acc))
                h(0.5cm)
                text(size: 11pt, fill: white, t)
              })
            }
          }))
      }
      // the title and subtitle, centred on the field
      place(top + left, dy: ph * 0.435, block(width: pw, {
        set text(dir: dir)
        set align(center)
        text(size: 50pt, weight: "bold", fill: gold,
          stroke: (paint: rgb("#205D20"), thickness: 0.9pt), title)
        if subtitle != none {
          v(0.45cm)
          text(size: 20pt, fill: white, subtitle)
        }
      }))
      // ---- the open book, slightly tilted ----
      let cx = pw / 2
      let pwid = 6.0cm
      let phh = 6.2cm
      let bw = 12.8cm
      let by = ph * 0.615
      place(top + left, dx: cx - bw / 2 - 0.4cm, dy: by + phh - 0.5cm,
        ellipse(width: bw + 1.6cm, height: 1.3cm, fill: luma(30).transparentize(80%)))
      let page(dx, header, graph, caption, tform: none) = place(top + left,
        dx: dx, dy: 0.15cm,
        box(width: pwid, height: phh, {
          place(top + left, sheet(pwid, phh, fill: white,
            stroke: (paint: col.transparentize(70%), thickness: 0.6pt), dy: 0cm))
          if header != none {
            place(top + left, dy: 0.5cm, box(width: pwid, {
              set text(dir: dir)
              set align(center)
              text(size: 8pt, weight: "bold", fill: ink-g, header)
            }))
          }
          if tform != none {
            place(top + left, dy: 0.95cm, box(width: pwid, {
              set text(dir: dir)
              set align(center)
              text(size: 7.5pt, fill: ink-g, tform)
            }))
          }
          place(top + left, dx: 0.5cm, dy: 1.4cm,
            box(width: 5.0cm, height: 3.45cm, graph))
          if caption != none {
            place(top + left, dy: phh - 1.35cm, box(width: pwid, {
              set text(dir: dir)
              set align(center)
              text(size: 8pt, fill: ink-g, caption)
            }))
          }
        }))
      let graph-grid = {
        let faint = luma(150).transparentize(55%)
        for gx in range(0, 11) {
          place(top + left, dx: gx * 0.45cm, dy: 0.2cm,
            line(start: (0pt, 0pt), end: (0pt, 3.1cm),
              stroke: (paint: faint, thickness: 0.4pt)))
        }
        for gy in range(0, 8) {
          place(top + left, dx: 0.2cm, dy: 0.2cm + gy * 0.42cm,
            line(length: 4.5cm, stroke: (paint: faint, thickness: 0.4pt)))
        }
        let inkc = col.transparentize(25%)
        place(top + left, line(start: (0.3cm, 2.4cm), end: (4.8cm, 2.4cm),
          stroke: (paint: inkc, thickness: 0.7pt)))
        place(top + left, line(start: (2.3cm, 3.3cm), end: (2.3cm, 0.3cm),
          stroke: (paint: inkc, thickness: 0.7pt)))
        place(top + left, curve(stroke: (paint: inkc, thickness: 0.9pt),
          curve.move((2.5cm, 3.1cm)),
          curve.cubic((2.7cm, 2.6cm), (3.2cm, 2.5cm), (4.6cm, 2.45cm))))
        place(top + left, curve(stroke: (paint: inkc, thickness: 0.9pt),
          curve.move((2.1cm, 0.5cm)),
          curve.cubic((1.9cm, 1.2cm), (1.6cm, 1.6cm), (0.6cm, 1.9cm))))
        place(top + left, line(start: (0.6cm, 0.6cm), end: (4.4cm, 3.2cm),
          stroke: (paint: orange, thickness: 0.7pt, dash: (2.5pt, 2.5pt))))
      }
      let graph-tan = {
        let inkc = col.transparentize(25%)
        place(top + left, line(start: (0.3cm, 2.9cm), end: (4.8cm, 2.9cm),
          stroke: (paint: inkc, thickness: 0.7pt)))
        place(top + left, line(start: (1.0cm, 3.3cm), end: (1.0cm, 0.3cm),
          stroke: (paint: inkc, thickness: 0.7pt)))
        place(top + left, curve(stroke: (paint: inkc, thickness: 0.9pt),
          curve.move((0.7cm, 0.7cm)),
          curve.cubic((1.8cm, 3.4cm), (3.2cm, 3.4cm), (4.5cm, 0.6cm))))
        place(top + left, line(start: (1.4cm, 0.9cm), end: (4.3cm, 2.6cm),
          stroke: (paint: orange, thickness: 0.8pt)))
        place(top + left, dx: 2.62cm, dy: 1.62cm,
          circle(radius: 0.09cm, fill: orange))
      }
      let book-body = box(width: bw, height: phh + 0.7cm, {
        for side in (0.2cm, bw - 0.2cm - pwid) {
          place(top + left, dx: side - 0.2cm,
            sheet(pwid + 0.4cm, phh + 0.55cm, fill: orange))
        }
        let tan-form = [$T : y = f'(a)(x - a) + f(a)$]
        if rtl {
          page(bw / 2 + 0.2cm, page-a, graph-tan, none, tform: tan-form)
          page(bw / 2 - 0.2cm - pwid, page-b, graph-grid, formula)
        } else {
          page(bw / 2 - 0.2cm - pwid, page-a, graph-grid, formula)
          page(bw / 2 + 0.2cm, page-b, graph-tan, none, tform: tan-form)
        }
        place(top + left, dx: bw / 2 - 0.3cm, dy: 0.6cm,
          rect(width: 0.6cm, height: phh - 1.2cm, fill: gradient.linear(
            white.transparentize(100%), luma(50).transparentize(82%),
            white.transparentize(100%))))
      })
      place(top + left, dx: cx - bw / 2, dy: by, rotate(-2.5deg, book-body))
      // ---- the instruments around the book ----
      // the protractor, a half ring with ticks, at the trailing foot
      place(top + trail, dx: if rtl { 2.2cm } else { -2.2cm }, dy: ph - 5.9cm,
        rotate(if rtl { -14deg } else { 14deg }, box(width: 5.4cm, height: 2.9cm, {
          let pts = ()
          for i in range(0, 19) {
            let a = calc.pi * i / 18
            pts.push((2.7cm - 2.5cm * calc.cos(a), 2.7cm - 2.5cm * calc.sin(a)))
          }
          for i in range(18, -1, step: -1) {
            let a = calc.pi * i / 18
            pts.push((2.7cm - 1.55cm * calc.cos(a), 2.7cm - 1.55cm * calc.sin(a)))
          }
          place(top + left, polygon(fill: acc, ..pts))
          for i in range(0, 19) {
            let a = calc.pi * i / 18
            place(top + left,
              line(start: (2.7cm - 2.5cm * calc.cos(a), 2.7cm - 2.5cm * calc.sin(a)),
                end: (2.7cm - 2.2cm * calc.cos(a), 2.7cm - 2.2cm * calc.sin(a)),
                stroke: (paint: col.darken(10%), thickness: 0.5pt)))
          }
          place(top + left, dx: 0.2cm, dy: 2.62cm,
            rect(width: 5.0cm, height: 0.28cm, radius: 0.1cm, fill: acc))
        })))
      // the set square, a triangle with a triangular window, leading foot
      place(top + lead, dx: if rtl { -0.8cm } else { 0.8cm }, dy: ph - 6.6cm,
        rotate(if rtl { 10deg } else { -10deg }, box(width: 5.2cm, height: 4.2cm, {
          place(top + left, polygon(fill: acc,
            (0.2cm, 3.9cm), (5.0cm, 3.9cm), (5.0cm, 0.3cm)))
          place(top + left, polygon(fill: col.lighten(9%),
            (2.0cm, 3.35cm), (4.45cm, 3.35cm), (4.45cm, 1.1cm)))
          // ruler ticks along the base leg, every fifth one longer
          for i in range(0, 15) {
            let tx = 0.7cm + i * 0.29cm
            let tl = if calc.rem(i, 5) == 0 { 0.34cm } else { 0.2cm }
            place(top + left,
              line(start: (tx, 3.88cm), end: (tx, 3.88cm - tl),
                stroke: (paint: col.darken(15%), thickness: 0.5pt)))
          }
        })))
      // the small blue compass leaning on the trailing side of the book
      place(top + trail, dx: if rtl { 2.5cm } else { -2.5cm }, dy: ph - 9.8cm,
        rotate(if rtl { 12deg } else { -12deg }, box(width: 2.6cm, height: 3.9cm, {
          place(top + left,
            line(start: (1.3cm, 0.55cm), end: (0.55cm, 3.4cm),
              stroke: (paint: blue, thickness: 2pt)))
          place(top + left,
            line(start: (1.3cm, 0.55cm), end: (1.95cm, 3.3cm),
              stroke: (paint: blue, thickness: 2pt)))
          place(top + left, dx: 1.05cm, dy: 0.3cm,
            circle(radius: 0.25cm, fill: orange,
              stroke: (paint: col.darken(20%), thickness: 0.6pt)))
          place(top + left,
            line(start: (0.55cm, 3.4cm), end: (0.42cm, 3.8cm),
              stroke: (paint: luma(60), thickness: 0.9pt)))
          place(top + left,
            line(start: (1.95cm, 3.3cm), end: (2.06cm, 3.7cm),
              stroke: (paint: luma(60), thickness: 0.9pt)))
        })))
      // the yellow footer band
      place(top + left, dy: foot-y, rect(width: pw, height: 2.7cm, fill: acc))
      place(top + left, dy: foot-y + 0.62cm, block(width: pw, {
        set text(dir: dir)
        set align(center)
        if author != none {
          text(size: 15pt, weight: "bold", fill: ink-g, author)
        }
        if place-line != none {
          v(0.16cm)
          text(size: 8.5pt, fill: col.darken(5%), place-line)
        }
      }))
    }))
  } else if style == "dice" {
    // a dark navy plate: double frame, gem motifs, a rosette, and a white
    // card whose trailing corner is cut by a swoosh carrying three dice
    let teal = rgb("#467F83")
    let card-c = rgb("#FAF7EE")
    let cream = rgb("#FAF7EE")
    let gray = luma(110)
    let card-x = pw * 0.14
    let card-w = pw * 0.72
    let card-y = ph * 0.465
    let card-h = ph * 0.42
    // an elongated octagon gem, outlined twice
    let gem(dx, dy, w, h, rot) = place(top + left, dx: dx, dy: dy,
      rotate(rot, box(width: w, height: h, {
        place(top + left, polygon(fill: teal.transparentize(86%),
          stroke: (paint: teal.transparentize(40%), thickness: 0.9pt),
          (w * 0.28, 0cm), (w * 0.72, 0cm), (w, h * 0.26), (w, h * 0.74),
          (w * 0.72, h), (w * 0.28, h), (0cm, h * 0.74), (0cm, h * 0.26)))
        place(top + left, polygon(fill: none,
          stroke: (paint: teal.transparentize(55%), thickness: 0.6pt),
          (w * 0.36, h * 0.14), (w * 0.64, h * 0.14), (w * 0.84, h * 0.32),
          (w * 0.84, h * 0.68), (w * 0.64, h * 0.86), (w * 0.36, h * 0.86),
          (w * 0.16, h * 0.68), (w * 0.16, h * 0.32)))
      })))
    // one 3D die: three faces, pips mapped bilinearly onto each face
    let die(dx, dy, w, h, rot, base, nt, nl, nr) = _die3d(dx, dy, w, h, rot,
      base.lighten(25%), base, base.darken(22%), nt, nl, nr, white)
    place(top + left, dx: -ml, dy: -mt, block(width: pw, height: ph, clip: true, {
      set text(dir: dir)
      place(top + left, rect(width: pw, height: ph, fill: col))
      // the double frame
      place(top + left, dx: 0.75cm, dy: 0.75cm,
        rect(width: pw - 1.5cm, height: ph - 3.35cm,
          stroke: (paint: white.transparentize(55%), thickness: 0.9pt)))
      place(top + left, dx: 1.05cm, dy: 1.05cm,
        rect(width: pw - 2.1cm, height: ph - 3.95cm,
          stroke: (paint: acc.transparentize(45%), thickness: 0.6pt)))
      // gem motifs at the four corner zones and the middle edges
      gem(1.3cm, 0.9cm, 1.7cm, 2.1cm, 18deg)
      gem(2.6cm, 1.9cm, 1.3cm, 1.6cm, -14deg)
      gem(pw - 3.0cm, 0.9cm, 1.7cm, 2.1cm, -18deg)
      gem(pw - 3.9cm, 1.9cm, 1.3cm, 1.6cm, 14deg)
      gem(0.55cm, ph * 0.47, 1.4cm, 1.7cm, 8deg)
      gem(1.15cm, ph * 0.53, 1.5cm, 1.8cm, -10deg)
      gem(0.65cm, ph * 0.60, 1.3cm, 1.6cm, 14deg)
      gem(pw - 1.95cm, ph * 0.47, 1.4cm, 1.7cm, -8deg)
      gem(pw - 2.65cm, ph * 0.53, 1.5cm, 1.8cm, 10deg)
      gem(pw - 1.95cm, ph * 0.60, 1.3cm, 1.6cm, -14deg)
      gem(pw - 2.4cm, ph * 0.78, 1.5cm, 1.8cm, 12deg)
      gem(pw - 1.7cm, ph * 0.85, 1.2cm, 1.5cm, -8deg)
      // the heading stack
      place(top + left, dy: 1.8cm, block(width: pw, {
        set text(dir: dir)
        set align(center)
        if series != none {
          text(size: 10pt, fill: acc, tracking: 1.6pt, series)
        }
        v(0.4cm)
        if note != none {
          box(width: 12cm, {
            set align(center)
            grid(columns: (1fr, auto, 1fr), column-gutter: 0.5cm,
              align(horizon, line(length: 100%,
                stroke: (paint: white.transparentize(50%), thickness: 0.6pt))),
              text(size: 9pt, style: "italic", fill: white, note),
              align(horizon, line(length: 100%,
                stroke: (paint: white.transparentize(50%), thickness: 0.6pt))),
            )
          })
        }
        v(0.55cm)
        text(size: 48pt, weight: "bold", fill: white, title)
        if subtitle != none {
          v(0.3cm)
          text(size: 15pt, fill: acc.lighten(15%), subtitle)
        }
        if author != none {
          v(0.5cm)
          text(size: 13pt, fill: white.transparentize(10%), author)
        }
      }))
      // the rosette with its flanking rules
      let ry = ph * 0.43
      for side in (1, -1) {
        place(top + left, dx: pw / 2 + side * 2.4cm - if side == 1 { 0cm } else { 6.1cm },
          dy: ry, line(length: 6.1cm,
            stroke: (paint: white.transparentize(55%), thickness: 0.6pt)))
        place(top + left, dx: pw / 2 + side * 8.5cm - 0.06cm, dy: ry - 0.06cm,
          circle(radius: 0.06cm, fill: white.transparentize(40%)))
      }
      place(top + left, dx: pw / 2 - 1.3cm, dy: ry - 1.3cm,
        box(width: 2.6cm, height: 2.6cm, {
          for k in range(0, 8) {
            place(top + left, dx: 1.3cm, dy: 1.3cm, rotate(k * 45deg,
              polygon(fill: teal.transparentize(78%),
                stroke: (paint: teal.transparentize(25%), thickness: 0.8pt),
                (0cm, -0.98cm), (0.26cm, -0.38cm), (0cm, -0.08cm),
                (-0.26cm, -0.38cm)), origin: center))
          }
          place(top + left, dx: 0.75cm, dy: 0.75cm,
            circle(radius: 0.55cm, fill: col.darken(30%),
              stroke: (paint: teal, thickness: 0.8pt)))
          if topics != none {
            place(top + left, dx: 0.75cm, dy: 0.75cm,
              box(width: 1.1cm, height: 1.1cm, {
                set align(center + horizon)
                text(size: 8pt, style: "italic", fill: white, topics)
              }))
          }
        }))
      // the swoosh and the dice, mirrored with the direction
      let sw = box(width: card-w, height: 5.4cm, {
        place(top + left, curve(stroke: (paint: white, thickness: 1.15cm),
          curve.move((card-w - 4.6cm, 1.15cm)),
          curve.cubic((card-w - 1.9cm, 1.5cm), (card-w - 0.55cm, 3.0cm),
            (card-w - 0.35cm, 5.4cm))))
        gem(card-w - 3.6cm, 2.5cm, 1.1cm, 1.3cm, 20deg)
        gem(card-w - 2.2cm, 3.9cm, 1.0cm, 1.2cm, -16deg)
      })
      place(top + left, dx: if rtl { pw - card-x - card-w } else { card-x },
        dy: card-y - 1.15cm, if rtl { scale(x: -100%, sw) } else { sw })
      // the card, its trailing top corner cut by the swoosh
      let card-shape = curve(fill: card-c,
        curve.move((0cm, 0cm)),
        curve.line((card-w - 4.6cm, 0cm)),
        curve.cubic((card-w - 1.9cm, 0.35cm), (card-w - 0.55cm, 1.85cm),
          (card-w - 0.35cm, 4.25cm)),
        curve.line((card-w - 0.2cm, card-h)),
        curve.line((0cm, card-h)),
      )
      place(top + left, dx: card-x, dy: card-y,
        if rtl { scale(x: -100%, card-shape) } else { card-shape })
      // the three dice ride the swoosh, in front of the card's corner
      let dice-box = box(width: card-w, height: 5.4cm, {
        die(card-w - 4.5cm, 0.1cm, 2.0cm, 2.0cm, -14deg, teal, 1, 2, 3)
        die(card-w - 2.7cm, 1.5cm, 2.0cm, 2.0cm, 9deg, rgb("#E8791E"), 3, 2, 3)
        die(card-w - 1.5cm, 3.3cm, 1.7cm, 1.7cm, -7deg, rgb("#3A4DBF"), 1, 3, 2)
      })
      place(top + left, dx: if rtl { pw - card-x - card-w } else { card-x },
        dy: card-y - 1.15cm,
        if rtl { scale(x: -100%, dice-box) } else { dice-box })
      // the card's texts
      place(top + left, dx: card-x + 1.1cm, dy: card-y + 0.9cm,
        block(width: card-w - 2.2cm, {
          set text(dir: dir)
          set align(start)
          if page-a != none {
            text(size: 11pt, weight: "bold", fill: col, tracking: 1pt, page-a)
            v(0.25cm)
            line(length: 9cm, stroke: (paint: acc, thickness: 0.8pt))
          }
          if formula != none {
            v(0.55cm)
            text(size: 15pt, fill: col, formula)
          }
          if lead-in != none {
            v(0.35cm)
            text(size: 8.5pt, fill: gray, lead-in)
          }
          v(0.55cm)
          grid(columns: (1fr, 1fr), column-gutter: 1.0cm,
            block(width: 100%, {
              set align(center)
              if page-b != none {
                text(size: 9.5pt, weight: "bold", fill: col, tracking: 0.8pt,
                  page-b)
              }
              v(0.4cm)
              box(width: 6.4cm, height: 3.5cm, {
                place(top + left, line(start: (0.55cm, 0.3cm),
                  end: (0.55cm, 3.0cm), stroke: (paint: gray, thickness: 0.7pt)))
                place(top + left, line(start: (0.55cm, 3.0cm),
                  end: (6.2cm, 3.0cm), stroke: (paint: gray, thickness: 0.7pt)))
                place(top + left, line(start: (0.55cm, 0.9cm),
                  end: (6.1cm, 0.9cm),
                  stroke: (paint: gray, thickness: 0.5pt, dash: (2pt, 2pt))))
                for i in range(0, 6) {
                  place(top + left, dx: 1.0cm + i * 0.85cm, dy: 0.9cm,
                    rect(width: 0.55cm, height: 2.1cm, fill: teal))
                  place(top + left, dx: 1.0cm + i * 0.85cm, dy: 3.1cm,
                    box(width: 0.55cm, {
                      set align(center)
                      text(size: 7pt, fill: gray, str(i + 1))
                    }))
                }
              })
              v(0.15cm)
              text(size: 8.5pt, fill: teal,
                [$P(X = k) = 1/6, quad k in Omega$])
            }),
            block(width: 100%, {
              set align(center)
              if badge-label != none {
                text(size: 9.5pt, weight: "bold", fill: col, tracking: 0.8pt,
                  badge-label)
              }
              if badge != none {
                v(0.45cm)
                text(size: 12pt, fill: col, badge)
              }
            }),
          )
        }))
      // the cream footer band with an arched top
      place(top + left, curve(fill: cream,
        curve.move((0cm, ph - 2.4cm)),
        curve.cubic((pw * 0.3, ph - 2.75cm), (pw * 0.7, ph - 2.75cm),
          (pw, ph - 2.4cm)),
        curve.line((pw, ph)),
        curve.line((0cm, ph)),
      ))
      place(top + left, dy: ph - 1.85cm, block(width: pw, {
        set text(dir: dir)
        set align(center)
        if publisher != none {
          text(size: 13pt, weight: "bold", fill: col, tracking: 2pt, publisher)
        }
      }))
      place(top + left, dx: if rtl { pw - 3.1cm } else { 2.0cm }, dy: ph - 1.75cm,
        box(width: 1.1cm, height: 0.7cm, {
          place(top + left, polygon(fill: none,
            stroke: (paint: col, thickness: 0.8pt),
            (0cm, 0.14cm), (0.52cm, 0cm), (0.52cm, 0.5cm), (0cm, 0.64cm)))
          place(top + left, polygon(fill: none,
            stroke: (paint: col, thickness: 0.8pt),
            (0.58cm, 0cm), (1.1cm, 0.14cm), (1.1cm, 0.64cm), (0.58cm, 0.5cm)))
        }))
    }))
  } else if style == "scatter" {
    // a night-teal ground: faint rosettes, a gold rule with corner ticks,
    // a cloud of scattered 3D dice around one great die, and a footer band
    let deep = rgb("#123D4D")
    let gold = acc
    let cream = rgb("#FFF4D2")
    let muted = rgb("#86A5A2")
    let ornament = rgb("#24474D")
    let ivory-die = (rgb("#FFFEF1"), rgb("#A6A797"), rgb("#F3E7BC"))
    let gold-die = (rgb("#FFF2D3"), rgb("#AB9665"), rgb("#E7C886"))
    let aqua-die = (rgb("#B8EBE0"), rgb("#3A8D89"), rgb("#75D1C6"))
    let X = (mm) => pw * mm / 210
    let Y = (mm) => ph * mm / 297
    // a 16-spoke guilloche rosette, like the source's background wheels
    let rosette(cx, cy, r, paint) = {
      place(top + left, dx: cx - r, dy: cy - r,
        circle(radius: r, fill: none,
          stroke: (paint: paint, thickness: 0.3pt)))
      place(top + left, dx: cx - r * 0.92, dy: cy - r * 0.92,
        circle(radius: r * 0.92, fill: none,
          stroke: (paint: paint, thickness: 0.25pt)))
      for i in range(16) {
        let a = i * 22.5deg
        let qx = cx + r * 0.53 * calc.cos(a)
        let qy = cy + r * 0.53 * calc.sin(a)
        place(top + left, dx: qx - r * 0.44, dy: qy - r * 0.44,
          circle(radius: r * 0.44, fill: none,
            stroke: (paint: paint, thickness: 0.27pt)))
        place(top + left,
          line(start: (cx + r * calc.cos(a), cy + r * calc.sin(a)),
            end: (cx + r * calc.cos(a + 112.5deg),
              cy + r * calc.sin(a + 112.5deg)),
            stroke: (paint: paint, thickness: 0.22pt)))
        place(top + left, dx: qx - 0.04cm, dy: qy - 0.04cm,
          circle(radius: 0.04cm, fill: paint))
        place(top + left,
          dx: cx + r * 1.055 * calc.cos(a) - r * 0.038,
          dy: cy + r * 1.055 * calc.sin(a) - r * 0.038,
          circle(radius: r * 0.038, fill: none,
            stroke: (paint: paint, thickness: 0.25pt)))
      }
    }
    place(top + left, dx: -ml, dy: -mt, block(width: pw, height: ph, clip: true, {
      set text(dir: dir)
      place(top + left, rect(width: pw, height: ph,
        fill: gradient.linear(col, deep, angle: 90deg)))
      // the background rosettes and the star dust
      rosette(X(4), Y(22), X(38), rgb("#173541"))
      rosette(X(211), Y(59), X(37), rgb("#173B46"))
      rosette(X(3), Y(128), X(30), rgb("#1B414A"))
      rosette(X(204), Y(173), X(28), rgb("#214750"))
      rosette(X(12), Y(279), X(34), rgb("#244B53"))
      rosette(X(104), Y(207), X(45), rgb("#315553"))
      for i in range(52) {
        let hx = 13 + calc.rem(i * 37, 183)
        let vy = 23 + calc.rem(i * 53, 241)
        if vy > 150 or hx < 46 or hx > 170 {
          place(top + left, dx: X(hx), dy: Y(vy),
            circle(radius: 0.03cm, fill: rgb("#527276")))
        }
      }
      // the gold rule and its corner ticks
      place(top + left, dx: X(6), dy: Y(7),
        rect(width: X(198), height: Y(283), fill: none,
          stroke: (paint: rgb("#7C8066"), thickness: 0.4pt)))
      for (tx, ty, sx, sy) in ((6, 7, 1, 1), (204, 7, -1, 1),
                               (6, 290, 1, -1), (204, 290, -1, -1)) {
        place(top + left,
          line(start: (X(tx), Y(ty)), end: (X(tx + sx * 9), Y(ty)),
            stroke: (paint: gold, thickness: 1pt)))
        place(top + left,
          line(start: (X(tx), Y(ty)), end: (X(tx), Y(ty + sy * 9)),
            stroke: (paint: gold, thickness: 1pt)))
      }
      // edition, title block, rule and the centred formula
      place(top + left, dy: Y(31), block(width: pw, {
        set text(dir: dir)
        set align(center)
        if series != none {
          text(size: 15pt, fill: gold, series)
        }
      }))
      place(top + left, dy: Y(44.4), box(width: pw, {
        place(top + left, dx: X(86),
          line(length: X(16), stroke: (paint: rgb("#687767"), thickness: 0.4pt)))
        place(top + left, dx: X(108),
          line(length: X(16), stroke: (paint: rgb("#687767"), thickness: 0.4pt)))
        place(top + left, dx: X(104.1), dy: Y(0.9),
          polygon(fill: gold, (X(0.9), 0pt), (X(1.8), Y(0.9)),
            (X(0.9), Y(1.8)), (0pt, Y(0.9))))
      }))
      place(top + left, dy: Y(57), block(width: pw, {
        set text(dir: dir)
        set align(center)
        text(size: 47pt, weight: "bold", fill: cream, title)
      }))
      place(top + left, dy: Y(86), block(width: pw, {
        set text(dir: dir)
        set align(center)
        if subtitle != none {
          text(size: 21pt, fill: gold, subtitle)
        }
      }))
      place(top + left, dy: Y(103), block(width: pw, {
        set text(dir: dir)
        set align(center)
        if author != none {
          text(size: 13pt, fill: muted, author)
        }
      }))
      place(top + left, dy: Y(117),
        line(start: (X(67), 0pt), end: (X(143), 0pt),
          stroke: (paint: rgb("#30505A"), thickness: 0.45pt)))
      if formula != none {
        place(top + left, dx: X(65), dy: Y(128), block(width: X(80), {
          set align(center)
          set text(dir: ltr, size: 17pt, fill: muted)
          formula
        }))
      }
      // the two side formulas and the caption under the trailing one
      place(top + left, dx: X(16), dy: Y(190), block(width: X(52), {
        set align(center)
        set text(dir: ltr, size: 9pt, fill: rgb("#577C7B"))
        [$Omega = \{1, 2, 3, 4, 5, 6\}$]
      }))
      place(top + left, dx: X(148), dy: Y(195), block(width: X(48), {
        set align(center)
        set text(dir: ltr, size: 12pt, fill: rgb("#839073"))
        [$sum_i P(A_i) = 1$]
      }))
      if note != none {
        place(top + left, dx: X(148), dy: Y(204), block(width: X(48), {
          set text(dir: dir)
          set align(center)
          text(size: 7pt, fill: rgb("#577C7B"), note)
        }))
      }
      // the cloud of dice, one great die among them
      let die-mm(h, v, f, pal, nt, nl, nr, tilt, pipc) = _die3d(
        X(h), Y(v), X(43 * f), Y(48 * f), tilt,
        pal.at(0), pal.at(1), pal.at(2), nt, nl, nr, pipc,
        shadow: rgb("#0D2D3A"))
      die-mm(176, 28, 0.22, gold-die, 2, 1, 3, -8deg, col)
      die-mm(31, 52, 0.18, ivory-die, 3, 1, 2, 12deg, col)
      die-mm(19, 106, 0.26, aqua-die, 2, 3, 6, -12deg, rgb("#12474D"))
      die-mm(179, 115, 0.27, ivory-die, 6, 3, 5, -5deg, col)
      die-mm(50, 151, 0.29, gold-die, 4, 1, 5, 8deg, col)
      die-mm(149, 153, 0.35, aqua-die, 2, 6, 3, -12deg, rgb("#12474D"))
      die-mm(81, 176, 1.10, ivory-die, 6, 3, 5, 8deg, col)
      die-mm(39, 217, 0.57, aqua-die, 4, 1, 5, -5deg, rgb("#12474D"))
      die-mm(145, 222, 0.60, gold-die, 2, 3, 1, -10deg, col)
      die-mm(17, 247, 0.22, ivory-die, 6, 3, 5, 10deg, col)
      die-mm(87, 250, 0.24, gold-die, 3, 2, 6, 15deg, col)
      die-mm(121, 257, 0.17, ivory-die, 4, 1, 5, -8deg, col)
      die-mm(184, 253, 0.26, aqua-die, 6, 3, 5, 12deg, rgb("#12474D"))
      // the footer band
      place(top + left, dy: Y(271), rect(width: pw, height: Y(18.7),
        fill: col))
      place(top + left, dy: Y(277), block(width: pw, {
        set text(dir: dir)
        set align(center)
        if publisher != none {
          text(size: 12pt, fill: cream, publisher)
        }
      }))
    }))
  } else {
    // "spine" — a coloured band on the leading edge, a ruled panel beside it
    let band = 4.2cm
    let bx = if rtl { pw - band } else { 0pt }
    place(top + left, dx: -ml, dy: -mt, block(width: pw, height: ph, clip: true, {
      set text(dir: dir)
      place(top + left, rect(width: pw, height: ph, fill: white))
      place(top + left, dx: bx, rect(width: band, height: ph, fill: col))
      place(top + left, dx: if rtl { bx - 0.25cm } else { band },
        rect(width: 0.25cm, height: ph, fill: acc))
      // rings and rungs on the band
      let mx = if rtl { bx + band / 2 } else { band / 2 }
      place(top + left, dx: mx - 0.9cm, dy: 2.6cm,
        circle(radius: 0.9cm, fill: acc.transparentize(30%)))
      place(top + left, dx: mx - 0.45cm, dy: 3.05cm,
        circle(radius: 0.45cm, fill: white))
      place(top + left, dx: mx - 1.1cm, dy: ph - 4.6cm,
        circle(radius: 1.1cm, fill: white.transparentize(60%)))
      place(top + left, dx: mx - 0.55cm, dy: ph - 4.05cm,
        circle(radius: 0.55cm, fill: acc))
      for i in range(0, 7) {
        place(top + left, dx: mx - 0.9cm, dy: 10.5cm + i * 0.8cm,
          line(length: 1.8cm, stroke: (paint: white, thickness: 2pt)))
      }
      // the double panel
      let px = if rtl { 1.0cm } else { band + 1.0cm }
      let pww = pw - band - 2.0cm
      place(top + left, dx: px, dy: 1.3cm,
        rect(width: pww, height: ph - 2.6cm, radius: 12pt,
          stroke: (paint: col.lighten(25%), thickness: 1.5pt), fill: none))
      place(top + left, dx: px + 0.3cm, dy: 1.6cm,
        rect(width: pww - 0.6cm, height: ph - 3.2cm, radius: 10pt,
          stroke: (paint: acc.lighten(45%), thickness: 1.2pt),
          fill: acc.lighten(88%).transparentize(50%)))
      // the centred title stack
      place(top + left, dx: px, dy: 0pt,
        block(width: pww, height: ph, {
          set text(dir: dir)
          set align(center)
          v(3.2cm)
          if series != none {
            text(size: 13pt, fill: col.darken(10%), tracking: 2pt, series)
            v(0.3cm)
          }
          if level != none {
            text(size: 12pt, fill: luma(40), level)
            v(2.2cm)
          }
          line(length: 5cm, stroke: (paint: acc.darken(15%), thickness: 3pt))
          v(0.8cm)
          text(size: 40pt, weight: "bold", fill: col.darken(35%), title)
          if subtitle != none {
            v(0.5cm)
            box(fill: acc.lighten(80%), stroke: (paint: acc, thickness: 2pt),
              inset: (x: 1.6cm, y: 0.5cm), radius: 10pt,
              text(size: 22pt, weight: "bold", fill: acc.darken(30%), subtitle))
          }
          v(0.8cm)
          line(length: 5cm, stroke: (paint: acc.darken(15%), thickness: 3pt))
          if author != none {
            v(2.6cm)
            block(stroke: (top: (paint: acc.lighten(20%), thickness: 2pt)),
              inset: (top: 1.0cm, x: 1cm), width: 13cm, {
              set text(dir: dir)
              set align(center)
              text(size: 16pt, weight: "bold", fill: col.darken(25%), author)
              if year != none {
                v(0.25cm)
                text(size: 12pt, fill: luma(40), year)
              }
            })
          }
        }))
    }))
  }
}
