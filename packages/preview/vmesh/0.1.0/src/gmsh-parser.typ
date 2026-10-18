// gmsh-parser.typ
// Parses Gmsh .msh files (MSH 2.2 ASCII format)

#let parse-msh(msh-string) = {
  let lines = msh-string.split("\n").map(l => l.trim())
  
  let nodes = (:)
  let elements = ()
  
  let in-nodes = false
  let in-elements = false
  
  for line in lines {
    if line == "" { continue }
    
    if line == "$Nodes" or line == "$ParametricNodes" {
      in-nodes = true
      continue
    }
    if line == "$EndNodes" or line == "$EndParametricNodes" {
      in-nodes = false
      continue
    }
    if line == "$Elements" {
      in-elements = true
      continue
    }
    if line == "$EndElements" {
      in-elements = false
      continue
    }
    
    if in-nodes {
      // Node format: node_id x y z
      let parts = line.split(regex("\\s+")).filter(p => p != "")
      if parts.len() >= 4 {
        let id = str(int(parts.at(0)))
        let x = float(parts.at(1))
        let y = float(parts.at(2))
        let z = float(parts.at(3))
        nodes.insert(id, (x, y, z))
      }
    }
    
    if in-elements {
      // Element format: elm_id elm_type num_tags <tags> node1 node2 ...
      let parts = line.split(regex("\\s+")).filter(p => p != "")
      if parts.len() >= 3 {
        let elm-id = int(parts.at(0))
        let elm-type = int(parts.at(1))
        let num-tags = int(parts.at(2))
        let node-start-idx = 3 + num-tags
        
        let physical-tag = 0
        let geometrical-tag = 0
        
        if num-tags >= 1 {
          physical-tag = int(parts.at(3))
        }
        if num-tags >= 2 {
          geometrical-tag = int(parts.at(4))
        }
        
        if parts.len() > node-start-idx {
          let node-ids = parts.slice(node-start-idx)
          elements.push((
            id: elm-id,
            type: elm-type,
            physical-tag: physical-tag,
            geometrical-tag: geometrical-tag,
            nodes: node-ids
          ))
        }
      }
    }
  }
  
  return (nodes: nodes, elements: elements)
}
