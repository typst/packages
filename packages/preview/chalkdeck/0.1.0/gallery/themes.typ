// gallery/themes.typ — every theme and a few recolourings, side by side.
#import "@preview/chalkdeck:0.1.0": *
#set page(width: 21cm, height: auto, margin: 9mm, fill: white)
#set text(font: "New Computer Modern", size: 9.5pt, fill: black)

#let vign(th, lbl, pal: (:), bd: auto, w: 6.1, h: 4.6) = {
  let p = chalk-palettes.at(th) + pal
  let b = if bd != auto { bd } else { chalk-backdrops.at(th) }
  box(width: w * 1cm, {
    box(width: w * 1cm, height: h * 1cm, clip: true, {
      if b == "board" { backdrop-board(w, h, p) }
      else if b == "notebook" { backdrop-notebook(w, h, p) }
      else if b == "grid" { backdrop-grid(w, h, p) }
      else { backdrop-plain(w, h, p) }
      place(top + left, dx: 0.75cm, dy: 0.62cm,
        text(fill: p.at("title", default: p.structure), weight: "bold",
          size: 1.2em, font: "FreeSans", lbl))
      place(top + left, dx: 0.75cm, dy: 1.30cm,
        text(fill: p.fg, size: 0.95em, font: "FreeSans")[Body text.])
      place(top + left, dx: 0.75cm, dy: 1.82cm,
        text(fill: p.alert, size: 0.95em, font: "FreeSans")[Alerted.])
    })
    v(2pt); text(size: 0.78em, raw(th))
  })
}

= chalkdeck — themes

*The seven shipped themes — `print` is the one meant for paper.*
#v(2mm)
#grid(columns: 3, gutter: 5mm, row-gutter: 4mm,
  vign("blackboard", [blackboard]), vign("whiteboard", [whiteboard]),
  vign("slate", [slate]), vign("darkconsole", [darkconsole]),
  vign("lightconsole", [lightconsole]), vign("notebook", [notebook]),
  vign("print", [print]))

#v(4mm)
*Recolouring: `palette:` merges, so one key is enough.*
#v(2mm)
#grid(columns: 3, gutter: 5mm, row-gutter: 4mm,
  vign("blackboard", [navy board],
    pal: (board: rgb("#12314F"), bg: rgb("#12314F"))),
  vign("blackboard", [black board],
    pal: (board: rgb("#1C1C1C"), bg: rgb("#1C1C1C"))),
  vign("blackboard", [pale wood],
    pal: (frame-lit: rgb("#E8C39E"), frame-dim: rgb("#8A5A3B"),
          plate: rgb("#C89464"))))

#v(4mm)
*Backdrops are independent of the theme.*
#v(2mm)
#grid(columns: 3, gutter: 5mm,
  vign("slate", [`"grid"`], bd: "grid"),
  vign("blackboard", [`"plain"`], bd: "plain"),
  vign("lightconsole", [`"notebook"`], bd: "notebook",
    pal: (rule: rgb("#1776C7"))))

#v(4mm)
*Paper sizes: `ratio:` takes a name or a size of your own. Each sheet below
is drawn at its true proportions, scaled to a common WIDTH so the shapes can
be compared.*
#v(2mm)

// The vignette is the sheet at its own aspect, so the furniture scales with
// it — that is the whole point of the exercise. Every cell is boxed to the
// SAME height (that of the squarest sheet) so the captions line up instead
// of stepping down the row.
#let sheet(r, th: "blackboard", to: 4.3, cell: 4.35) = {
  let (pw, ph) = _paper(r)
  let p = chalk-palettes.at(th)
  let b = chalk-backdrops.at(th)
  let w = to
  let h = to * ph / pw
  box(width: w * 1cm, {
    box(width: w * 1cm, height: cell * 1cm, {
      place(top + left, box(width: w * 1cm, height: h * 1cm, {
        if b == "board" { backdrop-board(w, h, p) }
        else if b == "notebook" { backdrop-notebook(w, h, p) }
        else { backdrop-plain(w, h, p) }
      }))
    })
    v(1.5pt)
    text(size: 0.72em, raw(r) + text(fill: luma(120))[ #pw × #ph cm])
  })
}

#grid(columns: 4, gutter: 4mm, row-gutter: 4mm, align: top,
  ..("4-3", "16-9", "16-10", "3-2", "5-4", "1-1", "a4", "a5")
    .map(r => sheet(r)))

#v(3mm)
The notebook sheet at three sizes — the rules and the punched column keep
their proportions, so the first line of text is never struck through:
#v(2mm)
#grid(columns: 4, gutter: 4mm, align: top,
  ..("4-3", "16-9", "a4", "1-1").map(r => sheet(r, th: "notebook")))
