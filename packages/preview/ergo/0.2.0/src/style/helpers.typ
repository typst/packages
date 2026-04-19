#import "cosmetic-envs.typ": (
  proof,
  solution
)

#let ergo-title-selector = <__ergo_title>
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

#let get-title-content(
  preheader,
  title,
  is-proof:    false,
  prob-nums:   false,
  pad-env:     true,
  title-style: "colon",
) = {
  let xpad = 12pt
  let ypad = 6pt

  let count = if prob-nums [ #{problem-counter.step(); context problem-counter.display()}] else []

  let title-content = if title-style == "parens" {
    if title == [] {
      text(weight: "bold")[#preheader#count.]
    } else {
      text(weight: "bold")[#preheader#count] + [ (#title).]
    }

  } else if title-style == "colon" {
    if title == [] {
      text(weight: "bold")[#preheader#count]
    } else {
      text(weight: "bold")[#preheader#count: #title]
    }

  } else {
    panic("Unrecognized title style")
  }

  if title-style == "colon" and is-proof {
    title-content = [#emph[#title-content]]
  }

  title-content = [#title-content#ergo-title-selector]

  if pad-env {
    return pad(x: xpad, y: ypad, title-content)
  } else {
    return title-content
  }
}

#let get-solution-content(
  solution-body,
  is-proof,
  inline-qed,
  sol-color: none,
  pad-env: true,
  title-style: "colon",
) = {
  let xpad = 12pt
  let ypad = 6pt
  let solution-content

  if solution-body == [] {
    return none
  } else {
    if is-proof {
      solution-content = proof(
        solution-body,
        inline-qed: inline-qed,
        color: sol-color,
        title-style: title-style
      )
    } else {
      solution-content = solution(
        solution-body,
        color: sol-color,
        title-style: title-style
      )
    }
  }

  if pad-env {
    return pad(x: xpad, y: ypad, solution-content)
  } else {
    return solution-content
  }
}

#let get-statement-content(
  statement,
  pad-env: true,
) = {
  let xpad = 12pt
  let ypad = 6pt

  if statement == [] {
    return none
  } else {

    if pad-env {
      return pad(x: xpad, y: ypad, statement)
    } else {
      return statement
    }
  }
}
