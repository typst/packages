#import "@preview/merman:0.2.0": analyze-mermaid, mermaid, mermaid-result, mermaid-svg

= merman Typst Options Example

#let source = "flowchart LR
  Start([Start]) --> Parse[Parse]
  Parse --> Render[Render SVG]
  Render --> Done([Done])
"

#let analysis = analyze-mermaid(source)
#let render-result = mermaid-result(
  source,
  pipeline: "readable",
  text-measurement: "deterministic",
  math-renderer: "none",
)
#let failed-result = mermaid-result("flowchart TD\n  A -->")

Analysis schema: `#analysis.version`

Analysis valid: `#analysis.valid`

Render result: `#render-result.code_name`

Failed render result: `#failed-result.code_name`

#mermaid(
  source,
  width: 95%,
  id: "typst-options-demo",
  scale: 1.05,
  background: "#f8fafc",
  theme-name: "base",
  theme: (
    primaryColor: "#0f172a",
    primaryTextColor: "#f8fafc",
    primaryBorderColor: "#38bdf8",
    lineColor: "#475569",
  ),
)

#let svg = mermaid-svg(source, pipeline: "readable")

SVG starts with:

```text
#svg.slice(0, 80)
```

Diagram errors can stay visible in drafts:

#mermaid(
  "flowchart TD\n  A -->",
  width: 95%,
  error-mode: "placeholder",
)
