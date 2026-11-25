// citrus - Nocite API Module
//
// Provides nocite() function for including bibliography entries without citing them.

/// Include bibliography entries without citing them in-text
///
/// Accepts string arguments, a content body with @key references, or "*" for all entries:
///
/// ```typst
/// #nocite[@smith2020 @jones2021]
/// #nocite("smith2020", "jones2021")
/// #nocite("*")
/// ```
///
/// - keys: Citation keys (strings or content with @key refs). Use "*" to include all entries.
#let nocite(..args) = {
  let raw-list = args.pos()

  if raw-list.len() == 0 { return }

  // Content body path: #nocite[@key1 @key2 ...]
  let keys = if raw-list.len() == 1 and type(raw-list.first()) == content {
    let body = raw-list.first()
    let children = if body.has("children") {
      body.children
    } else {
      (body,)
    }
    children
      .filter(it => it != [ ] and it != parbreak())
      .map(it => {
        if it.func() == ref {
          str(it.target)
        } else if it.func() == cite {
          str(it.key)
        } else {
          panic("nocite: expected @key or cite(), got " + repr(it))
        }
      })
  } else {
    // String arguments path
    raw-list.map(item => {
      if type(item) == str {
        item
      } else {
        panic("nocite: expected string key or \"*\", got " + repr(item))
      }
    })
  }

  // Place metadata for each key (NO counter step — separate from cite-marker)
  for key in keys {
    if key == "*" {
      [#metadata((all: true))<citeproc-nocite>]
    } else {
      [#metadata((key: key))<citeproc-nocite>]
    }
  }
}
