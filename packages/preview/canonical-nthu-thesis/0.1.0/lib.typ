#import "pages/zh-cover.typ": zh-cover-page
#import "pages/en-cover.typ": en-cover-page
#import "pages/outlines.typ": outline-pages
#import "layouts/preface.typ": preface-impl
#import "layouts/body.typ": body-impl

#let cover-pages-impl(info: (:)) = {
    zh-cover-page(info: info)
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
    ) + style

    let doc(it) = {
        set document(
            title: info.title-en + " " + info.title-zh,
            author: info.author-en + " " + info.author-zh,
            keywords: info.keywords-en + info.keywords-zh,
        )

        it
    }

    return (
        doc: doc,
        cover-pages: cover-pages-impl.with(info: info),
        preface: preface-impl.with(margin: style.margin),
        outline-pages: outline-pages,
        body: body-impl.with(margin: style.margin),
    )
}
