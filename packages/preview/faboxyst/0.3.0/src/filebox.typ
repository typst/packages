// ===========================================================================
//  filebox — a folder with labelled tabs along the top.
//
//    #filebox(tabs: ([Notes], [Ex], [Def]), active: 0)[…]
// ===========================================================================

#import "fabox.typ": is-rtl
#import "engine.typ": rounded-rect-pts
#import "antique.typ": vintage-pts

#import "theme.typ": theme-state

#let filebox(
  body,
  tabs: ([Notes],),
  active: 0,
  colour: rgb("#C4A35A"),
  active-fill: rgb("#F4E4B8"),
  idle-fill: rgb("#E0D0A0"),
  title-colour: rgb("#4A3A18"),
  fill: rgb("#FFF8E8"),
  frame-weight: 1.15pt,
  tab-height: 0.46cm,
  radius: 0.10cm,
  inset: 0.36cm,
  width: 100%,
  direction: auto,
  vintage: false,      // main frame engraved with an elliptical nib
  vintage-pen: none,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let colour = if print-mode { black } else { colour }
  let active-fill = if print-mode { white } else { active-fill }
  let idle-fill = if print-mode { luma(224) } else { idle-fill }
  let title-colour = if print-mode { black } else { title-colour }
  let fill = if print-mode { white } else { fill }
  if print-mode { set text(fill: black) }

  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let labels = if type(tabs) == array { tabs } else { (tabs,) }
  let n = calc.max(1, labels.len())
  let act = calc.min(calc.max(0, active), n - 1)
  let th = tab-height

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let main = block(width: W - 2 * inset, {
      set text(dir: body-dir)
      set align(start)
      body
    })
    let mh = measure(main).height
    let H = th + mh + 2 * inset

    block(width: W, height: H, {
      set text(dir: ltr)
      let folder-y = th * 0.42
      place(top + left, dy: folder-y,
        box(width: W, height: H - folder-y, fill: fill, radius: radius,
          stroke: if vintage { none } else { frame-weight + colour }))
      if vintage {
        place(top + left, dy: folder-y,
          vintage-pts(rounded-rect-pts((0pt, 0pt), (W, H - folder-y),
            radius: radius, n: 10), colour, frame-weight,
            vintage-pen: vintage-pen))
      }

      let gap = 0.10cm
      let tab-w = (W - gap * (n + 1)) / n
      for (i, lab) in labels.enumerate() {
        let physical = if rtl { n - 1 - i } else { i }
        let x = gap + physical * (tab-w + gap)
        let is-on = i == act
        let h = if is-on { th } else { th * 0.78 }
        let y = th - h
        place(top + left, dx: (x) + title-offset-x, dy: (y) + title-offset-y, box(
            width: tab-w, height: h + 0.08cm,
            fill: if is-on { active-fill } else { idle-fill },
            radius: (top: radius, bottom: 0pt),
            stroke: frame-weight + colour,
            clip: true,
            align(center + horizon,
              text(size: 0.78em, weight: if is-on { "bold" } else { "regular" },
                fill: title-colour, lab)),
          ))
      }
      // cover the tab bottoms so they join the folder
      place(top + left, dy: th,
        box(width: W, height: 0.10cm, fill: fill))
      place(top + left, dx: inset, dy: th + inset, main)
    })
  })
}
