#import "/utils/states.typ": heh-config

#let double-table(
  ..args,
) = context {
  let primary-color = heh-config.get().campus.style.primary-color
  show table.cell: it => {
    if (it.y == 0 or it.x == 0) {
      set text(white, weight: "bold")
      it
    } else {
      it
    }
  }

  table(
    ..args, fill: (x, y) => {
      if (y == 0 or x == 0) {
        primary-color.darken(40%)
      } else {
        primary-color.transparentize(90%)
      }
    }
  )
}
