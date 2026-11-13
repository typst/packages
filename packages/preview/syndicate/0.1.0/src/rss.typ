// Functions that generate RSS 2.0 feeds (https://www.rssboard.org/rss-specification).

#import "util.typ" as _util
#import "xml.typ" as _xml

#let _ns = (
  atom: "http://www.w3.org/2005/Atom",
  content: "http://purl.org/rss/1.0/modules/content/",
  dc: "http://purl.org/dc/elements/1.1/",
)

#let _text(tag, value) = if value != none {
  (tag: tag, children: (_util.to-text(value, field: tag),))
}

/// Describes a media attachment for `rss.item(enclosure: ..)`, for example a
/// podcast episode. All three values are necessary.
///
/// ```typc
/// rss.enclosure(
///   "https://example.com/episode-1.mp3",
///   length: 24986239,
///   type: "audio/mpeg",
/// )
/// ```
///
/// -> dictionary
#let enclosure(
  /// The URL of the file. -> str
  url,
  /// The size of the file in bytes. -> int
  length: none,
  /// The MIME type, for example `"audio/mpeg"`. -> str
  type: none,
) = {
  if length == none or type == none {
    panic("`rss.enclosure` needs `url`, `length` (in bytes) and `type` (MIME type)")
  }
  if std.type(length) != int or length < 0 {
    panic("enclosure `length` must be a non-negative integer number of bytes")
  }
  _util.record("rss.enclosure", (
    url: _util.to-text(url, field: "url"),
    length: length,
    type: _util.to-text(type, field: "type"),
  ))
}

// RSS uses the format `email (Name)` in <author>. If there is no email, the function
// writes the name in <dc:creator>.
#let _author(a) = {
  if a == none { return none }
  if type(a) != dictionary {
    let s = _util.to-text(a, field: "author")
    return (tag: if s.contains("@") { "author" } else { "dc:creator" }, children: (s,))
  }
  if "name" not in a and "email" not in a {
    panic("`author` dictionaries need a `name` and/or an `email`, found " + repr(a))
  }
  let name = _util.opt-text(a.at("name", default: none), field: "name")
  let email = _util.opt-text(a.at("email", default: none), field: "email")
  if email == none {
    (tag: "dc:creator", children: (name,))
  } else {
    (tag: "author", children: (if name == none { email } else { email + " (" + name + ")" },))
  }
}

#let _category(c) = {
  if type(c) != dictionary {
    return (tag: "category", children: (_util.to-text(c, field: "category"),))
  }
  if "name" not in c { panic("category dictionaries need a `name`, found " + repr(c)) }
  (
    tag: "category",
    attrs: (domain: _util.opt-text(c.at("domain", default: none), field: "domain")),
    children: (_util.to-text(c.name, field: "category"),),
  )
}

/// Describes an item for `rss.feed(items: ..)`.
///
/// ```typc
/// rss.item(
///   "Hello, world",
///   link: "https://example.com/blog/hello/",
///   published: "2026-07-01",
///   description: [My _first_ post],
/// )
/// ```
///
/// -> dictionary
#let item(
  /// The title. It can be `none` if there is a `description`. -> str | content | none
  title,
  /// The URL of the web page of the item. -> str | none
  link: none,
  /// A unique identifier. The default is `link`. -> str | auto | none
  guid: auto,
  /// If `true`, `guid` is a URL of the item. The default is `true` for
  /// identifiers that start with `http://` or `https://`. -> bool | auto
  permalink: auto,
  /// The date of publication. -> datetime | str | none
  published: none,
  /// A summary or the full text. It can contain HTML source. The function escapes it.
  /// -> str | content | none
  description: none,
  /// The full content as HTML source. The function writes it as `<content:encoded>`.
  /// -> str | none
  content: none,
  /// The author, as a dictionary `(name: .., email: ..)`, an `atom.author(..)`
  /// or a string. If the author has an email, the function writes `<author>`.
  /// If not, it writes the name as `<dc:creator>`. -> dictionary | str | none
  author: none,
  /// The categories, as strings or dictionaries `(name: .., domain: ..)`. -> array
  categories: (),
  /// The URL of the comments on the item. -> str | none
  comments: none,
  /// A media attachment. Make it with `rss.enclosure(..)`. -> dictionary | none
  enclosure: none,
  /// More XML nodes. The function adds them at the end of the item. -> array
  extra: (),
) = {
  if title == none and description == none {
    panic("an RSS item needs a `title` or a `description`")
  }
  let link = _util.opt-text(link, field: "link")
  let guid = if guid == auto { link } else { _util.opt-text(guid, field: "guid") }
  let permalink = if permalink != auto { permalink } else {
    guid != none and (guid.starts-with("http://") or guid.starts-with("https://"))
  }
  if enclosure != none {
    _util.expect-record(enclosure, "rss.enclosure", "enclosure")
  }
  _util.record("rss.item", (
    title: _util.opt-text(title, field: "title"),
    link: link,
    guid: guid,
    permalink: permalink,
    published: _util.opt-datetime(published, field: "published"),
    description: _util.opt-text(description, field: "description"),
    content: _util.opt-text(content, field: "content"),
    author: _author(author),
    categories: _util.flatten(categories).map(_category),
    comments: _util.opt-text(comments, field: "comments"),
    enclosure: enclosure,
    extra: extra,
  ))
}

#let _render-item(i, tz) = (
  tag: "item",
  children: (
    _text("title", i.title),
    _text("link", i.link),
    _text("description", i.description),
    if i.content != none { (tag: "content:encoded", children: (i.content,)) },
    i.author,
    i.categories,
    _text("comments", i.comments),
    if i.enclosure != none {
      let e = i.enclosure
      (tag: "enclosure", attrs: (url: e.url, length: e.length, type: e.type))
    },
    if i.guid != none { (tag: "guid", attrs: (isPermaLink: i.permalink), children: (i.guid,)) },
    if i.published != none { (tag: "pubDate", children: (_util.rfc2822(i.published, tz: tz),)) },
    i.extra,
  ),
)

// Returns `true` if an element in the tree uses the namespace prefix.
#let _uses(tree, prefix) = {
  if type(tree) == array { return tree.any(t => _uses(t, prefix)) }
  if type(tree) != dictionary or "tag" not in tree { return false }
  str(tree.tag).starts-with(prefix + ":") or _uses(tree.at("children", default: ()), prefix)
}

/// Generates an RSS 2.0 feed. If the feed uses the `atom`, `content` or `dc`
/// namespace, the function declares it automatically.
///
/// ```examplec
/// rss.feed(
///   title: "My Blog",
///   link: "https://example.com/",
///   description: "Things I write",
///   items: rss.item(
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
  /// The URL of the website. This value is necessary. -> str
  link: none,
  /// A description of the feed. This value is necessary. -> str | content
  description: none,
  /// The URL of this feed. The function writes it as `<atom:link rel="self">`.
  /// Set it if possible. -> str | none
  self-link: none,
  /// The language of the feed, for example `"en-us"`. -> str | none
  language: none,
  /// A copyright statement. -> str | content | none
  copyright: none,
  /// The email address of the editor. -> str | none
  managing-editor: none,
  /// The email address of the person who operates the website. -> str | none
  web-master: none,
  /// The date of publication of the feed content. -> datetime | str | none
  published: none,
  /// The date of the last change (`<lastBuildDate>`). The default is the latest
  /// `published` of the items. If `none`, the function does not write it.
  /// -> datetime | str | auto | none
  updated: auto,
  /// The categories, as strings or dictionaries `(name: .., domain: ..)`. -> array
  categories: (),
  /// The software that generated the feed. -> str | none
  generator: none,
  /// The URL of the RSS specification. -> str | none
  docs: none,
  /// The maximum time in minutes that a reader can keep the feed in a cache. -> int | none
  ttl: none,
  /// An image, as a URL or a dictionary
  /// `(url: .., title: .., link: .., width: .., height: ..)`. The default `title`
  /// and `link` are those of the feed. -> str | dictionary | none
  image: none,
  /// The items. Make them with `rss.item(..)`. -> array
  items: (),
  /// The time zone of all dates. Use `"Z"` for UTC, or an offset, for example `"+01:00"`.
  /// -> str
  tz: "Z",
  /// The URL of an XSL or CSS stylesheet. Browsers apply it to the feed. -> str | none
  stylesheet: none,
  /// More namespace declarations `(prefix: uri)` for the elements in `extra`. -> dictionary
  namespaces: (:),
  /// More XML nodes. The function adds them at the end of the channel. -> array
  extra: (),
  /// If `true`, the function indents the output. -> bool
  pretty: true,
) = {
  if title == none { panic("`title` is required") }
  if link == none { panic("`link` is required") }
  if description == none { panic("`description` is required") }
  let title = _util.to-text(title, field: "title")
  let link = _util.to-text(link, field: "link")
  let items = _util.flatten(items).map(i => _util.expect-record(i, "rss.item", "items"))
  let updated = if updated == auto {
    _util.latest(items.map(i => i.published))
  } else {
    _util.opt-datetime(updated, field: "updated")
  }
  let image = if image != none {
    let image = if type(image) == dictionary { image } else { (url: image) }
    (
      tag: "image",
      children: (
        _text("url", image.url),
        _text("title", image.at("title", default: title)),
        _text("link", image.at("link", default: link)),
        _text("width", image.at("width", default: none)),
        _text("height", image.at("height", default: none)),
      ),
    )
  }
  let channel = (
    tag: "channel",
    children: (
      (tag: "title", children: (title,)),
      (tag: "link", children: (link,)),
      _text("description", description),
      if self-link != none {
        let href = _util.to-text(self-link, field: "self-link")
        (tag: "atom:link", attrs: (href: href, rel: "self", type: "application/rss+xml"))
      },
      _text("language", language),
      _text("copyright", copyright),
      _text("managingEditor", managing-editor),
      _text("webMaster", web-master),
      if published != none { (tag: "pubDate", children: (_util.rfc2822(published, tz: tz),)) },
      if updated != none { (tag: "lastBuildDate", children: (_util.rfc2822(updated, tz: tz),)) },
      _util.flatten(categories).map(_category),
      _text("generator", generator),
      _text("docs", docs),
      _text("ttl", ttl),
      image,
      extra,
      items.map(i => _render-item(i, tz)),
    ),
  )
  let used = (:)
  for (prefix, uri) in _ns {
    if _uses(channel, prefix) { used.insert(prefix, uri) }
  }
  let root = (
    tag: "rss",
    attrs: (version: "2.0") + _util.xmlns-attrs(used) + _util.xmlns-attrs(namespaces),
    children: (channel,),
  )
  _xml.encode((_util.stylesheet-pi(stylesheet), root), pretty: pretty)
}
