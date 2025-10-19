#set page(height: auto, width: auto, margin: 2mm)
#show raw: block.with(stroke: gray, inset: 0.6em, radius: 0.5em)

#show raw.where(block: true, lang: "example"): it => {
  show raw: set text(1em / 0.8)
  eval(it.text, mode: "markup")

  it


  raw(it.text, lang: "typst", block: true)
}

```example
#text(blue,[Hello World])
```