// Electrical diagram defaults and component-level overrides.

#import "../validation-core.typ" as core-validation
#import "../validation-styles.typ" as style-validation

#let theme = (
  wire-stroke: 0.9pt + rgb("#343A40"),
  component-stroke: 0.9pt + rgb("#212529"),
  component-fill: white,
  source-fill: rgb("#F8F9FA"),
  junction-fill: rgb("#212529"),
  resistor-symbol: "zigzag",
  voltage-source-symbol: "battery",
  component-length: 2.2,
  resistor-length: 1.05,
  resistor-height: 0.42,
  capacitor-plate-gap: 0.24,
  capacitor-plate-height: 0.82,
  source-radius: 0.36,
  source-plate-gap: 0.24,
  source-long-plate: 0.78,
  source-short-plate: 0.44,
  parallel-gap: 1.15,
  branch-lead: 0.65,
  label-offset: 0.44,
  source-clearance: 0.85,
  apex-rise: 2.7,
  frame-rise: 2.8,
  minimum-loop-width: 4.4,
  label-text: (size: 9pt),
  show-junctions: true,
  scale: 1.0,
)

#let _sparse-style(..entries) = {
  let declared-entries = (:)
  for (key, value) in entries.named() {
    if value != auto { declared-entries.insert(key, value) }
  }
  declared-entries
}

#let resistor-style(
  symbol: auto,
  fill: auto,
  stroke: auto,
  text: auto,
) = _sparse-style(
  symbol: symbol,
  fill: fill,
  stroke: stroke,
  text: text,
)

#let voltage-source-style(
  symbol: auto,
  fill: auto,
  stroke: auto,
  text: auto,
) = _sparse-style(
  symbol: symbol,
  fill: fill,
  stroke: stroke,
  text: text,
)

#let capacitor-style(
  stroke: auto,
  text: auto,
) = _sparse-style(
  stroke: stroke,
  text: text,
)

#let validate-component-style(
  component-style,
  source-description,
  component-kind,
) = {
  style-validation.validate-element-style(
    component-style,
    if component-kind == "capacitor" {
      ("stroke", "text")
    } else {
      ("symbol", "fill", "stroke", "text")
    },
    source-description,
  )
  if "symbol" in component-style {
    core-validation.validate-enum(
      component-style.symbol,
      if component-kind == "resistor" {
        ("zigzag", "rectangle")
      } else {
        ("battery", "circle")
      },
      source-description + " style",
      "symbol",
    )
  }
  component-style
}

#let resolve-style(overrides) = {
  style-validation.validate-style-dictionary(
    overrides,
    "electricity diagram style",
  )
  for key in overrides.keys() {
    assert(
      key in theme,
      message: (
        "typed-physics: unknown electricity diagram style key \""
          + key
          + "\"; accepted keys are "
          + theme.keys().join(", ")
      ),
    )
  }
  for numeric-key in (
    "component-length", "resistor-length", "resistor-height",
    "capacitor-plate-gap", "capacitor-plate-height", "source-radius",
    "source-plate-gap", "source-long-plate", "source-short-plate",
    "parallel-gap", "branch-lead", "label-offset", "source-clearance",
    "apex-rise", "frame-rise", "minimum-loop-width", "scale",
  ) {
    if numeric-key in overrides {
      core-validation.validate-positive-number(
        overrides.at(numeric-key),
        "electricity diagram style",
        numeric-key,
      )
    }
  }
  for stroke-key in ("wire-stroke", "component-stroke") {
    if stroke-key in overrides {
      style-validation.validate-stroke(
        overrides.at(stroke-key),
        "electricity diagram style",
        stroke-key,
      )
    }
  }
  for paint-key in ("component-fill", "source-fill", "junction-fill") {
    if paint-key in overrides {
      style-validation.validate-paint(
        overrides.at(paint-key),
        "electricity diagram style",
        paint-key,
      )
    }
  }
  if "label-text" in overrides {
    assert(
      type(overrides.label-text) == dictionary,
      message: "typed-physics: electricity diagram style `label-text:` must be a text-style dictionary",
    )
  }
  if "show-junctions" in overrides {
    core-validation.validate-boolean(
      overrides.show-junctions,
      "electricity diagram style",
      "show-junctions",
    )
  }
  if "resistor-symbol" in overrides {
    core-validation.validate-enum(
      overrides.resistor-symbol,
      ("zigzag", "rectangle"),
      "electricity diagram style",
      "resistor-symbol",
    )
  }
  if "voltage-source-symbol" in overrides {
    core-validation.validate-enum(
      overrides.voltage-source-symbol,
      ("battery", "circle"),
      "electricity diagram style",
      "voltage-source-symbol",
    )
  }
  let resolved-style = theme + overrides
  assert(
    resolved-style.resistor-length < resolved-style.component-length,
    message: "typed-physics: electricity diagram style `resistor-length:` must be smaller than `component-length:` so the resistor has visible leads",
  )
  assert(
    resolved-style.capacitor-plate-gap < resolved-style.component-length,
    message: "typed-physics: electricity diagram style `capacitor-plate-gap:` must be smaller than `component-length:` so the capacitor has visible leads",
  )
  resolved-style
}

#let resolve-component-style(diagram-style, component) = (
  symbol: component.style.at(
    "symbol",
    default: if component.component-kind == "resistor" {
      diagram-style.resistor-symbol
    } else if component.component-kind == "voltage-source" {
      diagram-style.voltage-source-symbol
    } else {
      none
    },
  ),
  fill: component.style.at(
    "fill",
    default: if component.component-kind == "voltage-source" {
      diagram-style.source-fill
    } else {
      diagram-style.component-fill
    },
  ),
  stroke: component.style.at("stroke", default: diagram-style.component-stroke),
  text: diagram-style.label-text + component.style.at("text", default: (:)),
)

#let scaled-diagram(diagram-style, content) = if diagram-style.scale == 1.0 {
  content
} else {
  scale(diagram-style.scale * 100%, reflow: true, content)
}
