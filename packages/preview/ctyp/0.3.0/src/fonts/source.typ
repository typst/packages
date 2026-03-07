#let source-fontset = (
  family: (
    song: (name: "Source Han Serif SC", variants: ("thin", "extralight", "light", "medium", "semibold", "bold", "extrabold", "heavy")),
    hei: (name: "Source Han Sans SC", variants: ("thin", "extralight", "light", "medium", "semibold", "bold", "extrabold", "heavy")),
  ),
  map: (
    text: (cjk: "song", latin: "serif"),
    strong: (cjk: "hei", latin: "serif"),
    emph: (cjk: "song:underline", latin: "serif"),
    raw: (cjk: "song", latin: "mono"),
    heading: (cjk: "song:bold", latin: "serif"),
  )
)
