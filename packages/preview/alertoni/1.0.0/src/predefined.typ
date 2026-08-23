#import "@preview/tableau-icons:0.344.0": ti-icon

#let ti-icon = ti-icon.with(top-edge: "bounds", bottom-edge: "bounds")

// NOTE: the .with is only used, so additional configuraiton using .map can be done ==> .map(v => v()) IS REQUIRED!
#let default-icon-set = (
  "info": ti-icon.with("info-circle"),
  "warning": ti-icon.with("alert-triangle"),
  "important": ti-icon.with("exclamation-circle"),
  "tip": ti-icon.with("bulb"),
  "caution": ti-icon.with("traffic-cone"),
  "correct": ti-icon.with("check"),
  "incorrect": ti-icon.with("x"),
  "example": ti-icon.with("tools"),
).map(v => v(top-edge: "bounds", bottom-edge: "bounds"))




#let default-callout-types = (
  // quarto based callouts
  info: (
    color: rgb("#2780e3"),
    placeholder: (de: "Information", en: "Information", fallback: "Information"),
  ),
  warning: (
    color: rgb("#ff7518"),
    placeholder: (de: "Warnung", en: "Warning", fallback: "Warning"),
  ),
  important: (
    color: rgb("#ff0039"),
    placeholder: (de: "Wichtig", en: "Important", fallback: "Important"),
  ),
  tip: (
    color: rgb("#3fb618"),
    placeholder: (de: "Tipp", en: "Tip", fallback: "Tip"),
  ),
  caution: (
    color: rgb("#f0ad4e"),
    placeholder: (de: "Vorsicht", en: "Caution", fallback: "Caution"),
  ),
  // my callouts
  correct: (
    color: green.darken(5%),
    placeholder: (de: "Korrekt", en: "Correct", fallback: "Correct"),
  ),
  incorrect: (
    color: red.darken(5%),
    placeholder: (de: "Inkorrekt", en: "Incorrect", fallback: "Incorrect"),
  ),
  example: (
    color: rgb("#966FD6"),
    placeholder: (de: "Beispiel", en: "Example", fallback: "Example"),
  ),
)