// Chemical formula integration and Rust plugin entrypoints.

#import "@preview/chemformula:0.1.3": ch
#import "validation.typ": _invalid-input

#let _smiles-plugin = plugin("../plugin/typst_smiles_plugin.wasm")

// Re-export as ce so users only need one import line.
// chemformula uses math mode internally, giving proper operator spacing.
#let ce(chem, font: none, font-size: none, ..args) = {
  if font == none and font-size == none {
    ch(chem, ..args)
  } else if font == none {
    [
      #show math.equation: set text(size: font-size)
      #ch(chem, ..args)
    ]
  } else if font-size == none {
    [
      #show math.equation: set text(font: font)
      #ch(chem, ..args)
    ]
  } else {
    [
      #show math.equation: set text(font: font, size: font-size)
      #ch(chem, ..args)
    ]
  }
}

// Parse a SMILES string into layout JSON via the WASM plugin.
#let _compute-layout(smiles-str) = {
  if type(smiles-str) != str {
    _invalid-input(
      "SMILES expression",
      "expected a string, got " + repr(smiles-str),
      "Pass a SMILES string such as \"CCO\".",
    )
  }
  if smiles-str.trim() == "" {
    _invalid-input(
      "SMILES expression",
      "the string is empty",
      "Pass at least one atom, such as \"C\".",
    )
  }
  json(_smiles-plugin.layout(bytes(smiles-str)))
}

/// Computes the molecular weight of a SMILES string in g/mol, summing IUPAC
/// standard atomic weights over all atoms including implicit and explicit
/// hydrogens. Errors on input whose mass is undefined: wildcard `*` atoms,
/// `{label}` abbreviations, and isotope-labeled atoms.
///
/// - smiles-str (str): A valid SMILES string, e.g. "CCO".
/// -> float
#let mol-weight(smiles-str) = {
  if type(smiles-str) != str {
    _invalid-input(
      "mol-weight SMILES expression",
      "expected a string, got " + repr(smiles-str),
      "Pass a SMILES string such as \"CCO\".",
    )
  }
  if smiles-str.trim() == "" {
    _invalid-input(
      "mol-weight SMILES expression",
      "the string is empty",
      "Pass at least one atom, such as \"C\".",
    )
  }
  json(_smiles-plugin.mol_weight(bytes(smiles-str)))
}

/// Computes a Hill-ordered molecular formula from a SMILES string and renders
/// it through chemformula. Dot-separated fragments are combined into one
/// composition and their formal charges are summed. Errors on wildcards,
/// abbreviations, and isotope-labeled atoms whose formula representation would
/// need isotope-aware formatting.
///
/// - smiles-str (str): A valid SMILES string, e.g. "CCO".
/// -> content
#let mol-formula(smiles-str) = {
  if type(smiles-str) != str {
    _invalid-input(
      "mol-formula SMILES expression",
      "expected a string, got " + repr(smiles-str),
      "Pass a SMILES string such as \"CCO\".",
    )
  }
  if smiles-str.trim() == "" {
    _invalid-input(
      "mol-formula SMILES expression",
      "the string is empty",
      "Pass at least one atom, such as \"C\".",
    )
  }
  ce(json(_smiles-plugin.mol_formula(bytes(smiles-str))))
}
