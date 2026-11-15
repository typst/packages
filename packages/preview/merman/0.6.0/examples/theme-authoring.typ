#import "@preview/merman:0.6.0": (
  describe-theme-support,
  export-theme-preset,
  materialize-theme,
  mermaid,
  mermaid-theme-definition,
)

#let definition = (
  tokens: (
    canvas: (type: "color", value: "#0f172a"),
    surface: (type: "color", value: "#1e293b"),
    text: (type: "color", value: "#e5e7eb"),
    accent: (type: "color", value: "#38bdf8"),
  ),
  canvas: (base: (kind: "solid", color: (ref: "canvas"))),
  // Sequence labels and lifelines have their own paint roles.
  styles: (
    text: (fill: (kind: "solid", color: (ref: "text"))),
    actor-label: (fill: (kind: "solid", color: (ref: "text"))),
    message-label: (fill: (kind: "solid", color: (ref: "text"))),
    actor: (
      fill: (kind: "solid", color: (ref: "surface")),
      stroke: (paint: (kind: "solid", color: (ref: "accent"))),
    ),
    message: (stroke: (paint: (kind: "solid", color: (ref: "accent")))),
    lifeline: (stroke: (paint: (kind: "solid", color: (ref: "accent")))),
  ),
)

#let support = describe-theme-support((
  schema_version: 1,
  family: "sequence",
  output: "standalone-svg",
  subject: (kind: "base-typography", property: "font-stack"),
))
#let preset = export-theme-preset("editor")
#let inspection = materialize-theme((
  schema_version: 1,
  action: "inspect",
  recipe: preset,
))

#mermaid-theme-definition(
  "sequenceDiagram\n  Alice->>Bob: Shared theme definition",
  definition,
  width: 90%,
)

// Select a paired preset without manually materializing its specification.
#mermaid(
  "flowchart LR\nA[One design] --> B[Dark appearance]",
  theme-preset: "editor",
  theme-appearance: "dark",
  document-context: true,
  width: 90%,
)

// Keep the complete editable recipe for copying, saving, and later changes.
#let editable = export-theme-preset("paper-cut")
#let full-configuration = json.encode(editable, pretty: true)
// Set to true to view/copy every setting as JSON in the compiled document.
#let show-full-configuration = false
#if show-full-configuration {
  raw(full-configuration, lang: "json", block: true)
}

// A shared font token feeds both the default and authored family font stacks.
#let tokens = editable.design.tokens
#let body-font = tokens.at("body-font")
#body-font.insert("value", ("Source Sans 3", "Arial", "sans-serif"))
#tokens.insert("body-font", body-font)
#let design = editable.design
#design.insert("tokens", tokens)
#editable.insert("design", design)

// This text is the full edited configuration; save it as custom.theme.json.
#let edited-json = json.encode(editable, pretty: true)
#let imported = json(bytes(edited-json))
// For a saved file, replace the previous line with: let imported = json("custom.theme.json")
#assert.eq(imported, editable)
#mermaid(
  "flowchart LR\nA[Editable JSON] --> B[Shared font token]",
  theme-recipe: imported,
  document-context: true,
  width: 90%,
)
#if show-full-configuration {
  raw(edited-json, lang: "json", block: true)
}

Support: #support.state

Preset export kind: #preset.kind

Available appearances: #inspection.supported_appearances.join(", ")

#mermaid-theme-definition(
  "sequenceDiagram\n  Alice->>Bob: One design, dark appearance",
  (schema_version: 1, action: "materialize", recipe: preset, appearance: "dark"),
  width: 90%,
)
