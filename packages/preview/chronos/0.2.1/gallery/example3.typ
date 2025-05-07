#import "/src/lib.typ" as chronos

#set page(width: auto, height: auto)

#let TYPST = image("typst.png", width: 1.5cm, height: 1.5cm, fit: "contain")
#let FERRIS = image("ferris.png", width: 1.5cm, height: 1.5cm, fit: "contain")
#let ME = image("me.jpg", width: 1.5cm, height: 1.5cm, fit: "contain")

#chronos.diagram({
  import chronos: *
  _par("Foo", display-name: "Participant", shape: "participant")
  _par("Foo1", display-name: "Actor", shape: "actor")
  _par("Foo2", display-name: "Boundary", shape: "boundary")
  _par("Foo3", display-name: "Control", shape: "control")
  _par("Foo4", display-name: "Entity", shape: "entity")
  _par("Foo5", display-name: "Database", shape: "database")
  _par("Foo6", display-name: "Collections", shape: "collections")
  _par("Foo7", display-name: "Queue", shape: "queue")
  _par("Foo8", display-name: "Typst", shape: "custom", custom-image: TYPST)
  _par("Foo9", display-name: "Ferris", shape: "custom", custom-image: FERRIS)
  _par("Foo10", display-name: "Baryhobal", shape: "custom", custom-image: ME)

  _seq("Foo", "Foo1", comment: "To actor")
  _seq("Foo", "Foo2", comment: "To boundary")
  _seq("Foo", "Foo3", comment: "To control")
  _seq("Foo", "Foo4", comment: "To entity")
  _seq("Foo", "Foo5", comment: "To database")
  _seq("Foo", "Foo6", comment: "To collections")
  _seq("Foo", "Foo7", comment: "To queue")
  _seq("Foo", "Foo8", comment: "To Typst")
  _seq("Foo", "Foo9", comment: "To ferris")
  _seq("Foo", "Foo10", comment: "To Baryhobal")
})

#pagebreak()
#chronos.diagram({
  import chronos: *
  _par("me", display-name: "Me", shape: "custom", custom-image: ME)
  _par("typst", display-name: "Typst", shape: "custom", custom-image: TYPST)
  _par("rust", display-name: "Rust", shape: "custom", custom-image: FERRIS)

  _seq("me", "typst", comment: "opens document", enable-dst: true)
  _seq("me", "typst", comment: "types document")
  _seq("typst", "rust", comment: "compiles content", enable-dst: true)
  _seq("rust", "typst", comment: "renders document", disable-src: true)
  _seq("typst", "me", comment: "displays document")
  _evt("typst", "disable")
})

#pagebreak()

#stack(dir: ltr, spacing: 1em,
chronos.diagram({
  import chronos: *

  _par("a", display-name: "Alice")
  _par("b", display-name: "Bob")

  _seq("a", "b", end-tip: ">", comment: `->`)
  _seq("a", "b", end-tip: ">>", comment: `->>`)
  _seq("a", "b", end-tip: "\\", comment: `-\`)
  _seq("a", "b", end-tip: "\\\\", comment: `-\\`)
  _seq("a", "b", end-tip: "/", comment: `-/`)
  _seq("a", "b", end-tip: "//", comment: `-//`)
  _seq("a", "b", end-tip: "x", comment: `->x`)
  _seq("a", "b", start-tip: "x", comment: `x->`)
  _seq("a", "b", start-tip: "o", comment: `o->`)
  _seq("a", "b", end-tip: ("o", ">"), comment: `->o`)
  _seq("a", "b", start-tip: "o", end-tip: ("o", ">"), comment: `o->o`)
  _seq("a", "b", start-tip: ">", end-tip: ">", comment: `<->`)
  _seq("a", "b", start-tip: ("o", ">"), end-tip: ("o", ">"), comment: `o<->o`)
  _seq("a", "b", start-tip: "x", end-tip: "x", comment: `x<->x`)
  _seq("a", "b", end-tip: ("o", ">>"), comment: `->>o`)
  _seq("a", "b", end-tip: ("o", "\\"), comment: `-\o`)
  _seq("a", "b", end-tip: ("o", "\\\\"), comment: `-\\o`)
  _seq("a", "b", end-tip: ("o", "/"), comment: `-/o`)
  _seq("a", "b", end-tip: ("o", "//"), comment: `-//o`)
  _seq("a", "b", start-tip: "x", end-tip: ("o", ">"), comment: `x->o`)
}),

chronos.diagram({
  import chronos: *

  _par("a", display-name: "Alice")
  _par("b", display-name: "Bob")

  _seq("b", "a", end-tip: ">", comment: `->`)
  _seq("b", "a", end-tip: ">>", comment: `->>`)
  _seq("b", "a", end-tip: "\\", comment: `-\`)
  _seq("b", "a", end-tip: "\\\\", comment: `-\\`)
  _seq("b", "a", end-tip: "/", comment: `-/`)
  _seq("b", "a", end-tip: "//", comment: `-//`)
  _seq("b", "a", end-tip: "x", comment: `->x`)
  _seq("b", "a", start-tip: "x", comment: `x->`)
  _seq("b", "a", start-tip: "o", comment: `o->`)
  _seq("b", "a", end-tip: ("o", ">"), comment: `->o`)
  _seq("b", "a", start-tip: "o", end-tip: ("o", ">"), comment: `o->o`)
  _seq("b", "a", start-tip: ">", end-tip: ">", comment: `<->`)
  _seq("b", "a", start-tip: ("o", ">"), end-tip: ("o", ">"), comment: `o<->o`)
  _seq("b", "a", start-tip: "x", end-tip: "x", comment: `x<->x`)
  _seq("b", "a", end-tip: ("o", ">>"), comment: `->>o`)
  _seq("b", "a", end-tip: ("o", "\\"), comment: `-\o`)
  _seq("b", "a", end-tip: ("o", "\\\\"), comment: `-\\o`)
  _seq("b", "a", end-tip: ("o", "/"), comment: `-/o`)
  _seq("b", "a", end-tip: ("o", "//"), comment: `-//o`)
  _seq("b", "a", start-tip: "x", end-tip: ("o", ">"), comment: `x->o`)
}),

chronos.diagram({
  import chronos: *

  _par("a", display-name: "Alice")
  _par("b", display-name: "Bob")

  _seq("a", "a", end-tip: ">", comment: `->`)
  _seq("a", "a", end-tip: ">>", comment: `->>`)
  _seq("a", "a", end-tip: "\\", comment: `-\`)
  _seq("a", "a", end-tip: "\\\\", comment: `-\\`)
  _seq("a", "a", end-tip: "/", comment: `-/`)
  _seq("a", "a", end-tip: "//", comment: `-//`)
  _seq("a", "a", end-tip: "x", comment: `->x`)
  _seq("a", "a", start-tip: "x", comment: `x->`)
  _seq("a", "a", start-tip: "o", comment: `o->`)
  _seq("a", "a", end-tip: ("o", ">"), comment: `->o`)
  _seq("a", "a", start-tip: "o", end-tip: ("o", ">"), comment: `o->o`)
  _seq("a", "a", start-tip: ">", end-tip: ">", comment: `<->`)
  _seq("a", "a", start-tip: ("o", ">"), end-tip: ("o", ">"), comment: `o<->o`)
  _seq("a", "a", start-tip: "x", end-tip: "x", comment: `x<->x`)
  _seq("a", "a", end-tip: ("o", ">>"), comment: `->>o`)
  _seq("a", "a", end-tip: ("o", "\\"), comment: `-\o`)
  _seq("a", "a", end-tip: ("o", "\\\\"), comment: `-\\o`)
  _seq("a", "a", end-tip: ("o", "/"), comment: `-/o`)
  _seq("a", "a", end-tip: ("o", "//"), comment: `-//o`)
  _seq("a", "a", start-tip: "x", end-tip: ("o", ">"), comment: `x->o`)
})
)

#chronos.diagram({
  import chronos: *

  _par("a", display-name: "Alice")
  _par("b", display-name: "Bob", show-bottom: false)
  _par("c", display-name: "Caleb", show-top: false)
  _par("d", display-name: "Danny", show-bottom: false, show-top: false)

  _gap()
})

#chronos.diagram({
  import chronos: *

  _par("a", display-name: "Alice")
  _par("b", display-name: "Bob")
  _par("c", display-name: "Caleb")
  _par("d", display-name: "Danny")
  _par("e", display-name: "Erika")

  _col("a", "b")
  _col("b", "c", width: 2cm)
  _col("c", "d", margin: .5cm)
  _col("d", "e", min-width: 2cm)

  //_seq("b", "c", comment: [Hello World !])
  //_seq("c", "d", comment: [Hello World])
  //_seq("d", "e", comment: [Hello World])
})