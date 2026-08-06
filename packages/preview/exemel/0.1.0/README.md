# Exemel
Encodes Typst values to XML. This package also provides built-in support for generating Atom feeds.

## Encoding XML
You should structure your Typst values as follows:
```typ
#import "@preview/exemel:0.1.0": to-xml

// An XML node is either:
// - a dictionary describing an element, or
// - a plain string, which becomes a text node

#let value = (
  tag: "bookstore",
  // `namespace` is optional and defaults to `none`
  namespace: none,
  // `attrs` is optional and defaults to an empty dictionary
  attrs: (:),
  // `children` is optional and defaults to no children
  children: (
    (
      tag: "book",
      attrs: (id: "bk101", category: "programming"),
      children: (
        (tag: "title", attrs: (lang: "en"), children: ("XML Developer's Guide",)),
        (tag: "author", children: ("Gambardella, Matthew",)),
        (tag: "year", children: ("2000",)),
        (tag: "price", children: ("44.95",)),
      ),
    ),
  ),
)

#to-xml(value, pretty: true)
```

Notes on the shape:
- `tag` is required on every element; `attrs` and `children` may be omitted and default to empty.
- `attrs` is a dictionary of string keys to string values.
- `children` is an array whose entries are either nested element dictionaries or plain strings (text content). An element can't currently have both mixed markup *and* be namespace-prefixed. Typst's own `xml()` reader doesn't preserve namespace prefixes either, so round-tripping a parsed document through `xml()` and back through `to-xml` will lose any `foo:bar`-style prefixes.
- Passing `pretty: true` indents the output with two spaces per level. the default, `pretty: false`, produces compact output with no added whitespace.
- `to-xml` also accepts an array of top-level values, in which case it returns one XML string per value.

## Generating Atom Feed
```typ
#import "@preview/exemel:0.1.0": atom-encode, atom-post, atom-author, atom-site-id

#let me = atom-author(
  "Hachimi",
  email: "Namerudo@example.com",
  uri: "https://example.com/ashiga",
)

#let posts = (
  atom-post(
    "Hayaku",
    link: "https://example.com/blog/hayaku-naro",
    id: atom-site-id(
      authority: "example.com",
      time: datetime(year: 2026, month: 7, day: 1),
      identifier: "blog/typst-xml-plugin",
    ),
    updated: datetime(year: 2026, month: 7, day: 3, hour: 14, minute: 30, second: 0),
    published: datetime(year: 2026, month: 7, day: 1, hour: 9, minute: 0, second: 0),
    summary: "Hachimi hachimi hachimi hachimi hachimi hachimi o namerudo",
    content: "Ashiga ashiga ashiga ashiga ashiga hayaku naro",
    authors: (me,),
    categories: ("umamusume", "clannad", "baka futari"),
  ),
)

#atom-encode(
  title: "Honey Drink",
  subtitle: "Hachimi, hachimi, and hachimi",
  site-link: "https://example.com/",
  id: atom-site-id(
    authority: "example.com",
    time: datetime(year: 2026, month: 1, day: 1),
  ),
  updated: datetime(year: 2026, month: 7, day: 3, hour: 14, minute: 30, second: 0),
  authors: (me,),
  posts: posts,
)
```

`atom-encode` builds the `<feed>` root, and accepts:
- `title` (required), `subtitle` (optional)
- `site-link` (required): the human-readable site URL
- `feed-link`: the URL of the feed itself; defaults to `site-link + "feed.xml"`
- `id` (required): a stable, unique feed identifier; `atom-site-id` is a helper for building spec-compliant `tag:` URIs (RFC 4151) from a domain you control
- `updated` (required `datetime`): when the feed was last modified
- `authors`: an array built from `atom-author(...)` calls
- `posts`: an array built from `atom-post(...)` calls

`atom-post` builds a single `<entry>`, and accepts:
- the entry title (positional, required)
- `link` (required): URL of the human-readable post
- `id` (required): unique entry identifier, same convention as the feed `id`
- `updated` (required `datetime`), `published` (optional `datetime`)
- `summary`, `content`: both optional; `content-type` (default `"html"`) is written as the `content` element's `type` attribute
- `authors`: optional per-entry authors; if omitted, readers fall back to the feed-level authors per the Atom spec
- `categories`: an array of plain category strings, each rendered as `<category term="...">`

`atom-author` builds an `<author>` element from a name plus optional `email` and `uri`, and is used for both the feed-level and per-entry `authors` arrays.
