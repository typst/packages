#import "example.typ": example

#let seq-return = example(```
_seq(
  "Bob", "Alice",
  comment: [hello],
  enable-dst: true
)
_seq(
  "Alice", "Alice",
  comment: [some action]
)
_ret(comment: [bye])
```)

#let seq-comm-align = example(```
_par("p1",
     display-name: "Start participant")
_par("p2",
     display-name: "End participant")
let alignments = (
  "start", "end",
  "left", "right",
  "center"
)
for a in alignments {
  _seq(
    "p2", "p1",
    comment: raw(a),
    comment-align: a
  )
}
```)

#let seq-tips = example(```
let _seq = _seq.with(comment-align: "center")
_par("a", display-name: "Alice")
_par("b", display-name: "Bob")

_seq("a", "b", comment: "Various tips", end-tip: "")
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
_seq("a", "b", start-tip: "o",
               end-tip: ("o", ">"), comment: `o->o`)
_seq("a", "b", start-tip: ">",
               end-tip: ">", comment: `<->`)
_seq("a", "b", start-tip: ("o", ">"),
               end-tip: ("o", ">"), comment: `o<->o`)
_seq("a", "b", start-tip: "x",
               end-tip: "x", comment: `x<->x`)
_seq("a", "b", end-tip: ("o", ">>"), comment: `->>o`)
_seq("a", "b", end-tip: ("o", "\\"), comment: `-\o`)
_seq("a", "b", end-tip: ("o", "\\\\"), comment: `-\\o`)
_seq("a", "b", end-tip: ("o", "/"), comment: `-/o`)
_seq("a", "b", end-tip: ("o", "//"), comment: `-//o`)
_seq("a", "b", start-tip: "x",
               end-tip: ("o", ">"), comment: `x->o`)
```)

#let grp = example(```
_par("a", display-name: "Alice")
_par("b", display-name: "Bob")

_grp("Group 1", desc: "Description", {
  _seq("a", "b", comment: "Authentication")
  _grp("loop", desc: "1000 times", {
    _seq("a", "b", comment: "DoS Attack")
  })
  _seq("a", "b", end-tip: "x")
})
```)

#let alt = example(```
_par("a", display-name: "Alice")
_par("b", display-name: "Bob")

_alt(
  "first encounter", {
    _seq("a", "b", comment: "Who are you ?")
    _seq("b", "a", comment: "I'm Bob")
  },

  "know eachother", {
    _seq("a", "b", comment: "Hello Bob")
    _seq("b", "a", comment: "Hello Alice")
  },

  "best friends", {
    _seq("a", "b", comment: "Hi !")
    _seq("b", "a", comment: "Hi !")
  }
)
```)

#let loop = example(```
_par("a", display-name: "Alice")
_par("b", display-name: "Bob")

_loop("default loop", {
  _seq("a", "b", comment: "Are you here?")
})
_gap()
_loop("min loop", min: 1, {
  _seq("a", "b", comment: "Are you here?")
})
_gap()
_loop("min-max loop", min: 1, max: 5, {
  _seq("a", "b", comment: "Are you still here?")
})
```)

#let sync = example(```
_par("alice", display-name: "Alice")
_par("bob", display-name: "Bob")
_par("craig", display-name: "Craig")

_seq("bob", "alice")  // Unsynchronized
_seq("bob", "craig")  //  "
_sync({
  _seq("bob", "alice")  // Synchronized
  _seq("bob", "craig")  //  "
})
_seq("alice", "bob")  // Unsynchronized
_seq("craig", "bob")  //  "
_sync({
  _seq("alice", "bob")  // Synchronized
  _seq("craig", "bob")  //  "
})
```)

#let gaps = example(```
_par("a", display-name: "Alice")
_par("b", display-name: "Bob")

_seq("a", "b", comment: [message 1])
_seq("b", "a", comment: [ok], dashed: true)
_gap()
_seq("a", "b", comment: [message 2])
_seq("b", "a", comment: [ok], dashed: true)
_gap(size: 40)
_seq("a", "b", comment: [message 3])
_seq("b", "a", comment: [ok], dashed: true)
```)

#let seps = example(```
_par("a", display-name: "Alice")
_par("b", display-name: "Bob")

_sep[Initialization]
_seq("a", "b", comment: [Request 1])
_seq(
  "b", "a",
  comment: [Response 1],
  dashed: true
)

_sep[Repetition]
_seq("a", "b", comment: [Request 2])
_seq(
  "b", "a",
  comment: [Response 2],
  dashed: true
)
```)

#let delays = example(```
_par("a", display-name: "Alice")
_par("b", display-name: "Bob")

_seq("a", "b", comment: [Auth Request])
_delay()
_seq(
  "b", "a",
  comment: [Auth Response],
  dashed: true
)
_delay(name: [5 minutes later])
_seq(
  "b", "a",
  comment: [Good Bye !],
  dashed: true
)
```)

#let notes-shapes = example(```
_par("alice", display-name: "Alice")
_par("bob", display-name: "Bob")
_note("over", `default`, pos: "alice")
_note("over", `rect`, pos: "bob", shape: "rect")
_note("over", `hex`, pos: ("alice", "bob"), shape: "hex")
```)

#let notes-sides = example(```
_par("alice", display-name: "Alice")
_par("bob", display-name: "Bob")
_par("charlie", display-name: "Charlie")
_note("left", [`left` of Alice], pos: "alice")
_note("right", [`right` of Charlie], pos: "charlie")
_note("over", [`over` Alice and Bob], pos: ("alice", "bob"))
_note("across", [`across` all participants])
_seq("alice", "bob")
_note("left", [linked with sequence])
_note("over", [A note], pos: "alice")
_note("over", [Aligned note], pos: "charlie", aligned: true)
```, vertical: true)