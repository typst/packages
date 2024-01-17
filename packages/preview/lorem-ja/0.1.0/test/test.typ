#set text(font: "Noto Serif CJK JP")
#show raw: set text(font: "Noto Sans Mono CJK JP")
#import "../src/lib.typ": lorem-ja

#show raw.where(block: true): it => {
  box(fill: luma(240), inset: 10pt, radius: 4pt, it)
}

```typst
#lorem-ja(8)
```

#lorem-ja(8)

#v(1em)

```typst
#lorem-ja(8, offset: 8)
```

#lorem-ja(8, offset: 8)

#v(1em)

```typst
#lorem-ja(38, offset: 16)
```

#lorem-ja(38, offset: 16)

#v(1em)

```typst
#lorem-ja(100, custom-text: "私はその人を常に先生と呼んでいた。")
```

#lorem-ja(100, custom-text: "私はその人を常に先生と呼んでいた。")

#v(1em)

```typst
#lorem-ja(125)

#lorem-ja(107, offset: 125)
```

#lorem-ja(125)

#lorem-ja(107, offset: 125)
