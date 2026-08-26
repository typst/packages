/// Lightweight Rust-like formatting.
///
/// This will simply iterate over the string, replacing each instance of `{}` with one of the provided arguments.
/// See also the `oxifmt` library for the more heavyweight alternative.
///
/// *Usage:*
///
/// ```typst
/// #let foo = "Hello"
/// #let bar = "world"
/// #let hello_world = fmt("{} {}, hello!", foo, bar)
/// #assert(hello_world, "Hello world, hello!")
/// ```
///
/// *Returns:*
///
/// The formatted string.
///
/// *Arguments:*
///
/// - format (str): e.g. "hello {}"
/// - args (arguments): e.g. "world"
#let fmt(format, ..args) = {
    assert.eq(
        args.named().len(),
        0,
        message: "`fmt` does not consume any named arguments. Got `" + repr(args.named().keys()) + "`",
    )
    let pieces = format.split("{}")
    let out = (pieces.at(0),)
    for (arg, piece) in args.pos().zip(pieces.slice(1), exact: true) {
        out.push(arg)
        out.push(piece)
    }
    out.join("")
}

/// Short for `panic(fmt(fmt, ..args))`
/// - format (str): e.g. "hello {}"
/// - args (arguments): e.g. "world"
#let panic-fmt(format, ..args) = {
    panic(fmt(format, ..args))
}
