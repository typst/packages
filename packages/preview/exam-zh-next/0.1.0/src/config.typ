// Shared configuration for every exam-zh module.
//
// All options live in one nested dictionary. `exam` seeds it, `exam-setup`
// changes it from that point on, and each component reads it in `context`.
// Per-call arguments are merged over the section they belong to, so
// `choices(columns: 2)` and `exam-setup(choices: (columns: 2))` accept the
// same keys. Unknown keys fail loudly, which catches typos such as
// `colums: 2` instead of silently ignoring them.

// Chinese point sizes (字号). Negative numbers are the 小 sizes, matching
// ctex's `\zihao{-4}`.
#let zihao-table = (
    "初号": 42pt, "小初": 36pt, "一号": 26pt, "小一": 24pt,
    "二号": 22pt, "小二": 18pt, "三号": 16pt, "小三": 15pt,
    "四号": 14pt, "小四": 12pt, "五号": 10.5pt, "小五": 9pt,
    "六号": 7.5pt, "小六": 6.5pt, "七号": 5.5pt, "八号": 5pt,
)
#let _zihao-numbers = (
    "0": "初号", "-0": "小初", "1": "一号", "-1": "小一", "2": "二号",
    "-2": "小二", "3": "三号", "-3": "小三", "4": "四号", "-4": "小四",
    "5": "五号", "-5": "小五", "6": "六号", "-6": "小六", "7": "七号",
    "8": "八号",
)

// `zihao("小四")`, `zihao(-4)` and `zihao(4)` return a length.
#let zihao(size) = {
    // `str(-4)` uses a Unicode minus sign, so build the key by hand.
    let key = if type(size) == int { (if size < 0 { "-" } else { "" }) + str(calc.abs(size)) }
    let name = if type(size) == int { _zihao-numbers.at(key, default: none) } else { size }
    assert(
        name in zihao-table,
        message: "exam-zh: unknown 字号 " + repr(size),
    )
    zihao-table.at(name)
}

// CJK font families per platform. Each role falls back to the serif family
// for glyphs the role's font lacks, and Typst warns once about any family
// that is not installed. Noto and Source Han have no Kai or Fangsong face,
// so those presets use the serif face; set `font: (kai: "LXGW WenKai")` or
// similar when a Kai font is installed.
#let font-presets = (
    noto: (
        serif: "Noto Serif CJK SC",
        sans: "Noto Sans CJK SC",
        kai: "Noto Serif CJK SC",
        fangsong: "Noto Serif CJK SC",
    ),
    source-han: (
        serif: "Source Han Serif SC",
        sans: "Source Han Sans SC",
        kai: "Source Han Serif SC",
        fangsong: "Source Han Serif SC",
    ),
    fandol: (
        serif: "FandolSong",
        sans: "FandolHei",
        kai: "FandolKai",
        fangsong: "FandolFang",
    ),
    windows: (
        serif: "SimSun",
        sans: "SimHei",
        kai: "KaiTi",
        fangsong: "FangSong",
    ),
    mac: (
        serif: "Songti SC",
        sans: "Heiti SC",
        kai: "Kaiti SC",
        fangsong: "STFangsong",
    ),
    founder: (
        serif: "FZShuSong-Z01",
        sans: "FZHei-B01",
        kai: "FZKai-Z03",
        fangsong: "FZFangSong-Z02",
    ),
)

// Default student-information fields beside the seal line.
#let _default-info = (
    ("姓名", 8em),
    ("准考证号", 8em),
    ("考场号", 8em),
    ("座位号", 8em),
)

#let default-config = (
    // "student" or "teacher"; `exam(mode:)` and `--input exam-mode=` set it.
    mode: "student",
    // Set by `exam`. Page hooks at the top of page 1 run before the state
    // update, and use the template's settings while this is false.
    ready: false,
    // Settings saved by `with-setup`, restored when its body ends.
    saved: (),
    // Title and subject printed by `make-title`; `exam(title:, subject:)`
    // sets them.
    meta: (
        title: none,
        subject: none,
        // Width the subject is spread over; auto is twice its natural width.
        subject-width: auto,
    ),
    page: (
        // "a4", "a3" (landscape, two A4 columns per sheet) or
        // (width, height) for a custom single-column sheet.
        size: "a4",
        // auto picks the original margins for the size and seal line.
        margin: auto,
        column-gutter: 30mm,
        show-head: false,
        head: none,
        show-foot: true,
        // A function `(page, total) => content`, a string with `;` for the
        // page and total (as in exam-zh), or fixed content.
        foot: (page, total) => [第 #page 页（共 #total 页）],
        foot-format: (size: 9pt),
        // A3 only: "separate" prints one footer per A4 half, "common" one
        // footer per sheet.
        foot-type: "separate",
        show-columnline: false,
        columnline-stroke: 0.4pt,
        show-chapter: true,
    ),
    style: (
        // Replace "。" with "．", as some math papers do.
        fullwidth-stop: false,
        // Typeset every inline equation in display style (\everymath{\displaystyle}).
        display-math: false,
        par-leading: 0.85em,
        par-spacing: 0.85em,
        first-line-indent: 2em,
        // Footnote marks: a numbering pattern such as "1" or "①", or a
        // function, e.g. `n => circled-number(n, filled: true)`.
        footnote-numbering: "1",
    ),
    font: (
        preset: "noto",
        size: 10.5pt,
        // Latin text font used before the CJK family.
        latin: "New Computer Modern",
        math: "New Computer Modern Math",
        mono: "DejaVu Sans Mono",
        // auto takes the family from `preset`.
        serif: auto,
        sans: auto,
        kai: auto,
        fangsong: auto,
    ),
    // Options of `make-title`. (The paper's title itself is `exam(title:)`.)
    make-title: (
        title-format: (size: 16pt),
        subject-format: (family: "sans", weight: "bold", size: 22pt),
        subject-sep: -0.2em,
        top-sep: 0em,
        bottom-sep: 0.6em,
    ),
    notice: (
        label: [注意事项：],
        label-format: (family: "sans", weight: "bold"),
        numbering: "1.",
        indent: 1.5em,
        top-sep: 0.4em,
        bottom-sep: 0.6em,
    ),
    section: (
        numbering: "一、",
        format: (family: "sans", weight: "bold"),
        above: 1.6em,
        below: 0.9em,
    ),
    sealline: (
        enable: false,
        // firstpage, oddpage, everypage, first-and-last, mod-2, mod-3, mod-4, mod-6
        scope: "everypage",
        line-thickness: 1pt,
        line-xshift: 8mm,
        line-yshift: 0mm,
        line-type: "loosely-dashed",
        text: "密封线内不得答题",
        text-xshift: 11mm,
        text-yshift: 0mm,
        // Length, or a ratio of the text-area height.
        text-width: 80%,
        text-format: (family: "sans", size: 14pt),
        text-xscale: 100%,
        text-yscale: 80%,
        text-direction-vertical: false,
        circle-show: true,
        circle-start: 0.07,
        circle-end: 0.92,
        circle-step: 3.5em,
        circle-diameter: 3mm,
        circle-xshift: 8mm,
        // Fields beside the line: an array of content, or of
        // (label, blank-width) pairs.
        info: _default-info,
        info-format: (family: "kai"),
        info-separator: h(3em),
        info-align: center,
        info-xshift: 20mm,
        info-yshift: 0mm,
        // Overrides for odd and even pages, with the keys above. `info`
        // appears on odd pages only unless `even` sets its own.
        odd: (:),
        even: (:),
    ),
    square: (
        x-length: 1.4em,
        y-length: 1.2em,
        baseline: 3pt,
        linewidth: 0.4pt,
    ),
    question: (
        label: "1.",
        label-align: right,
        label-width: 1.3em,
        label-sep: 0.7em,
        hang: true,
        // auto shows points on problems only.
        show-points: auto,
        points-separate-par: false,
        points-prelabel: [（],
        points-postlabel: [分）],
        // none, true, or a dictionary of `fillin` arguments with `answer`.
        combine-fillin: none,
        top-sep: 0.5em,
        bottom-sep: 0.5em,
        enum-numbering: ("（1）", "（a）", "（i）"),
    ),
    problem: (
        label: "1.",
        label-align: right,
        label-width: 1.3em,
        label-sep: 0.7em,
        hang: false,
        show-points: auto,
        points-separate-par: true,
        points-prelabel: [（],
        points-postlabel: [分）],
        top-sep: 0.5em,
        bottom-sep: 0.5em,
        enum-numbering: ("（1）", "（i）", "（a）"),
    ),
    choices: (
        // A numbering pattern, a function `n => content`, or fixed content.
        label: "A.",
        label-pos: auto,
        label-align: left,
        label-sep: 0.5em,
        label-width: 0pt,
        // auto picks the column count; an integer forces it.
        columns: auto,
        max-columns: 4,
        column-sep: 1em,
        index: 1,
        top-sep: 0.3em,
        bottom-sep: 0.3em,
        linesep: 0pt,
        item-linesep: 0pt,
        left-indent: 0pt,
        right-indent: 0pt,
        // Sets both indents when not none.
        margin: none,
        show-answer: false,
        answer-color: red,
    ),
    paren: (
        show-paren: true,
        show-answer: false,
        text-color: black,
        // "hfill", "dotfill" or "none".
        type: "hfill",
        width: 2em,
    ),
    fillin: (
        // "line", "paren", "circle", "rectangle" or "blank".
        type: "line",
        show-answer: false,
        // A length, or auto for the answer's own width.
        width: 3em,
        width-extra: 0pt,
        // For blanks wider than a line: "normal" keeps the width, "fill"
        // extends the last line to the margin.
        width-type: "normal",
        box-color: black,
        text-color: black,
        // "blacktriangle", "counter" or "none".
        no-answer-type: "blacktriangle",
        no-answer-counter-label: "1",
        // The number of the next counter blank; set it with exam-setup.
        no-answer-counter-index: 1,
        // "banjiao" or "quanjiao".
        paren-type: "banjiao",
        // Depth of the underline below the baseline.
        depth: 0.3em,
        stroke: 0.5pt,
    ),
    solution: (
        // "hide", "show-stay" or "show-move".
        show-solution: "hide",
        label-content: [解答],
        label-punct: none,
        label-format: (weight: "bold"),
        label-indentation: true,
        parbreak: false,
        pre-analysis: [【解析】],
        show-qed: true,
        qedsymbol: $square$,
        text-color: black,
        // Blank left when solutions are hidden: "none", "manual" or "hide".
        blank-type: "none",
        blank-vsep: 12em,
        top-sep: 0.5em,
        bottom-sep: 0.5em,
        score-showleader: true,
        score-pre-content: none,
        score-post-content: [分],
        score-format: (fill: red),
        moved-title: [参考答案],
        moved-format: (family: "kai"),
    ),
    list: (
        step-name: [步骤],
        method-name: [方法],
        case-name: [情形],
        step-punct: [.],
        method-punct: none,
        case-punct: [.],
        label-format: (weight: "bold"),
        indent: 1.7cm,
    ),
    draft: (
        show-watermark: true,
        watermark-size: auto,
        watermark-text: [草#h(1em)稿#h(1em)纸],
        watermark-color: luma(85%),
        // "manual" or "auto" (two draft sheets after the last page).
        show-draft: "manual",
    ),
    scoringbox: (
        // none, "onecolumn" or "twocolumn": a scoring box beside each section.
        type: none,
        position: left,
        cell-width: 3em,
        cell-height: 2em,
    ),
    symbols: (
        // "slant" or "perpendicular".
        paralleleq-type: "slant",
        // Extra space on both sides of every numerator and denominator, as
        // exam-zh's change-frac-style; none keeps Typst's spacing. 5mu is
        // `5em / 18`.
        frac-add: none,
    ),
    select: (
        mark-symbol: sym.checkmark,
        show-mark: false,
        // right, left, top, bottom
        mark-position: right,
        mark-xshift: 0pt,
        mark-yshift: 0pt,
        separator: h(1em),
        pre-content: [(],
        post-content: [)],
    ),
    lineto: (
        xsep: 25%,
        ysep: 1cm,
        stroke: 0.6pt,
        // The lines are the answer, so they show in the teacher version.
        show-lines: false,
        item-inset: 0.25em,
    ),
    material: (
        title-format: (size: 14pt),
        author-format: (size: 9pt),
        format: (family: "kai"),
        source-format: none,
        title-author-sep: 2em,
        top-sep: 0.5em,
        bottom-sep: 0.5em,
        title-material-sep: 0.3em,
    ),
    poem: (
        title-format: (size: 10.5pt),
        author-format: (size: 9pt),
        format: (family: "kai"),
        title-author-sep: 2em,
        top-sep: 0.5em,
        bottom-sep: 1em,
        title-poem-sep: 0.4em,
        align: left,
        // "chinese" (one 【注】 paragraph) or "minipage" (one note per line).
        type: "chinese",
        // "font" uses the ① glyphs for note marks, "tikz" draws the circles
        // (as `circled-number`).
        zhu-circlednumber-base: "font",
    ),
    composition-grid: (
        columns: 20,
        cell-size: auto,
        cell-scale: 1.75,
        row-sep-ratio: 2,
        // "口", "田" or "米".
        frame-type: "口",
        frame-color: black,
        fill-color: none,
        frame-linewidth: 0.4pt,
        auto-break: true,
        count-marks: (),
        count-format: (size: 6pt),
        count-sep: 2pt,
    ),
    writing: (
        box-stroke: 0.6pt,
        lines-stroke: 1pt,
        inset: 0.6em,
        title-format: none,
        line-width: 100%,
        line-height: 1.8em,
        line-thickness: 0.4pt,
        line-color: black,
    ),
    multifigures: (
        columns: 3,
        // Explicit grid column widths, e.g. (4.5cm,) * 3; auto sizes the
        // columns to the figures.
        column-widths: auto,
        // top, bottom, left, right: where the figure sits relative to its label.
        fig-pos: top,
        column-gap: 6pt,
        row-gap: 1em,
        align: bottom,
        label-sep: 0.4em,
        xshift: 0pt,
        yshift: 0pt,
        label-xshift: 0pt,
        label-yshift: 0pt,
        top-sep: 0.6em,
        bottom-sep: 0.3em,
    ),
    textfigure: (
        fig-pos: "bottom-right",
        column-gap: 1em,
        text-width: auto,
        // Width of the figure part; auto uses the figure's own width.
        figure-width: auto,
        // Share of the line width given to the text, e.g. 60%; it takes
        // precedence over text-width.
        ratio: auto,
        min-text-width: 35%,
        parindent: 2em,
        xshift: 0pt,
        yshift: 0pt,
        figure-xshift: 0pt,
        figure-yshift: 0pt,
        top-sep: 0.3em,
        bottom-sep: 0.6em,
    ),
    calculations: (
        label: "1.",
        index: 1,
        columns: 2,
        hsep: 2em,
        vsep: 0pt,
        // top, horizon or bottom alignment of the items in a row.
        align: top,
        label-sep: 0.3em,
        // Where the item sits relative to its label: "left-top" (inline, the
        // default), "left", "right", "top" or "bottom".
        fig-pos: "left-top",
        label-xshift: 0pt,
        label-yshift: 0pt,
        xshift: 2em,
        top-sep: 0.6em,
        bottom-sep: 0.3em,
    ),
)

// Merge `over` into `base`, checking every key. Top-level sections merge
// key by key; option values, including format dictionaries, replace the
// default as a whole.
#let merge(base, over, path: "") = {
    let out = base
    for (key, value) in over {
        assert(
            key in base,
            message: "exam-zh: unknown option `" + path + key + "`",
        )
        let old = base.at(key)
        if path == "" and type(old) == dictionary and type(value) == dictionary {
            out.insert(key, merge(old, value, path: path + key + "."))
        } else {
            out.insert(key, value)
        }
    }
    out
}

#let exam-state = state("exam-zh/config", default-config)

// Expand shorthand options: `question.show-answer` (or `problem.show-answer`)
// sets the answers of both `paren` and `fillin`, as in exam-zh. Returns the
// options and the requested next question number, if any.
#let normalize-options(options) = {
    // Counter values requested by the options: the next question number and
    // the next numbered fill-in blank.
    let counters = (:)
    let fillin = options.at("fillin", default: none)
    if type(fillin) == dictionary and "no-answer-counter-index" in fillin {
        counters.fillin = fillin.remove("no-answer-counter-index")
        options.insert("fillin", fillin)
    }
    for section in ("question", "problem") {
        let opts = options.at(section, default: none)
        if type(opts) != dictionary { continue }
        if "index" in opts {
            counters.question = opts.remove("index")
        }
        if "show-answer" in opts {
            let value = opts.remove("show-answer")
            for target in ("paren", "fillin") {
                let current = options.at(target, default: (:))
                options.insert(target, (show-answer: value) + current)
            }
        }
        options.insert(section, opts)
    }
    (options, counters)
}

#let question-counter = counter("exam-zh/question")
#let fillin-counter = counter("exam-zh/fillin")

// Apply the counter values returned by `normalize-options`.
#let set-counters(counters) = {
    if "question" in counters { question-counter.update(counters.question - 1) }
    if "fillin" in counters { fillin-counter.update(counters.fillin - 1) }
}

// Change options from here on: `exam-setup(fillin: (type: "paren"))`.
// `question: (index: n)` makes the next question number n, and
// `fillin: (no-answer-counter-index: n)` the next numbered blank n.
#let exam-setup(..args) = {
    assert(args.pos().len() == 0, message: "exam-zh: exam-setup takes named options only")
    let (options, counters) = normalize-options(args.named())
    set-counters(counters)
    exam-state.update(cfg => merge(cfg, options))
}

// Save the current settings and apply `options`; `pop-setup` restores them.
// Both are pure state updates, so nested scopes converge in one layout pass.
#let push-setup(options) = {
    let (options, counters) = normalize-options(options)
    set-counters(counters)
    exam-state.update(cfg => {
        let current = cfg
        current.saved = ()
        let out = merge(cfg, options)
        out.saved = cfg.saved + (current,)
        out
    })
}
#let pop-setup() = exam-state.update(cfg => {
    assert(cfg.saved.len() > 0, message: "exam-zh: pop-setup without push-setup")
    let previous = cfg.saved.last()
    previous.saved = cfg.saved.slice(0, -1)
    previous
})

// Apply `options` to `body` only, then restore the previous settings.
#let with-setup(options, body) = {
    if options.len() == 0 { return body }
    push-setup(options)
    body
    pop-setup()
}

// Merge the per-call `overrides` over section `name` of `cfg`.
#let section-config(cfg, name, overrides) = merge(
    cfg.at(name),
    overrides,
    path: name + ".",
)

#let font-family(cfg, role) = {
    let font = cfg.font
    if role == "mono" { return (font.mono,) }
    if role == "math" { return (font.math,) }
    assert(
        role in ("serif", "sans", "kai", "fangsong"),
        message: "exam-zh: unknown font family role " + repr(role),
    )
    assert(
        font.preset in font-presets,
        message: "exam-zh: unknown font preset " + repr(font.preset)
            + "; use one of " + font-presets.keys().join(", "),
    )
    let preset = font-presets.at(font.preset)
    let pick(name) = {
        let value = font.at(name)
        if value == auto { preset.at(name) } else { value }
    }
    let cjk = pick(role)
    let cjk = if type(cjk) == array { cjk } else { (cjk,) }
    let serif = pick("serif")
    let serif = if type(serif) == array { serif } else { (serif,) }
    // Sans text uses the CJK sans font for Latin letters too, as ctex's
    // \sffamily does with Hei fonts.
    let latin = if role == "sans" or font.latin == none { () } else {
        ((name: font.latin, covers: "latin-in-cjk"),)
    }
    let fallback = if role == "serif" { () } else { serif }
    latin + cjk + fallback
}

// Apply a format: none, a function `body => content`, or a dictionary of
// `text` arguments with an optional `family` role ("serif", "sans", "kai",
// "fangsong", "mono").
#let apply-format(cfg, format, body) = {
    if format == none { return body }
    if type(format) == function { return format(body) }
    assert(
        type(format) == dictionary,
        message: "exam-zh: a format must be none, a function or a dictionary, got " + repr(format),
    )
    let args = format
    if "family" in args {
        let role = args.remove("family")
        args.insert("font", font-family(cfg, role))
    }
    text(..args, body)
}

// Typeset a label from a numbering pattern ("1.", "A.", "①", "（一）"), a
// function `n => content`, fixed content, or none.
// A number in a circle. Unlike the "①" numbering pattern, which stops at
// 50, it works for any number. `filled: true` sets it white on black.
#let circled-number(n, filled: false) = {
    let digits = str(n)
    let size = if digits.len() == 1 { 0.7em } else if digits.len() == 2 { 0.56em } else { 0.42em }
    let ink = if filled { white } else { black }
    box(baseline: 0.07em, circle(
        radius: 0.44em,
        inset: 0pt,
        stroke: if filled { none } else { 0.05em + black },
        fill: if filled { black } else { none },
        align(center + horizon, text(size: size, fill: ink, top-edge: "cap-height", bottom-edge: "baseline", digits)),
    ))
}

// Typeset a label from a numbering pattern ("1.", "A.", "①", "（一）"), a
// function `n => content`, fixed content, or none. A "①" pattern falls back
// to `circled-number` past 50.
#let format-label(label, n) = {
    if label == none { none }
    else if type(label) == str {
        if label.contains("①") and n > 50 {
            let (before, ..after) = label.split("①")
            [#before#circled-number(n)#after.join("①")]
        } else { numbering(label, n) }
    }
    else if type(label) == function { label(n) }
    else { label }
}

// Best-effort plain text of simple content, used for spreading titles and
// seal-line text character by character.
#let plain-text(it) = {
    if it == none { "" }
    else if type(it) == str { it }
    else if type(it) in (int, float) { str(it) }
    else if type(it) == content {
        if it.has("text") { it.text }
        else if it.has("children") { it.children.map(plain-text).join() }
        else if it.has("body") { plain-text(it.body) }
        else if it == [ ] { " " }
        else { none }
    } else { none }
}

// Spread the characters of `body` evenly across `width`, like \makebox[w][s].
#let spread(body, width) = {
    let txt = plain-text(body)
    if txt == none or width == auto {
        return box(width: width, align(center, body))
    }
    let chars = txt.clusters().filter(c => c.trim() != "")
    if chars.len() < 2 { return box(width: width, align(center, body)) }
    box(width: width, chars.join(h(1fr)))
}

// Resolve a length or a ratio of `whole`.
#let resolve-size(value, whole) = {
    if type(value) == ratio { value * whole }
    else if type(value) == relative { value.ratio * whole + value.length }
    else { value }
}

// Show `body` only in the student or teacher version.
#let student-only(body) = context {
    if exam-state.get().mode != "teacher" { body }
}
#let teacher-only(body) = context {
    if exam-state.get().mode == "teacher" { body }
}

// Font-role wrappers: 宋体, 黑体, 楷体, 仿宋.
#let songti(body) = context text(font: font-family(exam-state.get(), "serif"), body)
#let heiti(body) = context text(font: font-family(exam-state.get(), "sans"), body)
#let kaishu(body) = context text(font: font-family(exam-state.get(), "kai"), body)
#let fangsong(body) = context text(font: font-family(exam-state.get(), "fangsong"), body)
