#let gp = plugin("neoplot.wasm")

#let gettext(it) = {
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

#let getbytes(it) = {
    if type(it) == bytes {
        it
    } else {
        bytes(gettext(it))
    }
}

#let exec(it) = str(gp.exec(getbytes(it)))
#let eval(it) = str(gp.eval(getbytes(it)))
