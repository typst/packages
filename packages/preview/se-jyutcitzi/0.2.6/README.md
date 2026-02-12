# Se-Jyutcitzi

A Typst package for rendering
[Jyutcitzi (粵切字)](https://jyutcitzi.github.io/table).  "Se-Jyutcitzi" means
"to write Jyutcitzi", and it is pronounced as **[sɛː˧˥ jyːt˨ t͡sʰiːt˧ t͡siː˨]**.

## Features

- Jyutcitzi generation from jyutping (粵拼)
- Compound initial support

## Usage

```typst
#import "@preview/se-jyutcitzi:0.2.6": *
#set page(height: auto, width: auto, margin: 4pt)
// #set text(bottom-edge: "descender", top-edge: "ascender")
// Set to any font that contains the Jyutcitzi alphabets
#set text(font: "Noto Sans CJK TC")

#jyutcitzi("keu leu liu lang")嘅粵字

"Skill"#"ge3 jyut6 zi6 m3 hm1".split().map(jyutcitzi).join()係「#combine-3parts("厶", "臼", "么", "tbr")」。\
"Cheese"#"ge hai".split().map(jyutcitzi).join()「#combine-3parts("此", "子", "厶", "lrb", tone: "1")」。
```

![jyutcitzi sample](sample.png)

## License

MIT

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
