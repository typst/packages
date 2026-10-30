// Keep plugin loading lazy so constructors can be used before the WASM build.
#let backend() = plugin("../wasm/michem.wasm")

/// A SMILES molecule; optional coordinates cover all atoms in parse order.
#let smiles-input(value, positions: none) = (
  kind: "smiles",
  value: value,
  positions: positions,
)

/// Named atom. Coordinates are normalized bond units with y pointing upward.
#let atom(
  id,
  element: "C",
  at: none,
  charge: 0,
  hydrogens: none,
  isotope: none,
  aromatic: false,
) = (
  id: id,
  element: element,
  position: at,
  charge: charge,
  hydrogens: hydrogens,
  isotope: isotope,
  aromatic: aromatic,
)

/// A bond between atom names; order is single, double, triple, or aromatic.
#let bond(from, to, order: "single") = (from: from, to: to, order: order)

/// Manual topology with automatic layout, or complete explicit coordinates.
#let molecule(atoms: (), bonds: ()) = (
  kind: "manual",
  atoms: atoms,
  bonds: bonds,
)

#let color-value(value) = {
  if type(value) == color { value.to-hex() } else { value }
}

/// Paint configuration; accepts Typst colors and hexadecimal strings.
#let style(..options) = {
  assert(options.pos().len() == 0, message: "style expects named options")
  let result = options.named()
  for key in ("foreground", "background") {
    if key in result and result.at(key) != none {
      result.insert(key, color-value(result.at(key)))
    }
  }
  if "color-map" in result {
    let colors = (:)
    for (element, value) in result.at("color-map") {
      colors.insert(element, color-value(value))
    }
    result.insert("color-map", colors)
  }
  result
}

/// Automatic layout parameters, expressed as named options.
#let layout(..options) = {
  assert(options.pos().len() == 0, message: "layout expects named options")
  options.named()
}

/// Typography shared by measurement and native Typst mechanism labels.
#let host-text(
  family,
  size,
  body,
  top-edge: "bounds",
  bottom-edge: "bounds",
  fill: black,
) = text(
  font: family,
  size: size * 0.75pt,
  style: "normal",
  weight: "regular",
  stretch: 100%,
  kerning: false,
  ligatures: false,
  tracking: 0pt,
  top-edge: top-edge,
  bottom-edge: bottom-edge,
  fill: fill,
  body,
)

#let request(mol, style: (:), layout: (:), scale: 1) = {
  let data = (
    molecule: if type(mol) == str { smiles-input(mol) } else { mol },
    style: style,
    layout: layout,
    "measurement-scale": scale,
  )
  let font = style.at("font", default: none)
  if font != none {
    assert(type(font) == str, message: "font must be a Typst font family name")
    let labels = json(backend().labels(bytes(json.encode(data))))
    let measurements = labels.map(label => {
      let run = host-text.with(font, label.size)
      let advance = measure(run(label.text)).width / 0.75pt
      let ascent = (
        measure(run(
          top-edge: "bounds",
          bottom-edge: "baseline",
          label.text,
        )).height
          / 0.75pt
      )
      let descent = (
        measure(run(
          top-edge: "baseline",
          bottom-edge: "bounds",
          label.text,
        )).height
          / 0.75pt
      )
      (
        text: label.text,
        size: label.size,
        key: label.key,
        advance: advance,
        min: (0, -ascent),
        max: (advance, descent),
      )
    })
    data.insert("measurements", measurements)
  }
  bytes(json.encode(data))
}

/// SVG and geometry, including atom anchors and layout diagnostics.
#let diagram(mol, style: (:), layout: (:)) = {
  let data = request(mol, style: style, layout: layout)
  json(backend().diagram(data))
}

/// Portable SVG bytes for export or custom image placement.
#let svg(mol, style: (:), layout: (:)) = {
  let data = request(mol, style: style, layout: layout)
  backend().render(data)
}

/// Render a molecule as Typst content; SVG drawing units are pixels (0.75pt).
#let smiles(mol, style: (:), layout: (:), width: auto, height: auto) = context {
  image(
    svg(mol, style: style, layout: layout),
    format: "svg",
    width: width,
    height: height,
  )
}
