// Fix https://github.com/typst/typst/issues/4359
/// Prefer this to `figure`. It adds a `label` argument, which fixes an issue with hyperlinks.
#let labeled-figure(..args, placement: none, clearance: 1em, label: none) = {
    assert(placement in (none, auto, bottom, top))
    let out = figure(..args)
    out = if label == none { out } else [#out #label]
    if placement != none {
        placement = if placement == auto { placement } else { placement + center }
        out = place(placement, clearance: clearance, float: true, out)
    }
    out
}

#let _subfigure-enabled = state("cff4409cca2e4ba580b2343755cdc628", none)
#let _subfigure-supplement = state("a9a416beff354362a74ef2e7710d7d61", none)
#let _subfigure-subsupplement = state("a1522481a72c4586ae634bd2646bb602", none)
#let _subfigure-kind = "20bead2ae82843c1bae51d6c208631e8"

/// Creates a subfigure. For use within the body of a `figure`. This adds a counter, a caption, and makes it referable.
///
/// Arguments are largely as `figure`. Differences:
/// - `placement` and `kind` are all superfluous and removed.
/// - `outlined` defaults to `false`, `supplement` defaults to nothing, and `numbering` defaults to `"(a)"`.
/// - New argument `label`. When referred to from outside the enclosing figure, it will render as e.g. `Figure 3(a)`.
///     The word 'Figure' in this example is inherited from the enclosing figure. When referred to from inside the
///     enclosing figure (e.g. from its caption), it will render as e.g. `Panel (a)`.
/// - New argument `subsupplement`. This defines the word 'Panel' when referred to this figure, as above.
/// - New argument `gap-below`. This adds vspace below the caption, which is often useful to add space between the
///     caption of the subfigure and the caption of the figure.
#let subfigure(
    body,
    ..args,
    supplement: _ => none,
    numbering: "(a)",
    gap: 0.65em,
    outlined: false,
    label: none,
    subsupplement: "Panel",
    gap-below: 0.65em,
) = {
    context assert.ne(
        _subfigure-enabled.get(),
        none,
        message: "Call `#show: enable-referable-subfigures` before using `subfigure`.",
    )
    _subfigure-subsupplement.update(subsupplement)
    set par(spacing: 0em)
    [#body#v(gap)#figure(
            [],
            ..args,
            placement: none,
            kind: _subfigure-kind,
            supplement: supplement,
            gap: 0em,
            outlined: outlined,
            numbering: numbering,
        )#label#v(gap-below)]
}
/// Enables the use of subfigures. Set up the relevant show rules.
#let enable-referable-subfigures(doc) = {
    context assert.eq(_subfigure-enabled.get(), none, message: "Cannot call `enable-referable-subfigures` twice.")
    _subfigure-enabled.update(true)
    show figure.where(kind: image): fig => {
        counter(figure.where(kind: _subfigure-kind)).update(0)
        _subfigure-supplement.update((fig.supplement, fig.numbering))
        show ref: it => {
            let el = it.element
            if type(el) == content and el.func() == figure and el.kind == _subfigure-kind {
                let subsupplement = _subfigure-subsupplement.at(el.location())
                let subfigcounter = counter(figure.where(kind: _subfigure-kind)).at(el.location()).at(0)
                link(
                    el.location(),
                    {
                        subsupplement
                        [~]
                        numbering(el.numbering, subfigcounter)
                    },
                )
            } else {
                it
            }
        }
        fig
    }
    show ref: it => {
        let el = it.element
        if type(el) == content and el.func() == figure and el.kind == _subfigure-kind {
            let (figsupplement, fignumbering) = _subfigure-supplement.at(el.location())
            let figcounter = counter(figure.where(kind: image)).at(el.location()).at(0)
            let subfigcounter = counter(figure.where(kind: _subfigure-kind)).at(el.location()).at(0)
            link(
                el.location(),
                {
                    figsupplement
                    [~]
                    numbering(fignumbering, figcounter)
                    numbering(el.numbering, subfigcounter)
                },
            )
        } else {
            it
        }
    }
    doc
}
