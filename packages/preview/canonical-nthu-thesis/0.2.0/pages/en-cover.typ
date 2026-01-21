#set heading(
    numbering: "1.1.1",
)


#let cover-author-info(
    department,
    author-en,
    supervisor-en,
) = grid(
    columns: (auto, 0.75em, auto),
    rows: (1.5em, 1.5em),
    align: (right, left, left),
    [Advisor: ],
    "",
    supervisor-en,
    [Student: ],
    "",
    author-en,
)


#let en-cover-page(
    info: (:),
) = page(
    paper: "a4",
    margin: (top: 1.75in, left: 1in, right: 1in, bottom: 2in),
    [
        #set text(
            size: 14pt,
        )

        #align(
            horizon + center,
            block(
                height: 100%,
                stack(
                    dir: ttb,
                    strong(info.title-en),
                    v(1.5in),
                    [#info.department-en \ National Tsing Hua University \ Hsin-Chu, Taiwan 300, Taiwan],
                    v(1.5in),
                    cover-author-info(info.department-en, info.author-en, info.supervisor-en),
                    v(1fr),
                    info.date-en,
                )
            )
        )
    ]
)
