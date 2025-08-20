#import "graphviz_interface/protocol.typ": *
#let plugin = plugin("graphviz_interface/diagraph.wasm")


/// Converts a string containing escape sequences to content.
#let parse-string(s) = {
  let result = []
  let row = ""
  let is-escaped = false

  for cluster in s {
    if is-escaped {
      is-escaped = false

      if cluster == "l" {
        result += align(left, row)
        row = ""
      } else if cluster == "n" {
        result += align(center, row)
        row = ""
      } else if cluster == "r" {
        result += align(right, row)
        row = ""
      } else {
        row += cluster
      }
    } else if cluster == "\\" {
      is-escaped = true
    } else {
      row += cluster
    }
  }

  set block(spacing: 0.65em)
  result + align(center, row)
}

/// Convert a number to a string with a fixed number of digits.
/// The number is padded with zeros on the left if necessary.
#let int-to-string(n, digits, base: 10) = {
  let n-str = str(n, base: base)
  let n-len = n-str.len()
  let zeros = "0" * (digits - n-len)
  zeros + n-str
}

/// Return a buffer in readable format.
#let buffer-repr(buffer) = [
  #repr(array(buffer).map(x => "0x" + int-to-string(x, 2, base: 16)).join(", "))
]

/// COnvert a string to math or text mode
#let convert-label(label, math-mode) = {
  if label == "" {
    return ""
  }
  if math-mode {
    math.equation(eval(mode: "math", label))
  } else {
    parse-string(label)
  }
}

/// Return a formatted label based on its color, font and content.
#let label-format(color, font, fontsize, label) = {
  if label == "" {
    return ""
  }
  set text(fill: rgb(int-to-string(color, 8, base: 16)), bottom-edge: "bounds")
  set text(size: fontsize) if fontsize.pt() != 0
  set text(font: font) if font != ""
  text(label)
}
/// Check that all edges in the overwrite dictionary are present in the encoded label edges.
#let check-overwrite(encoded-label, edge-overwrite) = {
  for to-node in edge-overwrite.keys() {
    if encoded-label.at("edges_infos").find(edge => edge.at("to") == to-node) == none {
      panic("Node \"" + encoded-label.at("name") + "\" does not have an edge to node \"" + to-node + "\"")
    }
  }
}

#let edge-label-format(edge-overwrite, edge-label, color, font, fontsize, name) = {
  let overwrite-list = edge-overwrite.at(edge-label.at("to"), default: none)
  if overwrite-list != none {
    let index = edge-label.at("index")
    if type(overwrite-list) == array and index < overwrite-list.len() {
			let overwrite = overwrite-list.at(index)
			if type(overwrite) != dictionary {
				if name == "label" {
					return overwrite
				}
			} else if name in overwrite {
      	return overwrite.at(name)
			}
    } else if index == 0 {
			if type(overwrite-list) != dictionary {
				if name == "label" {
					return overwrite-list
				}
			} else if name in overwrite-list {
				return overwrite-list.at(name)
			}
    }
  }
  let label-content = edge-label.at(name)
  if label-content == "" {
    return ""
  }
  label-format(color, font, fontsize, convert-label(label-content, edge-label.at(name + "_math_mode")))
}

#let format-edge-labels(encoded-label, edge-overwrite) = {
  let formatted-edge-labels = ()
  for edge-label in encoded-label.at("edges_infos") {
    let font-size = text.size
    if edge-label.at("font_size").pt() != 0 {
      font-size = edge-label.at("font_size")
    }
    let font-name = edge-label.at("font_name").split(",")
    let font-color = edge-label.at("color")

    // panic(edge-label, edge-overwrite)

    formatted-edge-labels.push((
      native: "label" in edge-overwrite,
      label: edge-label-format(edge-overwrite, edge-label, edge-label.at("color"), font-name, font-size, "label"),
      xnative: "xlabel" in edge-overwrite,
      xlabel: edge-label-format(edge-overwrite, edge-label, edge-label.at("color"), font-name, font-size, "xlabel"),
      tailnative: "taillabel" in edge-overwrite,
      taillabel: edge-label-format(
        edge-overwrite,
        edge-label,
        edge-label.at("color"),
        font-name,
        font-size,
        "taillabel",
      ),
      headnative: "headlabel" in edge-overwrite,
      headlabel: edge-label-format(
        edge-overwrite,
        edge-label,
        edge-label.at("color"),
        font-name,
        font-size,
        "headlabel",
      ),
    ))
  }
  formatted-edge-labels
}

/// Get an array of evaluated labels from a graph.
#let get-labels(labels, xlabels, clusters, edges, dot) = {
  let overridden-labels = (
    "dot": dot,
  )
  // panic(buffer-repr(encode-GetGraphInfo(overridden-labels)))
  let encoded-labels = plugin.get_labels(encode-GetGraphInfo(overridden-labels))
  let (graph-labels, _) = decode-GraphInfo(encoded-labels)
  // panic(graph-labels)
  (
    graph-labels.at("labels").map(encoded-label => {
      let font-size = text.size
      if encoded-label.at("font_size").pt() != 0 {
        font-size = encoded-label.at("font_size")
      }
      let font-name = encoded-label.at("font_name").split(",")

      let label = encoded-label.at("label")
      let overwrite = false
      if encoded-label.at("name") in labels {
        overwrite = true
        label = labels.at(encoded-label.at("name"))
      } else if label != "" {
        overwrite = true
        label = convert-label(label, encoded-label.at("math_mode"))
        label = label-format(encoded-label.at("color"), font-name, font-size, label)
      }

      let xlabel = encoded-label.at("xlabel")
      let xoverwrite = false
      if encoded-label.at("name") in xlabels {
        xoverwrite = true
        xlabel = xlabels.at(encoded-label.at("name"))
      } else if xlabel != "" {
        xoverwrite = true
        xlabel = convert-label(xlabel, encoded-label.at("xlabel_math_mode"))
        xlabel = label-format(encoded-label.at("color"), font-name, font-size, xlabel)
      }

      let edges-overwrite = edges.at(encoded-label.at("name"), default: (:))
      check-overwrite(encoded-label, edges-overwrite)
      let edge-labels = format-edge-labels(encoded-label, edges-overwrite)
      (
        overwrite: overwrite,
        label: label,
        xoverwrite: xoverwrite,
        xlabel: xlabel,
        edges_infos: edge-labels,
      )
    }),
    graph-labels.at("cluster_labels").map(encoded-label => {
      let overwrite = false
      let label = encoded-label.at("label")
      if encoded-label.at("name") in clusters {
        label = clusters.at(encoded-label.at("name"))
        overwrite = true
      } else if label != "" {
        let font_name = encoded-label.at("font_name").split(",")
        let font_size = text.size
        if encoded-label.at("font_size").pt() != 0 {
          font_size = encoded-label.at("font_size")
        }
        label = convert-label(label, encoded-label.at("math_mode"))
        label = label-format(encoded-label.at("color"), font_name, font_size, label)
        overwrite = true
      }
      (
        overwrite: overwrite,
        label: label,
      )
    }),
  )
}


#let label-dimensions(color, font, fontsize, label) = {
  if label == "" {
    (
      width: 0pt,
      height: 0pt,
    )
  } else {
    let label = label-format(color, font, fontsize, label)
    measure(label)
  }
}

#let measure-label(edge, name, margin: 0pt) = {
  let dim = measure(edge.at(name))
  (
    width: dim.width + margin,
    height: dim.height + margin,
  )
}

/// Encodes the dimensions of labels into bytes.
#let encode-label-dimensions(labels, overridden-labels, overridden-xlabels) = {
  let edges-margin = 5pt
  labels.map(label => {
    let edges-size = label.at("edges_infos").map(edge => {
      let label = measure-label(edge, "label", margin: edges-margin)
      let xlabel = measure-label(edge, "xlabel", margin: edges-margin)
      let taillabel = measure-label(edge, "taillabel", margin: edges-margin)
      let headlabel = measure-label(edge, "headlabel", margin: edges-margin)
      (
        overwrite: edge.at("label") != "",
        width: label.width,
        height: label.height,
        xoverwrite: edge.at("xlabel") != "",
        xwidth: xlabel.width,
        xheight: xlabel.height,
        tailoverwrite: edge.at("taillabel") != "",
        tailwidth: taillabel.width,
        tailheight: taillabel.height,
        headoverwrite: edge.at("headlabel") != "",
        headwidth: headlabel.width,
        headheight: headlabel.height,
      )
    })

    let dimensions = if label.at("overwrite") {
      measure(label.at("label"))
    } else {
      (width: 0pt, height: 0pt)
    }
    let xdimensions = if label.at("xoverwrite") {
      measure(label.at("xlabel"))
    } else {
      (width: 0pt, height: 0pt)
    }
    (
      overwrite: label.at("label") != "" or label.at("overwrite"),
      xoverwrite: label.at("xlabel") != "" or label.at("xoverwrite"),
      width: dimensions.width,
      height: dimensions.height,
      xwidth: xdimensions.width,
      xheight: xdimensions.height,
      edges_size: edges-size,
    )

  })
}

#let encode-cluster-label-dimensions(clusters-labels-infos, clusters) = {
  clusters-labels-infos.map(label => {
    let dim = measure(label.at("label"))
    (
      width: dim.width,
      height: dim.height,
    )
  })
}

/// Converts any relative length to an absolute length.
#let relative-to-absolute(value, container-dimension) = {
  if type(value) == relative {
    let absolute-part = relative-to-absolute(value.length, container-dimension)
    let ratio-part = relative-to-absolute(value.ratio, container-dimension)
    return absolute-part + ratio-part
  }
  if type(value) == length {
    return value.to-absolute()
  }
  if type(value) == ratio {
    return value * container-dimension
  }
  panic("Expected relative length, found " + str(type(value)))
}

#let debug-rectangle(x, y, width, height) = {
  place(
    top + left,
    dx: x,
    dy: y,
    rect(height: height, width: width, fill: none, stroke: red),
  )
}

/// Renders a graph with Graphviz.
#let render(
  /// A string containing Dot code.
	dot,
  /// Nodes whose name appear in this dictionary will have their label
  /// overridden with the corresponding content. Defaults to an empty
  /// dictionary.
  labels: (:),
	/// Nodes whose name appear in this dictionary will have their xlabel
	/// overridden with the corresponding content. Defaults to an empty
	/// dictionary.
	xlabels: (:),
	/// Nodes whose name appear in this dictionary will have their
	/// edge label overridden with the corresponding content.
	/// Each vale mut be a list of dictionaries, one for each edge.
	/// Each dictionary can have the following keys:
	/// - `label`: the content of the label
	/// - `xlabel`: the content of the xlabel
	/// - `taillabel`: the content of the taillabel
	/// - `headlabel`: the content of the headlabel
	edges: (:),
	/// Cluster names whose name appear in this dictionary will have their
	/// label overridden with the corresponding content. Defaults to an empty
	/// dictionary.
	clusters: (:),
  /// The name of the engine to generate the graph with. Defaults to `"dot"`.
	engine: "dot",
  /// The width of the image to display. If set to `auto` (the default), will be
  /// the width of the generated SVG or, if the height is set to a value, it
  /// will be scaled to keep the aspect ratio.
	width: auto,
  /// The height of the image to display. If set to `auto` (the default), will
  /// be the height of the generated SVG or if the width is set to a value, it
  /// will be scaled to keep the aspect ratio.
	height: auto,
  /// Whether to hide parts of the graph that extend beyond its frame. Defaults
  /// to `true`.
  clip: true,
	/// Display a red rectangle around each label to help with debugging.
	debug: false,
  /// A color or gradient to fill the background with. If set to `none` (the
  /// default), the background will be transparent.
  background: none,
) = {
  set math.equation(numbering: none)

  layout(((width: container-width, height: container-height)) => (
    context {
      let (labels-infos, clusters-labels-infos) = get-labels(
        labels,
        xlabels,
        clusters,
        edges,
        dot,
      )
      // return [#repr(labels-infos)]
      // return [#repr(clusters-labels-infos)]
      let labels-info-count = labels-infos.len()

      let encoded-data = (
        "font_size": text.size.to-absolute(),
        "dot": dot,
        "labels": encode-label-dimensions(labels-infos, labels, xlabels),
        "cluster_labels": encode-cluster-label-dimensions(clusters-labels-infos, clusters),
        "engine": engine,
      )

      // return [#repr(encoded-data)]
      // return [#buffer-repr(encode-renderGraph(encoded-data))]

      let output = plugin.render(encode-renderGraph(encoded-data))

      if output.at(0) != 0 {
        return {
          show: highlight.with(fill: red)
          set text(white)
          raw(block: true, str(output))
        }
      }

      let output = decode-graphInfo(output).at(0)

      // return [#repr(output)]

      // Get SVG dimensions.
      let (width: svg-width, height: svg-height) = measure(image.decode(output.at("svg"), format: "svg"))

      let final-width = if width == auto {
        svg-width
      } else {
        relative-to-absolute(width, container-width)
      }
      let final-height = if height == auto {
        svg-height
      } else {
        relative-to-absolute(height, container-height)
      }

      if width == auto and height != auto {
        let ratio = final-height / svg-height
        final-width = svg-width * ratio
      } else if width != auto and height == auto {
        let ratio = final-width / svg-width
        final-height = svg-height * ratio
      }
      // Rescale the final image to the desired size.
      show: block.with(
        width: final-width,
        height: final-height,
        clip: clip,
        breakable: false,
      )

      set align(top + left)

      show: scale.with(
        origin: top + left,
        x: final-width / svg-width * 100%,
        y: final-height / svg-height * 100%,
      )

      // Construct the graph and its labels.
      show: block.with(width: svg-width, height: svg-height, fill: background)

      // Display SVG.
      image.decode(
        output.at("svg"),
        format: "svg",
        width: svg-width,
        height: svg-height,
      )

      let place-label(dx, dy, label) = {
        let dimensions = measure(label)
        place(
          top + left,
          dx: dx - dimensions.width / 2,
          dy: final-height - dy - dimensions.height / 2 - (final-height - svg-height),
          label,
        )
        if debug {
          debug-rectangle(
            dx - dimensions.width / 2,
            final-height - dy - dimensions.height / 2 - (final-height - svg-height),
            dimensions.width,
            dimensions.height,
          )
        }
      }

      let place-edge-label(dx, dy, name, edge-info) = {
        if edge-info.at(name) == "" {
          return
        }
        place-label(
          dx,
          dy,
          edge-info.at(name),
        )
      }

      // Place labels.
      for (label-info, label-coordinates) in labels-infos.zip(output.at("labels")) {
        for (edge-info, edge-coordinates) in label-info.at("edges_infos").zip(label-coordinates.at("edges")) {
          place-edge-label(
            edge-coordinates.at("x"),
            edge-coordinates.at("y"),
            "label",
            edge-info,
          )
          place-edge-label(
            edge-coordinates.at("xx"),
            edge-coordinates.at("xy"),
            "xlabel",
            edge-info,
          )
          place-edge-label(
            edge-coordinates.at("headx"),
            edge-coordinates.at("heady"),
            "headlabel",
            edge-info,
          )
          place-edge-label(
            edge-coordinates.at("tailx"),
            edge-coordinates.at("taily"),
            "taillabel",
            edge-info,
          )
        }

        if label-info.at("overwrite") {
          place-label(
            label-coordinates.at("x"),
            label-coordinates.at("y"),
            label-info.at("label"),
          )
        }
        if label-info.at("xoverwrite") {
          place-label(
            label-coordinates.at("xx"),
            label-coordinates.at("xy"),
            label-info.at("xlabel"),
          )
        }
      }


      for (clusters-infos, cluster-coordinates) in clusters-labels-infos.zip(output.at("cluster_labels")) {
        if clusters-infos.at("overwrite") {
          place-label(
            cluster-coordinates.at("x"),
            cluster-coordinates.at("y"),
            clusters-infos.at("label"),
          )
        }
      }
    }
  ))
}

#let engine-list() = {
	let list = plugin.engine_list()
  let (engines, _) = decode-Engines(plugin.engine_list())
	engines
}