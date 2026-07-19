
#let resolve-defaults(nodes, defaults) = if defaults == none { nodes } else {
	nodes.map(node => if type(node) == content {node} else {
		defaults + node
	})
}
#let remove-nones(dict) = {
	let _ = for (key, value) in dict {
		if value == none {
			dict.remove(key)
		}
	};
	dict
}
#let remove-autos(dict) = {
	let _ = for (key, value) in dict {
		if value == auto {
			let _ = dict.remove(key);
		}
	};
	dict
}

#let stroke-to-dict(object) = if type(object) == stroke {
	remove-autos((
		paint:       object.paint,
		dash:        object.dash,
		thickness:   object.thickness,
		cap:         object.cap,
		join:        object.join,
		miter-limit: object.miter-limit,
	))
} else if type(object) == dictionary {
	object
} else {
	panic(type(object))	
}


#let new-node-info(
	content,
	n-children: 0,
	layer-spacing: none,
	child-spacing: none,
	branch-stroke: none,
	align: none,
	color: none,
) = {
	let params = remove-nones((
		layer-spacing: layer-spacing,
		child-spacing: child-spacing,
		branch-stroke: branch-stroke,
		align: align,
	))
	let node-info = (
		tag: content,
		n-children: n-children
	)
	node-info + params
}


#let render-node(node, children) = {
	let child-spacing = node.child-spacing.to-absolute()
	let (branch-stroke, color) = node
	// Goal: align the middle of "tag" node with the middle of the root of the first child and the root of the last child (in case of binary tree, this guarantees symmetry)
	// NB: This is not the same as center alignment: if last child is heavily right branching, its root will to the left compared to its center.
	// 
	//
	// Schematically:
	//
	//         [-----+-----]                    <- parent tag
	//               ∧
	//               |
	//   rootchild1  v    rootlastchild
	//      +--------°-----------+               <- ° marks 'mid': the middle point between root of the first child and the root of the last child
	//      |                    |
	//      v                    v
	///
	//   [--^--]..[--^--]..[-----^---------]     <- children nodes (^ marks positition of root node in each child)
	//    
	//   |----------->  (from-left-edge-to-mid)   
	//   |---->         (tag_from-left-edge-of-children-to-left-edge-of-tag)



	// First we compute the position of the the mid point of first and last root wrt to left edge of children
	let n-children = children.len()
	let children-width = children.map(c => measure(c.content).width).sum() + (n-children - 1) * child-spacing

	let first-child = children.first()
	let last-child  = children.last()
	let last-child-width = measure(last-child.content).width
	let first-root-x-position = first-child.root-x-position
	let last-root-x-position  = last-child.root-x-position

	let from-left-edge-to-root-last-child = children-width - last-child-width + last-root-x-position
	let from-left-edge-to-root-first-child = first-root-x-position
	let from-left-edge-to-mid = (from-left-edge-to-root-first-child + from-left-edge-to-root-last-child) / 2


	// Next, we compute from-left-edge-of-children-to-left-edge-of-tag, i.e. how much space (in signed units) there is between the left edge of the children and the left edge of the parent tag
	// If positive, it means parent_tag's left edge is to the right of the children's left edge.
	// If negative, it means parent_tag's left edge is to the left of the children's left edge.
	let tag = node.tag
	let node-align = node.align
	if node-align != none {
		tag = align(node-align, tag)
	}
	if color != none and tag != none {
		tag = text(color, tag)
	}
	let tag-empty = tag == none
	let tag-width = measure(tag).width
	let from-left-edge-of-children-to-left-edge-of-tag = from-left-edge-to-mid - tag-width / 2

	// We now create the left-to-right child stack adding the edges to the root node
	let child-stack = stack(
		dir: ltr,
		spacing: child-spacing,
		.. children.map(c => c.content)
	)

	let layer-spacing = node.layer-spacing
    let hi = - layer-spacing + if tag-empty { 0em } else { 0.3em }


	// To this stack we add edges for each child node to the root node
	let acc = 0em
	let los = ()
	let edges = for i in array.range(n-children) {
		let (content: child-content, root-x-position, tag-empty) = children.at(i)
		let width = measure(child-content).width

		let lo = if tag-empty { 0em } else { -0.3em }
		los.push(lo)



		// panic(type(stroke-to-dict(branch-stroke)))
		let stroke = if color != none { (paint : color) } else { (:) } + stroke-to-dict(branch-stroke) 
		place(line(
			stroke:  stroke, 
			start:  (acc + root-x-position, lo), 
			end:    (tag-width / 2 + from-left-edge-of-children-to-left-edge-of-tag, hi)
		))
		acc += width + child-spacing
	}
	let child_stack = edges + child-stack

	// before we stack the tag on top of the children (represented by child-stack), we pad either one of them to meet our alignment constraint
	let root-x-position = none
	if from-left-edge-of-children-to-left-edge-of-tag > 0em {
		tag = pad(left: from-left-edge-of-children-to-left-edge-of-tag, tag)
		root-x-position = from-left-edge-to-mid
	}
	else {
		child-stack = pad(left: -from-left-edge-of-children-to-left-edge-of-tag, child-stack)
		root-x-position = tag-width / 2
	}




	(
		content: stack(
			dir: ttb, 
			spacing: layer-spacing, 
			align(left, tag), 
			align(left, child_stack)
		),
		root-x-position: root-x-position,
		tag-empty: tag-empty,
	)
}
