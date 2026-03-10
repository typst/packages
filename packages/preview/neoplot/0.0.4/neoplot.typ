#import "utils.typ": get-svg-array, get-svg-image, get-text

#let gp = plugin("bin/neoplot.wasm")
#let gp-exec = plugin.transition(gp.init).exec

#let bridge(code, kind) = {
  let arg = cbor.encode((
    code: code,
    type: kind,
  ))
  let output = gp-exec(arg)
  cbor(output)
}

#let image-format = ("image", "string", "bytes")

#let exec(
  it,
  kind: "script",
  format: auto,
  ..args,
) = {
  if kind not in ("script", "command") {
    panic("Invalid code type `" + kind + "`")
  }
  if format == none {
    return
  }
  let code = get-text(it)
  if code.len() == 0 {
    return
  }
  if format == auto {
    return {
      let output = bridge(code, kind)
      if output.terminal != none {
        let svgs = get-svg-array(output.terminal)
        get-svg-image(svgs.last(), ..args)
      } else if output.print != none {
        str(output.print)
      }
    }
  }

  format = (format,)
    .flatten()
    .map(fmt => {
      if fmt == image {
        "image"
      } else if fmt == str {
        "string"
      } else if fmt == bytes {
        "bytes"
      } else {
        fmt
      }
    })
    .dedup()
  for fmt in format {
    if fmt not in ("print", ..image-format) {
      panic("Invalid format `" + fmt + "`")
    }
  }

  let result = (:)
  for fmt in format {
    let output = bridge(code, kind)
    if fmt in image-format and output.terminal == none {
      panic("No image output")
    }
    result.insert(
      fmt,
      if fmt == "image" {
        get-svg-array(output.terminal).map(data => get-svg-image(data, ..args))
      } else if fmt == "string" {
        get-svg-array(output.terminal).map(str)
      } else if fmt == "bytes" {
        get-svg-array(output.terminal)
      } else if fmt == "print" {
        if output.print == none {
          panic("No print output")
        }
        str(output.print)
      },
    )
  }

  if result.len() == 1 {
    return result.values().first()
  } else {
    return result
  }
}
