#import "pages/zh-cover.typ": zh-cover-page
#import "pages/en-cover.typ": en-cover-page
#import "pages/outlines.typ": outline-pages
#import "layouts/preface.typ": preface-impl
#import "layouts/body.typ": body-impl
#import "layouts/doc.typ": doc-impl

#let cover-pages-impl(info: (:), style: (:)) = {
    zh-cover-page(info: info, style: style)
    en-cover-page(info: info)
}


#let setup-thesis(
    info: (:),
    style: (:),
) = {
    // The default values for info.
    info = (
        degree: "master",
        title-zh: [一個標題有點長的 \ 有趣的研究],
        title-en: [An Interesting Research \ With a Somewhat Long Title],
        department-zh: "某學系",
        department-en: "Mysterious Department",
        id: "012345678",
        author-zh: "張三",
        author-en: "San Chang",
        supervisor-zh: "李四 教授",
        supervisor-en: "Prof. Si Lee",
        // TODO: Revisit this when Typst support displaying datetime in non-English languages.
        year-zh: "一一三",
        month-zh: "七",
        date-en: "July 2024",
        keywords-zh: ("關鍵詞", "列表", "範例"),
        keywords-en: ("example", "keywords", "list"),
    ) + info

    // The default values for style.
    style = (
        // Margin sizes for all non-cover pages.
        margin: (top: 1.75in, left: 2in, right: 1in, bottom: 2in),
        // The fonts used throughout the thesis.
        fonts: ("New Computer Modern", "TW-MOE-Std-Kai"),
        // The math equation fonts used throughout the thesis.
        math-fonts: ("New Computer Modern"),
        // Whether to show a list of tables in the `outline-pages()` function.
        outline-tables: true,
        // Whether to show a list of figures in the `outline-pages()` function.
        outline-figures: true,
        // Whether to show the text "Draft version" and the date on the margin.
        show-draft-mark: false,
        // The row heights of the Chinese cover page.
        cover-row-heights: (30pt, 30pt, 30pt),
    ) + style

    return (
        doc: doc-impl.with(info: info, style: style, show-draft-mark: style.show-draft-mark),
        cover-pages: cover-pages-impl.with(info: info, style: style),
        preface: preface-impl.with(margin: style.margin),
        outline-pages: outline-pages.with(
            outline-tables: style.outline-tables,
            outline-figures: style.outline-figures,
        ),
        body: body-impl.with(margin: style.margin),
    )
}
