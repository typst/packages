// rendering/colors.typ — Color palettes, theme helpers
// Contains all color definitions for Scratch block categories.

// ------------------------------------------------
// State for global Scratch block options
// ------------------------------------------------
#let scratch-block-options = state("scratch-block-options", (
  theme: "normal",    // "normal" or "high-contrast"
  stroke-width: auto, // auto or specific length (e.g. 1pt)
  scale: 100%,        // block scale
  font: "Helvetica Neue", // font family for block text
))

// Internal helper — use set-blockst() from lib.typ as the public API
#let set-scratch(theme: auto, stroke-width: auto, scale: auto, font: auto) = {
  scratch-block-options.update(current => {
    let new-state = current
    if theme != auto {
      new-state.theme = theme
    }
    if stroke-width != auto {
      new-state.stroke-width = stroke-width
    }
    if scale != auto {
      new-state.scale = scale
    }
    if font != auto {
      new-state.font = font
    }
    new-state
  })
}

// ------------------------------------------------
// Color palettes
// ------------------------------------------------
// Standard Scratch colors (official Blockly naming convention)
#let colors-normal = (
  text-color: rgb("#FFFFFF"),
  motion:    (primary: rgb("#4C97FF"), secondary: rgb("#4280D7"), tertiary: rgb("#3373CC"), quaternary: rgb("#3373CC")),
  looks:     (primary: rgb("#9966FF"), secondary: rgb("#855CD6"), tertiary: rgb("#774DCB"), quaternary: rgb("#774DCB")),
  sound:     (primary: rgb("#CF63CF"), secondary: rgb("#C94FC9"), tertiary: rgb("#BD42BD"), quaternary: rgb("#BD42BD")),
  events:    (primary: rgb("#FFBF00"), secondary: rgb("#E6AC00"), tertiary: rgb("#CC9900"), quaternary: rgb("#CC9900")),
  control:   (primary: rgb("#FFAB19"), secondary: rgb("#EC9C13"), tertiary: rgb("#CF8B17"), quaternary: rgb("#CF8B17")),
  sensing:   (primary: rgb("#5CB1D6"), secondary: rgb("#47A8D1"), tertiary: rgb("#2E8EB8"), quaternary: rgb("#2E8EB8")),
  operators: (primary: rgb("#59C059"), secondary: rgb("#46B946"), tertiary: rgb("#389438"), quaternary: rgb("#389438")),
  variables: (primary: rgb("#FF8C1A"), secondary: rgb("#FF8000"), tertiary: rgb("#DB6E00"), quaternary: rgb("#DB6E00")),
  lists:     (primary: rgb("#FF661A"), secondary: rgb("#FF5500"), tertiary: rgb("#E64D00"), quaternary: rgb("#E64D00")),
  custom:    (primary: rgb("#FF6680"), secondary: rgb("#FF4D6A"), tertiary: rgb("#FF3355"), quaternary: rgb("#FF3355")),
  pen:       (primary: rgb("#0FBD8C"), secondary: rgb("#0DA57A"), tertiary: rgb("#0B8E69"), quaternary: rgb("#0B8E69")),
)

// High-contrast variant (official Scratch high-contrast colors)
#let colors-high-contrast = (
  text-color: rgb("#000000"),
  motion:    (primary: rgb("#80B5FF"), secondary: rgb("#B3D2FF"), tertiary: rgb("#3373CC"), quaternary: rgb("#CCE1FF")),
  looks:     (primary: rgb("#CCB3FF"), secondary: rgb("#DDCCFF"), tertiary: rgb("#774DCB"), quaternary: rgb("#EEE5FF")),
  sound:     (primary: rgb("#E19DE1"), secondary: rgb("#FFB3FF"), tertiary: rgb("#BD42BD"), quaternary: rgb("#FFCCFF")),
  events:    (primary: rgb("#FFD966"), secondary: rgb("#FFECB3"), tertiary: rgb("#CC9900"), quaternary: rgb("#FFF2CC")),
  control:   (primary: rgb("#FFBE4C"), secondary: rgb("#FFDA99"), tertiary: rgb("#CF8B17"), quaternary: rgb("#FFE3B3")),
  sensing:   (primary: rgb("#85C4E0"), secondary: rgb("#AED8EA"), tertiary: rgb("#2E8EB8"), quaternary: rgb("#C2E2F0")),
  operators: (primary: rgb("#7ECE7E"), secondary: rgb("#B5E3B5"), tertiary: rgb("#389438"), quaternary: rgb("#DAF1DA")),
  variables: (primary: rgb("#FFA54C"), secondary: rgb("#FFCC99"), tertiary: rgb("#DB6E00"), quaternary: rgb("#FFE5CC")),
  lists:     (primary: rgb("#FF9966"), secondary: rgb("#FFCAB0"), tertiary: rgb("#E64D00"), quaternary: rgb("#FFDDCC")),
  custom:    (primary: rgb("#FF99AA"), secondary: rgb("#FFCCD5"), tertiary: rgb("#FF3355"), quaternary: rgb("#FFE5EA")),
  pen:       (primary: rgb("#13ECAF"), secondary: rgb("#75F0CD"), tertiary: rgb("#0B8E69"), quaternary: rgb("#A3F5DD")),
)

// ------------------------------------------------
// Theme/Stroke helpers
// ------------------------------------------------
// Get color palette from options
#let get-colors-from-options(options) = {
  if options.theme == "high-contrast" {
    colors-high-contrast
  } else {
    colors-normal
  }
}

// Get stroke thickness from options
#let get-stroke-from-options(options) = {
  if options.stroke-width != auto {
    options.stroke-width
  } else if options.theme == "high-contrast" {
    1.0pt
  } else {
    0.5pt
  }
}

// Get font family from options
#let get-font-from-options(options) = options.at("font", default: "Helvetica Neue")

// ------------------------------------------------
// Public helper functions (require context!)
// ------------------------------------------------
// Returns the current colors dictionary (requires context!)
// Usage: #context { let colors = get-colors(); ... }
#let get-colors() = {
  let options = scratch-block-options.get()
  get-colors-from-options(options)
}

// Returns the current stroke thickness (requires context!)
#let get-stroke() = {
  let options = scratch-block-options.get()
  get-stroke-from-options(options)
}

// ------------------------------------------------
// Legacy aliases (German keys → English keys)
// For backward compatibility with code referencing colors.bewegung etc.
// ------------------------------------------------
// These are provided as functions that wrap the English-keyed palettes
// so that existing user code like `colors.bewegung` still works.
// Note: The raw dictionaries above use English keys.
// The legacy mapping is applied in the barrel file (scratch.typ).
