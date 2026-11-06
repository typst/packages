
#import "meta-and-state.typ": shiroa-sys-target

#let link2page = state("shiroa-link2page", (:))

#let encode-url-component(s) = {
  let prev = false
  for (idx, c) in s.codepoints().enumerate() {
    if c.starts-with(regex("[a-zA-Z]")) {
      if prev {
        prev = false
        "-"
      }
      c
    } else {
      prev = true
      if idx != 0 {
        "-"
      }
      str(c.to-unicode())
    }
  }
}

#let cross-link-path-label(path) = {
  assert(path.starts-with("/"), message: "absolute positioning required")
  encode-url-component(path)
}

/// Cross link support
#let cross-link(path, reference: none, content) = {
  let path-lbl = cross-link-path-label(path)
  if reference != none {
    assert(type(reference) == label, message: "invalid reference")
  }

  assert(content != none, message: "invalid label content")
  context {
    let link-result = link2page.final()
    if path-lbl in link-result {
      link((page: link-result.at(path-lbl), x: 0pt, y: 0pt), content)
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

    let href = {
      "cross-link://jump?path-label="
      path-lbl
      if reference != none {
        "&label="
        encode-url-component(str(reference))
      }
    }

    if shiroa-sys-target() == "html" {
      html.elem("a", content, attrs: (class: "typst-content-link", href: href))
    } else {
      link(href, content)
    }
  }
}
