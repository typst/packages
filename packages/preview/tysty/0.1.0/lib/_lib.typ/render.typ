#import "pdf.render.typ" as _pdf
#import "html.render.typ" as _html
#import "render.common.typ": lookup, set-base
#import "ssg.render.typ" as _ssg
#import "art.typ": current, meta

// Resolve at the call site: a bundle may contain both HTML and paged documents.
// PNG/SVG export and HTML frames also use Typst's "paged" target.
#let _auto(paged, web) = (..args) => context {
  if target() == "paged" { paged(..args) } else { web(..args) }
}

#let mkcover = _auto(_pdf.mkcover, _html.mkcover)
#let embed(..args) = context {
  if target() == "bundle" or _ssg.is-bundle-output() { _ssg.embed(..args) } else if target() == "paged" {
    _pdf.embed(..args)
  } else { _html.embed(..args) }
}

#let mkdoc(..args) = context {
  if target() == "bundle" { _ssg.mkdoc(..args) } else if target() == "paged" { _pdf.mkdoc(..args) } else {
    _html.mkdoc(..args)
  }
}

#let mkoutline(..args) = context {
  if target() == "bundle" or _ssg.is-bundle-output() {
    _ssg.mkoutline(..args)
  } else {
    outline(..args)
  }
}

#let render-children = _auto(_pdf.render-children, _html.render-children)

#let render-tags = _auto(_pdf.render-tags, _html.render-tags)

// A bundle needs its shared assets; individual pages provide their own shell.
#let template(body, ..options) = context {
  if target() == "bundle" {
    _html.bundle(body, ..options)
  } else if target() == "html" {
    _html.template(body, ..options)
  } else {
    _pdf.template(body, ..options)
  }
}

#let entry(..args, content) = context {
  let fields = arguments.named(args)
  if not ("parent-id" in fields) {
    let parent = (current.get)().at("id", default: auto)
    if parent != auto {
      fields.insert("parent-id", parent)
    }
  }
  meta(..fields) + mkdoc(content)
}

