#let _config = toml("../typst.toml")
#let version = _config.package.version
#let package_name = _config.package.name
/// Elembic prefix for this package.
#let PREFIX = "@preview/" + package_name + ",v" + version

#let SHOW_SOLUTIONS_OVERRIDE = sys.inputs.at("show-solutions", default: none)
#let SHOW_SOLUTIONS_OVERRIDE = if SHOW_SOLUTIONS_OVERRIDE == "true" { true } else if (
  SHOW_SOLUTIONS_OVERRIDE == "false"
) { false } else { none }
#let SHOW_RUBRIC_OVERRIDE = sys.inputs.at("show-rubric", default: none)
#let SHOW_RUBRIC_OVERRIDE = if SHOW_RUBRIC_OVERRIDE == "true" { true } else if (
  SHOW_RUBRIC_OVERRIDE == "false"
) { false } else { none }
