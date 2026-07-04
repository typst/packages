#import "@preview/tidy:0.4.3"
#import "lib.typ" as riichinator
#let docs = tidy.parse-module(
  read("lib.typ"),
  name: "riichinator",
  scope: (riichinator: riichinator),
  preamble: "#import riichinator: *\n",
)
== Notation
=== Tile identifiers
This library uses mpsz notation, where m = Manzu (Character suit), p = Pinzu (Circle suit), s = Souzu (Bamboo suit) and z = Honor tiles and others. Here is every available tile:
#stack(
  dir: ttb,
  spacing: 1em,
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    rows: (auto, auto),
    align: center + horizon,
    ..("1", "2", "3", "4", "5", "0", "6", "7", "8", "9").map(i => raw(i + "m")),
    ..("1", "2", "3", "4", "5", "0", "6", "7", "8", "9").map(i => riichinator.tile(i + "m"))
  ),
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    rows: (auto, auto),
    align: center + horizon,
    ..("1", "2", "3", "4", "5", "0", "6", "7", "8", "9").map(i => raw(i + "p")),
    ..("1", "2", "3", "4", "5", "0", "6", "7", "8", "9").map(i => riichinator.tile(i + "p"))
  ),
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    rows: (auto, auto),
    align: center + horizon,
    ..("1", "2", "3", "4", "5", "0", "6", "7", "8", "9").map(i => raw(i + "s")),
    ..("1", "2", "3", "4", "5", "0", "6", "7", "8", "9").map(i => riichinator.tile(i + "s"))
  ),
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto),
    rows: (auto, auto),
    align: center + horizon,
    ..("1", "2", "3", "4", "5", "6", "7", "0").map(i => raw(i + "z")),
    ..("1", "2", "3", "4", "5", "6", "7", "0").map(i => riichinator.tile(i + "z"))
  ),
)
=== Concatenation of tiles
For ease of typing, for inputs that accept more than 1 tile, if multiple tiles have the same suit, the suit indicator can be placed at the end of the sequence.
For example, instead of inputting `1s1s1s2s3s4s5s6s7s8s9s9s9s`, we can instead input `1112345678999s`.
```typ
#hand("1112345678999s")
#hand("123p778s11m789p33z")
```
#riichinator.hand("1112345678999s")\
#riichinator.hand("123p778s11m789p33z")

==== Shorthand for hidden tiles
Often, you may want to show a large sequence of hidden tiles, e.g. opponent's hands or irrelevant discard pools for example problems.
In this case, simply specify the number of hidden tiles as an integer:
```typ
#hand(13)
#river(13)
```
#riichinator.hand(13)
#riichinator.river(13)

=== Tile spacer
you can use `-` to draw a space 1/4 the width of a tile, for example to show the most recently drawn tile, or a called group (e.g. closed kan):
```typ
#hand("45089m3488p2467s-8p")
#hand("1236688p-0770z")
```
#riichinator.hand("45089m3488p2467s-8p")\
#riichinator.hand("1234668899m-0770z")

=== Tile Modifiers
To rotate a tile, simply add `'` to the end of the number. Here are some examples:
```typ
#river("1s6p7m67s8p253'z")
#hand("5567m34p6788s-0p-77'7z")
#hand("1123456789p-1'111z")
```
#riichinator.river("1s6p7m67s8p253'z")
#riichinator.hand("5567m34p6788s-0p-77'7z")\
#riichinator.hand("11234567899p-1'111z")

For added/extended kans, use `"` to rotate and stack the previous 2 tiles:
```typ
#hand("11178p35566z-505\"5p")
```
#riichinator.hand("11178p35566z-505\"5p")

To insert a shaded overlay on top of a tile, use the `?` modifier. \
This can be combined with all other modifiers, but for added/extened kans it is only possible to shade both kan tiles at once. The modifier is ignored if attached to the first of the two kan tiles:
```typ
#hand("123456789s-2?3?4?'m-5?5?p")
#hand("123m123s123p-8?88\"?8?s-6?6?z")
```

#riichinator.hand("123456789s-2?3?4?'m-5?5?p")\
#riichinator.hand("123m123s123p-8?88\"?8?s-6?6?z")

#pagebreak()

To add a highlight border to a tile, use the `!` modifier. \
This can be combined with the `'` and `?` modifiers but not the `"` modifier:

```typ
#hand("1144m77z336688s3p-3!p")
#hand("333s333m333p-4'!44z-77z")
#hand("666\"!6m")
```

#riichinator.hand("1144m77z336688s3p-3!p")\
#riichinator.hand("333s333m333p-4'!44z-77z")\
#riichinator.hand("666\"!6m") #text(fill: gray)[\/\/ highlight ignored!]

#pagebreak()
#tidy.show-module(docs, style: tidy.styles.default)

#context measure(layout(size => box(width: size.width)))
