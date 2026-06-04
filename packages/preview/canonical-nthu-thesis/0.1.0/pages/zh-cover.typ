#import "../utils/cover-with-rect.typ": cover-with-white-rect


#set heading(
    numbering: "1.1.1",
)


#let cover-heading(
    degree: "master",  // "master" | "doctor"
    size: 26pt,  // Font size
    tracking: 0.5em,  // Intra-character spacing
) = {
    let heading-from-degree(degree) = (
        "master": "碩士論文",
        "doctor": "博士論文",
    ).at(degree)


    stack(
        text(size: size, tracking: tracking, [國立清華大學]),
        v(65pt),
        text(size: size, tracking: tracking, heading-from-degree(degree)),
    )
}


#let cover-titles(
    title_zh,
    title_en,
    size: 16pt,  // Font size
    spacing: 1cm,  // Spacing between zh and en titles
) = stack(
    text(size: size, strong(title_zh)),
    v(spacing),
    text(size: size, strong(title_en)),
)


#let cover-author-info(
    department,
    id,
    author-zh,
    author-en,
    supervisor-zh,
    supervisor-en,
) = {
    set text(size: 16pt)
    grid(
        columns: (auto, 1em, 11cm),
        rows: (30pt, 30pt, 30pt),
        align: (right, left, auto),
        // Row 1
        text(tracking: 0.5em, [系所別]),
        text([：]),
        grid.cell(stroke: (bottom: (paint: black, thickness: 0.4pt)), text(tracking: 0.5em, department)),
        // Row 2
        text([學號姓名]),
        text([：]),
        grid.cell(stroke: (bottom: (paint: black, thickness: 0.4pt)), text(id + author-zh + "（" + author-en + "）")),
        // Row 3
        text([指導教授]),
        text([：]),
        grid.cell(stroke: (bottom: (paint: black, thickness: 0.4pt)), text(supervisor-zh + "（" + supervisor-en + "）")),
    )
}


#let cover-year-month(
    year-zh,
    month-zh,
) = {
    set text(size: 16pt)
    stack(
        dir: ltr,
        spacing: 0.75em,
        text(/* Spacing between characters */ tracking: 0.75em, [中華民國]),
        text(year-zh),
        text([年]),
        text(month-zh),
        text([月]),
    )
}


#let zh-cover-page(
    info: (:),
) = page(
    paper: "a4",
    margin: (top: 1.75in, left: 1in, right: 1in, bottom: 2in),
    background: cover-with-white-rect(image("../nthu-logo.svg", width: 1.95in, height: 1.95in)),
    [
        #set text(
            font: ("New Computer Modern", "TW-MOE-Std-Kai"),
            size: 12pt,
        )

        #align(
            horizon + center,
            block(
                height: 100%,
                // The vertical stack of the content of the cover.
                stack(
                    dir: ttb,
                    cover-heading(degree: info.degree, size: 26pt, tracking: 0.5em),
                    v(1.25in),
                    cover-titles(info.title-zh, info.title-en, size: 16pt, spacing: 1cm),
                    v(1fr),  // This spacing makes the whole stack fill exactly 100% its parent block.
                    cover-author-info(
                        info.department-zh,
                        info.id,
                        info.author-zh,
                        info.author-en,
                        info.supervisor-zh,
                        info.supervisor-en,
                    ),
                    v(1in),
                    cover-year-month(info.year-zh, info.month-zh),
                )
            )
        )
    ]
)
