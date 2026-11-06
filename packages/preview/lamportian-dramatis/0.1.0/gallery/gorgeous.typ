#import "@preview/lamportian-dramatis:0.1.0": lamport-diagram, sync, below, above, send, recv, replica

#set page(width: 13cm, height: auto, margin: 0.4cm)
#set text(size: 10pt)

#lamport-diagram(
  replicas: (
    replica("S", above, color: luma(0)),
    replica("A", below),
    replica("C", below),
  ),
  events: (
    "S": (
      sync("boot"),
      send("c-reads"),
      sync("a-pushes"),
      recv("c-pushes"),
      sync("a-catches-up"),
    ),
    "C": (
      recv("c-reads"),
      [`C.1`],
      send("c-pushes"),
    ),
    "A": (
      [`A.1`],
      sync("boot"),
      [`A.2`],
      sync("a-pushes"),
      sync("a-catches-up")[Bug: A #sym.eq.not C],
    ),
  ),
)
