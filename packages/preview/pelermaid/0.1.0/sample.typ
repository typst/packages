// A self-contained tour of Pelermaid. Compile with:
//
//   typst compile --package-path dist/packages sample.typ sample.pdf
//
// or after ./scripts/install-local.sh:
//
//   typst compile sample.typ sample.pdf
//
// The full diagram corpus lives in tests/corpus.typ.
#import "@preview/pelermaid:0.1.0": mermaid, mermaid-figure, mermaid-result, show-mermaid-blocks

#set page(width: 21cm, height: 29.7cm, margin: 2cm)
#set text(font: "DejaVu Sans", size: 11pt)

= Pelermaid

Mermaid diagrams for Typst, rendered with Pele. Layout, spacing, and edge routing are
Pele's; this package does not use Mermaid.js.

== A flowchart

#mermaid("
flowchart TD
    A((Start)) --> B[/Input score/]
    B --> C{Score >= 5?}
    C -->|Yes| D[/Output Pass/]
    C -->|No| E[/Output Fail/]
    D --> F((End))
    E --> F
", width: 75%)

== A sequence diagram

#mermaid("
sequenceDiagram
    participant U as User
    participant A as App
    U->>A: Submit form
    A-->>U: Confirmation
", width: 75%)

== A figure

#mermaid-figure("
stateDiagram-v2
    [*] --> Idle
    Idle --> Running: start
    Running --> Idle: stop
", caption: [A state machine], width: 65%)

== Dark theme

#mermaid("
pie showData
    title Where time goes
    \"Writing\" : 35
    \"Review\" : 25
    \"Meetings\" : 20
    \"Debugging\" : 20
", base-theme: "dark", width: 60%)

== Raw blocks

#show raw.where(lang: "mermaid"): show-mermaid-blocks(width: 60%, error-mode: "placeholder")

```mermaid
mindmap
    Release
        Docs
        Code
        Tests
```

== Inspecting a result

#let result = mermaid-result("
flowchart LR
    A[Start] --> B[Stop]
")
Result: #if result.ok [rendered #result.type (#result.width × #result.height)] else [failed: #result.message]
