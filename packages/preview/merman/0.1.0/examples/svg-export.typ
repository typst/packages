#import "@preview/merman:0.1.0": mermaid-result, mermaid-svg

= SVG export

#let source = "flowchart LR
  Source[Mermaid source] --> SVG[SVG string]
  Source --> Result[Structured result]
"

#let svg = mermaid-svg(source, pipeline: "readable")
#let result = mermaid-result(source, pipeline: "readable")

Render result: `#result.code_name`

SVG starts with:

```text
#svg.slice(0, 120)
```

Result SVG starts with:

```text
#result.svg.slice(0, 120)
```
