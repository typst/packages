#import "/src/dependencies.typ": cetz
#import "/src/styles.typ"

/// initialize beam
///
/// Useful when working with other cetz extensions (for example #link("https://github.com/l0uisgrange/zap")[zap]) that bring their own canvas
/// ```typst
/// #cetz.canvas({
///   import cetz.draw: *
///   init-beam()
///   // draw setup here
/// })
/// ```
#let init-beam() = {
    cetz.draw.set-ctx(ctx => {
        ctx.insert("beam", ("style": styles.default))
        ctx
    })
}

/// beam's canvas wrapper. Takes care of proper initialization
/// ```typst
/// #beam.setup({
///     import beam: *
///     // draw setup here
/// })
/// ```
#let setup(body, preamble: none, ..params) = {
    cetz.canvas(..params, {
        init-beam()
        preamble
        body
    })
}
