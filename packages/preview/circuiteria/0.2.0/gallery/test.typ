#import "../src/lib.typ": circuit, element, util, wire

#set page(width: auto, height: auto, margin: .5cm)

#circuit({
  element.block(
    x: 0, y: 0, w: 1.5, h: 2.2,
    id: "PCBuf",
    fill: util.colors.orange,
    ports: (
      west: (
        (id: "PCNext"),
      ),
      north: (
        (id: "CLK", clock: true),
      ),
      east: (
        (id: "PC"),
      ),
      south: (
        (id: "EN", name: "EN"),
      )
    )
  )
  wire.stub("PCBuf-port-CLK", "north", name: "CLK")
  wire.stub("PCBuf-port-EN", "south", name: "PCWrite")
  
  element.multiplexer(
    x: 3, y: (from: "PCBuf-port-PC", to: "in0"), w: 1, h: 2,
    id: "AdrSrc-MP",
    fill: util.colors.orange,
    entries: 2
  )
  wire.wire(
    "wPCBuf-InstDataMgr", (
      "PCBuf-port-PC",
      "AdrSrc-MP-port-in0"
    ),
    name: "PC",
    bus: true
  )
  wire.stub("AdrSrc-MP.north", "north", name: "AdrSrc")
  
  element.block(
    x: 6, y: (from: "AdrSrc-MP-port-out", to: "A"), w: 3, h: 4,
    id: "InstDataMgr",
    fill: util.colors.yellow,
    ports: (
      west: (
        (id: "A", name: "A"),
        (id: "WD", name: "WD")
      ),
      north: (
        (id: "CLK", clock: true),
        (id: "WE", name: "WE", vertical: true),
        (id: "IRWrite", name: "IRWrite", vertical: true)
      ),
      east: (
        (id: "Instr", name: "Instr."),
        (id: "RD", name: "RD")
      )
    ),
    ports-margins: (
      west: (30%, 0%),
      east: (40%, 0%)
    )
  )
  wire.wire(
    "wAdrSrcMP-InstDataMgr", (
      "AdrSrc-MP-port-out",
      "InstDataMgr-port-A"
    ),
    name: "Adr",
    name-pos: "end",
    bus: true
  )
  
  wire.stub("InstDataMgr-port-CLK", "north", name: "CLK")
  wire.stub("InstDataMgr-port-WE", "north")
  wire.stub("InstDataMgr-port-IRWrite", "north")
  wire.stub("InstDataMgr-port-WD", "west")

  element.block(
    x: 15, y: (from: "InstDataMgr-port-RD", to: "WD3"), w: 3, h: 4,
    id: "RegFile",
    fill: util.colors.pink,
    ports: (
      west: (
        (id: "A1", name: "A1"),
        (id: "A2", name: "A2"),
        (id: "A3", name: "A3"),
        (id: "WD3", name: "WD3"),
      ),
      north: (
        (id: "CLK", clock: true),
        (id: "WE3", name: "WE3", vertical: true)
      ),
      east: (
        (id: "RD1", name: "RD1"),
        (id: "RD2", name: "RD2"),
      )
    ),
    ports-margins: (
      east: (20%, 20%)
    )
  )
  wire.stub("RegFile-port-CLK", "north", name: "CLK")
  wire.stub("RegFile-port-WE3", "north", name: "Regwrite", name-offset: 0.6)
  wire.stub("RegFile-port-A2", "west")
  wire.stub("RegFile-port-RD2", "east")

  element.extender(
    x: 15, y: -3.5, w: 3, h: 1,
    id: "Extender",
    fill: util.colors.green
  )
  wire.wire(
    "wExtender-ImmSrc", (
      "Extender.north",
      (18, -2)
    ),
    style: "zigzag",
    zigzag-ratio: 0%,
    name: "ImmSrc",
    name-pos: "end",
    bus: true
  )

  let mid = ("InstDataMgr.east", 50%, "RegFile.west")
  wire.wire(
    "wInstDataMgr-Bus", (
      "InstDataMgr-port-Instr",
      (vertical: (), horizontal: mid)
    ),
    name: "Instr",
    name-pos: "start",
    bus: true
  )
  wire.wire(
    "wBus", (
      (v => (v.at(0), -3.5), mid),
      (horizontal: (), vertical: (0, 3.5)),
    ),
    bus: true
  )
  wire.wire(
    "wBus-RegFile-A1", (
      "RegFile-port-A1",
      (horizontal: mid, vertical: ()),
    ),
    name: "RS1",
    name-pos: "end",
    slice: (19, 15),
    reverse: true,
    bus: true
  )
  wire.wire(
    "wBus-RegFile-A3", (
      "RegFile-port-A3",
      (horizontal: mid, vertical: ()),
    ),
    name: "RD",
    name-pos: "end",
    slice: (11, 7),
    reverse: true,
    bus: true
  )
  wire.wire(
    "wBus-Extender", (
      "Extender-port-in",
      (horizontal: mid, vertical: ()),
    ),
    slice: (31, 7),
    reverse: true,
    bus: true
  )

  element.alu(
    x: 22, y: (from: "RegFile-port-RD1", to: "in1"), w: 1, h: 2,
    id: "ALU",
    fill: util.colors.purple
  )
  wire.wire(
    "wRegFile-ALU", (
      "RegFile-port-RD1",
      "ALU-port-in1"
    ),
    name: ("A", "SrcA"),
    bus: true
  )

  element.block(
    x: 26, y: (from: "ALU-port-out", to: "in"), w: 1.5, h: 2,
    id: "OutBuf",
    fill: util.colors.orange,
    ports: (
      west: (
        (id: "in"),
      ),
      north: (
        (id: "CLK", clock: true),
      ),
      east: (
        (id: "out"),
      )
    )
  )
  wire.stub("OutBuf-port-CLK", "north", name: "CLK")
  wire.wire(
    "wALU-OutBuf", (
      "ALU-port-out",
      "OutBuf-port-in"
    ),
    name: "ALUResult",
    bus: true
  )

  element.multiplexer(
    x: 30, y: (from: "OutBuf-port-out", to: "in0"), w: 1, h: 2.5,
    id: "Res-MP",
    fill: util.colors.orange,
    entries: 3
  )
  wire.stub("Res-MP.north", "north", name: "ResultSrc")
  wire.stub("Res-MP-port-in2", "west")
  wire.wire(
    "wOutBuf-ResMP", (
      "OutBuf-port-out",
      "Res-MP-port-in0"
    ),
    name: "ALUOut",
    bus: true
  )

  wire.wire(
    "wExt-ALU", (
      "Extender-port-out",
      "ALU-port-in2",
    ),
    name: ("ImmExt", "SrcB"),
    bus: true,
    style: "zigzag",
    zigzag-ratio: 60%
  )

  wire.wire(
    "wInstDataMgr-ResMP", (
      "InstDataMgr-port-RD",
      "Res-MP-port-in1"
    ),
    style: "dodge",
    dodge-y: -4,
    dodge-sides: ("east", "west"),
    name: "Data",
    name-pos: "start",
    bus: true
  )

  wire.wire(
    "wResMP-AdrSrc", (
      "Res-MP-port-out",
      "AdrSrc-MP-port-in1"
    ),
    style: "dodge",
    dodge-y: -5,
    dodge-sides: ("east", "west"),
    dodge-margins: (0.5, 1),
    bus: true
  )

  wire.wire(
    "wResMP-RegFile", (
      "Res-MP-port-out",
      "RegFile-port-WD3"
    ),
    style: "dodge",
    dodge-y: -5,
    dodge-sides: ("east", "west"),
    dodge-margins: (0.5, 1),
    bus: true
  )

  wire.wire(
    "wResMP-PCBuf", (
      "Res-MP-port-out",
      "PCBuf-port-PCNext"
    ),
    style: "dodge",
    dodge-y: -5,
    dodge-sides: ("east", "west"),
    dodge-margins: (0.5, 1.5),
    name: "PCNext",
    name-pos: "end",
    bus: true
  )

  wire.intersection("wResMP-RegFile.dodge-end", radius: .2)
  wire.intersection("wResMP-AdrSrc.dodge-end", radius: .2)
})