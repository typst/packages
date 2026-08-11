#let _config = toml("../typst.toml")
#let version = _config.package.version
#let package_name = _config.package.name
/// Elembic prefix for this package.
#let PREFIX = "@preview/" + package_name + ",v" + version

/// Value used for determining if a key is in a dictionary.
#let NOT_FOUND_SENTINEL = () => {}