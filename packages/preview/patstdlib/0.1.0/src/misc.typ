/// Indicates a task that is still to-do. Renders like `TODO(author)[text here]`, all in red.
///
/// *Examples:*
///
/// ```typst
/// #TODO[]                      // renders as: TODO
/// #TODO[foo]                   // renders as: TODO[foo]
/// #TODO(author: patrick)[]     // renders as: TODO(patrick)
/// #TODO(author: patrick)[foo]  // renders as: TODO(patrick)[foo]
/// ```
///
/// *Arguments:*
///
/// - doc (content): the text to render.
/// - author (content): the author of the to-do.
/// -> content
#let TODO(author: none, doc) = {
    set text(font: "DejaVu Sans Mono", size: 0.9em, fill: red)
    if author == none {
        if doc == [] [TODO] else [TODO\[#doc\]]
    } else {
        if doc == [] [TODO(#author)] else [TODO(#author)\[#doc\]]
    }
}

/// Indicates a citation that needs filling in. Renders like `CITE[text here]`, all in red.
///
/// *Examples:*
///
/// ```typst
/// #CITE[]     // renders as: CITE
/// #CITE[foo]  // renders as: CITE[foo]
/// ```
///
/// *Arguments:*
///
/// - doc (content): the text to render.
/// -> content
#let CITE(doc) = {
    set text(font: "DejaVu Sans Mono", size: 0.9em, fill: red)
    if doc == [] [CITE] else [CITE\[#doc\]]
}

/// Creates either a fraction `dx/dy`, or just a `dx` e.g. for use at the end of an integral.
///
/// *Constructors:*
///
/// There are two valid constructors:
///
/// 1. `dd(x)` to create a single-line `dx`.
/// 2. `dd(x, y)` to create a fraction `dx/dy`.
///
/// In addition both forms consumes a `d:` keyword argument, defaulting to `math.dif`, indicating how to render the `d`.
///
/// -> content
#let dd(..x, d: math.dif) = {
    if x.named().len() > 0 { panic }
    x = x.pos()
    if x.len() == 1 { $#d#x.at(0)$ } else if x.len() == 2 { $(#d#x.at(0)) / (#d#x.at(1))$ } else { panic }
}

/// As `dd`, but uses `d: math.diff`.
///
/// -> content
#let partial(..x) = dd(..x, d: math.diff)

/// Rounds a number to a specified number of significant figures.
///
/// - x (str, int, float, decimal): a number to round.
/// - digits (int): the number of significant digits to round to.
/// -> decimal
#let sigfig(x, digits: none) = {
    assert(digits != none, message: "Must provide `digits` keyword argument.")
    assert(digits > 0, message: "`digits` must be positive.")

    // Convert to a decimal with enough zeros, so that we get the right number of trailing zeros out.
    if type(x) == float {
        x = str(x)  // Suppress decimal conversion warning
    }
    x = str(decimal(x))
    if "." not in x {
        x = x + "."
    }
    x = decimal(x + "0" * digits)

    let trunc = calc.trunc(x)
    let trunc_len = if trunc == 0 { 0 } else { str(calc.abs(trunc)).len() }
    let decimal_digits = digits - trunc_len
    assert(decimal_digits >= 0, message: "Cannot truncate to fewer significant digits than the integer component has.")
    calc.round(x, digits: decimal_digits)
}
