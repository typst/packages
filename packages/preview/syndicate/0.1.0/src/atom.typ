// Functions that generate Atom 1.0 feeds (RFC 4287).

#import "util.typ" as _util
#import "xml.typ" as _xml

#let _ns = "http://www.w3.org/2005/Atom"
#let _content-type = content

/// Makes a `tag:` URI (RFC 4151). Use it as a permanent, unique identifier for a
/// feed or an entry. The identifier does not change when your URLs change.
///
/// ```examplec
/// atom.tag-uri("example.com", "2026-07-01", "blog/hello-world")
/// ```
///
/// -> str
#let tag-uri(
  /// A domain name or an email address that you controlled on `date`. -> str
  authority,
  /// A date on which you controlled `authority`. Usually, this is the date
  /// when you made the feed or the entry. -> datetime | str
  date,
  /// A text that is unique for this authority and date. -> str
  specific,
) = {
  let authority = _util.to-text(authority, field: "authority").trim()
  if authority == "" { panic("`authority` must not be empty") }
  let date = _util.to-datetime(date, field: "date").display("[year]-[month]-[day]")
  "tag:" + authority + "," + date + ":" + _util.to-text(specific, field: "specific")
}

/// Describes a person for the `authors` and `contributors` of feeds and
/// entries. Where a function expects a person, you can also use a string. The
/// function uses the string as the name.
///
/// -> dictionary
#let author(
  /// The name of the person. -> str | content
  name,
  /// An email address. -> str | none
  email: none,
  /// A web page. -> str | none
  uri: none,
) = _util.record("person", (
  name: _util.to-text(name, field: "name"),
  email: _util.opt-text(email, field: "email"),
  uri: _util.opt-text(uri, field: "uri"),
))

#let _person(p, field) = {
  if type(p) in (str, _content-type) { return author(p) }
  if _util.is-record(p, "person") { return p }
  if type(p) == dictionary and "name" in p {
    return author(p.name, email: p.at("email", default: none), uri: p.at("uri", default: none))
  }
  panic(
    "entries of `" + field + "` must be strings or created with `atom.author`, found " + repr(p),
  )
}

#let _people(list, field) = _util.flatten(list).map(p => _person(p, field))

#let _render-person(tag, p) = (
  tag: tag,
  children: (
    (tag: "name", children: (p.name,)),
    if p.email != none { (tag: "email", children: (p.email,)) },
    if p.uri != none { (tag: "uri", children: (p.uri,)) },
  ),
)

#let _category(c) = {
  if type(c) != dictionary {
    return (tag: "category", attrs: (term: _util.to-text(c, field: "category")))
  }
  if "term" not in c { panic("category dictionaries need a `term`, found " + repr(c)) }
  (
    tag: "category",
    attrs: (
      term: _util.to-text(c.term, field: "term"),
      scheme: _util.opt-text(c.at("scheme", default: none), field: "scheme"),
      label: _util.opt-text(c.at("label", default: none), field: "label"),
    ),
  )
}

// Makes a text construct, for example <title> or <content>. The function does not write
// `type="text"`, because it is the default.
#let _text(tag, value, kind: "text") = if value != none {
  (
    tag: tag,
    attrs: (type: if kind != "text" { kind }),
    children: (_util.to-text(value, field: tag),),
  )
}

/// Describes an entry for `atom.feed(entries: ..)`.
///
/// ```typc
/// atom.entry(
///   "Hello, world",
///   link: "https://example.com/blog/hello/",
///   published: "2026-07-01",
///   summary: [My _first_ post],
/// )
/// ```
///
/// -> dictionary
#let entry(
  /// The title. -> str | content
  title,
  /// A permanent, unique identifier. The default is `link`. If your URLs can
  /// change, use `atom.tag-uri`. -> str | auto
  id: auto,
  /// The URL of the web page of the entry. It is necessary if there is no `content`. -> str | none
  link: none,
  /// The date of the last important change. The default is `published`. -> datetime | str | auto
  updated: auto,
  /// The date of the first publication. -> datetime | str | none
  published: none,
  /// A short summary in plain text. -> str | content | none
  summary: none,
  /// The full content. A string is HTML source. The function escapes it as
  /// Atom specifies. The function converts content to plain text.
  /// -> str | content | none
  content: none,
  /// The `type` of the content: `"html"`, `"text"` or a MIME type. The default
  /// is `"html"` for strings and `"text"` for content. -> str | auto
  content-type: auto,
  /// The authors, as strings or `atom.author(..)`. -> array
  authors: (),
  /// The contributors, as strings or `atom.author(..)`. -> array
  contributors: (),
  /// The categories, as strings or dictionaries `(term: .., scheme: .., label: ..)`. -> array
  categories: (),
  /// A copyright statement. -> str | content | none
  rights: none,
  /// More XML nodes. The function adds them at the end of the entry. -> array
  extra: (),
) = {
  let title = _util.to-text(title, field: "title")
  let link = _util.opt-text(link, field: "link")
  if id == auto and link == none {
    panic("entry \"" + title + "\" needs an `id` or a `link`")
  }
  if link == none and content == none {
    panic("entry \"" + title + "\" needs a `link` or `content` (RFC 4287, section 4.1.2)")
  }
  let published = _util.opt-datetime(published, field: "published")
  let updated = if updated == auto { published } else {
    _util.opt-datetime(updated, field: "updated")
  }
  if updated == none {
    panic("entry \"" + title + "\" needs `updated` or `published`")
  }
  let content-type = if content-type != auto { content-type } else if (
    type(content) == _content-type
  ) {
    "text"
  } else { "html" }

  _util.record("atom.entry", (
    title: title,
    id: if id == auto { link } else { _util.to-text(id, field: "id") },
    link: link,
    updated: updated,
    published: published,
    summary: summary,
    content: content,
    content-type: content-type,
    authors: _people(authors, "authors"),
    contributors: _people(contributors, "contributors"),
    categories: _util.flatten(categories).map(_category),
    rights: rights,
    extra: extra,
  ))
}

#let _render-entry(e, tz) = (
  tag: "entry",
  children: (
    (tag: "title", children: (e.title,)),
    if e.link != none { (tag: "link", attrs: (rel: "alternate", type: "text/html", href: e.link)) },
    (tag: "id", children: (e.id,)),
    (tag: "updated", children: (_util.rfc3339(e.updated, tz: tz),)),
    if e.published != none { (tag: "published", children: (_util.rfc3339(e.published, tz: tz),)) },
    e.authors.map(p => _render-person("author", p)),
    e.contributors.map(p => _render-person("contributor", p)),
    e.categories,
    _text("summary", e.summary),
    _text("content", e.content, kind: e.content-type),
    _text("rights", e.rights),
    e.extra,
  ),
)

/// Generates an Atom 1.0 feed.
///
/// ```examplec
/// atom.feed(
///   title: "My Blog",
///   link: "https://example.com/",
///   authors: "Basil",
///   entries: atom.entry(
///     "Hello, world",
///     link: "https://example.com/blog/hello/",
///     published: "2026-07-01",
///   ),
/// )
/// ```
///
/// -> str
#let feed(
  /// The title of the feed. This value is necessary. -> str | content
  title: none,
  /// A subtitle or a description. -> str | content | none
  subtitle: none,
  /// The URL of the website. This value is necessary. -> str
  link: none,
  /// The URL of this feed. Set it if possible. -> str | none
  self-link: none,
  /// A permanent, unique identifier. The default is `link`. -> str | auto
  id: auto,
  /// The date of the last change. The default is the latest `updated` of the entries.
  /// -> datetime | str | auto
  updated: auto,
  /// The authors, as strings or `atom.author(..)`. This value is necessary if an entry
  /// has no authors. -> array | str
  authors: (),
  /// The contributors, as strings or `atom.author(..)`. -> array
  contributors: (),
  /// The categories, as strings or dictionaries `(term: .., scheme: .., label: ..)`. -> array
  categories: (),
  /// A copyright statement. -> str | content | none
  rights: none,
  /// The URL of a small, square icon, for example a favicon. -> str | none
  icon: none,
  /// The URL of a larger logo with an aspect ratio of 2:1. -> str | none
  logo: none,
  /// The software that generated the feed. Use a name or a dictionary
  /// `(name: .., uri: .., version: ..)`. -> str | dictionary | none
  generator: none,
  /// The language of the feed, for example `"en"`. The function writes it as `xml:lang`.
  /// -> str | none
  language: none,
  /// The entries. Make them with `atom.entry(..)`. -> array
  entries: (),
  /// The time zone of all dates. Use `"Z"` for UTC, or an offset, for example `"+01:00"`.
  /// -> str
  tz: "Z",
  /// The URL of an XSL or CSS stylesheet. Browsers apply it to the feed. -> str | none
  stylesheet: none,
  /// More namespace declarations `(prefix: uri)` for the elements in `extra`. -> dictionary
  namespaces: (:),
  /// More XML nodes. The function adds them at the end of the feed. -> array
  extra: (),
  /// If `true`, the function indents the output. -> bool
  pretty: true,
) = {
  if title == none { panic("`title` is required") }
  if link == none { panic("`link` is required") }
  let link = _util.to-text(link, field: "link")
  let entries = _util.flatten(entries).map(e => _util.expect-record(e, "atom.entry", "entries"))
  let authors = _people(authors, "authors")
  if authors.len() == 0 {
    for e in entries {
      if e.authors.len() == 0 {
        panic(
          "entry \""
            + e.title
            + "\" has no author; set `authors` on the feed or on every entry (RFC 4287, section 4.1.1)",
        )
      }
    }
  }
  let updated = if updated == auto {
    let latest = _util.latest(entries.map(e => e.updated))
    if latest == none { panic("cannot infer `updated` from an empty feed; pass `updated`") }
    latest
  } else {
    _util.to-datetime(updated, field: "updated")
  }
  let generator = if type(generator) == dictionary {
    (
      tag: "generator",
      attrs: (
        uri: generator.at("uri", default: none),
        version: generator.at("version", default: none),
      ),
      children: (_util.to-text(generator.name, field: "generator"),),
    )
  } else if generator != none {
    (tag: "generator", children: (_util.to-text(generator, field: "generator"),))
  }

  let root = (
    tag: "feed",
    attrs: (xmlns: _ns, "xml:lang": _util.opt-text(language, field: "language"))
      + _util.xmlns-attrs(namespaces),
    children: (
      _text("title", title),
      _text("subtitle", subtitle),
      (tag: "link", attrs: (rel: "alternate", type: "text/html", href: link)),
      if self-link != none {
        let href = _util.to-text(self-link, field: "self-link")
        (tag: "link", attrs: (rel: "self", type: "application/atom+xml", href: href))
      },
      (tag: "id", children: (if id == auto { link } else { _util.to-text(id, field: "id") },)),
      (tag: "updated", children: (_util.rfc3339(updated, tz: tz),)),
      authors.map(p => _render-person("author", p)),
      _people(contributors, "contributors").map(p => _render-person("contributor", p)),
      _util.flatten(categories).map(_category),
      generator,
      if icon != none { (tag: "icon", children: (_util.to-text(icon, field: "icon"),)) },
      if logo != none { (tag: "logo", children: (_util.to-text(logo, field: "logo"),)) },
      _text("rights", rights),
      extra,
      entries.map(e => _render-entry(e, tz)),
    ),
  )
  _xml.encode((_util.stylesheet-pi(stylesheet), root), pretty: pretty)
}
