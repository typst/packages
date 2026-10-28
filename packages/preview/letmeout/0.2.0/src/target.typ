// Target-specific content and rules.
// The function form leaves a marker next to its context fallback, so `letmeout`
// can apply the HTML rule directly and see the page set rules inside it. A
// context block would hide them.
#let marker-label = <letmeout-target>

// The show-rule implementation shared by the target helpers.
// Absent targets leave the content unchanged.
#let target-rule(html: body => body, paged: body => body) = body => {
  [#metadata((html: html, body: body))#marker-label]
  context { if target() == "html" { html(body) } else { paged(body) } }
}

// Content branches select content; function branches return a show rule.
// #by-target(html: [Web], paged: [Print])
// #show: by-target(html: body => { set page(width: auto); body })
// Missing content branches are empty. Missing function branches are identity.
#let by-target(html: none, paged: none) = {
  if type(html) == function or type(paged) == function {
    assert((html == none or type(html) == function) and (paged == none or type(paged) == function),
      message: "letmeout: by-target takes either content branches or function branches; do not mix them")
    return target-rule(
      html: if html == none { body => body } else { html },
      paged: if paged == none { body => body } else { paged },
    )
  }
  context { if target() == "html" { html } else { paged } }
}

// One-target shortcuts. Content is shown only there; functions are show rules
// that leave other targets unchanged. Native .with() functions keep rules short:
// #show: html-only(page.with(width: auto, margin: 1em))
// #show: paged-only(page.with(paper: "a4", margin: 2.5cm))
#let html-only(value) = by-target(html: value)
#let paged-only(value) = by-target(paged: value)

// Existing names remain aliases for compatibility.
#let for-target = by-target
#let for-html = html-only
#let for-paged = paged-only
#let on-target = by-target
#let show-target = target-rule

#let is-marker(it) = (repr(it.func()) == "metadata" and it.has("label")
  and it.label == marker-label)

// `#show: letmeout` calls this on the document in HTML. It applies each HTML
// rule left by `by-target` directly and drops its context fallback, so the
// page settings inside become visible. Markers deeper inside other elements
// keep working through the fallback.
#let resolve(it) = {
  let k = repr(it.func())
  if k == "sequence" {
    let children = ()
    let rest = it.children
    while rest.len() > 0 {
      let child = rest.remove(0)
      if is-marker(child) and rest.len() > 0 and repr(rest.first().func()) == "context" {
        let _ = rest.remove(0)
        children.push(resolve((child.value.html)(child.value.body)))
      } else { children.push(resolve(child)) }
    }
    return children.sum(default: [])
  }
  if k == "styled" { return it.func()(resolve(it.child), it.styles) }
  it
}
