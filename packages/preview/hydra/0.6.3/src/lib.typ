#import "/src/core.typ"
#import "/src/util.typ"
#import "/src/selectors.typ"

/// An anchor used to search from. When using @cmd:hydra outside of the page
/// header, this should be placed inside the page header to find the correct
/// searching @type:hydra-context. @cmd:hydra always searches from the last
/// anchor it finds, if and only if it detects that it is outside of the
/// top-margin.
///
/// -> content
#let anchor() = [#metadata(()) <hydra-anchor>]

/// #property(requires-context: true)
/// Query for an element within the bounds of its ancestors. The
/// @type:hydra-context passed to various callbacks contains the resolved
/// top-margin, the current location, as well as the binding direction, primary
/// and ancestor element selectors and customized functions.
///
/// -> content
#let hydra(
  /// This function is called at most once before rendering the candidate and
  /// should return true if they are eligible for display. The primary next
  /// candidate may be none. If this is #typ.v.auto no filter is applied and
  /// every candidate is considered eligible.
  ///
  /// Signature: #lambda("hydra-context", "candidates", ret: bool)
  ///
  /// -> function | auto
  prev-filter: auto,
  /// This function is called at most once before rendering the candidate and
  /// should return true if they are eligible for display. The primary prev
  /// candidate may be none. If this is #typ.v.auto no filter is applied and
  /// every candidate is considered eligible.
  ///
  /// Signature: #lambda("hydra-context", "candidates", ret: bool)
  ///
  /// -> function | auto
  next-filter: auto,
  /// A function which receives the @type:hydra-context and a candidate element
  /// to display. If this is #typ.v.auto, the default implementaion will be
  /// used.
  ///
  /// Signature: #lambda("hydra-context", content, ret: content)
  ///
  /// -> function | auto
  display: auto,
  /// Whether @cmd:hydra should show the current candidate even if it's on top of
  /// the current page.
  ///
  /// -> bool
  skip-starting: true,
  /// Whether @cmd:hydra should show the name of the first or last candidate on
  /// the page.
  ///
  /// -> bool
  use-last: false,
  /// Whether the binding direction should be considered for redundancy.
  /// If the binding direction is set it'll be used to check for redundancy
  /// when an element is visible on the previous page.
  ///
  /// -> bool
  book: false,
  /// The label to use for the anchor if @cmd:hydra is used outside the header.
  /// If this is #typ.v.none, the anchor is not searched.
  ///
  /// -> label | none
  anchor: <hydra-anchor>,
  /// The element to look for, to use other elements than headings, read the
  /// documentation on selectors. This can be an element function or selector,
  /// or an integer declaring a heading level.
  ///
  /// -> queryable | full-selector | int
  ..sel,
) = {
  util.assert.types("prev-filter", prev-filter, function, auto)
  util.assert.types("next-filter", next-filter, function, auto)
  util.assert.types("display", display, function, auto)
  util.assert.types("skip-starting", skip-starting, bool)
  util.assert.types("use-last", use-last, bool)
  util.assert.types("book", book, bool)
  util.assert.types("anchor", anchor, label, none)

  let (named, pos) = (sel.named(), sel.pos())
  assert.eq(named.len(), 0, message: util.fmt(
    "Unexected named arguments: `{}`",
    named,
  ))
  assert(pos.len() <= 1, message: util.fmt(
    "Unexpected positional arguments: `{}`",
    pos,
  ))

  let sanitized = selectors.sanitize("sel", pos.at(0, default: heading))

  let default-filter = (_, _) => true

  let ctx = (
    prev-filter: util.auto-or(prev-filter, () => default-filter),
    next-filter: util.auto-or(next-filter, () => default-filter),
    display: util.auto-or(display, () => core.display),
    skip-starting: skip-starting,
    use-last: use-last,
    book: book,
    anchor: anchor,
    primary: sanitized.primary,
    ancestors: sanitized.ancestors,
  )

  core.execute(ctx)
}
