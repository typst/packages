
#import "meta-and-state.typ": is-html-target
#import "supports-html-internal.typ"
#let data-url(mime, src) = {
  import "@preview/based:0.2.0": base64
  "data:" + mime + ";base64," + base64.encode(src)
}

#let virt-slot(name) = figure(kind: "virt-slot:" + name, supplement: "_virt-slot")[]
#let set-slot(name, body) = it => {
  show figure.where(kind: "virt-slot:" + name): slot => body

  it
}

#let shiroa-assets = state("shiroa:assets", (:))
#let add-assets(global-style, cond: true) = if cond {
  shiroa-assets.update(it => {
    it.insert(global-style.text, global-style)
    it
  })
}
#let add-scripts(assets, cond: true) = add-assets(assets, cond: cond)
#let add-styles(assets, cond: true) = add-assets(assets, cond: cond)

#let inline-assets(body) = if is-html-target() {
  show raw.where(lang: "css"): it => {
    html.elem("link", attrs: (rel: "stylesheet", href: data-url("text/css", it.text)))
  }
  show raw.where(lang: "js"): it => {
    html.elem("script", attrs: (src: data-url("application/javascript", it.text)))
  }

  body
}
