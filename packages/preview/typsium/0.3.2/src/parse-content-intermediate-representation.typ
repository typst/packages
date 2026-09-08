#import "model/molecule-element.typ": molecule
#import "model/bond-element.typ": bond
#import "model/reaction-element.typ": reaction
#import "model/element-element.typ": element
#import "model/group-element.typ": group
#import "model/arrow-element.typ": reaction-arrow
#import "utils.typ": (
  arrow-string-to-kind, get-all-children, is-default, is-kind, is-metadata, length, reconstruct-content-from-strings,
  reconstruct-nested-content, roman-to-number, typst-builtin-context, typst-builtin-styled,typst-builtin-symbol,
)
#import "parse-formula-intermediate-representation.typ": patterns

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

  //TODO custom charges (refer to)
  // let custom-charge = false
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

  // how agressively should we convert things to elements? always when possible or only when needed?
  if x.at(0) == none and x.at(1) == none and x.at(2) == false  and oxidation-number == none and a == none and z == none{
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

#let string-to-bond(remaining, full-string, templates, index) = {
  let bond-match = remaining.match(patterns.bond-content)
  if bond-match == none {
    return (false,)
  }
  bond-match.text = bond-match.text.replace("\u{00A0}", "~")
  let n = if bond-match.text.contains("="){
    2
  } else if bond-match.text.contains("~"){
    3
  } else{
    1
  }
  let kind = bond-match.text.position("..")
  if kind == none{kind = 0} else {kind += 1}
  return (true, bond(n:n, kind:kind), bond-match.end)
}

#let string-to-particle(formula, count) = {
  return if formula.starts-with("proton"){
    (
      true,
      particle(
         "p",
        charge: 1,
        count:count,
      ),
      6
    )
  }else if formula.starts-with("antiproton"){
    (
      true,
      particle(
         "ap",
        charge: 0,
        count:count,
      ),
      10
    )
  } else if formula.starts-with("neutrino"){
    (
      true,
      particle(
         "ne",
        charge: 0,
        count:count,
      ),
      8
    )
  } else if formula.starts-with("antineutrino"){
    (
      true,
      particle(
         "ane",
        charge: 0,
        count:count,
      ),
      12
    )
  } else if formula.starts-with("neutron"){
    (
      true,
      particle(
         "n",
        charge: 0,
        count:count,
      ),
      7
    )
  } else if formula.starts-with("antineutron"){
    (
      true,
      particle(
         "an",
        charge: 0,
        count:count,
      ),
      11
    )
  } else if formula.starts-with("electron"){
    (
      true,
      particle(
         "e",
        charge: -1,
        count:count,
      ),
      8
    )
  }else if formula.starts-with("positron"){
    (
      true,
      particle(
         "e",
        charge: 1,
        count:count,
      ),
      8
    )
  } else if formula.starts-with("muon"){
    let charge = if formula.len() >4 {if formula.at(4) == "-"{-1} }
    (
      true,
      particle(
        "m",
        charge: charge,
        count:count,
      ),
      4 + calc.abs(charge)
    )
  } else if formula.starts-with("mu"){
    let charge = if formula.len() >2 {if formula.at(2) == "-"{-1} }
    (
      true,
      particle(
         "m",
        charge: charge,
        count:count,
      ),
      2 + calc.abs(charge)
    )
  } else if formula.starts-with("photon"){
    (
      true,
      particle(
         "g",
        charge: 0,
        count:count,
      ),
      6
    )
  } else if formula.starts-with("gamma"){
    (
      true,
      particle(
         "g",
        charge: 0,
        count:count,
      ),
      5
    )
  } else if formula.starts-with("beta"){
    let charge = if formula.len() >4 {if formula.at(4) == "-"{-1} else if formula.at(4) == "+"{1} else{0}} else {0}
    (
      true,
      particle(
         "b",
        charge: charge,
        count:count,
      ),
      4 + calc.abs(charge)
    )
  } else if formula.starts-with("alpha"){
    (
      true,
      particle(
         "a",
        charge: 0,
        count:count,
      ),
      5
    )
  } else {
    (false, none, 0)
  }
}

// #let string-to-math(formula) = {
//   let match = formula.match(patterns.math)
//   if match == none {
//     return (false,)
//   }
//   return (true, eval(match.text), match.end)
// }

#let string-to-reaction(
  reaction-string,
  templates,
  create-molecules: true,
) = {
  let remaining = reaction-string//.replace("\u{00A0}\u{00A0}", "~~")
  if remaining.len() == 0 {
    return ()
  }
  let full-reaction = ()
  let current-molecule-children = ()
  let current-molecule-count = none
  let current-molecule-count-len = 0
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
        current-molecule-count = none
      }
      //end flush current molecule

      full-reaction.push($&$)
      remaining = remaining.slice(1)
      index += 1
      continue
    }

    let bond-match = string-to-bond(remaining, reaction-string, templates, index)
    if bond-match.at(0){
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
      
      current-molecule-children.push(bond-match.at(1))
      remaining = remaining.slice(bond-match.at(2))
      index += bond-match.at(2)
    }

    // let math-result = string-to-math(remaining)
    // if math-result.at(0) {
    //   //flush random content
    //   if current-molecule-count != none{
    //     random-content += current-molecule-count-len
    //     current-molecule-count = none
    //     current-molecule-count-len = 0
    //   }
    //   if random-content != 0 {
    //     if current-molecule-children.len() == 0 {
    //       full-reaction.push(
    //         reconstruct-content-from-strings(
    //           reaction-string,
    //           templates,
    //           start: index - random-content,
    //           end: index,
    //         ),
    //       )
    //     } else {
    //       current-molecule-children.push(
    //         reconstruct-content-from-strings(
    //           reaction-string,
    //           templates,
    //           start: index - random-content,
    //           end: index,
    //         ),
    //       )
    //     }
    //     random-content = 0
    //   }
    //   //end flush random content

    //   full-reaction.push(math-result.at(1))
    //   remaining = remaining.slice(math-result.at(2))
    //   index += math-result.at(2)
    //   continue
    // }

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
      if current-molecule-count != none{
        random-content += current-molecule-count-len
        current-molecule-count = none
        current-molecule-count-len = 0
      }
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
        current-molecule-count = none
      }
      //end flush current molecule

      continue
    }

    let group-match = remaining.match(patterns.group)
    if group-match != none {
      //flush random content
      // if current-molecule-count != none{
      //   random-content += current-molecule-count-len
      //   current-molecule-count = none
      //   current-molecule-count-len = 0
      // }
      // if random-content != 0 {
      //   if current-molecule-children.len() == 0 {
      //     full-reaction.push(
      //       reconstruct-content-from-strings(
      //         reaction-string,
      //         templates,
      //         start: index - random-content,
      //         end: index,
      //       ),
      //     )
      //   } else {
      //     current-molecule-children.push(
      //       reconstruct-content-from-strings(
      //         reaction-string,
      //         templates,
      //         start: index - random-content,
      //         end: index,
      //       ),
      //     )
      //   }
      //   random-content = 0
      // }
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
        reaction-string,
        templates,
        index + group-match.captures.at(0).len(),
      )
      // Parse inside-group content with the *same* template mapping.
      // `string-to-reaction` in this file requires both `reaction-string` and `templates`.
      // `group-content` is `reaction-string[index..index+group_match.end]` stripped of the outer brackets,
      // so we slice templates accordingly.
      let inner-group-start = index + 1
      let inner-group-end = index + group-match.end - 1
      let group-children = string-to-reaction(
        group-content,
        templates.slice(inner-group-start, inner-group-end),
        create-molecules: false,
      )

      current-molecule-children.push(group(group-children, kind: kind, count: x.at(0), charge: x.at(1)))
      remaining = remaining.slice(group-match.end)
      index += group-match.end
      continue
    }

    let count-match = remaining.match(patterns.count)
    if count-match != none{
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

      current-molecule-count =  reconstruct-content-from-strings(
        reaction-string,
        templates,
        start: index,
        end: index + count-match.end,
      )
      current-molecule-count-len = count-match.end
      remaining = remaining.slice(count-match.end)
      index += count-match.end
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
        current-molecule-count = none
      }
      //end flush current molecule

      //flush random content
      if current-molecule-count != none{
        random-content += current-molecule-count-len
        current-molecule-count = none
        current-molecule-count-len = 0
      }
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
        current-molecule-count = none
      }
      //end flush current molecule

      //flush random content
      if current-molecule-count != none{
        random-content += current-molecule-count-len
        current-molecule-count = none
        current-molecule-count-len = 0
      }
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
      let top = none
      let bottom = none
      if arrow-match.captures.at(1) != none {
        top = string-to-reaction(
          arrow-match.captures.at(1),
          templates.slice(
            index + arrow-match.captures.at(0).len() + 2,
            count: arrow-match.captures.at(1).len() + 2,
          ),
        )
        top = if top.len() == 1{
          top.at(0)
        } else {
          reaction(top)
        }
      }
      if arrow-match.captures.at(2) != none {
        bottom = string-to-reaction(
          arrow-match.captures.at(2),
          templates.slice(
            index + arrow-match.captures.at(0).len() + length(arrow-match.captures.at(1)) + 2 + 2,
            count: arrow-match.captures.at(2).len() + 2,
          ),
        )
        bottom = if bottom.len() == 1{
          bottom.at(0)
        } else {
          reaction(bottom)
        }
      }
      full-reaction.push(reaction-arrow(kind: kind, top: top, bottom: bottom))
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
        current-molecule-count = none
      }
      //end flush current molecule

      //flush random content
      if current-molecule-count != none{
        random-content += current-molecule-count-len
        current-molecule-count = none
        current-molecule-count-len = 0
      }
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
        current-molecule-count = none
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
    current-molecule-count = none
  }
  //end flush current molecule

  //flush random content
  if current-molecule-count != none{
    random-content += current-molecule-count-len
    current-molecule-count = none
    current-molecule-count-len = 0
  }
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
    // let x = type(child)
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
      } else if func-type == text or func-type == typst-builtin-symbol{
        full-string += child.text
        for value in child.text {
          for _ in range(value.len()) {
            templates.push(())
          }
        }
      } else if func-type == typst-builtin-styled {
        let (inner-full-strings, inner-templates) = create-full-string(get-all-children(child.child))
        for value in range(inner-templates.len()) {
          inner-templates.at(value).push(child)
        }
        full-string += inner-full-strings
        templates += inner-templates
      }else if (
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
