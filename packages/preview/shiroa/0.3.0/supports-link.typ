
#import "meta-and-state.typ": shiroa-sys-target, x-url-base

#let link2page = state("shiroa-link2page", (:))

// todo: deprecated
#let cross-link-path-label(path) = {
  assert(path.starts-with("/"), message: "absolute positioning required")
  path.replace(regex(".typ$"), ".html")
}

/// Cross link support
#let cross-link(path, reference: none, content) = {
  let path = cross-link-path-label(path)
  if reference != none {
    assert(type(reference) == label, message: "invalid reference")
  }

  assert(content != none, message: "invalid label content")
  context {
    let link-result = link2page.final()
    if path in link-result {
      link((page: link-result.at(path), x: 0pt, y: 0pt), content)
      return
    }

    if reference != none {
      let result = query(reference)
      // whether it is internal link
      if result.len() > 0 {
        link(reference, content)
        return
      }
    }
    // assert(read(path) != none, message: "no such file")

    let path = path
    if path.starts-with("/") {
      path = path.slice(1)
    }
    let href = (
      x-url-base
        + path
        + if reference != none {
          if type(reference) == label {
            "#label-" + str(reference)
          } else {
            "#" + str(reference)
          }
        }
    )

    if shiroa-sys-target() == "html" {
      html.elem("a", content, attrs: (class: "typst-content-link", href: href))
    } else {
      link(href, content)
    }
  }
}
