#import "@preview/chalkdeck:0.1.0": *
#set page(width: 19cm, height: auto, margin: 6mm, fill: white)
#set text(font: "New Computer Modern", size: 9pt, fill: black)
#let vign(th, lbl, w: 5.9, h: 4.4) = {
  let p = chalk-palettes.at(th)
  let b = chalk-backdrops.at(th)
  box(width: w * 1cm, {
    box(width: w * 1cm, height: h * 1cm, clip: true, {
      if b == "board" { backdrop-board(w, h, p) }
      else if b == "notebook" { backdrop-notebook(w, h, p) }
      else if b == "grid" { backdrop-grid(w, h, p) }
      else { backdrop-plain(w, h, p) }
      place(top + left, dx: 0.7cm, dy: 0.58cm,
        text(fill: p.at("title", default: p.structure), weight: "bold", size: 1.25em, lbl))
      place(top + left, dx: 0.7cm, dy: 1.30cm, text(fill: p.fg, size: 1em)[Body text.])
      place(top + left, dx: 0.7cm, dy: 1.85cm, text(fill: p.alert, size: 1em)[Alerted.])
    })
  })
}
#grid(columns: 3, column-gutter: 4mm, row-gutter: 4mm,
  vign("blackboard", [blackboard]), vign("whiteboard", [whiteboard]), vign("slate", [slate]),
  vign("darkconsole", [darkconsole]), vign("lightconsole", [lightconsole]), vign("notebook", [notebook]),
)
