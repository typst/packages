// Chemical formula integration and Rust plugin entrypoints.

#import "@preview/chemformula:0.1.3": ch
#import "validation.typ": _invalid-input, _validate-bool, _validate-charge-style
#import "molecule/label-fragments.typ": _prepare-abbreviation-fragments

#let _smiles-plugin = plugin("../plugin/typst_smiles_plugin.wasm")

// A math font extends an arrow to the width of its labels only when it carries
// a glyph assembly for that arrow. New Computer Modern Math ships with Typst
// and carries assemblies for every reaction arrow, so it stands in for fonts
// that lack one.
#let _arrow-fallback-font = "New Computer Modern Math"
#let _reaction-arrow-glyphs = (
  sym.arrow.r,
  sym.arrow.l,
  sym.arrow.l.r,
  sym.harpoons.rtlb,
)

// Labels can be several em wide, so the probe is long enough that only
// glyphs with an unbounded assembly reach it.
#let _arrow-probe-length-in-ems = 10
#let _arrow-probe-tolerance = 0.9

// Whether the math font at the call site stretches `arrow` to `length`.
#let _font-extends-arrow(arrow, length) = {
  let stretched-arrow = measure(math.equation(math.stretch(arrow, size: length)))
  stretched-arrow.width >= length * _arrow-probe-tolerance
}

// Keeps the reader's math font unless it cannot extend every reaction arrow,
// in which case the arrows are drawn from the fallback font so they span their
// labels like in any other font.
#let _with-extensible-arrows(body) = context {
  let probe-length = text.size * _arrow-probe-length-in-ems
  let font-extends-every-arrow = _reaction-arrow-glyphs.all(arrow => _font-extends-arrow(arrow, probe-length))
  show math.stretch: set text(font: _arrow-fallback-font) if not font-extends-every-arrow
  body
}

// The letters and digits of math content, which is all that is needed to
// recognize a written charge.
#let _plain-text(math-content) = {
  if type(math-content) == str { return math-content }
  if math-content.has("text") { return math-content.text }
  if math-content.has("body") { return _plain-text(math-content.body) }
  if math-content.has("children") {
    return math-content.children.map(_plain-text).join("")
  }
  ""
}

// Reads a charge such as "+", "2−", or "3+" from a superscript, or none when
// the superscript is anything else (an isotope, an exponent, a label).
#let _written-charge(superscript) = {
  if superscript == none { return none }
  let charge-match = _plain-text(superscript).match(regex("^(\\d*)([+\u{2212}-])$"))
  if charge-match == none { return none }
  let (digits, sign) = charge-match.captures
  (digits: digits, is-positive: sign == "+")
}

// Written as characters because the symbol names for circled signs differ
// between Typst versions.
#let _circled-plus = "\u{2295}"
#let _circled-minus = "\u{2296}"

// A charge sign inside a circle, written after its digits like "2⊕".
#let _circled-charge-script(charge) = {
  let circled-sign = math.class(
    "normal",
    text(if charge.is-positive { _circled-plus } else { _circled-minus }),
  )
  if charge.digits == "" { return circled-sign }
  math.equation(block: false, text(charge.digits) + circled-sign)
}

// Applies the requested charge style to one attachment. An attachment without
// a charge, or whose charge is already in the requested form, comes back
// unchanged, so the rewritten attachment is not rewritten again. A non-stacked
// charge is attached to the base together with its subscript, which places it
// after the subscript instead of above it.
#let _restyle-charge-attachment(attachment, charge-style, stacked-charges) = {
  let charge = _written-charge(attachment.tr)
  if charge == none { return attachment }
  let moves-subscript-before-charge = not stacked-charges and attachment.br != none
  if charge-style == "plain" and not moves-subscript-before-charge { return attachment }
  let charge-script = if charge-style == "circled" {
    _circled-charge-script(charge)
  } else {
    attachment.tr
  }
  // Typst folds an attachment on an attachment back into one stacked pair, so
  // the subscripted base is wrapped to keep it a single unit.
  let base = if moves-subscript-before-charge {
    math.class("normal", math.attach(attachment.base, br: attachment.br))
  } else {
    attachment.base
  }
  math.attach(
    base,
    t: attachment.t,
    b: attachment.b,
    tl: attachment.tl,
    bl: attachment.bl,
    tr: charge-script,
    br: if moves-subscript-before-charge { none } else { attachment.br },
  )
}

#let _with-charge-style(charge-style, stacked-charges, body) = {
  if charge-style == "plain" and stacked-charges { return body }
  show math.attach: attachment => _restyle-charge-attachment(
    attachment,
    charge-style,
    stacked-charges,
  )
  body
}

// Re-export as ce so users only need one import line.
// chemformula uses math mode internally, giving proper operator spacing.
#let ce(
  chem,
  font: none,
  font-size: none,
  charge-style: "plain",
  stacked-charges: true,
  ..args,
) = {
  _validate-charge-style(charge-style, "ce charge-style")
  _validate-bool(stacked-charges, "ce stacked-charges")
  let formula = _with-extensible-arrows(
    _with-charge-style(charge-style, stacked-charges, ch(chem, ..args)),
  )
  show math.equation: set text(font: font) if font != none
  show math.equation: set text(size: font-size) if font-size != none
  formula
}

// Catalogue names accepted by automatic abbreviation, in priority order.
#let _abbreviation-names() = json(_smiles-plugin.abbreviation_names())

// Parse a SMILES string into layout JSON via the WASM plugin. A non-none
// `abbreviation-request` ("all" or comma-separated catalogue names) draws the
// matching terminal groups as labels while keeping original atom indices.
#let _compute-layout(smiles-str, abbreviation-request: none) = {
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
  if abbreviation-request == none {
    json(_smiles-plugin.layout(bytes(smiles-str)))
  } else {
    _prepare-abbreviation-fragments(json(_smiles-plugin.layout_abbreviated(
      bytes(smiles-str),
      bytes(abbreviation-request),
    )))
  }
}

// Orients molecules onto a reference through the WASM plugin. The request
// carries molecules, scaffold, atoms, reference, and allow_reflection, already
// validated at the public call boundary.
#let _compute-alignment(request) = {
  json(_smiles-plugin.align_molecules(bytes(json.encode(request))))
}

/// Finds distinct SMARTS substructures in depiction writing-order indices.
/// Returns an array of (atoms: (indices...), bonds: ((from, to)...)) dictionaries.
/// No match returns (); malformed or unsupported patterns produce a diagnostic.
#let substructure-matches(smiles-str, pattern) = {
  if type(smiles-str) != str or smiles-str.trim() == "" {
    _invalid-input(
      "substructure-matches SMILES expression",
      "expected a non-empty string, got " + repr(smiles-str),
      "Pass a SMILES string such as \"CCO\".",
    )
  }
  if type(pattern) != str or pattern.trim() == "" {
    _invalid-input(
      "SMARTS pattern",
      "expected a non-empty string, got " + repr(pattern),
      "Pass a pattern such as \"C(=O)[OX2H1]\".",
    )
  }
  json(_smiles-plugin.substructure_matches(bytes(smiles-str), bytes(pattern)))
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
