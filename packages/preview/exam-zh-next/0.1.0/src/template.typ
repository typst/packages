// The `exam` template: page setup, typography and document-level hooks.

#import "config.typ": (
    apply-format, default-config, exam-state, font-family, merge, normalize-options,
    set-counters,
)
#import "page.typ": background, draftpaper, footer, geometry, header
#import "title.typ": _chapter-style, scoringbox
#import "question.typ": _moved-solutions

// Options applied in the teacher version unless `exam(teacher:)` replaces
// them: every answer, the marked options, select marks, matching lines and
// the solutions in place.
#let teacher-defaults = (
    question: (show-answer: true),
    choices: (show-answer: true),
    solution: (show-solution: "show-stay"),
    select: (show-mark: true),
    lineto: (show-lines: true),
)

#let _section(cfg, it) = context {
    let s = cfg.section
    let number = if it.numbering != none { counter(heading).display(it.numbering) }
    let title = {
        set par(first-line-indent: 0pt, hanging-indent: measure(number).width, justify: true)
        apply-format(cfg, s.format, [#number#it.body])
    }
    let body = if cfg.scoringbox.type == none { title } else {
        let mark = scoringbox(simple: cfg.scoringbox.type == "onecolumn")
        if cfg.scoringbox.position == left {
            grid(columns: (auto, 1fr), column-gutter: 1em, align: horizon, mark, title)
        } else {
            grid(columns: (1fr, auto), column-gutter: 1em, align: horizon, title, mark)
        }
    }
    block(width: 100%, above: s.above, below: s.below, sticky: true, body)
}

// Typeset an exam paper.
//
// - `title`, `subject`: printed by `make-title()` and kept for the footer.
// - `mode`: "student" or "teacher"; it defaults to
//   `--input exam-mode=teacher`, so one source compiles both versions.
// - `teacher`: options merged over the others in the teacher version.
//   It may also replace `title` and `subject`.
// - every other named argument is an option section, as for `exam-setup`.
#let exam(
    title: none,
    subject: none,
    subject-width: auto,
    mode: sys.inputs.at("exam-mode", default: "student"),
    teacher: teacher-defaults,
    ..options,
    body,
) = {
    assert(mode in ("student", "teacher"), message: "exam-zh: mode must be \"student\" or \"teacher\"")
    assert(options.pos().len() == 0, message: "exam-zh: exam takes one body")
    let meta = (title: title, subject: subject, subject-width: subject-width)
    let (options, counters) = normalize-options(options.named())
    let cfg = merge(default-config, options)
    if mode == "teacher" {
        let extra = teacher
        for key in ("title", "subject", "subject-width") {
            if key in extra { meta.insert(key, extra.remove(key)) }
        }
        let (extra, _) = normalize-options(extra)
        cfg = merge(cfg, extra)
    }
    cfg = merge(cfg, (mode: mode, meta: meta, ready: true))
    let geo = geometry(cfg)

    set document(title: if title != none { title } else { none })
    set page(
        width: geo.width,
        height: geo.height,
        columns: geo.columns,
        margin: if geo.twoside {
            (inside: geo.inside, outside: geo.outside, top: geo.top, bottom: geo.bottom)
        } else {
            (left: geo.inside, right: geo.outside, top: geo.top, bottom: geo.bottom)
        },
        binding: left,
        header: header(cfg),
        footer: footer(geo, cfg),
        background: background(geo, cfg),
    )
    set columns(gutter: geo.gutter)
    set text(
        font: font-family(cfg, "serif"),
        size: cfg.font.size,
        lang: "zh",
        region: "cn",
    )
    set par(
        justify: true,
        leading: cfg.style.par-leading,
        spacing: cfg.style.par-spacing,
        first-line-indent: (amount: cfg.style.first-line-indent, all: true),
    )
    show math.equation: set text(font: font-family(cfg, "math"))
    show raw: set text(font: font-family(cfg, "mono"))
    show strong: set text(weight: "bold")
    // Chinese emphasis is set in Kai rather than slanted.
    show emph: it => text(font: font-family(cfg, "kai"), style: "normal", it.body)
    // Typst spaces lines by font metrics, so a tall inline equation (a
    // display-style fraction) would run into its neighbours. Equations whose
    // ink is clearly taller than the line use their real bounds instead;
    // ordinary lines keep the regular leading. With `style.display-math`,
    // inline equations are first rebuilt in display style (the label marks
    // the rebuilt ones).
    show math.equation.where(block: false): it => {
        if cfg.style.display-math and it.at("label", default: none) != <exam-zh-display> {
            return [#math.equation(math.display(it.body), block: false)<exam-zh-display>]
        }
        context {
            let ink = measure({
                set text(top-edge: "bounds", bottom-edge: "bounds")
                it
            }).height
            if ink > measure(it).height + 0.2em.to-absolute() {
                set text(top-edge: "bounds", bottom-edge: "bounds")
                it
            } else { it }
        }
    }
    show "。": it => if cfg.style.fullwidth-stop { "．" } else { it }
    set footnote(numbering: cfg.style.footnote-numbering)
    // `symbols.frac-add` pads numerators and denominators. The padding
    // itself marks a rebuilt fraction, so the rule does not apply twice.
    show math.frac: it => context {
        let add = exam-state.get().symbols.frac-add
        let padded(body) = [#h(add)#body#h(add)]
        let done = add == none or (
            it.num.func() == [].func()
                and it.num.children.len() > 0
                and it.num.children.first() == h(add)
        )
        if done { it } else {
            let style = it.fields().at("style", default: none)
            let args = if style == none { (:) } else { (style: style) }
            math.frac(padded(it.num), padded(it.denom), ..args)
        }
    }

    let pattern = cfg.section.numbering
    set heading(numbering: (..nums) => {
        let nums = nums.pos()
        if nums.len() == 1 { numbering(pattern, ..nums) } else { numbering("1.", nums.last()) }
    })
    show heading: set text(font: font-family(cfg, "sans"), size: cfg.font.size)
    show heading.where(level: 1): it => context {
        let cfg = exam-state.get()
        if it.at("label", default: none) == <exam-zh-chapter> { _chapter-style(cfg, it) }
        else { _section(cfg, it) }
    }

    exam-state.update(cfg)
    set-counters(counters)

    body

    context {
        if query(<exam-zh-moved-printed>).len() == 0 { _moved-solutions(false) }
    }
    if cfg.draft.show-draft == "auto" {
        draftpaper()
        draftpaper()
    }
    [#metadata("end")<exam-zh-end>]
}
