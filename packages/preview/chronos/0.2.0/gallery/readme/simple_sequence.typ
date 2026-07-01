#import "/src/lib.typ" as chronos

#set page(
  width: auto,
  height: auto,
  margin: 0.5cm
)

#chronos.diagram({
  import chronos: *
  _par("Alice")
  _par("Bob")

  _seq("Alice", "Bob", comment: "Hello")
  _seq("Bob", "Bob", comment: "Think")
  _seq("Bob", "Alice", comment: "Hi")
})