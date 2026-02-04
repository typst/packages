#set page(margin: 0pt, height: auto)
#import "../lib.typ": *

#{
  let obj = read("./suzanne.obj")
  let float-pat = `[+-]?\d*(?:\.\d+)?`.text
  let v-pat = regex("v" + range(3).map(_ => "\s+(" + float-pat + ")").join())
  let vs = obj.matches(v-pat).map(x => x.captures.map(float))
  let fs = obj
    .split("\n")
    .map(str.trim)
    .filter(x => x.starts-with("f "))
    .map(x => {
      let vis = x.split().slice(1).map(int)
      range(1, vis.len() - 1).map(i => triangle(
        ..(0, i, i + 1).map(i => vs.at(vis.at(i) - 1)),
      ))
    })
    .flatten()
  render(
    eye: (2.5, 1.0, 6.0),
    center: (1.0, -0.5, 0.0),
    up: (0.0, 1.0, 0.0),
    fovy: 35.0,
    step: 0.01,
    ..fs,
  )
}
