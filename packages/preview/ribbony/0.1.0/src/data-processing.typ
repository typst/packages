/* Input Data Processing Functions */
/*
 * There are 3 supported input data formats:
 * 1. Adjacency list: array of (from, to, size, ?([style]: , ..edge-attributes))
 * 2. Adjacency matrix: (matrix: n*n array, ids: array of n node-ids)
 * 3. Adjacency dictionary: ("node-id": outgoingEdges)
 *
 * outgoingEdges = DetailedEdges | SimpleEdges
 * DetailedEdges = array of (to: node-id, size: number, ([style]: , ..edge-attributes))
 * SimpleEdges = a dict: ([to: node-id]: size | array of size)
 *
 * The output of all preprocess-data functions is a dictionary:
 * ([node-id]: DetailedEdges)
 * Meanwhile, add nodes that defined implicitly by being a target of an edge
 */

#let is-adjacency-list = (data) => {
	if (type(data) != array) {
		return false
	}
	// adjacency list is the only array input type, so we don't check further, and can provide more detailed error messages later
	return true
}
#let process-adjancy-list = (data) => {
	let nodes = (:)
	for edge in data {
		assert(type(edge) == array, message: "Expected each edge to be a array")
		assert(edge.len() >= 3, message: "Expected each edge to have at least 3 elements: (from, to, size, ?attrs)")
		let (from, to, size) = (edge.at(0), edge.at(1), edge.at(2))
		let attrs = edge.at(3, default: (:))
		if (nodes.at(from, default: none) == none) {
			nodes.insert(from, ())
		}
		if (nodes.at(to, default: none) == none) {
			nodes.insert(to, ())
		}
		nodes.at(from).push((
			from: from,
			to: to,
			size: size,
			..attrs
		))
	}
	return nodes
}
#let is-adjacency-matrix = (data) => {
	if (type(data) != dictionary) {
		return false
	}
	if (data.at("matrix", default: none) == none or data.at("ids", default: none) == none) {
		return false
	}
	if (type(data.at("matrix")) != array or type(data.at("ids")) != array) {
		return false
	}
	return true
}
#let process-adjacency-matrix = (data) => {
	let (matrix, ids) = data
	let n = matrix.len()
	assert(matrix.len() == n, message: "Expected square adjacency matrix")
	for row in matrix {
		assert(type(row) == array, message: "Expected each row of adjacency matrix to be an array")
		assert(row.len() == n, message: "Expected square adjacency matrix")
	}
	assert(ids.len() == n, message: "Expected ids array length to match adjacency matrix size")
	let nodes = (:)
	for i in range(0, n) {
		let from = ids.at(i)
		nodes.insert(from, ())
		for j in range(0, n) {
			let to = ids.at(j)
			let size = matrix.at(i).at(j)
			if (size > 0) {
				nodes.at(from).push((
					from: from,
					to: to,
					size: size
				))
			}
		}
	}
	return nodes
}
#let process-adjacency-dictionary = (data) => {
	let nodes = (:)
	for (from, edges) in data {
		nodes.insert(from, ())
		assert(type(edges) == dictionary or type(edges) == array, message: "Expected edges to be a dictionary or an array")
		if (type(edges) == dictionary) {
			// SimpleEdges
			for (to, size) in edges {
				let sizes = if (type(size) == array) {
					size
				} else if (type(size) == int or type(size) == float) {
					(size, )
				} else {
					panic("Edge size must be a number or an array of numbers", repr(size))
				}

				if (nodes.at(to, default: none) == none) {
					nodes.insert(to, ())
				}
				for size in sizes {
						nodes.at(from).push((
							from: from,
							to: to,
							size: size
						))
				}
			}
		} else {
			// DetailedEdges
			for edge in edges {
				assert(type(edge) == dictionary, message: "Expected each edge to be a dictionary")
				let (to, size, ..attrs) = edge
				if (nodes.at(to, default: none) == none) {
					nodes.insert(to, ())
				}
				nodes.at(from).push((
					from: from,
					to: to,
					size: size,
					..attrs
				))
			}
		}
	}
	return nodes
}

// Merge duplicated edges and return two adjacency dictionarys in which edges are SimpleEdges
// return (merged-out-edges, merged-in-edges)
// Useful for some types of layouts (e.g. undirected circular layout)
#let merge-duplicated-edges = (nodes) => {
	let merged-out-edges = (:)
	let merged-in-edges = (:)
	for (node-id, properties) in nodes {
		merged-out-edges.insert(node-id, (:))
		merged-in-edges.insert(node-id, (:))
		for (to, size, ..) in properties.edges {
			merged-out-edges.at(node-id).insert(to, merged-out-edges.at(node-id).at(to, default: 0) + size)
		}
		for (from, size, ..) in properties.from-edges {
			merged-in-edges.at(node-id).insert(from, merged-in-edges.at(node-id).at(from, default: 0) + size)
		}
	}
	return (merged-out-edges, merged-in-edges)
}


#let preprocess-data = (
	data,
	aliases,
	categories
) => {
	// Preprocess edges, standarize to DetailedEdges
	if (is-adjacency-list(data)) {
		data = process-adjancy-list(data)
	} else if (is-adjacency-matrix(data)) {
		data = process-adjacency-matrix(data)
	} else {
		data = process-adjacency-dictionary(data)
	}

	// Make edges dictionaries one of the attributes
	for (node-id, edges) in data {
		data.insert(node-id, (
			edges: edges,
			from-edges: ()
		))
	}

	// Add from-edges
	for (node-id, properties) in data {
		for edge in properties.edges {
			let to = edge.to
			data.at(to).from-edges.push(edge)
		}
	}

	// Add id (same as key) and name (alias | id)
	for (node-id, properties) in data {
		data.at(node-id).insert("id", node-id)
		if (aliases.at(node-id, default: none) != none) {
			data.at(node-id).insert("name", aliases.at(node-id))
		} else {
			data.at(node-id).insert("name", node-id)
		}
	}
	// Add category
	for (category-name, node-ids) in categories {
		for node-id in node-ids {
			if (data.at(node-id, default: none) != none) {
				data.at(node-id).insert("category", category-name)
			}
		}
	}
	// Add #id
	let counter = 0
	for (node-id, properties) in data {
		data.at(node-id).insert("number-id", counter)
		counter += 1
	}

	// Add other necessary attributes to nodes
	// in-size and out-size: sum of incoming and outgoing edge sizes
	for (node-id, properties) in data {
		data.at(node-id).insert("in-size", properties.from-edges.map(edge => edge.size).sum(default: 0))
		data.at(node-id).insert("out-size", properties.edges.map(edge => edge.size).sum(default: 0))
	}

	data
}

#let assign-layers = (
	nodes,
	layer-override: (:)
) => {
	let layer-dict = (:)

	let queue = ()
	let visited = (:)
	let max-layer = 0
	for (node-id, properties) in nodes {
		// BFS to assign layers for each component
		if (visited.at(node-id, default: false) == false) {
			queue.push((node-id: node-id, layer: 0))
		}
		let tmp-layer = (:)
		let min-layer = 0
		while (queue.len() > 0) {
			let (node-id, layer) = queue.remove(0)
			if (visited.at(node-id, default: false) == true) {
				continue
			}
			tmp-layer.insert(node-id, layer)
			min-layer = calc.min(min-layer, layer)
			visited.insert(node-id, true)
			for (to, ..) in nodes.at(node-id).edges {
				if (visited.at(to, default: false) == false) {
					queue.push((node-id: to, layer: layer + 1))
				}
			}
			for (from, size) in nodes.at(node-id).from-edges {
				if (visited.at(from, default: false) == false) {
					queue.push((node-id: from, layer: layer - 1))
				}
			}
		}
		// Normalize layers to start from 0
		for (node-id, layer) in tmp-layer {
			let normalized-layer = layer - min-layer
			max-layer = calc.max(max-layer, normalized-layer)
			layer-dict.insert(node-id, normalized-layer)
		}
	}
	// Apply layer override
	for (layer, node-ids) in layer-override {
		layer = int(layer)
		if (not type(node-ids) == array) {
			node-ids = (node-ids, )
		}
		for node-id in node-ids {
			layer-dict.insert(node-id, layer)
			max-layer = calc.max(max-layer, layer)
		}
	}

	// Collect nodes in layers
	let layers = ()
	for i in range(0, max-layer + 1) {
		layers.push(())
	}
	for node-id in nodes.keys() { // keep original order
		let layer = layer-dict.at(node-id)
		layers.at(layer).push(node-id)
	}
	layers = layers.map(layer => layer.sorted(key: (it) => nodes.at(it).number-id))

	return layers
}
