// Reaction correspondence analysis and reactant/agent/product composition.
#import "plugins.typ": mol-plugin, _mol-data-to-bytes
#import "molecule.typ": render-mol, render-smiles
#import "composition.typ": _molecule-row, _reaction-row

#let inspect-reaction(data, format: "reaction-smiles", infer-mapping: false, search-limit: 200000) = {
  cbor(mol-plugin.reaction_inspection(_mol-data-to-bytes(data), bytes(format), bytes(repr(infer-mapping)), bytes(str(search-limit))))
}

/// Render reactants, reagents, conditions and products. Inferred mappings are
/// inspected separately; ambiguous/incomplete search is never hidden.
#let render-reaction(data, format: "reaction-smiles", infer-mapping: false, search-limit: 200000, highlight-center: true, mapping-policy: "report", fidelity: "ignore", conditions: none, skeletal: true, config: (:)) = {
  assert(mapping-policy in ("report", "strict"), message: "Unknown reaction mapping policy")
  assert(fidelity in ("ignore", "strict"), message: "Unknown fidelity policy")
  let analysis = inspect-reaction(data, format: format, infer-mapping: infer-mapping, search-limit: search-limit)
  if mapping-policy == "strict" {
    assert(analysis.searchComplete and not analysis.ambiguous, message: "Reaction atom mapping is ambiguous or search is incomplete")
  }
  metadata((kind: "molchemist-reaction", analysis: analysis))
  let changed = analysis.changes.map(c => c.maps).flatten().dedup()
  let render-side(molecules, side) = {
    let drawings = ()
    for (index, mol) in molecules.enumerate() {
      if index > 0 { drawings.push(box(baseline: 0.35em)[$+$]) }
      let highlighted = analysis.at(side + "Atoms").filter(a => a.map in changed and a.molecule == index).map(a => "a" + str(a.atom))
      let bonds = analysis.changes.filter(c => c.at(side) != none and c.at(side).at(0) == index).map(c => c.at(side).slice(1).map(i => "a" + str(i)))
      let style = (layout: "avoid", ..config, highlight-atoms: if highlight-center { highlighted } else { () }, highlight-bonds: if highlight-center { bonds } else { () })
      drawings.push(if mol.format == "smiles" { render-smiles(mol.data, skeletal: skeletal, config: style) } else { render-mol(mol.data, skeletal: skeletal, fidelity: fidelity, config: style) })
    }
    _molecule-row(drawings)
  }
  let agents = analysis.reaction.agents.map(m => if m.format == "smiles" { render-smiles(m.data, skeletal: skeletal, config: config) } else { render-mol(m.data, skeletal: skeletal, fidelity: fidelity, config: config) })
  _reaction-row(render-side(analysis.reaction.reactants, "reactant"), agents,
    render-side(analysis.reaction.products, "product"), conditions)
}
