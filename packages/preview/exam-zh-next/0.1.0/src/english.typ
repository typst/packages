// English-paper components: writing boxes and ruled answer lines.

#import "config.typ": apply-format, exam-state, section-config

// A framed writing area with an optional centred title.
#let writingbox(..args) = context {
    let named = args.named()
    let title = named.remove("title", default: none)
    let cfg = exam-state.get()
    let w = section-config(cfg, "writing", named)
    block(width: 100%, stroke: w.box-stroke, inset: w.inset, breakable: true, {
        set par(first-line-indent: 0pt)
        if title != none { align(center, apply-format(cfg, w.title-format, title)) }
        args.pos().join()
    })
}

// One ruled line across the current width, with `line-height` above it.
#let writingline(..args) = context {
    let w = section-config(exam-state.get(), "writing", args.named())
    block(spacing: 0pt, above: 0pt, {
        v(w.line-height)
        line(length: w.line-width, stroke: w.line-thickness + w.line-color)
    })
}

// A framed box of `n` ruled lines, edge to edge: `writinglines(8)`.
#let writinglines(n, ..args) = context {
    assert(type(n) == int and n > 0, message: "exam-zh: writinglines needs a positive line count")
    let w = section-config(exam-state.get(), "writing", args.named())
    let rule = line(length: 100%, stroke: w.line-thickness + w.line-color)
    block(width: w.line-width, stroke: w.lines-stroke, breakable: true, stack(
        ..range(n).map(_ => v(w.line-height)).intersperse(rule),
    ))
}
