#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  let n = 3
  surface-code((0, 0),size:1.5, n, n,name: "surface1")
  for i in range(n) {
    for j in range(n) {
      content((rel: (0.3, 0.3), to: "surface1" + "-" + str(i) + "-" + str(j)), [#(i*n+j+1)])
    }
  }
  surface-code((4, 0), 15, 7,color1:red,color2:green,size:0.5,type-tag: false)
  })