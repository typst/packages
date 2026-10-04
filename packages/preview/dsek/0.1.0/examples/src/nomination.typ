#import "@preview/dsek:0.1.0": *
#import strings: valb

#show: valförslag.with(
  title: "Nomineringar till Presidiet",
  meeting: "S23",
  candidates: (
    "Ordförande": "Trula Teknolog",
    "Vice Ordförande": "Truls Teknolog",
    "posten Posten": (
      "J. Doe",
      "Nomen Nescio",
      "[REDACTED]",
    ),
  ),
  authors: (
    // position defaults to "Sektionsmedlem" / "Guild member",
    // message defaults to "Lund, dag som ovan" / "Lund, day as above"
    (name: "Råsa Pantern", position: valb.ordf),
  ),
  stats: (
    "Ordförande": [0 -- 4],
    "Vice Ordförande": [5 -- 9],
    "posten Posten": [250 -- 254],
  ),
)

Dessa personer gjorde bättre ifrån sig på sina intervjuer än någon annan.

// extra space is inserted before this paragraph automatically
Med hänvisning till den utförliga motivationen ovan yrkar jag därmed på
- att välja in dessa tjommar till respektive post // becomes: *att* välja...
