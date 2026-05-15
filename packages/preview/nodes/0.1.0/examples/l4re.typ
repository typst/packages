#import "@preview/cetz:0.4.2"
#import "/src/lib.typ": canvas, edge, node

#set page(width: 16cm, height: 12cm)
#set text(font: "Noto Sans", size: 1.5em)

#let colors = (
  rgb("#4A90E2"),
  rgb("#E94E77"),
  rgb("#F5A623"),
  rgb("#FFFFFF"),
  rgb("#BBBBBB"),
).map(c => c.lighten(50%))

#let big-gap = .5
#let gap = .3
#let total-w = 13cm
#let serv-w = (total-w - 2 * gap * 1cm) / 3

#let block(pos, lbl, ..args) = node(
  pos,
  text(size: .8em)[#lbl],
  inset: .4cm,
  radius: 2pt,
  ..args,
)

#let app(pos, lbl, ..args) = block(pos, lbl, fill: colors.at(0), height: 1.1cm, ..args)

#let serv(pos, lbl, ..args) = block(
  pos,
  lbl,
  fill: colors.at(2),
  width: serv-w,
  height: 1.2,
  ..args,
)

#let kobj(pos, lbl, ..args) = block(
  pos,
  lbl,
  fill: colors.at(3),
  width: (total-w - gap * 6 * 1cm) / 5,
  height: 1.5cm,
  ..args,
)

#let uk-line(layer, kernel) = {
  import cetz.draw: line
  let color = black.lighten(50%)
  let mid-l = (layer + ".south-west", 50%, kernel + ".north-west")
  let mid-r = (layer + ".south-east", 50%, kernel + ".north-east")
  line(
    (layer + ".south-west", "|-", mid-l),
    ((rel: (1, 0), to: layer + ".south-east"), "|-", mid-r),
    stroke: color,
  )
  node((east-of: (kernel, gap)), text(fill: color)[kernel], body-angle: 90deg, stroke: 0pt)
  node((east-of: (layer, gap)), text(fill: color)[user], body-angle: 90deg, stroke: 0pt)
}

#canvas({
  block((0, 0), [Hardware], fill: colors.at(4), width: total-w, name: "hw")
  block(
    (north-of: ("hw", big-gap)),
    [Fiasco.OC Microkernel],
    body-pos: "north",
    fill: colors.at(1),
    width: total-w,
    height: 3cm,
    name: "kernel",
  )

  kobj((in-south-west: ("kernel", gap)), [Task], name: "task")
  kobj((east-of: ("task", gap)), [Thread], name: "thread")
  kobj((east-of: ("thread", gap)), [IPC], name: "ipc")
  kobj((east-of: ("ipc", gap)), [IRQ], name: "irq")
  kobj((in-south-east: ("kernel", gap)), [Sched], name: "sched")

  serv((north-of: ("kernel", big-gap * 2)), [L4Re], width: total-w, name: "l4re")
  serv((north-of: ("l4re", gap, "left")), [L4Linux], name: "l4linux")
  serv((east-of: ("l4linux", gap)), [Dope], name: "dope")
  serv((east-of: ("dope", gap)), [VPFS], name: "vpfs")

  app(
    (north-of: ("l4linux", gap)),
    [Lx Application],
    width: serv-w,
    name: "lxapp",
  )
  app(
    (north-of: ("dope", gap, "left")),
    [L4Re Application],
    width: serv-w * 2 + gap * 1cm,
    name: "l4reapp",
  )

  uk-line("l4re", "kernel")
})
