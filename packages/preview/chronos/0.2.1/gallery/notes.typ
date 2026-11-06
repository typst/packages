#import "/src/lib.typ" as chronos: *

#set page(width: auto, height: auto)
#chronos.diagram({
  _par("a", display-name: "Alice")
  _par("b", display-name: "Bob")

  _seq("a", "b", comment: [hello])
  _note("left", [this is a first note])

  _seq("b", "a", comment: [ok])
  _note("right", [this is another note])

  _seq("b", "b", comment: [I am thinking])
  _note("left", [a note\ can also be defined\ on several lines])
})

#pagebreak()

#chronos.diagram({
  _par("a", display-name: "Alice")
  _par("b", display-name: "Bob")

  _note("left", [This is displayed\ left of Alice.], pos: "a", color: rgb("#00FFFF"))
  _note("right", [This is displayed right of Alice.], pos: "a")
  _note("over", [This is displayed over Alice.], pos: "a")
  _note("over", [This is displayed\ over Bob and Alice.], pos: ("a", "b"), color: rgb("#FFAAAA"))
  _note("over", [This is yet another\ example of\ a long note.], pos: ("a", "b"))
})

#pagebreak()

#chronos.diagram({
  _par("caller")
  _par("server")

  _seq("caller", "server", comment: [conReq])
  _note("over", [idle], pos: "caller", shape: "hex")
  _seq("server", "caller", comment: [conConf])
  _note("over", ["r" as rectangle\ "h" as hexagon], pos: "server", shape: "rect")
  _note("over", [this is\ on several\ lines], pos: "server", shape: "rect")
  _note("over", [this is\ on several\ lines], pos: "caller", shape: "hex")
})

#pagebreak()

#chronos.diagram({
  _par("a", display-name: "Alice")
  _par("b", display-name: "Bob")
  _par("c", display-name: "Charlie")

  _seq("a", "b", comment: [m1])
  _seq("b", "c", comment: [m2])

  _note("over", [Old method for note over all part. with:\ `note over FirstPart, LastPart`.], pos: ("a", "c"))
  _note("across", [New method with:\ `note across`.])

  _seq("b", "a")

  _note("across", [Note across all part.], shape: "hex")
})

#pagebreak()

#chronos.diagram({
  _par("a", display-name: "Alice")
  _par("b", display-name: "Bob")

  _note("over", [initial state of Alice], pos: "a")
  _note("over", [initial state of Bob], pos: "b")
  _seq("b", "a", comment: [hello])
})

#chronos.diagram({
  _par("a", display-name: "Alice")
  _par("b", display-name: "Bob")
  _par("c", display-name: "Charlie")
  _par("d", display-name: "Donald")
  _par("e", display-name: "Eddie")

  _note("over", [initial state of Alice], pos: "a")
  _note("over", [initial state of Bob the builder], pos: "b", aligned: true)

  _note("over", [Note 1], pos: "a")
  _note("over", [Note 2], pos: "b", aligned: true)
  _note("over", [Note 3], pos: "c", aligned: true)

  _seq("a", "d")
  _note("over", [this is an extremely long note], pos: ("d", "e"))
})

#pagebreak()

#chronos.diagram({
  _par("a", display-name: [Alice])
  _par("b", display-name: [The *Famous* Bob])

  _seq("a", "b", comment: [hello #strike([there])])

  _gap()
  _seq("b", "a", comment: [ok])
  _note("left", [
    This is *bold*\
    This is _italics_\
    This is `monospaced`\
    This is #strike([stroked])\
    This is #underline([underlined])\
    This is #underline([waved])\
  ])

  _seq("a", "b", comment: [A _well formatted_ message])
  _note("right", [
    This is #box(text([displayed], size: 18pt), fill: rgb("#5F9EA0"))\
    #underline([left of]) Alice.
  ], pos: "a")
  _note("left", [
    #underline([This], stroke: red) is #text([displayed], fill: rgb("#118888"))\
    *#text([left of], fill: rgb("#800080")) #strike([Alice], stroke: red) Bob.*
  ], pos: "b")
  _note("over", [
    #underline([This is hosted], stroke: rgb("#FF33FF")) by #box(baseline: 50%, image("gitea.png", width: 1cm, height: 1cm, fit: "contain"))
  ], pos: ("a", "b"))
})

// TODO
/*
#pagebreak()

#chronos.diagram({
  _par("a", display-name: [Alice])
  _par("b", display-name: [Bob])

  _seq("a", "b", comment: [Hello])
  _note("left", [This is a note])

  _seq("[", "a", comment: [Test])
  _note("left", [This is also a note])
})*/

#pagebreak()

#chronos.diagram({
  _seq("Bob", "Alice", comment: [Hello])
  _evt("Other", "create")
})