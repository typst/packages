# Changelog

## 0.1.0 (2026-11-11)

This is the first release. It needs Typst 0.15 or later.

- `xml.encode` encodes XML in pure Typst. It can encode trees of all depths. It keeps the order
  of attributes. It ignores attributes and children that are `none`, and it flattens nested
  arrays of children.
- `xml.element`, `xml.comment`, `xml.cdata`, `xml.pi`, `xml.raw` and `xml.escape` make nodes.
- `xml.decode` uses the XML reader of Typst. It accepts strings, bytes and `path(..)` values. It
  removes the placeholders that the reader makes for comments. `xml.encode` can encode its
  output again, also with namespaces.
- `atom.feed`, `atom.entry`, `atom.author` and `atom.tag-uri` generate Atom 1.0 feeds.
- `rss.feed`, `rss.item` and `rss.enclosure` generate RSS 2.0 feeds. They declare the `atom`,
  `content` and `dc` namespaces automatically.
- `sitemap.urlset` and `sitemap.url` generate sitemaps with `hreflang` alternates.
  `sitemap.index` generates sitemap indexes.
- `rfc3339` and `rfc2822` format dates. A date can be a `datetime` value or an ISO 8601 string.
  You set the time zone one time for each document with `tz`.
- Text fields accept simple Typst content. The functions convert it to plain text. If an
  element has no plain-text form, the functions stop with an error. They do not remove it
  without a message.
- The options `stylesheet`, `namespaces` and `extra` add data to documents.
- The functions examine their input and give clear errors. They examine XML names, prohibited
  characters, comment syntax, the authors of Atom feeds, the limits of sitemaps and more.
- The manual contains a guide and a full reference: [docs/manual.pdf](docs/manual.pdf).
