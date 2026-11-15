// Questions, answer blanks, solutions and solution-step lists.

#import "config.typ": (
    apply-format, exam-state, fillin-counter, format-label, question-counter,
    section-config, spread, with-setup,
)
#import "page.typ": column-edges, geometry


// Whether the current context is inside an equation. The template sets the
// math font only there. (A show rule on equations cannot mark them instead:
// wrapping an equation in other content loses its line height.)
#let _in-math(cfg) = {
    let font = text.font
    let first = if type(font) == array { font.first() } else { font }
    let name = if type(first) == dictionary { first.name } else { first }
    type(name) == str and lower(name) == lower(cfg.font.math)
}

// Split `args` into the body, the named options in `keys`, and the rest.
#let _split(args, keys) = {
    let named = args.named()
    let picked = (:)
    for (key, default) in keys {
        picked.insert(key, named.at(key, default: default))
        let _ = named.remove(key, default: none)
    }
    (args.pos(), picked, named)
}

#let _points(q, points, kind) = {
    let visible = if q.show-points == auto { kind == "problem" } else { q.show-points }
    if visible and points != none and points != 0 {
        [#q.points-prelabel#points#h(0.25em)#q.points-postlabel]
    }
}

#let _enum-numbering(patterns) = (..nums) => {
    let nums = nums.pos()
    let pattern = patterns.at(calc.min(nums.len(), patterns.len()) - 1)
    numbering(pattern, nums.last())
}

// The blank of a `combine-fillin` question, set before its number.
#let _combined-fillin(spec, fillin) = {
    if spec == none or spec == false { return none }
    let spec = if spec == true { (:) } else { spec }
    let args = spec
    let answer = args.remove("answer", default: none)
    if answer == none { fillin(..args) } else { fillin(..args, answer) }
}

#let _question(kind, fillin, args) = {
    let (pos, own, overrides) = _split(args, (
        points: none,
        index: none,
        show-answer: none,
    ))
    assert(pos.len() == 1, message: "exam-zh: " + kind + " takes one body")
    let body = pos.first()
    let scoped = if own.show-answer == none { (:) } else {
        (question: (show-answer: own.show-answer))
    }
    if own.index != none { question-counter.update(own.index) } else { question-counter.step() }
    with-setup(scoped, context {
        let cfg = exam-state.get()
        let q = section-config(cfg, kind, overrides)
        let n = question-counter.get().first()
        let combined = if kind == "question" { _combined-fillin(q.combine-fillin, fillin) }
        // The label box widens for long labels such as "第 10 题".
        let number = format-label(q.label, n)
        let label = box(
            width: calc.max(q.label-width.to-absolute(), measure(number).width),
            align(q.label-align, number),
        )
        let label = if combined == none { label } else { box[#combined#h(0.3em)#label] }
        let label-width = measure(label).width
        let indent = label-width + q.label-sep.to-absolute()
        let points = _points(q, own.points, kind)
        let lead = [#label#h(q.label-sep)#points]

        set enum(numbering: _enum-numbering(q.enum-numbering), full: true, body-indent: 0.25em)
        // A label hung `by` to the left of the line start, so the text
        // after it starts where the line would.
        let hung(by) = box(width: 0pt, place(bottom + left, dx: -by, box(width: label-width, label)))
        let separate = kind == "problem" and q.points-separate-par and points != none
        let content = if separate {
            // The number and points on their own line, then the body with
            // indented paragraphs.
            set par(first-line-indent: (amount: 2em, all: true))
            block(spacing: 0.6em, par(first-line-indent: 0pt, lead))
            set enum(indent: 2em)
            body
        } else if q.hang {
            // Continuation lines align with the text after the label, which
            // hangs into the margin of the padded body.
            set par(first-line-indent: 0pt)
            pad(left: indent, [#hung(indent)#points#body])
        } else if kind == "problem" {
            // Paragraphs are indented 2em; the label sits in the first indent.
            set par(first-line-indent: (amount: 2em, all: true))
            set enum(indent: 2em)
            let extra = calc.max(0pt, indent - 2em.to-absolute())
            [#hung(2em.to-absolute())#h(extra)#points#body]
        } else {
            set par(first-line-indent: 0pt)
            [#lead#body]
        }
        block(width: 100%, above: q.top-sep, below: q.bottom-sep, content)
    })
}

// Answer parentheses at the end of the line: `paren[B]`.
// `wide: true` leaves a 3em blank, like `\paren*`.
#let paren(..args) = context {
    let (pos, own, overrides) = _split(args, (wide: false))
    let answer = pos.at(0, default: none)
    let p = section-config(exam-state.get(), "paren", overrides)
    if not (p.show-paren or p.show-answer) { return }
    let inner = if p.show-answer and answer != none {
        [#h(0.7em)#text(fill: p.text-color, answer)#h(0.7em)]
    } else {
        h(if own.wide { 3em } else { p.width })
    }
    let parens = box[（#inner）]
    if p.type == "none" { return parens }
    let fill = if p.type == "dotfill" {
        box(width: 1fr, repeat(gap: 0.2em)[.])
    } else { h(1fr) }
    // The zero-width space lets the parentheses move to the end of the next
    // line when they do not fit on this one.
    // The box keeps the second fill when the line breaks there.
    [#fill#sym.zws#box()#fill#parens]
}

#let _triangle(size: 0.55em) = box(polygon(
    fill: black,
    (0pt, size * 0.866),
    (size, size * 0.866),
    (size / 2, 0pt),
))

#let _centered(width, body) = box(width: width, [#h(1fr)#body#h(1fr)])

// Draw the blank of type `f.type` around `body`.
#let _decorate(f, body, width: auto) = {
    let line = f.stroke + f.box-color
    let padded = if width == auto { [#h(0.5em)#body#h(0.5em)] } else { _centered(width, body) }
    if f.type == "line" {
        box(stroke: (bottom: line), outset: (bottom: f.depth), padded)
    } else if f.type == "paren" {
        let (l, r) = if f.paren-type == "quanjiao" { ("（", "）") } else { ("(", ")") }
        [#l#padded#r]
    } else if f.type == "rectangle" {
        box(stroke: line, inset: (x: 0.15em, y: 0.25em), outset: (y: 0.05em), padded)
    } else if f.type == "circle" {
        // A circle around short answers that stretches for longer ones.
        let inner = if width == auto { body } else { _centered(width, body) }
        let size = measure(inner)
        let height = calc.max(size.height, 0.7em.to-absolute()) + 0.4em.to-absolute()
        box(
            width: calc.max(size.width + 0.6em.to-absolute(), height),
            inset: (y: (height - size.height) / 2),
            radius: height / 2,
            stroke: line,
            [#h(1fr)#inner#h(1fr)],
        )
    } else if f.type == "blank" {
        padded
    } else {
        panic("exam-zh: unknown fillin type " + repr(f.type))
    }
}

// Whether content contains an equation.
#let _has-math(it) = {
    if type(it) != content { return false }
    if it.func() == math.equation { return true }
    if it.has("children") { return it.children.any(_has-math) }
    if it.has("body") { return _has-math(it.body) }
    if it.has("child") { return _has-math(it.child) }
    false
}

// The usable width of the column holding the current location.
#let _column-width() = {
    let cfg = exam-state.get()
    let edges = column-edges(geometry(cfg), here().page())
    edges.first().right - edges.first().left
}

// A long blank that breaks across lines, as `\fillin*`: a chain of short
// underlined boxes with a break opportunity between each pair.
#let _breakable-blank(f, width) = {
    let line = (bottom: f.stroke + f.box-color)
    let step = 0.5em.to-absolute()
    let n = calc.max(1, int(calc.ceil(width / step)))
    let segment = box(width: step, stroke: line, outset: (bottom: f.depth))
    let tail = if f.width-type == "fill" { box(width: 1fr, stroke: line, outset: (bottom: f.depth)) }
    [#range(n).map(_ => segment).join(sym.zws)#tail]
}

// A fill-in blank: `fillin[答案]` or `fillin()`. The answer shows only with
// `show-answer`; otherwise the blank holds a triangle, a running number, or
// empty space of `width`. `breakable: true` lets a long blank wrap.
#let fillin(..args) = context {
    let (pos, own, overrides) = _split(args, (breakable: false))
    let answer = pos.at(0, default: none)
    let cfg = exam-state.get()
    let f = section-config(cfg, "fillin", overrides)
    let has-answer = answer != none and answer != []
    if f.show-answer and has-answer {
        let body = text(fill: f.text-color, answer)
        let long = measure(body).width > _column-width() - 4em.to-absolute()
        // A text answer is underlined as text, so it wraps wherever the line
        // ends. An answer with math keeps the boxed underline, which runs
        // under the formula and drops below tall fractions.
        if f.type == "line" and (own.breakable or long or not _has-math(answer)) {
            underline(offset: f.depth, stroke: f.stroke + f.box-color, evade: false, [\u{2002}#body\u{2002}])
        } else {
            _decorate(f, body)
        }
    } else if f.no-answer-type == "blacktriangle" {
        _decorate(f, _triangle())
    } else if f.no-answer-type == "counter" {
        fillin-counter.step()
        _decorate(f, context format-label(f.no-answer-counter-label, fillin-counter.get().first()))
    } else if f.no-answer-type == "none" {
        let width = if f.width == auto {
            if has-answer { measure(answer).width + f.width-extra.to-absolute() } else { 3em.to-absolute() }
        } else { f.width }
        let column = _column-width()
        let width = if type(width) == ratio { width * column }
            else if type(width) == relative { width.ratio * column + width.length.to-absolute() }
            else { width.to-absolute() }
        if f.type in ("line", "blank") and (own.breakable or width > column) {
            _breakable-blank(f, width)
        } else {
            _decorate(f, none, width: width)
        }
    } else {
        panic("exam-zh: unknown fillin no-answer-type " + repr(f.no-answer-type))
    }
}

// A choice or fill-in question: `question[...]`, `question(points: 5)[...]`.
#let question(..args) = _question("question", fillin, args)

// A free-response problem; points show by default and sit on their own line.
#let problem(..args) = _question("problem", fillin, args)

// A scoring point inside a solution: `score(2)`, with a dotted leader to the
// right margin. It also works at the end of a display equation.
#let score(points) = context {
    let cfg = exam-state.get()
    let s = cfg.solution
    let label = apply-format(cfg, s.score-format, [#s.score-pre-content#points#s.score-post-content])
    let dot = box(width: 0.44em, align(center, $dot.c$))
    if _in-math(cfg) {
        // In an equation, draw from here to the column's right edge without
        // taking space, so the equation stays centred.
        let x = here().position().x
        let edges = column-edges(geometry(cfg), here().page())
        let edge = edges.find(e => x < e.right)
        let right = if edge == none { edges.last().right } else { edge.right }
        let width = calc.max(right - x, measure(label).width)
        box(width: 0pt, place(left + bottom, dy: 0.25em, box(width: width, if s.score-showleader {
            [#box(width: 1fr, repeat(dot))#label]
        } else {
            [#h(1fr)#label]
        })))
    } else {
        let leader = if s.score-showleader { box(width: 1fr, repeat(dot)) } else { h(1fr) }
        [#leader#label#linebreak()]
    }
}

// A worked solution. `solution.show-solution` hides it, prints it here
// ("show-stay"), or collects it for `print-moved-solutions` ("show-move").
#let solution(..args) = context {
    let (pos, _, overrides) = _split(args, (:))
    assert(pos.len() == 1, message: "exam-zh: solution takes one body")
    let body = pos.first()
    let cfg = exam-state.get()
    let s = section-config(cfg, "solution", overrides)
    let mode = s.show-solution
    if mode == "hide" {
        if s.blank-type == "manual" { v(s.blank-vsep) }
        else if s.blank-type == "hide" { block(width: 100%, hide(body)) }
        else { assert(s.blank-type == "none", message: "exam-zh: unknown solution blank-type " + repr(s.blank-type)) }
    } else if mode == "show-stay" {
        let label = apply-format(cfg, s.label-format, [#s.label-content#s.label-punct])
        block(width: 100%, above: s.top-sep, below: s.bottom-sep)[
            #set par(first-line-indent: (amount: if s.label-indentation { 2em } else { 0pt }, all: true))
            #label#h(0.5em)#if s.parbreak { parbreak() }#text(fill: s.text-color, body)#if s.show-qed [#h(1fr)#s.qedsymbol]
        ]
    } else if mode == "show-move" {
        [#metadata((n: question-counter.get().first(), body: body, pre: s.pre-analysis))<exam-zh-moved-solution>]
    } else {
        panic("exam-zh: unknown solution show-solution " + repr(mode))
    }
}

#let _moved-solutions(mark) = context {
    let items = query(<exam-zh-moved-solution>)
    if items.len() == 0 { return }
    let cfg = exam-state.get()
    let s = cfg.solution
    pagebreak(weak: true)
    if mark { [#metadata("printed")<exam-zh-moved-printed>] }
    align(center, apply-format(cfg, (family: "sans", size: 18pt), spread(s.moved-title, 5em)))
    v(1.5em)
    set par(first-line-indent: 0pt)
    set enum(numbering: _enum-numbering(cfg.problem.enum-numbering), full: true, body-indent: 0.25em)
    apply-format(cfg, s.moved-format, for item in items {
        let v = item.value
        block(spacing: 1em)[#v.n.#v.pre#v.body]
    })
}

// Print the solutions collected by `show-move` here. Without this call the
// template prints them at the end of the document.
#let print-moved-solutions() = _moved-solutions(true)

#let _list-stacks = (
    step: state("exam-zh/list-step", ()),
    method: state("exam-zh/list-method", ()),
    case: state("exam-zh/list-case", ()),
)

#let _exam-list(kind, items) = context {
    let cfg = exam-state.get()
    let l = cfg.list
    let stack = _list-stacks.at(kind)
    let parents = stack.get()
    let name = l.at(kind + "-name")
    let punct = l.at(kind + "-punct")
    let indent = l.indent.to-absolute()
    for (i, item) in items.enumerate() {
        let number = if kind == "method" { numbering("一", i + 1) }
            else { (parents + (i + 1,)).map(str).join(".") }
        let label = apply-format(cfg, l.label-format, [#name#number#punct])
        stack.update(p => p + (i + 1,))
        block(width: 100%, spacing: 0.6em, {
            set par(first-line-indent: 0pt)
            if parents.len() == 0 {
                pad(left: indent)[#h(-indent)#box(width: indent - 0.5em, label)#h(0.5em)#item]
            } else {
                [#label#h(0.5em)#item]
            }
        })
        stack.update(p => p.slice(0, -1))
    }
}

// 步骤1. 步骤2. … ; nested steps are numbered 1.1, 1.2.
#let step(..items) = _exam-list("step", items.pos())
// 方法一 方法二 …
#let method(..items) = _exam-list("method", items.pos())
// 情形1. 情形2. … ; nested cases are numbered 1.1, 1.2.
#let case(..items) = _exam-list("case", items.pos())
