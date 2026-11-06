# Se-Jyutcitzi

A Typst package for rendering
[Jyutcitzi (粵切字)](https://jyutcitzi.github.io/table).  "Se-Jyutcitzi" means
"to write Jyutcitzi", and it is pronounced as **[sɛː˧˥ jyːt˨ t͡sʰiːt˧ t͡siː˨]**.

## Features

- Jyutcitzi generation from jyutping (粵拼)
- Compound initial support

## Usage

```typst
#import "@preview/se-jyutcitzi:0.3.2": *
#set page(height: auto, width: auto, margin: 4pt)
// Set to any font that contains the Jyutcitzi alphabets
#set text(font: "AR PL KaitiM Big5")
Normal text.

#jyutcitzi("keu leu liu lang 嘅粵字 m4 亾冇 se。")

正常文字段落。

#jyutcitzi(merge-nasals: true)[
  "Skill" ge3 jyut6 cit3 zi6 亾兮6「厶臼么」\
  "Cheese" 丩旡 hai 「此子厶1」
]
```

![jyutcitzi sample](sample.png)

## License

MIT

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
