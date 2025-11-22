#import "../utils/cover-with-rect.typ": cover-with-white-rect

#let body-impl(
    margin: (:),
    it,
) = {
    // Returns whether the current page has a chapter (top-level) heading.
    let is-chapter-start-page() = {
        // Find chapter headings on the current page.
        let all-chapter-headings = query(heading.where(level: 1))
        let current = counter(page).get()
        let page-chapter-headings = all-chapter-headings.filter(m => m.location().page() == here().page())

        return page-chapter-headings.len() > 0
    }

    // Set the page numbering to arabic numerals.
    //
    // Although we use custom headers and footers to display the page numbers in the body part,
    // this is still required to show the page numbers in arabic numerals in the outlines.
    set page(numbering: "1")

    set page(
        margin: margin,
        background: cover-with-white-rect(image("../nthu-logo.svg", width: 1.95in, height: 1.95in)),
        header: context {
            if not is-chapter-start-page() {
                let chapter-headings-so-far = query(heading.where(level: 1).before(here()))
                let chapter-heading = chapter-headings-so-far.last()
                let chapter-number = counter(heading).at(chapter-heading.location()).at(0)

                // Show the chapter number, the chapter name, and the page number in the header.
                smallcaps("Chapter " + str(chapter-number) + ".")
                h(0.75em)
                smallcaps(chapter-heading.body)
                h(1fr)
                counter(page).display()
            }
        },
        footer: context {
            if is-chapter-start-page() {
                // Show the chapter number centered in the footer.
                h(0.5fr)
                counter(page).display()
                h(0.5fr)
            }
        }
    )

    // Reset the page counter for the body.
    // TODO: Figure out why is-chapter-start-page returns true for page 2 when this line is moved above.
    counter(page).update(1)

    set text(
        size: 12pt,
        font: ("New Computer Modern", "TW-MOE-Std-Kai"),
        hyphenate: true,
    )

    set par(
        leading: 1.5em,
        first-line-indent: 2em,
        linebreaks: "optimized",
    )

    set heading(numbering: "1.1.1")

    show heading: it => locate(loc => {
        let size = if it.level == 2 {
            18pt
        } else {
            14pt
        }
        block(width: 100%, {
            set text(size: size)
            // Collapse 1em vertically if there is a parent heading close enough above.
            // Otherwise, space 1em vertically.
            let all-prev-headings = query(selector(heading).before(loc), loc)
            if all-prev-headings.len() > 1 {
                let prev-heading = all-prev-headings.at(-2)
                let is-same-page = prev-heading.location().page() == it.location().page()
                let is-close = prev-heading.location().position().y + 250pt > it.location().position().y
                let is-parent = prev-heading.level == it.level - 1
                if (is-same-page and is-close and is-parent) {
                    v(-1em)
                } else {
                    v(1em)
                }
            } else {
                v(1em)
            }

            // Show the numbering and the body of the heading.
            box(
                width: 100%,
                stack(
                    dir: ltr,
                    counter(heading).display(it.numbering),
                    h(1em),
                    it.body
                )
            )
            v(1em)
        })
    })

    show heading.where(
        level: 1,
    ): it => {
        // Start a chapter on a new page unless it's the 1st chapter,
        // in which case it is already on a new page.
        if counter(heading).get() != (1,) {
            pagebreak()
        }

        if it.numbering == none {
            // Show the body of the heading.
            block(width: 100%, {
                set text(size: 24pt)
                v(3em)
                it.body
                v(2em)
            })
        } else {
            // Show "Chapter n" and the body of the heading on 2 separate lines.
            block(width: 100%, {
                set text(size: 24pt)
                v(3em)
                text([Chapter ] + counter(heading).display(it.numbering))
                linebreak()
                it.body
                v(2em)
            })
        }
    }

    it
}
