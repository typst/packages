#import "@preview/cetz:0.2.2"

#import "../src/nassi.typ"

#set page(width: auto, height:auto, margin: 5mm)

#let strukt = nassi.parse(```
  function inorder(tree t)
    if t has left child
      inorder(left child of t)
    end if
    process(root of t)
    if t has right child
      inorder(right child of t)
    end if
  end function
```.text)

#figure(
  cetz.canvas({
    import nassi.draw: diagram
    import cetz.draw: *

    diagram((4,4), strukt)

    circle((rel:(.65,0), to:"nassi.e1-text"), stroke:red, fill:red.transparentize(80%), radius:.5, name: "a")
    content((5,5), "current subtree", name: "b", frame:"rect", padding:.1, stroke:red, fill:red.transparentize(90%))
    line("a", "b", stroke:red)

    content((1,2), "recursion", name: "rec", frame:"rect", padding:.1, stroke:red, fill:red.transparentize(90%))
    line("rec", (rel:(.15,0), to:"nassi.e3.west"), stroke:red, mark:(end: ">"))
    line("rec", (rel:(.15,0), to:"nassi.e7.west"), stroke:red, mark:(end: ">"))

    content((17, 2.7), [empty\ branches], name: "empty", frame:"rect", padding:.1, stroke:red, fill:red.transparentize(90%))
    line("empty", (rel:(.15,0), to:"nassi.e4-text.east"), stroke:red, mark:(end: ">"))
    line("empty", (rel:(.15,0), to:"nassi.e8"), stroke:red, mark:(end: ">"))
  }),
  caption: "Nassi-Shneiderman diagram of a inorder tree traversal."
)

// #cetz.canvas({
//   import nassi.draw: diagram
//   import nassi.elements: *
//   import cetz.draw: *

//   diagram((0,0), {
//     branch("a > b", {
//       empty(name: "empty-1")
//     }, {
//       empty(name: "empty-2")
//     })
//   })

//   arc-through(
//     "nassi.empty-1",
//     (
//       rel:(0,-.5),
//       to: (
//         a:"nassi.empty-1",
//         b:"nassi.empty-2",
//         number:.5
//       )
//     ),
//     "nassi.empty-2",
//     mark:(start:">", end:">"),
//     stroke:red+2pt
//   )
// })
