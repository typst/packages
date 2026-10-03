#import "../src/exports.typ" as dd

// #dd.wave(
//   (signal: (
//     (wave: "10.15..1.",),
//     (wave: "10.14.6..",),
//     (:),
//     (wave: "10.13.8..",),
//   )),
//   stroke: (n) => if n == 1 {
//     stroke(paint: red, dash: "dashed")
//   } else {
//     stroke(blue)
//   },
//   guide-stroke: olive + 0.5pt,
//   debug: "coordinates",
//   name: "mywave",
//   others: (info) => {
//     import dd.cetz.draw: *
//   }
// )


// #dd.cetz.canvas({
//   dd.subwave(
//     (0,1),
//     name: "wave",
//     (signal: (
//       (wave: "10.153.1.",),
//       (wave: "10.14.6..",),
//       (wave: "10.13.8..",),
//     )),
//   )

//   import dd.cetz.draw: *

  
// })

// #dd.wave(
//   symbol-width:  1cm,
//   symbol-height: 5mm,
//   wave-gutter: 7.5mm,
//   (signal: (
//     (wave: "x2.ud", name: "A Name"),
//     (wave: "x2.ud", data: ([Data],)),
//     (:),
//     (wave: "x2.ud"))
//   ),
//   debug: ("coordinates", "anchors")
// )

// #dd.wave(
//   (signal: (
//     (wave: "x2.ud", name: "A Name"), // gutter yes + height
//     (wave: "x2.ud", data: ([Data],)), // gutter yes + height
//     (:), // gutter no -> just height
//     (wave: "x2.ud=")) // gutter no -> is end
//   ),
//   debug: ("coordinates", "anchors")
// )


// - #raw("\"anchors\"", lang: "typc") -- shows the various anchor points of each wave. *Additionally*, the whole diagram has anchor points for all directions (#("center","north","north-east","east", "south-east","south","south-west","west","north-west").map(x => raw(lang: "typc", "\"" + x + "\"")).join([, ], last: [and ]))
// #dd.wave(
//   debug: "anchors",
//   // 
//   (signal: ((wave: "01010101",),(wave: "01010101",))), symbol-height: 1cm, 
//   others: (info) => {
//     import dd.cetz.draw: *
//     circle("wave.1.south-west", radius: 0.2)
//     circle("wave.0.south-west", radius: 0.2)
    
//     dd.subwave("wave.0.south-west", (signal: ((wave: "==......",),)), stroke: (paint: red,), wave-layer: -2, symbol-height: info.symbol-height
//     )

//     dd.subwave("wave.1", (signal: ((wave: "==......",),)), stroke: (olive + 2pt), wave-layer: -2, symbol-height: info.symbol-height
//     )

//     //dd.subwave("1",(signal: ((wave: "10101010",),)), stroke: (paint: blue, dash: "loosely-dashed", thickness: 2pt), symbol-height: 5mm)
//   }
// )

#let style(n) = {
  if n == 1 {red}
  else {black}
}

#let data = (signal: (
  (wave: "10|uz3x"),
  (wave: "10|uz3x"),
  (wave: "10|uz3x"),
  (wave: "10|uz3x"),
  (wave: "10|uz3x"),
))

#dd.wave(data, stroke: style)