#let pawn = symbol(
  ("filled", "♟"),
  ("filled.r", "🨔"),
  ("filled.b", "🨩"),
  ("filled.l", "🨾"),

  ("stroked", "♙"),
  ("stroked.r", "🨎"),
  ("stroked.b", "🨣"),
  ("stroked.l", "🨸"),

  ("white", "♙"),
  ("white.r", "🨎"),
  ("white.b", "🨣"),
  ("white.l", "🨸"),

  ("black", "♟"),
  ("black.r", "🨔"),
  ("black.b", "🨩"),
  ("black.l", "🨾"),

  ("neutral", "🨅"),
  ("neutral.r", "🨚"),
  ("neutral.b", "🨯"),
  ("neutral.l", "🩄"),
)

#let knight = symbol(
  ("filled", "♞"),
  ("filled.r", "🨓"),
  ("filled.b", "🨨"),
  ("filled.l", "🨽"),
  ("filled.tr", "🨇"),
  ("filled.br", "🨜"),
  ("filled.bl", "🨱"),
  ("filled.tl", "🩆"),
  ("filled.bishop", "🩓"),
  ("filled.rook", "🩒"),
  ("filled.queen", "🩑"),

  ("stroked", "♘"),
  ("stroked.r", "🨍"),
  ("stroked.b", "🨢"),
  ("stroked.l", "🨷"),
  ("stroked.tr", "🨆"),
  ("stroked.br", "🨛"),
  ("stroked.bl", "🨰"),
  ("stroked.tl", "🩅"),
  ("stroked.bishop", "🩐"),
  ("stroked.rook", "🩏"),
  ("stroked.queen", "🩎"),

  ("white", "♘"),
  ("white.r", "🨍"),
  ("white.b", "🨢"),
  ("white.l", "🨷"),
  ("white.tr", "🨆"),
  ("white.br", "🨛"),
  ("white.bl", "🨰"),
  ("white.tl", "🩅"),
  ("white.bishop", "🩐"),
  ("white.rook", "🩏"),
  ("white.queen", "🩎"),

  ("black", "♞"),
  ("black.r", "🨓"),
  ("black.b", "🨨"),
  ("black.l", "🨽"),
  ("black.tr", "🨇"),
  ("black.br", "🨜"),
  ("black.bl", "🨱"),
  ("black.tl", "🩆"),
  ("black.bishop", "🩓"),
  ("black.rook", "🩒"),
  ("black.queen", "🩑"),

  ("neutral", "🨄"),
  ("neutral.r", "🨙"),
  ("neutral.b", "🨮"),
  ("neutral.l", "🩃"),
  ("neutral.tr", "🨈"),
  ("neutral.br", "🨝"),
  ("neutral.bl", "🨲"),
  ("neutral.tl", "🩇"),
)

#let bishop = symbol(
  ("filled", "♝"),
  ("filled.r", "🨒"),
  ("filled.b", "🨧"),
  ("filled.l", "🨼"),

  ("stroked", "♗"),
  ("stroked.r", "🨌"),
  ("stroked.b", "🨡"),
  ("stroked.l", "🨶"),

  ("white", "♗"),
  ("white.r", "🨌"),
  ("white.b", "🨡"),
  ("white.l", "🨶"),

  ("black", "♝"),
  ("black.r", "🨒"),
  ("black.b", "🨧"),
  ("black.l", "🨼"),

  ("neutral", "🨃"),
  ("neutral.r", "🨘"),
  ("neutral.b", "🨭"),
  ("neutral.l", "🩂"),
)

#let rook = symbol(
  ("filled", "♜"),
  ("filled.r", "🨑"),
  ("filled.b", "🨦"),
  ("filled.l", "🨻"),

  ("stroked", "♖"),
  ("stroked.r", "🨋"),
  ("stroked.b", "🨠"),
  ("stroked.l", "🨵"),

  ("white", "♖"),
  ("white.r", "🨋"),
  ("white.b", "🨠"),
  ("white.l", "🨵"),

  ("black", "♜"),
  ("black.r", "🨑"),
  ("black.b", "🨦"),
  ("black.l", "🨻"),

  ("neutral", "🨂"),
  ("neutral.r", "🨗"),
  ("neutral.b", "🨬"),
  ("neutral.l", "🩁"),
)

#let queen = symbol(
  ("filled", "♛"),
  ("filled.r", "🨐"),
  ("filled.b", "🨥"),
  ("filled.l", "🨺"),

  ("stroked", "♕"),
  ("stroked.r", "🨊"),
  ("stroked.b", "🨟"),
  ("stroked.l", "🨴"),

  ("white", "♕"),
  ("white.r", "🨊"),
  ("white.b", "🨟"),
  ("white.l", "🨴"),

  ("black", "♛"),
  ("black.r", "🨐"),
  ("black.b", "🨥"),
  ("black.l", "🨺"),

  ("neutral", "🨁"),
  ("neutral.r", "🨖"),
  ("neutral.b", "🨫"),
  ("neutral.l", "🩀"),
)

#let king = symbol(
  ("filled", "♚"),
  ("filled.r", "🨏"),
  ("filled.b", "🨤"),
  ("filled.l", "🨹"),

  ("stroked", "♔"),
  ("stroked.r", "🨉"),
  ("stroked.b", "🨞"),
  ("stroked.l", "🨳"),

  ("white", "♔"),
  ("white.r", "🨉"),
  ("white.b", "🨞"),
  ("white.l", "🨳"),

  ("black", "♚"),
  ("black.r", "🨏"),
  ("black.b", "🨤"),
  ("black.l", "🨹"),

  ("neutral", "🨀"),
  ("neutral.r", "🨕"),
  ("neutral.b", "🨪"),
  ("neutral.l", "🨿"),
)

#let equihopper = symbol(
  ("filled", "🩉"),
  ("filled.rot", "🩌"),

  ("stroked", "🩈"),
  ("stroked.rot", "🩋"),

  ("white", "🩈"),
  ("white.rot", "🩋"),

  ("black", "🩉"),
  ("black.rot", "🩌"),

  ("neutral", "🩊"),
  ("neutral.rot", "🩍"),
)

#let soldier = symbol(
  ("filled", "🩭"),
  ("stroked", "🩦"),
  ("red", "🩦"),
  ("black", "🩭"),
)

#let cannon = symbol(
  ("filled", "🩬"),
  ("stroked", "🩥"),
  ("red", "🩥"),
  ("black", "🩬"),
)

#let chariot = symbol(
  ("filled", "🩫"),
  ("stroked", "🩤"),
  ("red", "🩤"),
  ("black", "🩫"),
)

#let horse = symbol(
  ("filled", "🩪"),
  ("stroked", "🩣"),
  ("red", "🩣"),
  ("black", "🩪"),
)

#let elephant = symbol(
  ("filled", "🩩"),
  ("stroked", "🩢"),
  ("red", "🩢"),
  ("black", "🩩"),
)

#let mandarin = symbol(
  ("filled", "🩨"),
  ("stroked", "🩡"),
  ("red", "🩡"),
  ("black", "🩨"),
)

#let general = symbol(
  ("filled", "🩧"),
  ("stroked", "🩠"),
  ("red", "🩠"),
  ("black", "🩧"),
)
