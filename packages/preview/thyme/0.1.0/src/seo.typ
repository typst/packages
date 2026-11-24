// XML sitemap (`sitemap.xml`), `robots.txt`, Atom 1.0 (`atom.xml`), RSS 2.0 (`rss.xml`)
// builders (summary or full semantic HTML), plus opt-in OpenGraph & Google Scholar
// Highwire `<meta>` helpers, backed by `@preview/syndicate`.

#import "@preview/syndicate:0.1.0": atom, rss, sitemap
#import "i18n.typ": normalize-alternates
#import "paths.typ": canonical-page-url, date-sort-key, format-date, url-authority
#import "text.typ": to-plain-text

#let _default-epoch = datetime(
  year: 2026,
  month: 1,
  day: 1,
  hour: 0,
  minute: 0,
  second: 0,
)

#let _plain-or-none(v, lang: none) = if v == none { none } else {
  to-plain-text(v, lang: lang)
}

#let _escape-html(s) = {
  str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;")
}

#let _entry-summary(p, lang: none) = {
  let s = p.at("summary", default: none)
  let sub = p.at("subtitle", default: none)
  let desc = p.at("description", default: none)
  let raw-val = if s != none { s } else if desc != none { desc } else if (
    sub != none
  ) { sub } else { none }
  _plain-or-none(raw-val, lang: lang)
}

#let _entry-lastmod(p) = {
  let mod = p.at("modified", default: none)
  let cre = p.at("created", default: none)
  if mod != none { mod } else { cre }
}

#let _latest-lastmod(entries) = {
  let dated = entries.filter(e => _entry-lastmod(e) != none)
  if dated.len() > 0 {
    _entry-lastmod(
      dated.sorted(key: e => date-sort-key(_entry-lastmod(e))).last(),
    )
  } else {
    none
  }
}

// `normalize-alternates` returns `(hreflang: .., href: ..)` records. `syndicate`
// wants a `(hreflang: url)` dictionary, so collapse them here.
#let _alternates-dict(records) = records.fold(
  (:),
  (acc, r) => acc + ((r.hreflang, r.href),).to-dict(),
)

#let _resolve-feed-url(dest-str, site-url, doc-path) = {
  let s = str(dest-str).trim()
  if (
    s.starts-with("http://") or s.starts-with("https://") or s.starts-with("mailto:") or s.starts-with("#")
  ) {
    s
  } else if site-url == none {
    s
  } else if s.starts-with("/") {
    str(site-url).trim("/", at: end) + s
  } else {
    canonical-page-url(site-url, doc-path) + s
  }
}

#let _resolve-label-feed-url(lbl-str, site-url, label-urls) = {
  if lbl-str in label-urls {
    label-urls.at(lbl-str)
  } else if site-url != none {
    str(site-url).trim("/", at: end) + "/posts/" + lbl-str + "/"
  } else {
    "#"
  }
}

#let _join-strs(arr, sep: "") = if arr.len() > 0 { arr.join(sep) } else { "" }

// Render a Typst `table` element into clean `<table><thead><tbody><tr><th><td>` feed HTML.
#let _table-to-feed-html(tbl, render-cell) = {
  let cols-spec = tbl.at("columns", default: ())
  let ncols = if type(cols-spec) == int {
    calc.max(1, cols-spec)
  } else if type(cols-spec) == array {
    calc.max(1, cols-spec.len())
  } else {
    1
  }

  let render-rows(cells, cell-tag) = {
    let rows = ()
    let cur = ()
    for c in cells {
      let fn = c.func()
      if fn == table.hline or fn == table.vline {
        continue
      }
      let body = if fn == table.cell { c.body } else { c }
      cur.push(
        "<" + cell-tag + ">" + render-cell(body).trim() + "</" + cell-tag + ">",
      )
      if cur.len() >= ncols {
        rows.push("<tr>" + _join-strs(cur) + "</tr>")
        cur = ()
      }
    }
    if cur.len() > 0 {
      rows.push("<tr>" + _join-strs(cur) + "</tr>")
    }
    _join-strs(rows)
  }

  let head-html = ""
  let body-cells = ()
  for ch in tbl.children {
    let fn = ch.func()
    if fn == table.header {
      head-html += render-rows(ch.children, "th")
    } else if fn == table.footer {
      body-cells += ch.children
    } else if fn != table.hline and fn != table.vline {
      body-cells.push(ch)
    }
  }
  let body-html = render-rows(body-cells, "td")
  (
    "<table>"
      + (if head-html != "" { "<thead>" + head-html + "</thead>" } else { "" })
      + (if body-html != "" { "<tbody>" + body-html + "</tbody>" } else { "" })
      + "</table>"
  )
}

/// Serialize a Typst `content` AST into clean, reader-friendly semantic HTML
/// for full-content Atom (`<content type="html">`) and RSS 2.0 (`<content:encoded>`) feeds.
/// -> str
#let content-to-feed-html(
  /// Typst `content` body to serialize.
  /// -> any
  node,
  /// Canonical site origin URL used to resolve relative links.
  /// -> str | none
  site-url: none,
  /// Document bundle path (e.g. `"posts/foo/index.html"`).
  /// -> str | none
  doc-path: none,
  /// Preferred language code when flattening `#tr(...)` nodes.
  /// -> str | none
  lang: none,
  /// Optional map of bundle `<label>` names (`"about"`, `"rss"`, `"fixed-points"`) to canonical URLs.
  /// -> dictionary
  label-urls: (:),
) = {
  let recurse(sub) = content-to-feed-html(
    sub,
    site-url: site-url,
    doc-path: doc-path,
    lang: lang,
    label-urls: label-urls,
  )
  let go-inline(n) = {
    if n == none {
      ""
    } else if type(n) == str {
      _escape-html(n)
    } else if type(n) != content {
      _escape-html(str(n))
    } else {
      let fn = n.func()
      if n == [ ] or fn == [ ].func() {
        " "
      } else if fn == linebreak {
        "<br>"
      } else if fn == parbreak {
        "\n\n"
      } else if fn == smartquote {
        if n.at("double", default: true) { "&quot;" } else { "’" }
      } else if fn == metadata {
        if type(n.value) == dictionary {
          if n.value.at("thyme-tr", default: false) {
            let entries = n.value.at("entries", default: (:))
            let b = if lang != none and lang in entries {
              entries.at(lang)
            } else if entries.len() > 0 {
              entries.values().first()
            } else {
              none
            }
            if b != none { go-inline(b) } else { "" }
          } else if n.value.at("thyme-feed-node", default: false) {
            let kind = n.value.at("kind", default: "")
            if kind == "sidenote" {
              " <small>(" + go-inline(n.value.body) + ")</small>"
            } else {
              recurse(n.value.body)
            }
          } else {
            ""
          }
        } else {
          ""
        }
      } else if fn == strong {
        "<strong>" + go-inline(n.body) + "</strong>"
      } else if fn == emph {
        "<em>" + go-inline(n.body) + "</em>"
      } else if fn == super {
        "<sup>" + go-inline(n.body) + "</sup>"
      } else if fn == sub {
        "<sub>" + go-inline(n.body) + "</sub>"
      } else if fn == raw {
        if n.at("block", default: false) {
          let cls = if n.has("lang") and n.lang != none {
            " class=\"language-" + _escape-html(n.lang) + "\""
          } else { "" }
          "<pre><code" + cls + ">" + _escape-html(n.text) + "</code></pre>"
        } else {
          "<code>" + _escape-html(n.text) + "</code>"
        }
      } else if fn == link {
        let href = if type(n.dest) == str {
          _resolve-feed-url(n.dest, site-url, doc-path)
        } else if type(n.dest) == label {
          _resolve-label-feed-url(str(n.dest), site-url, label-urls)
        } else {
          "#"
        }
        "<a href=\"" + _escape-html(href) + "\">" + go-inline(n.body) + "</a>"
      } else if fn == ref {
        let tgt-str = str(n.target)
        let txt = if n.supplement != auto and n.supplement != none {
          go-inline(n.supplement)
        } else {
          _escape-html(tgt-str.replace("-", " "))
        }
        if site-url != none or tgt-str in label-urls {
          (
            "<a href=\""
              + _escape-html(_resolve-label-feed-url(
                tgt-str,
                site-url,
                label-urls,
              ))
              + "\">"
              + txt
              + "</a>"
          )
        } else {
          txt
        }
      } else if fn == cite {
        "[" + _escape-html(str(n.key)) + "]"
      } else if fn == footnote {
        " <small>(" + go-inline(n.body) + ")</small>"
      } else if fn == table {
        _table-to-feed-html(n, go-inline)
      } else if fn == math.equation {
        let mtxt = _escape-html(to-plain-text(n, lang: lang).trim())
        if n.at("block", default: false) {
          "<p><code>" + mtxt + "</code></p>"
        } else {
          "<code>" + mtxt + "</code>"
        }
      } else if n.has("text") and type(n.text) == str {
        _escape-html(n.text)
      } else if n.has("children") {
        _join-strs(n.children.map(go-inline))
      } else if n.has("body") {
        go-inline(n.body)
      } else if n.has("child") {
        go-inline(n.child)
      } else {
        _escape-html(to-plain-text(n, lang: lang))
      }
    }
  }

  if node == none {
    return ""
  }
  if type(node) != content {
    let s = _escape-html(str(node)).trim()
    return if s != "" { "<p>" + s + "</p>" } else { "" }
  }

  let flatten-seq(el) = {
    if el.func() == [].func() and el.has("children") {
      let acc = ()
      for c in el.children {
        acc += flatten-seq(c)
      }
      acc
    } else {
      (el,)
    }
  }

  let children = flatten-seq(node)

  let out = ()
  let para-buf = ()
  let list-tag = none
  let list-items = ()

  for ch in children {
    let fn = ch.func()
    if fn == parbreak {
      if list-tag != none and list-items.len() > 0 {
        out.push(
          "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
        )
      }
      list-tag = none
      list-items = ()
      let txt = _join-strs(para-buf).trim()
      if txt != "" { out.push("<p>" + txt + "</p>") }
      para-buf = ()
    } else if fn == heading {
      if list-tag != none and list-items.len() > 0 {
        out.push(
          "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
        )
      }
      list-tag = none
      list-items = ()
      let txt = _join-strs(para-buf).trim()
      if txt != "" { out.push("<p>" + txt + "</p>") }
      para-buf = ()
      let lvl = calc.min(6, ch.at("depth", default: 1) + 1)
      out.push(
        "<h" + str(lvl) + ">" + go-inline(ch.body) + "</h" + str(lvl) + ">",
      )
    } else if fn == list.item {
      let txt = _join-strs(para-buf).trim()
      if txt != "" { out.push("<p>" + txt + "</p>") }
      para-buf = ()
      if list-tag != "ul" {
        if list-tag != none and list-items.len() > 0 {
          out.push(
            "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
          )
        }
        list-tag = "ul"
        list-items = ()
      }
      list-items.push("<li>" + go-inline(ch.body).trim() + "</li>")
    } else if fn == enum.item {
      let txt = _join-strs(para-buf).trim()
      if txt != "" { out.push("<p>" + txt + "</p>") }
      para-buf = ()
      if list-tag != "ol" {
        if list-tag != none and list-items.len() > 0 {
          out.push(
            "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
          )
        }
        list-tag = "ol"
        list-items = ()
      }
      list-items.push("<li>" + go-inline(ch.body).trim() + "</li>")
    } else if fn == table {
      if list-tag != none and list-items.len() > 0 {
        out.push(
          "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
        )
      }
      list-tag = none
      list-items = ()
      let txt = _join-strs(para-buf).trim()
      if txt != "" { out.push("<p>" + txt + "</p>") }
      para-buf = ()
      out.push(_table-to-feed-html(ch, go-inline))
    } else if fn == raw and ch.at("block", default: false) {
      if list-tag != none and list-items.len() > 0 {
        out.push(
          "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
        )
      }
      list-tag = none
      list-items = ()
      let txt = _join-strs(para-buf).trim()
      if txt != "" { out.push("<p>" + txt + "</p>") }
      para-buf = ()
      out.push(go-inline(ch))
    } else if fn == quote and ch.at("block", default: false) {
      if list-tag != none and list-items.len() > 0 {
        out.push(
          "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
        )
      }
      list-tag = none
      list-items = ()
      let txt = _join-strs(para-buf).trim()
      if txt != "" { out.push("<p>" + txt + "</p>") }
      para-buf = ()
      let attr = if ch.at("attribution", default: none) != none {
        "<p><small>— " + go-inline(ch.attribution) + "</small></p>"
      } else {
        ""
      }
      out.push("<blockquote>" + recurse(ch.body) + attr + "</blockquote>")
    } else if fn == math.equation and ch.at("block", default: false) {
      if list-tag != none and list-items.len() > 0 {
        out.push(
          "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
        )
      }
      list-tag = none
      list-items = ()
      let txt = _join-strs(para-buf).trim()
      if txt != "" { out.push("<p>" + txt + "</p>") }
      para-buf = ()
      out.push(go-inline(ch))
    } else if (
      fn == metadata and type(ch.value) == dictionary and ch.value.at("thyme-feed-node", default: false)
    ) {
      let k = ch.value.at("kind", default: "")
      if k == "sidenote" {
        para-buf.push(go-inline(ch))
      } else {
        if list-tag != none and list-items.len() > 0 {
          out.push(
            "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
          )
        }
        list-tag = none
        list-items = ()
        let txt = _join-strs(para-buf).trim()
        if txt != "" { out.push("<p>" + txt + "</p>") }
        para-buf = ()
        if k == "code" {
          out.push(go-inline(ch.value.body))
        } else if k == "epigraph" {
          let src = if ch.value.at("title", default: none) != none {
            "<p><small>— " + go-inline(ch.value.title) + "</small></p>"
          } else {
            ""
          }
          out.push(
            "<blockquote>" + recurse(ch.value.body) + src + "</blockquote>",
          )
        } else if k in ("sbox", "proof", "callout") {
          let label = ch.value.at("label", default: none)
          let title = ch.value.at("title", default: none)
          let head-parts = ()
          if label != none {
            head-parts.push(
              "<strong>" + _escape-html(str(label)) + ".</strong>",
            )
          }
          if title != none {
            head-parts.push("<em>" + go-inline(title) + "</em>")
          }
          let head-html = if head-parts.len() > 0 {
            "<p>" + _join-strs(head-parts, sep: " ") + "</p>"
          } else { "" }
          let qed = if k == "proof" { "<p>◻</p>" } else { "" }
          out.push(
            "<blockquote>" + head-html + recurse(ch.value.body) + qed + "</blockquote>",
          )
        } else {
          out.push(recurse(ch.value.body))
        }
      }
    } else if fn == metadata or repr(fn) == "context" {
      if (
        fn == metadata and type(ch.value) == dictionary and ch.value.at("thyme-tr", default: false)
      ) {
        para-buf.push(go-inline(ch))
      }
    } else if fn == par or fn == block {
      if list-tag != none and list-items.len() > 0 {
        out.push(
          "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
        )
      }
      list-tag = none
      list-items = ()
      let txt = _join-strs(para-buf).trim()
      if txt != "" { out.push("<p>" + txt + "</p>") }
      para-buf = ()
      out.push(recurse(ch.body))
    } else if list-tag != none and (ch == [ ] or fn == [ ].func()) {
      // Preserve active `<ul>` / `<ol>` across inter-item newline spaces
    } else {
      if list-tag != none and list-items.len() > 0 {
        out.push(
          "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
        )
      }
      list-tag = none
      list-items = ()
      para-buf.push(go-inline(ch))
    }
  }

  if list-tag != none and list-items.len() > 0 {
    out.push(
      "<" + list-tag + ">" + _join-strs(list-items) + "</" + list-tag + ">",
    )
  }
  let txt = _join-strs(para-buf).trim()
  if txt != "" { out.push("<p>" + txt + "</p>") }
  _join-strs(out, sep: "\n")
}

/// Emit opt-in OpenGraph (`og:*`, `article:*`) and Google Scholar Highwire Press
/// (`citation_*`) `<meta>` tags inside `<head>`.
/// -> content
#let render-seo-meta(
  title: none,
  site-title: none,
  description: none,
  author: none,
  canonical-url: none,
  created: none,
  modified: none,
  monograph: none,
  tags: (),
  is-article: false,
  lang: "en",
  open-graph: false,
  scholar-meta: false,
) = {
  let title-str = _plain-or-none(title, lang: lang)
  let site-str = _plain-or-none(site-title, lang: lang)
  let desc-str = _plain-or-none(description, lang: lang)
  let author-str = _plain-or-none(author, lang: lang)
  let created-iso = format-date(created)
  let modified-iso = format-date(modified)

  if open-graph {
    if title-str != none {
      html.elem("meta", attrs: (property: "og:title", content: title-str))
    }
    html.elem("meta", attrs: (
      property: "og:type",
      content: if is-article { "article" } else { "website" },
    ))
    if canonical-url != none {
      html.elem("meta", attrs: (property: "og:url", content: canonical-url))
    }
    if desc-str != none {
      html.elem("meta", attrs: (property: "og:description", content: desc-str))
    }
    if site-str != none {
      html.elem("meta", attrs: (property: "og:site_name", content: site-str))
    }
    if is-article {
      if created-iso != none {
        html.elem("meta", attrs: (
          property: "article:published_time",
          content: created-iso,
        ))
      }
      if modified-iso != none {
        html.elem("meta", attrs: (
          property: "article:modified_time",
          content: modified-iso,
        ))
      }
      if author-str != none {
        html.elem("meta", attrs: (
          property: "article:author",
          content: author-str,
        ))
      }
      for t in tags {
        html.elem("meta", attrs: (property: "article:tag", content: str(t)))
      }
    }
  }

  if scholar-meta and is-article {
    if title-str != none {
      html.meta(name: "citation_title", content: title-str)
    }
    if author-str != none {
      html.meta(name: "citation_author", content: author-str)
    }
    if created-iso != none {
      html.meta(name: "citation_publication_date", content: created-iso.replace(
        "-",
        "/",
      ))
    }
    if modified-iso != none {
      html.meta(name: "citation_online_date", content: modified-iso.replace(
        "-",
        "/",
      ))
    }
    if monograph != none {
      html.meta(
        name: "citation_technical_report_number",
        content: to-plain-text(monograph, lang: lang),
      )
    }
    if tags.len() > 0 {
      html.meta(name: "citation_keywords", content: tags.map(str).join("; "))
    }
    if canonical-url != none {
      html.meta(name: "citation_public_url", content: canonical-url)
    }
  }
}

/// Generate a spec-compliant `sitemap.xml` (`http://www.sitemaps.org/schemas/sitemap/0.9`)
/// via `@preview/syndicate` (`sitemap.urlset`) covering `index.html`, all public pages/posts,
/// and any `hreflang` alternate URLs.
/// -> str
#let sitemap-xml(
  /// Canonical site origin URL (`"https://example.com"`).
  /// -> str
  site-url: "https://example.com",
  /// Public page/post records (`(html-path: "...", created: ..., modified: ..., alternates?: ...)`).
  /// -> array
  entries: (),
  /// Include the site root URL (`/`) as the first `<url>` entry.
  /// -> bool
  include-root: true,
  /// Root-level `hreflang` alternates (`("de": "/de/")`).
  /// -> dictionary | array | none
  root-alternates: none,
) = {
  let latest = _latest-lastmod(entries)

  let root-urls = if include-root {
    (
      sitemap.url(
        canonical-page-url(site-url, "index.html"),
        lastmod: latest,
        alternates: _alternates-dict(normalize-alternates(
          root-alternates,
          site-url: site-url,
        )),
      ),
    )
  } else {
    ()
  }

  let page-urls = entries
    .filter(e => str(e.at("html-path", default: "")).trim("/") != "index.html")
    .map(e => sitemap.url(
      canonical-page-url(site-url, e.html-path),
      lastmod: _entry-lastmod(e),
      alternates: _alternates-dict(normalize-alternates(
        e.at("alternates", default: none),
        site-url: site-url,
      )),
    ))

  sitemap.urlset(..(root-urls + page-urls))
}

/// Generate a standard `robots.txt` pointing crawlers to `sitemap.xml`.
/// -> str
#let robots-txt(
  /// Canonical site origin URL (`"https://example.com"`).
  /// -> str
  site-url: "https://example.com",
  /// Relative path to the emitted XML sitemap, or `none` to omit the `Sitemap:` line.
  /// -> str | none
  sitemap-path: "sitemap.xml",
) = {
  let clean-url = str(site-url).trim("/", at: end)
  let base = "User-agent: *\nAllow: /\n"
  if sitemap-path != none {
    base + "\nSitemap: " + clean-url + "/" + str(sitemap-path).trim("/") + "\n"
  } else {
    base
  }
}

#let _infer-feed-epoch(posts, explicit-epoch) = {
  if type(explicit-epoch) == datetime {
    return explicit-epoch
  }
  let dated = posts.filter(p => (
    type(p.at("created", default: none)) == datetime or type(p.at("modified", default: none)) == datetime
  ))
  if dated.len() > 0 {
    let sorted = dated.sorted(key: p => date-sort-key(if p.at(
      "created",
      default: none,
    )
      != none { p.created } else { p.modified }))
    let earliest = sorted.first()
    if type(earliest.at("created", default: none)) == datetime {
      earliest.created
    } else {
      earliest.modified
    }
  } else {
    _default-epoch
  }
}

#let _build-post-label-urls(clean-url, posts, extra: (:)) = {
  let out = extra
  for p in posts {
    if (
      p.at("slug", default: none) != none and p.at("html-path", default: none) != none
    ) {
      out.insert(str(p.slug), canonical-page-url(clean-url, p.html-path))
    }
  }
  out
}

/// Generate an Atom 1.0 XML feed string via `@preview/syndicate` (`atom.feed`),
/// supporting both summary-only (`feed-content: "summary"`) and full semantic HTML
/// (`feed-content: "full"`) entries.
/// -> str
#let atom-xml(
  /// Feed title.
  /// -> content | str
  site-title: [Site],
  /// Optional Atom `<subtitle>`.
  /// -> content | str | none
  site-subtitle: none,
  /// Canonical site origin URL.
  /// -> str
  site-url: "https://example.com",
  /// Default feed author name.
  /// -> content | str | none
  author: none,
  /// Relative path to the Atom feed (`atom.xml`).
  /// -> str
  atom-path: "atom.xml",
  /// Entry payload mode (`"summary"` or `"full"`).
  /// -> str
  feed-content: "summary",
  /// Optional RFC 4151 feed `<id>` minting date (`auto` derives from earliest post).
  /// -> auto | datetime
  feed-epoch: auto,
  /// Optional map of bundle `<label>` names to canonical URLs for cross-bundle links.
  /// -> dictionary
  label-urls: (:),
  /// Page/post records returned by `query-pages()`.
  /// -> array
  posts: (),
) = {
  let clean-url = str(site-url).trim("/", at: end)
  let authority = url-authority(clean-url)
  let plain-author = _plain-or-none(author)
  // RFC 4287 requires an author on the feed or on every entry, and `syndicate`
  // enforces that. Fall back to the site title so a site with no `author` still builds.
  let feed-authors = if plain-author != none {
    (atom.author(plain-author, uri: clean-url + "/"),)
  } else {
    (atom.author(to-plain-text(site-title), uri: clean-url + "/"),)
  }
  let epoch = _infer-feed-epoch(posts, feed-epoch)
  let include-full = feed-content == "full"
  let merged-label-urls = _build-post-label-urls(
    clean-url,
    posts,
    extra: label-urls,
  )

  let entries = posts.map(p => {
    let pub-dt = p.at("created", default: none)
    let mod-dt = if p.at("modified", default: none) != none {
      p.modified
    } else if pub-dt != none {
      pub-dt
    } else {
      epoch
    }
    let id-dt = if pub-dt != none { pub-dt } else { mod-dt }
    let post-url = canonical-page-url(clean-url, p.html-path)
    let p-lang = p.at("primary-lang", default: none)
    let p-author = _plain-or-none(p.at("author", default: none), lang: p-lang)
    let entry-authors = if p-author != none and p-author != plain-author {
      (atom.author(p-author),)
    } else {
      ()
    }
    let html-body = if (
      include-full and p.at("raw-body", default: none) != none
    ) {
      content-to-feed-html(
        p.raw-body,
        site-url: clean-url,
        doc-path: p.html-path,
        lang: p-lang,
        label-urls: merged-label-urls,
      )
    } else {
      none
    }
    atom.entry(
      to-plain-text(p.title, lang: p-lang),
      link: post-url,
      id: atom.tag-uri(authority, id-dt, p.slug),
      updated: mod-dt,
      published: pub-dt,
      summary: _entry-summary(p, lang: p-lang),
      content: if html-body != none and html-body != "" { html-body } else {
        none
      },
      authors: entry-authors,
      categories: p.at("tags", default: ()),
    )
  })

  atom.feed(
    title: to-plain-text(site-title),
    subtitle: _plain-or-none(site-subtitle),
    link: clean-url + "/",
    self-link: clean-url + "/" + str(atom-path).trim("/", at: start),
    id: atom.tag-uri(authority, epoch, "feed"),
    updated: if entries.len() > 0 { auto } else { epoch },
    authors: feed-authors,
    entries: entries,
  )
}

/// Generate an RSS 2.0 XML feed string via `@preview/syndicate` (`rss.feed`),
/// supporting both `<description>` summaries (`feed-content: "summary"`) and full
/// `<content:encoded>` HTML (`feed-content: "full"`).
/// -> str
#let rss-xml(
  /// Channel `<title>`.
  /// -> content | str
  site-title: [Site],
  /// Channel `<description>` (falls back to `site-title` when `none`).
  /// -> content | str | none
  site-subtitle: none,
  /// Canonical site origin URL.
  /// -> str
  site-url: "https://example.com",
  /// Optional `<language>` tag (e.g. `"en"`).
  /// -> str | none
  language: none,
  /// Relative path to the RSS feed (`rss.xml`) for `atom:link rel="self"`.
  /// -> str
  rss-path: "rss.xml",
  /// Entry payload mode (`"summary"` or `"full"`).
  /// -> str
  feed-content: "summary",
  /// Optional map of bundle `<label>` names to canonical URLs for cross-bundle links.
  /// -> dictionary
  label-urls: (:),
  /// Page/post records returned by `query-pages()`.
  /// -> array
  posts: (),
) = {
  let clean-url = str(site-url).trim("/", at: end)
  let include-full = feed-content == "full"
  let merged-label-urls = _build-post-label-urls(
    clean-url,
    posts,
    extra: label-urls,
  )
  let latest = _latest-lastmod(posts)

  let items = posts.map(p => {
    let p-lang = p.at("primary-lang", default: none)
    let html-body = if (
      include-full and p.at("raw-body", default: none) != none
    ) {
      content-to-feed-html(
        p.raw-body,
        site-url: clean-url,
        doc-path: p.html-path,
        lang: p-lang,
        label-urls: merged-label-urls,
      )
    } else {
      none
    }
    rss.item(
      to-plain-text(p.title, lang: p-lang),
      link: canonical-page-url(clean-url, p.html-path),
      published: p.at("created", default: none),
      description: _entry-summary(p, lang: p-lang),
      content: if html-body != none and html-body != "" { html-body } else {
        none
      },
      categories: p.at("tags", default: ()),
    )
  })

  rss.feed(
    title: to-plain-text(site-title),
    description: if _plain-or-none(site-subtitle) == none {
      to-plain-text(site-title)
    } else {
      _plain-or-none(site-subtitle)
    },
    link: clean-url + "/",
    self-link: clean-url + "/" + str(rss-path).trim("/", at: start),
    updated: if type(latest) == datetime { latest } else { auto },
    language: language,
    items: items,
  )
}
