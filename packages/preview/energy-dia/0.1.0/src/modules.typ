#let scale_y(energy, min, max, height) = {
  if max == min {
    height / 2
  } else {
    let scaled_y = height * 0.8 * (energy - min) / (max - min) + height * 0.1
    scaled_y
  }
}

#let position_x_ao(width)={
  let pos_x = width / 2
  pos_x
}

#let draw_axis(line_fn, content_fn, width, height) = {
  line_fn((0, 0), (0, height), mark: (end: "straight"))
  content_fn((0, height / 2), [energy / eV], angle: 90deg, anchor: "south")
}

#let draw_energy_level_ao(line_fn, content_fn, energy, width, height, min, max, degeneracy: 1, caption: none, exclude_energy: bool) = {
  let y= scale_y(energy, min, max, height)
  let x= position_x_ao(width)
  let line_length = width / 7
  let spacing = height / 50
  for i in range(degeneracy) {
    let offset = (i - (degeneracy - 1) / 2) * spacing
    line_fn((x - line_length, y + offset),(x + line_length, y + offset))
  }
  if exclude_energy == false {
  content_fn((x - line_length - width/20,y), [$energy$])
  }
  if caption !=none{
    content_fn((x + line_length + width/20, y), [$caption$])
  }
}

#let draw_electron_ao(line_fn, content_fn, energy, number, width, height, min, max, up: none) = {
  if number <= 0 {
  } else {
    let y = scale_y(energy, min, max, height)
    let x_center = position_x_ao(width)
    let left = x_center - width / 7
    let right = x_center + width / 7
    let spacing = (right - left) / (number + 1)
    if up == none {
      for i in range(number) {
        let x = left + (i + 1) * spacing
        let is_up = calc.rem(i, 2) == 0
        if is_up {
          line_fn((x, y - height/20), (x, y + height/20), mark: (end: "straight"))
        } else {
          line_fn((x, y + height/20), (x, y - height/20), mark: (end: "straight"))
        }
      }
    } else {
      let up_count = up
      let down_count = number - up_count

      if up_count >= down_count{
        let smaller = down_count
        let current_x = left + spacing
        for i in range(smaller){
          line_fn((current_x, y - height/20), (current_x, y + height/20), mark: (end: "straight"))
          current_x += spacing
          line_fn((current_x, y + height/20), (current_x, y - height/20), mark: (end: "straight"))
          current_x += spacing
        }
        let rem = up_count - smaller
        let current_x = left + spacing * (2 * smaller + 1)
        for i in range(rem){
          line_fn((current_x, y - height/20), (current_x, y + height/20), mark: (end: "straight"))
          current_x += spacing
        }
      }else{
        let smaller = up_count
        for i in range(smaller){
          let current_x = left + spacing
          line_fn((current_x, y + height/20), (current_x, y - height/20), mark: (end: "straight"))
          current_x += spacing
          line_fn((current_x, y - height/20), (current_x, y + height/20), mark: (end: "straight"))
          current_x += spacing
        }
        let rem = down_count - smaller
        let current_x = left + spacing * (2 * smaller + 1)
        for i in range(rem){
          line_fn((current_x, y + height/20), (current_x, y - height/20), mark: (end: "straight"))
          current_x += spacing
        }
      }
    }
  }
}

#let draw_atomic_name(line_fn, content_fn, name, width, height) = {
  content_fn((width, height), [$name$], anchor: "center")
}

#let find_min(levels)={
  if levels.len() == 0 {
    0
  } else {
    let energies = levels.map(it => it.at("energy"))
    calc.min(..energies)
  }
}

#let find_max(levels)={
  if levels.len() == 0 {
    0
  } else {
    let energies = levels.map(it => it.at("energy"))
    calc.max(..energies)
  }
}


#let draw_energy_level_mo(line_fn, content_fn, energy, x_pos, width, height, min, max, degeneracy: 1, caption: none, exclude_energy: bool) = {
  let y= scale_y(energy, min, max, height)
  let line_length = width / 21
  let spacing = height / 50
  for i in range(degeneracy) {
    let offset = (i - (degeneracy - 1) / 2) * spacing
    line_fn((x_pos - line_length, y + offset),(x_pos + line_length, y + offset))
  }
  if exclude_energy == false {
    content_fn((x_pos - line_length - width/20,y), [$energy$])
  }
  if caption !=none{
  content_fn((x_pos + line_length + width/20, y), [$caption$])
  }
}

#let draw_electron_mo(line_fn, content_fn, energy, number, x_pos, width, height, min, max, up: none) = {
  if number <= 0 {
  } else {
    let y = scale_y(energy, min, max, height)
    let left = x_pos - width / 21
    let right = x_pos + width / 21
    let spacing = (right - left) / (number + 1)
    if up == none {
      for i in range(number) {
        let x = left + (i + 1) * spacing
        let is_up = calc.rem(i, 2) == 0
        if is_up {
          line_fn((x, y - height/20), (x, y + height/20), mark: (end: "straight"))
        } else {
          line_fn((x, y + height/20), (x, y - height/20), mark: (end: "straight"))
        }
      }
    } else {
      let up_count = calc.min(up, number)
      let down_count = number - up_count
      if up_count >= down_count{
        let smaller = down_count
        let current_x = left + spacing
        for i in range(smaller){
          line_fn((current_x, y - height/20), (current_x, y + height/20), mark: (end: "straight"))
          current_x += spacing
          line_fn((current_x, y + height/20), (current_x, y - height/20), mark: (end: "straight"))
          current_x += spacing
        }
        let rem = up_count - smaller
        let current_x = left + spacing * (2 * smaller + 1)
        for i in range(rem){
          line_fn((current_x, y - height/20), (current_x, y + height/20), mark: (end: "straight"))
          current_x += spacing
        }
      }else{
        let smaller = up_count
        for i in range(smaller){
          let current_x = left + spacing
          line_fn((current_x, y + height/20), (current_x, y - height/20), mark: (end: "straight"))
          current_x += spacing
          line_fn((current_x, y - height/20), (current_x, y + height/20), mark: (end: "straight"))
          current_x += spacing
        }
        let rem = down_count - smaller
        let current_x = left + spacing * (2 * smaller + 1)
        for i in range(rem){
          line_fn((current_x, y + height/20), (current_x, y - height/20), mark: (end: "straight"))
          current_x += spacing
        }
      }
    }
  }
}

#let get_position_by_label(label, atom1, molecule, atom2, width, height, min, max, position) = {
  let left_x = width / 6 + width / 21
  let center_left_x = width / 2 - width / 21
  let center_right_x = width / 2 + width / 21
  let right_x = 5 * width / 6 - width / 21
  for level in atom1 {
    if level.at("label", default: none) == label {
      let y = scale_y(level.at("energy"), min, max, height)
      return (left_x, y)
    }
  }
  for level in molecule {
    if level.at("label", default: none) == label {
      let y = scale_y(level.at("energy"), min, max, height)
      if position == "atom1_to_molecule" {
        return (center_left_x, y)
      } else {
        return (center_right_x, y)
      }
    }
  }
  for level in atom2 {
    if level.at("label", default: none) == label {
      let y = scale_y(level.at("energy"), min, max, height)
      return (right_x, y)
    }
  }
  return none
}

#let draw_connections(line_fn, connections, atom1, molecule, atom2, width, height, min, max) = {
  for conn in connections {
    let label1 = conn.at(0)
    let label2 = conn.at(1)
    let level1 = atom1.map(it => it.at("label",default:none))
    let position = if label1 in level1 or label2 in level1 {
      "atom1_to_molecule"
    }else{
      "atom2_to_molecule"
    }
    let pos1 = get_position_by_label(label1, atom1, molecule, atom2, width, height, min, max, position)
    let pos2 = get_position_by_label(label2, atom1, molecule, atom2, width, height, min, max, position)
    if pos1 != none and pos2 != none {
      line_fn(pos1, pos2, stroke: (dash: "dashed"))
    }
  }
}

#let draw_energy_level_band(line_fn, content_fn, energy, width, height, min, max, include_energy_labels: bool) = {
  let y= scale_y(energy, min, max, height)
  let x = width / 2
  let line_length = width / 7
  line_fn((x - line_length, y),(x + line_length, y))
  if include_energy_labels {
    content_fn((x - line_length - width/20,y), [$energy$])
  }
}