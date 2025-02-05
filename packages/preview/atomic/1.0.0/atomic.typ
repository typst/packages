#import "@preview/cetz:0.3.2"

#let draw_orbit(radius, electrons, color: luma(90%)) = {
  import cetz.draw: *
      
  circle((0,0), radius: radius, fill: none)

  set-style(content: (padding: .2),
      fill: color,
      stroke: black)
  
  for i in range(electrons) {
    circle((radius*calc.sin(360deg/electrons*i), radius*calc.cos(360deg/electrons*i)), radius: 0.13)
    content((), "-")
  }
}

#let draw_center(atomic, mass, atom, radius: 0.6, color: luma(90%)) = {

  import cetz.draw: *

  if (atom.len() < 2){
    atom = atom + " "
  }

  set-style(content: (padding: .2),
      fill: color,
      stroke: black)
  
  circle((0, 0), radius: radius)
  content((),$""_atomic^(mass)atom$,)
}

#let draw_atom(atomic, mass, atom, electrons, orbitals: 1.0, step: 0.4, center: 0.6, color: luma(90%)) = {
                  
  import cetz.draw: *

  let loop = 0
  
  for i in electrons {
    draw_orbit((orbitals + loop*step), i, color: color)
    loop = loop + 1
  }

  draw_center(atomic, mass, atom, radius: center, color: color)
}

#let atom(atomic, mass, atom, electrons, orbitals: 1.0, step: 0.4, center: 0.6, color: luma(90%)) = {
    cetz.canvas({
    import cetz.draw: *
    draw_atom(atomic, mass, atom, electrons, orbitals: orbitals, step: step,
    center: center, color: color)
  })
}
