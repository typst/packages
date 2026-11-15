// Answer options with automatic column layout.

#import "config.typ": exam-state, format-label, section-config

// Item positions (1-based) of the correct answers. Letters follow the item
// labels ("BD" with labels starting at `index`); integers count items.
#let _answer-items(answer, index) = {
    if answer == none { return () }
    let answer = if type(answer) == array { answer } else { (answer,) }
    let out = ()
    for a in answer {
        if type(a) == int { out.push(a) }
        else {
            assert(type(a) == str, message: "exam-zh: choices answer must be letters or integers")
            for letter in upper(a).clusters() {
                if letter.trim() == "" or letter == "," { continue }
                let n = letter.to-unicode() - "A".to-unicode() + 1
                assert(n >= 1 and n <= 26, message: "exam-zh: invalid choices answer " + repr(letter))
                out.push(n - index + 1)
            }
        }
    }
    out
}

// Options of a choice question: `choices[$2$][$4$][$6$][$8$]`.
// The column count follows the widest option: `max-columns`, then half of it,
// and so on until the options fit. `answer: "B"` marks the correct option
// when `choices.show-answer` is true.
#let choices(..args) = context {
    let items = args.pos()
    let named = args.named()
    let answer = named.remove("answer", default: none)
    let c = section-config(exam-state.get(), "choices", named)
    let marked = _answer-items(answer, c.index)
    let left-indent = (if c.margin == none { c.left-indent } else { c.margin }).to-absolute()
    let right-indent = (if c.margin == none { c.right-indent } else { c.margin }).to-absolute()
    let label-sep = c.label-sep.to-absolute()
    let column-sep = c.column-sep.to-absolute()
    let leading = par.leading.to-absolute()

    let color(i, body) = if c.show-answer and (i + 1) in marked {
        text(fill: c.answer-color, body)
    } else { body }
    let labels = range(items.len()).map(i => color(i, format-label(c.label, c.index + i)))
    let items = items.enumerate().map(((i, item)) => color(i, item))

    block(width: 100%, above: c.top-sep, below: c.bottom-sep, layout(size => {
        let total = size.width - left-indent - right-indent
        let label-width = calc.max(c.label-width.to-absolute(), ..labels.map(l => measure(l).width))
        let sizes = items.map(item => measure(item))
        let item-width = calc.max(0pt, ..sizes.map(s => s.width))
        let min-height = calc.min(..sizes.map(s => s.height))

        // Options taller than two lines are figures: centre their labels.
        let pos = if c.label-pos == auto {
            if min-height > 2 * (1em.to-absolute() + leading) { "left" } else { "top-left" }
        } else { c.label-pos }
        assert(
            pos in ("top-left", "left", "bottom"),
            message: "exam-zh: choices label-pos must be auto, \"top-left\", \"left\" or \"bottom\"",
        )

        let columns = if c.columns == auto {
            let need = item-width + if pos == "bottom" { 0pt } else { label-width + label-sep }
            let fit = calc.max(1, calc.floor((total + column-sep) / (need + column-sep)))
            let k = c.max-columns
            while k > fit { k = calc.quo(k, 2) }
            calc.max(k, 1)
        } else { c.columns }

        let row-gap = leading + c.linesep.to-absolute()
        let cell-width = (total - (columns - 1) * column-sep) / columns
        let cells = labels.zip(items).map(((label, item)) => {
            set par(first-line-indent: 0pt, justify: false, leading: leading + c.item-linesep.to-absolute())
            let label = box(width: label-width, align(c.label-align, label))
            if pos == "top-left" {
                par(hanging-indent: label-width + label-sep)[#label#h(label-sep)#item]
            } else if pos == "left" {
                grid(
                    columns: (label-width, 1fr),
                    column-gutter: label-sep,
                    align: horizon,
                    label, item,
                )
            } else {
                stack(spacing: 0.4em, align(center, item), align(center, label))
            }
        })
        let body = if pos == "top-left" {
            // Each row is one line of boxes, so options share a baseline even
            // when one of them has taller math.
            set par(first-line-indent: 0pt, justify: false)
            for row in cells.chunks(columns) {
                block(spacing: row-gap, row.map(c => box(width: cell-width, c)).join(h(column-sep)))
            }
        } else {
            grid(
                columns: (cell-width,) * columns,
                column-gutter: column-sep,
                row-gutter: row-gap,
                align: if pos == "left" { horizon } else { bottom },
                ..cells,
            )
        }
        pad(left: left-indent, right: right-indent, body)
    }))
}
