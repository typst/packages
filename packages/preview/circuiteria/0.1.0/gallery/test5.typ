#import "@preview/cetz:0.2.2": draw
#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: .5cm)

#circuit({
  element.multiplexer(
    x: 0, y: 0, w: .5, h: 1.5, id: "PCMux",
    entries: 2,
    fill: util.colors.blue,
    h-ratio: 80%
  )
  element.block(
    x: (rel: 2, to: "PCMux.east"),
    y: (from: "PCMux-port-out", to: "in"),
    w: 1, h: 1.5, id: "PCBuf",
    ports: (
      north: ((id: "clk", clock: true),),
      west: ((id: "in"),),
      east: ((id: "out"),)
    ),
    fill: util.colors.green
  )

  element.block(
    x: (rel: 2, to: "PCBuf.east"),
    y: (from: "PCBuf-port-out", to: "A"),
    w: 3, h: 4, id: "IMem",
    ports: (
      west: (
        (id: "A", name: "A"),
      ),
      east: (
        (id: "RD", name: "RD"),
      )
    ),
    ports-margins: (
      west: (0%, 50%),
      east: (0%, 50%)
    ),
    fill: util.colors.green,
    name: "Instruction\nMemory"
  )
  element.block(
    x: (rel: 3, to: "IMem.east"),
    y: (from: "IMem-port-RD", to: "A1"),
    w: 4.5, h: 4, id: "RegFile",
    ports: (
      north: (
        (id: "clk", clock: true, small: true),
        (id: "WE3", name: "WE3"),
        (id: "dummy1")
      ),
      west: (
        (id: "dummy2"),
        (id: "A1", name: "A1"),
        (id: "dummy3"),
        (id: "A2", name: "A2"),
        (id: "A3", name: "A3"),
        (id: "dummy4"),
        (id: "WD3", name: "WD3"),
      ),
      east: (
        (id: "RD1", name: "RD1"),
        (id: "RD2", name: "RD2"),
      )
    ),
    ports-margins: (
      north: (-20%, -20%),
      east: (0%, 10%)
    ),
    fill: util.colors.green,
    name: "Register\nFile"
  )

  element.alu(
    x: (rel: -.7, to: "IMem.center"),
    y: -7,
    w: 1.4, h: 2.8, id: "PCAdd",
    name: text("+", size: 1.5em),
    name-anchor: "name",
    fill: util.colors.pink
  )
  element.extender(
    x: (rel: 0, to: "RegFile.west"),
    y: (from: "PCAdd-port-out", to: "in"),
    w: 4, h: 1.5, id: "Ext",
    h-ratio: 50%,
    name: "Extend",
    name-anchor: "south",
    align-out: false,
    fill: util.colors.green
  )

  element.multiplexer(
    x: (rel: 3, to: "RegFile.east"),
    y: (from: "RegFile-port-RD2", to: "in0"),
    w: .5, h: 1.5, id: "SrcBMux",
    fill: util.colors.blue,
    h-ratio: 80%
  )

  element.alu(
    x: (rel: 2, to: "SrcBMux.east"),
    y: (from: "SrcBMux-port-out", to: "in2"),
    w: 1.4, h: 2.8, id: "ALU",
    name: rotate("ALU", -90deg),
    name-anchor: "name",
    fill: util.colors.pink
  )
  element.alu(
    x: (rel: 2, to: "SrcBMux.east"),
    y: (from: "Ext-port-out", to: "in2"),
    w: 1.4, h: 2.8, id: "JumpAdd",
    name: text("+", size: 1.5em),
    name-anchor: "name",
    fill: util.colors.pink
  )

  element.block(
    x: (rel: 4, to: "ALU.east"),
    y: (from: "ALU-port-out", to: "A"),
    w: 3, h: 4, id: "DMem",
    name: "Data\nMemory",
    ports: (
      north: (
        (id: "clk", clock: true, small: true),
        (id: "dummy1"),
        (id: "WE", name: "WE")
      ),
      west: (
        (id: "A", name: "A"),
        (id: "WD", name: "WD")
      ),
      east: (
        (id: "RD", name: "RD"),
        (id: "dummy2")
      )
    ),
    ports-margins: (
      north: (-10%, -10%),
      west: (-20%, -30%),
      east: (-10%, -20%)
    ),
    fill: util.colors.green
  )

  element.multiplexer(
    x: (rel: 3, to: "DMem.east"),
    y: (from: "DMem-port-RD", to: "in1"),
    w: .5, h: 1.5, id: "ResMux",
    entries: 2,
    fill: util.colors.blue,
    h-ratio: 80%
  )

  element.block(
    x: (rel: 0, to: "RegFile.west"),
    y: 3.5, w: 2.5, h: 5, id: "Ctrl",
    name: "Control\nUnit",
    name-anchor: "north",
    ports: (
      west: (
        (id: "op", name: "op"),
        (id: "funct3", name: "funct3"),
        (id: "funct7", name: [funct7#sub("[5]")]),
        (id: "zero", name: "Zero"),
      ),
      east: (
        (id: "PCSrc"),
        (id: "ResSrc"),
        (id: "MemWrite"),
        (id: "ALUCtrl"),
        (id: "ALUSrc"),
        (id: "ImmSrc"),
        (id: "RegWrite"),
      )
    ),
    ports-margins: (
      west: (40%, 0%)
    ),
    fill: util.colors.orange
  )

  // Wires
  wire.wire(
    "wPCNext", ("PCMux-port-out", "PCBuf-port-in"),
    name: "PCNext"
  )
  wire.stub("PCBuf-port-clk", "north", name: "clk", length: 0.25)
  wire.wire(
    "wPC1", ("PCBuf-port-out", "IMem-port-A"),
    name: "PC"
  )
  wire.wire(
    "wPC2", ("PCBuf-port-out", "JumpAdd-port-in1"),
    style: "zigzag",
    zigzag-ratio: 1
  )
  wire.wire(
    "wPC3", ("PCBuf-port-out", "PCAdd-port-in1"),
    style: "zigzag",
    zigzag-ratio: 1
  )
  wire.intersection("wPC2.zig")
  wire.intersection("wPC2.zag")
  wire.stub("PCAdd-port-in2", "west", name: "4", length: 1.5)
  wire.wire(
    "wPC+4", ("PCAdd-port-out", "PCMux-port-in0"),
    style: "dodge",
    dodge-sides: ("east", "west"),
    dodge-y: -7.5,
    dodge-margins: (1.2, .5),
    name: "PC+4",
    name-pos: "start"
  )
  
  let mid = ("IMem-port-RD", 50%, "RegFile-port-A1")
  wire.wire(
    "wInstr", ("IMem-port-RD", mid),
    bus: true,
    name: "Instr",
    name-pos: "start"
  )
  draw.hide({
    draw.line(name: "bus-top",
      mid,
      (horizontal: (), vertical: "Ctrl-port-op")
    )
    draw.line(name: "bus-bot",
      mid,
      (horizontal: (), vertical: "Ext-port-in")
    )
  })
  wire.wire(
    "wInstrBus", ("bus-top.end", "bus-bot.end"),
    bus: true
  )
  wire.wire(
    "wOp", ("Ctrl-port-op", (horizontal: mid, vertical: ())),
    bus: true,
    reverse: true,
    slice: (6, 0)
  )
  wire.wire(
    "wF3", ("Ctrl-port-funct3", (horizontal: mid, vertical: ())),
    bus: true,
    reverse: true,
    slice: (14, 12)
  )
  wire.wire(
    "wF7", ("Ctrl-port-funct7", (horizontal: mid, vertical: ())),
    bus: true,
    reverse: true,
    slice: (30,)
  )
  wire.wire(
    "wA1", ("RegFile-port-A1", (horizontal: mid, vertical: ())),
    bus: true,
    reverse: true,
    slice: (19, 15)
  )
  wire.wire(
    "wA2", ("RegFile-port-A2", (horizontal: mid, vertical: ())),
    bus: true,
    reverse: true,
    slice: (24, 20)
  )
  wire.wire(
    "wA3", ("RegFile-port-A3", (horizontal: mid, vertical: ())),
    bus: true,
    reverse: true,
    slice: (11, 7)
  )
  wire.wire(
    "wExt", ("Ext-port-in", (horizontal: mid, vertical: ())),
    bus: true,
    reverse: true,
    slice: (31, 7)
  )
  wire.intersection("wF3.end")
  wire.intersection("wF7.end")
  wire.intersection("wA1.end")
  wire.intersection("wA2.end")
  wire.intersection("wA3.end")

  wire.stub("RegFile-port-clk", "north", name: "clk", length: 0.25)
  wire.wire("wRD2", ("RegFile-port-RD2", "SrcBMux-port-in0"))
  wire.wire(
    "wWD", ("RegFile-port-RD2", "DMem-port-WD"),
    style: "zigzag",
    zigzag-ratio: 1.5,
    name: "WriteData",
    name-pos: "end"
  )
  wire.intersection("wWD.zig")

  wire.wire(
    "wImmALU", ("Ext-port-out", "SrcBMux-port-in1"),
    style: "zigzag",
    zigzag-ratio: 2.5,
    name: "ImmExt",
    name-pos: "start"
  )
  wire.wire(
    "wImmJump", ("Ext-port-out", "JumpAdd-port-in2")
  )
  wire.intersection("wImmALU.zig")
  wire.wire(
    "wJumpPC", ("JumpAdd-port-out", "PCMux-port-in1"),
    style: "dodge",
    dodge-sides: ("east", "west"),
    dodge-y: -8,
    dodge-margins: (1, 1),
    name: "PCTarget",
    name-pos: "start"
  )

  wire.wire(
    "wSrcA", ("RegFile-port-RD1", "ALU-port-in1"),
    name: "SrcA",
    name-pos: "end"
  )
  wire.wire(
    "wSrcB", ("SrcBMux-port-out", "ALU-port-in2"),
    name: "SrcB",
    name-pos: "end"
  )

  wire.wire(
    "wZero", (
      ("ALU.north-east", 50%, "ALU-port-out"),
      "Ctrl-port-zero"
    ),
    style: "dodge",
    dodge-sides: ("east", "west"),
    dodge-y: 3,
    dodge-margins: (1.5, 1),
    name: "Zero",
    name-pos: "start"
  )
  wire.wire(
    "wALURes1", ("ALU-port-out", "DMem-port-A"),
    name: "ALUResult",
    name-pos: "start"
  )
  wire.wire(
    "wALURes2", ("ALU-port-out", "ResMux-port-in0"),
    style: "dodge",
    dodge-sides: ("east", "west"),
    dodge-y: 2,
    dodge-margins: (3, 2)
  )
  wire.intersection("wALURes2.start2")

  wire.stub("DMem-port-clk", "north", name: "clk", length: 0.25)
  wire.wire(
    "wRD", ("DMem-port-RD", "ResMux-port-in1"),
    name: "ReadData",
    name-pos: "start"
  )

  wire.wire(
    "wRes", ("ResMux-port-out", "RegFile-port-WD3"),
    style: "dodge",
    dodge-sides: ("east", "west"),
    dodge-y: -7.5,
    dodge-margins: (1, 2)
  )
  draw.content(
    "wRes.dodge-start",
    "Result",
    anchor: "south-east",
    padding: 5pt
  )

  // Other wires
  draw.group({
    draw.stroke(util.colors.blue)
    draw.line(name: "wPCSrc", 
      "Ctrl-port-PCSrc",
      (horizontal: "RegFile.east", vertical: ()),
      (horizontal: (), vertical: (rel: (0, 0.5), to: "Ctrl.north")),
      (horizontal: "PCMux.north", vertical: ()),
      "PCMux.north"
    )
    draw.line(name: "wResSrc",
      "Ctrl-port-ResSrc",
      (horizontal: "ResMux.north", vertical: ()),
      "ResMux.north"
    )
    draw.line(name: "wMemWrite",
      "Ctrl-port-MemWrite",
      (horizontal: "DMem-port-WE", vertical: ()),
      "DMem-port-WE"
    )
    draw.line(name: "wALUCtrl",
      "Ctrl-port-ALUCtrl",
      (horizontal: "ALU.north", vertical: ()),
      "ALU.north"
    )
    draw.line(name: "wALUSrc",
      "Ctrl-port-ALUSrc",
      (horizontal: "SrcBMux.north", vertical: ()),
      "SrcBMux.north"
    )
    draw.line(name: "wImmSrc",
      "Ctrl-port-ImmSrc",
      (rel: (1, 0), to: (horizontal: "RegFile.east", vertical: ())),
      (horizontal: (), vertical: (rel: (0, -.5), to: "RegFile.south")),
      (horizontal: "Ext.north", vertical: ()),
      "Ext.north"
    )
    draw.line(name: "wRegWrite",
      "Ctrl-port-RegWrite",
      (rel: (.5, 0), to: (horizontal: "RegFile.east", vertical: ())),
      (horizontal: (), vertical: ("Ctrl.south", 50%, "RegFile.north")),
      (horizontal: "RegFile-port-WE3", vertical: ()),
      "RegFile-port-WE3"
    )

    let names = (
      "PCSrc": "PCSrc",
      "ResSrc": "ResultSrc",
      "MemWrite": "MemWrite",
      "ALUCtrl": [ALUControl#sub("[2:0]")],
      "ALUSrc": "ALUSrc",
      "ImmSrc": [ImmSrc#sub("[1:0]")],
      "RegWrite": "RegWrite"
    )
    for (port, name) in names {
      draw.content("Ctrl-port-"+port, name, anchor: "south-west", padding: 3pt)
    }
  })
})