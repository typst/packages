#let ergo-title-selector = <__ergo_title>
#let ergo_title(content) = {
  set text(weight: "bold")
  [#content#ergo-title-selector]
}

#let proof(body, inline-qed) = {
  if inline-qed {
    [*Proof:* ]; body; [$square.big$]
  } else {
    [*Proof:* ]; body; [#v(0.2em) #h(90%) $square.big$]
  }
}
#let solution(body) = {
  [*Solution:* ]; body
}

#let problem_counter = counter("problem")

#let highlight_raw(content, raw_color) = {
  box(
    fill:   raw_color,
    outset: (x: 1pt, y: 3pt),
    inset:  (x: 2pt),
    radius: 2pt,
    content
  )
}

#let get_proofname_content(kind, name, problem: false) = {
  let xpad = 12pt
  let ypad = 6pt
  let name_content = none

  if problem {
    let count = [#{problem_counter.step(); context problem_counter.display()}]

    if name == [] {
      name_content = ergo_title[#kind #count]
    } else {
      name_content = ergo_title[#kind #count: #name]
    }
  } else {
    if name == [] {
      name_content =  ergo_title[_#kind _]
    } else {
      name_content = ergo_title[_#kind: _ #name]
    }
  }

  return pad(x: xpad, y: ypad, name_content)
}

#let get_statementname_content(kind, name) = {
  let xpad = 12pt
  let ypad = 6pt
  let name_content = none

  if name == [] {
    name_content =  ergo_title[#kind]
  } else {
    name_content = ergo_title[#kind: #name]
  }

  return pad(x: xpad, y: ypad, name_content)
}

#let get_proof_content(statement, problem, inline-qed) = {
  let xpad = 12pt
  let ypad = 6pt

  if statement == [] {
    return none
  } else {
    if problem {
      return pad(x: xpad, y: ypad, solution(statement))
    } else {
      return pad(x: xpad, y: ypad, proof(statement, inline-qed))
    }
  }
}

#let get_statement_content(statement) = {
  let xpad = 12pt
  let ypad = 6pt

  if statement == [] {
    return none
  } else {
    return pad(x: xpad, y: ypad, statement)
  }
}
