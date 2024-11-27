#import "/src/lib.typ" as chronos

#set page(
  width: auto,
  height: auto,
  margin: 0.5cm
)

#chronos.diagram({
  import chronos: *
  _par("A", display-name: "Alice")
  _par("B", display-name: "Bob")
  _par("C", display-name: "Charlie")
  _par("D", display-name: "Derek")

  _seq("A", "B", comment: "hello", enable-dst: true)
  _seq("B", "B", comment: "self call", enable-dst: true)
  _seq("C", "B", comment: "hello from thread 2", enable-dst: true, lifeline-style: (fill: rgb("#005500")))
  _seq("B", "D", comment: "create", create-dst: true)
  _seq("B", "C", comment: "done in thread 2", disable-src: true, dashed: true)
  _seq("B", "B", comment: "rc", disable-src: true, dashed: true)
  _seq("B", "D", comment: "delete", destroy-dst: true)
  _seq("B", "A", comment: "success", disable-src: true, dashed: true)
})