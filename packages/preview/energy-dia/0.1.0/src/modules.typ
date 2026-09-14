#let scale-y(energy, min, max, height) = {
  if max == min {
    height / 2
  } else {
    let scaled-y = height * 0.8 * (energy - min) / (max - min) + height * 0.1
    scaled-y
  }
}

#let position-x-ao(width)={
  let pos-x = width / 2
  pos-x
}

#let draw-axis(line-fn, content-fn, width, height) = {
  line-fn((0, 0), (0, height), mark: (end: "straight"))
  content-fn((0, height / 2), [energy / eV], angle: 90deg, anchor: "south")
}

#let draw-energy-level-ao(line-fn, content-fn, energy, width, height, min, max, degeneracy: 1, caption: none, exclude-energy: bool) = {
  let y= scale-y(energy, min, max, height)
  let x= position-x-ao(width)
  let line-length = width / 7
  let spacing = height / 50
  for i in range(degeneracy) {
    let offset = (i - (degeneracy - 1) / 2) * spacing
    line-fn((x - line-length, y + offset),(x + line-length, y + offset))
  }
  if exclude-energy == false {
  content-fn((x - line-length - width/20,y), [$energy$])
  }
  if caption !=none{
    content-fn((x + line-length + width/20, y), [$caption$])
  }
}

#let draw-electron-ao(line-fn, content-fn, energy, number, width, height, min, max, up: none) = {
  if number <= 0 {
  } else {
    let y = scale-y(energy, min, max, height)
    let x-center = position-x-ao(width)
    let left = x-center - width / 7
    let right = x-center + width / 7
    let spacing = (right - left) / (number + 1)
    if up == none {
      for i in range(number) {
        let x = left + (i + 1) * spacing
        let is-up = calc.rem(i, 2) == 0
        if is-up {
          line-fn((x, y - height/20), (x, y + height/20), mark: (end: "straight"))
        } else {
          line-fn((x, y + height/20), (x, y - height/20), mark: (end: "straight"))
        }
      }
    } else {
      let up-count = up
      let down-count = number - up-count

      if up-count >= down-count{
        let smaller = down-count
        let current-x = left + spacing
        for i in range(smaller){
          line-fn((current-x, y - height/20), (current-x, y + height/20), mark: (end: "straight"))
          current-x += spacing
          line-fn((current-x, y + height/20), (current-x, y - height/20), mark: (end: "straight"))
          current-x += spacing
        }
        let rem = up-count - smaller
        let current-x = left + spacing * (2 * smaller + 1)
        for i in range(rem){
          line-fn((current-x, y - height/20), (current-x, y + height/20), mark: (end: "straight"))
          current-x += spacing
        }
      }else{
        let smaller = up-count
        for i in range(smaller){
          let current-x = left + spacing
          line-fn((current-x, y + height/20), (current-x, y - height/20), mark: (end: "straight"))
          current-x += spacing
          line-fn((current-x, y - height/20), (current-x, y + height/20), mark: (end: "straight"))
          current-x += spacing
        }
        let rem = down-count - smaller
        let current-x = left + spacing * (2 * smaller + 1)
        for i in range(rem){
          line-fn((current-x, y + height/20), (current-x, y - height/20), mark: (end: "straight"))
          current-x += spacing
        }
      }
    }
  }
}

#let draw-atomic-name(line-fn, content-fn, name, width, height) = {
  content-fn((width, height), [$name$], anchor: "center")
}

#let find-min(levels)={
  if levels.len() == 0 {
    0
  } else {
    let energies = levels.map(it => it.at("energy"))
    calc.min(..energies)
  }
}

#let find-max(levels)={
  if levels.len() == 0 {
    0
  } else {
    let energies = levels.map(it => it.at("energy"))
    calc.max(..energies)
  }
}


#let draw-energy-level-mo(line-fn, content-fn, energy, x-pos, width, height, min, max, degeneracy: 1, caption: none, exclude-energy: bool) = {
  let y= scale-y(energy, min, max, height)
  let line-length = width / 21
  let spacing = height / 50
  for i in range(degeneracy) {
    let offset = (i - (degeneracy - 1) / 2) * spacing
    line-fn((x-pos - line-length, y + offset),(x-pos + line-length, y + offset))
  }
  if exclude-energy == false {
    content-fn((x-pos - line-length - width/20,y), [$energy$])
  }
  if caption !=none{
  content-fn((x-pos + line-length + width/20, y), [$caption$])
  }
}

#let draw-electron-mo(line-fn, content-fn, energy, number, x-pos, width, height, min, max, up: none) = {
  if number <= 0 {
  } else {
    let y = scale-y(energy, min, max, height)
    let left = x-pos - width / 21
    let right = x-pos + width / 21
    let spacing = (right - left) / (number + 1)
    if up == none {
      for i in range(number) {
        let x = left + (i + 1) * spacing
        let is-up = calc.rem(i, 2) == 0
        if is-up {
          line-fn((x, y - height/20), (x, y + height/20), mark: (end: "straight"))
        } else {
          line-fn((x, y + height/20), (x, y - height/20), mark: (end: "straight"))
        }
      }
    } else {
      let up-count = calc.min(up, number)
      let down-count = number - up-count
      if up-count >= down-count{
        let smaller = down-count
        let current-x = left + spacing
        for i in range(smaller){
          line-fn((current-x, y - height/20), (current-x, y + height/20), mark: (end: "straight"))
          current-x += spacing
          line-fn((current-x, y + height/20), (current-x, y - height/20), mark: (end: "straight"))
          current-x += spacing
        }
        let rem = up-count - smaller
        let current-x = left + spacing * (2 * smaller + 1)
        for i in range(rem){
          line-fn((current-x, y - height/20), (current-x, y + height/20), mark: (end: "straight"))
          current-x += spacing
        }
      }else{
        let smaller = up-count
        for i in range(smaller){
          let current-x = left + spacing
          line-fn((current-x, y + height/20), (current-x, y - height/20), mark: (end: "straight"))
          current-x += spacing
          line-fn((current-x, y - height/20), (current-x, y + height/20), mark: (end: "straight"))
          current-x += spacing
        }
        let rem = down-count - smaller
        let current-x = left + spacing * (2 * smaller + 1)
        for i in range(rem){
          line-fn((current-x, y + height/20), (current-x, y - height/20), mark: (end: "straight"))
          current-x += spacing
        }
      }
    }
  }
}

#let get-position-by-label(label, atom1, molecule, atom2, width, height, min, max, position) = {
  let left-x = width / 6 + width / 21
  let center-left-x = width / 2 - width / 21
  let center-right-x = width / 2 + width / 21
  let right-x = 5 * width / 6 - width / 21
  for level in atom1 {
    if level.at("label", default: none) == label {
      let y = scale-y(level.at("energy"), min, max, height)
      return (left-x, y)
    }
  }
  for level in molecule {
    if level.at("label", default: none) == label {
      let y = scale-y(level.at("energy"), min, max, height)
      if position == "atom1-to-molecule" {
        return (center-left-x, y)
      } else {
        return (center-right-x, y)
      }
    }
  }
  for level in atom2 {
    if level.at("label", default: none) == label {
      let y = scale-y(level.at("energy"), min, max, height)
      return (right-x, y)
    }
  }
  return none
}

#let draw-connections(line-fn, connections, atom1, molecule, atom2, width, height, min, max) = {
  for conn in connections {
    let label1 = conn.at(0)
    let label2 = conn.at(1)
    let level1 = atom1.map(it => it.at("label",default:none))
    let position = if label1 in level1 or label2 in level1 {
      "atom1-to-molecule"
    }else{
      "atom2-to-molecule"
    }
    let pos1 = get-position-by-label(label1, atom1, molecule, atom2, width, height, min, max, position)
    let pos2 = get-position-by-label(label2, atom1, molecule, atom2, width, height, min, max, position)
    if pos1 != none and pos2 != none {
      line-fn(pos1, pos2, stroke: (dash: "dashed"))
    }
  }
}

#let draw-energy-level-band(line-fn, content-fn, energy, width, height, min, max, include-energy-labels: bool) = {
  let y= scale-y(energy, min, max, height)
  let x = width / 2
  let line-length = width / 7
  line-fn((x - line-length, y),(x + line-length, y))
  if include-energy-labels {
    content-fn((x - line-length - width/20,y), [$energy$])
  }
}