#let _config = toml("../typst.toml")
#let version = _config.package.version
#let package_name = _config.package.name
/// Elembic prefix for this package.
#let PREFIX = "@preview/" + package_name + ",v" + version

/// How many rounds of a walk over content one round of its outer loop runs.
/// Typst ends a `while` loop after 10,000 rounds, taking it for an infinite
/// one, and a walk goes round once per piece of content it meets, so a long
/// exam goes round more often than that. Each walk runs its loop in batches
/// of this many, inside an outer loop, whose count of rounds is its own:
///
/// ```typst
/// while stack.len() > 0 {
///   let round = 0
///   while stack.len() > 0 and round < BATCH {
///     round += 1
///     ..
///   }
/// }
/// ```
///
/// (Not a function that takes the round as a closure: Typst memoizes each
/// call, hashing its arguments, the walk's stack among them, every round.)
#let BATCH = 9999

/// A `--input name=true|false` flag as a bool; `none` when it is absent.
/// `alias`, its name in the singular, is read too, so that either spelling
/// works; given both, they must agree. Any other value is an error.
#let _bool_input(name, alias: none) = {
  let read(name) = {
    let value = sys.inputs.at(name, default: none)
    assert(
      value in (none, "true", "false"),
      message: "examy: `--input " + name + "` must be `true` or `false`, got `" + repr(value).trim("\"") + "`",
    )
    if value == none { none } else { value == "true" }
  }
  let value = read(name)
  if alias == none { return value }
  let other = read(alias)
  assert(
    value == none or other == none or value == other,
    message: "examy: `--input " + name + "` and `--input " + alias + "` are the same option, and disagree",
  )
  if value == none { other } else { value }
}

#let SHOW_SOLUTIONS_OVERRIDE = _bool_input("show-solutions", alias: "show-solution")
#let SHOW_RUBRICS_OVERRIDE = _bool_input("show-rubrics", alias: "show-rubric")

/// `--input _debug_panic=..`: what the check every question carries does
/// when no exam lays the question out (see `outside_check`).
/// `"text-warning"` (the default) shows a warning in red where it is;
/// `"panic"` fails the compile, for a build that must not produce a
/// document with one; `"none"` leaves the check out of every question.
#let DEBUG_PANIC = {
  let value = sys.inputs.at("_debug_panic", default: "text-warning")
  let modes = ("text-warning", "panic", "none")
  assert(
    value in modes,
    message: "examy: `--input _debug_panic` must be " + modes.map(m => "`" + m + "`").join(", ", last: ", or ") + ", got `" + value + "`",
  )
  value
}
