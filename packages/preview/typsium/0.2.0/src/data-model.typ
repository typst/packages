#import "utils.typ": is-sequence, is-kind, is-heading, is-metadata, padright, get-all-children, hydrates, elements, shell-capacities, orbital-capacities, get-element-dict, get-molecule-dict, to-string
#import "regex.typ": patterns

#import "formula-parser.typ": ce

//TODO: properly parse bracket contents
// maybe recursively with a bracket regex, passing in the bracket content and multiplier(?)
//TODO: Properly apply stochiometry
#let get-element-counts(molecule)={
  
  // how the f do you create an empty dictionary?
  let elements = (H:0)
  let remaining = molecule.trim()
  while remaining.len() > 0 {
    let match = remaining.match(regex_patterns.at("element"))
    if match != none {
      remaining = remaining.slice(match.end)
      let element = match.captures.at(0)
      let count = int(if match.captures.at(1, default: "") == "" {1} else{match.captures.at(1)})
      let current = elements.at(element, default: 0)
      elements.insert(element, count)
    }
    else{
      let char-len = remaining.codepoints().at(0).len()
      
      remaining = remaining.slice(char-len)
    }
  }
  //hack because no empty dict
  if elements.H == 0{
    elements.remove("H")
  }
  return elements
}

#let get-weight(molecule)={
  let element = get-element-dict(molecule)
  molecule = get-molecule-dict(molecule)
  if type(element) == dictionary and  element.at("atomic-weight", default: none) != none{
    return element.atomic-weight
  }
  let weight = 0
  for value in molecule.elements {
    let element = elements.find(x=> x.symbol == value.at(0))

    weight += element.atomic-weight * value.at(1)
  }
  return weight
}

#let get-shell-configuration(element)={
  element = get-element-dict(element)
  let charge = element.at("charge", default:0)
  let electron-amount = element.atomic-number - charge

  let result = ()
  for value in shell-capacities {
    if electron-amount <= 0{
      break
    }
      
    if electron-amount >= value.at(1){
      result.push(value)
      electron-amount -= value.at(1)
    } else {
      result.push((value.at(0), electron-amount))
      electron-amount = 0
    }
  }
  return result
}

//TODO: fix Cr and Mo
#let get-electron-configuration(element)={
  element = get-element-dict(element)
  let charge = element.at("charge", default:0)
  let electron-amount = element.atomic-number - charge

  let result = ()
  for value in orbital-capacities {
    if electron-amount <= 0{
      break
    }
    if electron-amount >= value.at(1){
      result.push(value)
      electron-amount -= value.at(1)
    } else {
      result.push((value.at(0), electron-amount))
      electron-amount = 0
    }
  }
  return result
}

#let display-electron-configuration(element, short: false)={
  let configuration = get-electron-configuration(element)

  if short{
  let prefix = ""
    if configuration.at(14, default: (0,0)).at(1) == 6{
      configuration = configuration.slice(15)
      prefix = "[Rn]"
    } else if configuration.at(10, default: (0,0)).at(1) == 6{
      configuration = configuration.slice(11)
      prefix = "[Xe]"
    } else if configuration.at(7, default: (0,0)).at(1) == 6{
      configuration = configuration.slice(8)
      prefix = "[Kr]"
    } else if configuration.at(4, default: (0,0)).at(1) == 6{
      configuration = configuration.slice(5)
      prefix = "[Ar]"
    } else if configuration.at(2, default: (0,0)).at(1) == 6{
      configuration = configuration.slice(3)
      prefix = "[Ne]"
    } else if configuration.at(0, default: (0,0)).at(1) == 2{
      configuration = configuration.slice(1)
      prefix = "[He]"
    }

    return prefix + configuration.map(x=> $#x.at(0)^#str(x.at(1))$).sum()
  } else{
    return configuration.map(x=> $#x.at(0)^#str(x.at(1))$).sum()
  }  
}

#let get-element(
  symbol: auto,
  atomic-number:auto,
  common-name:auto,
  cas:auto,
)={
  let element = if symbol != auto {
    elements.find(x=> x.symbol == symbol)
  } else if atomic-number != auto{
    elements.find(x=> x.atomic-number == atomic-number)
  } else if common-name != auto{
    elements.find(x=> x.common-name == common-name)
  } else if cas != auto{
    elements.find(x=> x.cas == cas)
  }
  return metadata(element)
}

#let define-ion(
  element,
  charge: 0,
  delta: 0,
)={
  if charge != 0{
    return element.charge = charge
  } else {
    element.charge = element.at("charge", default:0) + delta
  }
}

#let define-molecule(
  common-name:none,
  iupac-name:none,
  formula:"",
  smiles:"",
  inchi:"",
  cas:"",
  h-p:(),
  ghs:(),
)={
  // TODO: continue to add more validation as we go
  // things should fail here instead of causing errors down the line
  if common-name == none{
    common-name = formula
  }
  
  if smiles == ""{
    smiles == none
  } else if formula == ""{
    //TODO: actually calculate the formula based on the smiles code (don't forget to add H on Carbon atoms)
    formula = smiles
  }
  
  if cas == ""{
    cas = none
  }
  
  let elements = get-element-counts(formula)

  if inchi != ""{
    // TODO: create inchi keys from provided inchi:
    // https://typst.app/universe/package/jumble
    // https://www.inchi-trust.org/download/104/inchi_TechMan.pdf
  }else{
    inchi = none
  }
  
  return metadata((kind: "molecule",
    common-name: common-name, 
    iupac-name:iupac-name, 
    formula: formula, 
    smiles: smiles, 
    inchi: inchi, 
    cas: cas, 
    h-p: h-p, 
    ghs: ghs, 
    elements: elements
  ))
}

#let define-hydrate(
  molecule,
  amount:1,
  override-common-name:none,
  override-iupac-name:none,
  override-smiles:none,
  override-inchi:none,
  override-cas:none,
  override-h-p:none,
  override-ghs:none,
) = {
  molecule = get-molecule-dict(molecule)
  define-molecule(
    common-name: if override-common-name != none {override-common-name} else {molecule.common-name + sym.space + hydrates.at(amount)},
    iupac-name: if override-iupac-name != none {override-iupac-name}else{molecule.iupac-name + sym.semi + hydrates.at(amount)},
    formula: molecule.formula + sym.space.narrow + sym.dot + sym.space.narrow + str(amount) + "H2O",
    smiles:  if override-smiles != none {override-smiles}else{molecule.smiles},
    inchi:  if override-inchi != none {override-inchi}else{molecule.inchi},
    cas:  if override-cas != none {override-cas}else{molecule.cas},
    h-p:  if override-h-p != none {override-h-p}else{molecule.h-p},
    ghs:  if override-ghs != none {override-ghs}else{molecule.ghs}
  )
}

#let reaction(body)={
  let children = get-all-children(body)

  // repr(body)

  // linebreak()
  let result = ""
  for child in children {
    if is-metadata(child){
      if is-kind(child, "molecule"){
        result += child.value.formula
      }else if is-kind(child, "element"){
        result += child.value.symbol
      }
      
    }else{
      result += child
    }
  }
  ce(to-string(result))
}