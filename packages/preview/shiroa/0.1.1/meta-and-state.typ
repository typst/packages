
#import "sys.typ": target, page-width

// Export typst.ts variables again, don't use sys arguments directly

/// The default target is _pdf_.
/// `typst.ts` will set it to _web_ when rendering a dynamic layout.
///
/// Example:
/// ```typc
/// #let is-web-target() = target.starts-with("web")
/// #let is-pdf-target() = target.starts-with("pdf")
/// ```
#let target = target

/// The default page width is A4 paper's width (21cm).
///
/// Example:
/// ```typc
/// set page(
///   width: page-width,
///   height: auto, // Also, for a website, we don't need pagination.
/// ) if is-web-target;
/// ```
#let get-page-width() = page-width

/// Whether the current compilation is for _web_
#let is-web-target() = target.starts-with("web")
/// Whether the current compilation is for _pdf_
#let is-pdf-target() = target.starts-with("pdf")

/// Derived book variables from `sys.args`
#let book-sys = (
  target: target,
  page-width: page-width,
  is-web-target: is-web-target(),
  is-pdf-target: is-pdf-target(),
)

/// Store the calculated metadata of the book.
#let book-meta-state = state("book-meta", none)
