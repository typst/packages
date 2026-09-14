#import "states.typ": begin, timeline
#import "utils.typ": get_max_block

#let _bar(width, color: none) = box(
  [\ ],
  width: width * 25pt,
  radius: 2pt,
  fill: color,
)

#let _show-timeline(timeline) = {
  let mblock = get_max_block(timeline)
  grid(
    columns: mblock + 1,
    align: left + bottom,
    inset: 3pt,
    [],
    grid.vline(stroke: (dash: "dashed")),
    ..range(1, mblock + 1)
      .map(b => { ([#b], grid.vline(stroke: (dash: "dashed"))) })
      .flatten(),
    grid.hline(),
    ..timeline
      .keys()
      .filter(k => k != "builtin_pause_counter")
      .map(k => {
        let name_dict = timeline.at(k)
        (
          (k,)
            + range(1, mblock + 1).map(b => {
              let total = 0
              let res = ()
              for e in name_dict.at(str(b), default: ()) {
                let (v, ho, du, dw, t) = e
                res += (
                  [#_bar(ho - total)#_bar(du, color: blue)#_bar(dw)],
                )
                total += ho - total + du + dw
              }
              res.join()
            })
        )
      })
      .join(),
  )
}

#let show-timeline() = context {
  if not begin.get() {
    _show-timeline(timeline.get())
  }
}
