# Easy Pinyin

Write Chinese pinyin easily.

## Usage

Import the package:

```typst
#import "@preview/easy-pinyin:0.1.0": pinyin, zhuyin
```

With the `pinyin` function, you can use `a2` to write an `ɑ́`, `o3` to write an `ǒ`, `v4` to represent `ǜ`, etc.

With `zhuyin` function，you can put pinyin above the text easily, with parameters:

- positional parameters:
  - `doc: content|string`: main characters
  - `ruby: content|string`: zhuyin characters
- named parameters:
  - `scale: number = 0.7`: font size scale of `ruby`, default `0.7`
  - `gutter: length = 0.3em`: spacing between `doc` and `ruby`, default `0.3em`
  - `delimiter: string|none = none`: if not none, use this character to split `doc` and `ruby` into parts
  - `spacing: length|none = none`: spacing between each parts

See example bellow.

## Example

```typst
汉（#pinyin[ha4n]）语（#pinyin[yu3]）拼（#pinyin[pi1n]）音（#pinyin[yi1n]）。

#let per-char(f) = [#f(delimiter: "|")[汉|语|拼|音][ha4n|yu3|pi1n|yi1n]]
#let per-word(f) = [#f(delimiter: "|")[汉语|拼音][ha4nyu3|pi1nyi1n]]
#let all-in-one(f) = [#f[汉语拼音][ha4nyu3pi1nyi1n]]
#let example(f) = (per-char(f), per-word(f), all-in-one(f))

// argument of scale and spacing
#let arguments = ((0.5, none), (0.7, none), (0.7, 0.1em), (1.0, none), (1.0, 0.2em))

#table(
  columns: (auto, auto, auto, auto),
  align: (center + horizon, center, center, center),
  [arguments], [per char], [per word], [all in one],
  ..arguments.map(((scale, spacing)) => (
    text(size: 0.7em)[#scale,#repr(spacing)], 
    ..example(zhuyin.with(scale: scale, spacing: spacing))
  )).flatten(),
)
```

![result of above example](https://github.com/7sDream/typst-easy-pinyin/blob/master/example.png?raw=true)

## LICENSE

MIT, see License file.
