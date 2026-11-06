#import "utils.typ": arrow-string-to-kind, is-default, roman-to-number
#import "model/molecule-element.typ": molecule
#import "model/reaction-element.typ": reaction
#import "model/element-element.typ": element
#import "model/group-element.typ": group
#import "model/arrow-element.typ": arrow

#let patterns = (
  element: regex(
    "^(\^\d+)?(_\d+)?"+
    "([A-Z][a-z]?)" +
    "(?:((?:_?\d+)|(?:_\([^()]*(?:\([^()]*\)[^()]*)*\)))|(\^\.?[+-]?\d+[+-]?|\^[+-]?[IV]+[+-]?|\^\.?[+-.]{1}|\.?[+-]{1}\d?))?" +
    "(?:(_?\d+)|(\^\.?[+-]?\d+[+-]?|\^[+-]?[IV]+[+-]?|\^\.?[+-.]{1}|\^\([^)]*\)|\.?[+-]{1}\d?))?" +
    "(\^\^[+-]?(?:[IViv]{1,3}|\d+))?",
  ),
  group: regex(
    "^((?:\([^()]*(?:\([^()]*\)[^()]*)*\))|(?:\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\})|(?:\[[^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*\]))" +
    "(?:(_?\d+)|(\^\.?[+-]?\d+[+-]?|\^\.?[+-.]{1}|[+-]{1}\d?))?" +
    "(?:(_?\d+)|(\^\.?[+-]?\d+[+-]?|\^\.?[+-.]{1}|[+-]{1}\d?))?"
  ),
  reaction-plus: regex("^\s*\+\s*"),
  reaction-arrow: regex(
    "^\s*(<->|↔|<=>|⇔|->|→|<-|←|=>|⇒|<=|⇐|-/?\>|</-)" +
    "(?:\[([^\[\]]*)\])?" +
    "(?:\[([^\[\]]*)\])?" +
    "\s*"
  ),
  math: regex("^\$[^$]*?\$"),
  aggregation: regex("^\((?:s|l|g|aq|cd|cr|fl|lc|vit|a|ads|pol|mon|sln|am)\)"),
  count: regex("^\d+"),
)

#let get-count-and-charge(count1, count2, charge1, charge2) = {
  let radical = false
  let roman-charge = false
  let count = if not is-default(count1) {
    if count1.at(0) == "_" and count1.at(1) == "("{
      count1.slice(2,count1.len()-1)
    } else{
      int(count1.replace("_", ""))
    }
  } else if not is-default(count2) {
    int(count2.replace("_", ""))
  } else {
    none
  }

  let custom-charge = false
  let charge = if not is-default(charge1) {
    charge1.replace("^", "")
  } else if not is-default(charge2) {
    if charge2.at(0) == "^" and charge2.at(1) == "("{
      custom-charge = true
      charge2.slice(2,charge2.len()-1)
    } else{
      charge2.replace("^", "")
    }
  } else {
    none
  }

  if not is-default(charge) and not custom-charge {
    if charge.contains(".") {
      charge = charge.replace(".", "")
      radical = true
    }
    if charge.contains("I") or charge.contains("V") {
      let multiplier = if charge.contains("-") { -1 } else { 1 }
      charge = charge.replace("-", "").replace("+", "")
      charge = roman-to-number(charge) * multiplier
      roman-charge = true
    } else if charge == "-" {
      charge = -1
    } else if charge.contains("-") {
      charge = -int(charge.replace("-", ""))
    } else if charge == "+" {
      charge = 1
    } else if charge.replace("+", "").contains(regex("^[0-9]+$")) {
      charge = int(charge.replace("+", ""))
    } else {
      charge = 0
    }
  }

  return (count, charge, radical, roman-charge)
}

#let string-to-element(formula) = {
  let element-match = formula.match(patterns.element)
  if element-match == none {
    return (false,)
  }
  let x = get-count-and-charge(
    element-match.captures.at(3),
    element-match.captures.at(5),
    element-match.captures.at(4),
    element-match.captures.at(6),
  )
  let oxidation = element-match.captures.at(7)
  let a = element-match.captures.at(0)
  let z = element-match.captures.at(1)
  if a != none{a = a.slice(1, a.len())}
  if z != none{z = z.slice(1, z.len())}
  let oxidation-number = none
  let roman-oxidation = true
  let roman-charge = false
  if oxidation != none {
    oxidation = upper(oxidation)
    oxidation = oxidation.replace("^", "", count: 2)
    let multiplier = if oxidation.contains("-") { -1 } else { 1 }
    oxidation = oxidation.replace("-", "").replace("+", "")
    if oxidation.contains("I") or oxidation.contains("V") {
      oxidation-number = roman-to-number(oxidation)
    } else {
      roman-oxidation = false
      oxidation-number = int(oxidation)
    }
    if oxidation-number != none {
      oxidation-number *= multiplier
    }
  }

  if x.at(0) == none and x.at(1) == none and x.at(2) == false {
    if formula.at(element-match.end, default: "").match(regex("[a-z]")) != none {
      return (false,)
    }
  }

  return (
    true,
    if x.at(3) {
      element(
        element-match.captures.at(2),
        count: x.at(0),
        charge: x.at(1),
        radical: x.at(2),
        oxidation: oxidation-number,
        roman-charge: x.at(3),
        a:a,
        z:z,
      )
    } else {
      element(
        element-match.captures.at(2),
        count: x.at(0),
        charge: x.at(1),
        radical: x.at(2),
        oxidation: oxidation-number,
        a:a,
        z:z,
      )
    },
    element-match.end,
  )
}

#let string-to-math(formula) = {
  let match = formula.match(patterns.math)
  if match == none {
    return (false,)
  }
  return (true, eval(match.text), match.end)
}

#let string-to-reaction(
  reaction-string,
  create-molecules: true,
) = {
  let remaining = reaction-string.trim()
  if remaining.len() == 0 {
    return ()
  }
  let full-reaction = ()
  let current-molecule-children = ()
  let current-molecule-count = 1
  let current-molecule-phase = none
  let random-content = ""

  while remaining.len() > 0 {
    if remaining.at(0) == "&" {
      //flush current molecule
      if current-molecule-children.len() > 0 {
        full-reaction.push(
          molecule(
            current-molecule-children,
            count: current-molecule-count,
            aggregation: current-molecule-phase,
          ),
        )
        current-molecule-children = ()
        current-molecule-phase = none
        current-molecule-count = 1
      }
      //end flush current molecule

      full-reaction.push($&$)
      remaining = remaining.slice(1)
      continue
    }

    let math-result = string-to-math(remaining)
    if math-result.at(0) {
      //flush random content
      if not is-default(random-content) {
        if current-molecule-children.len() == 0 {
          full-reaction.push([#random-content])
        } else {
          current-molecule-children.push([#random-content])
        }
      }
      random-content = ""
      //end flush random content

      full-reaction.push(math-result.at(1))
      remaining = remaining.slice(math-result.at(2))
      continue
    }

    let element = string-to-element(remaining)
    if element.at(0) {
      //flush random content
      if not is-default(random-content) {
        if current-molecule-children.len() == 0 {
          full-reaction.push([#random-content])
        } else {
          current-molecule-children.push([#random-content])
        }
      }
      random-content = ""
      //end flush random content

      current-molecule-children.push(element.at(1))
      remaining = remaining.slice(element.at(2))
      continue
    }

    let aggregation-match = remaining.match(patterns.aggregation)
    if aggregation-match != none{
      //flush random content
      if not is-default(random-content) {
        if current-molecule-children.len() == 0 {
          full-reaction.push([#random-content])
        } else {
          current-molecule-children.push([#random-content])
        }
      }
      random-content = ""
      //end flush random content

      current-molecule-phase = aggregation-match.text
      remaining = remaining.slice(aggregation-match.end)
      continue
    }

    let group-match = remaining.match(patterns.group)
    if group-match != none {
      //flush random content
      if not is-default(random-content) {
        if current-molecule-children.len() == 0 {
          full-reaction.push([#random-content])
        } else {
          current-molecule-children.push([#random-content])
        }
      }
      random-content = ""
      //end flush random content

      let group-content = group-match.captures.at(0)
      let kind = if group-content.at(0) == "(" {
        group-content = group-content.trim(regex("[()]"), repeat: false)
        0
      } else if group-content.at(0) == "[" {
        group-content = group-content.trim(regex("[\[\]]"), repeat: false)
        1
      } else if group-content.at(0) == "{" {
        group-content = group-content.trim(regex("[{}]"), repeat: false)
        2
      }
      let x = get-count-and-charge(
        group-match.captures.at(1),
        group-match.captures.at(3),
        group-match.captures.at(2),
        group-match.captures.at(4),
      )
      let group-children = string-to-reaction(group-content, create-molecules: false)

      current-molecule-children.push(group(group-children, kind: kind, count: x.at(0), charge: x.at(1)))
      remaining = remaining.slice(group-match.end)
      continue
    }

    let count-match = remaining.match(patterns.count)
    if count-match != none{
      //flush random content
      if not is-default(random-content) {
        if current-molecule-children.len() == 0 {
          full-reaction.push([#random-content])
        } else {
          current-molecule-children.push([#random-content])
        }
      }
      random-content = ""
      //end flush random content

      current-molecule-count = count-match.text
      remaining = remaining.slice(count-match.end)
      continue
    }

    let plus-match = remaining.match(patterns.reaction-plus)
    if plus-match != none {
      //flush current molecule
      if current-molecule-children.len() > 0 {
        full-reaction.push(
          molecule(
            current-molecule-children,
            count: current-molecule-count,
            aggregation: current-molecule-phase,
          ),
        )
        current-molecule-children = ()
        current-molecule-phase = none
        current-molecule-count = 1
      }
      //end flush current molecule
      
      //flush random content
      if not is-default(random-content) {
        if current-molecule-children.len() == 0 {
          full-reaction.push([#random-content])
        } else {
          current-molecule-children.push([#random-content])
        }
      }
      random-content = ""
      //end flush random content
      full-reaction.push([+])
      remaining = remaining.slice(plus-match.end)
      continue
    }

    let arrow-match = remaining.match(patterns.reaction-arrow)
    if arrow-match != none {
      //flush current molecule
      if current-molecule-children.len() > 0 {
        full-reaction.push(
          molecule(
            current-molecule-children,
            count: current-molecule-count,
            aggregation: current-molecule-phase,
          ),
        )
        current-molecule-children = ()
        current-molecule-phase = none
        current-molecule-count = 1
      }
      //end flush current molecule
      
      //flush random content
      if not is-default(random-content) {
        if current-molecule-children.len() == 0 {
          full-reaction.push([#random-content])
        } else {
          current-molecule-children.push([#random-content])
        }
      }
      random-content = ""
      //end flush random content

      let kind = arrow-string-to-kind(arrow-match.captures.at(0))
      let top = ()
      let bottom = ()
      if arrow-match.captures.at(1) != none {
        top = string-to-reaction(arrow-match.captures.at(1))
      }
      if arrow-match.captures.at(2) != none {
        bottom = string-to-reaction(arrow-match.captures.at(2))
      }
      full-reaction.push(arrow(kind: kind, top: top, bottom: bottom))
      remaining = remaining.slice(arrow-match.end)
      continue
    }

    //TODO: revisit if this is not giving good results
    if remaining.codepoints().at(0) == " "{
      //flush current molecule
      if current-molecule-children.len() > 0 {
        full-reaction.push(
          molecule(
            current-molecule-children,
            count: current-molecule-count,
            aggregation: current-molecule-phase,
          ),
        )
        current-molecule-children = ()
        current-molecule-phase = none
        current-molecule-count = 1
      }
      //end flush current molecule
    }

    random-content += remaining.codepoints().at(0)
    remaining = remaining.slice(remaining.codepoints().at(0).len())  
    }

  //flush current molecule
  if current-molecule-children.len() > 0 {
    full-reaction.push(
      molecule(
        current-molecule-children,
        count: current-molecule-count,
        aggregation: current-molecule-phase,
      ),
    )
    current-molecule-children = ()
    current-molecule-phase = none
    current-molecule-count = 1
  }
  //end flush current molecule
  
  //flush random content
  if not is-default(random-content) {
    if current-molecule-children.len() == 0 {
      full-reaction.push([#random-content])
    } else {
      current-molecule-children.push([#random-content])
    }
  }
  random-content = ""
  //end flush random content


  return full-reaction
}
