#import "@preview/codly:1.3.0": codly, codly-init

// main project
#let bubble(
    title: "",
    subtitle: none,
    author: "",
    affiliation: none,
    year: none,
    class: none,
    other: none,
    date: datetime.today().display(),
    logo: none,
    main-color: "E94845",
    alpha: 60%,
    color-words: (),
    body,
) = {
    set document(author: author, title: title)

    // Save heading and body font families in variables.
    let body-font = "LXGW WenKai"
    let title-font = ("ChillKai", "LXGW WenKai")
    let code-font = "JetBrains Mono NL"

    // Set colors
    let primary-color = rgb(main-color) // alpha = 100%
    // change alpha of primary color
    let secondary-color = color.mix(color.rgb(100%, 100%, 100%, alpha), primary-color, space: rgb)

    // highlight important words
    show regex(if color-words.len() == 0 { "$ " } else { color-words.join("|") }): text.with(fill: primary-color)

    //customize look of figure
    set figure.caption(separator: [ --- ], position: top)

    let code-languages = (
        bash: (name: "Bash", icon: "", color: primary-color),
        c: (name: "C", icon: "", color: primary-color),
        cpp: (name: "C++", icon: "", color: primary-color),
        csharp: (name: "C#", icon: "", color: primary-color),
        cs: (name: "C#", icon: "", color: primary-color),
        css: (name: "CSS", icon: "", color: primary-color),
        go: (name: "Go", icon: "", color: primary-color),
        html: (name: "HTML", icon: "", color: primary-color),
        java: (name: "Java", icon: "", color: primary-color),
        javascript: (name: "JavaScript", icon: "", color: primary-color),
        js: (name: "JavaScript", icon: "", color: primary-color),
        json: (name: "JSON", icon: "", color: primary-color),
        kotlin: (name: "Kotlin", icon: "", color: primary-color),
        kt: (name: "Kotlin", icon: "", color: primary-color),
        markdown: (name: "Markdown", icon: "", color: primary-color),
        md: (name: "Markdown", icon: "", color: primary-color),
        php: (name: "PHP", icon: "", color: primary-color),
        py: (name: "Python", icon: "", color: primary-color),
        python: (name: "Python", icon: "", color: primary-color),
        rust: (name: "Rust", icon: "", color: primary-color),
        rs: (name: "Rust", icon: "", color: primary-color),
        shell: (name: "Shell", icon: "", color: primary-color),
        sh: (name: "Shell", icon: "", color: primary-color),
        sql: (name: "SQL", icon: "", color: primary-color),
        swift: (name: "Swift", icon: "", color: primary-color),
        toml: (name: "TOML", icon: "", color: primary-color),
        typ: (name: "Typst", icon: "", color: primary-color),
        typescript: (name: "TypeScript", icon: "", color: primary-color),
        ts: (name: "TypeScript", icon: "", color: primary-color),
        xml: (name: "XML", icon: "", color: primary-color),
        yaml: (name: "YAML", icon: "", color: primary-color),
        yml: (name: "YAML", icon: "", color: primary-color),
    )

    //customize code font and raw code
    show raw: set text(font: code-font, size: 0.92em)
    show raw.line: set text(font: code-font, size: 0.92em)
    show raw.where(block: false): it => (
        h(0.25em)
            + box(
                fill: primary-color.lighten(92%),
                inset: (x: 0.25em),
                outset: (y: 0.15em),
                radius: 0.15em,
                it,
            )
            + h(0.25em)
    )

    show: codly-init.with()
    codly(
        languages: code-languages,
        default-color: primary-color,
        fill: primary-color.lighten(97%),
        zebra-fill: primary-color.lighten(94%),
        stroke: 0.6pt + primary-color.lighten(65%),
        radius: 0.25em,
        display-icon: false,
        header-transform: it => text(fill: primary-color, weight: 700, it),
        number-format: n => text(size: 0.8em, fill: primary-color.lighten(20%), str(n)),
    )

    // Set body font family.
    set text(font: body-font, lang: "zh", 12pt)
    show heading: set text(font: title-font, fill: primary-color, weight: 700)

    //heading numbering
    set heading(numbering: (..nums) => {
        let level = nums.pos().len()
        // only level 1 and 2 are numbered
        let pattern = if level == 1 {
            "I."
        } else if level == 2 {
            "I.1."
        }
        if pattern != none {
            numbering(pattern, ..nums)
        }
    })

    // add space for heading
    show heading.where(level: 1): it => it + v(0.5em)

    // Set link style
    show link: it => underline(text(fill: primary-color, it))

    //numbered list colored
    set enum(indent: 1em, numbering: n => [#text(fill: primary-color, numbering("1.", n))])

    //unordered list colored
    set list(indent: 1em, marker: n => [#text(fill: primary-color, "•")])


    // display of outline entries
    show outline.entry: it => text(size: 12pt, weight: "regular", it)

    // Title page.
    // Logo at top right if given
    if logo != none {
        set image(width: 6cm)
        place(top + right, logo)
    }
    // decorations at top left
    place(top + left, dx: -35%, dy: -28%, circle(radius: 150pt, fill: primary-color))
    place(top + left, dx: -10%, circle(radius: 75pt, fill: secondary-color))

    // decorations at bottom right
    place(bottom + right, dx: 40%, dy: 30%, circle(radius: 150pt, fill: secondary-color))


    v(2fr)

    align(center, text(font: title-font, 3em, weight: 700, title))
    v(2em, weak: true)
    if subtitle != none {
        align(center, text(font: title-font, 2em, weight: 700, subtitle))
        v(2em, weak: true)
    }
    align(center, text(1.1em, date))

    v(2fr)

    // Author and other information.
    align(center)[
        #if author != "" {
            text(font: title-font, weight: 700, author)
            linebreak()
        }
        #if affiliation != none {
            text(font: title-font, affiliation)
            linebreak()
        }
        #if year != none {
            text(font: title-font, year)
            linebreak()
        }
        #if class != none {
            text(font: title-font, class)
            linebreak()
        }
        #if other != none {
            emph(other.join(linebreak()))
            linebreak()
        }
    ]

    pagebreak()


    // Table of contents.
    set page(
        numbering: "1 / 1",
        number-align: center,
    )


    // Main body.
    set page(
        header: [#emph()[#title #h(1fr) #author]],
    )
    set par(justify: true, leading: 0.65em)

    //设置数学公式的标号
    set math.equation(numbering: "(1)", number-align: right)

    body
}

//useful functions
//set block-quote
#let blockquote = rect.with(stroke: (left: 2.5pt + luma(170)), inset: (left: 1em))

// use primary-color and secondary-color in main
#let primary-color = rgb("0E419C")
#let secondary-color = rgb(255, 80, 69, 60%)
