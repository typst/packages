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
  set text(font: font) if font != ("",)
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

#let edge-label-format(math-mode, edge-overwrite, edge-label, color, font, fontsize, name) = {
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
  label-format(color, font, fontsize, convert-label(label-content, math-mode == "math" or (edge-label.at(name + "_math_mode") and math-mode != "text")))
}

#let format-edge-labels(math-mode, encoded-label, edge-overwrite) = {
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
      label: edge-label-format(math-mode, edge-overwrite, edge-label, edge-label.at("color"), font-name, font-size, "label"),
      xnative: "xlabel" in edge-overwrite,
      xlabel: edge-label-format(math-mode, edge-overwrite, edge-label, edge-label.at("color"), font-name, font-size, "xlabel"),
      tailnative: "taillabel" in edge-overwrite,
      taillabel: edge-label-format(
				math-mode,
        edge-overwrite,
        edge-label,
        edge-label.at("color"),
        font-name,
        font-size,
        "taillabel",
      ),
      headnative: "headlabel" in edge-overwrite,
      headlabel: edge-label-format(
				math-mode,
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

/// Return
/// - the label content depending on the overwrite method.
/// - a boolean indicating if the label was overwritten.
#let label-overwrite(math-mode, label-type, label, overwrite-method, font-name, font-size, math-mode-name) = {
  let name = label.at("name")
  if type(overwrite-method) == dictionary and name in overwrite-method {
    return (overwrite-method.at(name), true)
  }

  if type(overwrite-method) == function {
    let overwrite = overwrite-method(name)
    if overwrite != none {
      return (overwrite, true)
    }
  }

  let label-content = label.at(label-type)
  if label-content != "" {
    label-content = convert-label(label-content, math-mode == "math" or (label.at(math-mode-name) and math-mode != "text"))
    label-content = label-format(label.at("color"), font-name, font-size, label-content)
    return (label-content, true)
  }

  return ("", false)
}

/// Get an array of evaluated labels from a graph.
#let get-labels(math-mode, labels, xlabels, clusters, edges, dot) = {
  let overridden-labels = (
    "dot": dot,
  )
  // panic(buffer-repr(encode-GetGraphInfo(overridden-labels)))
  let encoded-labels = plugin.get_labels(encode-GetGraphInfo(overridden-labels))
  let (graph-labels, _) = decode-GraphInfo(encoded-labels)
  //panic(graph-labels)
  (
    graph-labels
      .at("labels")
      .map(encoded-label => {
        let font-size = text.size
        if encoded-label.at("font_size").pt() != 0 {
          font-size = encoded-label.at("font_size")
        }
        let font-name = encoded-label.at("font_name").split(",")

        let (label, overwrite) = label-overwrite(math-mode, "label", encoded-label, labels, font-name, font-size, "math_mode")

        let (xlabel, xoverwrite) = label-overwrite(math-mode, "xlabel", encoded-label, xlabels, font-name, font-size, "xlabel_math_mode")

        let edges-overwrite = if type(edges) == function {
          edges(encoded-label.at("name"), encoded-label.at("edges_infos").map(edge => edge.at("to")))
        } else {
          edges.at(encoded-label.at("name"), default: (:))
        }
        check-overwrite(encoded-label, edges-overwrite)
        let edge-labels = format-edge-labels(math-mode, encoded-label, edges-overwrite)
        (
          overwrite: overwrite,
          label: label,
          xoverwrite: xoverwrite,
          xlabel: xlabel,
          edges_infos: edge-labels,
        )
      }),
    graph-labels
      .at("cluster_labels")
      .map(encoded-label => {
        let font-name = encoded-label.at("font_name").split(",")
        let font-size = text.size
        if encoded-label.at("font_size").pt() != 0 {
          font-size = encoded-label.at("font_size")
        }
        let (label, overwrite) = label-overwrite(math-mode, "label", encoded-label, clusters, font-name, font-size, "math_mode")
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
    let edges-size = label
      .at("edges_infos")
      .map(edge => {
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

///
///
/// - dot (str): A string containing Dot code.
/// - labels (dict): Nodes whose name appear in this dictionary will have their label overridden with the corresponding content. Defaults to an empty dictionary.
/// - xlabels (dict): Nodes whose name appear in this dictionary will have their xlabel overridden with the corresponding content. Defaults to an empty dictionary.
/// - edges (dict): Nodes whose name appear in this dictionary will have their edge label overridden with the corresponding content. Each vale mut be a list of dictionaries, one for each edge. Each dictionary can have the following keys:
/// 	- `label`: the content of the label - `xlabel`: the content of the xlabel
/// 	- `taillabel`: the content of the taillabel - `headlabel`: the content of the headlabel
/// 	- clusters (dict): Cluster names whose name appear in this dictionary will have their label overridden with the corresponding content. Defaults to an empty dictionary.
/// - engine (str): The name of the engine to generate the graph with. Defaults to `"dot"`.
/// - width (str): The width of the image to display. If set to `auto` (the default), will be the width of the generated SVG or, if the height is set to a value, it will be scaled to keep the aspect ratio.
/// - height (str): The height of the image to display. If set to `auto` (the default), will be the height of the generated SVG or if the width is set to a value, it will be scaled to keep the aspect ratio.
/// - clip (bool): Whether to hide parts of the graph that extend beyond its frame. Defaults to `true`.
/// - debug (bool): Display a red rectangle around each label to help with debugging.
/// - background (str): A color or gradient to fill the background with. If set to `none` (the default), the background will be transparent.
/// - stretch (bool): if true, the render will be stretched to fit the width and height. Otherwise, it will keep it's aspect ratio.
/// - math-mode (str): The math mode to use for the labels. Can be `auto`, `"math"` or `"text"`. If set to `auto`, the mode will be determined by label content. In `"text"` mode, the label content will be parsed as a string. In `"math"` mode, the label content will be parsed as a math expression.
/// - alt (str): A text describing the image. This parameter is directly passed to the `image` element as its `alt` attribute. See #link("https://typst.app/docs/reference/visualize/image/#parameters-alt")[documentation] for more information.
/// -> content: The rendered graph.
#let render(
  dot,
  labels: (:),
  xlabels: (:),
  edges: (:),
  clusters: (:),
  engine: "dot",
  width: auto,
  height: auto,
  clip: true,
  debug: false,
  background: none,
  stretch: true,
	math-mode: auto,
  alt: none,
) = {
  set math.equation(numbering: none)
  if type(dot) != str {
    panic("The dot code must be a string")
  }

  layout(((width: container-width, height: container-height)) => (
    context {
      let (labels-infos, clusters-labels-infos) = get-labels(
				math-mode,
        labels,
        xlabels,
        clusters,
        edges,
        dot,
      )
      //return [#repr(labels-infos)]
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
      let (width: svg-width, height: svg-height) = measure({
        set image(width: auto, height: auto)
        image(bytes(output.at("svg")), format: "svg", alt: alt)
      })
      if output.landscape {
        // Swap width and height for landscape mode.
        let temp = svg-width
        svg-width = svg-height
        svg-height = temp
      }

      let final-width = width
      let final-height = height
      
      // fill the container like css background contain
      if not stretch and width != auto and height != auto {
        let ratio = svg-width / svg-height
        let container-ratio = width / height

        if ratio > container-ratio {
          final-width = width
          final-height = width / ratio
        } else {
          final-height = height
          final-width = height * ratio
        }
      } else {
        // stretch
        final-width = if width == auto {
          svg-width
        } else {
          relative-to-absolute(width, container-width)
        }
        final-height = if height == auto {
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
      show: block.with(
        width: svg-width, 
        height: svg-height, 
        fill: background
      )
      show: rotate.with(if output.landscape { -90deg } else { 0deg })
      if output.landscape {
        let temp = svg-height
        svg-height = svg-width
        svg-width = temp
      }

      // Display SVG.
      image(
        bytes(output.at("svg")),
        format: "svg",
        width: svg-width,
        height: svg-height,
        alt: alt,
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
