#import "intern.typ"

#let default-layer-spacing = 3em
#let default-child-spacing = 1em
/// Default values for the parameters of @tree. 
///
/// *NB:* Because Typst is pure, changing these values will not change how trees are rendered. @global-defaults is only provided for your information.
/// To change the defaults globally, rename `render` (name shadowing):
///
/// ```typst
/// #let render = render.with(defaults: new-defaults)
/// /* rest of document */
/// ```
#let global-defaults = (
	layer-spacing: default-layer-spacing,
	child-spacing: default-child-spacing,
	branch-stroke: (thickness: 0.75pt),
	color: none,
	align: none,
)

/// Creates a tree from children trees or contents. The root may be labelled with an optional tag (label for the root node). This function returns a data structure that can serve as argument for `render` or for subsequent invocation of `tree`.
/// -> tree
#let tree(
	/// Label for the root node. If none, no label will be rendered.
	/// -> content | none
	tag: none,
	/// Children of the root node
	/// -> content | tree
	.. children,
	/// Distance between this root node and its immediate children. If none, a default value is used.
	///
	/// #let tree = lingotree.tree(tag: [A], [B], [C])
	/// 
	/// #table(
	///   columns: (1fr, 1fr, 1fr),
	///   stroke: none,
	///   align: center,
	///   [*`layer-spacing: 1em`*],
	///   [*`layer-spacing: 2em`*],
	///   [*`layer-spacing: 3em`*],
	///   box(lingotree.render(tree, defaults: (layer-spacing: 1em))),
	///   box(lingotree.render(tree, defaults: (layer-spacing: 2em))),
	///   box(lingotree.render(tree, defaults: (layer-spacing: 3em))),
	/// )
	///
	/// -> length | none
	layer-spacing: none,
	/// Distance between consecutive children of the root node. If none, a default value is used.
	///
	/// #let tree = lingotree.tree(tag: [A], [B], [C])
	/// 
	/// #table(
	///   columns: (1fr, 1fr, 1fr),
	///   stroke: none,
	///   align: center,
	///   [*`child-spacing: 0em`*],
	///   [*`child-spacing: 2em`*],
	///   [*`child-spacing: 5em`*],
	///   box(lingotree.render(tree, defaults: (layer-spacing: 2em, child-spacing: 0em))),
	///   box(lingotree.render(tree, defaults: (layer-spacing: 2em, child-spacing: 2em))),
	///   box(lingotree.render(tree, defaults: (layer-spacing: 2em, child-spacing: 5em))),
	/// )
	///
	/// -> length | none
	child-spacing: none,
	/// Stroke with which to draw the edge between the root node and its immediate children
	/// 
	/// #let tree = lingotree.tree(tag: [A], [B], [C])
	/// 
	/// #table(
	///   columns: (1fr, 1fr),
	///   stroke: none,
	///   align: center,
	///   [*`stroke: blue + 3pt`*],
	///   [*`stroke: (dash: "dashed")`*],
	///   box(lingotree.render(tree, defaults: (layer-spacing: 2em, branch-stroke: blue + 3pt))),
	///   box(lingotree.render(tree, defaults: (layer-spacing: 2em, branch-stroke: (dash: "dashed")))),
	/// )
	/// 
	/// -> stroke | color | length | dictionary | none
	branch-stroke: none,
	/// Color of the edges, the tag and the leaf nodes. If none, the edges will be black and the content will have its default color.
	///
	/// #align(center, box(lingotree.render(lingotree.tree(tag: [A], [B], [C], defaults: (color: blue, layer-spacing: 2em)))))
	///
	/// -> color | none
	color: none,
	/// Alignments for the content of the tags and the content.
	///
	/// #let tree = lingotree.tree(tag: [VP\ likes carrots], [V\ likes], [NP\ carrots])
	/// 
	/// #table(
	///   columns: (1fr, 1fr, 1fr),
	///   stroke: none,
	///   align: center,
	///   [*`align: left`*],
	///   [*`align: center`*],
	///   [*`align: right`*],
	///   box(lingotree.render(tree, defaults: (align: left))),
	///   box(lingotree.render(tree, defaults: (align: center))),
	///   box(lingotree.render(tree, defaults: (align: right))),
	/// )
	///
	/// -> alignment | none
	align: none,
	/// This dictionary can take any of the value for the optional parameters above.
	/// When a parameter value is specified here, it applies to this node and _all_ of its descendants.
	///
	/// #let tree = lingotree.tree.with(
	/// 	tag: [DP],
	/// 	lingotree.tree(
	/// 		[a],
	///			lingotree.tree(
	///				[nice],
	/// 			[person],
	///			)
	/// 	),
	/// 	[came]
	/// )
	/// 
	/// #table(
	///   columns: (1fr, 1fr),
	///   stroke: none,
	///   align: center,
	///   [*`defaults: (layer-spacing: 1em)`*],
	///   [*`layer-spacing: 1em`*],
	///   box(lingotree.render(tree(defaults: (layer-spacing: 1em)))),
	///   box(lingotree.render(tree(layer-spacing: 1em)))
	/// )
	///
	/// -> dictionary | none
	defaults: none,
	// if filled, defaults will be used for every node dominated by this one
	// if none, inherit defaults from parent
	// if none and tree is root, defaults is given by the `render' function
) = {
	// nodes are represented in reverse Polish notation
	// So, to merge multiple trees, we turn every content node (leaf) into a node of its own
	// we concatenate the result
	// (node1, node2, parentOf12) content (node3, node4, node5, parentOf345)
	// =>
	// (node1, node2, parentOf12, content, node3, node4, node5, parentOf345)
	// =>
	// (node1, node2, parentOf12, content, node3, node4, node5, parentOf345, parentOfThemAll)
	let flattened-nodes = children
		.pos()
		.map(c => 
			if type(c) == content 
			{ 
				(intern.new-node-info(c),)
			} 
			else {
				c
			}
		)
		.join()


	let new-node = intern.new-node-info(
		tag,
		n-children: children.pos().len(),
		layer-spacing: layer-spacing,
		child-spacing: child-spacing,
		branch-stroke: branch-stroke,
		align: align,
		color: color,
	)
	flattened-nodes.push(new-node)
	intern.resolve-defaults(flattened-nodes, defaults)
}


/// Renders a tree
/// -> content
#let render(
	/// Tree to render
	/// -> tree
	tree,
	/// A dictionary overriding default parameters of rendering, cf @tree for a list of parameters and explanation.
	/// -> dictionary
	defaults: global-defaults,
) = context {
	// First, we fill in all values for layer-spacing and child-spacing if they haven't been specified by intermediate nodes
	let tree = intern.resolve-defaults(tree, global-defaults + defaults)

	// Second, we define series of stacks
	let stack = ()
	// Each element of the stack meets the template:
	// (
	//     content         : ...,
	//     root-x-position : ...,
	//     tag-empty       : ..., // whether the node is an empty tag or not
	// )

	for node in tree {
		if type(node) == dictionary {
			let n-children = node.n-children

			if n-children == 0 {
				let (tag, color, align: node-align) = node
				if node-align != none {
					tag = align(node-align, tag)
				}
				if color != none {
					tag = text(color, tag)
				}
				let width = measure(tag).width
				stack.push((
					content:         tag,
					root-x-position: width / 2,
					tag-empty:       false,
				))
			}
			else {

				let children = stack.slice(-n-children)
				for _ in array.range(n-children) {
					let _ = stack.pop();
				};


				let rendered-node = intern.render-node(node, children);


				stack.push(rendered-node);
			}

		}
		else {
			panic("Wrong argument type");
		}
	};

	return stack.first().content
}

