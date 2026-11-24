// Compound-series grids that draw every molecule at one shared chemical scale.

#import "../validation.typ": (
  _content-type,
  _invalid-input,
  _validate-positive-number,
  _validate-nonnegative-length,
  _validate-bool,
)
#import "api.typ": smiles, _typst-scale
#import "alignment.typ": _is-aligned-molecule, align-molecules
#import "../reaction/schemes.typ": mol

#let _is-molecule-item(item) = (
  type(item) == dictionary and item.at("__mol__", default: false)
)

#let _grid-molecule-item(item, item-index) = {
  if _is-molecule-item(item) { return item }
  if type(item) == str or _is-aligned-molecule(item) { return mol(item) }
  _invalid-input(
    "molecule-grid item " + str(item-index),
    "expected a SMILES string, mol(), or an align-molecules() result, got " + repr(item),
    "Wrap content in mol(...) and pass captions with mol(..., label: [...]).",
  )
}

// Per-molecule sizing would break the shared scale the grid exists to keep.
#let _validate-grid-item-options(molecule-item, item-index) = {
  for option-name in ("scale", "bond-length") {
    if option-name in molecule-item.opts {
      _invalid-input(
        "molecule-grid item " + str(item-index) + " " + option-name,
        "every molecule in a grid shares one scale, got " + repr(molecule-item.opts.at(option-name)),
        "Remove it from mol() and set molecule-grid(" + option-name + ": ...) instead.",
      )
    }
  }
}

// Orients the grid's molecules onto the first molecule's scaffold. Captions,
// annotations, offsets, and drawing options of each item are kept.
#let _align-grid-items(molecule-items, scaffold) = {
  for (item-index, molecule-item) in molecule-items.enumerate() {
    if type(molecule-item.spec) != str {
      _invalid-input(
        "molecule-grid item " + str(item-index),
        "scaffold alignment needs a SMILES molecule, got opaque content",
        "Pass SMILES strings or mol(\"...\") items, or remove scaffold:.",
      )
    }
    for option-name in ("rotation", "mirror") {
      if option-name in molecule-item.opts {
        _invalid-input(
          "molecule-grid item " + str(item-index) + " " + option-name,
          "the grid scaffold sets each molecule's orientation, got " + repr(molecule-item.opts.at(option-name)),
          "Remove it, or orient the series with align-molecules(rotation: ..., mirror: ...) and omit the grid scaffold.",
        )
      }
    }
  }
  let aligned-molecules = align-molecules(
    molecule-items.map(molecule-item => molecule-item.spec),
    scaffold: scaffold,
  )
  molecule-items.zip(aligned-molecules).map(((molecule-item, aligned-molecule)) => mol(
    aligned-molecule,
    label: molecule-item.label,
    offset: molecule-item.offset,
    ..molecule-item.annotations,
    ..molecule-item.opts,
  ))
}

#let _grid-molecule-body(molecule-item, scale, bond-length) = {
  if type(molecule-item.spec) != str { return molecule-item.spec }
  let body = smiles(
    molecule-item.spec,
    ..molecule-item.annotations,
    ..molecule-item.opts,
    scale: scale,
    bond-length: bond-length,
  )
  if molecule-item.offset == (0, 0) { return body }
  let canvas-unit = 30pt * bond-length
  move(
    dx: molecule-item.offset.at(0) * canvas-unit,
    dy: -molecule-item.offset.at(1) * canvas-unit,
    body,
  )
}

/// Arranges a series of molecules in a grid with one shared bond length, so
/// molecules of different sizes stay chemically comparable. Molecules are
/// centered in their cells and never enlarged individually; captions from
/// `mol(label: ...)` start on one line per row. Page breaks fall only between
/// rows, so a molecule never separates from its caption.
///
/// - columns (auto / int): Number of equal-width columns. `auto` uses one
///   column per molecule, up to four. Default: auto.
/// - scale (float): Shared scale of bonds, labels, and strokes. Default: 1.0.
/// - bond-length (none / float): Shared bond length (1.0 = 30 pt); overrides
///   the bond length implied by `scale`. Default: none.
/// - sizing ("fixed" / "fit"): "fixed" draws at the given scale and reports a
///   molecule too wide for its column; "fit" scales the whole series by one
///   common factor so the widest molecule fills its column. Default: "fixed".
/// - scaffold (none / str): Orient every SMILES molecule onto the first
///   molecule's occurrence of this SMARTS pattern, as `align-molecules()` does.
///   Default: none.
/// - column-gutter (length): Space between columns. Default: 1.5em.
/// - row-gutter (length): Space between rows. Default: 1.5em.
/// - label-gap (length): Space between a molecule and its caption. Default: 0.6em.
/// - breakable (bool): Allow page breaks between rows. Default: true.
/// - ..items: SMILES strings, `align-molecules()` results, or `mol()` items.
/// -> content
#let molecule-grid(
  columns: auto,
  scale: 1.0,
  bond-length: none,
  sizing: "fixed",
  scaffold: none,
  column-gutter: 1.5em,
  row-gutter: 1.5em,
  label-gap: 0.6em,
  breakable: true,
  ..items,
) = {
  if items.named().len() > 0 {
    let option-name = items.named().keys().first()
    _invalid-input(
      "molecule-grid option " + repr(option-name),
      "the option is not supported",
      "Use columns, scale, bond-length, sizing, scaffold, column-gutter, row-gutter, label-gap, or breakable; set drawing options on each mol().",
    )
  }
  let molecule-items = items.pos().enumerate().map(((item-index, item)) => _grid-molecule-item(item, item-index))
  if molecule-items.len() == 0 {
    _invalid-input(
      "molecule-grid items",
      "the grid is empty",
      "Pass at least one SMILES string or mol() item.",
    )
  }
  if columns != auto and (type(columns) != int or columns < 1) {
    _invalid-input(
      "molecule-grid columns",
      "expected auto or a positive integer, got " + repr(columns),
      "Pass a column count such as 3.",
    )
  }
  _validate-positive-number(scale, "molecule-grid scale")
  if bond-length != none {
    _validate-positive-number(bond-length, "molecule-grid bond-length")
  }
  if sizing not in ("fixed", "fit") {
    _invalid-input(
      "molecule-grid sizing",
      "expected \"fixed\" or \"fit\", got " + repr(sizing),
      "Use \"fixed\" for the given scale or \"fit\" for one common fitted scale.",
    )
  }
  if scaffold != none and (type(scaffold) != str or scaffold.trim() == "") {
    _invalid-input(
      "molecule-grid scaffold",
      "expected none or a non-empty SMARTS string, got " + repr(scaffold),
      "Pass a pattern shared by every molecule, such as \"c1ccccc1\".",
    )
  }
  _validate-nonnegative-length(column-gutter, "molecule-grid column-gutter")
  _validate-nonnegative-length(row-gutter, "molecule-grid row-gutter")
  _validate-nonnegative-length(label-gap, "molecule-grid label-gap")
  _validate-bool(breakable, "molecule-grid breakable")
  for (item-index, molecule-item) in molecule-items.enumerate() {
    _validate-grid-item-options(molecule-item, item-index)
  }
  if scaffold != none and molecule-items.len() < 2 {
    _invalid-input(
      "molecule-grid scaffold",
      "alignment needs at least two molecules, got " + str(molecule-items.len()),
      "Add molecules to the series or remove scaffold:.",
    )
  }

  let molecule-items = if scaffold == none {
    molecule-items
  } else {
    _align-grid-items(molecule-items, scaffold)
  }
  let column-count = if columns == auto { calc.min(molecule-items.len(), 4) } else { columns }
  let bond-length = if bond-length == none { scale } else { bond-length }
  let bodies = molecule-items.map(molecule-item => _grid-molecule-body(molecule-item, scale, bond-length))

  let grid-body = layout(container => {
    let measured-sizes = bodies.map(body => measure(body))
    let widest = calc.max(..measured-sizes.map(size => size.width))
    let unbounded-width = container.width == float.inf * 1pt
    let column-width = if unbounded-width {
      widest
    } else {
      (container.width - column-gutter.to-absolute() * (column-count - 1)) / column-count
    }
    let fit-factor = if sizing == "fit" and widest > 0pt { column-width / widest } else { 1.0 }
    if sizing == "fixed" and not unbounded-width {
      for (item-index, size) in measured-sizes.enumerate() {
        if size.width > column-width + 0.01pt {
          _invalid-input(
            "molecule-grid item " + str(item-index),
            "the molecule is "
              + repr(calc.round(size.width.pt(), digits: 1))
              + "pt wide but each of the "
              + str(column-count)
              + " columns is "
              + repr(calc.round(column-width.pt(), digits: 1))
              + "pt wide",
            "Use a smaller scale or bond-length, fewer columns, or sizing: \"fit\".",
          )
        }
      }
    }
    let scaled-body(body) = if fit-factor == 1.0 {
      body
    } else {
      _typst-scale(x: fit-factor * 100%, y: fit-factor * 100%, reflow: true, body)
    }
    let rows = range(0, molecule-items.len(), step: column-count).map(row-start => {
      range(row-start, calc.min(row-start + column-count, molecule-items.len()))
    })
    let cells = rows.map(row-indices => {
      let molecule-height = calc.max(..row-indices.map(item-index => measured-sizes.at(item-index).height)) * fit-factor
      row-indices.map(item-index => {
        let caption = molecule-items.at(item-index).label
        let molecule-cell = box(
          width: 100%,
          height: molecule-height,
          align(center + horizon, scaled-body(bodies.at(item-index))),
        )
        block(breakable: false, width: 100%, if caption == none {
          molecule-cell
        } else {
          stack(spacing: label-gap, molecule-cell, align(center, caption))
        })
      })
    }).flatten()
    grid(
      columns: (column-width,) * column-count,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      ..cells,
    )
  })
  if breakable { grid-body } else { block(breakable: false, grid-body) }
}
