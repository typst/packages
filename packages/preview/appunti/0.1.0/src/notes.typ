// Internal
#import "i18n.typ": current-language, translate
#import "theme.typ": resolve-theme

// Algorithmic
#import "@preview/algorithmic:1.0.7"
#import algorithmic: *

// Hydra
#import "@preview/hydra:0.6.3": hydra

// Theorion
#import "@preview/theorion:0.6.0": show-theorion, set-theorion-numbering, set-inherited-levels

/// Default logo
#let default-logo = (
    data: none,
    align: left,
    width: 7.5cm,
)

/// Lecture notes template with a title page, outline and running headers.
///
/// - course (str): Course name, shown as the main title.
/// - degree (str): Degree programme, shown above the title.
/// - author (str): Author name.
/// - logo (dictionary): Title page image.
///   - `data`: SVG or image bytes, from `read(path, encoding: none)`.
///   - `align`: Alignment on the page. Defaults to `left`.
///   - `width`: Displayed width. Defaults to `7.5cm`.
/// - language (str): Language code for text and localized strings.
/// - theme (dictionary): Color overrides. Missing keys keep their default.
///   - `background`: Page fill.
///   - `foreground`: Body text.
///   - `link`: Links.
///   - `rule`: Rules, table borders and algorithm lines.
/// - body (content): Document content.
/// -> content
#let notes(
    course: "Course",
    degree: "Degree",
    author: "Author",
    logo: (:),
    language: "en",
    theme: (:),
    body,
) = {
    // Palette
    let palette = resolve-theme(theme)

    // Algorithmic
    show: style-algorithm.with(
        hlines: (
            grid.hline(stroke: 0.5pt + palette.rule),
            grid.hline(stroke: 0.5pt + palette.rule),
            grid.hline(stroke: 0.5pt + palette.rule),
        ),
    )

    // Theorion
    show: show-theorion

    set-theorion-numbering("1.1")
    set-inherited-levels(1)

    // i18n
    current-language.update(language)
    let strings = translate(language)

    // Global styling rules
    set document(
        title: course,
        author: author,
    )

    set text(
        size: 12pt,
        fill: palette.foreground,
        lang: language,
    )

    set heading(numbering: "1.1")
    show heading.where(level: 1): it => {
        if it.outlined {
            pagebreak(weak: true)

            [#strings.chapter #counter(heading).display("1")]
            v(1em, weak: true)
            text(size: 2em)[#it.body]
        } else {
            it.body
        }
    }

    show link: it => underline(text(fill: palette.link)[#it])

    set table(stroke: 0.5pt + palette.rule)

    // Front matter
    set page(
        fill: palette.background,
        margin: (x: 3.5cm, y: 3cm),
        numbering: none,
    )

    let logo = default-logo + logo
    if logo.data != none {
        align(logo.align, image(logo.data, width: logo.width))
        v(0em)
    }

    text(size: 1.5em)[#degree]
    v(1em, weak: true)
    text(2em)[*#course*]

    v(0em)

    text(1.25em)[#author]

    line(length: 100%, stroke: 1pt + palette.rule)

    outline()

    pagebreak()

    // Body
    set page(
        numbering: none,
        header: context {
            if hydra(1) != none {
                hydra(heading, skip-starting: false)
                h(1fr)
                counter(page).display("1")
                v(0.5em, weak: true)
                line(length: 100%, stroke: 0.5pt + palette.rule)
            }
        },
    )

    counter(page).update(1)

    body
}
