/// A stub function for #link("https://staging.typst.app/docs/reference/html/elem/")[`std.html.elem()`].
/// This function simply contextually panics, i.e. it can be called but its result must not appear
/// in a document:
///
/// ```typ
/// // assume `--features html` is not active
/// #let x = std.html.elem("div")  // panics, because `std.html` does not exist
/// #let y = bullseye.html.elem("div")  // ok
/// #y  // panics, because bullseye doesn't actually implement HTML elements
/// ```
///
/// This is useful for writing code where alternative content for HTML is specified, but only
/// rendered when HTML support is activated.
#let elem(..args) = context panic()

/// A stub function for #link("https://staging.typst.app/docs/reference/html/frame/")[`std.html.frame()`].
/// This function simply contextually panics, i.e. it can be called but its result must not appear
/// in a document:
///
/// ```typ
/// // assume `--features html` is not active
/// #let x = std.html.frame[body]  // panics, because `std.html` does not exist
/// #let y = bullseye.html.frame[body]  // ok
/// #y  // panics, because bullseye doesn't actually implement HTML elements
/// ```
///
/// This is useful for writing code where alternative content for HTML is specified, but only
/// rendered when HTML support is activated.
#let frame(..args) = context panic()
