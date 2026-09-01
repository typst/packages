#import "@preview/merman:0.3.0": mermaid, mermaid-profile

#set page(paper: "a4", margin: 20mm)

= Print-friendly Mermaid

#let source = "flowchart TD
  Draft[Draft Mermaid] --> Review[Review in Typst]
  Review --> Export[Export PDF]
"

#let print-profile = mermaid-profile(
  background: "#ffffff",
  theme-name: "base",
  typography: (
    font: ("Source Sans 3", "Arial", "sans-serif"),
    size: "16px",
  ),
  theme: (
    primaryColor: "#f8fafc",
    primaryTextColor: "#111827",
    primaryBorderColor: "#2563eb",
    lineColor: "#475569",
  ),
)

#mermaid(
  source,
  profile: print-profile,
  width: 100%,
  alt: "A print-friendly flowchart rendered by merman",
)
