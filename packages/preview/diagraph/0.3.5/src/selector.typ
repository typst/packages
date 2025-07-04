/// Skip the current block in the graphs string until the next block
///
/// - graphs (string): the content of the dot file
/// - index (int): the index of the graph in the graphs string
/// -> int: the index of the next block in the graphs string
#let next-block-index(graphs, index) = {
	assert(graphs.at(index) == "{")
	let opened = 1
	while opened > 0 {
		index = index + 1
		if graphs.at(index) == "{" {
			opened = opened + 1
		} else if graphs.at(index) == "}" {
			opened = opened - 1
		}
	}
	return index
}

/// Perform a knuth-morris-pratt search to find the index of the graph name in the graphs string
///
/// - name (string): the name of the graph 
/// - graphs (string): the content of the dot file 
/// - base-index (int): the index to start the search
/// -> int: the index of the graph in the graphs string or -1 if not found
#let kmp-search(name, graphs, base-index) = {
	let j = base-index
	let k = 0
	while j < graphs.len() {
		if graphs.at(j) == "{" {
			j = next-block-index(graphs, j)
			k = 0
			continue
		}
		if name.at(k) == graphs.at(j) {
			j = j + 1
			k = k + 1
			if k == name.len() {
				return j - k
			}
		} else {
			if k == 0 {
				j = j + 1
			} else {
				k = 0
			}
		}
	}
	return -1
}

/// Perform a reverse knuth-morris-pratt search to find the index of the graph keyword in the graphs string
///
/// - name (string): the name of the graph
/// - graphs (string): the content of the dot file
/// - base-index (int): the index to start the search
/// -> int: the index of the graph in the graphs string or -1 if not found
#let reverse-kmp-search(name, graphs, base-index) = {
	let j = base-index
	let k = name.len() - 1
	while j >= 0 {
		if name.at(k) == graphs.at(j) {
			j = j - 1
			k = k - 1
			if k == -1 {
				return j + 1
			}
		} else {
			if k == name.len() - 1 {
				j = j - 1
			} else {
				k = name.len() - 1
			}
		}
	}
	return -1
}

#let next-char(graphs, index, char) = {
	while graphs.at(index) != char {
		index = index + 1
	}
	return index
}

#let select-graph(name, graphs) = {
	let name-index = kmp-search(name, graphs, 0)
	if name-index == -1 {
		return ""
	}
	let graph-keyword-index = reverse-kmp-search("graph", graphs, name-index)
	if graph-keyword-index == -1 {
		return ""
	}
	if graph-keyword-index > 1 and graphs.slice(graph-keyword-index - 2, graph-keyword-index) == "di" {
		graph-keyword-index = graph-keyword-index - 2
	}

	let opening = next-char(graphs, name-index, "{")
	let closing = next-block-index(graphs, opening)
	return graphs.slice(graph-keyword-index, closing + 1)
}
