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
#let decode-ClusterLabelInfo(bytes) = {
  let offset = 0
  let (f_native, size) = decode-bool(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_html, size) = decode-bool(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_name, size) = decode-string(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_label, size) = decode-string(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_math_mode, size) = decode-bool(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_color, size) = decode-int(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_font_name, size) = decode-string(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_font_size, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  ((
    native: f_native,
    html: f_html,
    name: f_name,
    label: f_label,
    math_mode: f_math_mode,
    color: f_color,
    font_name: f_font_name,
    font_size: f_font_size,
  ), offset)
}
#let encode-SizedClusterLabel(value) = {
  encode-point(value.at("width")) + encode-point(value.at("height"))
}
#let encode-SizedNodeLabel(value) = {
  encode-bool(value.at("override")) + encode-bool(value.at("xoverride")) + encode-point(value.at("width")) + encode-point(value.at("height")) + encode-point(value.at("xwidth")) + encode-point(value.at("xheight"))
}
#let decode-NodeLabelInfo(bytes) = {
  let offset = 0
  let (f_native, size) = decode-bool(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_html, size) = decode-bool(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_name, size) = decode-string(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_label, size) = decode-string(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_math_mode, size) = decode-bool(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_override_xlabel, size) = decode-bool(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_xlabel, size) = decode-string(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_xlabel_math_mode, size) = decode-bool(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_color, size) = decode-int(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_font_name, size) = decode-string(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_font_size, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  ((
    native: f_native,
    html: f_html,
    name: f_name,
    label: f_label,
    math_mode: f_math_mode,
    override_xlabel: f_override_xlabel,
    xlabel: f_xlabel,
    xlabel_math_mode: f_xlabel_math_mode,
    color: f_color,
    font_name: f_font_name,
    font_size: f_font_size,
  ), offset)
}
#let encode-OverrideLabel(value) = {
  encode-string(value.at("label")) + encode-bool(value.at("content")) + encode-bool(value.at("xlabel"))
}
#let decode-NodeCoordinates(bytes) = {
  let offset = 0
  let (f_x, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_y, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_xx, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_xy, size) = decode-point(bytes.slice(offset, bytes.len()))
  offset += size
  ((
    x: f_x,
    y: f_y,
    xx: f_xx,
    xy: f_xy,
  ), offset)
}
#let decode-ClusterCoordinates(bytes) = {
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
#let decode-graphInfo(bytes) = {
  let offset = 0
  let (f_error, size) = decode-bool(bytes.slice(offset, bytes.len()))
  offset += size
  let (f_labels, size) = decode-list(bytes.slice(offset, bytes.len()), decode-NodeCoordinates)
  offset += size
  let (f_cluster_labels, size) = decode-list(bytes.slice(offset, bytes.len()), decode-ClusterCoordinates)
  offset += size
  let (f_svg, size) = decode-string(bytes.slice(offset, bytes.len()))
  offset += size
  ((
    error: f_error,
    labels: f_labels,
    cluster_labels: f_cluster_labels,
    svg: f_svg,
  ), offset)
}
#let encode-overriddenLabels(value) = {
  encode-list(value.at("labels"), encode-OverrideLabel) + encode-list(value.at("cluster_labels"), encode-string) + encode-string(value.at("dot"))
}
#let decode-LabelsInfos(bytes) = {
  let offset = 0
  let (f_labels, size) = decode-list(bytes.slice(offset, bytes.len()), decode-NodeLabelInfo)
  offset += size
  let (f_cluster_labels, size) = decode-list(bytes.slice(offset, bytes.len()), decode-ClusterLabelInfo)
  offset += size
  ((
    labels: f_labels,
    cluster_labels: f_cluster_labels,
  ), offset)
}
#let encode-renderGraph(value) = {
  encode-point(value.at("font_size")) + encode-string(value.at("dot")) + encode-list(value.at("labels"), encode-SizedNodeLabel) + encode-list(value.at("cluster_labels"), encode-SizedClusterLabel) + encode-string(value.at("engine"))
}
