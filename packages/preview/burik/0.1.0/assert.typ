#import "algo.typ":*

#let two-top-layers = (face) => {
    let c = face.at(4)  // couleur du centre
    face.at(0) == c and face.at(1) == c and face.at(2) == c and face.at(3) == c and face.at(4) == c and face.at(5) == c
}

#let cross = (face) => {
    let c = face[4]  // couleur du centre
    face[1] == c and face[3] == c and face[5] == c and face[7] == c
}

#let assert-pll(cube) = {

  // Check white face
  let u-check = cube.u.all((x) => x == colors.white)

  // Check 2 top layers on the 4 sides
  let f-check = two-top-layers(cube.f)
  let b-check = two-top-layers(cube.b)
  let r-check = two-top-layers(cube.r)
  let l-check = two-top-layers(cube.l)

  // Check yellow face
  let d-check = cube.d.all((x) => x == colors.yellow)

  // Returns True only if cube is in pll config
  u-check and f-check and b-check and r-check and l-check and d-check
}

#let assert-oll(cube) = {

  // Check white face
  let u-check = cube.u.all((x) => x == colors.white)

  // Check 2 top layers on the 4 sides
  let f-check = two-top-layers(cube.f)
  let b-check = two-top-layers(cube.b)
  let r-check = two-top-layers(cube.r)
  let l-check = two-top-layers(cube.l)

  // Returns True only if cube is in oll config
  u-check and f-check and b-check and r-check and l-check
}

/*let assert-f2l(cube) = {

  // Check white face
  let u-check = cube.u.all((x) => x == colors.white)

  // Check 2 top layers on the 4 sides
  let f-check = two-top-layers(cube.f)
  let b-check = two-top-layers(cube.b)
  let r-check = two-top-layers(cube.r)
  let l-check = two-top-layers(cube.l)

  // Returns True only if cube is in oll config
  u-check and f-check and b-check and r-check and l-check
}*/

// TODO : assert-f2l, 3 pairs solved over 4