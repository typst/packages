#import "/src/lib.typ" as chronos

#chronos.from-plantuml(```plantuml
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response

Alice -> Bob: Another authentication Request
Alice <-- Bob: Another authentication Response
```)


#chronos.diagram({
  import chronos: *
  _seq("Alice", "Bob", comment: "Authentication Request")
  _seq("Bob", "Alice", comment: "Authentication Response", dashed: true)
  
  _seq("Alice", "Bob", comment: "Another authentication Request")
  _seq("Bob", "Alice", comment: "Another authentication Response", dashed: true)
})

#chronos.diagram({
  import chronos: *
  _seq("Bob", "Alice", comment: "bonjour", color: red)
  _seq("Alice", "Bob", comment: "ok", color: blue)
})

#chronos.diagram({
  import chronos: *
  _seq("Alice", "Bob", comment: "This is a test")
  _seq("Alice", "Callum", comment: "This is another test with a long text")
})

#chronos.diagram({
  import chronos: *
  _seq("Alice", "Bob", comment: "Authentication Request")
  _seq("Bob", "Alice", comment: "Authentication Failure")

  _grp("My own label", desc: "My own label2", {
    _seq("Alice", "Log", comment: "Log attack start")
    _grp("loop", desc: "1000 times", {
      _seq("Alice", "Bob", comment: "DNS Attack")
    })
    _seq("Alice", "Bob", comment: "Log attack end")
  })
})

#chronos.diagram({
  import chronos: *
  _sep("Initialization")
  _seq("Alice", "Bob", comment: "Authentication Request")
  _seq("Bob", "Alice", comment: "Authentication Response", dashed: true)
  
  _sep("Repetition")
  _seq("Alice", "Bob", comment: "Another authentication Request")
  _seq("Bob", "Alice", comment: "another authentication Response", dashed: true)
})

#chronos.diagram({
  import chronos: *
  _seq("Alice", "Bob", comment: "message 1")
  _seq("Bob", "Alice", comment: "ok", dashed: true)
  _gap()
  _seq("Alice", "Bob", comment: "message 2")
  _seq("Bob", "Alice", comment: "ok", dashed: true)
  _gap(size: 45)
  _seq("Alice", "Bob", comment: "message 3")
  _seq("Bob", "Alice", comment: "ok", dashed: true)
})

#chronos.diagram({
  import chronos: *
  _seq("Alice", "Alice", comment: "On the\nright")
  _seq("Alice", "Alice", flip: true, comment: "On the\nleft")
})