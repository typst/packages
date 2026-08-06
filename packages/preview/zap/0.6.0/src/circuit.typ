#import "/src/deps.typ": cetz
#import "/src/styles.typ": default

/// CeTZ native canvas wrapper
///
/// https://zap.grangelouis.ch/#getting-started
///
/// - drawing (none, array, element): canvas content, typically containing the circuit elements
/// -> content
#let circuit(drawing, ..params) = {
    cetz.canvas(..params, {
        // Init style directory
        cetz.draw.set-ctx(ctx => {
            ctx.style.insert("zap", default)
            return ctx
        })
        drawing
    })
}
