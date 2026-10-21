// RGfile roots, alternative members, attachment sites and logic panels.
#import "plugins.typ": mol-plugin, _mol-data-to-bytes
#import "molecule.typ": render-mol, inspect-mol
#import "composition.typ": _rgroup-panel

#let inspect-rgroup(data) = cbor(mol-plugin.rgroup_inspection(_mol-data-to-bytes(data)))

/// Show all R-group alternatives, their attachment sites, and source logic.
#let render-rgroup(data, skeletal: true, fidelity: "strict", config: (:)) = {
  assert(fidelity in ("ignore", "strict"), message: "Unknown fidelity policy")
  let document = inspect-rgroup(data)
  let root = render-mol(document.root, skeletal: skeletal, fidelity: fidelity, config: (layout: "avoid", ..config))
  let members = ()
  for member in document.members {
    let inspection = inspect-mol(member.data)
    if fidelity == "strict" {
      let remaining = inspection.diagnostics.filter(d => d.code != "rgroup-attachment-context-not-supported")
      assert(remaining.len() == 0, message: "Unsupported R-group member data: " + repr(remaining))
    }
    let attachments = (:)
    for (atom, points) in member.attachments { attachments.insert("a" + str(atom), points) }
    members.push((group: member.group, drawing: render-mol(member.data, skeletal: skeletal, config: (layout: "avoid", ..config, attachment-points: attachments))))
  }
  _rgroup-panel(root, members, document.conditions)
}
