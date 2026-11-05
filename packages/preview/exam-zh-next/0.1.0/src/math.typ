// Math helpers: upright constants, vectors and calculation drills.

#import "config.typ": exam-state, format-label, plain-text, section-config

// Upright e, i and π: `$eu^x$`, `$2 - iu$`, `$2 uppi$`.
#let eu = $upright(e)$
#let upe = eu
#let iu = $upright(i)$
#let upi = iu
#let uppi = $upright(pi)$

// A vector: one letter is set in bold, several get an arrow.
// `$vect(a)$` gives a bold a, `$vect(A B)$` gives AB with an arrow.
#let vect(body) = {
    let txt = plain-text(body)
    let letters = if txt == none { 2 } else { txt.clusters().filter(c => c.trim() != "").len() }
    if letters == 1 { math.bold(body) } else { math.arrow(body) }
}

// Calculation drills laid out in a grid: `calculations[$1 + 1$][$2 + 2$]`.
#let calculations(..args) = context {
    let items = args.pos()
    let c = section-config(exam-state.get(), "calculations", args.named())
    block(width: 100%, above: c.top-sep, below: c.bottom-sep, pad(left: c.xshift, grid(
        columns: (1fr,) * c.columns,
        column-gutter: c.hsep,
        row-gutter: c.vsep,
        align: c.align + left,
        ..items.enumerate().map(((i, item)) => {
            set par(first-line-indent: 0pt)
            let label = move(dx: c.label-xshift, dy: c.label-yshift, format-label(c.label, c.index + i))
            let label = box(label)
            if c.fig-pos == "left-top" { [#label#h(c.label-sep)#item] }
            else if c.fig-pos == "left" { grid(columns: 2, column-gutter: c.label-sep, align: horizon, label, item) }
            else if c.fig-pos == "right" { grid(columns: 2, column-gutter: c.label-sep, align: horizon, item, label) }
            else if c.fig-pos == "top" { stack(spacing: c.label-sep, label, item) }
            else if c.fig-pos == "bottom" { stack(spacing: c.label-sep, item, label) }
            else { panic("exam-zh: calculations fig-pos must be \"left-top\", \"left\", \"right\", \"top\" or \"bottom\"") }
        }),
    )))
}
