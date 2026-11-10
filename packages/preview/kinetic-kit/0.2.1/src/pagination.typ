// pagination.typ — page break helpers shared by the style engine

/// Break to the next odd page, leaving any filler page blank.
///
/// -> content
#let break-to-odd-page() = {
    set page(header: none, footer: none)
    pagebreak(weak: true, to: "odd")
}
