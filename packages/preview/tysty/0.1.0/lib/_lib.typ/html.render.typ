#import "doc.typ": current, documents
#import "indexer.typ": indexers, mkindex
#import "render.common.typ": _breadcrumb-path, entities, file_base, lookup
#import "embed.typ": _embed

#let embed(offset: false, body) = _embed(body, offset: offset)

// This module uses Typst's built-in html; the public html namespace wraps it.
#let stylesheet = read("html.render.css")

#let _element(tag, class, body) = html.elem(tag, attrs: (class: class), body)

#let _details(doc) = {
  let authors = doc.authors.map(a => {
    if type(a) == str { a } else if a.home == "" { a.name } else { link(a.home, a.name) }
  })
  let parts = ()
  if authors.len() > 0 { parts.push(authors.join(", ")) }
  parts.push(html.elem(
    "time",
    attrs: (datetime: doc.date.display("[year]-[month]-[day]")),
    doc.date.display("[year]-[month]-[day]"),
  ))
  if doc.tags.len() > 0 { parts.push(doc.tags.map(t => t.name).join(", ")) }
  _element("div", "tysty-details", parts.join(" · "))
}

// Navigation uses plain links: rendering a menu must not create backlinks.
#let _navigation(doc) = context {
  let entries = indexers()
  let ids = entities()
  let pos = ids.position(id => id == doc.id)
  let links = ()
  if pos != none and pos > 0 {
    links.push(link(entries.find(index => index.label == ids.at(pos - 1)).loc, [Previous]))
  }
  if doc.parent-id != doc.id and entries.any(index => index.label == doc.parent-id) {
    links.push(link(entries.find(index => index.label == doc.parent-id).loc, [Parent]))
  }
  if pos != none and pos + 1 < ids.len() {
    links.push(link(entries.find(index => index.label == ids.at(pos + 1)).loc, [Next]))
  }
  if links.len() > 0 {
    html.elem("nav", attrs: (class: "tysty-navigation", aria-label: "Note navigation"), links.join(" · "))
  } else {
    []
  }
}

#let _breadcrumbs(doc) = context {
  let entries = indexers()
  let docs = documents()
  let path = _breadcrumb-path(doc, docs)
  let crumbs = path.map(node => {
    if entries.any(index => index.label == node.id) {
      link(entries.find(index => index.label == node.id).loc, node.title)
    } else { node.title }
  })
  html.elem("nav", attrs: (class: "tysty-breadcrumbs", aria-label: "Breadcrumb"), crumbs.join(" / "))
}

// Covers are presentation only, outside the primary-index reading sequence.
#let mkcover() = context {
  let doc = (current.get)()
  _element("header", "tysty-cover", mkindex(doc.id, [
    #if doc.cover_image.variant in ("path", "data") {
      image(doc.cover_image.payload, alt: "Cover image")
    }
    #html.elem("h1", doc.title)
    #_details(doc)
    #if doc.abstract != "" { _element("p", "tysty-abstract", doc.abstract) }
  ]))
}

// new-page is accepted for shared PDF/HTML source; HTML flows continuously.
#let mkdoc(new-page: true, cover: false, ssg: false, content) = context {
  let scope = here()
  let doc = (current.get)()
  [#metadata(doc.id) <tysty-rendered-document>]
  let article = _element("article", "tysty-note", [
    #if cover {
      mkcover()
    } else {
      mkindex(doc.id, heading(depth: 1, [
        #doc.title
        #_element("span", "tysty-note-id", link((file_base.get)() + doc.file-path, "[" + doc.id + "]"))
      ]))
    }
    #_details(doc)
    #if not ssg { _navigation(doc) }
    #if not ssg { _breadcrumbs(doc) }
    #if doc.abstract != "" { _element("p", "tysty-abstract", doc.abstract) }
    #content
  ])
  if ssg {
    _element("div", "tysty-site-page", [
      #_element("header", "tysty-topbar", [#_navigation(doc) #_breadcrumbs(doc)])
      #_element("div", "tysty-page-layout", [
        #article
        #_element("aside", "tysty-page-outline", outline(
          title: none,
          target: heading.where(outlined: true).within(scope),
        ))
      ])
    ])
  } else {
    article
  }
}

#let render-children(title) = context {
  let doc = (current.get)()
  let entries = indexers()
  let ids = entities()
  let children = documents().filter(d => (
    d.parent-id == doc.id and d.id != doc.id and d.id in ids and entries.any(index => index.label == d.id)
  ))
  if children.len() > 0 {
    _element("section", "tysty-children", [
      #heading(level: 2, outlined: false, title)
      #list(..children.map(d => link(entries.find(index => index.label == d.id).loc, d.title)))
    ])
  }
}

#let render-tags(tree) = context {
  let entries = indexers()
  let ids = entities()
  let docs = documents().filter(d => d.id in ids and entries.any(index => index.label == d.id))
  let node(it) = {
    let items = it.children.values().map(node)
    for doc in docs.filter(d => d.tags.any(t => t.id == it.tag.id)) {
      items.push(list.item(link(entries.find(index => index.label == doc.id).loc, doc.title)))
    }
    list.item(strong(it.tag.name) + if items.len() > 0 { list(..items) } else { [] })
  }
  _element("section", "tysty-tags", list(node(tree)))
}

// Inline CSS makes single-file HTML portable. Bundle pages link the shared asset.
#let template(body, title: "Notebook", lang: "en", css: stylesheet, css-href: none) = {
  html.elem("html", attrs: (lang: lang), [
    #html.elem("head", [
      #html.elem("meta", attrs: (charset: "utf-8"))
      #html.elem("meta", attrs: (name: "viewport", content: "width=device-width, initial-scale=1"))
      #html.elem("title", title)
      #if css-href == none {
        html.elem("style", css)
      } else {
        html.elem("link", attrs: (rel: "stylesheet", href: css-href))
      }
    ])
    #html.elem("body", _element("main", "tysty", body))
  ])
}

// Paths are relative to the output bundle, independent of document IDs.
// Each page restores the caller's current-document scope.
#let page(path, body, title: "Notebook", lang: "en") = {
  assert(
    path.ends-with(".html")
      and not path.starts-with("/")
      and path.split("/").all(p => p != ".." and p != "." and p != ""),
    message: "HTML page path must be a relative .html path without dot segments",
  )
  let css-href = "../" * (path.split("/").len() - 1) + "tysty.css"
  document(path, title: title)[
    #(current.enter)()
    #template(body, title: title, lang: lang, css-href: css-href)
    #(current.leave)()
  ]
}

// Use as #show: html.bundle with --features html,bundle --format bundle.
#let bundle(body, css: stylesheet) = {
  asset("tysty.css", bytes(css))
  body
}
