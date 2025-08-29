#import "/src/lib.typ" as chronos


#chronos.diagram({
  import chronos: *
  _seq("User", "A", comment: "DoWork", enable-dst: true)
  _seq("A", "B", comment: [#sym.quote.angle.l createRequest #sym.quote.angle.r], enable-dst: true)
  _seq("B", "C", comment: "DoWork", enable-dst: true)
  _seq("C", "B", comment: "WorkDone", destroy-src: true, disable-src: true, dashed: true)
  _seq("B", "A", comment: "RequestCreated", disable-src: true, dashed: true)
  _seq("A", "User", comment: "Done", disable-src: true)
})

#chronos.diagram({
  import chronos: *
  _seq("User", "A", comment: "DoWork", enable-dst: true, lifeline-style: (fill: rgb("#FFBBBB")))
  _seq("A", "A", comment: "Internal call", enable-dst: true, lifeline-style: (fill: rgb("#E9967A")))
  _seq("A", "B", comment: [#sym.quote.angle.l createRequest #sym.quote.angle.r], enable-dst: true)
  _seq("B", "A", comment: "RequestCreated", disable-src: true, disable-dst: true, dashed: true)
  _seq("A", "User", comment: "Done", disable-src: true)
})

#chronos.diagram({
  import chronos: *
  _seq("alice", "bob", comment: "hello", enable-dst: true)
  _seq("bob", "bob", comment: "self call", enable-dst: true)
  _seq("bill", "bob", comment: "hello from thread 2", enable-dst: true, lifeline-style: (fill: rgb("#005500")))
  _seq("bob", "george", comment: "create", create-dst: true)
  _seq("bob", "bill", comment: "done in thread 2", disable-src: true, dashed: true)
  _seq("bob", "bob", comment: "rc", disable-src: true, dashed: true)
  _seq("bob", "george", comment: "delete", destroy-dst: true)
  _seq("bob", "alice", comment: "success", disable-src: true, dashed: true)
})

#chronos.diagram({
  import chronos: *
  _seq("alice", "bob", comment: "hello1", enable-dst: true)
  _seq("bob", "charlie", comment: "hello2", enable-dst: true, disable-src: true)
  _seq("charlie", "alice", comment: "ok", dashed: true, disable-src: true)
})

#chronos.diagram({
  import chronos: *
  _seq("?", "Alice", comment: [?->\ *short* to actor1])
  _seq("[", "Alice", comment: [\[->\ *from start* to actor1])
  _seq("[", "Bob", comment: [\[->\ *from start* to actor2])
  _seq("?", "Bob", comment: [?->\ *short* to actor2])
  _seq("Alice", "]", comment: [->\]\ from actor1 *to end*])
  _seq("Alice", "?", comment: [->?\ *short* from actor1])
  _seq("Alice", "Bob", comment: [->\ from actor1 to actor2])
})

#chronos.diagram({
  import chronos: *
  _par("alice", display-name: "Alice")
  _par("bob", display-name: "Bob")
  _par("craig", display-name: "Craig")

  _seq("bob", "alice")
  _seq("bob", "craig")
  _gap()
  
  _sync({
    _seq("bob", "alice", comment: "Synched", comment-align: "start")
    _seq("bob", "craig", comment: "Synched", comment-align: "start")
  })
  _gap()
  
  _seq("alice", "bob")
  _seq("craig", "bob")
  _gap()
  
  _sync({
    _seq("alice", "bob")
    _seq("craig", "bob")
  })
  _gap()
  
  _sync({
    _seq("alice", "bob", enable-dst: true)
    _seq("craig", "bob")
  })
  _gap()

  _evt("bob", "disable")
})

#chronos.diagram({
  import chronos: *
  _par("alice", display-name: "Alice")
  _par("bob", display-name: "Bob")
  _par("craig", display-name: "Craig")

  _seq("alice", "bob")
  _seq("bob", "craig", slant: auto)
  _seq("alice", "craig", slant: 20)

  _sync({
    _seq("alice", "bob", slant: 10)
    _seq("craig", "bob", slant: 20)
  })

  _sync({
    _seq("alice", "bob", slant: auto)
    _seq("bob", "alice", slant: auto)
  })

  _gap()
  _evt("bob", "disable")
})

#grid(columns: 2, column-gutter: 2em,
  chronos.diagram({
    import chronos: *

    _par("alice", display-name: "Alice")
    _par("bob", display-name: "Bob")
    _seq("alice", "bob", comment: "This is a very long comment")

    // Left to right
    _seq("alice", "bob", comment: "Start aligned", comment-align: "start")
    _seq("alice", "bob", comment: "End aligned", comment-align: "end")
    _seq("alice", "bob", comment: "Left aligned", comment-align: "left")
    _seq("alice", "bob", comment: "Right aligned", comment-align: "right")
    _seq("alice", "bob", comment: "Centered", comment-align: "center")
    _gap()

    // Right to left
    _seq("bob", "alice", comment: "Start aligned", comment-align: "start")
    _seq("bob", "alice", comment: "End aligned", comment-align: "end")
    _seq("bob", "alice", comment: "Left aligned", comment-align: "left")
    _seq("bob", "alice", comment: "Right aligned", comment-align: "right")
    _seq("bob", "alice", comment: "Centered", comment-align: "center")
    _gap()

    // Slant left to right
    _seq("alice", "bob", comment: "Start aligned", comment-align: "start", slant: 10)
    _seq("alice", "bob", comment: "End aligned", comment-align: "end", slant: 10)
    _seq("alice", "bob", comment: "Left aligned", comment-align: "left", slant: 10)
    _seq("alice", "bob", comment: "Right aligned", comment-align: "right", slant: 10)
    _seq("alice", "bob", comment: "Centered", comment-align: "center", slant: 10)
    _gap()

    // Slant right to left
    _seq("bob", "alice", comment: "Start aligned", comment-align: "start", slant: 10)
    _seq("bob", "alice", comment: "End aligned", comment-align: "end", slant: 10)
    _seq("bob", "alice", comment: "Left aligned", comment-align: "left", slant: 10)
    _seq("bob", "alice", comment: "Right aligned", comment-align: "right", slant: 10)
    _seq("bob", "alice", comment: "Centered", comment-align: "center", slant: 10)
  }),

  chronos.diagram({
    import chronos: *

    _par("alice", display-name: "Alice")

    _seq("alice", "alice", comment: "Start aligned", comment-align: "start")
    _seq("alice", "alice", comment: "End aligned", comment-align: "end")
    _seq("alice", "alice", comment: "Left aligned", comment-align: "left")
    _seq("alice", "alice", comment: "Right aligned", comment-align: "right")
    _seq("alice", "alice", comment: "Centered", comment-align: "center")

    _seq("alice", "alice", comment: "Start aligned", comment-align: "start", flip: true)
    _seq("alice", "alice", comment: "End aligned", comment-align: "end", flip: true)
    _seq("alice", "alice", comment: "Left aligned", comment-align: "left", flip: true)
    _seq("alice", "alice", comment: "Right aligned", comment-align: "right", flip: true)
    _seq("alice", "alice", comment: "Centered", comment-align: "center", flip: true)
  })
)