// Typst 0.15 bundle export: emit a `.pdfpc` file next to every PDF document of
// a bundle. Bundle export is experimental and is enabled with `--features
// bundle` (or `TYPST_FEATURES=bundle`); outside that target these functions do
// nothing, so a file that calls them still compiles to a plain PDF.

/// Returns the location of the `document` element that contains `loc`.
///
/// Introspection in a bundle export sees the whole bundle rather than a single
/// document, so callers scope their queries with this. Outside bundle export
/// (and in the paged target) there is no `document` element and this returns
/// `none`, which callers read as "do not scope".
///
/// = Parameters
/// - `loc` (location): A location inside the document of interest.
///
/// = Returns
/// The document's location, or `none`.
#let _current-document-location(loc) = {
  let documents = query(selector(document).before(loc))
  if documents.len() > 0 {
    documents.last().location()
  } else {
    none
  }
}

/// Restricts `target` to the document that contains `loc`.
///
/// = Parameters
/// - `target` (selector, label or function): The selector to restrict.
/// - `loc` (location): A location inside the document of interest.
///
/// = Returns
/// The restricted selector, or the unrestricted one when there is no document.
#let _within-current-document(target, loc) = {
  let document-location = _current-document-location(loc)
  if document-location == none {
    selector(target)
  } else {
    selector(target).within(document-location)
  }
}

/// Writes the pdfpc payload of every presentation in a bundle export to a
/// `.pdfpc` file next to its PDF.
///
/// Call it at the top level of the file, outside every `#document(..)`. Each
/// PDF document that carries speaker notes gets one sidecar, named after the
/// document: `slides/deck.pdf` is accompanied by `slides/deck.pdfpc`. Outside
/// of a bundle export it does nothing, so a file containing the call still
/// compiles to a plain PDF.
///
/// = Example
/// ```typ
/// #import "@preview/pepentation:0.4.0": pdfpc-bundle-assets
///
/// #pdfpc-bundle-assets()
///
/// #document("deck.pdf", include "deck.typ")
/// ```
///
/// = Parameters
/// - `pretty` (boolean, default: `true`): Pretty-print the JSON.
#let pdfpc-bundle-assets(pretty: true) = context {
  if target() == "bundle" {
    for doc in query(document) {
      // The extension decides the format when it is not set explicitly, so a
      // bundle can also contain the source `.typ` files and non-PDF outputs.
      let path = str(doc.path)
      let is-pdf = if doc.format == auto {
        lower(path).ends-with(".pdf")
      } else {
        doc.format == "pdf"
      }
      if is-pdf {
        let files = query(selector(<pepentation-pdfpc>).within(doc.location()))
        if files.len() > 0 {
          asset(
            path.replace(regex("\\.[^./]*$"), "") + ".pdfpc",
            json.encode(files.last().value, pretty: pretty) + "\n",
          )
        }
      }
    }
  }
}
