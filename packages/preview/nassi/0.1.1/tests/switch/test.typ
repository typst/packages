#import "../../src/nassi.typ"

#nassi.diagram({
  nassi.elements.switch(
    "trafficLight",
    (
      red: {
        nassi.elements.process("pressBrakes()")
        nassi.elements.assign("Ignission", "off")
      },
      yellow: {
        nassi.elements.assign("Ignission", "on")
      },
      green: {
        nassi.elements.process("accelerate()")
      },
      default: { },
    ),
  )
})
#v(1cm)

#nassi.diagram({
  nassi.elements.switch(
    "trafficLight",
    (
      red: {
        nassi.elements.process("pressBrakes()")
        nassi.elements.assign("Ignission", "off")
      },
      yellow: {
        nassi.elements.assign("Ignission", "on")
      },
      green: {
        nassi.elements.process("accelerate()")
      },
      default: { },
    ),
    labels: ("A", "B", "C"),
    fill: red,
    height: 1.5,
  )
})
