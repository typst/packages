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

/// Get an array of evaluated labels from a graph.
#let get-labels(manual-label-names, dot) = {
	let encoded-labels = plugin.get_labels(encode-overriddenLabels((
		"labels": manual-label-names,
		"dot": dot,
	)))
	let (labels, _) = decode-LabelsInfos(encoded-labels)
  labels.at("labels").map(encoded-label => {
		let label = if encoded-label.at("native") {
			if encoded-label.at("mathMode") {
				math.equation(eval(mode: "math", encoded-label.at("label")))
			} else {
				parse-string(encoded-label.at("label"))
			}
		} else {
			encoded-label.at("label")
		}
		(
			..encoded-label,
			label: label,
		)
  })
}

/// Return a formatted label based on its color, font and content.
#let label-format(color, font, fontsize, label) = [
	#set text(fill: rgb(int-to-string(color, 8, base: 16)))
	#set text(size: fontsize) if fontsize.pt() != 0
	#set text(font: font) if font != ""
	#text(label)
]

#let label-dimensions(color, font, fontsize, label) = {
	let label = label-format(color, font, fontsize, label)
	measure(label)
}

/// Encodes the dimensions of labels into bytes.
#let encode-label-dimensions(labels, overriden-labels) = {
	labels.map(label => {
		if label.at("html") {
			(
				override: false,
				width: 0,
				height: 0,
			)
		} else if label.at("native") {
			let dimensions = label-dimensions(label.at("color"), label.at("fontName"), label.at("fontSize"), label.at("label"))
			(
				override: true,
				width: dimensions.width / 1pt,
				height: dimensions.height / 1pt,
			)
		} else {
			let dimensions = measure(overriden-labels.at(label.at("label")))
			(
				override: true,
				width: dimensions.width / 1pt,
				height: dimensions.height / 1pt,
			)
		}
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

/// Renders a graph with Graphviz.
#let render(
  /// A string containing Dot code.
	dot,
  /// Nodes whose name appear in this dictionary will have their label
  /// overridden with the corresponding content. Defaults to an empty
  /// dictionary.
  labels: (:),
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
  /// A color or gradient to fill the background with. If set to `none` (the
  /// default), the background will be transparent.
  background: none,
) = {
  set math.equation(numbering: none)
  let manual-label-names = labels.keys()
  let labels-infos = get-labels(manual-label-names, dot)
  let labels-info-count = labels-infos.len()
	
	layout(((width: container-width, height: container-height)) => context {
		// replace invalid font sizes with the current text size

		let labels-infos = labels-infos.map((label) => {
			let fontSize = text.size
			if label.at("fontSize").pt() != 0 {
				fontSize = label.at("fontSize")
			}
			(
				..label,
				fontSize: fontSize,
			)
		})
		// return [#repr(labels-infos)]

		let encoded-data = (
			"fontSize": text.size.to-absolute(),
			"dot": dot,
			"labels": encode-label-dimensions(labels-infos, labels),
			"engine": engine,
		)
		// return [#repr(encoded-data)]
		// return [#((array(encode-renderGraph(encoded-data)).map(x => "0x" + int-to-string(x, 2, base: 16))).join(", "))]

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

    // Place labels.
		for (label-infos, label-coordinates) in labels-infos.zip(output.at("labels")) {
			if label-infos.at("html") {
				continue
			}
			let label = if label-infos.at("native") {
				label-infos.at("label")
			} else {
				labels.at(label-infos.at("label"))
			}
			let label = label-format(label-infos.at("color"), label-infos.at("fontName"), label-infos.at("fontSize"), label)
			let label-dimensions = measure(label)
			place(
				top + left,
				dx: label-coordinates.at("x") - label-dimensions.width / 2,
				dy: final-height - label-coordinates.at("y") - label-dimensions.height / 2 - (final-height - svg-height),
				label
			)
			// place(
			// 	top + left,
			// 	dx: label-coordinates.at("x") - label-dimensions.width / 2,
			// 	dy: final-height - label-coordinates.at("y") - label-dimensions.height / 2 - (final-height - svg-height),
			// 	rect(height: label-dimensions.height, width: label-dimensions.width, fill: none)
			// )
		}
	})
}
