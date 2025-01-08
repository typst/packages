#let p = plugin("mahjong_tiles.wasm")

#let mahjong(hand, ..args, tile-set: "yellow-fluffy-stuff", tile_gap: 0.0, group_gap: 1.0 / 3.0) = image.decode(
  p.mahjong(bytes(hand), bytes(tile-set), bytes(str(tile_gap)), bytes(str(group_gap))),
  ..args,
)
