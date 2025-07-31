#import "../src/nassi.typ"
#import nassi: cetz

#set page(width: 13cm, height: auto, margin: 5mm)

#cetz.canvas({
  import nassi.draw: diagram
  import nassi.elements: *
  import cetz.draw: *

  diagram(
    (4, 4),
    {
      function(
        "ggt(a, b)",
        {
          loop(
            "a > b and b > 0",
            {
              branch(
                "a > b",
                {
                  assign("a", "a - b")
                },
                {
                  assign("b", "b - a")
                },
              )
            },
          )
          branch(
            "b == 0",
            {
              process("return a")
            },
            {
              process("return b")
            },
          )
        },
      )
    },
  )

  for i in range(8) {
    content(
      "nassi.e" + str(i + 1) + ".north-west",
      stroke: red,
      fill: red.transparentize(50%),
      frame: "circle",
      padding: .05,
      anchor: "north-west",
      text(white, weight: "bold", "e" + str(i)),
    )
  }
})
