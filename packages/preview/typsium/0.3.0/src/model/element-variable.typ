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
  "element-variable",
  prefix: "@preview/typsium:0.3.0",
  fields: (
    e.field("symbol", str, doc: "The symbol in the periodic table. For example: H, He, Li,..."),
    e.field("common-name", str, doc: "The name of the element."),
    e.field("atomic-number", int, doc: "Atomic number (Z) of the element / number of protons."),
    e.field("most-common-isotope",int,doc: "Mass number (A) of the most common isotope / number of protons + neutrons."),
    e.field("group", int, doc: "The column of the element inside the periodic table. ranges 1-18."),
    e.field("period", int, doc: "The period of the element inside the periodic table."),
    e.field("block", int, doc: "Is the element s-block, f-block, d-block or p-block?"),
    e.field("atomic-weight", int, doc: "The average of the weights of all isotopes of the element."),
    e.field("covalent-radius", int, doc: "Covalent radius of the element."),
    e.field("van-der-waal-radius", int, doc: "Van der Waals radius of the element."),
    e.field("outshell-electrons", int, doc: "The number of electrons in the outermost shell."),
    e.field("density", int, doc: "The density of the pure element in kg/m^3"),
    e.field("melting-point", int, doc: "The melting point of the element under standard conditions."),
    e.field("boiling-point", int, doc: "The boiling point of the element under standard conditions."),
    e.field("electronegativity", int, doc: "The Electronegativify of the element."),
    e.field("phase", int, doc: "The boiling point of the element under standard conditions."),
    e.field("cas", int, doc: "The CAS number of the pure element"),
  ),
)


#let get-element(
  symbol: auto,
  atomic-number: auto,
  common-name: auto,
  cas: auto,
) = {
  let element = if symbol != auto {
    elements.find(x => x.symbol == symbol)
  } else if atomic-number != auto {
    elements.find(x => x.atomic-number == atomic-number)
  } else if common-name != auto {
    elements.find(x => x.common-name == common-name)
  } else if cas != auto {
    elements.find(x => x.cas == cas)
  }
  return metadata(element)
}

#let validate-element(element) = {
  let type = type(element)
  if type == str {
    if element.len() > 2 {
      return get-element(common-name: element)
    } else {
      return get-element(symbol: element)
    }
  } else if type == int {
    return get-element(atomic-number: element)
  } else if type == content {
    return get-element-dict(element)
  } else if type == dictionary {
    return element
  }
}

//TODO: properly parse bracket contents
// maybe recursively with a bracket regex, passing in the bracket content and multiplier(?)
//TODO: Properly apply stochiometry
#let get-element-counts(molecule) = {
  let found-elements = (:)
  let remaining = molecule.trim()
  while remaining.len() > 0 {
    let match = remaining.match(patterns.element)
    if match != none {
      remaining = remaining.slice(match.end)
      let element = match.captures.at(0)
      let count = 1 //int(if match.captures.at(1, default: "") == "" {1} else{match.captures.at(1)})
      let current = found-elements.at(element, default: 0)
      found-elements.insert(element, count)
    } else {
      let char-len = remaining.codepoints().at(0).len()

      remaining = remaining.slice(char-len)
    }
  }
  return found-elements
}

#let define-ion(
  element,
  charge: 0,
  delta: 0,
  override-common-name: none,
  override-iupac-name: none,
  override-CAS: none,
  override-h-p: none,
  override-ghs: none,
  validate: true,
) = {
  if validate {
    element = validate-element(element)
  }
  element = if charge != 0 {
    element.charge = charge
  } else {
    element.charge = element.at("charge", default: 0) + delta
  }
  return element
}

#let define-isotope(
  element,
  mass-number,
  override-atomic-weight: none,
  override-common-name: none,
  override-iupac-name: none,
  override-cas: none,
  override-h-p: none,
  override-ghs: none,
  validate: true,
) = {
  if validate {
    element = validate-element(element)
  }

  element.mass-number = mass-number
  if override-atomic-weight != none {
    element.atomic-weight = override-atomic-weight
  }
  if override-common-name != none {
    element.common-name = override-common-name
  }
  if override-iupac-name != none {
    element.iupac-name = override-iupac-name
  }
  if override-cas != none {
    element.override-cas = override-cas
  }
  if override-common-name != none {
    element.common-name = override-common-name
  }
  if override-common-name != none {
    element.common-name = override-common-name
  }
  if override-common-name != none {
    element.common-name = override-common-name
  }
  return element
}

#let get-shell-configuration(element) = {
  element = get-element-dict(element)
  let charge = element.at("charge", default: 0)
  let electron-amount = element.atomic-number - charge

  let result = ()
  for value in shell-capacities {
    if electron-amount <= 0 {
      break
    }

    if electron-amount >= value.at(1) {
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
#let get-electron-configuration(element) = {
  element = get-element-dict(element)
  let charge = element.at("charge", default: 0)
  let electron-amount = element.atomic-number - charge

  let result = ()
  for value in orbital-capacities {
    if electron-amount <= 0 {
      break
    }
    if electron-amount >= value.at(1) {
      result.push(value)
      electron-amount -= value.at(1)
    } else {
      result.push((value.at(0), electron-amount))
      electron-amount = 0
    }
  }
  return result
}

#let display-electron-configuration(element, short: false) = {
  let configuration = get-electron-configuration(element)
  if short {
    let prefix = ""
    if configuration.at(14, default: (0, 0)).at(1) == 6 {
      configuration = configuration.slice(15)
      prefix = "[Rn]"
    } else if configuration.at(10, default: (0, 0)).at(1) == 6 {
      configuration = configuration.slice(11)
      prefix = "[Xe]"
    } else if configuration.at(7, default: (0, 0)).at(1) == 6 {
      configuration = configuration.slice(8)
      prefix = "[Kr]"
    } else if configuration.at(4, default: (0, 0)).at(1) == 6 {
      configuration = configuration.slice(5)
      prefix = "[Ar]"
    } else if configuration.at(2, default: (0, 0)).at(1) == 6 {
      configuration = configuration.slice(3)
      prefix = "[Ne]"
    } else if configuration.at(0, default: (0, 0)).at(1) == 2 {
      configuration = configuration.slice(1)
      prefix = "[He]"
    }

    return prefix + configuration.map(x => $#x.at(0)^#str(x.at(1))$).sum()
  } else {
    return configuration.map(x => $#x.at(0)^#str(x.at(1))$).sum()
  }
}