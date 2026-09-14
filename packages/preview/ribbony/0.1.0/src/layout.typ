#import "@preview/cetz:0.4.2"

#import "./data-processing.typ": assign-layers, merge-duplicated-edges
#import "./ribbon-stylizer.typ": edge-overriding-styles
#import "./utils.typ"

#let auto-linear = (
	layer-gap: 2,
	node-gap: 1,
	node-width: 0.25,
	base-node-height: 3,
	min-node-height: 0.1,
	centerize-layer: false,
	vertical: false,
	layers: (:),
	radius: 2pt,
	curve-factor: 0.3,
) => {
	let layer-override = layers
	( layouter: (nodes) => {
		// Calculate layers for each node
		let layers = assign-layers(nodes, layer-override: layer-override)

		for (layer-index, layer) in layers.enumerate() {
			for node-id in layer {
				nodes.at(node-id).insert("layer", layer-index)
			}
		}
		// node size=max(in-size, out-size)
		for (node-id, properties) in nodes {
			let node-size = calc.max(properties.in-size, properties.out-size)
			nodes.at(node-id).insert("size", node-size)
		}
		// Give widths
		for (node-id, properties) in nodes {
			nodes.at(node-id).insert("width", node-width)
		}
		// Give heights
		let max-node-size = 0
		for (node-id, properties) in nodes {
			max-node-size = calc.max(max-node-size, properties.size)
		}
		for (node-id, properties) in nodes {
			let node-size = properties.size
			let node-height = calc.max(node-size / max-node-size * base-node-height, min-node-height)
			nodes.at(node-id).insert("height", node-height)
		}

		// Give initial x positions
		for (node-id, properties) in nodes {
			let layer = properties.layer
			let x = layer * (node-width + layer-gap) + node-width / 2
			nodes.at(node-id).insert("x", x)
		}
		// Assign initial y positions based on node-gap
		let layer-assign-y-positions = (nodes, layer) => {
			let offset = 0.0
			for node-id in layer {
				let height = nodes.at(node-id).height
				nodes.at(node-id).insert("y", offset - height / 2)
				offset -= height + node-gap
			}
			nodes
		}
		for layer in layers {
			nodes = layer-assign-y-positions(nodes, layer)
		}

		/*
			A node receives forces from:
				- attraction to every connected nodes
			Nodes have rigid constraints:
				- nodes in the same layer must have at least node-gap distance
		*/
		let calculate-attraction-forces = (nodes) => {
			let forces = (:)
			for (node-id, properties) in nodes {
				forces.insert(node-id, 0.0)
			}

			for (node-id, properties) in nodes {
				let y1 = properties.y

				for to in properties.edges.map(edge => edge.to).dedup() {
					let y2 = nodes.at(to).y
					let dy = y2 - y1
					let dx = layer-gap
					let dist = calc.sqrt(dx * dx + dy * dy)
					let theta = calc.atan2(dy, dx)
					let force = dist * calc.cos(theta) * 0.5
					forces.insert(node-id, forces.at(node-id) + force)
					forces.insert(to, forces.at(to) - force)
				}
			}

			return forces
		}

		let enforce-rigid-min-gap = (nodes, layers) => {
			let max-iterations = 15
			let nodes-new = nodes

			for iter in range(0, max-iterations) {
				let violations = false

				for layer in layers {
					for i in range(0, layer.len() - 1) {
						let node-id1 = layer.at(i)
						let node-id2 = layer.at(i + 1)
						let y1 = nodes-new.at(node-id1).y
						let h1 = nodes-new.at(node-id1).height
						let y2 = nodes-new.at(node-id2).y
						let h2 = nodes-new.at(node-id2).height

						let bottom1 = y1 - h1 / 2
						let top2 = y2 + h2 / 2
						let current-gap = bottom1 - top2

						if current-gap < node-gap {
							violations = true
							let violation = node-gap - current-gap
							// Push them apart equally
							nodes-new.at(node-id1).insert("y", nodes-new.at(node-id1).y + violation / 2)
							nodes-new.at(node-id2).insert("y", nodes-new.at(node-id2).y - violation / 2)
						}
					}
				}

				if not violations { break }
			}

			return nodes-new
		}

		// Resolve physical system
		let iterations = 30
		let alpha = 0.1

		for i in range(1, iterations) {
			let nodes-new = nodes

			let forces = calculate-attraction-forces(nodes)

			// Apply forces
			for (node-id, properties) in nodes {
				let y = properties.y
				let force = forces.at(node-id)
				y += force * alpha
				nodes-new.at(node-id).insert("y", y)
				nodes-new.at(node-id).insert("force", force)
			}

			nodes = enforce-rigid-min-gap(nodes-new, layers)
		}

		// Center each layer to y=0
		if (centerize-layer) {
			for layer in layers {
				let min-y = 0.0
				let max-y = 0.0
				for node-id in layer {
					let y = nodes.at(node-id).y
					let height = nodes.at(node-id).height
					min-y = calc.min(min-y, y - height / 2)
					max-y = calc.max(max-y, y + height / 2)
				}
				let layer-height = max-y - min-y
				let offset = layer-height / 2 + min-y

				for node-id in layer {
					let y = nodes.at(node-id).y
					nodes.at(node-id).insert("y", y - offset)
				}
			}
		}

		// Normalize y positions
		let min-y = 99999999
		for (node-id, properties) in nodes {
			let y = properties.y
			let height = properties.height
			min-y = calc.min(min-y, y - height / 2)
		}
		for (node-id, properties) in nodes {
			let y = properties.y
			nodes.at(node-id).insert("y", y - min-y)
		}

		return nodes
	}, drawer: (nodes, ribbon-stylizer, label-drawer) => {
		cetz.canvas({
			import cetz.draw: *

			if (vertical) {
				set-transform(cetz.matrix.mul-mat(
					cetz.matrix.transform-rotate-z(90deg),
					cetz.matrix.transform-scale((1, -1))
				))
			}

			let acc-out-size = (:)
			let acc-in-size = (:)
			for (node-id, properties) in nodes {
				let (x, y, width, height) = properties
				let node-name = node-id + "_node";

				rect(
                    name: node-name,
					(rel: (0, -radius / 2), to: (x - width / 2, y - height / 2)),
					(rel: (0, radius / 2), to: (x + width / 2, y + height / 2)),
					fill: properties.color,
					stroke: none,
					radius: radius
				)

				// label
                if (label-drawer != none) {
                    on-layer(
                        1,
                        {
                            label-drawer(
                                node-name,
                                properties,
                                layer-gap: layer-gap,
                                node-gap: node-gap,
                                node-width: node-width,
                                base-node-height: base-node-height,
                                vertical-layout: vertical
                            )
                        }
                    )
                }

				// sort ribbons first by slope to prevent crossing
				let slopes = (:)
				for to in properties.edges.map(edge => edge.to).dedup() {
					slopes.insert(
						to,
						calc.atan2((nodes.at(to).y - y), (nodes.at(to).x - x))
					)
				}
				let edges = properties.edges.sorted(key: it => slopes.at(it.to))

				// ribbons
				for edge in edges {
                    let (to, size, ..) = edge
					let to-properties = nodes.at(to)
					let top-left = (x + width / 2, y + height / 2 - acc-out-size.at(node-id, default: 0) / properties.size * height)
					let bottom-left = (top-left.at(0), top-left.at(1) - size / properties.size * height)
					let top-right = (to-properties.x - to-properties.width / 2, to-properties.y + to-properties.height / 2 - acc-in-size.at(to, default: 0) / to-properties.size * to-properties.height)
					let bottom-right = (top-right.at(0), top-right.at(1) - size / to-properties.size * to-properties.height)
					acc-out-size.insert(node-id, acc-out-size.at(node-id, default: 0) + size)
					acc-in-size.insert(to, acc-in-size.at(to, default: 0) + size)

					let ribbon-width = calc.min(top-left.at(1) - bottom-left.at(1), top-right.at(1) - bottom-right.at(1))

					let bezier-top-control-1 = utils.point-translate(top-left, (curve-factor * (top-right.at(0) - top-left.at(0)), 0))
					let bezier-top-control-2 = utils.point-translate(top-right, (-curve-factor * (top-right.at(0) - top-left.at(0)), 0))
					let bezier-bottom-control-1 = utils.point-translate(bottom-left, (curve-factor * (bottom-right.at(0) - bottom-left.at(0)), 0))
					let bezier-bottom-control-2 = utils.point-translate(bottom-right, (-curve-factor * (bottom-right.at(0) - bottom-left.at(0)), 0))
					merge-path(
                        ..utils.dict-merge(
						    ribbon-stylizer(edge, properties.color, to-properties.color, nodes.at(node-id), nodes.at(to), angle: if (vertical) { 90deg } else { 0deg }),
                            edge-overriding-styles(edge, nodes)
                        ),
						{
							bezier(top-left, top-right, bezier-top-control-1, bezier-top-control-2)
							line(top-right, bottom-right)
							bezier(bottom-right, bottom-left, bezier-bottom-control-2, bezier-bottom-control-1)
							line(bottom-left, top-left)
						}
					)
				}

				// forces
				let force = properties.at("force", default: 0)
				if (force != 0) {
					let sign = if (force > 0) { 1 } else { -1 }
					let len = calc.min(calc.abs(force), 1)
					// line((x, y), (x, y + len * sign), stroke: red, stroke-width: 0.05, mark: (end: ">"))
				}
			}
		})

	})
}

#let circular = (
	radius: 4,
	node-width: 0.5,
	node-gap: 1deg,
	angle-offset: 0deg,
	directed: false,
) => {
	(layouter: (nodes) => {
		// node size=in-size+out-size by default
		for (node-id, properties) in nodes {
			let node-size = if (directed) { properties.in-size + properties.out-size } else { properties.out-size }
			nodes.at(node-id).insert("size", node-size)
		}
		// Place all node on a ring (only 1 layer)
		let sum = 0
		for (node-id, properties) in nodes {
			sum += properties.size
		}
		sum /= 1 - (node-gap * nodes.keys().len() / 360deg)

		let angle = angle-offset + 90deg
		for (node-id, properties) in nodes {
			let node-size = properties.size
			let node-arc = (node-size / sum) * 360deg
			nodes.at(node-id).insert("angle", angle + node-arc / 2)
			nodes.at(node-id).insert("arc", node-arc)
			angle += node-arc + node-gap
		}

		return nodes
	}, drawer: (nodes, ribbon-stylizer, label-drawer) => {
		cetz.canvas({
			import cetz.draw: *

			// out size acculates from 0, in size acculates from total size
			let in-acc-size = (:)
			let out-acc-size = (:) // if undirected, only use out-acc-size
			let drawn = (:) // drawn[from][to] = bool, for drawing undirected edges only once

			// if undirected, we combine all out and in edges and use this instead
			let (merged-out-edges, merged-in-edges) = merge-duplicated-edges(nodes)

			for (node-id, properties) in nodes {
				let angle = properties.angle
				let node-arc = properties.arc
				let width = node-width

				let inner-left = utils.polar-to-cartesian(radius, angle - node-arc / 2)
				let inner-center = utils.polar-to-cartesian(radius, angle)
				let inner-right = utils.polar-to-cartesian(radius, angle + node-arc / 2)
				let outer-left = utils.polar-to-cartesian(radius + width, angle - node-arc / 2)
				let outer-center = utils.polar-to-cartesian(radius + width, angle)
				let outer-right = utils.polar-to-cartesian(radius + width, angle + node-arc / 2)

				let node-name = node-id + "_node";

				merge-path(
                    name: node-name,
					fill: properties.color,
					stroke: none,
					{
						arc-through(inner-left, inner-center, inner-right)
						line(inner-right, outer-right)
						arc-through(outer-right, outer-center, outer-left)
						line(outer-left, inner-left)
					}
				)

                // label
                if (label-drawer != none) {
                    on-layer(
                        1,
                        {
                            label-drawer(
                                node-name,
                                properties,
                                radius: radius,
                                node-width: node-width,
                                node-gap: node-gap,
                                angle-offset: angle-offset,
                                directed: directed,
                            )
                        }
                    )
                }

				// ribbons
				for edge in if (not directed) { merged-out-edges.at(node-id).keys()} else { properties.edges } {
                    let to = if (not directed) { edge } else { edge.to }
                    let out-edge-size = if (not directed) { merged-out-edges.at(node-id).at(to) } else { edge.size }

					if (not directed and (
						drawn.at(node-id, default: (:)).at(to, default: false) or
						drawn.at(to, default: (:)).at(node-id, default: false)
					)) {
						continue
					}


					let to-properties = nodes.at(to)

					let in-edge-size = if (directed) { out-edge-size } else {
						merged-in-edges.at(node-id).at(to, default: 0)
					}

					let from-acc-size = out-acc-size.at(node-id, default: 0)
					let to-acc-size = if (directed) {in-acc-size.at(to, default: to-properties.size) }
										else { out-acc-size.at(to, default: 0) }
					let from-start-angle = angle - node-arc / 2 + (from-acc-size / properties.size * node-arc)
					let from-end-angle = angle - node-arc / 2 + ((from-acc-size + out-edge-size) / properties.size * node-arc)
					let to-start-angle = to-properties.angle - to-properties.arc / 2 + ((to-acc-size - in-edge-size) / to-properties.size * to-properties.arc)
					let to-end-angle = to-properties.angle - to-properties.arc / 2 + (to-acc-size / to-properties.size * to-properties.arc)
					if (not directed) {
						to-start-angle = to-properties.angle - to-properties.arc / 2 + (to-acc-size / to-properties.size * to-properties.arc)
						to-end-angle = to-properties.angle - to-properties.arc / 2 + ((to-acc-size + in-edge-size) / to-properties.size * to-properties.arc)
						if (drawn.at(node-id, default: none) == none) { drawn.insert(node-id, (:)) }
						drawn.at(node-id).insert(to, true)
						if (drawn.at(to, default: none) == none) { drawn.insert(to, (:)) }
						drawn.at(to).insert(node-id, true)
					}

					let from-left = utils.polar-to-cartesian(radius, from-start-angle)
					let from-center = utils.polar-to-cartesian(radius, (from-start-angle + from-end-angle) / 2)
					let from-right = utils.polar-to-cartesian(radius, from-end-angle)
					let to-left = utils.polar-to-cartesian(radius, to-start-angle)
					let to-center = utils.polar-to-cartesian(radius, (to-start-angle + to-end-angle) / 2)
					let to-right = utils.polar-to-cartesian(radius, to-end-angle)

					out-acc-size.insert(node-id, from-acc-size + out-edge-size)
					if (directed) {
						in-acc-size.insert(to, to-acc-size - in-edge-size)
					} else if (node-id != to) {
						out-acc-size.insert(to, to-acc-size + in-edge-size)
					}

                    let structured-edge = if (not directed) {
                        (from: node-id, to: to, size: (out-edge-size, in-edge-size))
                    } else {
                        edge
                    }

					merge-path(
                        ..utils.dict-merge(
						    ribbon-stylizer(
                                structured-edge,
                                properties.color, to-properties.color, nodes.at(node-id), nodes.at(to),
                                angle: -calc.atan2(to-center.at(0) - from-center.at(0), to-center.at(1) - from-center.at(1))
                            ),
                            edge-overriding-styles(structured-edge, nodes)
                        ),
						{
                            if (out-edge-size > 0) {
							    arc-through(from-left, from-center, from-right)
                            }
							bezier(from-right, to-left, (0, 0))
                            if (in-edge-size > 0) {
							    arc-through(to-left, to-center, to-right)
                            }
							bezier(to-right, from-left, (0, 0))
						}
					)
				}
			}
		})
	})
}
