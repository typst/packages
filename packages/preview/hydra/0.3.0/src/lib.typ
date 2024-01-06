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
/// - ..sel (any): The element to look for, to use other elements than headings, read the
///   documentation on selectors. This can be an element function or selector, an integer declaring
///   a heading level.
/// - prev-filter (function): A function which receives the `context` and `candidates`, and returns
///   if they are eligible for display. This function is called at most once. The primary next
///   candidate may be none.
/// - next-filter (function): A function which receives the `context` and `candidates`, and returns
///   if they are eligible for display. This function is called at most once. The primary prev
///   candidate may be none.
/// - display (function): A function which receives the `context` and candidate element to display.
/// - skip-starting (bool): Whether `hydra` should show the current candidate even if it's on top of
///   the current page.
/// - book (bool): The binding direction if it should be considered, `none` if not. If the binding
///   direction is set it'll be used to check for redundancy when an element is visible on the last
///   page. Make sure to set `binding` and `dir` if the document is not using left-to-right reading
///   direction.
/// - binding (alignment): The binding direction of the document.
/// - dir (direction): The reading direction, that is, the direction pages are read in, this is
///   usually the same as the text direction, but doesn't have to be.
/// - paper (str): The paper size of the current page, used to calculate the top-margin.
/// - page-size (length, auto): The smaller page size of the current page, used to calculated the
///   top-margin.
/// - top-margin (length, auto): The top margin of the current page, used to check if the current
///   page has a primary candidate on top.
/// - anchor (label, none): The label to use for the anchor if `hydra` is used outside the header.
///   If this is `none`, the anchor is not searched.
/// - loc (location, none): The location to use for the callback, if this is not given `hydra` calls
///   locate internally, making the return value opaque.
/// -> content
#let hydra(
  prev-filter: (ctx, c) => true,
  next-filter: (ctx, c) => true,
  display: core.display,
  skip-starting: true,
  book: false,
  binding: left,
  dir: ltr,
  paper: "a4",
  page-size: auto,
  top-margin: auto,
  anchor: <hydra-anchor>,
  loc: none,
  ..sel,
) = {
  util.assert.types("prev-filter", prev-filter, function)
  util.assert.types("next-filter", next-filter, function)
  util.assert.types("display", display, function)
  util.assert.types("skip-starting", skip-starting, bool)
  util.assert.types("book", book, bool)
  util.assert.enum("binding", binding, left, right)
  util.assert.enum("dir", dir, ltr, rtl)
  util.assert.types("paper", paper, str)
  util.assert.types("page-size", page-size, length, auto)
  util.assert.types("top-margin", top-margin, length, auto)
  util.assert.types("anchor", anchor, label, none)
  util.assert.types("loc", loc, location, none)

  // if margin is auto we need the page size
  if top-margin == auto {
    // if page size is auto then only paper was given
    if page-size == auto {
      if paper == auto {
        panic("Must set one of `paper`, `page-size` or `top-margin`")
      }

      page-size = util.page-sizes.at(paper, default: none)
      assert.ne(page-size, none, message: util.fmt("Unknown paper: `{}`", paper))
      page-size = calc.min(page-size.w, page-size.h)
    }

    // the calculation given by page.margin's documentation
    top-margin = (2.5 / 21) * page-size
  }

  let (named, pos) = (sel.named(), sel.pos())
  assert.eq(named.len(), 0, message: util.fmt("Unexected named arguments: `{}`", named))
  assert(pos.len() <= 1, message: util.fmt("Unexpected positional arguments: `{}`", pos))

  let sanitized = selectors.sanitize("sel", pos.at(0, default: heading))

  let func = loc => {
    let ctx = (
      prev-filter: prev-filter,
      next-filter: next-filter,
      display: display,
      skip-starting: skip-starting,
      book: book,
      binding: binding,
      dir: dir,
      top-margin: top-margin,
      anchor: anchor,
      loc: loc,
      primary: sanitized.primary,
      ancestors: sanitized.ancestors,
    )

    core.execute(ctx)
  }

  if loc != none {
    func(loc)
  } else {
    locate(func)
  }
}
