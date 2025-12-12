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
    logo: none,
    // logo-width: 2cm,
    partner: "BHX",
    student-name: "Arshtyi",
    grade: "大一",
    group: "01",
    course: "大学物理实验",
    lab-title: "实验题目",
    date: datetime.today(),
    tool-group: "01",
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
            "({3:1})", // here, we only want the 3rd level
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
    counter(page).update(1)

    [
        #set text(tracking: 0.1em)
        #grid(
            columns: (1fr, 4fr, 2fr),
            align: center + horizon,
            box(height: 10%, logo),
            underline(text("山东大学实验报告", size: 20pt)),
            underline(text(date.display("[year]年[month]月[day]日"), size: 12pt)),
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

    [
        #set text(size: 字号.小四)
        #grid(
            columns: (1fr, 1fr, 1fr, 1fr),
            text("姓名" + underline(student-name)),
            text("系年级" + underline(grade)),
            text("组别" + underline(group)),
            text("同组者" + underline(partner)),
        )
        #v(1em, weak: true)
        #grid(
            columns: (1fr, 2fr, 1fr),
            text("科目" + underline(course)),
            text("题目" + underline(lab-title)),
            text("仪器编号" + underline(tool-group)),
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
