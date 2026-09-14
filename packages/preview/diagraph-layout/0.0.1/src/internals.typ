#import "../graphviz_interface/protocol.typ": *
#let graphviz = plugin("../graphviz_interface/diagraph.wasm")

#let repr-bytes(data) = {
  for b in data [
    0x#str(b, base: 16),
  ]
}

#let node(name, width: 0.75 * 75pt, height: 0.5 * 75pt, xlabel: none) = {
  if width < 0.01 * 75pt {
    panic("Node width too small, must be at least 0.01 inch (" + str(0.01 * 75) + "pt): " + name)
  }
  if height < 0.01 * 75pt {
    panic("Node height too small, must be at least 0.01 inch (" + str(0.01 * 75) + "pt): " + name)
  }
  if xlabel != none and type(xlabel) != dictionary {
    panic("Node xlabel must be none or a dictionary: " + name)
  }
  if xlabel != none and (not "width" in xlabel or not "height" in xlabel) {
    panic("Node xlabel dictionary must contain width and height keys: " + name)
  }
  (
    type: "node",
    name: name,
    width: width,
    height: height,
    xlabel: xlabel,
  )
}

#let edge(head, tail, label: none, xlabel: none, taillabel: none, headlabel: none, ..args) = {
  if args.pos().len() > 0 {
    panic("Too many arguments for edge: " + head + " -> " + tail)
  }
  if xlabel != none and type(xlabel) != dictionary {
    panic("Edge xlabel must be none or a dictionary: " + head + " -> " + tail)
  }
  if xlabel != none and (not "width" in xlabel or not "height" in xlabel) {
    panic("Edge xlabel dictionary must contain width and height keys: " + head + " -> " + tail)
  }
  if label != none and type(label) != dictionary {
    panic("Edge label must be none or a dictionary: " + head + " -> " + tail)
  }
  if label != none and (not "width" in label or not "height" in label) {
    panic("Edge label dictionary must contain width and height keys: " + head + " -> " + tail)
  }
  if taillabel != none and type(taillabel) != dictionary {
    panic("Edge taillabel must be none or a dictionary: " + head + " -> " + tail)
  }
  if taillabel != none and (not "width" in taillabel or not "height" in taillabel) {
    panic("Edge taillabel dictionary must contain width and height keys: " + head + " -> " + tail)
  }
  if headlabel != none and type(headlabel) != dictionary {
    panic("Edge headlabel must be none or a dictionary: " + head + " -> " + tail)
  }
  if headlabel != none and (not "width" in headlabel or not "height" in headlabel) {
    panic("Edge headlabel dictionary must contain width and height keys: " + head + " -> " + tail)
  }
  (
    type: "edge",
    head: head,
    tail: tail,
    label: label,
    xlabel: xlabel,
    taillabel: taillabel,
    headlabel: headlabel,
    attributes: args.named().pairs().map(a => (key: a.at(0), value: a.at(1)))
  )
}

#let graph-attribute(type, key, value) = {
  let type = if type == "GRAPH" { 0 } else if type == "NODE" { 1 } else if type == "EDGE" { 2 } else {
    panic("Invalid graph attribute type for '" + key + "': expected GRAPH, NODE, or EDGE")
  }
  (
    type: "graph-attribute",
    attr-type: type,
    key: key,
    value: value,
  )
}

#let subgraph(..args) = {
  let result = (
    type: "subgraph",
    nodes: (),
    attributes: ()
  )
  for arg in args.pos() {
    if type(arg) == str {
      result.nodes.push(arg)
    } else {
      panic("Invalid argument type for subgraph: " + repr(arg))
    }
  }
  for (key, value) in args.named().pairs() {
    result.attributes.push((key: key, value: value))
  }
  result
}

#let layout-graph(engine: "dot", directed: false, ..graph) = {
  let pos = graph.pos()
  for n in graph.named().pairs() {
    pos.push(graph-attribute("GRAPH", n.at(0), n.at(1)))
  }
  let nodes-id = (:)
  let input = (
    engine: engine,
    directed: directed,
    nodes: (),
    edges: (),
    attributes: (),
    subgraphs: (),
  )
  for item in pos {
    if item.type == "node" {
      input.nodes.push((
        name: item.name,
        width: item.width,
        height: item.height,
        xlabel: item.xlabel,
      ))
			if item.name in nodes-id {
				panic("Duplicate node name: " + item.name)
			}
      nodes-id.insert(item.name, input.nodes.len() - 1)
    } else if item.type == "edge" {
      let head-id = nodes-id.at(item.head, default: none)
      let tail-id = nodes-id.at(item.tail, default: none)
      if head-id == none {
        panic("Edge references unknown node: " + item.head)
      }
      if tail-id == none {
        panic("Edge references unknown node: " + item.tail)
      }
      input.edges.push((
        tail: item.tail,
        head: item.head,
        label: item.label,
        xlabel: item.xlabel,
        taillabel: item.taillabel,
        headlabel: item.headlabel,
        attributes: item.attributes
      ))
    } else if item.type == "graph-attribute" {
      input.attributes.push((
        for_: item.attr-type,
        key: item.key,
        value: item.value,
      ))
    } else if item.type == "subgraph" {
      input.subgraphs.push((
        nodes: item.nodes,
        attributes: item.attributes
      ))
    } else {
      panic("Unknown graph item type: " + item.type)
    }
  }
  // return input
	let input = encode-Graph(input)
  // return repr-bytes(input)
	let output = graphviz.layout_graph(input)
	if output.at(0) == 1 {
		panic("Graph layout failed:" + str(output.slice(1)))
	}
	decode-Layout(output).at(0)
}


#let engine-list() = {
  let engines = graphviz.engine_list()
  decode-Engines(engines).at(0).engines
}
