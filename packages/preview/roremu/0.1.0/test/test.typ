#set text(font: "Noto Serif CJK JP")
#show raw: set text(font: "Noto Sans Mono CJK JP")
#import "../src/lib.typ": roremu

#show raw.where(block: true): it => {
  box(fill: luma(240), inset: 10pt, radius: 4pt, it)
}

```typst
#roremu(8)
```

#roremu(8)

#v(1em)

```typst
#roremu(8, offset: 8)
```

#roremu(8, offset: 8)

#v(1em)

```typst
#roremu(38, offset: 16)
```

#roremu(38, offset: 16)

#v(1em)

```typst
#roremu(100, custom-text: "私はその人を常に先生と呼んでいた。")
```

#roremu(100, custom-text: "私はその人を常に先生と呼んでいた。")

#v(1em)

```typst
#roremu(125)

#roremu(107, offset: 125)
```

#roremu(125)

#roremu(107, offset: 125)
