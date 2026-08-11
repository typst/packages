#let parse-individual-id(id) = { // starts with i
  let (generation, ind-number) = id.slice(1, none).split("-")
  return (type: "individual", generation: int(generation) - 1, ind-number: int(ind-number))
}
#let parse-union-id(id) = { // starts with u
  let union-number = id.slice(1, none)
  return (type: "union", id: int(union-number) - 1)
}
#let parse-children-id(id) = { // starts with a c (cereal!)
  let children-number = id.slice(1, none)
  return (type: "children", id: int(children-number) - 1)
}
#let parse-duplicate-id(id) = { // starts with d
  let duplicate-number = id.slice(1, none)
  return (type: "duplicate", id: int(duplicate-number) - 1)
}
#let parse-twin-id(id) = { // starts with a t
  let twin-number = id.slice(1, none)
  return (type: "twin", id: int(twin-number) - 1)
}
#let parse-id(id) = { // returns a coord
  if id.at(0) == "i" {
    return parse-individual-id(id)
  } else if id.at(0) == "u" {
    return parse-union-id(id)
  } else if id.at(0) == "c" {
    return parse-children-id(id)
  } else if id.at(0) == "d" {
    return parse-duplicate-id(id)
  } else if id.at(0) == "t" {
    return parse-twin-id(id)
  }
  panic(id + " should start with 'i' or 'u' or 'c' or 'd' or 't'")
}

#let individual-from-position(data, coord-generation, coord-ind-number) = {
  let generation = data.individuals-by-gen.at(coord-generation)
  let generation-indices = data.individuals-by-gen-indices.at(coord-generation)
  for (individual, index) in generation.zip(generation-indices) {
    if individual.type == "individual" and individual.ind-number == coord-ind-number {
      return (
        type: "individual",
        individual: individual,
        id: index,
        ind-id: index, // same here, but not in duplicate
        x: data.individuals-x.at(index),
        generation: individual.generation,
      )
    }
  }
  panic("No individual of id i" + str(coord-generation + 1) + "-" + str(coord-ind-number))
}
#let individual-from-id(data, id) = {
  let individual = data.individuals.at(id)
  return (
    type: "individual",
    individual: individual,
    id: id,
    ind-id: id, // same here, but not in duplicate
    x: data.individuals-x.at(id),
    generation: individual.generation,
  )
}
#let union-from-id(data, id) = {
  let individuals = data.unions-individuals.at(id)
  return (
    type: "union",
    union: data.unions.at(id),
    individual-1: individuals.individual-1,
    individual-2: individuals.individual-2,
    id: id,
  )
}
#let children-from-id(data, id) = {
  return (
    type: "children",
    children: data.childrens.at(id),
    parents: data.childrens-parents.at(id),
    childs: data.childrens-children.at(id),
    minimum-generation: data.childrens-bounds.at(id),
    id: id,
  )
}
#let duplicate-from-id(data, id) = {
  let individual-id = data.duplicates-indices.at(id)
  return (
    type: "duplicate",
    individual: data.duplicates-individuals.at(individual-id).individual,
    id: id,
    ind-id: individual-id,
    x: data.individuals-x.at(individual-id),
    generation: data.duplicates.at(id).generation,
  )
}
#let twin-from-id(data, id) = {
  let twin-individuals = data.twins-individuals.at(id)
  return (
    type: "twin",
    twin: data.twins.at(id),
    id: id,
    individuals: twin-individuals,
    generation: twin-individuals.at(0).generation,
  )
}
#let from-coord(data, coord) = {
  if coord.type == "individual" {
    if "id" in coord {
      return individual-from-id((data, coord.id))
    } else {
      return individual-from-position(data, coord.generation, coord.ind-number)
    }
  } else if coord.type == "union" {
    return union-from-id(data, coord.id)
  } else if coord.type == "children" {
    return children-from-id(data, coord.id)
  } else if coord.type == "duplicate" {
    return duplicate-from-id(data, coord.id)
  } else if coord.type == "twin" {
    return twin-from-id(data, coord.id)
  }
  panic("type is not in ('individual', 'union', 'children', 'duplicate', 'twin')")
}


#let iterate-individuals(data) = {
  let output = ()
  for individual-id in range(data.individuals.len()) {
    output.push(individual-from-id(data, individual-id))
  }
  return output
}
#let iterate-duplicates(data) = {
  let output = ()
  for duplicate-id in range(data.duplicates.len()) {
    output.push(duplicate-from-id(data, duplicate-id))
  }
  return output
}
#let iterate-twins(data) = {
  let output = ()
  for twin-id in range(data.twins.len()) {
    output.push(twin-from-id(data, twin-id))
  }
  return output
}
#let iterate-unions(data) = {
  let output = ()
  for union-id in range(data.unions.len()) {
    output.push(union-from-id(data, union-id))
  }
  return output
}
#let iterate-childrens(data) = {
  let output = ()
  for children-id in range(data.childrens.len()) {
    output.push(children-from-id(data, children-id))
  }
  return output
}

// returns a modified data and duplicates, individuals, maximum-generation, individuals-by-gen, individuals-by-gen-indices, duplicates-individuals, individuals-x, individuals-unions, and individuals-childrens
#let process-individuals(data, contents) = {
  let duplicates = ()
  let individuals = ()
  let maximum-generation = 0
  let individuals-by-gen = ()
  let individuals-by-gen-indices = ()
  let duplicates-individuals = ()
  let individuals-x = ()
  let individuals-unions = ()
  let individuals-childrens = ()

  let individual-index = 0
  for item in contents {
    if item.type in "duplicate" {
      duplicates.push(item)
    }
    if item.type in ("individual", "duplicate") {
      individuals.push(item)
      if item.generation > maximum-generation {
        maximum-generation = item.generation
        for i in range(maximum-generation - individuals-by-gen.len()) {
          individuals-by-gen.push(())
          individuals-by-gen-indices.push(())
        }
      }
      duplicates-individuals.push(none) // regular individuals have it as none
      individuals-x.push(individuals-by-gen.at(item.generation - 1).len())
      individuals-by-gen-indices.at(item.generation - 1).push(individual-index)
      individuals-by-gen.at(item.generation - 1).push(item)
      individuals-unions.push(()) // prepare; will be filled in unions section
      individuals-childrens.push(())
      individual-index += 1
    }
  }

  data = {data; (
    individuals: individuals,
    individuals-by-gen: individuals-by-gen,
    individuals-x: individuals-x,
    individuals-by-gen-indices: individuals-by-gen-indices,
    maximum-generation: maximum-generation,
    duplicates: duplicates,
    duplicates-individuals: duplicates-individuals,
    individuals-unions: individuals-unions,
    individuals-childrens: individuals-childrens,
  )}
  return data
}

#let process-duplicates(data, contents) = {
  let duplicates-individuals = data.duplicates-individuals
  let duplicates-indices = ()

  let individual-index = 0
  for item in contents {
    if item.type == "duplicate" {
      let individual = from-coord(data, parse-id(item.individual))
      duplicates-individuals.at(individual-index) = individual
      duplicates-indices.push(individual-index)
    }
    // increment index for both types
    if item.type in ("individual", "duplicate") {
      individual-index += 1
    }
  }

  data = {data; (
    duplicates-individuals: duplicates-individuals,
    duplicates-indices: duplicates-indices,
  )}
  return data
}

#let process-twins(data, contents) = {
  let twins = ()
  let twins-individuals = ()
  let twins-childrens = ()

  for item in contents {
    if item.type == "twin" {
      twins.push(item)
      let twin-individuals = ()
      for individual-id in item.individuals {
        let individual = from-coord(data, parse-id(individual-id))
        twin-individuals.push(individual)
      }
      let common-generation = twin-individuals.at(0).generation
      for individual in twin-individuals {
        assert(individual.generation == common-generation)
      }
      twins-individuals.push(twin-individuals)
      twins-childrens.push(())
    }
  }

  data = {data; (
    twins: twins,
    twins-individuals: twins-individuals,
    twins-childrens: twins-childrens,
  )}
  return data
}

#let process-unions(data, contents) = {
  let unions = ()
  let unions-individuals = ()
  let individuals-unions = data.individuals-unions
  let unions-childrens = ()

  let union-index = 0
  for item in contents {
    if item.type == "union" {
      unions.push(item)
      let individual-1-data = from-coord(data, parse-id(item.individual-1-id))
      let individual-2-data = from-coord(data, parse-id(item.individual-2-id))
      unions-individuals.push((
        individual-1: individual-1-data,
        individual-2: individual-2-data,
      ))
      individuals-unions.at(individual-1-data.ind-id).push(union-index)
      individuals-unions.at(individual-2-data.ind-id).push(union-index)
      unions-childrens.push(()) // prepare; will be filled in children section
      union-index += 1
    }
  }

  data = {data; (
    unions: unions,
    unions-individuals: unions-individuals,
    individuals-unions: individuals-unions,
    unions-childrens: unions-childrens,
  )}
  return data
}

#let process-childrens(data, contents) = {
  let childrens = ()
  let childrens-parents = ()
  let individuals-childrens = data.individuals-childrens
  let twins-childrens = data.twins-childrens
  let unions-childrens = data.unions-childrens
  let childrens-bounds = ()
  let childrens-children = ()

  let children-index = 0
  for item in contents {
    if item.type == "children" {
      childrens.push(item)
      let parents = from-coord(data, parse-id(item.parents-id))
      childrens-parents.push(parents)
      let children = ()
      let minimum-generation = none
      for child-id in item.children {
        let child = from-coord(data, parse-id(child-id))
        children.push(child)
        if minimum-generation == none or child.generation < minimum-generation {
          minimum-generation = child.generation
        }
        if child.type in ("individual", "duplicate") {
          individuals-childrens.at(child.ind-id).push(children-index)
        } else { // twin
          twins-childrens.at(child.id).push(children-index)
        }

      }
      childrens-bounds.push(minimum-generation)
      childrens-children.push(children)
      if parents.type == "union" {
        unions-childrens.at(parents.id).push(children-index)
      }
      children-index += 1
    }
  }

  data = {data; (
    childrens: childrens,
    childrens-parents: childrens-parents,
    childrens-children: childrens-children,
    childrens-bounds: childrens-bounds,
    individuals-childrens: individuals-childrens,
    twins-childrens: twins-childrens,
    unions-childrens: unions-childrens,
  )}
  return data
}
