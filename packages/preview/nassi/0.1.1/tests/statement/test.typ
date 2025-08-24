#import "../../src/nassi.typ"

#nassi.diagram({
  nassi.elements.process("Statement 1")
})
#v(1cm)

#nassi.diagram({
  nassi.elements.process("Statement 1")
  nassi.elements.process("Statement 2")
})
#v(1cm)

#block(
  width: 12cm,
  nassi.diagram({
    nassi.elements.process("Statement 1")
    nassi.elements.process("Statement 2")
  }),
)
#v(1cm)

#nassi.diagram({
  nassi.elements.process("Statement 1", fill: red)
  nassi.elements.process("Statement 2", height: 2)
})
#v(1cm)
