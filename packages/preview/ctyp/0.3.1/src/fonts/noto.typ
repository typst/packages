#let noto-fontset = (
  family: (
    song: (name: "Noto Serif CJK SC", variants: ("thin", "extralight", "light", "medium", "semibold", "bold", "extrabold", "heavy")),
    hei: (name: "Noto Sans CJK SC", variants: ("thin", "extralight", "light", "medium", "semibold", "bold", "extrabold", "heavy")),
  ),
  map: (
    text: (cjk: "song", latin: "serif"),
    strong: (cjk: "hei", latin: "serif"),
    emph: (cjk: "song:underline", latin: "serif"),
    raw: (cjk: "song", latin: "mono"),
    heading: (cjk: "song:bold", latin: "serif"),
  )
)
