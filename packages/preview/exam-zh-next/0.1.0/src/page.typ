// Page geometry, header and footer, seal line (密封线) and draft paper.

#import "config.typ": apply-format, exam-state, merge, plain-text, resolve-size

#let _papers = (
    a4: (width: 210mm, height: 297mm, columns: 1),
    a3: (width: 420mm, height: 297mm, columns: 2),
)

// The resolved sheet: size, columns and margins as absolute lengths.
// `inside` is the binding side: left on odd pages, right on even pages.
#let geometry(cfg) = {
    let page = cfg.page
    let seal = cfg.sealline.enable
    let paper = if type(page.size) == str {
        assert(
            page.size in _papers,
            message: "exam-zh: page.size must be \"a4\", \"a3\" or (width, height)",
        )
        _papers.at(page.size)
    } else {
        assert(
            type(page.size) == array and page.size.len() == 2,
            message: "exam-zh: a custom page.size is (width, height)",
        )
        (width: page.size.at(0), height: page.size.at(1), columns: 1)
    }
    let base = if seal and page.size == "a4" {
        (inside: 1.3in, outside: 0.8in, top: 1in, bottom: 1in)
    } else if seal and page.size == "a3" {
        (inside: 1.2in, outside: 0.8in, top: 1in, bottom: 1in)
    } else {
        (inside: 1in, outside: 1in, top: 1in, bottom: 1in)
    }
    let margin = page.margin
    if type(margin) == length {
        base = (inside: margin, outside: margin, top: margin, bottom: margin)
    } else if type(margin) == dictionary {
        for (key, value) in margin {
            if key == "rest" { base = (inside: value, outside: value, top: value, bottom: value) }
        }
        for (key, value) in margin {
            if key in ("inside", "left") { base.inside = value }
            else if key in ("outside", "right") { base.outside = value }
            else if key == "x" { base.inside = value; base.outside = value }
            else if key == "y" { base.top = value; base.bottom = value }
            else if key in ("top", "bottom") { base.insert(key, value) }
            else if key != "rest" { panic("exam-zh: unknown page.margin key " + repr(key)) }
        }
    } else {
        assert(margin == auto, message: "exam-zh: page.margin must be auto, a length or a dictionary")
    }
    (
        width: paper.width,
        height: paper.height,
        columns: paper.columns,
        gutter: page.column-gutter,
        // Two-sided margins only matter with a seal line or an explicit
        // inside/outside pair.
        twoside: base.inside != base.outside,
        ..base,
    )
}

// The current settings, or `initial` before `exam` has stored them.
#let _current(initial) = {
    let cfg = exam-state.get()
    if cfg.ready { cfg } else { initial }
}

// Left and right margins of physical page `p`.
#let side-margins(geo, p) = {
    if not geo.twoside or calc.odd(p) { (left: geo.inside, right: geo.outside) }
    else { (left: geo.outside, right: geo.inside) }
}

// x positions (from the page's left edge) of the column edges on page `p`.
#let column-edges(geo, p) = {
    let m = side-margins(geo, p)
    let body = geo.width - m.left - m.right
    let col = (body - (geo.columns - 1) * geo.gutter) / geo.columns
    range(geo.columns).map(i => {
        let left = m.left + i * (col + geo.gutter)
        (left: left, right: left + col)
    })
}

#let _foot-text(foot, n, total) = {
    if type(foot) == function { foot(n, total) }
    else if type(foot) == str and foot.contains(";") {
        let parts = foot.split(";")
        assert(parts.len() <= 3, message: "exam-zh: page.foot may contain at most two `;`")
        if parts.len() == 2 { [#parts.at(0)#n#parts.at(1)] }
        else { [#parts.at(0)#n#parts.at(1)#total#parts.at(2)] }
    } else { foot }
}

#let footer(geo, initial) = context {
    let cfg = _current(initial)
    if not cfg.page.show-foot { return }
    let n = counter(page).get().first()
    let total = counter(page).final().first()
    let fmt(body) = apply-format(cfg, cfg.page.foot-format, body)
    if geo.columns == 2 and cfg.page.foot-type == "separate" {
        grid(
            columns: (1fr, 1fr),
            column-gutter: geo.gutter,
            align(center, fmt(_foot-text(cfg.page.foot, 2 * n - 1, 2 * total))),
            align(center, fmt(_foot-text(cfg.page.foot, 2 * n, 2 * total))),
        )
    } else {
        align(center, fmt(_foot-text(cfg.page.foot, n, total)))
    }
}

#let header(initial) = context {
    let cfg = _current(initial)
    if not cfg.page.show-head or cfg.page.head == none { return }
    let head = cfg.page.head
    if type(head) == function { head(counter(page).get().first()) } else { head }
}

// TikZ-style line names, as in exam-zh's sealline/line-type.
#let _dash(name) = {
    if type(name) != str { return name }
    let dots(on, off) = (on, off, 0.5pt, off, 0.5pt, off)
    let table = (
        "solid": none,
        "dotted": "dotted",
        "densely-dotted": "densely-dotted",
        "loosely-dotted": "loosely-dotted",
        "dashed": "dashed",
        "densely-dashed": "densely-dashed",
        "loosely-dashed": "loosely-dashed",
        "dash-dot": "dash-dotted",
        "densely-dash-dot": "densely-dash-dotted",
        "loosely-dash-dot": "loosely-dash-dotted",
        "dash-dot-dot": dots(3pt, 2pt),
        "densely-dash-dot-dot": dots(3pt, 1pt),
        "loosely-dash-dot-dot": dots(3pt, 4pt),
    )
    assert(name in table, message: "exam-zh: unknown sealline line-type " + repr(name))
    table.at(name)
}

#let _scope-has(scope, p, last) = {
    if scope == "firstpage" { p == 1 }
    else if scope == "oddpage" { calc.odd(p) }
    else if scope == "everypage" { true }
    else if scope == "first-and-last" { p == 1 or p == last }
    else if scope.starts-with("mod-") { calc.rem(p, int(scope.slice(4))) == 1 }
    else { panic("exam-zh: unknown sealline scope " + repr(scope)) }
}

#let _info-content(cfg, side) = {
    let items = side.info.map(item => {
        if type(item) == array {
            let (label, width) = item
            [#label：#box(width: width, stroke: (bottom: 0.5pt), outset: (bottom: 2pt))]
        } else { item }
    })
    apply-format(cfg, side.info-format, items.join(side.info-separator))
}

// The spread seal-line text, upright or along the line.
#let _seal-text(cfg, side, length, odd) = {
    let fmt(body) = apply-format(cfg, side.text-format, body)
    let txt = plain-text(side.text)
    assert(txt != none, message: "exam-zh: sealline text must be plain text")
    let chars = txt.clusters().filter(c => c.trim() != "")
    if side.text-direction-vertical {
        let column = box(height: length, stack(
            dir: ttb,
            ..chars.map(c => align(center, fmt(c))).intersperse(v(1fr)),
        ))
        scale(x: side.text-xscale, y: side.text-yscale, reflow: true, column)
    } else {
        let line = box(width: length, fmt(chars.join(h(1fr))))
        let scaled = scale(x: side.text-xscale, y: side.text-yscale, reflow: true, line)
        rotate(if odd { -90deg } else { 90deg }, reflow: true, scaled)
    }
}

// Seal line, circles, text and student information for physical page `p`.
#let sealline(geo, p, cfg) = {
    let seal = cfg.sealline
    // The scope counts pages as numbered (the table of contents is not
    // counted); the side follows the physical page, like the margins.
    let n = counter(page).get().first()
    let last = counter(page).final().first()
    if not seal.enable or not _scope-has(seal.scope, n, last) { return }

    let odd = calc.odd(p)
    let common = seal
    let _ = common.remove("odd")
    let _ = common.remove("even")
    let side = merge(common, if odd { seal.odd } else { seal.even }, path: "sealline.")
    if not odd and "info" not in seal.even { side.info = none }

    let m = side-margins(geo, p)
    let height = geo.height - geo.top - geo.bottom
    let middle = geo.top + height / 2
    // Distance from the text area towards the page edge.
    let edge = if odd { m.left } else { geo.width - m.right }
    let out(shift) = if odd { edge - shift.to-absolute() } else { edge + shift.to-absolute() }
    let at(x, y, body) = place(top + left, dx: x, dy: y, body)

    // The line.
    let yshift = side.line-yshift.to-absolute()
    at(out(side.line-xshift), geo.top + yshift, line(
        angle: 90deg,
        length: height - 2 * yshift,
        stroke: (paint: black, thickness: side.line-thickness, dash: _dash(side.line-type)),
    ))

    // Binding holes along the line.
    if side.circle-show {
        let d = side.circle-diameter.to-absolute()
        let step = side.circle-step.to-absolute()
        let start = side.circle-start * height
        let stop = side.circle-end * height
        let pos = start
        while pos <= stop + 0.01pt {
            at(out(side.circle-xshift) - d / 2, geo.top + pos - d / 2, circle(
                radius: d / 2,
                fill: white,
                stroke: 0.5pt + black,
            ))
            pos += step
        }
    }

    // Text along the line.
    if side.text != none and side.text != "" {
        let length = resolve-size(side.text-width, height)
        let body = _seal-text(cfg, side, length, odd)
        let size = measure(body)
        let yshift = side.text-yshift.to-absolute()
        let dy = if odd or side.text-direction-vertical { -yshift } else { yshift }
        let x = if odd { out(side.text-xshift) - size.width } else { out(side.text-xshift) }
        at(x, middle - size.height / 2 + dy, body)
    }

    // Student information.
    if side.info != none and side.info.len() > 0 {
        let body = rotate(if odd { -90deg } else { 90deg }, reflow: true, _info-content(cfg, side))
        let size = measure(body)
        let yshift = side.info-yshift.to-absolute()
        // Alignment is read along the rotated line: left is the start of the text.
        let y = if side.info-align == center { middle - size.height / 2 }
            else if (side.info-align == left) == odd { geo.top + height - size.height }
            else { geo.top }
        let x = if odd { out(side.info-xshift) - size.width } else { out(side.info-xshift) }
        at(x, y - yshift, body)
    }
}

#let columnline(geo, p, cfg) = {
    if geo.columns < 2 or not cfg.page.show-columnline { return }
    let edges = column-edges(geo, p)
    for i in range(1, edges.len()) {
        let x = (edges.at(i - 1).right + edges.at(i).left) / 2
        place(top + left, dx: x, dy: geo.top, line(
            angle: 90deg,
            length: geo.height - geo.top - geo.bottom,
            stroke: cfg.page.columnline-stroke,
        ))
    }
}

#let background(geo, initial) = context {
    let cfg = _current(initial)
    let p = here().page()
    sealline(geo, p, cfg)
    columnline(geo, p, cfg)
}

// A blank draft sheet (草稿纸). It is not counted in the page total.
#let draftpaper(..args) = context {
    let cfg = exam-state.get()
    let draft = merge(cfg.draft, args.named(), path: "draft.")
    let size = if draft.watermark-size != auto { draft.watermark-size }
        else if cfg.page.size == "a3" { 180pt } else { 100pt }
    let mark = if draft.show-watermark {
        place(center + horizon, apply-format(
            cfg,
            (family: "sans", size: size, fill: draft.watermark-color),
            draft.watermark-text,
        ))
    }
    page(header: none, footer: none, foreground: mark)[
        #counter(page).update(n => n - 1)
        #metadata("draft")<exam-zh-draft>
    ]
}
