#let ergo-title-selector = <__ergo_title>
#let ergo-title(content) = {
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

#let problem-counter = counter("problem")

#let highlight-raw(content, raw-color) = {
  box(
    fill:   raw-color,
    outset: (x: 1pt, y: 3pt),
    inset:  (x: 2pt),
    radius: 2pt,
    content
  )
}

#let get-proofname-content(kind, name, problem: false, prob-nums: true) = {
  let xpad = 12pt
  let ypad = 6pt
  let name-content = none

  if problem {
    let count = if prob-nums [ #{problem-counter.step(); context problem-counter.display()}] else []

    if name == [] {
      name-content = ergo-title[#kind#count]
    } else {
      name-content = ergo-title[#kind#count: #name]
    }
  } else {
    if name == [] {
      name-content =  ergo-title[_#kind _]
    } else {
      name-content = ergo-title[_#kind: _ #name]
    }
  }

  return pad(x: xpad, y: ypad, name-content)
}

#let get-statementname-content(kind, name) = {
  let xpad = 12pt
  let ypad = 6pt
  let name-content = none

  if name == [] {
    name-content =  ergo-title[#kind]
  } else {
    name-content = ergo-title[#kind: #name]
  }

  return pad(x: xpad, y: ypad, name-content)
}

#let get-proof-content(statement, problem, inline-qed) = {
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

#let get-statement-content(statement) = {
  let xpad = 12pt
  let ypad = 6pt

  if statement == [] {
    return none
  } else {
    return pad(x: xpad, y: ypad, statement)
  }
}
