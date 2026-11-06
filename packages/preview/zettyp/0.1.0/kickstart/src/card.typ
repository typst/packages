// Forester tree markup (tree.xsl): details > summary > header, with backmatter
// in a footer. The note's root heading becomes the card's summary, so its
// label remains the card's anchor. Links are ordinary refs to note labels.

#import "../../site/lib.typ" as site
#import site: html-rules, tree

#let meta-items(meta) = {
  let items = ()
  let lifecycle = meta.at("lifecycle", default: none)
  if type(lifecycle) == dictionary and lifecycle.value != "active" {
    items.push(html.span(class: "status", lifecycle.value))
  }
  let tags = meta.at("tags", default: ())
  if tags.len() > 0 { items.push(tags.join(", ")) }
  for (key, text) in (
    ("replaced-by", "Replaced by"),
    ("evolved-into", "Evolved into"),
  ) {
    let ids = meta.at(key, default: ())
    if ids.len() > 0 {
      items.push[#text #ids.map(id => ref(label(id))).join[, ]]
    }
  }
  items
}

#let frontmatter(note, title) = html.header({
  html.h1({
    title
    [ ]
    // A ref, so the slug is rendered as a link to its note like any other.
    html.span(class: "slug", ref(label(note.id), supplement: [\[#note.id\]]))
  })
  let items = meta-items(note.metadata)
  if items.len() > 0 {
    html.div(class: "metadata", html.ul(
      items.map(it => html.li(class: "meta-item", it)).join(),
    ))
  }
})

// Collapsed trees; the site expands each from its canonical card.
#let backmatter(title, notes) = if notes.len() > 0 {
  tree(
    html.header(html.h1(title)),
    notes
      .map(it => tree(
        frontmatter(it, it.title),
        none,
        open: false,
        attrs: site.expand-attrs(it.id),
      ))
      .join(),
  )
}

#let blank(value) = value in (none, "", (), (:), [])

// One metadata value as text: vocabulary members by name, lists joined.
#let metadata-value(value) = if type(value) == dictionary and "value" in value {
  value.value
} else if type(value) == dictionary {
  value
    .pairs()
    .filter(((_, it)) => not blank(it))
    .map(((key, it)) => [#key: #metadata-value(it)])
    .join[; ]
} else if type(value) == array {
  value.map(metadata-value).join[, ]
} else if type(value) == bool {
  if value [yes] else [no]
} else if type(value) in (str, content) { value } else { repr(value) }

/// The default `about` view: the note's metadata and its graph neighbourhood,
/// as the editor's hover shows them.
#let about(note) = html.elem("dl", attrs: (class: "zk-about"), {
  for (key, value) in note.metadata {
    if not blank(value) {
      html.elem("dt", key)
      html.elem("dd", metadata-value(value))
    }
  }
  html.elem("dt", "backlinks")
  html.elem("dd", str(note.backlinks.len()))
  html.elem("dt", "links")
  html.elem("dd", str(note.links.len()))
})

/// The card layout. `views` are policies deciding, per note, what the card
/// shows when it appears elsewhere, by name:
/// - `preview`: a hover preview, from a link in another card;
/// - `expand`: an in-place expansion of a collapsed tree;
/// - `about`: a hover preview from the card's own links (its slug, say);
///   by default its metadata.
/// Each returns `auto` (the card's title and body, marked in place), `none`
/// (no such view) or content, e.g. `note => [#note.metadata.abstract]`.
/// Content is rendered like the card, kept inert in a `<template>`, and does
/// not advance counters. `note.main` (the body without its root heading) can
/// be repeated safely; other labels it holds must not be referenced twice.
#let card(note, views: (:)) = {
  show: html-rules
  let shown = (
    (preview: note => auto, expand: note => auto, about: about) + views
  )
    .pairs()
    .map(((name, view)) => (name, view(note)))
    .to-dict()
  html.elem("details", attrs: (open: "") + site.view-attrs(shown), {
    show heading.where(level: 1): it => html.summary(frontmatter(note, it.body))
    note.body
  })
  site.view-templates(shown)
  html.footer({
    backmatter("Backlinks", note.backlinks)
    backmatter("Related", note.links)
  })
}
