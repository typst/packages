// Chinese-paper components: pick-one marks, matching lines, reading
// material, classical poems with notes, and composition grids.

#import "config.typ": apply-format, circled-number, exam-state, resolve-size, section-config

#let _positions(answer) = {
    if answer == none { () } else if type(answer) == array { answer } else { (answer,) }
}

// Pick the right reading or character: `select[zhé][shé](answer: 2)`.
// The mark appears on the answers when `select.show-mark` is true.
#let select(..args) = context {
    let named = args.named()
    let answer = _positions(named.remove("answer", default: none))
    let cfg = exam-state.get()
    let s = section-config(cfg, "select", named)
    let mark = box(move(dx: s.mark-xshift, dy: s.mark-yshift, s.mark-symbol))
    let items = args.pos().enumerate().map(((i, item)) => {
        if not (s.show-mark and (i + 1) in answer) { return item }
        if s.mark-position == right { [#item#mark] }
        else if s.mark-position == left { [#mark#item] }
        else if s.mark-position in (top, bottom) {
            let parts = if s.mark-position == top { (mark, item) } else { (item, mark) }
            box(baseline: if s.mark-position == top { 0pt } else { measure(mark).height }, stack(
                spacing: 0.1em,
                ..parts.map(p => align(center, p)),
            ))
        } else { panic("exam-zh: select mark-position must be left, right, top or bottom") }
    })
    [#s.pre-content#items.join(s.separator)#s.post-content]
}

// A matching question: each positional argument is one column of items;
// `connect` lists chains of item numbers, one number per column, e.g.
// `connect: ((1, 3), (2, 1))`. Lines show when `lineto.show-lines` is true.
#let lineto(..args) = context {
    let named = args.named()
    let connect = named.remove("connect", default: ())
    let l = section-config(exam-state.get(), "lineto", named)
    let columns = args.pos()
    assert(columns.len() >= 2, message: "exam-zh: lineto needs at least two columns")
    let inset = l.item-inset.to-absolute()
    let ysep = l.ysep.to-absolute()
    block(width: 100%, layout(size => {
        let xsep = resolve-size(l.xsep, size.width)
        let xsep = if type(xsep) == length { xsep.to-absolute() } else { xsep }
        let sizes = columns.map(col => col.map(item => measure(item)))
        let first-half = calc.max(..sizes.first().map(s => s.width)) / 2 + inset
        let last-half = calc.max(..sizes.last().map(s => s.width)) / 2 + inset
        let rows = calc.max(..columns.map(c => c.len()))
        let tallest = calc.max(..sizes.flatten().map(s => s.height))
        // Item centres, as TikZ nodes at (k xsep, -(i - 1) ysep).
        let cx(k) = first-half + k * xsep
        let cy(i) = tallest / 2 + inset + (i - 1) * ysep
        let width = cx(columns.len() - 1) + last-half
        let height = cy(rows) + tallest / 2 + inset
        let items = for (k, col) in columns.enumerate() {
            for (i, item) in col.enumerate() {
                let s = sizes.at(k).at(i)
                place(top + left, dx: cx(k) - s.width / 2, dy: cy(i + 1) - s.height / 2, item)
            }
        }
        let lines = if l.show-lines {
            for chain in connect {
                for k in range(chain.len() - 1) {
                    let (a, b) = (chain.at(k), chain.at(k + 1))
                    let wa = sizes.at(k).at(a - 1).width
                    let wb = sizes.at(k + 1).at(b - 1).width
                    place(top + left, line(
                        start: (cx(k) + wa / 2 + inset, cy(a)),
                        end: (cx(k + 1) - wb / 2 - inset, cy(b)),
                        stroke: l.stroke,
                    ))
                }
            }
        }
        align(center, box(width: width, height: height, items + lines))
    }))
}

// A reading passage with an optional title, author and source line.
#let material(..args) = context {
    let named = args.named()
    let own = (:)
    for key in ("title", "author", "source") { own.insert(key, named.remove(key, default: none)) }
    let cfg = exam-state.get()
    let m = section-config(cfg, "material", named)
    let fmt(format, body) = apply-format(cfg, format, body)
    block(width: 100%, above: m.top-sep, below: m.bottom-sep, {
        if own.title != none or own.author != none {
            block(width: 100%, below: m.title-material-sep, align(center, {
                fmt(m.title-format, own.title)
                if own.title != none and own.author != none { h(m.title-author-sep) }
                fmt(m.author-format, own.author)
            }))
        }
        fmt(m.format, args.pos().join())
        if own.source != none {
            block(width: 100%, above: 0.4em, align(right, fmt(m.source-format, own.source)))
        }
    })
}

#let _zhu-counter = counter("exam-zh/zhu")

// A note inside `poem`, marked with a circled number.
#let _zhu-mark(n) = context {
    if exam-state.get().poem.zhu-circlednumber-base == "tikz" { circled-number(n) }
    else { numbering("①", n) }
}

#let zhu(note) = {
    _zhu-counter.step()
    context super(_zhu-mark(_zhu-counter.get().first()))
    [#metadata(note)<exam-zh-zhu>]
}

// A classical poem: centred as a block, lines separated with `\`.
// Notes made with `zhu` are listed after it.
#let poem(..args) = {
    let named = args.named()
    let own = (:)
    for key in ("title", "author") { own.insert(key, named.remove(key, default: none)) }
    _zhu-counter.update(0)
    [#metadata("start")<exam-zh-poem-start>]
    context {
        let cfg = exam-state.get()
        let p = section-config(cfg, "poem", named)
        let fmt(format, body) = apply-format(cfg, format, body)
        set par(first-line-indent: 0pt, justify: false)
        block(width: 100%, above: p.top-sep, below: p.title-poem-sep, align(center, {
            fmt(p.title-format, own.title)
            if own.title != none and own.author != none { h(p.title-author-sep) }
            fmt(p.author-format, own.author)
        }))
        block(width: 100%, below: p.bottom-sep, align(center, box(align(
            p.align,
            fmt(p.format, args.pos().join()),
        ))))
    }
    context {
        let cfg = exam-state.get()
        let p = section-config(cfg, "poem", named)
        let start = query(selector(<exam-zh-poem-start>).before(here())).last().location()
        let notes = query(selector(<exam-zh-zhu>).after(start).before(here()))
        if notes.len() == 0 { return }
        set par(first-line-indent: 0pt)
        set text(size: 0.9em)
        let numbered = notes.enumerate().map(((i, n)) => [#_zhu-mark(i + 1)#n.value])
        if p.type == "chinese" {
            block(width: 100%, [*［注］*#numbered.join(h(0.5em))])
        } else {
            block(width: 100%, {
                line(length: 30%, stroke: 0.4pt)
                numbered.join(linebreak())
            })
        }
    }
}

#let _cell-pattern(type, size, stroke) = {
    let dashed = (paint: stroke.paint, thickness: stroke.thickness * 0.6, dash: "dashed")
    if type == "口" { none }
    else {
        let cross = (
            place(line(start: (50%, 0%), end: (50%, 100%), stroke: dashed)),
            place(line(start: (0%, 50%), end: (100%, 50%), stroke: dashed)),
        )
        let diagonals = (
            place(line(start: (0%, 0%), end: (100%, 100%), stroke: dashed)),
            place(line(start: (100%, 0%), end: (0%, 100%), stroke: dashed)),
        )
        if type == "田" { cross.join() }
        else if type == "米" { (cross + diagonals).join() }
        else { panic("exam-zh: composition-grid frame-type must be 口, 田 or 米") }
    }
}

// A composition answer grid with at least `count` cells:
// `composition-grid(1000, count-marks: (600, 800))`.
#let composition-grid(count, ..args) = context {
    let cfg = exam-state.get()
    let g = section-config(cfg, "composition-grid", args.named())
    assert(count > 0 and g.columns > 0, message: "exam-zh: composition-grid needs a positive count and columns")
    let cell = if g.cell-size == auto { g.cell-scale * text.size } else { g.cell-size.to-absolute() }
    let rows = calc.ceil(count / g.columns)
    for mark in g.count-marks {
        assert(
            calc.rem(mark, g.columns) == 0 and mark <= rows * g.columns,
            message: "exam-zh: each count mark must be a multiple of the columns within the grid",
        )
    }
    let gap = cell / (g.row-sep-ratio + 1)
    let stroke = g.frame-linewidth + g.frame-color
    let pattern = _cell-pattern(g.frame-type, cell, stroke)
    let row(r) = {
        let cells = grid(
            columns: (cell,) * g.columns,
            rows: cell,
            stroke: stroke,
            fill: g.fill-color,
            ..range(g.columns).map(_ => pattern),
        )
        let total = (r + 1) * g.columns
        let mark = if total in g.count-marks {
            place(bottom + right, dx: g.count-sep + measure(apply-format(cfg, g.count-format, [#total])).width,
                apply-format(cfg, g.count-format, [#total]))
        }
        block(spacing: gap, breakable: false, box[#cells#mark])
    }
    block(width: 100%, breakable: g.auto-break, {
        set par(first-line-indent: 0pt)
        for r in range(rows) { row(r) }
    })
}
