#let gp = plugin("neoplot.wasm")
#let gp-exec = plugin.transition(gp.init).exec

#let get-text(it) = {
    if type(it) == str {
        it
    } else if type(it) == content {
        if it.has("text") {
            it.text
        } else {
            panic("Content must contain field `text`")
        }
    } else {
        panic("Invalid type `" + type(it) + "`")
    }
}

#let get-svg-image(..args) = image(format: "svg", ..args)

#let bridge(code, kind) = {
    let arg = cbor.encode(
        (
            code: code,
            type: kind,
        )
    )
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
            if output.images != none {
                get-svg-image(output.images.last(), ..args)
            } else if output.print != none {
                str(output.print)
            }
        }
    }

    format = (format,).flatten().map(fmt => {
        if type(fmt) == type {
            if fmt == image {
                "image"
            } else if fmt == str {
                "string"
            } else if fmt == bytes {
                "bytes"
            } else {
                fmt
            }
        } else {
            fmt
        }
    }).dedup()
    for fmt in format {
        if fmt not in ("print", ..image-format) {
            panic("Invalid format `" + fmt + "`")
        }
    }

    let result = (:)
    for fmt in format {
        let output = bridge(code, kind)
        result.insert(fmt,
            if fmt in image-format and output.images == none {
                panic("No image output")
            } else if fmt == "image" {
                output.images.map(data => get-svg-image(data, ..args))
            } else if fmt == "string" {
                output.images.map(str)
            } else if fmt == "bytes" {
                output.images
            } else if fmt == "print" {
                if output.print == none {
                    panic("No print output")
                }
                str(output.print)
            }
        )
    }

    if result.len() == 1 {
        result.values().first()
    } else {
        result
    }
}
