// Heading styling

#import "typography.typ": fonts, leading

/// Shared heading styling: per-level sizes and spacing, chapter page breaks and
/// counter resets, and number–body alignment. Apply as a show rule.
///
/// - font-sizes (dict): Format-specific font sizes resolved by the template.
/// - serif-headings (bool): Use Libertinus Serif for headings when `true`.
/// - heading-numbering-depth (int): Deepest heading level that receives a number.
/// - body (content): Document body (injected automatically by the show rule).
/// -> content
#let setup-headings(
    font-sizes,
    serif-headings: false,
    heading-numbering-depth: 3,
    body,
) = {
    let hfont = if serif-headings { fonts.serif } else { fonts.sans }

    show heading: set par(leading: leading * 0.75)

    // Lay out a heading's number and body in a two-column grid so that text
    // across all heading levels aligns at the same horizontal position.
    // The indent width is determined by the longest numbering present in the
    // document (i.e. the deepest heading level), measured at that level's font size.
    let _heading-grid(it) = {
        // Font size for each heading depth — used when measuring number widths.
        // Index 0 is unused; depths start at 1.
        let depth-sizes = (
            font-sizes.chapter,
            font-sizes.chapter, // depth 1
            font-sizes.section, // depth 2
            font-sizes.subsection, // depth 3
            font-sizes.subsubsection, // depth 4
        )

        // Find the widest rendered heading number in the document.
        // fold() walks every heading, measures its number at the correct font
        // size, and keeps a running maximum — giving a pixel-precise indent.
        let all-headings = query(heading)
        let indent = all-headings.fold(0pt, (max-w, h) => {
            if h.numbering == none or h.depth > heading-numbering-depth { return max-w }
            let depth = calc.min(h.depth, depth-sizes.len() - 1)
            // Reconstruct the number string from the counter at this heading's location.
            let num = numbering(
                h.numbering,
                ..counter(heading).at(h.location()).slice(0, h.depth),
            )
            let w = measure(text(
                font: hfont,
                size: depth-sizes.at(depth),
                weight: "bold",
            )[#num]).width
            calc.max(max-w, w)
        })

        if it.numbering != none and it.depth <= heading-numbering-depth {
            let num = numbering(
                it.numbering,
                ..counter(heading).at(it.location()).slice(0, it.depth),
            )
            grid(
                columns: (indent, 1fr),
                column-gutter: 0.5 * font-sizes.base,
                align: (top + left, top + left),
                [#num], it.body,
            )
        } else {
            // Unnumbered headings (e.g. front matter) need no grid.
            it.body
        }
    }

    show heading: it => {
        // Per-level sizes and spacing — index = level - 1, clamped so level 4+
        // all inherit the last entry.
        let sizes = (
            font-sizes.chapter, // level 1
            font-sizes.section, // level 2
            font-sizes.subsection, // level 3
            font-sizes.subsubsection, // level 4+
        )
        // Spacing uses block(above:, below:) with explicit values (weakness=3) so that
        // adjacent spacings collapse to the larger of the two rather than stacking.
        // This makes H1→text, H1→H2, and H1→figure all produce the same gap.
        // H1.above is a strong v() instead of block.above because it must survive at
        // the top of the fresh page after the pagebreak.
        let h1-above = 4em
        let above = (0pt, 2.0em, 1.7em, 1.4em) // H1: handled by h1-above; H2+: block.above
        let below = (3em, 1.5em, 1.4em, 1.25em)
        let idx = calc.min(it.level - 1, sizes.len() - 1)

        if it.level == 1 {
            counter(math.equation).update(0)
            counter(footnote).update(0)
            // Typst never resets figure counters at a heading, and it keeps one
            // counter per `kind`. Reading the kinds off the document instead of a
            // fixed list means custom kinds restart per chapter too — otherwise
            // their numbers pick up the new chapter but keep counting on
            // (2.1, 2.2, 4.3), with nothing to warn about it.
            context {
                for kind in query(figure).map(fig => fig.kind).dedup() {
                    counter(figure.where(kind: kind)).update(0)
                }
            }
            {
                set page(header: none, footer: none)
                pagebreak(weak: true, to: "odd")
            }
            v(h1-above)
        }
        block(above: above.at(idx), below: below.at(idx))[
            #set par(justify: false)
            #set text(
                font: hfont,
                size: sizes.at(idx),
                weight: "bold",
                hyphenate: false,
            )
            #context _heading-grid(it)
        ]
    }

    body
}
