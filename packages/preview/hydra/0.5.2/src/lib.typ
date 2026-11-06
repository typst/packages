#import "/src/core.typ"
#import "/src/util.typ"
#import "/src/selectors.typ"

/// An anchor used to search from. When using `hydra` ouside of the page header, this should be
/// placed inside the pge header to find the correct searching context. `hydra` always searches from
/// the last anchor it finds, if and only if it detects that it is outside of the top-margin.
#let anchor() = [#metadata(()) <hydra-anchor>]

/// Query for an element within the bounds of its ancestors.
///
/// The context passed to various callbacks contains the resolved top-margin, the current location,
/// as well as the binding direction, primary and ancestor element selectors and customized
/// functions.
///
/// This function is contextual.
///
/// - ..sel (any): The element to look for, to use other elements than headings, read the
///   documentation on selectors. This can be an element function or selector, or an integer
///   declaring a heading level.
/// - prev-filter (function, auto): A function which receives the `context` and `candidates`, and
///   returns if they are eligible for display. This function is called at most once. The primary
///   next candidate may be none. If this is `auto` no filter is applied.
/// - next-filter (function, auto): A function which receives the `context` and `candidates`, and
///   returns if they are eligible for display. This function is called at most once. The primary
///   prev candidate may be none. If this is `auto` no filter is applied.
/// - display (function, auto): A function which receives the `context` and candidate element to
///   display. If this is `auto`, the default implementaion will be used.
/// - skip-starting (bool): Whether `hydra` should show the current candidate even if it's on top of
///   the current page.
/// - use-last (bool): If hydra should show the name of the first or last candidate on the page.
//    Defaults to false.
/// - dir (direction, auto): The reading direction of the document. If this is `auto`, the text
///   direction is used. Be cautious about leaving this option on `auto` if you switch text
///   direction mid-page and use hydra outside of footers or headers.
/// - binding (alignement, auto): The binding of the document. If this is `auto`, the binding is
///   inferred from `dir`, similar to how it is done in page. Be cautious about leaving this on
///   option on `auto` if you switch text direction mid-page and use hydra outside of footers or
///   headers.
/// - book (bool): The binding direction if it should be considered, `none` if not. If the binding
///   direction is set it'll be used to check for redundancy when an element is visible on the last
///   page. Make sure to set `binding` and `dir` if the document is not using left-to-right reading
///   direction.
/// - anchor (label, none): The label to use for the anchor if `hydra` is used outside the header.
///   If this is `none`, the anchor is not searched.
/// -> content
#let hydra(
  prev-filter: auto,
  next-filter: auto,
  display: auto,
  skip-starting: true,
  use-last: false,
  dir: auto,
  binding: auto,
  book: false,
  anchor: <hydra-anchor>,
  ..sel,
) = {
  util.assert.types("prev-filter", prev-filter, function, auto)
  util.assert.types("next-filter", next-filter, function, auto)
  util.assert.types("display", display, function, auto)
  util.assert.types("skip-starting", skip-starting, bool)
  util.assert.types("use-last", use-last, bool)
  util.assert.enum("dir", dir, ltr, rtl, auto)
  util.assert.enum("binding", binding, left, right, auto)
  util.assert.types("book", book, bool)
  util.assert.types("anchor", anchor, label, none)

  let (named, pos) = (sel.named(), sel.pos())
  assert.eq(named.len(), 0, message: util.fmt("Unexected named arguments: `{}`", named))
  assert(pos.len() <= 1, message: util.fmt("Unexpected positional arguments: `{}`", pos))

  let sanitized = selectors.sanitize("sel", pos.at(0, default: heading))

  let default-filter = (_, _) => true
  let dir = util.auto-or(dir, core.get-text-dir)
  let binding = util.auto-or(binding, () => page.binding)
  let binding = util.auto-or(binding, () => util.page-binding(dir))

  let ctx = (
    prev-filter: util.auto-or(prev-filter, () => default-filter),
    next-filter: util.auto-or(next-filter, () => default-filter),
    display: util.auto-or(display, () => core.display),
    skip-starting: skip-starting,
    use-last: use-last,
    dir: dir,
    binding: binding,
    book: book,
    anchor: anchor,
    primary: sanitized.primary,
    ancestors: sanitized.ancestors,
  )

  core.execute(ctx)
}
