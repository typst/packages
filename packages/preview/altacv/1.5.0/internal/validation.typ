// Shared validators. `_strict_merge` is the typo-catcher used to
// merge user overrides over the built-in defaults dicts; `_check_bool`
// is the uniform bool-validation helper for individual preference
// fields. Both panic on misuse so errors surface at the caller rather
// than as cryptic render-time failures.

// Panics on the wrong override-shape (non-dictionary) up front, then
// on unknown keys so typos surface as errors instead of being silently
// absorbed.
#let _strict_merge(defaults, overrides, name) = {
  if type(overrides) != dictionary {
    panic(name + " must be a dictionary, got: " + repr(overrides))
  }
  let unknown = overrides.keys().filter(k => k not in defaults)
  if unknown.len() > 0 {
    panic(
      "Unknown " + name + " key(s): " + unknown.join(", ")
        + ". Valid keys: " + defaults.keys().join(", "),
    )
  }
  defaults + overrides
}

// Shared validator for bool-typed preferences — keeps panic messages
// uniform and avoids the same five-line `if type(...) != bool` block
// across every new pref.
#let _check_bool(name, value) = {
  if type(value) != bool {
    panic(name + " must be a bool, got: " + repr(value))
  }
}
