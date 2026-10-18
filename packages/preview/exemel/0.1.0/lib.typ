#let _plugin = plugin("xml_plugin.wasm")

#let to-xml(value, pretty: false, header: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>") = {
  if type(value) != array {
    value = (value,)
  }
  header
  if pretty { "\n" }
  for val in value {
    str(_plugin.to_xml(cbor.encode((
      root: val,
      pretty: pretty,
    ))))
  }
}

#let atom-site-id(
  scheme: "tag",
  authority: none,
  time: none,
  identifier: "blog/feed",
) = {
  if authority == none {
    panic("`authority` cannot be `none`! Enter a domain you control (e.g. example.com)")
  }
  if type(time) != datetime {
    panic("`time` must be a `datetime`!")
  }
  scheme + ":" + authority + "," + time.display("[year]-[month]-[day]") + ":" + identifier
}

#let atom-author(
  name,
  email: none,
  uri: none,
) = {
  (
    tag: "author",
    children: (
      (tag: "name", children: (name,)),
      ..if email != none { ((tag: "email", children: (email,)),) } else { () },
      ..if uri != none { ((tag: "uri", children: (uri,)),) } else { () },
    ),
  )
}

#let atom-post(
  title,
  link: none,
  id: none,
  updated: none,
  published: none,
  summary: none,
  content: none,
  content-type: "html",
  authors: (),
  categories: (),
) = {
  if link == none {
    panic("`link` cannot be `none`!")
  }
  if id == none {
    panic("`id` cannot be `none`! See `atom-site-id` for a helper.")
  }
  if type(updated) != datetime {
    panic("`updated` must be a `datetime`!")
  }
  if published != none and type(published) != datetime {
    panic("`published` must be a `datetime`!")
  }

  (
    tag: "entry",
    children: (
      (tag: "title", children: (title,)),
      (
        tag: "link",
        attrs: (rel: "alternate", type: "text/html", href: link),
      ),
      (tag: "id", children: (id,)),
      (tag: "updated", children: (updated.display("[year]-[month]-[day]T[hour]:[minute]:[second]Z"),)),
      ..if published != none {
        ((tag: "published", children: (published.display("[year]-[month]-[day]T[hour]:[minute]:[second]Z"),)),)
      } else { () },
      ..if summary != none { ((tag: "summary", children: (summary,)),) } else { () },
      ..if content != none {
        ((tag: "content", attrs: (type: content-type), children: (content,)),)
      } else { () },
      ..authors,
      ..categories.map(term => (tag: "category", attrs: (term: term))),
    ),
  )
}

#let atom-encode(
  title: none,
  subtitle: none,
  site-link: none,
  feed-link: auto,
  id: none,
  updated: none,
  authors: (),
  posts: (),
) = {
  if title == none {
    panic("`title` cannot be `none`!")
  }
  if site-link == none {
    panic("`site-link` cannot be `none`!")
  }
  if id == none {
    panic("`id` cannot be `none`! See `atom-site-id` for a helper.")
  }
  if type(updated) != datetime {
    panic("`updated` must be a `datetime`!")
  }

  let resolved-feed-link = if feed-link == auto {
    site-link + "feed.xml"
  } else {
    feed-link
  }

  let c = (
    tag: "feed",
    attrs: (xmlns: "http://www.w3.org/2005/Atom"),
    children: (
      (tag: "title", children: (title,)),
      ..if subtitle != none { ((tag: "subtitle", children: (subtitle,)),) } else { () },
      (
        tag: "link",
        attrs: (rel: "self", type: "application/atom+xml", href: resolved-feed-link),
      ),
      (
        tag: "link",
        attrs: (rel: "alternate", type: "text/html", href: site-link),
      ),
      (tag: "id", children: (id,)),
      (tag: "updated", children: (updated.display("[year]-[month]-[day]T[hour]:[minute]:[second]Z"),)),
      ..authors,
      ..posts,
    ),
  )

  to-xml(c, pretty: true)
}
