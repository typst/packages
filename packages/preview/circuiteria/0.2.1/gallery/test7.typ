#import "@preview/circuiteria:0.2.1": circuit, element, util, wire

#set page(width: auto, height: auto, margin: .5cm)

#circuit({
  element.iec-gate-buf(
    x: 0,
    y: 0,
    w: 2,
    h: 2,
    id: "iec-buf",
    inputs: 1,
  )
  wire.stub("iec-buf-port-in0", "west")

  element.iec-gate-not(
    x: 3,
    y: 0,
    w: 2,
    h: 2,
    id: "iec-not",
    inputs: 1,
  )
  wire.stub("iec-not-port-in0", "west")

  element.iec-gate-and(
    id: "iec-and",
    x: 0,
    y: -3,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-and-port-in" + str(i), "west")
  }

  element.iec-gate-nand(
    id: "iec-nand",
    x: 3,
    y: -3,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-nand-port-in" + str(i), "west")
  }

  element.iec-gate-or(
    id: "iec-or",
    x: 0,
    y: -6,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-or-port-in" + str(i), "west")
  }

  element.iec-gate-nor(
    id: "iec-nor",
    x: 3,
    y: -6,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-nor-port-in" + str(i), "west")
  }

  element.iec-gate-xor(
    id: "iec-xor",
    x: 0,
    y: -9,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-xor-port-in" + str(i), "west")
  }

  element.iec-gate-xnor(
    id: "iec-nxor",
    x: 3,
    y: -9,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-nxor-port-in" + str(i), "west")
  }
})