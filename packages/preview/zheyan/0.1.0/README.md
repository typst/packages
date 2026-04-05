
# Usage

```typst
import "@preview/zheyan:0.1.0": mask-str

#let masked_str =  mask-str(str: "Hello World!")
```

`masked-str` will become `************`.

To compile with mask:
```
typst compile --input mask=true main.typ
```
