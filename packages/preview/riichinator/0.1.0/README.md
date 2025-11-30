# Riichinator

Riichi Mahjong hand and board state renderer.

## Notation

This library uses mpsz notation, where m = Manzu (Character suit), p = Pinzu (Circle suit), s = Souzu (Bamboo suit) and z = Honor tiles and others. Here is every available tile:
![](./screenshots/tile_table.png)

### Concatenation of tiles

For ease of typing, for inputs that accept more than 1 tile, if multiple tiles have the same suit, the suit indicator can be placed at the end of the sequence.

For example, instead of inputting `1s1s1s2s3s4s5s6s7s8s9s9s9s`, we can instead input `1112345678999s`.

Other examples includes `123p778s11m789p33z` and `19m19p19s1234567z`
```typ
#hand("1112345678999s")\
#hand("123p778s11m789p33z")\
#hand("19m19p19s1234567z")
```
![](./screenshots/tile_concat_example.png)

### Tile modifiers

Currently, this library only supports rotation, like when the riichi declaration tile is rotated, or when *chi* or *pon* is called.

To rotate a tile, simply add `'` to the end of the number. For example, to show a rotated `3m`, use `3'm`.
```typ
An example of a discard pool:
#river("1s6p7m67s8p253'z")
```
![](./screenshots/rotate_example.png)

### Spaces

This library also accepts `-` as a small spacer. This is useful for things like showing hands with the context of the most recently drawn tiles, or to show open calls:

```typ
#hand("11m23p-4'30m-77;7z-0z11s0z")
```
![](./screenshots/space_example.png)

## Future features

### Tile modifier
- Allow the display of extended kans
- Allow for shading of tiles to indicate tsumogiri / tedashi or whatever other purposes
### Board state
- Make the board state more robust to allow for hands with more than 15 tiles
### Customization
- Allow usage of other tilesets
- Allow user to change the color of the back of the tile

## Similar libraries
- #link("https://typst.app/universe/package/handy-dora/")[handyd-dora] A package for rendering mahjong hands.

## Credits

The tile assets are taken from https://github.com/FluffyStuff/riichi-mahjong-tiles/

