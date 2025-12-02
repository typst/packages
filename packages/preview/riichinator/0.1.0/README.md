# Riichinator

Riichi Mahjong hand and board state renderer.

## Notation

This library uses mpsz notation, where m = Manzu (Character suit), p = Pinzu (Circle suit), s = Souzu (Bamboo suit) and z = Honor tiles and others. Here is every available tile:
![so for example, for the 1 of character (1 man), it is shortened to "1m". Red fives are represented as 0. Honor tiles are 1-7 in wind order and dragon order](./screenshots/tile_table.png)

### Concatenation of tiles

For ease of typing, for inputs that accept more than 1 tile, if multiple tiles have the same suit, the suit indicator can be placed at the end of the sequence.

For example, instead of inputting `1s1s1s2s3s4s5s6s7s8s9s9s9s`, we can instead input `1112345678999s`.

Other examples includes `123p778s11m789p33z` and `19m19p19s1234567z`
```typ
#hand("1112345678999s")\
#hand("123p778s11m789p33z")\
#hand("19m19p19s1234567z")
```
![Three examples of a mahjong hand, showing that multiple tiles grouped together with the same suit only needs the suit to be specified at the end. Note that suits can be used more than once in a hand.](./screenshots/tile_concat_example.png)

### Rotation

To rotate a tile, simply add `'` to the end of the number. For example, to show a rotated `3m`, use `3'm`.
```typ
An example of a discard pool:
#river("1s6p7m67s8p253'z")
```
![A rotated tile can also be inside of a tile concatenation](./screenshots/rotate_example.png)

### Spaces

This library also accepts `-` as a small spacer. This is useful for things like showing hands with the context of the most recently drawn tiles, or to show open calls:

```typ
#hand("11m23p-4'30m-77;7z-0z11s0z")
```
![A space is added between the closed part of the hand and each opened part of hand](./screenshots/space_example.png)

### Added/Extended Kan
For added/extended kans, use `"` to rotate and stack the previous 2 tiles:
```typ
#hand("11178p35566z-505\"5p")
```
![An example of an added kan. The `"` affects previous two tiles, so the 0m (red five) will be the original pon, and the additional 5m will be the extended tile.](./screenshots/extended_kan_example.png)

## Features
### Show board state
You have already seen examples of how to use `hand()` and `river()` to show hands and discard pools respectively. This library builds off these components and allows you to render a full board state.

```typ
#board(
    hands: "345m368p1233566s-7p",
    discards: ("0000z", "00000z", "9p8s5z7s8'm", "00000z"),
    current-round: "East Round",
    hero-wind: "N",
    riichied-players: (false, false, true, false),
    dora-indicators: "4p0000z",
    pot: (riichi: 0, honba: 0),
    scores: (25000, 25000, 25000, 25000)
)
```
![A board state with information of your hand, the discard pools, the current round, the dora indicators on the dead wall, the pot of any leftover riichi sticks or honba, each player's seat wind and score and whether they have declared riichi.](./screenshots/board_example.png)

### Riichi and Honba sticks
If you wish to display a riichi or a honba stick on its own, this library also provides these components:
```typ
#riichi-stick(10em, 1em)
#honba-stick(10em, 1em)
```
![A horizontal riichi stick and honba stick](./screenshots/stick_example.png)

## Future features

### Tile modifier
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
