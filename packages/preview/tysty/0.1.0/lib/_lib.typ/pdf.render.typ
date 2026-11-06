#import "doc.typ": _core_doc, current, documents
#import "types.typ": author
#import "indexer.typ": backlinks, indexers, mkindex
#import "state.typ": _mkstate
#import "util.typ": _match
#import "embed.typ": _embed
#import "render.common.typ": _breadcrumb-path, entities, file_base, lookup

#let embed(offset: true, body) = _embed(body, offset: offset)

#let _meta-color = rgb("#999")
#let _nav-color = rgb("#555")
#let _taxon-color = rgb("#555")

#let _slug(body) = text(size: 0.9em, fill: rgb("#888"), underline(stroke: (thickness: 0.5pt, dash: ("dot", 1pt)), body))

#let _authors(doc) = (
  doc
    .authors
    .map(a => {
      if _match(author, a) { link(a.home, a.name) } else if _match(str, a) { a }
    })
    .join(", ")
)
#let _content-to-text(body) = {
  if type(body) == str {
    return body
  }
  if body.has("text") {
    return body.text
  }
  if body.has("children") {
    return body.children.map(_content-to-text).join("")
  }
  ""
}

#let _truncate-middle(body, max: 20) = {
  let chars = _content-to-text(body).clusters()
  if chars.len() <= max {
    return body
  }
  let left = calc.ceil((max - 1) / 2)
  let right = max - 1 - left
  chars.slice(0, left).join() + "…" + chars.slice(chars.len() - right).join()
}

#let _details(doc) = {
  let parts = ()
  if doc.authors.len() > 0 { parts.push(_authors(doc)) }
  parts.push(doc.date.display("[year]-[month]-[day]"))
  if doc.tags.len() > 0 {
    parts.push(text(fill: _taxon-color, doc.tags.map(t => t.name).join(", ")))
  }
  parts
}


// A separate cover does not register the heading label a second time.
#let mkcover() = context {
  let doc = (current.get)()
  assert("id" in doc, message: "Call meta before mkcover")
  pagebreak(weak: true)
  mkindex(doc.id, align(center)[
    #v(1fr)
    #if doc.cover_image.variant in ("path", "data") {
      image(doc.cover_image.payload, width: 60%)
      v(1em)
    }
    #text(size: 2em, weight: 600, doc.title)
    #v(1em)
    #text(fill: _meta-color, _details(doc).join(" · "))
    #if doc.abstract != "" { block(above: 2em, doc.abstract) }
    #v(1fr)

    #set document(
      title: doc.title,
      author: doc.authors.map(v => if type(v) == str {
        v
      } else {
        v.name
      }),
      date: doc.date,
      description: doc.description,
      keywords: doc.keywords,
    )
  ])
  pagebreak(weak: true)
}

// Render the current note and register its id as a global index label.
#let mkdoc(new-page: true, cover: false, content) = context {
  let doc = (current.get)()
  [#metadata(doc.id) <tysty-rendered-document>]
  assert("id" in doc, message: "Call meta before mkheading")
  if new-page { pagebreak(weak: true) }
  // Register outside the heading body: outlines replay that body.
  if cover {
    mkcover()
  } else {
    mkindex(doc.id, block(below: 0.3em, heading(
      depth: 1,
      text(weight: 600, doc.title) + h(0.5em) + link((file_base.get)() + doc.file-path, _slug("[" + doc.id + "]")),
    )))
  }
  let parts = _details(doc)
  let parent-id = doc.parent-id
  if parent-id != doc.id and parent-id in entities() {
    parts.push(link(indexers().find(index => index.label == parent-id).loc, "[back]"))
  }
  block(above: 0.3em, below: 0.6em, text(size: 0.9em, fill: _meta-color, parts.join(" · ")))
  if doc.abstract != "" {
    block(above: 0.6em, below: 1em, doc.abstract)
  }
  content
}

// Shared outline row, using the destination's page counter and numbering.
#let _document-row(doc, loc) = {
  let page-format = loc.page-numbering()
  let page-label = numbering(
    if page-format == none { "1" } else { page-format },
    ..counter(page).at(loc),
  )
  block(width: 100%, link(loc, doc.title + h(0.5em) + box(width: 1fr, repeat[.]) + h(0.5em) + page-label))
}

#let render-children(
  title,
) = context {
  let doc = (current.get)()
  let docs = documents()
  let entries = indexers()
  let ids = entities()

  let children = docs.filter(
    d => d.parent-id == doc.id and d.id != doc.id and d.id in ids and entries.any(index => index.label == d.id),
  )

  if children.len() > 0 {
    heading(level: 2, outlined: false, title)

    for child in children {
      _document-row(child, entries.find(index => index.label == child.id).loc)
    }
  }
}

// Render a tree returned by tag.register, including its root. Each tag owns
// only its immediate child tags and documents explicitly declaring that tag.
// Read final metadata so this list can also precede the document headings.
#let render-tags(tree) = context {
  let entries = indexers()
  let ids = entities()
  let docs = documents().filter(doc => doc.id in ids and entries.any(index => index.label == doc.id))

  let render-node(node) = {
    let items = node.children.values().map(child => render-node(child))
    for doc in docs.filter(doc => doc.tags.any(tag => tag.id == node.tag.id)) {
      items.push(list.item(_document-row(doc, entries.find(index => index.label == doc.id).loc)))
    }
    list.item(
      strong(node.tag.name)
        + if items.len() > 0 {
          list(..items)
        } else {
          []
        },
    )
  }

  list(render-node(tree))
}

// Wishful-Thinking's note layout with tag names and the new global index.
#let template(body) = {
  set page(
    paper: "a4",
    margin: (
      x: 2em,
      top: 4em,
      bottom: 3em,
    ),
    header: context {
      let doc = (current.get)()
      if _match(_core_doc, doc) {
        let entries = indexers()
        let ids = entities()
        let pos = ids.position(id => id == doc.id)

        let nav = ()
        let tocs = query(outline)
        if tocs.len() > 0 {
          nav.push(link(tocs.first().location(), "[toc]"))
        }
        if pos != none and pos > 0 {
          nav.push(link(entries.find(index => index.label == ids.at(pos - 1)).loc, "[prev]"))
        }
        if pos != none and pos + 1 < ids.len() {
          nav.push(link(entries.find(index => index.label == ids.at(pos + 1)).loc, "[next]"))
        }

        let parts = (doc.title, doc.date.display("[year]-[month]-[day]"))

        let path = _breadcrumb-path(doc)
        let breadcrumbs = path.map(node => {
          let title = _truncate-middle(node.title)
          if entries.any(index => index.label == node.id) {
            link(entries.find(index => index.label == node.id).loc, title)
          } else {
            title
          }
        })

        grid(
          columns: (auto, 1fr),
          gutter: 1em,
          row-gutter: 4pt,
          text(size: 9pt, fill: _nav-color, align(left, nav.join(" "))),
          text(size: 9pt, fill: _meta-color, align(right, parts.join(" · "))),

          grid.cell(
            colspan: 2,
            text(size: 7pt, fill: _meta-color, breadcrumbs.join(" > ")),
          ),
        )
      }
    },
  )
  body
}
