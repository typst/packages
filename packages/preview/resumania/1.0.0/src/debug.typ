// These are utilities for assisting with debugging layouts for the resume.
//
// They can be enabled by passing `--input debug=true` to the Typst compilation
// command.
// -----------------------------------------------------------------------------

// This is the state which determines whether or not debugging utilities are
// enabled.
#let is-debug-enabled = state("resumania:debug:is-debug-enabled",
  sys.inputs.at("debug", default: "false") == "true",
)

// Create a `block` with visual debugging depending of whether debug utilities
// are enabled.
// 
// Since every style-able part of the resume is `block`ed, this function can be
// used instead to allow additional visual styling when debugging is enabled.
//
// It is better to use this over set and show rules to enforce deliberate use of
// blocks where they make sense, and so any other blocks outside of this library
// are not affected.
#let debug-block(content, ..block-args) = {
  context if is-debug-enabled.get() {
    return block(
      fill: rgb(0, 0, 0, 10),
      stroke: 0.1mm + rgb(0, 0, 0, 50),
      ..block-args,
      content,
    )
  } else {
    return block(content, ..block-args)
  }
}
