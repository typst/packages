# Jyutcitzi

A Typst package for rendering [Jyutcitzi (粵切字)](https://jyutcitzi.github.io/table).

## Features

- Jyutcitzi generate from jyutping (粵拼)
- Compound initial support

## Usage

```typst
#import "@preview/jyutcitzi:0.1.0": *
// Set to any font that contains the Jyutcitzi alphabets
#set text(font: "Noto Sans CJK TC")

#jyutcitzi("keu")#jyutcitzi("leu")#jyutcitzi("liu")#jyutcitzi("leng")粵字

"Skill" #jyutcitzi("ge")#jyutcitzi("jyut")#jyutcitzi("zi")係「#combine-parts(
  combine-parts(beginnings-dict.s.at(0), beginnings-dict.k.at(0), "-"),
  "頁",
  "|"
)」。
```

![jyutcitzi sample](sample.png)

## License

MIT

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
