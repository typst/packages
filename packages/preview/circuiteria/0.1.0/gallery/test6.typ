#import "@preview/cetz:0.2.2": draw, vector
#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: .5cm)

#circuit({
  element.multiplexer(
    x: 10, y: 0, w: 1, h: 6, id: "ResMux",
    entries: ("000", "001", "010", "011", "101"),
    h-ratio: 90%,
    fill: util.colors.blue
  )
  element.extender(
    x: (rel: -3, to: "ResMux.west"),
    y: (from: "ResMux-port-in4", to: "out"),
    w: 2, h: 1, id: "Ext",
    name: "Zero Ext",
    name-anchor: "south",
    fill: util.colors.green
  )
  gates.gate-or(
    x: (rel: -2, to: "ResMux.west"),
    y: (from: "ResMux-port-in3", to: "out"),
    w: 1, h: 1, id: "Or"
  )
  gates.gate-and(
    x: (rel: -2, to: "ResMux.west"),
    y: (from: "ResMux-port-in2", to: "out"),
    w: 1, h: 1, id: "And"
  )
  element.alu(
    x: (rel: -2.5, to: "Ext.west"),
    y: (from: "ResMux-port-in0", to: "out"),
    w: 1.5, h: 3, id: "Add",
    name: text("+", size: 1.5em),
    name-anchor: "name",
    fill: util.colors.pink
  )
  element.multiplexer(
    x: (rel: -1.5, to: "Add.west"),
    y: (from: "Add-port-in1", to: "out"),
    w: 0.5, h: 1.5, id: "NotMux",
    h-ratio: 80%,
    fill: util.colors.blue
  )
  gates.gate-not(
    x: (rel: -2, to: "NotMux.west"),
    y: (from: "NotMux-port-in1", to: "out"),
    w: 1, h: 1, id: "Not"
  )
  
  draw.hide(
    draw.line(name: "l1",
      "Not-port-in0",
      (rel: (-2, 0), to: ()),
      (horizontal: (), vertical: "NotMux-port-in0")
    )
  )
  let b = "l1.end"
  draw.hide(
    draw.line(name: "l2",
      b,
      (horizontal: (), vertical: "Add-port-in2")
    )
  )
  let a = "l2.end"

  wire.wire("wB0", (b, "NotMux-port-in0"), bus: true)
  wire.wire(
    "wB1", (b, "Not-port-in0"),
    style: "zigzag",
    zigzag-ratio: 1.5,
    bus: true
  )
  wire.wire(
    "wB2", (b, "And-port-in0"),
    style: "zigzag",
    zigzag-ratio: 1,
    bus: true
  )
  wire.wire(
    "wB3", (b, "Or-port-in0"),
    style: "zigzag",
    zigzag-ratio: 1,
    bus: true
  )
  wire.intersection("wB1.zig")
  wire.intersection("wB2.zig")
  wire.intersection("wB2.zag")

  wire.wire("wNot", ("Not-port-out", "NotMux-port-in1"), bus: true)
  wire.wire("wAddA", ("NotMux-port-out", "Add-port-in1"), bus: true)

  wire.wire("wA0", (a, "Add-port-in2"), bus: true)
  wire.wire(
    "wA1", (a, "And-port-in1"),
    style: "zigzag",
    zigzag-ratio: 0.5,
    bus: true
  )
  wire.wire(
    "wA2", (a, "Or-port-in1"),
    style: "zigzag",
    zigzag-ratio: 0.5,
    bus: true
  )
  wire.intersection("wA1.zig")
  wire.intersection("wA1.zag")

  wire.wire("wMux0", ("Add-port-out", "ResMux-port-in0"), bus: true)
  wire.wire(
    "wMux1", ("Add-port-out", "ResMux-port-in1"),
    style: "zigzag",
    zigzag-ratio: 2,
    bus: true
  )
  wire.wire("wMux2", ("And-port-out", "ResMux-port-in2"), bus: true)
  wire.wire("wMux3", ("Or-port-out", "ResMux-port-in3"), bus: true)
  wire.wire("wMux4", ("Ext-port-out", "ResMux-port-in4"), bus: true)

  wire.wire(
    "wAdd", ("Add-port-out", "Ext-port-in"),
    style: "zigzag",
    zigzag-ratio: 0.5,
    bus: true
  )

  wire.intersection("wMux1.zig")
  wire.intersection("wAdd.zig")

  let c = (rel: (0, 2), to: "ResMux.north")
  wire.wire("wResCtrl", (c, "ResMux.north"), bus: true)
  wire.wire(
    "wAddCtrl", (c, "Add.north"),
    style: "zigzag",
    zigzag-dir: "horizontal"
  )

  let d = (rel: (1, 0), to: "ResMux-port-out")
  wire.wire("wRes", ("ResMux-port-out", d), bus: true)

  draw.content(
    "wAddCtrl.zag",
    [ALUControl#sub("[1]")],
    anchor: "south-west",
    padding: 3pt
  )
  
  wire.wire(
    "wCout", ("Add.south", (horizontal: (), vertical: "Ext.north-east"))
  )
  draw.content(
    "wCout.end",
    [C#sub("out")],
    angle: 90deg,
    anchor: "east",
    padding: 3pt
  )
  draw.content(
    a,
    [A],
    angle: 90deg,
    anchor: "south",
    padding: 3pt
  )
  draw.content(
    b,
    [B],
    angle: 90deg,
    anchor: "south",
    padding: 3pt
  )
  draw.content(
    c,
    [ALUControl#sub("[2:0]")],
    angle: 90deg,
    anchor: "west",
    padding: 3pt
  )
  draw.content(
    d,
    [Result],
    angle: 90deg,
    anchor: "north",
    padding: 3pt
  )
  draw.content(
    ("wAdd.zig", 0.2, "wAdd.zag"),
    text("[N-1]", size: 0.8em),
    angle: 90deg,
    anchor: "north-east",
    padding: 3pt
  )
})