# syndicate

syndicate generates **Atom feeds**, **RSS feeds** and **sitemaps** for websites that you make
with Typst. It also encodes Typst values to **XML**. It is written in pure Typst and does not use
plugins.

The [manual](docs/manual.pdf) contains a guide and a full reference.

## Quick start

Keep the data of your posts in one location. Then generate all formats from this data:

```typ
#import "@preview/syndicate:0.1.0": atom, rss, sitemap

#let site = "https://example.com/"
#let posts = (
  (title: "Hello, world", slug: "hello", date: "2026-07-01", summary: [My _first_ post]),
  (title: "Second post", slug: "second", date: "2026-07-14T09:30", summary: "More things"),
)
#let url(post) = site + "blog/" + post.slug + "/"

#let feed = atom.feed(
  title: "My Blog",
  link: site,
  self-link: site + "feed.xml",
  authors: "Basil",
  entries: posts.map(p => atom.entry(p.title, link: url(p), published: p.date, summary: p.summary)),
)

#let rss-feed = rss.feed(
  title: "My Blog",
  link: site,
  description: "Things I write",
  self-link: site + "rss.xml",
  items: posts.map(p => rss.item(p.title, link: url(p), published: p.date, description: p.summary)),
)

#let map = sitemap.urlset(site, posts.map(p => sitemap.url(url(p), lastmod: p.date)))
```

Each document function returns the complete XML as a string. The Atom feed above starts with
these lines:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>My Blog</title>
  <link rel="alternate" type="text/html" href="https://example.com/"/>
  <link rel="self" type="application/atom+xml" href="https://example.com/feed.xml"/>
  <id>https://example.com/</id>
  <updated>2026-07-14T09:30:00Z</updated>
  <author>
    <name>Basil</name>
  </author>
  <entry>
    <title>Hello, world</title>
    ...
```

## Write the files

**Bundle export** is the experimental output format of Typst 0.15 for more than one file. With
bundle export, Typst writes the XML files together with your HTML pages:

```typ
#asset("feed.xml", feed)
#asset("rss.xml", rss-feed)
#asset("sitemap.xml", map)
```

```sh
typst compile --features bundle --format bundle blog.typ site/
```

**With `typst eval`**, put the string into `#metadata(feed) <feed>`. Then get it with
`typst eval`. The output of `eval` is JSON. Thus, use `jq` to get the string from the JSON:

```sh
typst eval --in blog.typ 'query(<feed>).first().value' | jq -j . > feed.xml
```

## Overview

```typ
#import "@preview/syndicate:0.1.0": xml, atom, rss, sitemap, rfc3339, rfc2822
```

| Definition | Description |
| --- | --- |
| `atom.feed(..)` | An Atom 1.0 feed (RFC 4287). |
| `atom.entry(title, ..)` | An entry of an Atom feed. |
| `atom.author(name, ..)` | A person, with an optional email and URI. You can also use a string. |
| `atom.tag-uri(authority, date, specific)` | A permanent `tag:` URI (RFC 4151) for identifiers. |
| `rss.feed(..)` | An RSS 2.0 feed. |
| `rss.item(title, ..)` | An item of an RSS feed. |
| `rss.enclosure(url, length: .., type: ..)` | A media attachment, for example a podcast episode. |
| `sitemap.urlset(..urls)` | A sitemap. |
| `sitemap.url(loc, ..)` | A page of a sitemap, with `lastmod`, `changefreq`, `priority` and translations. |
| `sitemap.index(..sitemaps)` | A sitemap index, which lists more than one sitemap. |
| `xml.encode(root, ..)` | Serializes a tree of nodes to XML. |
| `xml.decode(source)` | Parses XML from a string, bytes or `path(..)` into a tree of nodes. |
| `xml.element(tag, ..)` | An element node. You can use it instead of a dictionary. |
| `xml.comment(body)` | A comment node. |
| `xml.cdata(body)` | A CDATA section. |
| `xml.pi(target, data)` | A processing instruction. |
| `xml.raw(body)` | Markup that is already serialized. `xml.encode` does not change it. |
| `xml.escape(text)` | Escapes text for XML. |
| `rfc3339(dt, tz: ..)` | Formats a date for Atom feeds and sitemaps. |
| `rfc2822(dt, tz: ..)` | Formats a date for RSS feeds. |

These rules apply to all functions:

- **Text** is a string or simple markup, for example `[My _first_ post]`. The functions convert
  markup to plain text. If markup has no plain-text form, for example an equation, the functions
  stop with an error. They do not remove it without a message.
- **Dates** are `datetime` values or ISO 8601 strings, for example `"2026-07-01"` or
  `"2026-07-01T14:30"`.
- **Time zones** apply to a full document. Set them with `tz`, for example `tz: "+01:00"`. The
  default is UTC.
- **Extensions** use the options `namespaces` and `extra` of documents and entries. With
  `stylesheet`, browsers show a page with styles, not the XML source.

## XML

An element is a dictionary with a `tag` and optional `attrs` and `children`. The `xml()` reader
of Typst returns the same structure. `xml.encode` escapes text automatically and keeps the order
of attributes. It ignores attributes and children that are `none`.

```typ
#import "@preview/syndicate:0.1.0": xml

#xml.encode(
  (
    tag: "book",
    attrs: (id: "bk101", lang: none),
    children: (
      (tag: "title", children: ("XML & Typst",)),
      (tag: "price", children: (44.95,)),
    ),
  ),
  pretty: true,
)
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<book id="bk101">
  <title>XML &amp; Typst</title>
  <price>44.95</price>
</book>
```

`xml.decode` reads XML into the same structure. Thus, you can change a document and encode it
again. When you import `xml`, it hides the `xml()` reader of Typst. To use the reader, write
`std.xml`.

## License

[MIT](LICENSE). The idea for syndicate came from [exemel](https://github.com/wensimehrp/exemel) by Jeremy Gao.
