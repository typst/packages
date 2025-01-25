#let gp = plugin("neoplot.wasm")

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

#let get-svg-image(..args) = image.decode(format: "svg", ..args)

#let bridge(code, kind) = {
    let arg = cbor.encode(
        (
            code: code,
            type: kind,
        )
    )
    let output = gp.exec(arg)
    let (
        print_output: print-output,
        term_output: term-output,
    ) = cbor.decode(output)
    (
        print-output,
        term-output,
    )
}

#let term-format = ("image", "string", "bytes")

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
            let (
                print-output,
                term-output,
            ) = bridge(code, kind)
            if term-output != none {
                get-svg-image(term-output.last(), ..args)
            } else if print-output != none {
                str(print-output)
            }
        }
    }

    format = (format,).flatten().map(fmt => {
        if fmt == image {
            "image"
        } else if fmt in (str, "str") {
            "string"
        } else if fmt == bytes {
            "bytes"
        } else {
            fmt
        }
    }).dedup()
    for fmt in format {
        if fmt not in ("print", ..term-format) {
            panic("Invalid format `" + fmt + "`")
        }
    }

    let result = (:)
    for fmt in format {
        let (
            print-output,
            term-output,
        ) = bridge(code, kind)
        result.insert(fmt,
            if fmt in term-format and term-output == none {
                panic("No terminal output")
            } else if fmt == "image" {
                term-output.map(data => get-svg-image(data, ..args))
            } else if fmt == "string" {
                term-output.map(str)
            } else if fmt == "bytes" {
                term-output
            } else if fmt == "print" {
                if print-output == none {
                    panic("No print output")
                }
                str(print-output)
            }
        )
    }

    if result.len() == 1 {
        result.values().first()
    } else {
        result
    }
}
