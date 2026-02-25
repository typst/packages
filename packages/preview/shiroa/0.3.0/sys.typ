//! Here is a good example of dynamic layout template: <https://github.com/Myriad-Dreamin/shiroa/blob/308e0aacc2578e9a0c424d20332c6711d1df8d1c/contrib/typst/gh-pages.typ>

// todo: deprecate me which is conflict with sys.target

/// The default target is _pdf_.
/// `typst.ts` will set it to _web_ when rendering a dynamic layout.
///
/// Example:
/// ```typc
/// #let is-web-target() = target.starts-with("web")
/// #let is-pdf-target() = target.starts-with("pdf")
/// ```
#let x-target = sys.inputs.at("x-target", default: "pdf")
/// Deprecated: Use `x-target` instead.
#let target = x-target

/// The url-base is `/`. This is usually needed when you deploy on GitHub Pages.
///
/// For example, if you deploy on `https://myriad-dreamin.github.io/shiroa/`, you should set it to `/shiroa/`.
#let x-url-base = sys.inputs.at("x-url-base", default: "/")
#if not x-url-base.starts-with("/") {
  x-url-base = "/" + x-url-base
}
#if not x-url-base.ends-with("/") {
  x-url-base = x-url-base + "/"
}

/// Experimental.
/// passing the current file path.
#let x-current = sys.inputs.at("x-current", default: none)

/// It is in default A4 paper size (21cm)
/// example:
/// ```typc
/// set page(
///   width: page-width,
///   height: auto, // Also, for a website, we don't need pagination.
/// ) if is-web-target;
/// ```
#let page-width = sys.inputs.at("x-page-width", default: 21cm)
