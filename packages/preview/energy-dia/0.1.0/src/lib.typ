#import "modules.typ": *
#import "@preview/cetz:0.4.2"

/// Display an energy level diagram for atomic orbitals
/// 
/// Arguments:
/// - width (length): Width of the diagram
/// - height (length): Height of the diagram
/// - name (string): Name of the atom (default: none)
/// - exclude_energy (boolean): Whether to exclude energy labels (default: false)
/// - levels (array of dictionaries): Energy level and electron count data. Each dictionary has the following keys:
///   - energy (number): Energy value
///   - electrons (number): Number of electrons (default: 0)
///   - degeneracy (number): Degeneracy (default: 1)
///   - caption (string): Caption (default: none)
///   - up (boolean): Upward spin (default: none)
/// 
/// Example:
/// ```
/// #ao(
///   (energy: -1, electrons: 2),
///   (energy: 0, electrons: 1)
/// )
/// ```
#let ao(width: 5, height: 5, name: none, exclude_energy:false, ..levels) = {
  let pos_levels = levels.pos()
  if pos_levels.len() == 0 {
    cetz.canvas({
      import cetz.draw: *
      draw_axis(line, content, width, height)
    })
  } else {
    let min = find_min(pos_levels)
    let max = find_max(pos_levels)
    cetz.canvas({
    import cetz.draw: *

    draw_axis(line, content, width, height)
    if name != none {
      let x_position = width / 2
      draw_atomic_name(line, content, name, x_position, height)
    }else{
    }

    for level in pos_levels {
      draw_energy_level_ao(line, content, level.at("energy"), width, height, min, max, degeneracy: level.at("degeneracy", default: 1), caption: level.at("caption", default: none), exclude_energy: exclude_energy)

      draw_electron_ao(line, content, level.at("energy"), level.at("electrons", default: 0), width, height, min, max, up: level.at("up", default: none))
    }
  })
  }
}

/// Display an energy level diagram for molecular orbitals
/// 
/// Arguments:
/// - width (length): Width of the diagram
/// - height (length): Height of the diagram
/// - names (array): Names of the atoms and molecule (default: ())
/// - exclude_energy (boolean): Whether to exclude energy labels (default: false)
/// - atom1 (array of dictionaries): Energy level data for the left atom. Each dictionary has the following keys:
///   - energy (number): Energy value
///   - electrons (number): Number of electrons (default: 0)
///   - degeneracy (number): Degeneracy (default: 1)
///   - caption (string): Caption (default: none)
///   - up (boolean): Upward spin (default: none)
/// - molecule (array of dictionaries): Energy level data for the molecule. Each dictionary has the following keys:
///   - energy (number): Energy value
///   - electrons (number): Number of electrons (default: 0)
///   - degeneracy (number): Degeneracy (default: 1)
///   - caption (string): Caption (default: none)
///   - up (boolean): Upward spin (default: none)
/// - atom2 (array of dictionaries): Energy level data for the right atom. Each dictionary has the following keys:
///   - energy (number): Energy value
///   - electrons (number): Number of electrons (default: 0)
///   - degeneracy (number): Degeneracy (default: 1)
///   - caption (string): Caption (default: none)
///   - up (boolean): Upward spin (default: none)
/// - connections (array): Connection data between orbitals
///
/// Example:
/// ```
/// #mo(
///   atom1: ((energy: -1, electrons: 2), (energy: 0, electrons: 1)),
///   molecule: ((energy: -0.5, electrons: 2)),
///   atom2: ((energy: -1, electrons: 2), (energy: 0, electrons: 1))
/// )
/// ```
/// Warning:
/// Each atom and molecular orbital is required to be an array. Therefore, even if there is only one orbital, do not forget to put a comma at the end.
#let mo(width: 5, height: 5, names: (), exclude_energy: false, atom1: (), molecule: (), atom2: (), ..connections)={
  let all_levels = atom1 + molecule + atom2
  let min = find_min(all_levels)
  let max = find_max(all_levels)
  cetz.canvas({
    import cetz.draw: *

    draw_axis(line, content, width, height)
    
    let left_x = width / 6
    for level in atom1 {
      draw_energy_level_mo(line, content, level.at("energy"), left_x, width, height, min, max, degeneracy: level.at("degeneracy", default: 1), caption: level.at("caption", default: none), exclude_energy: exclude_energy)

      draw_electron_mo(line, content, level.at("energy"), level.at("electrons", default: 0), left_x, width, height, min, max, up: level.at("up", default: none))
    }
    

    let center_x = width / 2
    for level in molecule {
      draw_energy_level_mo(line, content, level.at("energy"), center_x, width, height, min, max, degeneracy: level.at("degeneracy", default: 1), caption: level.at("caption", default: none), exclude_energy: exclude_energy)

      draw_electron_mo(line, content, level.at("energy"), level.at("electrons", default: 0), center_x, width, height, min, max, up: level.at("up", default: none))
    }

    let right_x = 5 * width / 6
    for level in atom2 {
      draw_energy_level_mo(line, content, level.at("energy"), right_x, width, height, min, max, degeneracy: level.at("degeneracy", default: 1), caption: level.at("caption", default: none), exclude_energy: exclude_energy)

      draw_electron_mo(line, content, level.at("energy"), level.at("electrons", default: 0), right_x, width, height, min, max, up: level.at("up", default: none))
    }


    draw_connections(line, connections.pos(), atom1, molecule, atom2, width, height, min, max)

    if names != () {
      let x_positions = (left_x, center_x, right_x)
      for i in range(names.len()) {
        if names.at(i) != "" {
          draw_atomic_name(line, content, names.at(i), x_positions.at(i), height)
        }
      }
    }
  })
}

/// Display an energy level diagram for band structure
/// 
/// Arguments:
/// - width (length): Width of the diagram
/// - height (length): Height of the diagram
/// - name (string): Name of the substance (default: none)
/// - include_energy_labels (boolean): Whether to display energy labels
/// - levels (array of numbers): List of energy level values
/// 
/// Example:
/// ```
/// #band(
///   -1, 0, 0.5, 1,
///   include_energy_labels: true
/// )
/// ```
#let band(width:5, height:5, name:none, include_energy_labels: false, ..levels) = {
  let levels_pos = levels.pos()
  if levels_pos.len() == 0 {
    cetz.canvas({
      import cetz.draw: *
      draw_axis(line, content, width, height)
    })
  } else {
    let min = calc.min(..levels_pos)
    let max = calc.max(..levels_pos)
    cetz.canvas({
    import cetz.draw: *

    draw_axis(line, content, width, height)
    if name != none {
      let x_position = width / 2
      draw_atomic_name(line, content, name, x_position, height)
    }else{
    }

    for level in levels_pos {
      draw_energy_level_band(line, content, level, width, height, min, max, include_energy_labels: include_energy_labels)
    }
  })
  }
}