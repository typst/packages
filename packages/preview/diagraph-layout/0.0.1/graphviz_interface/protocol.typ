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
  for byte in array(bytes.slice(0,4)) {
    result = result * 256 + byte
  }
  if (result > 0x7FFFFFFF) { // the number is negative
    result = result - 0x100000000
  }
  (result, 4)
}

/// Encodes a string into bytes.
#let encode-string(value) = {
	bytes(value) + bytes((0x00,))
}

/// Decodes a string from the given bytes.
#let decode-string(bytes) = {
	let length = 0
	for byte in array(bytes) {
		length = length + 1
		if byte == 0x00 {
			break
		}
	}
	if length == 0 {
		("", 1)
	} else { 
		(str(bytes.slice(0, length - 1)), length)
	}
	//(array(bytes.slice(0, length - 1)), length)
}

/// Encodes a boolean into bytes
#let encode-bool(value) = {
  if value {
	bytes((0x01,))
  } else {
	bytes((0x00,))
  }
}

/// Decodes a boolean from the given bytes
#let decode-bool(bytes) = {
  if bytes.at(0) == 0x00 {
	(false, 1)
  } else {
	(true, 1)
  }
}

/// Encodes a character into bytes
#let encode-char(value) = {
  bytes(value)
}

/// Decodes a character from the given bytes
#let decode-char(bytes) = {
  (bytes.at(0), 1)
}

#let fractional-to-binary(fractional_part, max_dec, zero) = {
	let result = 0
	let i = 22 - max_dec
	let first_one = 0
	if zero {
		while fractional_part < 1 {
			fractional_part *= 2
			first_one += 1
		}
		fractional_part -= 1
		i = 23
	}
	while i > 0 and fractional_part > 0 {
		fractional_part *= 2
		if fractional_part >= 1 {
			result += calc.pow(2, i - 1)
			fractional_part -= 1
		}
		i -= 1
	}
	(result, first_one)
}

#let float-to-int(value) = {
	if value == 0 {
		return 0
	}
	let sign = if value < 0.0 { 1 } else { 0 }
	let value = calc.abs(value)
	let mantissa = calc.trunc(value)
	let fractional_part = calc.fract(value)
	let exponent = if mantissa == 0 {
		0
	} else {
		calc.floor(calc.log(base: 2, mantissa)) - 1
	}
	let (fractional_part, first_one) = fractional-to-binary(fractional_part, exponent, mantissa == 0)
	mantissa *= calc.pow(2, 22 - exponent)
	mantissa += fractional_part
	if exponent == 0 {
		exponent = -first_one
	}
	exponent += 127
	return  sign * calc.pow(2, 31) + exponent * calc.pow(2, 23) + mantissa
}

#let mantissa-to-float(mantissa) = {
	let result = 1.0
	for i in range(0,23) {
		if calc.rem(mantissa, 2) == 1 {
			result += 1.0/calc.pow(2, 23 - i)
		}
		mantissa = calc.quo(mantissa, 2)
	}
	result
}

#let int-to-float(value) = {
	if value == 0 {
		return 0.0
	}
	let sign = if value >= calc.pow(2, 31) {
		value -= calc.pow(2, 31)
		 -1 
	} else { 
		1
	}
	let exponent = calc.rem(calc.quo(value, calc.pow(2, 23)), calc.pow(2, 8))
	let mantissa = calc.rem(value, calc.pow(2, 23))
	sign * calc.pow(2, exponent - 127) * mantissa-to-float(mantissa)
}

/// Encodes a float into bytes
#let encode-float(value) = {
	encode-int(float-to-int(value))
}

#let encode-point(value) = {
	encode-float(value.pt())
}

/// Decodes a float from the given bytes
#let decode-float(bytes) = {
	let (decoded, size) = decode-int(bytes)
	(int-to-float(decoded), size)
}

#let decode-point(bytes) = {
	let (value, size) = decode-float(bytes)
	(value * 1pt, size)
}

/// Encodes a list of elements into bytes
#let encode-list(arr, encoder) = {
	let length = encode-int(arr.len())
	let encoded = bytes(arr.map(encoder).map(array).flatten())
	length + encoded
}

/// Encodes an optional value into bytes
#let encode-optional(opt, encoder) = {
	if opt == none {
		bytes((0x00,))
	} else {
		bytes((0x01,)) + encoder(opt)
	}
}

/// Decodes a list of elements from the given bytes
#let decode-list(bytes, decoder) = {
	let (length, length_size) = decode-int(bytes)
	let result = ()
	let offset = length_size
	for i in range(0, length) {
		let (element, size) = decoder(bytes.slice(offset, bytes.len()))
		result.push(element)
		offset += size
	}
	(result, offset)
}

/// Decodes an optional value from the given bytes
#let decode-optional(bytes, decoder) = {
	let has_value = bytes.at(0) != 0x00
	if has_value {
		let (value, size) = decoder(bytes.slice(1, bytes.len()))
		((value), size + 1)
	} else {
		((none), 1)
	}
}
#let encode-Attribute(value) = {
  encode-string(value.at("key")) + encode-string(value.at("value"))
}
#let encode-Size(value) = {
  encode-point(value.at("width")) + encode-point(value.at("height"))
}
#let encode-Node(value) = {
  encode-string(value.at("name")) + encode-point(value.at("width")) + encode-point(value.at("height")) + encode-optional(value.at("xlabel", default: none), encode-Size)
}
#let encode-Edge(value) = {
  encode-string(value.at("tail")) + encode-string(value.at("head")) + encode-list(value.at("attributes"), encode-Attribute) + encode-optional(value.at("label", default: none), encode-Size) + encode-optional(value.at("xlabel", default: none), encode-Size) + encode-optional(value.at("headlabel", default: none), encode-Size) + encode-optional(value.at("taillabel", default: none), encode-Size)
}
#let encode-GraphAttribute(value) = {
  encode-int(value.at("for_")) + encode-string(value.at("key")) + encode-string(value.at("value"))
}
#let encode-SubGraph(value) = {
  encode-list(value.at("nodes"), encode-string) + encode-list(value.at("attributes"), encode-Attribute)
}
#let decode-LayoutLabel(bytes) = {
  let offset = 0
  let (f_x, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_y, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_width, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_height, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  ((
    x: f_x,
    y: f_y,
    width: f_width,
    height: f_height,
  ), offset)
}
#let decode-LayoutNode(bytes) = {
  let offset = 0
  let (f_name, size) = decode-string(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_x, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_y, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_width, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_height, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_xlabel, size) = decode-optional(bytes.slice(offset, bytes.len()), decode-LayoutLabel)
  offset += size
  ((
    name: f_name,
    x: f_x,
    y: f_y,
    width: f_width,
    height: f_height,
    xlabel: f_xlabel,
  ), offset)
}
#let decode-ControlPoint(bytes) = {
  let offset = 0
  let (f_x, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_y, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  ((
    x: f_x,
    y: f_y,
  ), offset)
}
#let decode-LayoutEdge(bytes) = {
  let offset = 0
  let (f_points, size) = decode-list(bytes.slice(offset, bytes.len()), decode-ControlPoint)
  offset += size
  let (f_head, size) = decode-string(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_tail, size) = decode-string(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_label, size) = decode-optional(bytes.slice(offset, bytes.len()), decode-LayoutLabel)
  offset += size
  let (f_xlabel, size) = decode-optional(bytes.slice(offset, bytes.len()), decode-LayoutLabel)
  offset += size
  let (f_headlabel, size) = decode-optional(bytes.slice(offset, bytes.len()), decode-LayoutLabel)
  offset += size
  let (f_taillabel, size) = decode-optional(bytes.slice(offset, bytes.len()), decode-LayoutLabel)
  offset += size
  ((
    points: f_points,
    head: f_head,
    tail: f_tail,
    label: f_label,
    xlabel: f_xlabel,
    headlabel: f_headlabel,
    taillabel: f_taillabel,
  ), offset)
}
#let decode-Layout(bytes) = {
  let offset = 0
  let (f_errored, size) = decode-bool(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_scale, size) = decode-float(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_width, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_height, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_nodes, size) = decode-list(bytes.slice(offset, bytes.len()), decode-LayoutNode)
  offset += size
  let (f_edges, size) = decode-list(bytes.slice(offset, bytes.len()), decode-LayoutEdge)
  offset += size
  ((
    errored: f_errored,
    scale: f_scale,
    width: f_width,
    height: f_height,
    nodes: f_nodes,
    edges: f_edges,
  ), offset)
}
#let encode-Graph(value) = {
  encode-string(value.at("engine")) + encode-bool(value.at("directed")) + encode-list(value.at("edges"), encode-Edge) + encode-list(value.at("nodes"), encode-Node) + encode-list(value.at("attributes"), encode-GraphAttribute) + encode-list(value.at("subgraphs"), encode-SubGraph)
}
#let decode-Engines(bytes) = {
  let offset = 0
  let (f_engines, size) = decode-list(bytes.slice(offset, bytes.len()), decode-string)
  offset += size
  ((
    engines: f_engines,
  ), offset)
}
