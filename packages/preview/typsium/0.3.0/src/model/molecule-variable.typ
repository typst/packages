#import "@preview/elembic:1.1.0" as e
#import "../utils.typ": (
  // is-sequence,
  // is-kind,
  // is-heading,
  // is-metadata,
  // padright,
  // get-all-children,
  // hydrates,
  // elements,
  // get-element-dict,
  // get-molecule-dict,
  // to-string,
)

#let element-variable = e.types.declare(
  "molecule-variable",
  prefix: "@preview/typsium:0.3.0",
  fields: ()
)

#let get-weight(molecule) = {
  let element = get-element-dict(molecule)
  molecule = get-molecule-dict(molecule)
  if type(element) == dictionary and element.at("atomic-weight", default: none) != none {
    return element.atomic-weight
  }
  let weight = 0
  for value in molecule.elements {
    let element = elements.find(x => x.symbol == value.at(0))

    weight += element.atomic-weight * value.at(1)
  }
  return weight
}

#let define-molecule(
  common-name: none,
  iupac-name: none,
  formula: "",
  smiles: "",
  inchi: "",
  cas: "",
  h-p: (),
  ghs: (),
  validate: true,
) = {
  let found-elements
  if validate {
    // TODO: continue to add more validation as we go
    // things should fail here instead of causing errors down the line
    if common-name == none {
      common-name = formula
    }

    if smiles == "" {
      smiles == none
    } else if formula == "" {
      //TODO: actually calculate the formula based on the smiles code (don't forget to add H on Carbon atoms)
      formula = smiles
    }

    if cas == "" {
      cas = none
    }

    found-elements = get-element-counts(formula)

    if inchi != "" {
      // TODO: create InChI keys from provided InChI:
      // https://typst.app/universe/package/jumble
      // https://www.inchi-trust.org/download/104/InChI_TechMan.pdf
    } else {
      inchi = none
    }
  }

  return metadata((
    kind: "molecule",
    common-name: common-name,
    iupac-name: iupac-name,
    formula: formula,
    smiles: smiles,
    inchi: inchi,
    cas: cas,
    h-p: h-p,
    ghs: ghs,
    elements: found-elements,
  ))
}

#let define-hydrate(
  molecule,
  amount: 1,
  override-common-name: none,
  override-iupac-name: none,
  override-smiles: none,
  override-inchi: none,
  override-cas: none,
  override-h-p: none,
  override-ghs: none,
) = {
  molecule = get-molecule-dict(molecule)
  define-molecule(
    common-name: if override-common-name != none { override-common-name } else {
      molecule.common-name + sym.space + hydrates.at(amount)
    },
    iupac-name: if override-iupac-name != none { override-iupac-name } else {
      molecule.iupac-name + sym.semi + hydrates.at(amount)
    },
    formula: molecule.formula + sym.space.narrow + sym.dot + sym.space.narrow + str(amount) + "H2O",
    smiles: if override-smiles != none { override-smiles } else { molecule.smiles },
    inchi: if override-inchi != none { override-inchi } else { molecule.inchi },
    cas: if override-cas != none { override-cas } else { molecule.cas },
    h-p: if override-h-p != none { override-h-p } else { molecule.h-p },
    ghs: if override-ghs != none { override-ghs } else { molecule.ghs },
  )
}