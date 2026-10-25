// Text beside figures, and rows of captioned figures.

#import "config.typ": exam-state, section-config

// Text with a figure beside, above or below it.
// `fig-pos` is one of top, bottom, left, right, or a combination such as
// "bottom-right", "top-center", "bottom-flushright", "left-top",
// "right-bottom". "-right" aligns the figure with the text's own width,
// "-flushright" with the line end.
#let textfigure(..args) = context {
    let (body, figure) = args.pos()
    let f = section-config(exam-state.get(), "textfigure", args.named())
    let pos = f.fig-pos
    let parts = pos.split("-")
    let side = parts.first()
    let place-at = parts.at(1, default: "center")
    assert(
        side in ("top", "bottom", "left", "right"),
        message: "exam-zh: unknown textfigure fig-pos " + repr(pos),
    )
    let figure = if f.figure-width == auto { figure } else { box(width: f.figure-width, align(center, figure)) }
    let figure = move(dx: f.figure-xshift, dy: f.figure-yshift, figure)
    let text-part = {
        set par(first-line-indent: (amount: f.parindent, all: true))
        body
    }
    let out = layout(size => {
        if side in ("left", "right") {
            let fig-width = measure(figure).width
            let min-text = if type(f.min-text-width) == ratio { f.min-text-width * size.width } else { f.min-text-width }
            let text-width = if f.ratio != auto { f.ratio * size.width }
                else if f.text-width != auto { f.text-width }
                else { calc.max(min-text, size.width - fig-width - f.column-gap.to-absolute()) }
            let valign = if place-at == "top" { top } else if place-at == "bottom" { bottom } else { horizon }
            let cells = (block(width: text-width, text-part), figure)
            grid(
                columns: if side == "right" { (text-width, 1fr) } else { (1fr, text-width) },
                column-gutter: f.column-gap,
                align: (x, y) => valign + if (side == "right") == (x == 1) { right } else { left },
                ..if side == "right" { cells } else { cells.rev() },
            )
        } else {
            // The text's natural width, as varwidth measures it.
            let fixed = if f.ratio != auto { f.ratio * size.width } else { f.text-width }
            let width = if fixed != auto { fixed }
                else { calc.min(size.width, measure(text-part).width) }
            let halign = if place-at == "left" { left }
                else if place-at in ("right", "flushright") { right }
                else { center }
            let fig = if place-at in ("center", "flushright") {
                block(width: 100%, align(halign, figure))
            } else {
                block(width: width, align(halign, figure))
            }
            let text-block = if fixed != auto { block(width: width, text-part) } else { text-part }
            if side == "top" { stack(spacing: 0.6em, fig, text-block) }
            else { stack(spacing: 0.6em, text-block, fig) }
        }
    })
    block(width: 100%, above: f.top-sep, below: f.bottom-sep, move(dx: f.xshift, dy: f.yshift, out))
}

// Figures in a grid, each with an optional label:
// `multifigures(([题 9 图], image("a.png")), ([题 10 图], image("b.png")))`.
#let multifigures(..args) = context {
    let m = section-config(exam-state.get(), "multifigures", args.named())
    let cells = args.pos().map(item => {
        let (label, body) = if type(item) == array { item } else { (none, item) }
        let label = if label == none { none } else { move(dx: m.label-xshift, dy: m.label-yshift, label) }
        let body = align(center, body)
        let cell = if label == none { body }
            else if m.fig-pos == top { stack(spacing: m.label-sep, body, align(center, label)) }
            else if m.fig-pos == bottom { stack(spacing: m.label-sep, align(center, label), body) }
            else if m.fig-pos == left { stack(dir: ltr, spacing: m.label-sep, body, align(horizon, label)) }
            else if m.fig-pos == right { stack(dir: ltr, spacing: m.label-sep, align(horizon, label), body) }
            else { panic("exam-zh: multifigures fig-pos must be top, bottom, left or right") }
        move(dx: m.xshift, dy: m.yshift, cell)
    })
    block(width: 100%, above: m.top-sep, below: m.bottom-sep, align(center, grid(
        columns: if m.column-widths == auto { calc.min(m.columns, cells.len()) } else { m.column-widths },
        column-gutter: m.column-gap,
        row-gutter: m.row-gap,
        align: m.align + center,
        ..cells,
    )))
}
