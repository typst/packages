#import "@preview/merman:0.1.0": mermaid

#set page(paper: "a4", margin: 20mm)

= Print-friendly Mermaid

#let source = "flowchart TD
  Draft[Draft Mermaid] --> Review[Review in Typst]
  Review --> Export[Export PDF]
"

#mermaid(
  source,
  width: 100%,
  background: "#ffffff",
  theme-name: "base",
  theme: (
    primaryColor: "#f8fafc",
    primaryTextColor: "#111827",
    primaryBorderColor: "#2563eb",
    lineColor: "#475569",
  ),
  alt: "A print-friendly flowchart rendered by merman",
)
