#import "@preview/dsek:0.1.0": *
#import strings: styr

#show: styrelsens-svar.with(
  title: [3.0 flugor i en smäll],
  meeting: "HTM1",
  authors: (
    // position defaults to "Sektionsmedlem" / "Guild member",
    // message defaults to "Lund, dag som ovan" / "Lund, day as above"
    (name: "Truls Teknolog", position: styr.ordf),
    (name: "Trula Teknolog", message: "För styrelsen"),
  ),
)

#emoji.thumb.up

Styrelsen yrkar på // extra space is inserted before this paragraph automatically
- att bifalla motionen i sin helhet // becomes: *att* bifalla...
