#let _config = toml("../typst.toml")
#let version = _config.package.version
#let package_name = _config.package.name
/// Elembic prefix for this package.
#let PREFIX = "@preview/" + package_name + ",v" + version

/// A `--input name=true|false` flag as a bool; `none` when it is absent or
/// has any other value.
#let _bool_input(name) = {
  let value = sys.inputs.at(name, default: none)
  if value == "true" { true } else if value == "false" { false } else { none }
}

#let SHOW_SOLUTIONS_OVERRIDE = _bool_input("show-solutions")
