#let p = plugin("mahjong_tiles.wasm")

#let mahjong(hand, ..args, tile-set: "yellow-fluffy-stuff", tile-gap: 0.0, group-gap: 1.0 / 3.0) = image.decode(
  p.mahjong(bytes(hand), bytes(tile-set), bytes(str(tile-gap)), bytes(str(group-gap))),
  ..args,
)
