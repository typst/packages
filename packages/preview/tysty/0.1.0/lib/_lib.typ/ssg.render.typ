#import "html.render.typ" as _html
#import "doc.typ": current, documents
#import "embed.typ": _embed

#let embed(offset: false, body) = _embed(body, offset: offset)

// `document()` switches nested page content to the HTML target, so retain the
// outer bundle target for automatic render helpers called inside a page.
#let is-bundle-output = () => query(<tysty-bundle-output>).len() > 0
#let entities() = query(<tysty-ssg-document>).map(item => item.value).dedup()
#let _page-body-selector(id) = std.label("tysty-ssg-page-body:" + id)

// Create a stable route from explicit semantic ancestry. This is pure so the
// caller can calculate routes before emitting any bundle documents.
#let _slug(value) = {
  // Keep Unicode letters and digits. Slashes remain route separators so
  // identifiers such as `guides/setup` can describe a multi-file route.
  let slug = lower(value)
    .split("/")
    .map(part => part.replace(regex("[^\\p{L}\\p{N}]+"), "-").trim("-"))
    .filter(part => part != "")
    .join("/", default: "")
  if slug == "" { "untitled" } else { slug }
}

// `ancestors` are root-to-parent IDs. The root page is index.html.
#let route(id, ancestors: (), root: false) = {
  if root {
    "index.html"
  } else {
    (ancestors.map(_slug) + (_slug(id),)).join("/") + "/index.html"
  }
}

#let _document-route(doc) = {
  let docs = documents()
  let visited = ()
  let parts = ()
  let node = doc
  while true {
    assert(node.id not in visited, message: "Cyclic parent while computing SSG route")
    visited.push(node.id)
    if node.parent-id == node.id { break }
    parts.insert(0, _slug(node.id))
    node = docs.find(doc => doc.id == node.parent-id)
  }
  if parts.len() == 0 { "index.html" } else { parts.join("/") + "/index.html" }
}

#let _relative-route(destination, source) = {
  let from = source.split("/").slice(0, -1)
  let to = destination.split("/")
  let common = 0
  while common < from.len() and common < to.len() and from.at(common) == to.at(common) {
    common += 1
  }
  ("../" * (from.len() - common)) + to.slice(common).join("/")
}

// A route-aware outline of all registered documents, grouped by parent.
#let _outline-node(doc, docs, generated, source, active-id) = {
  let children = docs.filter(child => child.parent-id == doc.id and child.id != doc.id)
  let href = _relative-route(_document-route(doc), source)
  let attrs = (href: href) + if doc.id == active-id { (aria-current: "page") } else { (:) }
  let label = if doc.id in generated {
    html.elem("a", attrs: attrs, doc.title)
  } else {
    html.elem("span", attrs: (class: "tysty-unrendered"), doc.title)
  }
  html.elem("li", [
    #label
    #if children.len() > 0 {
      html.elem("ul", children.map(child => _outline-node(child, docs, generated, source, active-id)).join())
    }
  ])
}

#let mkoutline(depth: none, title: [Documents]) = context {
  let docs = documents()
  let generated = entities()
  let active = (current.get)()
  let source = _document-route(active)
  let roots = docs.filter(doc => doc.parent-id == doc.id)
  html.elem("nav", attrs: (class: "tysty-site-outline", aria-label: "Site outline"), [
    #html.elem("h2", title)
    #html.elem("ul", roots.map(doc => _outline-node(doc, docs, generated, source, active.id)).join())
  ])
}

// Embed a generated page's Typst body by its document label.
#let ref(label) = context {
  let docs = documents()
  let doc = docs.find(doc => doc.id == label)
  let generated = entities()
  assert(label in generated, message: "SSG page is registered but has not been generated: `" + label + "`")
  let body = query(_page-body-selector(label)).last().value
  (current.enter)()
  (current.update)(doc)
  body
  (current.leave)()
}

// Bundle mkdoc uses the route derived from current metadata. Other targets
// keep their ordinary HTML/PDF rendering behavior.
#let mkdoc(cover: false, body) = context {
  if target() == "bundle" {
    [#metadata(true) <tysty-bundle-output>]
    let doc = (current.get)()
    [#metadata(doc.id) <tysty-ssg-document>]
    [#metadata(body)#_page-body-selector(doc.id)]
    let path = _document-route(doc)
    let depth = path.split("/").len() - 1
    let css-href = "../" * depth + "tysty.css"
    document(path, title: doc.title)[
      #_html.template(
        _html.mkdoc(
          ssg: true,
          cover: cover,
          body,
        ),
        title: doc.title,
        css-href: css-href,
      )
    ]
  } else {
    _html.mkdoc(
      cover: cover,
      body,
    )
  }
}

