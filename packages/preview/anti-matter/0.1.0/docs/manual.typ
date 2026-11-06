#import "@preview/tidy:0.1.0"

#import "template.typ": project
#let package = toml("/typst.toml").package

#show: project.with(
    package: package,
    date: datetime.today().display(),
    abstract: [
        This packages automaticall numbers the front and back matter fo your document separately
        from the main content. This is commonly used for books and theses.
    ]
)

#let codeblocks(body) = {
    show raw.where(block: true): set block(
        width: 100%,
        fill: gray.lighten(50%),
        radius: 5pt,
        inset: 5pt
    )

    show "{{version}}": package.version

    body
}

#show heading.where(level: 1): it => pagebreak(weak: true) + it
#outline(
    indent: auto,
    target: heading.where(outlined: true).before(<api-ref>, inclusive: true),
)

= Introduction
#[
    #show: codeblocks

    A document like this:
    #raw(
        block: true,
        lang: "typst",
        read("/example/main.typ").replace(
            regex("/src/lib.typ"),
            "@preview/anti-matter:{{version}}",
        ),
    )

    Would generate an outline like this:
    #block(fill: gray.lighten(50%), radius: 5pt, inset: 5pt, image("/example/example.png"))

    The front matter (in this case the outlines) are numbered using `"I"`, the content starts new at
    `"1"` and the back matter (glossary, acknowledgement, etc) are numbered `"I"` again, continuing
    from where the front matter left off.
]

= How it works & caveats
#[
    #show: codeblocks

    `anti-matter` keeps track of it's own inner and outer counter, which are updated in the header
    of a page. Numbering at a given location is resolved by inspecting where this location is
    between the given fences and applying the expected numbering to it. Both `page.header` and
    `outline.entry` need some special care if you wish to configure them. While `page.header` can
    simply be set in `anti-matter`, if you want to set it somewhere else you need to ensure that the
    counters are stepped. Likewise `outline.entry` or anything that displays page numbers for
    elements need to resolve the apge number from `anti-matter`.

    == Numbering
    Numbering is done as usual, with a string or function, or `none`. If the numbering is set to
    `none` then the counter is not stepped. Patterns and functions receive the current and total
    value. Which means that `"1 / 1"` will display `"3 / 5"` on the third out of five pages.
    ```typst
    #import "@preview/anti-matter:{{version}}": anti-matter, fence
    #show: anti-matter(numbering: ("I", numbering.with("1 / 1"), none))
    ```

    == Fences
    For `anti-matter` to know in which part of the document it is, it needs exactly 2 fences, these
    must be placed on the last page of the front matter and the last page of the main content. Make
    sure to put them before your page breaks, otherwise they'll be pushed onto the next page. Fences
    are placed with `fence()`.
    ```typst
    #import "@preview/anti-matter:{{version}}": anti-matter, fence
    #show: anti-matter

    // front matter
    #lorem(1000)
    #fence()

    // content
    #lorem(1000)
    #fence()

    // back matter
    #lorem(1000)
    ```

    == Page header
    `anti-matter` uses the page header to step it's own counters. If you want to adjust the page
    header sometime after the `anti-matter` show rule, you have to add `step()` before it.
    ```typst
    #import "@preview/hydra:0.2.0": hydra
    #import "@preview/anti-matter:{{version}}": anti-matter, step
    #show: anti-matter

    // ...
    // after front matter
    #set page(header: step() + hydra())
    ```

    == Outline entries and querying
    By default `outline` will use the regular page counter to resolve the page number. If you want
    to configure the appearance of `outline` but still get the correct page numbers use
    `page-number` with the element location.
    ```typst
    #import "@preview/anti-matter:{{version}}": anti-matter, page-number
    #show: anti-matter

    // render your own outline style while retaining the correct page numbering for queried elements
    #show outline.entry: it => {
        it.body
        box(width: 1fr, it.fill)
        page-number(loc: it.element.location())
    }
    ```

    The same logic applies to other things where elemnts are queried and display their page number.
]

= API-Reference <api-ref>
#let mods = (
    (`anti-matter`, "/src/lib.typ", [
        The public and stable library API intended for regular use.
    ]),
    (`core`, "/src/core.typ", [
        The core API, used for querying internal state, public, but not stable.
    ]),
    (`rules`, "/src/rules.typ", [
        Show and set rules which are applied in `anti-matter`, provides default versions to turn of
        rule.
    ]),
)

#for (title, path, descr) in mods [
    == #title
    #descr

    #tidy.show-module(tidy.parse-module(read(path)), style: tidy.styles.default)
]
