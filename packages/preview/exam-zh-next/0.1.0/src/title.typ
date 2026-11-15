// Title block, notices, scoring boxes, answer squares and exam collections.

#import "config.typ": apply-format, exam-state, merge, question-counter, spread
#import "page.typ": geometry

// Title and subject. Both default to the values given to `exam`.
#let make-title(title: auto, subject: auto, subject-width: auto) = context {
    let cfg = exam-state.get()
    let t = cfg.make-title
    let title = if title == auto { cfg.meta.title } else { title }
    let subject = if subject == auto { cfg.meta.subject } else { subject }
    let width = if subject-width == auto { cfg.meta.subject-width } else { subject-width }
    set par(first-line-indent: 0pt)
    v(t.top-sep)
    if title != none {
        align(center, apply-format(cfg, t.title-format, title))
    }
    if subject != none {
        v(t.subject-sep)
        let body = apply-format(cfg, t.subject-format, subject)
        // exam-zh measures the subject at body size, so the default spreads
        // it over twice its body-size width.
        let natural = measure(body).width
        let width = if width == auto { 2 * measure(subject).width } else { width.to-absolute() }
        align(center, apply-format(cfg, t.subject-format, spread(subject, calc.max(width, natural + 0.1pt))))
    }
    v(t.bottom-sep)
}

// 绝密★启用前
#let secret(body: [绝密 #sym.star.filled 启用前], format: (weight: "bold")) = context {
    block(spacing: 0.6em, apply-format(exam-state.get(), format, body))
}

// A centred row of student-information fields.
#let information(..items, separator: h(1em)) = {
    block(width: 100%, align(center, items.pos().join(separator)))
}

// A centred warning such as （在此卷上答题无效）.
#let warning(body, format: (family: "sans", weight: "bold", size: 12pt)) = context {
    block(width: 100%, align(center, apply-format(exam-state.get(), format, body)))
}

// 注意事项：each positional argument is one numbered item.
#let notice(..args) = context {
    let cfg = exam-state.get()
    let n = merge(cfg.notice, args.named(), path: "notice.")
    set par(first-line-indent: 0pt)
    block(width: 100%, above: n.top-sep, below: n.bottom-sep, {
        block(spacing: 0.5em, apply-format(cfg, n.label-format, n.label))
        for (i, item) in args.pos().enumerate() {
            block(spacing: 0.5em)[
                #h(n.indent)#box(width: 1.5em, align(right, numbering(n.numbering, i + 1)))#h(0.5em)#item
            ]
        }
    })
}

// A grade box (评分框): 得分/阅卷人 rows, or a single 得分 column.
#let scoringbox(simple: false) = context {
    let s = exam-state.get().scoringbox
    box(baseline: 50%, if simple {
        table(
            columns: s.cell-width,
            rows: s.cell-height,
            align: center + horizon,
            [得分], [],
        )
    } else {
        table(
            columns: (auto, s.cell-width),
            rows: s.cell-height,
            align: center + horizon,
            [得分], [], [阅卷人], [],
        )
    })
}

// A row of `n` answer squares, e.g. for 准考证号 in the seal-line info.
#let examsquare(n, ..args) = context {
    let s = merge(exam-state.get().square, args.named(), path: "square.")
    box(baseline: s.baseline, grid(
        columns: (s.x-length,) * n,
        rows: s.y-length,
        stroke: s.linewidth,
        ..range(n).map(_ => []),
    ))
}

// Start one exam of a collection. The title spans all columns, goes into
// the outline and restarts question and section numbers.
#let chapter(title, outlined: true) = {
    pagebreak(weak: true)
    [#heading(level: 1, numbering: none, outlined: outlined, title)<exam-zh-chapter>]
    question-counter.update(0)
    counter(heading).update(0)
}

#let _chapter-style(cfg, it) = {
    if not cfg.page.show-chapter { return }
    place(top + center, scope: "parent", float: true, clearance: 1.5em, block(
        width: 100%,
        align(center, apply-format(cfg, (family: "sans", weight: "bold", size: 20pt), it.body)),
    ))
}

// Table of contents of a collection. It sits on its own pages, which are
// not numbered, and the exams start at page 1.
#let exam-outline(title: [目#h(2em)录]) = page(header: none, footer: none, background: none)[
    #context {
        let cfg = exam-state.get()
        let a3 = cfg.page.size == "a3" and cfg.page.foot-type == "separate"
        show outline.entry: it => {
            let n = counter(page).at(it.element.location()).first()
            let n = if a3 { 2 * n - 1 } else { n }
            link(it.element.location(), block(spacing: 1em)[
                #it.body() #box(width: 1fr, repeat(gap: 0.25em)[.]) #n
            ])
        }
        place(top + center, scope: "parent", float: true, clearance: 2em,
            apply-format(cfg, (family: "sans", weight: "bold", size: 18pt), title))
        outline(title: none, target: selector(<exam-zh-chapter>))
        // With two-sided margins the papers start on an odd page, so the
        // physical and the printed page numbers have the same parity. The
        // page number restarts at 1 on the first paper.
        if geometry(cfg).twoside {
            pagebreak(to: "odd")
            counter(page).update(1)
        } else {
            counter(page).update(0)
        }
    }
]
