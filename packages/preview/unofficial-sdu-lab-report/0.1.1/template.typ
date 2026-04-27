#import "dependency.typ": *

#let font = (
    main: "Source Han Serif SC",
    mono: "IBM Plex Mono",
    cjk: "Noto Serif CJK SC",
)

#let 字号 = (
    初号: 42pt,
    小初: 36pt,
    一号: 26pt,
    小一: 24pt,
    二号: 22pt,
    小二: 18pt,
    三号: 16pt,
    小三: 15pt,
    四号: 14pt,
    中四: 13pt,
    小四: 12pt,
    五号: 10.5pt,
    小五: 9pt,
    六号: 7.5pt,
    小六: 6.5pt,
    七号: 5.5pt,
    小七: 5pt,
)

#let report(
    partner: "",
    student-name: "",
    student-grade: "",
    student-group: "",
    course: "",
    lab-title: "",
    lab-date: datetime.today(),
    tool-group: "",
    logo: none,
    body,
) = {
    set text(
        font: ("Source Han Serif SC", "Fira Sans"),
        size: 10.5pt,
        lang: "zh",
        region: "cn",
        // leading: 1.6
    )
    set page(
        paper: "a4",
        margin: (top: 2.6cm, bottom: 2.3cm, inside: 2cm, outside: 2cm),
        footer: [
            #set align(center)
            #set text(9pt)
            #context {
                counter(page).display("- 1/1 -")
            }
        ],
    )

    set document(title: lab-title, author: student-name)

    set heading(
        numbering: numbly(
            none,
            "{2:1}.",
            "({3:1})",
            none,
        ),
    )
    set par(justify: true)
    show math.equation.where(block: true): it => block(width: 100%, align(center, it))

    set raw(tab-size: 4)
    show raw: set text(font: (font.mono, font.cjk))
    // Display inline code in a small box
    // that retains the correct baseline.
    show raw.where(block: false): box.with(fill: luma(240), inset: (x: 3pt, y: 0pt), outset: (y: 3pt), radius: 2pt)
    show raw: it => {
        show ".": "." + sym.zws
        show "=": "=" + sym.zws
        show ";": ";" + sym.zws
        it
    }
    let style-number(number) = text(gray)[#number]
    show raw.where(block: true): it => {
        align(center)[
            #block(
                fill: luma(240),
                inset: 10pt,
                radius: 4pt,
                width: 100%,
            )[
                #place(top + right, dy: -15pt)[
                    #set text(size: 9pt, fill: white, style: "italic")
                    #block(
                        fill: gray,
                        outset: 4pt,
                        radius: 4pt,
                        // width: 100%,
                        context {
                            it.lang
                        },
                    )
                ]
                #set par(justify: false, linebreaks: "simple")
                #grid(
                    columns: (1em, 1fr),
                    align: (right, left),
                    column-gutter: 0.7em,
                    row-gutter: 0.6em,
                    // stroke: 1pt,
                    ..it.lines.enumerate().map(((i, line)) => (style-number(i + 1), line)).flatten(),
                )

            ]]
    }

    show link: it => {
        set text(fill: blue)
        underline(it)
    }

    set list(indent: 6pt)
    set enum(indent: 6pt)
    set enum(
        numbering: numbly(
            "{1:1})",
            "{2:a}.",
        ),
        full: true,
    )

    // Math equation numbering.Ref:https://guide.typst.dev/FAQ/math-equation
    let ct = counter("eq")
    set math.equation(numbering: it => ct.display("(1-1.a)"))
    show heading.where(level: 1): it => it + ct.step() + ct.step(level: 2)
    show math.equation.where(block: true): it => {
        it
        if it.numbering != none {
            if ct.get().len() == 2 {
                ct.step(level: 2)
            }
        }
    }
    let eq_nonum(body) = {
        set math.equation(numbering: none)
        body
    }
    let subeqs(..args) = {
        for eq in args.pos() {
            ct.step(level: 3)
            eq
        }
        ct.step(level: 2)
    }

    let underln(width, body) = box(align(center, body), width: width, stroke: (bottom: 0.5pt), outset: (bottom: 2pt))

    // First line contains logo, title and date.
    [
        #set text(tracking: 0.1em)
        #grid(
            columns: (1fr, 4fr, 2fr),
            align: center + horizon,
            box(height: 10%, logo),
            // box(text("山东大学实验报告", size: 20pt), baseline: -5pt, width: 1fr, stroke: (bottom: .5pt)), // Maybe this method is not good.
            underln(25em)[#text("山东大学实验报告", size: 20pt)],
            underln(10em)[#text(lab-date.display("[year]年[month]月[day]日"))],
        )
    ]

    show heading: set block(spacing: 1.5em)
    // show heading: set block(above: 1.4em, below: 1em)
    show heading.where(depth: 1): it => {
        show h.where(amount: 0.3em): none
        set text(size: 字号.小四)
        it
    }
    show heading: it => {
        set text(size: 字号.小四)
        it
    }

    set text(size: 字号.小四)
    set par(first-line-indent: 2em)
    let fakepar = context {
        box()
        v(-measure(block() + block()).height)
    }
    show math.equation.where(block: true): it => it + fakepar // 公式后缩进
    show heading: it => it + fakepar // 标题后缩进
    show figure: it => it + fakepar // 图表后缩进
    show enum: it => {
        // it.numbering + fakepar
        it
        // for item in it.children {
        //   context {
        //     counter(it.numbering).display()
        //   }
        //   [
        //     #item.body
        //   ]
        // }

        fakepar
    }
    // show enum.item: it => {
    //   repr(it)
    //   it
    // }
    show list: it => {
        it
        fakepar
    }
    show grid: it => it + fakepar // 列表后缩进
    show table: it => it + fakepar // 表格后缩进
    show raw.where(block: true): it => it + fakepar

    // Second line contains student-name, student-grade, student-group, partner.
    // Third line contains course, lab-title, tool-group.
    [
        #set text(size: 字号.小四)
        #grid(
            columns: (1fr, 1fr, 1fr, 1fr),
            text("姓名" + underln(7em)[#student-name]),
            text("系年级" + underln(7em)[#student-grade]),
            text("组别" + underln(7em)[#student-group]),
            text("同组者" + underln(7em)[#partner]),
        )
        #v(1em, weak: true)
        #grid(
            columns: (1fr, 2fr, 1fr),
            text("科目" + underln(7em)[#course]),
            text("题目" + underln(17em)[#lab-title]),
            text("仪器编号" + underln(6em)[#tool-group]),
        )
    ]

    v(1em, weak: true)
    show heading.where(depth: 1): it => {
        show h.where(amount: 0.3em): none
        set align(center)
        set text(size: 字号.小四)
        [
            #block(
                width: 100%,
                inset: 0em,
                stroke: none,
                breakable: true,
                it,
            )
        ]
    }
    counter(figure.where(kind: image)).update(0)
    body
}

#let code(path, lang) = {
    raw(read(path), lang: lang, block: true)
} // Read code from file

#let appendix(body) = {
    align(center)[
        #heading(numbering: none, depth: 1)[#text(size: 15pt)[附录]]
    ]
    body
}
