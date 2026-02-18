#import "@preview/cetz:0.3.2": draw, canvas
#import "@preview/typsium:0.2.0": get-element


#let is-metadata(it) = {
  type(it) == content and it.func() == metadata
}

/// Determine if a content is a metadata with a specific kind.
#let is-kind(it, kind) = {
  type(it.value) == dictionary and it.value.at("kind", default: none) == kind
}

#let get-element-dict(element)={
  if is-metadata(element) and is-kind(element, "element"){
    return element.value
  }
}


#let draw-shell(
  electrons: 0,
  radius: 1,
  fill: luma(90%),
  stroke: 1pt + black,
)={
  import draw: set-style, circle, content
  set-style(content: (padding: .2), fill: fill, stroke: stroke)

  circle((0,0), radius: radius, fill: none)

  for i in range(electrons) {
    circle(
      (radius*calc.sin(360deg/electrons*i),
      radius*calc.cos(360deg/electrons*i)),
      radius: 0.13)
    content((), padding: (bottom: 0.05),text(0.7em, math.minus))
  }
}

#let draw-core(
  atomic-number: none, 
  mass-number: none, 
  symbol: none, 
  core-radius: 0.6, 
  fill: luma(90%),
  stroke: 1pt + black,
) = {
  import draw: set-style, circle, content
  set-style(content: (padding: 0.2), fill: fill, stroke: stroke)
  
  if (symbol.len() < 2){
    symbol += " "
  }
  
  circle((0, 0), radius: core-radius)
  content((),$""_(#atomic-number)^(#mass-number)symbol$,)
}

#let validate-element(element)={
  let electrons = none
  if type(element) != dictionary{
    let candidate
    if type(element) == str{
      candidate = get-element(symbol: element).value
    } else if is-metadata(element){
      candidate = get-element-dict(element)
    }else if  type(element) == int{
      candidate = get-element(atomic-number: element).value
    }
    
    if candidate != none{
      element = (
        atomic-number: candidate.atomic-number,
        mass-number: candidate.at("most-common-isotope", default: candidate.at("mass-number", default: none)),
        symbol: candidate.symbol
      )
      let charge = candidate.at("charge", default:0)
      electrons = candidate.atomic-number - charge
    } else{
      element = (
        atomic-number: none,
        mass-number: none,
        symbol: ""
      )
    }
  }
  return (element, electrons)
}

#let validate-electrons(electrons)={
  if electrons == none or electrons == auto{
    return (0,)
  } else if type(electrons) == int or type(electrons) == float{
    let electron-shells = calc.floor(calc.sqrt(electrons/2)) + 1
    let rounds = ()

    for i in range(electron-shells) {
      if (electrons > 2*calc.pow(i+1, 2)){
        rounds.push(2*calc.pow(i+1, 2))
        electrons = electrons - (2*calc.pow(i+1, 2))
      } else {
        rounds.push(electrons)
      }
    }
    return rounds
  } else if type(electrons.first()) == array{
    return electrons.map(x=> x.at(1))
  }
  return electrons
}

#let draw-atom-shells(
  element:(
    atomic-number: 1,
    mass-number: 1,
    symbol: "H",
  ),
  electrons: auto,
  core-distance: 1,
  shell-distance: 0.4,
  core-radius: 0.6,
  fill: luma(90%),
  stroke: 1pt + black,
  validate: true,
)={
  if validate{
    let x = validate-element(element)
    element = x.at(0)
    if electrons == auto and x.at(1)!= none{electrons = x.at(1)}
    electrons = validate-electrons(electrons)
  }
  
  let loop = 0
  for current-shell in electrons {
    draw-shell(
      electrons: current-shell,
      radius: (core-distance + loop*shell-distance),
      fill: fill,
      stroke: stroke,
    )
    loop = loop + 1
  }
  
  draw-core(
    atomic-number: element.atomic-number, 
    mass-number: element.mass-number, 
    symbol: element.symbol, 
    core-radius: core-radius, 
    fill: fill,
    stroke: stroke,
  )
}

#let atom-shells(
  element:(
    atomic-number: 1,
    mass-number: 1,
    symbol: "H",
  ),
  electrons: auto,
  core-distance: 1,
  shell-distance: 0.4,
  core-radius: 0.6,
  fill: luma(90%),
  stroke: 1pt + black,
  validate: true,
)={
  if validate{
    let x = validate-element(element)
    element = x.at(0)
    if electrons == auto and x.at(1)!= none{electrons = x.at(1)}
    electrons = validate-electrons(electrons)
  }
    
  canvas({
    draw-atom-shells(
      element: element,
      electrons: electrons,
      core-distance: core-distance,
      shell-distance: shell-distance,
      core-radius: core-radius,
      fill: fill,
      stroke: stroke,
      validate: false
    )
  })
}
// TODO: Draw s, p, d, f orbitals, etc
// options:
//   n quantum number
//   l quantum number
//   m quantum number
//   s quantum number (maybe leave this one out)
//   two color mode or single color mode
//   rotation (?)

#let draw-atom-orbital()={
}
#let atom-orbital()={
}

// TODO: draw hybrid orbitals
// options:
//   sp, sp2, sp3
//   maybe even sp3d2 (?)
#let draw-hybrid-orbital()={
}
#let hybrid-orbital()={
}