// Shared layout of the exam-zh guide (guide.typ) and API reference
// (reference.typ): document styling, live examples and callout boxes.

#import "../src/lib.typ" as ez
#import "../src/lib.typ": *
#import "../src/config.typ": default-config, exam-state, font-family, question-counter, with-setup
#import "../src/template.typ": _section

#let doc-config = (
    code-size: 8.2pt,
    latex: (label: [LaTeX（exam-zh）], fill: rgb("#fbf3e8"), accent: rgb("#b4692a")),
    typst: (label: [Typst（本模板）], fill: rgb("#ecf3fb"), accent: rgb("#2b6cb0")),
    result: (label: [效果], accent: luma(45%)),
    frame: 0.5pt + luma(78%),
    tips: (
        info: (fill: rgb("#eef5fd"), accent: rgb("#2b6cb0")),
        warn: (fill: rgb("#fff7e6"), accent: rgb("#c77700")),
        good: (fill: rgb("#eefaf0"), accent: rgb("#2f855a")),
        bad: (fill: rgb("#fdeeee"), accent: rgb("#c53030")),
    ),
)

// Run an example in an isolated scope: its settings do not leak, its
// questions start at 1, and its `=` headings become exam sections at level 6
// so they stay out of the document's numbering and outline.
// Drop a full document's preamble (`#import` and `#show: exam.with(..)`), so
// a complete example can be shown as written and run inside the document;
// pass the options the preamble sets as `setup`.
#let _body(src) = {
    let out = ()
    let skipping = false
    for line in src.split("\n") {
        let t = line.trim()
        if skipping {
            if t == ")" { skipping = false }
        } else if t.starts-with("#import \"") {
        } else if t.starts-with("#show: exam") {
            // A call spanning several lines ends at a line holding only ")".
            skipping = t.contains("(") and not t.ends-with(")")
        } else {
            out.push(line)
        }
    }
    out.join("\n")
}

#let run(src, mode: "student", setup: (:)) = {
    let src = _body(src)
    question-counter.update(0)
    counter(heading).update((..n) => n.pos().slice(0, calc.min(n.pos().len(), 5)))
    set heading(offset: 5, outlined: false, bookmarked: false, numbering: (..n) => numbering("一、", n.pos().last()))
    show heading.where(level: 6): it => context _section(exam-state.get(), it)
    let options = (mode: mode) + (if mode == "teacher" { teacher-defaults } else { (:) }) + setup
    with-setup(options, eval(src, mode: "markup", scope: dictionary(ez)))
}

#let _label-bar(spec, body: none) = block(
    width: 100%,
    spacing: 0pt,
    inset: (x: 0.7em, y: 0.3em),
    fill: spec.at("fill", default: white),
    text(size: 7.5pt, weight: "bold", fill: spec.accent, if body == none { spec.label } else { body }),
)

#let _code(spec, code) = block(width: 100%, spacing: 0pt, fill: spec.fill, inset: (x: 0.8em, bottom: 0.7em, top: 0.1em), {
    set par(first-line-indent: 0pt, justify: false)
    code
})

#let _result(body) = block(width: 100%, spacing: 0pt, inset: 0.8em, body)

#let _frame(title, parts) = block(
    width: 100%,
    above: 0.9em,
    below: 0.9em,
    breakable: true,
    stroke: doc-config.frame,
    radius: 3pt,
    clip: true,
    {
        if title != none {
            block(width: 100%, spacing: 0pt, fill: luma(30%), inset: (x: 0.8em, y: 0.4em),
                text(fill: white, size: 8.5pt, weight: "bold", title))
        }
        parts.filter(p => p != none).join(line(length: 100%, stroke: doc-config.frame))
    },
)

#let _versions(src, setup) = grid(
    columns: (1fr, 1fr),
    column-gutter: 1.2em,
    block(width: 100%, { block(below: 0.4em, text(size: 7.5pt, fill: luma(45%))[学生版]); run(src, setup: setup) }),
    block(width: 100%, { block(below: 0.4em, text(size: 7.5pt, fill: luma(45%))[教师版]); run(src, mode: "teacher", setup: setup) }),
)

// A Typst example and its result. `versions: true` shows the student and
// teacher versions side by side; `show-result: false` shows only the code.
#let demo(code, title: none, versions: false, setup: (:), show-result: true) = _frame(title, (
    _label-bar(doc-config.typst),
    _code(doc-config.typst, code),
    if show-result {
        _result(if versions { _versions(code.text, setup) } else { run(code.text, setup: setup) })
    },
))

// The exam-zh LaTeX code, its Typst translation, and the Typst result.
#let compare(latex, typst, title: none, versions: false, setup: (:), show-result: true) = _frame(title, (
    _label-bar(doc-config.latex),
    _code(doc-config.latex, latex),
    _label-bar(doc-config.typst),
    _code(doc-config.typst, typst),
    if show-result and typst != none {
        _result(if versions { _versions(typst.text, setup) } else { run(typst.text, setup: setup) })
    },
))

// LaTeX-only code (a shell command, a LaTeX snippet) in a plain frame.
#let code-only(code, spec: doc-config.typst, title: none) = _frame(title, (_label-bar(spec), _code(spec, code)))

// A callout box: kind is "info", "warn", "good" or "bad".
#let tip(title, body, kind: "info") = {
    let spec = doc-config.tips.at(kind)
    block(width: 100%, above: 0.9em, below: 0.9em, breakable: true, fill: spec.fill, radius: 3pt,
        stroke: (left: 2.5pt + spec.accent), inset: (x: 0.9em, y: 0.7em), {
            set par(first-line-indent: 0pt)
            if title != none { block(below: 0.5em, sticky: true, text(weight: "bold", fill: spec.accent, title)) }
            body
        })
}

// A page rendered from one of the examples (see scripts/doc-images.sh).
#let shot(name, width: 100%, caption: none) = figure(
    box(stroke: doc-config.frame, image("images/" + name + ".png", width: width)),
    caption: caption,
    supplement: none,
    numbering: none,
)

// One dictionary entry: the exam-zh names, their Typst equivalents, the two
// syntaxes, and the explanation.
#let entry(latex-names, typst-names, latex-syntax: none, typst-syntax: none, status: none, body) = {
    let names(list, accent) = if type(list) == array { list } else { (list,) }
    let mono(s) = if type(s) == str { raw(s) } else { s }
    block(width: 100%, above: 1.3em, below: 0.7em, breakable: false, {
        set par(first-line-indent: 0pt, justify: false)
        grid(
            columns: (1fr, auto, 1fr),
            column-gutter: 0.6em,
            align: (left + horizon, center + horizon, left + horizon),
            text(fill: doc-config.latex.accent, weight: "bold", names(latex-names, none).map(mono).join([，])),
            text(fill: luma(55%), sym.arrow.r),
            text(fill: doc-config.typst.accent, weight: "bold", names(typst-names, none).map(mono).join([，])),
        )
        if status != none {
            block(above: 0.3em, below: 0pt, box(fill: doc-config.tips.warn.fill, inset: (x: 0.4em, y: 0.15em), radius: 2pt,
                text(size: 7.5pt, fill: doc-config.tips.warn.accent, status)))
        }
        if latex-syntax != none or typst-syntax != none {
            block(above: 0.5em, below: 0pt, grid(
                columns: (1fr, 1fr),
                column-gutter: 0.6em,
                block(width: 100%, fill: doc-config.latex.fill, inset: 0.5em, radius: 2pt, if latex-syntax != none { latex-syntax }),
                block(width: 100%, fill: doc-config.typst.fill, inset: 0.5em, radius: 2pt, if typst-syntax != none { typst-syntax }),
            ))
        }
    })
    block(above: 0.5em, below: 0.8em, body)
}

// The document setup shared by both docs.
#let doc(title: none, subject: none, body) = {
    show: exam.with(
        title: title,
        subject: subject,
        page: (foot: (page, total) => [#page / #total]),
        make-title: (subject-format: (family: "sans", weight: "bold", size: 20pt)),
    )
    set heading(numbering: "1.1.1")
    let number(it) = if it.numbering != none [#counter(heading).display(it.numbering)#h(0.6em)]
    show heading.where(level: 1): it => {
        pagebreak(weak: true)
        block(above: 1em, below: 1.2em, text(size: 17pt, weight: "bold", [#number(it)#it.body]))
    }
    show heading.where(level: 2): it => block(above: 1.6em, below: 0.9em, sticky: true,
        text(size: 13pt, weight: "bold", [#number(it)#it.body]))
    show heading.where(level: 3): it => block(above: 1.3em, below: 0.7em, sticky: true,
        text(size: 11pt, weight: "bold", [#number(it)#it.body]))
    show heading.where(level: 4): it => block(above: 1em, below: 0.6em, sticky: true,
        text(size: 10.5pt, weight: "bold", it.body))
    show raw: it => context text(
        font: ("DejaVu Sans Mono",) + font-family(exam-state.get(), "sans"),
        size: if it.block { doc-config.code-size } else { 0.92em },
        it,
    )
    show raw.where(block: true): set par(leading: 0.5em, justify: false)
    show link: it => text(fill: doc-config.typst.accent, it)
    show outline.entry.where(level: 1): set block(above: 1em)
    set table(stroke: 0.4pt + luma(70%), inset: (x: 0.5em, y: 0.4em))
    show table: set par(first-line-indent: 0pt, justify: false)
    body
}
