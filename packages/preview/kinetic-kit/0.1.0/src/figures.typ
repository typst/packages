// Figure, caption, and table styling

#import "translations.typ": t
#import "figure-kinds.typ": resolve-figure-kinds, resolve-localized

// Whether we're rendering inside an outline; lets captions switch to short form.
#let in-outline = state("in-outline", false)

/// Two-part caption: short version for LoF/LoT, long version under the figure.
///
/// Usage: `#figure(…, caption: flex-caption(short: [Short], long: [Long.]))`
///
/// - short (content): Short caption shown in List of Figures / Tables.
/// - long (content): Full caption shown below the figure in the document body.
/// -> content
#let flex-caption(short: none, long: none) = context if in-outline.get() {
    short
} else {
    long
}

// One show-set rule per registered kind. A `show` rule governs only the rest of its
// enclosing block, so rules emitted straight into the loop body would never reach the
// document. Re-wrapping the accumulated content each pass puts every rule ahead of
// everything it has to style.
#let _setup-supplements(kinds, lang, body) = {
    let styled = body
    for entry in kinds {
        styled = {
            // Resolved at the figure rather than here, so a passage that switches
            // `text.lang` gets that language's supplement.
            show figure.where(kind: entry.kind): set figure(
                supplement: context resolve-localized(
                    entry.supplement,
                    text.lang,
                    fallback: lang,
                    kind: entry.kind,
                    field: "supplement",
                ),
            )
            styled
        }
    }
    styled
}

/// Shared figure, caption, and table styling. Apply as a show rule.
///
/// - font-sizes (dict): Format-specific font sizes resolved by the template.
/// - lang (str): Document language — `"de"` or `"en"`.
/// - figure-kinds (array): Figure kind declarations, merged onto the built-in
///   ones. Only the supplements are read here; list pages are printed by the
///   template's back matter.
/// - body (content): Document body (injected automatically by the show rule).
/// -> content
#let setup-figures(font-sizes, lang: "de", figure-kinds: (), body) = {
    // Fallback for kinds the document never declared — they still get a caption,
    // just a generic one.
    set figure(supplement: it => if it.func() == table {
        t.at(lang).table
    } else {
        t.at(lang).figure
    })
    show: _setup-supplements.with(resolve-figure-kinds(figure-kinds), lang)
    show figure.where(kind: table): set figure.caption(position: top)
    set table(stroke: 0.3pt)

    show figure.caption: it => layout(container => context {
        let body = [
            #set text(size: font-sizes.small)
            #text(
                weight: "bold",
            )[#it.supplement #it.counter.display(it.numbering):]
            #it.body
        ]
        // Left-align captions ≥ 2 lines
        let h = measure(body, width: container.width).height
        if h > font-sizes.small * 1.5 {
            align(left, body)
        } else {
            align(center, body)
        }
    })

    set figure(numbering: it => {
        let ch = counter(heading.where(level: 1)).at(here()).first()
        if ch > 0 { numbering("1.1", ch, it) } else { numbering("1", it) }
    })
    set figure(gap: 0.8em)
    show figure: set block(above: 1.5em, below: 1.5em)

    body
}
