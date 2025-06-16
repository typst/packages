#let plugin = plugin("diagraph.wasm")


#let double-precision = 1000

#let length-to-int(value) = {
  calc.round(value * double-precision / 1pt)
}

#let int-to-length(value) = {
  value / double-precision * 1pt
}


/// Encodes a 32-bytes integer into big-endian bytes.
#let encode-int(value) = {
  bytes((
    calc.rem(calc.quo(value, 0x1000000), 0x100),
    calc.rem(calc.quo(value, 0x10000), 0x100),
    calc.rem(calc.quo(value, 0x100), 0x100),
    calc.rem(calc.quo(value, 0x1), 0x100),
  ))
}

/// Decodes a big-endian integer from the given bytes.
#let decode-int(bytes) = {
  let result = 0
  for byte in array(bytes) {
    result = result * 256 + byte
  }
  return result
}

/// Encodes an array of integers into bytes.
#let encode-int-array(arr) = {
  bytes(
    arr
      .map(encode-int)
      .map(array)
      .flatten()
  )
}

/// Encodes an array of strings into bytes.
#let encode-string-array(strings) = {
  bytes(strings.map(string => array(bytes(string)) + (0,)).flatten())
}

/// Transforms bytes into an array whose elements are all `bytes` with the
/// specified length.
#let group-bytes(buffer, group-len) = {
  assert(calc.rem(buffer.len(), group-len) == 0)
  array(buffer).fold((), (acc, x) => {
    if acc.len() != 0 and acc.last().len() < group-len {
      acc.last().push(x)
      acc
    } else {
      acc + ((x,),)
    }
  }).map(bytes)
}

/// Group elements of the array in pairs.
#let array-to-pairs(arr) = {
  assert(calc.even(arr.len()))
  arr.fold((), (acc, x) => {
    if acc.len() != 0 and acc.last().len() < 2 {
      acc.last().push(x)
      acc
    } else {
      acc + ((x,),)
    }
  })
}

/// Get an array of evaluated labels from a graph.
#let get-labels(manual-label-names, dot) = {
  let encoded-labels = plugin.get_labels(
    encode-int(manual-label-names.len()),
    encode-string-array(manual-label-names),
    bytes(dot),
  )
  let encoded-label-array = array(encoded-labels).split(0).slice(0, -1).map(bytes)
  encoded-label-array.map(encoded-label => {
    let mode = str(encoded-label.slice(0, 1))
    let label-str = str(encoded-label.slice(1))
    if mode == "t" {
      [#label-str]
    } else if mode == "m" {
      math.equation(eval(mode: "math", label-str))
    } else {
      panic("Internal Diagraph error: Unsopported mode: `" + mode + "`")
    }
  })
}

/// Encodes the dimensions of labels into bytes.
#let encode-label-dimensions(styles, labels) = {
  encode-int-array(
    labels
      .map(label => {
        let dimensions = measure(label, styles)
        (
          length-to-int(dimensions.width),
          length-to-int(dimensions.height),
        )
      })
      .flatten()
  )
}

/// Converts any relative length to an absolute length.
#let relative-to-absolute(value, styles, container-dimension) = {
  if type(value) == relative {
    let absolute-part = relative-to-absolute(value.length, styles, container-dimension)
    let ratio-part = relative-to-absolute(value.ratio, styles, container-dimension)
    return absolute-part + ratio-part
  }
  if type(value) == length {
    return value.abs + value.em * measure(line(length: 1em), styles).width
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
  let manual-labels = labels.values()
  let manual-label-names = labels.keys()
  let manual-label-count = manual-labels.len()

  let native-labels = get-labels(manual-label-names, dot)
  let native-label-count = native-labels.len()

	layout(((width: container-width, height: container-height)) => style(styles => {
		let font-size = measure(line(length: 1em), styles).width

		let output = plugin.render(
			encode-int(length-to-int(font-size)),
			bytes(dot),
      encode-label-dimensions(styles, native-labels),
      encode-label-dimensions(styles, manual-labels),
      encode-string-array(manual-label-names),
			bytes(engine),
		)

		if output.at(0) != 0 {
			return {
				show: highlight.with(fill: red)
				set text(white)
				raw(block: true, str(output))
			}
		}

		let integer-size = output.at(1)
		output = output.slice(2)

		// Get native label coordinates.
		let native-label-coordinates-size = 2 * native-label-count * integer-size
		let native-label-coordinates = array-to-pairs(
      group-bytes(output.slice(0, native-label-coordinates-size), integer-size)
      .map(decode-int)
      .map(int-to-length)
    )
		output = output.slice(native-label-coordinates-size)

    // Get manual label coordinates.
    let manual-label-coordinate-sets = ()
    for manual-label-index in range(manual-label-count) {
      let coordinate-set = ()
      let use-count = decode-int(output.slice(0, integer-size))
      output = output.slice(integer-size)
      for i in range(use-count) {
        coordinate-set.push(
          (output.slice(0, integer-size), output.slice(integer-size, 2 * integer-size))
            .map(decode-int)
            .map(int-to-length)
        )
        output = output.slice(integer-size * 2)
      }
      manual-label-coordinate-sets.push(coordinate-set)
    }

    // Get SVG dimensions.
    let svg-width = int-to-length(decode-int(output.slice(0, integer-size)))
    let svg-height = int-to-length(decode-int(output.slice(integer-size + 1, integer-size * 2)))
		output = output.slice(integer-size * 2)

		let final-width = if width == auto {
      svg-width
    } else {
      relative-to-absolute(width, styles, container-width)
    }
		let final-height = if height == auto {
      svg-height
    } else {
      relative-to-absolute(height, styles, container-height)
    }

    if width == auto and height != auto {
      let ratio = final-height / svg-height
      final-width = svg-width * ratio
    } else if width != auto and height == auto {
      let ratio = final-width / svg-width
      final-height = svg-height * ratio
    }

    set align(top + left)

		// Rescale the final image to the desired size.
		show: block.with(
      width: final-width,
      height: final-height,
      clip: clip,
      breakable: false,
    )
		show: scale.with(
      origin: top + left,
      x: final-width / svg-width * 100%,
      y: final-height / svg-height * 100%,
    )

		// Construct the graph and its labels.
		show: block.with(width: svg-width, height: svg-height, fill: background)

    // Display SVG.
		image.decode(
			output,
			format: "svg",
			width: svg-width,
			height: svg-height,
		)

    // Place native labels.
		for (label, coordinates) in native-labels.zip(native-label-coordinates) {
			let (x, y) = coordinates
			let label-dimensions = measure(label, styles)
			place(
				top + left,
				dx: x - label-dimensions.width / 2,
				dy: final-height - y - label-dimensions.height / 2 - (final-height - svg-height),
				label,
			)
		}

    // Place manual labels.
    for (label, coordinate-set) in manual-labels.zip(manual-label-coordinate-sets) {
      let label-dimensions = measure(label, styles)
      for (x, y) in coordinate-set {
        place(
          top + left,
          dx: x - label-dimensions.width / 2,
          dy: final-height - y - label-dimensions.height / 2 - (final-height - svg-height),
          label,
        )
      }
    }
	}))
}
