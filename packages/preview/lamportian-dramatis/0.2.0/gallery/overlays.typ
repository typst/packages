#import "@preview/lamportian-dramatis:0.2.0": lamport-diagram, sync, below, above, send, recv, replica, event, draw
#import draw: *

#set page(width: 13cm, height: auto, margin: 0.4cm)
#set text(size: 10pt)

#lamport-diagram(
  replicas: (replica("S", above, color: luma(0)), replica("A", below), replica("C", below)),
  events: (
    "S": (sync("boot"), send("c-reads"), sync("a-pushes"), recv("c-pushes"), sync("a-catches-up")),
    "C": (recv("c-reads"), event(id: "c1")[`C.1`], send("c-pushes")),
    "A": ([`A.1`], sync("boot"), event(id: "a2")[`A.2`], sync("a-pushes"), sync("a-catches-up")),
  ),
  overlays: (
    // The future of `A.2`: every event it can reach.  A cone, but not one opening at a fixed angle
    // -- what a diagram like this carries forward is messages, not light, so each edge of it is
    // aimed at something the messages actually did.
    //
    // Towards S it is aimed at the exchange that tells S about `A.2`, so S is taken in exactly
    // there, and it runs flat afterwards, S being the last lane that way.  Towards C it is aimed a
    // centimetre past C's own last event: no event on that lane is in this future -- the message C
    // receives was sent before S had heard of `A.2`, and nothing leaves S for C afterwards -- so
    // the edge may cross that lane, but only where there is nothing left to cross into.
    //
    // `col-gap` is centimetres per column, so `1 / col-gap` is a centimetre said in columns, and it
    // is the orientation's own value.  That is what lets this read the same whichever way time
    // runs: no lengths on the page, only the diagram's own axes.
    //
    // Over the backdrops, so the lanes do not fade a stripe through it, and still under every
    // timeline.
    backdrops: d => {
      let (column, point, replicas, span, col-gap, ..) = d
      let (_, ends) = span
      let lane-of = id => replicas.position(r => r == id)
      let (a, s, c) = (lane-of("A"), lane-of("S"), lane-of("C"))
      let apex = column("A", "a2")
      let crossing = column("C", -1) + 1 / col-gap
      let towards-c = (c - a) / (crossing - apex)
      line(
        point(apex, a),
        point(column("S", "a-pushes"), s - 0.4),
        point(ends, s - 0.4),
        point(ends, a + towards-c * (ends - apex)),
        close: true,
        fill: red.transparentize(93%),
        stroke: none,
      )
    },
    // Over the dot, under its label.
    marks: d => {
      let (mark, dot, mark-args, ..) = d
      let wash = red.transparentize(93%)

      circle(mark("A", "a2"), radius: dot * 3, stroke: red + 0.7pt)

      // Make the inners of the events have the same `wash` color of the future cone
      circle(..mark-args("S", 3), fill: wash)
      circle(..mark-args("S", 4), fill: wash)
      circle(..mark-args("S", 5), fill: wash)
      circle(..mark-args("A", 4), fill: wash)
      circle(..mark-args("A", 5), fill: wash)
    },
  ),
)
