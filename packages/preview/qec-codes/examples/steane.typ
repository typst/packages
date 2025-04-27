#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)
#canvas({
  import draw: *
  steane_code((0, 0), size: 3)
    for j in range(7) {
      content((rel: (0, -0.3), to: "steane" + "_" + str(j+1)), [#(j)])
    }
})