//! Variables for typst.ts's dyn-svg controlling the layout
//! Here is a good example of dynamic layout template: <https://github.com/Myriad-Dreamin/shiroa/blob/308e0aacc2578e9a0c424d20332c6711d1df8d1c/contrib/typst/gh-pages.typ>

/// The default target is _pdf_.
/// `typst.ts` will set it to _web_ when rendering a dynamic layout.
///
/// Example:
/// ```typc
/// #let is-web-target() = target.starts-with("web")
/// #let is-pdf-target() = target.starts-with("pdf")
/// ```
#let target = sys.inputs.at("x-target", default: "pdf")

/// It is in default A4 paper size (21cm)
/// example:
/// ```typc
/// set page(
///   width: page-width,
///   height: auto, // Also, for a website, we don't need pagination.
/// ) if is-web-target;
/// ```
#let page-width = sys.inputs.at("x-page-width", default: 21cm)
