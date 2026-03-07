#import "utils.typ": (
  arrow-string-to-kind, get-all-children, is-default, is-kind, is-metadata, length, reconstruct-content-from-strings,
  reconstruct-nested-content, roman-to-number, typst-builtin-context, typst-builtin-styled,
)
#import "parse-formula-intermediate-representation.typ": patterns
#import "@preview/elembic:1.1.1" as e

#import "model/molecule-element.typ": molecule
#import "model/reaction-element.typ": reaction
#import "model/element-element.typ": element
#import "model/group-element.typ": group
#import "model/arrow-element.typ": arrow

#let get-count-and-charge(count1, count2, charge1, charge2, full-string, templates, index) = {
  let radical = false
  let roman-charge = false
  let count = if not is-default(count1) {
    reconstruct-content-from-strings(
      full-string,
      templates,
      start: index + if count1.contains("_") { 1 },
      end: index + length(count1),
    )
    // templates.slice()
  } else if not is-default(count2) {
    reconstruct-content-from-strings(
      full-string,
      templates,
      start: index + length(charge1) + if count2.contains("_") { 1 },
      end: index + length(charge1) + length(count2),
    )
  } else {
    none
  }

  let charge = if not is-default(charge1) {
    if charge1.contains("I") or charge1.contains("V") {
      roman-charge = true
    }
    reconstruct-content-from-strings(
      full-string,
      templates,
      start: index + if charge1.contains("^") { 1 },
      end: index + length(charge1),
    )
  } else if not is-default(charge2) {
    if charge2.contains("I") or charge2.contains("V") {
      roman-charge = true
    }
    reconstruct-content-from-strings(
      full-string,
      templates,
      start: index + length(count1) + if charge2.contains("^") { 1 },
      end: index + length(count1) + length(charge2),
    )
  } else {
    none
  }
  return (count, charge, radical, roman-charge)
}

#let string-to-element(formula, full-string, templates, index) = {
  let element-match = formula.match(patterns.element)
  if element-match == none {
    return (false,)
  }
  let symbol = element-match.captures.at(2)
  let oxidation = element-match.captures.at(7)
  let a = element-match.captures.at(0)
  let z = element-match.captures.at(1)
  if a != none {
    let len = element-match.captures.at(0).len()
    a = reconstruct-content-from-strings(
      full-string,
      templates,
      start: index + 1,
      end: index + len,
    )
    index += len
  }
  if z != none {
    let len = element-match.captures.at(1).len()
    z = reconstruct-content-from-strings(
      full-string,
      templates,
      start: index + 1,
      end: index + len,
    )
    index += len
  }
  // if z != none{z = z.slice(1, z.len())}
  let x = get-count-and-charge(
    element-match.captures.at(3),
    element-match.captures.at(5),
    element-match.captures.at(4),
    element-match.captures.at(6),
    full-string,
    templates,
    index + symbol.len(),
  )
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
    element(
      reconstruct-content-from-strings(
        full-string,
        templates,
        start: index,
        end: index + element-match.captures.at(2).len(),
      ),
      count: x.at(0),
      charge: x.at(1),
      radical: x.at(2),
      oxidation: oxidation-number,
      roman-oxidation: roman-oxidation,
      roman-charge: x.at(3),
      a: a,
      z: z,
    ),
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
  templates,
  create-molecules: true,
) = {
  let remaining = reaction-string
  if remaining.len() == 0 {
    return ()
  }
  let full-reaction = ()
  let current-molecule-children = ()
  let current-molecule-count = 1
  let current-molecule-phase = none
  let random-content = 0

  let index = 0
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
      index += 1
      continue
    }

    let math-result = string-to-math(remaining)
    if math-result.at(0) {
      //flush random content
      if random-content != 0 {
        if current-molecule-children.len() == 0 {
          full-reaction.push(
            reconstruct-content-from-strings(
              reaction-string,
              templates,
              start: index - random-content,
              end: index,
            ),
          )
        } else {
          current-molecule-children.push(
            reconstruct-content-from-strings(
              reaction-string,
              templates,
              start: index - random-content,
              end: index,
            ),
          )
        }
        random-content = 0
      }
      //end flush random content

      full-reaction.push(math-result.at(1))
      remaining = remaining.slice(math-result.at(2))
      index += math-result.at(2)
      continue
    }

    let element = string-to-element(remaining, reaction-string, templates, index)
    if element.at(0) {
      //flush random content
      if random-content != 0 {
        if current-molecule-children.len() == 0 {
          full-reaction.push(
            reconstruct-content-from-strings(
              reaction-string,
              templates,
              start: index - random-content,
              end: index,
            ),
          )
        } else {
          current-molecule-children.push(
            reconstruct-content-from-strings(
              reaction-string,
              templates,
              start: index - random-content,
              end: index,
            ),
          )
        }
        random-content = 0
      }
      //end flush random content
      current-molecule-children.push(element.at(1))
      remaining = remaining.slice(element.at(2))
      index += element.at(2)
      continue
    }

    let aggregation-match = remaining.match(patterns.aggregation)
    if aggregation-match != none {
      //flush random content
      if random-content != 0 {
        if current-molecule-children.len() == 0 {
          full-reaction.push(
            reconstruct-content-from-strings(
              reaction-string,
              templates,
              start: index - random-content,
              end: index,
            ),
          )
        } else {
          current-molecule-children.push(
            reconstruct-content-from-strings(
              reaction-string,
              templates,
              start: index - random-content,
              end: index,
            ),
          )
        }
        random-content = 0
      }
      //end flush random content


      current-molecule-phase = reconstruct-content-from-strings(
        reaction-string,
        templates,
        start: index,
        end: index + aggregation-match.end,
      )
      remaining = remaining.slice(aggregation-match.end)
      index += aggregation-match.end
      continue
    }

    let group-match = remaining.match(patterns.group)
    if group-match != none {
      //flush random content
      if random-content != 0 {
        if current-molecule-children.len() == 0 {
          full-reaction.push(
            reconstruct-content-from-strings(
              reaction-string,
              templates,
              start: index - random-content,
              end: index,
            ),
          )
        } else {
          current-molecule-children.push(
            reconstruct-content-from-strings(
              reaction-string,
              templates,
              start: index - random-content,
              end: index,
            ),
          )
        }
        random-content = 0
      }
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
      index += group-match.end
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
      if random-content != 0 {
        full-reaction.push(
          reconstruct-content-from-strings(
            reaction-string,
            templates,
            start: index - random-content,
            end: index,
          ),
        )
        random-content = 0
      }
      //end flush random content

      full-reaction.push([+])
      remaining = remaining.slice(plus-match.end)
      index += plus-match.end
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
      if random-content != 0 {
        full-reaction.push(
          reconstruct-content-from-strings(
            reaction-string,
            templates,
            start: index - random-content,
            end: index,
          ),
        )
        random-content = 0
      }
      //end flush random content

      let kind = arrow-string-to-kind(arrow-match.captures.at(0))
      let top = ()
      let bottom = ()
      if arrow-match.captures.at(1) != none {
        top = string-to-reaction(
          arrow-match.captures.at(1),
          templates.slice(
            index + arrow-match.captures.at(0).len() + 2,
            count: arrow-match.captures.at(1).len() + 2,
          ),
        )
      }
      if arrow-match.captures.at(2) != none {
        bottom = string-to-reaction(
          arrow-match.captures.at(2),
          templates.slice(
            index + arrow-match.captures.at(0).len() + length(arrow-match.captures.at(1)) + 2 + 2,
            count: arrow-match.captures.at(2).len() + 2,
          ),
        )
      }
      full-reaction.push(arrow(kind: kind, top: top, bottom: bottom))
      remaining = remaining.slice(arrow-match.end)
      index += arrow-match.end
      continue
    }

    let current-character = remaining.codepoints().at(0)
    if (current-character == "#" and templates.at(index).len() != 0) {
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
      if random-content != 0 {
        full-reaction.push(
          reconstruct-content-from-strings(
            reaction-string,
            templates,
            start: index - random-content,
            end: index,
          ),
        )
        random-content = 0
      }
      //end flush random content

      full-reaction.push(reconstruct-nested-content(templates.at(index).slice(1), templates.at(index).at(0)))
      remaining = remaining.slice(1)
      index += 1
      continue
    }

    //TODO: revisit if this is giving good results
    if remaining.codepoints().at(0) == " " {
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

    random-content += current-character.len()
    remaining = remaining.slice(current-character.len())
    index += current-character.len()
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
  }
  //end flush current molecule

  //flush random content
  if random-content != 0 {
    full-reaction.push(
      reconstruct-content-from-strings(
        reaction-string,
        templates,
        start: reaction-string.len() - random-content,
        end: reaction-string.len(),
      ),
    )
  }

  return full-reaction
}

#let create-full-string(children) = {
  let full-string = ""
  let templates = ()
  for child in children {
    if is-metadata(child) {
      let elembic-data = e.data(child.value)
      if elembic-data.id.name == "element-variable" {
        let combined = child.value.symbol
        if child.value.charge != 0 {
          combined += "^" + str(child.value.charge)
        }
        full-string += combined
        for value in combined {
          templates.push(())
        }
      } else if elembic-data.id.name == "molecule-variable" {
        let combined = child.value.formula
        for value in combined {
          templates.push(())
        }
      }
    } else if type(child) == content {
      let func-type = child.func()
      if child == [ ] {
        full-string += " "
        templates.push(())
      } else if func-type == raw {
        let x = eval(child.text)
        full-string += "#"
        templates.push(())
      } else if func-type == text {
        full-string += child.text
        for value in child.text {
          templates.push(())
        }
      } else if func-type == typst-builtin-styled {
        let (inner-full-strings, inner-templates) = create-full-string(get-all-children(child.child))
        for value in range(inner-templates.len()) {
          inner-templates.at(value).push(child)
        }
        full-string += inner-full-strings
        templates += inner-templates
      } else if (
        func-type
          in (
            math.overbrace,
            math.underbrace,
            math.underbracket,
            math.overbracket,
            math.underparen,
            math.overparen,
            math.undershell,
            math.overshell,
            pad,
            strong,
            highlight,
            overline,
            underline,
            strike,
            math.cancel,
            //TODO: implement missing methods in utils:
            figure,
            quote,
            emph,
            smallcaps,
            sub,
            super,
            box,
            block,
            hide,
            move,
            scale,
            circle,
            ellipse,
            rect,
            square,
          )
      ) {
        let (inner-full-strings, inner-templates) = create-full-string(get-all-children(child.body))
        for value in range(inner-templates.len()) {
          inner-templates.at(value).push(child)
        }
        full-string += inner-full-strings
        templates += inner-templates
      } else {
        full-string += "#"
        templates.push((child,))
        continue
      }
    }
  }
  return (full-string, templates)
}

#let content-to-reaction(body) = {
  if type(body) != content {
    return ()
  }
  let children = get-all-children(body)
  let (full-string, templates) = create-full-string(children)

  return string-to-reaction(full-string, templates)
}
