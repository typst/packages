# Typst-Mahjong-Tiles

[riichi-hand-rs](https://github.com/m4tx/riichi-hand-rs) in Typst, powered by wasm.

## Usage

Start with `#import "src/lib.typ": mahjong`. Reminds that `mahjong_tiles.wasm` should be in the same directory as where `src/` is.

Parameters:

- `hand`: A string of tiles in the hand.
- `tile-set`: The tile set to use. Default is `"yellow-fluffy-stuff"`. `"red-fluffy-stuff"`, `"black-fluffy-stuff"`, `"martin-persson"` are also available.
- `tile-gap`: The gap between tiles. Default is `0.0`.
- `group-gap`: The gap between groups. Default is `1.0 / 3.0`.
- `..args`: Other arguments to pass to the `image.decode()` fuction.

```typst
#mahjong("21w2www7w28p", tile-set: "martin-persson", alt: "majhong")
```

![21w2www7w28p](assets/21w2www7w28p.png)

```typst
#mahjong("2312936963s", alt: "majhong")
```

![2312936963s](assets/2312936963s.png)

## Credits

- [riichi-hand-rs](https://github.com/m4tx/riichi-hand-rs)
