// Particle names are configurable drawing conventions, not theory validation.
/// Built-in propagator presets: scalar, fermion, photon, gluon, ghost and double.
/// -> dictionary
#let styles = (
  scalar: (line: "dashed", arrow: "none"),
  fermion: (line: "solid", arrow: "forward"),
  photon: (line: "wave", arrow: "none"),
  gluon: (line: "coil", arrow: "none", amplitude: 0.168, gluon-aspect: 1.1),
  ghost: (line: "dotted", arrow: "forward"),
  double: (line: "double", arrow: "none"),
)
#let check-style(style) = {
  assert(type(style) == dictionary, message: "style must be a dictionary")
  for key in style.keys() {
    assert(("line", "arrow", "paint", "thickness", "amplitude", "wavelength", "gluon-aspect").contains(key), message: "unknown style option: " + key)
  }
  assert(("solid", "dashed", "dotted", "wave", "coil", "double").contains(style.at("line", default: "solid")), message: "unknown line style")
  assert(("none", "forward", "backward").contains(style.at("arrow", default: "none")), message: "invalid arrow direction")
  for key in ("amplitude", "wavelength") {
    let n = style.at(key, default: 1)
    assert((type(n) == int or type(n) == float) and n > 0 and n < calc.inf, message: "invalid " + key)
  }
  let thickness = style.at("thickness", default: 0.9pt)
  let aspect = style.at("gluon-aspect", default: 1.1)
  assert((type(aspect) == int or type(aspect) == float) and aspect >= 0 and aspect < calc.inf, message: "invalid gluon-aspect")
  assert(type(thickness) == length and thickness > 0pt, message: "invalid thickness")
  style
}
/// Return a registry with a new preset. The original is unchanged; duplicate names are rejected.
/// -> dictionary
#let register-style(
  /// The original propagator registry.
  /// -> dictionary
  registry,
  /// A non-empty name for the new preset.
  /// -> str
  name,
  /// A style dictionary; see the style fields. Custom rendering callbacks are not supported.
  /// -> dictionary
  definition,
) = {
  assert(type(name) == str and name != "", message: "invalid style name")
  assert(not (name in registry), message: "duplicate style name")
  registry.insert(name, check-style(definition))
  registry
}
#let resolve-style(registry, particle, overrides) = {
  assert(particle in registry, message: "unknown particle style: " + particle)
  check-style((line: "solid", arrow: "none", paint: black, thickness: 0.9pt,
    amplitude: 0.085, wavelength: 0.42, ..check-style(registry.at(particle)), ..check-style(overrides)))
}
