#import "modules.typ": *
#import "@preview/cetz:0.4.2"

/// Display an energy level diagram for atomic orbitals
/// 
/// Arguments:
/// - width (length): Width of the diagram
/// - height (length): Height of the diagram
/// - name (string): Name of the atom (default: none)
/// - exclude-energy (boolean): Whether to exclude energy labels (default: false)
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
#let ao(width: 5, height: 5, name: none, exclude-energy:false, ..levels) = {
  let pos-levels = levels.pos()
  if pos-levels.len() == 0 {
    cetz.canvas({
      import cetz.draw: *
      draw-axis(line, content, width, height)
    })
  } else {
    let min = find-min(pos-levels)
    let max = find-max(pos-levels)
    cetz.canvas({
    import cetz.draw: *

    draw-axis(line, content, width, height)
    if name != none {
      let x-position = width / 2
      draw-atomic-name(line, content, name, x-position, height)
    }else{
    }

    for level in pos-levels {
      draw-energy-level-ao(line, content, level.at("energy"), width, height, min, max, degeneracy: level.at("degeneracy", default: 1), caption: level.at("caption", default: none), exclude-energy: exclude-energy)

      draw-electron-ao(line, content, level.at("energy"), level.at("electrons", default: 0), width, height, min, max, up: level.at("up", default: none))
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
/// - exclude-energy (boolean): Whether to exclude energy labels (default: false)
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
#let mo(width: 5, height: 5, names: (), exclude-energy: false, atom1: (), molecule: (), atom2: (), ..connections)={
  let all-levels = atom1 + molecule + atom2
  let min = find-min(all-levels)
  let max = find-max(all-levels)
  cetz.canvas({
    import cetz.draw: *

    draw-axis(line, content, width, height)
    
    let left-x = width / 6
    for level in atom1 {
      draw-energy-level-mo(line, content, level.at("energy"), left-x, width, height, min, max, degeneracy: level.at("degeneracy", default: 1), caption: level.at("caption", default: none), exclude-energy: exclude-energy)

      draw-electron-mo(line, content, level.at("energy"), level.at("electrons", default: 0), left-x, width, height, min, max, up: level.at("up", default: none))
    }
    

    let center-x = width / 2
    for level in molecule {
      draw-energy-level-mo(line, content, level.at("energy"), center-x, width, height, min, max, degeneracy: level.at("degeneracy", default: 1), caption: level.at("caption", default: none), exclude-energy: exclude-energy)

      draw-electron-mo(line, content, level.at("energy"), level.at("electrons", default: 0), center-x, width, height, min, max, up: level.at("up", default: none))
    }

    let right-x = 5 * width / 6
    for level in atom2 {
      draw-energy-level-mo(line, content, level.at("energy"), right-x, width, height, min, max, degeneracy: level.at("degeneracy", default: 1), caption: level.at("caption", default: none), exclude-energy: exclude-energy)

      draw-electron-mo(line, content, level.at("energy"), level.at("electrons", default: 0), right-x, width, height, min, max, up: level.at("up", default: none))
    }


    draw-connections(line, connections.pos(), atom1, molecule, atom2, width, height, min, max)

    if names != () {
      let x-positions = (left-x, center-x, right-x)
      for i in range(names.len()) {
        if names.at(i) != "" {
          draw-atomic-name(line, content, names.at(i), x-positions.at(i), height)
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
/// - include-energy-labels (boolean): Whether to display energy labels
/// - levels (array of numbers): List of energy level values
/// 
/// Example:
/// ```
/// #band(
///   -1, 0, 0.5, 1,
///   include-energy-labels: true
/// )
/// ```
#let band(width:5, height:5, name:none, include-energy-labels: false, ..levels) = {
  let levels-pos = levels.pos()
  if levels-pos.len() == 0 {
    cetz.canvas({
      import cetz.draw: *
      draw-axis(line, content, width, height)
    })
  } else {
    let min = calc.min(..levels-pos)
    let max = calc.max(..levels-pos)
    cetz.canvas({
    import cetz.draw: *

    draw-axis(line, content, width, height)
    if name != none {
      let x-position = width / 2
      draw-atomic-name(line, content, name, x-position, height)
    }else{
    }

    for level in levels-pos {
      draw-energy-level-band(line, content, level, width, height, min, max, include-energy-labels: include-energy-labels)
    }
  })
  }
}