#let get-forces(offsets, data, force-multiplier) = {
  import "processing.typ": *
  let forces = (0.0,) * offsets.len()

  // forces neighors in the same generation apart
  // maximum of 0.1 force, the highest out of all forces.
  for generation in data.individuals-by-gen-indices {
    for ind-number in range(generation.len() - 1) {
      let individual-1-id = generation.at(ind-number)
      let individual-2-id = generation.at(ind-number + 1)
      let x1 = offsets.at(individual-1-id)
      let x2 = offsets.at(individual-2-id) // normally is higher
      let force
      if x2 < x1 { // the individual that should be right is actually left
        force = 0.1
      } else if x2 < x1 + 1 { // too close
        force = (1 + x1 - x2) * 0.05 + calc.min(0.05, 1 + x1 - x2) // some force even when 0.999 away
      } else { // to far
        force = -calc.max(0.005, 0.005 * (x2 - x1) / 5)
      }
      forces.at(individual-1-id) = forces.at(individual-1-id) - force * force-multiplier
      forces.at(individual-2-id) = forces.at(individual-2-id) + force * force-multiplier
    }
  }

  // force children-parent lines to be straight.
  // maximum of 0.075 force, but spread over individuals
  for children in iterate-childrens(data) {
    if children.childs.len() == 0 {
      continue
    }
    let parent-x
    let parent-ids = ()
    if children.parents.type == "union" {
      parent-ids.push(children.parents.individual-1.ind-id)
      parent-ids.push(children.parents.individual-2.ind-id)
      parent-x = (
        offsets.at(children.parents.individual-1.ind-id)
        + offsets.at(children.parents.individual-2.ind-id)
      ) / 2
    } else {
      parent-ids.push(children.parents.ind-id)
      parent-x = offsets.at(children.parents.ind-id)
    }
    let minimum-children-x = none
    let maximum-children-x = none
    let children-ids = ()
    for child in children.childs {
      let individuals
      if child.type in ("individual", "duplicate") {
        individuals = (child,)
      } else { // twin
        individuals = child.individuals
      }
      for individual in individuals {
        children-ids.push(individual.ind-id)
        let child-x = offsets.at(individual.ind-id)
        if minimum-children-x == none or child-x < minimum-children-x {
          minimum-children-x = child-x
        }
        if maximum-children-x == none or child-x > minimum-children-x {
          maximum-children-x = child-x
        }
      }
    }
    let average-children-x = (minimum-children-x + maximum-children-x) / 2
    let force
    // strongly discourage parents that are not over their children
    if parent-x < minimum-children-x {
      force = 0.075 * calc.min(1, (maximum-children-x - parent-x) / 0.075)
    } else if parent-x > maximum-children-x {
      force = -0.075 * calc.min(1, (parent-x - minimum-children-x) / 0.075)
    } else { // push parents towards center of children
      force = calc.min(0.05, calc.max(-0.05, 0.05 * (average-children-x - parent-x)))
    }
    let force-per-child = force / children-ids.len()
    let force-per-parent = force / parent-ids.len()
    for parent-id in parent-ids {
      forces.at(parent-id) = forces.at(parent-id) + force-per-parent * force-multiplier
    }
    for child-id in children-ids {
      forces.at(child-id) = forces.at(child-id) - force-per-child * force-multiplier
    }
  }

  // vertical lines from children
  // maximum force of 0.025
  let vertical-line-obstacles = ((),) * data.maximum-generation
  for children in iterate-childrens(data) {
    if children.childs.len() == 0 {
      continue
    }
    let parent-generation
    let parent-x
    let parent-ids = ()
    if children.parents.type == "union" {
      let individual-1 = children.parents.individual-1
      let individual-2 = children.parents.individual-2
      parent-ids.push(individual-1.ind-id)
      parent-ids.push(individual-2.ind-id)
      parent-generation = (individual-1.generation + individual-2.generation) / 2 - 1
      parent-x = (offsets.at(individual-1.ind-id) + offsets.at(individual-2.ind-id)) / 2
    } else {
      parent-ids.push(children.parents.ind-id)
      parent-generation = children.parents.generation - 1
      parent-x = offsets.at(children.parents.ind-id)
    }
    let minimum-generation = children.minimum-generation - 1
    // now, find the obstacles
    for generation in range(calc.ceil(parent-generation + 0.5), minimum-generation) {
      vertical-line-obstacles.at(generation).push((x: parent-x, ids: parent-ids))
    }
    for child in children.childs {
      let obstacle-x
      let obstacle-ids
      if child.type in ("individual", "duplicate") {
        obstacle-ids = (child.ind-id,)
        obstacle-x = offsets.at(child.ind-id)
      } else { // twin
        let minimum-twin-x = none
        let maximum-twin-x = none
        obstacle-ids = ()
        for individual in child.individuals {
          obstacle-ids.push(individual.ind-id)
          let individual-x = offsets.at(individual.ind-id)
          if minimum-twin-x == none or individual-x < minimum-twin-x {
            minimum-twin-x = individual-x
          }
          if maximum-twin-x == none or individual-x > maximum-twin-x {
            maximum-twin-x = individual-x
          }
        }
        obstacle-x = (minimum-twin-x + maximum-twin-x) / 2
      }
      for generation in range(minimum-generation, child.generation - 1) {
        vertical-line-obstacles.at(generation).push((x: obstacle-x, ids: obstacle-ids))
      }
    }
  }
  for (generation, obstacles) in data.individuals-by-gen-indices.zip(vertical-line-obstacles) {
    for ind-id in generation {
      let individual-x = offsets.at(ind-id)
      for obstacle in obstacles {
        let force = 0

        if individual-x > obstacle.x and individual-x < obstacle.x + 1 {
          force = 0.0125
          forces.at(ind-id) = forces.at(ind-id) + 0.0125 * force-multiplier
          for id in obstacle.ids {
            forces.at(id) = forces.at(id) - (0.0125 / obstacle.ids.len()) * force-multiplier
          }
        } else if individual-x <= obstacle.x and individual-x > obstacle.x - 1 {
          force = -0.0125
        }

        if force != 0 {
          forces.at(ind-id) = forces.at(ind-id) - 0.0125 * force-multiplier
          for id in obstacle.ids {
            forces.at(id) = forces.at(id) + (0.0125 / obstacle.ids.len()) * force-multiplier
          }
        }
      }
    }
  }

  // force unions to be near to each other
  // maximum of 0.025 force per individual
  for union in iterate-unions(data) {
    let individual-1-id = union.individual-1.ind-id
    let individual-2-id = union.individual-2.ind-id
    let x1 = offsets.at(individual-1-id)
    let x2 = offsets.at(individual-2-id)
    if x2 > x1 + 1 { // only force if too far away; other processes take care of other conditions
      let force = calc.min(0.025, (x2 - x1 - 1) * 0.025)
      forces.at(individual-1-id) = forces.at(individual-1-id) + force * force-multiplier
      forces.at(individual-2-id) = forces.at(individual-2-id) - force * force-multiplier
    }
  }

  return forces
}

// resolve overlappings and stuff
#let resolve-overlaps(data, convergence-time) = {
  import "processing.typ": *
  let offsets = data.individuals-x

  for iteration in range(convergence-time) {
    let individual-forces = get-forces(offsets, data, 1)
    for (ind-id, (offset, force)) in offsets.zip(individual-forces).enumerate() {
      offsets.at(ind-id) = offset + force
    }
  }
  // fine adjustments
  for iteration in range(calc.min(10, convergence-time / 5)) {
    let individual-forces = get-forces(offsets, data, 0.1)
    for (ind-id, (offset, force)) in offsets.zip(individual-forces).enumerate() {
      offsets.at(ind-id) = offset + force
    }
  }
  // teleport single-child children objects to be straight
  while true { // multiple times in case of chains of single-children
    let has-changes = false
    for children in iterate-childrens(data) {
      if children.childs.len() != 1 {
        continue // only straighten single-childs
      }
      let parent-x
      if children.parents.type == "union" {
        parent-x = (
          offsets.at(children.parents.individual-1.ind-id)
          + offsets.at(children.parents.individual-2.ind-id)
        ) / 2
      } else {
        parent-x = offsets.at(children.parents.ind-id)
      }
      let first-child = children.childs.at(0)
      let child-ids
      let child-x
      if first-child.type in ("individual", "duplicate") {
        child-ids = (first-child.ind-id,)
        child-x = offsets.at(first-child.ind-id)
      } else { // twin
        child-ids = first-child.individuals.map(individual => individual.ind-id)
        let twins-x = first-child.individuals.map(individual => offsets.at(individual.ind-id))
        child-x = (calc.min(..twins-x) + calc.max(..twins-x)) / 2
      }
      if calc.abs(parent-x - child-x) > 0.0001 and calc.abs(parent-x - child-x) < 0.075 {
        for child-id in child-ids {
          offsets.at(child-id) = offsets.at(child-id) - child-x + parent-x
        }
        has-changes = true
      }
    }
    if not has-changes {break}
  }

  let minimum-offset = calc.min(..offsets)
  offsets = offsets.map(offset => offset - minimum-offset)
  // get bounds from offsets
  let childrens-x-bounds = iterate-childrens(data).map(children => {
    if children.childs.len() == 0 {
      return (minimum-x: none, maximum-x: none)
    }
    let childs-x = children.childs.map(child => {
      if child.type in ("individual", "duplicate") {
        return offsets.at(child.ind-id)
      } else { // twin
        let twins-x = child.individuals.map(individual => offsets.at(individual.ind-id))
        return (calc.min(..twins-x) + calc.max(..twins-x)) / 2
      }
    })
    return (minimum-x: calc.min(..childs-x), maximum-x: calc.max(..childs-x))
  })

  return (offsets, childrens-x-bounds)
}
