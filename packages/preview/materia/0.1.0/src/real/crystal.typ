#import "figure.typ": crystal-scene, render

#let _default-view = (azimuth: 25deg, elevation: 15deg)

/// Renders a periodic crystal structure as a standalone figure.
///
/// - structure (dictionary): A value returned by `structure` or a file importer.
/// - view (dictionary): Camera azimuth/elevation and optional perspective mode.
/// - supercell (array): Repetitions along the three lattice directions.
/// - mode (str): `"ball-and-stick"`, `"space-filling"`/`"cpk"`, or `"licorice"`.
/// - bonds (auto, none, array): Automatic, disabled, or explicit bond rules.
/// - bond-color (auto, color): Two-tone bonds or one explicit bond color.
/// - polyhedra (array): Elements whose coordination polyhedra are drawn.
/// - labels (bool): Whether to label atoms with element symbols.
/// - legend (bool): Whether to draw element color swatches.
/// - axes (bool): Whether to draw the crystallographic orientation triad.
/// - radius (auto, float): Mode-dependent atom-radius scale.
/// - colors (dictionary): Element-to-color overrides.
/// - width (length): Target figure width.
/// - engine (str): `"typst"` (default) or the bundled `"wasm"` accelerator.
/// -> content
#let crystal(
  structure,
  view: _default-view,
  supercell: (1, 1, 1),
  mode: "ball-and-stick",
  bonds: auto,
  bond-color: auto,
  polyhedra: (),
  labels: false,
  legend: true,
  axes: true,
  radius: auto,
  colors: (:),
  width: 8cm,
  engine: "typst",
) = {
  let scene = crystal-scene(structure, view: view, supercell: supercell,
    mode: mode, bonds: bonds, bond-color: bond-color, polyhedra: polyhedra,
    labels: labels, radius: radius, colors: colors, engine: engine)
  render(scene, width: width, legend: legend, engine: engine,
    axes-info: if axes {
      (vectors: structure.vectors, view: view,
       n-axes: if structure.periodic.at(2) { 3 } else { 2 })
    } else { none })
}

/// Renders a non-periodic molecule: atoms and bonds, with no unit cell or
/// crystallographic triad. Same scene options as crystal().
///
/// - structure (dictionary): A non-periodic value returned by `import-xyz`.
/// - mode (str): `"ball-and-stick"`, `"space-filling"`/`"cpk"`, or `"licorice"`.
/// - engine (str): `"typst"` (default) or the bundled `"wasm"` accelerator.
/// -> content
#let molecule(
  structure,
  view: _default-view,
  bonds: auto,
  bond-color: auto,
  labels: false,
  legend: true,
  radius: auto,
  colors: (:),
  mode: "ball-and-stick",
  width: 8cm,
  engine: "typst",
) = {
  let scene = crystal-scene(structure, view: view, supercell: (1, 1, 1),
    mode: mode, bonds: bonds, bond-color: bond-color, polyhedra: (),
    labels: labels, radius: radius, colors: colors, engine: engine)
  render(scene, width: width, legend: legend, axes-info: none, engine: engine)
}
