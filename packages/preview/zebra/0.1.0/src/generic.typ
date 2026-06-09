#let _plugin = plugin("zebra.wasm")

#let encode(data, barcode, options, quiet-zone: 0) = {
  let bytes = _plugin.encode(
    bytes(data),
    bytes(if type(data) == str { "str" } else { "bytes" }),
    bytes(barcode),
    cbor.encode(options),
  )
  let i16(index) = {
    let n = bytes.at(index + 1) * 256 + bytes.at(index)
    if n >= 0x8000 { n - 0x10000 } else { n }
  }
  let width = i16(0)
  let height = i16(2)
  let segments = ()
  if quiet-zone > 0 {
    width += quiet-zone * 2
    height += quiet-zone * 2
    segments.push(curve.move((quiet-zone * 1pt, quiet-zone * 1pt), relative: true))
  }
  let index = 4
  // typst limitation: loop seems to be infinite
  while index < bytes.len() {
    let op = bytes.at(index)
    index += 1
    if op == 0 {
      segments.push(curve.move((i16(index) * 1pt, i16(index + 2) * 1pt), relative: true))
      index += 4
    } else if op == 1 {
      segments.push(curve.line((i16(index) * 1pt, 0pt), relative: true))
      index += 2
    } else if op == 2 {
      segments.push(curve.line((0pt, i16(index) * 1pt), relative: true))
      index += 2
    } else if op == 3 {
      segments.push(curve.close())
    } else {
      panic()
    }
  }
  (width: width, height: height, segments: segments)
}

#let _generic(
  data,
  barcode,
  options: (:),
  quiet-zone: 0,
  width: auto,
  height: auto,
  module-size: auto,
  fill: black,
  background-fill: none,
  default-quiet-zone: 1,
) = context {
  let options = options
  for (key, value) in options.pairs() {
    if value == none {
      options.remove(key)
    }
  }

  let quiet-zone = if (quiet-zone == false or quiet-zone == none) {
    0
  } else if (quiet-zone == true) {
    default-quiet-zone
  } else {
    quiet-zone
  }
  let path = encode(
    data,
    barcode,
    options,
    quiet-zone: quiet-zone,
  )

  let sizes = (width, height, module-size).map(x => if x != auto { x.to-absolute() } else { x })
  let (width, height, module-size) = sizes
  if sizes.filter(x => x != auto).len() > 1 {
    panic("Specify at most one of width, height or module-size")
  } else if sizes.all(x => x == auto) {
    module-size = 3pt
  }
  if (width != auto) {
    module-size = width / path.width
    height = path.height * module-size
  } else if (height != auto) {
    module-size = height / path.height
    width = path.width * module-size
  } else if (module-size != auto) {
    width = path.width * module-size
    height = path.height * module-size
  }

  block(width: width, height: height, fill: background-fill, {
    set align(top + left)
    scale((module-size / 1pt) * 100%, origin: top + left, {
      curve(
        fill: fill,
        fill-rule: "even-odd",
        ..path.segments,
      )
    })
  })
}
