#let correction(body) = {
  text(fill: rgb("#ea4120"), weight: "semibold", body)
}

#let proof(body, inline-qed: false, color: none, title-style: "colon") = {
  let content = if title-style == "colon" {
    if (color == none) {
      strong[Proof: ]
    } else {
      text(fill: color, weight: "bold")[Proof: ]
    }
  } else if title-style == "parens" {
    emph[Proof. ]
  } else {
    panic("Unrecognized title style")
  }

  if inline-qed {
    content; body; [$square.big$]
  } else {
    content; body; [#v(0.2em) #h(90%) $square.big$]
  }
}

#let solution(body, color: none, title-style: "colon") = {
  let content = if title-style == "colon" {
    if (color == none) {
      strong[Solution: ]
    } else {
      text(fill: color, weight: "bold")[Solution: ]
    }
  } else if title-style == "parens" {
    emph[Solution. ]
  } else {
    panic("Unrecognized title style")
  }

  content; body
}
