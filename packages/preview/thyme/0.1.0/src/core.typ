// Unopinionated, zero-CSS static site generator core (`site`, `webpage`, `mount`,
// `file`, `page-asset`, `query-pages`, `backlinks`).
//
// Designed both for custom static websites (`apex`-style portfolios, documentation,
// Tadi Web sites) and as the single shared bundle engine underneath presets like `blog`.

#import "i18n.typ": (
  assert-complete-translations, i18n-css, lang-switcher, normalize-alternates, render-lang-inputs, resolve-page-langs,
)
#import "paths.typ": (
  canonical-page-url, date-sort-key, emit-doc-marker, find-doc-containing, format-date, join-path, parent-dir,
  query-backlinks, rel-href, rel-root, relative-typ-path, resolve-bundle-label, route-html-path, slug-from-path,
  slug-from-typ-path, slugify, source-path-for, unwrap-typ-path, with-html-headings, with-smart-refs,
)
#import "seo.typ": atom-xml, render-seo-meta, robots-txt, rss-xml, sitemap-xml
#import "blog/theme.typ": css-hex, theme-default
#import "text.typ": count-words, estimate-reading-minutes, to-plain-text
#import "tree.typ": collect-content, find-content, map-containers

// Normalize co-located page assets (`dictionary` or `array`, accepting `path(...)`, `bytes`, or `str`).
#let normalize-assets(assets) = {
  let coerce-data(d) = if type(d) == path { read(d, encoding: none) } else { d }
  if assets == none or assets == () or assets == (:) {
    ()
  } else if type(assets) == dictionary {
    assets
      .pairs()
      .map(((p, d)) => (
        path: str(p).trim("/"),
        data: coerce-data(d),
        label: none,
      ))
  } else if type(assets) == array {
    assets.map(a => if type(a) == array {
      (
        path: str(a.at(0)).trim("/"),
        data: coerce-data(a.at(1)),
        label: if a.len() >= 3 { a.at(2) } else { none },
      )
    } else {
      (
        path: str(a.path).trim("/"),
        data: coerce-data(a.data),
        label: a.at("label", default: none),
      )
    })
  } else {
    panic(
      "`assets` expects a dictionary or an array of `(path, data, label?)` records.",
    )
  }
}

/// Declare a co-located asset emitted next to the page that contains it
/// (`#page-asset("diagram.svg", path("diagram.svg")) <diagram>`).
/// -> content
#let page-asset(
  /// Relative filename inside the page's output directory.
  /// -> str
  out-path,
  /// Capability `path(...)`, raw `bytes`, or UTF-8 `str` payload.
  /// -> path | bytes | str
  data,
) = metadata((
  thyme-page-asset: true,
  path: str(out-path).trim("/"),
  data: if type(data) == path { read(data, encoding: none) } else { data },
))

/// Emit a static file at an exact bundle-root path
/// (`#file("pgp.txt", path("pgp.txt")) <pgp>`).
/// Pass a capability `path(...)` to read the payload, or `bytes` / `str` directly.
/// -> content
#let file(
  /// Bundle output path relative to the web root (e.g. `"age.txt"`, `"cv.pdf"`, `"assets/font.woff2"`).
  /// -> str
  out-path,
  /// Capability `path(...)`, raw `bytes`, or UTF-8 `str` payload.
  /// -> path | bytes | str
  data,
) = metadata((
  thyme-raw-file: true,
  path: str(out-path).trim("/"),
  data: if type(data) == path { read(data, encoding: none) } else { data },
))

// Resolve the active site configuration inside `context`.
//
// `site()` publishes exactly one `<site-config>` dictionary per bundle: the shared core
// keys (title, url, lang, ...) merged with any preset-specific keys (`theme`,
// `posts-dir`, ...). Post and page renderers read that single dictionary.
// -> dictionary | none
#let site-config() = {
  let found = query(<site-config>)
  if found.len() > 0 { found.first().value } else { none }
}

// Shared AST extractors built on `src/tree.typ` (single traversal implementation).
#let _is-mount-or-raw(c) = (
  c.func() == metadata
    and type(c.value) == dictionary
    and (
      c.value.at("thyme-mounted", default: false) or c.value.at("thyme-raw-file", default: false)
    )
)

#let extract-page-meta(c) = find-content(c, n => (
  if n.func() == metadata and n.at("label", default: none) == <thyme-page-meta> {
    n.value
  } else {
    none
  }
))

#let extract-page-assets(c) = collect-content(c, n => (
  if n.func() == metadata and type(n.value) == dictionary and n.value.at("thyme-page-asset", default: false) {
    (
      (
        path: n.value.path,
        data: n.value.data,
        label: n.at("label", default: none),
      ),
    )
  } else {
    ()
  }
))

#let extract-first-h1(c) = find-content(
  c,
  n => if n.func() == heading and n.at("depth", default: 1) == 1 {
    n.body
  } else { none },
  descend: n => not _is-mount-or-raw(n) and n.func() != heading,
)

#let extract-mounts(c) = collect-content(
  c,
  n => if n.func() == metadata and type(n.value) == dictionary and n.value.at("thyme-mounted", default: false) {
    ((el: n, val: n.value, lbl: n.at("label", default: none)),)
  } else {
    ()
  },
  descend: n => not _is-mount-or-raw(n),
)

#let extract-raw-files(c) = collect-content(
  c,
  n => if n.func() == metadata and type(n.value) == dictionary and n.value.at("thyme-raw-file", default: false) {
    ((val: n.value, lbl: n.at("label", default: none)),)
  } else {
    ()
  },
  descend: n => not _is-mount-or-raw(n),
)

// Deep container-preserving replacement of `#mount(...)` and `#file(...)` markers inside `site.typ` body.
#let transform-mounts(c, render-fn) = map-containers(c, n => {
  if n.func() == metadata and type(n.value) == dictionary {
    if n.value.at("thyme-mounted", default: false) {
      return render-fn((el: n, val: n.value, lbl: n.at("label", default: none)))
    }
    if n.value.at("thyme-raw-file", default: false) {
      return []
    }
  }
  auto
})

/// Mount a standalone `.typ` page into a `site` bundle
/// (`#mount(path("contact.typ")) <contact>`).
///
/// Passing `path(...)` lets `thyme` evaluate the page (`include p`), read its verbatim
/// `.typ` source for Tadi Web inspection (`read(p)`), and infer its URL route
/// (`contact/index.html`) — all with native `typst watch` dependency tracking.
/// -> content
#let mount(
  /// Capability `path("...")` to the `.typ` file (or pre-evaluated `include "..."` content).
  /// -> path | content
  target-page,
  /// Explicit slug override (`auto` derives from `<label>` or filename).
  /// -> auto | str
  slug: auto,
  /// Explicit bundle HTML path override (e.g. `"contact/index.html"`).
  /// -> str | none
  route: none,
  /// Collection name for `query-pages(collection: ...)` filtering (e.g. `"posts"`, `"pages"`).
  /// -> str | none
  collection: none,
  /// Co-located files (`("card.svg": path("card.svg"))`) emitted alongside the page's `index.html`.
  /// -> dictionary | array
  assets: (),
  /// Explicit `.typ` source override when `target-page` was passed via `include` rather than `path(...)`.
  /// -> path | str | none
  src: none,
) = {
  let is-path = type(target-page) == path
  let evaluated = if is-path { include target-page } else { target-page }
  let raw-source = if src != none {
    if type(src) == path { read(src) } else { str(src) }
  } else if is-path {
    read(target-page)
  } else {
    none
  }
  let typ-path = if is-path { unwrap-typ-path(target-page) } else { none }
  let detected = extract-page-meta(evaluated)
  let fallback-title = {
    let h1 = extract-first-h1(evaluated)
    if h1 != none { h1 } else { [Untitled] }
  }
  let meta = if detected != none {
    detected
  } else {
    (
      title: fallback-title,
      subtitle: none,
      description: none,
      summary: none,
      created: none,
      created-str: none,
      modified: none,
      modified-str: none,
      sort-key: "0000-00-00T00:00:00",
      author: none,
      monograph: none,
      tags: (),
      alternates: none,
      collection: collection,
      assets: (),
      slug: none,
      base-words: count-words(evaluated),
      wpm: 200,
      raw-body: evaluated,
      draft: false,
      unlisted: false,
      is-wrapped-page: false,
    )
  }
  let extra-assets = normalize-assets(assets)
  let merged-meta = (
    ..meta,
    collection: if collection != none { collection } else {
      meta.at("collection", default: none)
    },
    assets: meta.at("assets", default: ()) + extra-assets,
  )

  metadata((
    thyme-mounted: true,
    slug: if slug != auto { slug } else if merged-meta.slug != none {
      merged-meta.slug
    } else { slug-from-typ-path(typ-path) },
    path: route,
    typ-path: typ-path,
    raw-source: raw-source,
    meta: merged-meta,
    body: evaluated,
  ))
}

/// Query public (non-draft, unlisted-excluded) pages and posts across the active
/// bundle, newest first. Filter by `collection`, `tag`, or `lang`.
/// Call inside `context`.
/// -> array
#let query-pages(
  /// Optional collection filter (e.g. `"posts"`).
  /// -> str | none
  collection: none,
  /// Optional tag filter.
  /// -> str | none
  tag: none,
  /// Optional primary language filter (e.g. `"en"`, `"de"`).
  /// -> str | none
  lang: none,
  /// Include unlisted pages when `true`.
  /// -> bool
  include-unlisted: false,
) = {
  let docs = query(document)
  let entries = ()
  for d in docs {
    if d.path != none and d.path.ends-with(".html") and d.path != "404.html" {
      let metas = query(selector(<thyme-page-meta>).within(d.location()))
      if metas.len() > 0 {
        let m = metas.first().value
        let allow = (
          not m.at("draft", default: false)
            and (include-unlisted or not m.at("unlisted", default: false))
            and (
              collection == none or m.at("collection", default: none) == collection
            )
            and (tag == none or tag in m.at("tags", default: ()))
            and (lang == none or m.at("primary-lang", default: "en") == lang)
        )
        if allow {
          let derived-slug = if m.slug != none { m.slug } else {
            slug-from-path(d.path)
          }
          let hint-words = query(
            selector(<thyme-word-hint>).within(d.location()),
          ).fold(0, (acc, h) => acc + h.value)
          let total-words = m.base-words + hint-words
          entries.push((
            ..m,
            slug: derived-slug,
            words: total-words,
            minutes: estimate-reading-minutes(total-words, wpm: m.at(
              "wpm",
              default: 200,
            )),
            doc-loc: d.location(),
            doc-path: d.path,
            html-path: d.path,
          ))
        }
      }
    }
  }
  entries.sorted(key: p => p.sort-key).rev()
}

/// Render a compile-time "Referenced by" list for the enclosing page or post.
/// `target: auto` infers the current page's slug. Emits nothing when no public
/// page links here. Call inside `context`.
/// -> content
#let backlinks(
  /// Optional explicit target slug (`auto` infers from the enclosing bundle document).
  /// -> auto | str
  target: auto,
  /// Heading label rendered above the backlinks list.
  /// -> content | str
  title: [Referenced by],
) = context {
  let enc-doc = find-doc-containing(here())
  let doc-path = if enc-doc != none { enc-doc.path } else { none }
  let doc-metas = if enc-doc != none {
    query(selector(<thyme-page-meta>).within(enc-doc.location()))
  } else {
    query(selector(<thyme-page-meta>).before(here()))
  }
  let resolved-slug = if target != auto {
    str(target)
  } else if (
    doc-metas.len() > 0 and doc-metas.first().value.at("slug", default: none) != none
  ) {
    doc-metas.first().value.slug
  } else if doc-path != none {
    slug-from-path(doc-path)
  } else {
    none
  }
  if resolved-slug == none {
    return []
  }
  let refs = query-backlinks(resolved-slug, exclude-doc-path: doc-path)
  if refs.len() == 0 {
    return []
  }
  if std.target() == "html" {
    html.footer(class: "blog-backlinks", {
      html.div(class: "blog-backlinks-title", title)
      html.ul(class: "blog-backlinks-list", {
        for r in refs {
          html.li({
            link(r.doc-loc, r.title)
            if r.at("created-str", default: none) != none {
              html.span(class: "when", {
                " · "
                html.elem(
                  "time",
                  attrs: (datetime: r.created-str),
                  r.created-str,
                )
              })
            }
          })
        }
      })
    })
  } else {
    v(1em)
    line(length: 100%, stroke: 0.5pt + luma(80%))
    block(above: 0.5em, {
      strong(title)
      for r in refs {
        par(link(r.doc-loc, r.title))
      }
    })
  }
}

// Lookup the co-emitted `.typ` source path for `doc-path` from `<thyme-source-map>` inside `context`.
#let lookup-source-href(doc-path) = {
  if doc-path == none {
    return none
  }
  let clean-doc = str(doc-path).trim("/")
  let maps = query(<thyme-source-map>)
  if maps.len() == 0 {
    return none
  }
  let src-map = maps.first().value
  if clean-doc in src-map {
    rel-href(clean-doc, src-map.at(clean-doc))
  } else {
    none
  }
}

// Query `<thyme-tr-meta>` language codes inside a specific bundle `document` element
// (or across the document in standalone single-file mode).
#let query-doc-tr-codes(doc-el) = {
  let metas = if doc-el != none {
    query(selector(<thyme-tr-meta>).within(doc-el.location()))
  } else if query(document).len() == 0 {
    query(<thyme-tr-meta>)
  } else {
    ()
  }
  metas.fold((), (acc, m) => acc + m.value.entries.keys())
}

// Render the top utility bar (`backlink` on the left, `en · de` + `.typ` source link on the right).
#let render-top-bar(
  back-content: none,
  langs: ("en",),
  source-href: none,
  source-label: ".typ",
) = {
  let has-lang = langs.len() >= 2
  let has-src = (
    source-href != none and source-label != none and source-label != false
  )
  let has-right = has-lang or has-src
  if back-content == none and not has-right {
    return []
  }

  let nav-cls = if back-content == none { "back-home only-end" } else {
    "back-home"
  }
  html.elem(
    "nav",
    attrs: (class: nav-cls, "aria-label": "Site navigation"),
    {
      if back-content != none {
        back-content
      }
      if has-right {
        html.span(class: "top-actions", {
          if has-lang {
            lang-switcher(langs)
          }
          if has-src {
            html.a(
              href: source-href,
              type: "text/plain",
              rel: "alternate",
              class: "source-link",
              source-label,
            )
          }
        })
      }
    },
  )
}

// Minimal built-in layout CSS ONLY for the top utility bar on zero-stylesheet `thyme` core sites.
#let _core-topbar-css = "nav.back-home { display: flex; align-items: baseline; justify-content: space-between; gap: 1rem; margin-bottom: 1.25rem; font-family: ui-monospace, monospace; font-size: 0.82rem; }
nav.back-home.only-end { justify-content: flex-end; }
nav.back-home .top-actions { display: inline-flex; align-items: baseline; gap: 0.85rem; }
a.heading-anchor { margin-left: 0.35em; opacity: 0; text-decoration: none; font-weight: 400; }
:is(h2, h3, h4, h5, h6):hover > a.heading-anchor, a.heading-anchor:focus { opacity: 0.65; }
@media print { nav.back-home, a.heading-anchor { display: none !important; } }"

// Big operator glyphs whose presence inside `math.lr` requires vertical delimiter stretching.
#let _math-big-ops = (
  "∑",
  "∏",
  "∐",
  "∫",
  "∬",
  "∭",
  "∮",
  "∯",
  "∰",
  "⋀",
  "⋁",
  "⋂",
  "⋃",
  "⨀",
  "⨁",
  "⨂",
  "⨄",
  "⨅",
  "⨆",
)

// Pure syntactic AST predicate (zero `measure()`, zero `context`) checking whether a `math.lr`
// body contains multi-story / tall math constructs that warrant stretchy delimiters in MathML.
#let _math-needs-stretch(node, in-display: false) = {
  if node == none {
    return false
  }
  let f = node.func()
  if (
    f
      in (
        math.frac,
        math.binom,
        math.mat,
        math.vec,
        math.cases,
        math.root,
        math.overbrace,
        math.underbrace,
        math.overbracket,
        math.underbracket,
        math.mid,
      )
  ) {
    return true
  }
  if node.has("text") {
    return _math-big-ops.any(op => node.text.contains(op))
  }
  if node.has("children") {
    return node.children.any(c => _math-needs-stretch(
      c,
      in-display: in-display,
    ))
  }
  if node.has("body") {
    return _math-needs-stretch(node.body, in-display: in-display)
  }
  if node.has("child") {
    return _math-needs-stretch(node.child, in-display: in-display)
  }
  if node.has("radicand") {
    return true
  }
  if node.has("base") {
    let base = node.base
    if (
      in-display and base.func() == math.op and base.has("limits") and base.limits and (node.has("b") or node.has("t"))
    ) {
      return true
    }
    if _math-needs-stretch(base, in-display: in-display) {
      return true
    }
    for k in ("t", "b", "tl", "bl", "tr", "br") {
      if (
        node.has(k) and _math-needs-stretch(node.at(k), in-display: in-display)
      ) {
        return true
      }
    }
  }
  false
}

// Check whether an attachment script slot (`t`, `b`, etc.) is a single non-alphanumeric
// operator glyph (`∗`, `+`, `−`, `×`, `∘`, `⊥`, etc.) so Typst emits `<mi>` instead of
// an `<mo>` with W3C MathML Operator Dictionary `lspace`/`rspace` padding inside `<msup>`/`<msub>`.
#let _is-lone-script-op(node) = {
  if node == none or not node.has("text") {
    return false
  }
  let cps = node.text.codepoints()
  if cps.len() != 1 {
    return false
  }
  let cp = str.to-unicode(cps.at(0))
  if (
    (cp >= 0x30 and cp <= 0x39) or (cp >= 0x41 and cp <= 0x5A) or (cp >= 0x61 and cp <= 0x7A)
  ) {
    return false
  }
  if (
    (cp >= 0x0370 and cp <= 0x03FF) or (cp >= 0x2100 and cp <= 0x214F) or (cp >= 0x1D400 and cp <= 0x1D7FF)
  ) {
    return false
  }
  true
}

/// Normalize Typst HTML/MathML output using pure syntactic AST `show` rules (zero `measure()`,
/// zero SVG, 100% native `<math>`):
/// 1. Suppresses auto-`math.lr` `stretchy="true"` on single-line expressions (`$F(e)$`, `$F(d^*)$`)
///    so Safari/WebKit keeps delimiters on the math axis/baseline while still stretching tall
///    fractions, matrices, roots, big operators (`$F(a/b)$`, `$F(union.sq.big_n d_n)$`), and explicit `lr(...)`.
/// 2. Coerces lone operator glyphs in script slots (`$d^*$`, `$ℝ^+$`, `$G^×$`) to `math.class("normal", ...)`
///    so MathML engines do not pad superscripts/subscripts with binary `lspace`/`rspace`.
/// -> content
#let with-html-math(
  /// Content subtree to normalize for HTML MathML output.
  /// -> content
  body,
) = {
  show math.equation: eq => {
    let is-disp = eq.block
    show math.lr: it => {
      if (
        it.size != 100% + 0pt or it.body.func() == math.lr or _math-needs-stretch(it.body, in-display: is-disp)
      ) {
        it
      } else {
        it.body
      }
    }
    show math.attach: it => {
      let fields = it.fields()
      let base = fields.remove("base")
      let changed = false
      for k in ("t", "b", "tl", "bl", "tr", "br") {
        if k in fields and _is-lone-script-op(fields.at(k)) {
          fields.insert(k, math.class("normal", fields.at(k)))
          changed = true
        }
      }
      if changed {
        math.attach(base, ..fields)
      } else {
        it
      }
    }
    eq
  }
  body
}

// Shared HTML5 document shell used by both `thyme` core (`site`, `webpage`) and presets (`blog`).
#let render-core-shell(
  title: [Site],
  site-title: none,
  description: none,
  author: none,
  site-url: none,
  doc-path: none,
  langs: ("en",),
  alternates: none,
  stylesheet-paths: (),
  inline-styles: (),
  include-core-topbar-css: true,
  favicon-href: none,
  favicon-type: none,
  source-href: none,
  source-label: ".typ",
  back-content: none,
  render-topbar: true,
  include-feeds: false,
  rss-path: none,
  atom-path: none,
  created: none,
  modified: none,
  monograph: none,
  tags: (),
  is-article: false,
  open-graph: false,
  scholar-meta: false,
  extra-head: none,
  body-wrapper: none,
  wrap-main: true,
  /// Theme dictionary used to derive `<meta name="theme-color">`. Browsers only
  /// honour sRGB there, so the `oklch` tokens are converted to hex for this one tag.
  /// -> dictionary
  theme-config: theme-default,
  body,
) = {
  let in-bundle = doc-path != none
  let root-prefix = rel-root(doc-path)
  let primary-lang = if langs.len() > 0 { langs.first() } else { "en" }
  let title-str = to-plain-text(title, lang: primary-lang)
  let site-str = if site-title != none {
    to-plain-text(site-title, lang: primary-lang)
  } else { none }
  let page-title-str = if site-str != none and title-str != site-str {
    title-str + " - " + site-str
  } else {
    title-str
  }
  let canon-url = if in-bundle and site-url != none {
    canonical-page-url(site-url, doc-path)
  } else {
    none
  }
  let norm-alts = normalize-alternates(alternates, site-url: site-url)
  let i18n-rules = i18n-css(langs)
  let style-blocks = (
    ..if include-core-topbar-css { (_core-topbar-css,) } else { () },
    ..inline-styles.filter(s => s != none and s != ""),
    ..if i18n-rules != "" { (i18n-rules,) } else { () },
  )

  html.html(lang: primary-lang, {
    html.head({
      html.meta(charset: "utf-8")
      html.meta(
        name: "viewport",
        content: "width=device-width, initial-scale=1",
      )
      if description != none {
        html.meta(name: "description", content: to-plain-text(
          description,
          lang: primary-lang,
        ))
      }
      if author != none {
        html.meta(name: "author", content: to-plain-text(
          author,
          lang: primary-lang,
        ))
      }
      html.title(page-title-str)
      if canon-url != none {
        html.link(rel: "canonical", href: canon-url)
      }
      for alt in norm-alts {
        html.link(rel: "alternate", hreflang: alt.hreflang, href: alt.href)
      }
      render-seo-meta(
        title: title,
        site-title: site-title,
        description: description,
        author: author,
        canonical-url: canon-url,
        created: created,
        modified: modified,
        monograph: monograph,
        tags: tags,
        is-article: is-article,
        lang: primary-lang,
        open-graph: open-graph,
        scholar-meta: scholar-meta,
      )
      if favicon-href != none {
        html.link(
          rel: "icon",
          href: root-prefix + str(favicon-href).trim("/"),
          ..if favicon-type != none { (type: favicon-type) } else { (:) },
        )
      }
      // `theme-color` follows the active theme rather than a pinned hex value. This is
      // the one place a literal is unavoidable: browsers ignore non-sRGB colour
      // syntax here, so the oklch tokens are converted at compile time.
      html.meta(
        name: "theme-color",
        content: css-hex(theme-config.paper-light),
        media: "(prefers-color-scheme: light)",
      )
      html.meta(
        name: "theme-color",
        content: css-hex(theme-config.paper-dark),
        media: "(prefers-color-scheme: dark)",
      )
      for css-p in stylesheet-paths {
        let p-str = str(css-p)
        let href = if (
          p-str.starts-with("http://") or p-str.starts-with("https://") or p-str.starts-with("/")
        ) {
          p-str
        } else {
          root-prefix + p-str.trim("/")
        }
        html.link(rel: "stylesheet", href: href)
      }
      if source-href != none {
        html.link(
          rel: "alternate",
          type: "text/plain",
          title: "Typst source",
          href: source-href,
        )
      }
      if in-bundle and include-feeds {
        let label-base = if site-str != none { site-str } else { title-str }
        if rss-path != none {
          html.link(
            rel: "alternate",
            type: "application/rss+xml",
            title: label-base + " RSS",
            href: root-prefix + str(rss-path).trim("/"),
          )
        }
        if atom-path != none {
          html.link(
            rel: "alternate",
            type: "application/atom+xml",
            title: label-base + " Atom",
            href: root-prefix + str(atom-path).trim("/"),
          )
        }
      }
      if style-blocks.len() > 0 {
        html.style(style-blocks.join("\n"))
      }
      if extra-head != none {
        extra-head
      }
    })

    html.body({
      let inner = {
        render-lang-inputs(langs)
        let top-bar = if render-topbar {
          render-top-bar(
            back-content: back-content,
            langs: langs,
            source-href: source-href,
            source-label: source-label,
          )
        } else {
          []
        }
        if wrap-main {
          html.main({
            top-bar
            body
          })
        } else {
          top-bar
          body
        }
      }
      show: with-html-math
      if body-wrapper != none {
        body-wrapper(inner)
      } else {
        show: with-smart-refs
        inner
      }
    })
  })
}

/// Render one standalone HTML page (`#show: webpage.with(title: ..., ...)`).
///
/// Records the page metadata (`title`, `description`, `created`, `modified`, `lang`,
/// `tags`, `collection`) that `query-pages()` and the feeds read, without imposing a
/// stylesheet. Inside a `site` bundle it inherits the site's stylesheets and top bar.
/// -> content
#let webpage(
  /// Page title (`auto` infers from the first `= ...` heading in `body`).
  /// -> auto | content | str
  title: auto,
  /// Short page description for `<meta name="description">`, feeds, and listings.
  /// -> content | str | none
  description: none,
  /// Creation date (`YYYY-MM-DD`).
  /// -> datetime | str | none
  created: none,
  /// Last-modified date (`YYYY-MM-DD`); drives `<lastmod>` in `sitemap.xml` and `<updated>` in Atom.
  /// -> datetime | str | none
  modified: none,
  /// Page language (`auto` inherits from `site` and auto-detects `#tr(...)` blocks; `"de"`, or `("en", "de")`).
  /// -> auto | str | array
  lang: auto,
  /// Optional `hreflang` alternate URLs (`(de: "de/contact/index.html")`).
  /// -> dictionary | array | none
  alternates: none,
  /// Author override (inherits from `site` when `none`).
  /// -> content | str | none
  author: none,
  /// Tag strings for filtering and syndication categories.
  /// -> array
  tags: (),
  /// Optional collection group (e.g. `"pages"`, `"posts"`, `"projects"`).
  /// -> str | none
  collection: "pages",
  /// Co-located files (`("diagram.svg": path("diagram.svg"))`) emitted alongside the page.
  /// -> dictionary | array
  assets: (),
  /// Explicit URL slug override.
  /// -> auto | str
  slug: auto,
  /// Backlink label at the top of the page (`none` omits backlink).
  /// -> content | str | none
  home-text: "/..",
  /// Wrap `body` inside `<main>` (`false` lets `body` emit top-level `<header>`/`<main>`/`<footer>` directly).
  /// -> bool
  wrap-main: true,
  /// Append `§` hover permalinks on section headings (`h2`–`h6`).
  /// -> auto | bool
  heading-permalinks: auto,
  /// Render compile-time backlinks footer at the bottom of the page (`auto` inherits from `site`).
  /// -> auto | bool
  show-backlinks: auto,
  /// Emit OpenGraph `<meta property="og:*">` tags (`auto` inherits from `site`).
  /// -> auto | bool
  open-graph: auto,
  /// Additional `<head>` elements (e.g. custom `<meta>` or `<link>` tags).
  /// -> content | none
  head: none,
  /// Exclude page from `query-pages()`, `sitemap.xml`, and feeds when `true`.
  /// -> bool
  draft: false,
  /// Emit the HTML page at its URL, but omit it from `query-pages()`, `sitemap.xml`, and feeds.
  /// -> bool
  unlisted: false,
  /// Page body markup.
  /// -> content
  body,
) = {
  let h1 = extract-first-h1(body)
  let resolved-title = if title != auto {
    title
  } else if h1 != none {
    h1
  } else {
    [Untitled]
  }
  let created-str = format-date(created)
  let modified-str = format-date(modified)
  let page-langs = resolve-page-langs(lang, scan-nodes: (
    resolved-title,
    description,
    body,
  ))
  // A page that declares several languages must translate every block, or the switcher
  // offers a language that renders as a gap.
  assert-complete-translations((resolved-title, description, body), page-langs)
  let primary-lang = page-langs.first()

  let meta-payload = (
    title: resolved-title,
    subtitle: none,
    description: description,
    summary: description,
    created: created,
    created-str: created-str,
    modified: modified,
    modified-str: modified-str,
    sort-key: date-sort-key(created),
    author: author,
    monograph: none,
    tags: tags,
    alternates: alternates,
    collection: collection,
    langs: page-langs,
    primary-lang: primary-lang,
    assets: normalize-assets(assets) + extract-page-assets(body),
    slug: if slug == auto { none } else { slug },
    base-words: count-words(body),
    wpm: 200,
    raw-body: body,
    draft: draft,
    unlisted: unlisted,
    is-wrapped-page: true,
  )

  [#metadata(meta-payload)<thyme-page-meta>]

  context {
    let found = query(<site-config>)
    let site-config = if found.len() > 0 { found.first().value } else { none }
    let enc-doc = find-doc-containing(here())
    let doc-path = if enc-doc != none { enc-doc.path } else { none }
    let eff-langs = resolve-page-langs(
      lang,
      default-lang: if site-config != none { site-config.lang } else { "en" },
      scan-nodes: (resolved-title, description, body),
      queried-codes: query-doc-tr-codes(enc-doc),
    )
    let eff-permalinks = if heading-permalinks != auto {
      heading-permalinks == true
    } else if site-config != none {
      site-config.at("heading-permalinks", default: false)
    } else {
      false
    }
    let eff-backlinks = if show-backlinks != auto {
      show-backlinks == true
    } else if site-config != none {
      site-config.at("backlinks", default: false)
    } else {
      false
    }
    let eff-og = if open-graph != auto {
      open-graph == true
    } else if site-config != none {
      site-config.at("open-graph", default: false)
    } else {
      false
    }

    if target() == "html" {
      let home-docs = query(<site>)
      let back-node = if home-text != none {
        if home-docs.len() > 0 {
          link(home-docs.first().location(), home-text)
        } else {
          html.a(href: "/", home-text)
        }
      } else {
        none
      }
      let src-label = if site-config != none { site-config.source-label } else {
        none
      }
      let src-href = if src-label != none {
        lookup-source-href(doc-path)
      } else { none }
      let sheet-paths = if site-config != none {
        site-config.at("stylesheet-paths", default: ())
      } else { () }
      // A preset site (e.g. `blog`) styles its own top bar, so skip the built-in
      // monochrome rules; plain core sites get them.
      let is-preset-site = (
        site-config != none and site-config.at("is-preset", default: false)
      )
      // A preset may supply its resolved theme so `theme-color` tracks user overrides.
      let shell-theme = if site-config != none {
        site-config.at("theme", default: theme-default)
      } else {
        theme-default
      }

      render-core-shell(
        title: resolved-title,
        site-title: if site-config != none { site-config.title } else { none },
        description: description,
        author: if author != none { author } else if site-config != none {
          site-config.author
        } else { none },
        site-url: if site-config != none { site-config.url } else { none },
        doc-path: doc-path,
        langs: eff-langs,
        alternates: alternates,
        stylesheet-paths: sheet-paths,
        include-core-topbar-css: not is-preset-site,
        favicon-href: if site-config != none {
          site-config.at("favicon-href", default: none)
        } else { none },
        favicon-type: if site-config != none {
          site-config.at("favicon-type", default: none)
        } else { none },
        source-href: src-href,
        source-label: src-label,
        back-content: back-node,
        created: created,
        modified: modified,
        tags: tags,
        open-graph: eff-og,
        wrap-main: wrap-main,
        extra-head: head,
        theme-config: shell-theme,
        {
          show: with-html-headings.with(shift: 0, permalinks: eff-permalinks)
          set text(lang: eff-langs.first())
          [#metadata(none)<thyme-body-start>]
          body
          [#metadata(none)<thyme-body-end>]
          if eff-backlinks {
            backlinks()
          }
        },
      )
    } else {
      set text(lang: eff-langs.first())
      show: with-smart-refs
      [#metadata(none)<thyme-body-start>]
      body
      [#metadata(none)<thyme-body-end>]
      if eff-backlinks {
        backlinks()
      }
    }
  }
}

// Alias for `webpage`.
// -> function
// Normalize a `#mount(...)` record into its concrete bundle path, slug, label, and source mapping.
#let resolve-core-mount(rec, site-typ-path: none, default-route-fn: none) = {
  let v = rec.val
  let lbl = rec.lbl
  let rel-typ = relative-typ-path(v.typ-path, site-path: site-typ-path)
  let slug = if v.slug != none {
    v.slug
  } else if lbl != none {
    str(lbl)
  } else if rel-typ != none {
    slug-from-typ-path(rel-typ)
  } else {
    slugify(v.meta.title)
  }
  let doc-lbl = if lbl != none { lbl } else { label(slug) }
  let html-path = if v.path != none {
    route-html-path(v.path)
  } else if default-route-fn != none {
    default-route-fn(slug, rel-typ, v.meta)
  } else if rel-typ != none {
    route-html-path(rel-typ)
  } else {
    join-path(slug, "index.html")
  }
  (
    slug: slug,
    label: doc-lbl,
    path: html-path,
    dir: parent-dir(html-path),
    raw-source: v.raw-source,
    assets: v.meta.at("assets", default: ()),
    title: v.meta.title,
    is-wrapped: v.meta.at("is-wrapped-page", default: true),
    meta: v.meta,
    body: v.body,
    orig: v,
  )
}

// Emit a single bundle asset (with optional `<label>`).
#let emit-bundle-asset(out-path, data, lbl: none) = {
  let payload = if type(data) == bytes { data } else { bytes(str(data)) }
  if lbl != none {
    [#asset(out-path, payload)#lbl]
  } else {
    asset(out-path, payload)
  }
}

/// Generic, unopinionated static site bundler (`#show: site.with(...)`).
///
/// Compile a pure-Typst project into a static site bundle: `index.html`, mounted
/// subpages, your own stylesheets, static files, `404.html`, `sitemap.xml`,
/// `robots.txt`, optional RSS/Atom feeds, and Tadi Web `.typ` source files.
///
/// Ships no CSS or JavaScript of its own, so the site looks exactly like what you
/// pass in `stylesheets`. For the batteries-included monochrome blog instead, use
/// `blog.site` from the `blog` module.
/// -> content
#let site(
  /// Site title (`auto` infers from the first `= ...` heading in `body`, or pass any `str` / rich `content`).
  /// -> auto | content | str
  title: auto,
  /// Short site description for `<meta name="description">` and feed subtitles.
  /// -> content | str | none
  description: none,
  /// Canonical site origin URL (without trailing slash) for canonical links, `sitemap.xml`, and feeds.
  /// -> str
  url: "https://example.com",
  /// Default site author.
  /// -> content | str | none
  author: none,
  /// Default site language (`"en"` or `("en", "de")`).
  /// -> str | array
  lang: "en",
  /// Optional `hreflang` alternate URLs for the site root (`(de: "/de/")`).
  /// -> dictionary | array | none
  alternates: none,
  /// Stylesheets to emit and link (`path("styles.css")` or `(path: "styles.css", data: ..., href?: ..., label?: ...)`).
  /// -> array
  stylesheets: (),
  /// Optional site favicon (`path("assets/favicon.svg")` or `(path: "favicon.svg", data: ...)`).
  /// -> path | dictionary | none
  favicon: none,
  /// Additional static files `(path: "robots.txt", data: ..., label: none)` copied into the bundle root.
  /// -> array
  assets: (),
  /// Capability `path("site.typ")` (or `str`) of the root entrypoint so Tadi Web source view can emit `/site.typ`.
  /// -> path | str | none
  src: none,
  /// Co-emit sibling `.typ` plaintext source files (`/site.typ`, `/<route>.typ`) and render a top-right link (`true` uses `".typ"`, `false` disables, or pass custom label `str`).
  /// -> bool | str
  expose-source: true,
  /// Emit `404.html` (`true` emits a minimal root-relative 404 page, or pass custom `content`).
  /// -> bool | content
  not-found-page: true,
  /// Output path for the XML sitemap (`"sitemap.xml"`), or `none` to disable sitemap generation.
  /// -> str | none
  sitemap-path: "sitemap.xml",
  /// `robots.txt`. `path(...)` copies your file into the bundle root; `none` emits no file.
  /// -> path | none
  robots: none,
  /// `llms.txt`, a curated Markdown index for language models (`https://llmstxt.org`).
  /// `path(...)` copies your file into the bundle root; `none` emits no file.
  /// -> path | none
  llms: none,
  /// Output path for the RSS 2.0 feed (e.g. `"rss.xml"`), or `none` to omit RSS on non-blog sites.
  /// -> str | none
  rss-path: none,
  /// Output path for the Atom 1.0 feed (e.g. `"atom.xml"`), or `none` to omit Atom on non-blog sites.
  /// -> str | none
  atom-path: none,
  /// Feed payload mode (`"summary"` for compact descriptions or `"full"` for full semantic HTML).
  /// -> str
  feed-content: "summary",
  /// Optional RFC 4151 feed `<id>` minting date (`auto` derives from earliest post).
  /// -> auto | datetime
  feed-epoch: auto,
  /// Append `§` hover permalinks on section headings (`h2`–`h6`) across pages.
  /// -> bool
  heading-permalinks: false,
  /// Render compile-time backlinks footers across pages/posts by default.
  /// -> bool
  backlinks: false,
  /// Emit OpenGraph `<meta property="og:*">` tags across pages/posts by default.
  /// -> bool
  open-graph: false,
  /// Emit Google Scholar Highwire `<meta name="citation_*">` tags on articles by default.
  /// -> bool
  scholar-meta: false,
  /// Wrap the root `index.html` body inside `<main>` (`false` lets `body` emit `<header>`/`<main>`/`<footer>` directly, like `apex`).
  /// -> bool
  wrap-main: true,
  /// Additional `<head>` elements injected on `index.html`.
  /// -> content | none
  head: none,
  /// Extra preset-specific options forwarded when `preset != none` (and internal preset hooks).
  /// -> any
  ..extra,
  /// Root homepage markup and `#mount(path(...))` / `#file(...)` declarations.
  /// -> content
  body,
) = {
  let ext = extra.named()

  // Internal preset composition hooks (used by `blog.site` so bundle assembly lives in one place)
  let shell-hook = ext.at("_shell-fn", default: none)
  let not-found-hook = ext.at("_not-found-fn", default: none)
  let mount-card-hook = ext.at("_mount-card-fn", default: none)
  let default-route-hook = ext.at("_default-route-fn", default: none)
  let extra-docs-hook = ext.at("_extra-docs-fn", default: none)
  let feed-collection = ext.at("_feed-collection", default: none)
  let paged-fallback-hook = ext.at("_paged-fallback-fn", default: none)
  let default-title = ext.at("_default-title", default: [Site])

  let h1 = extract-first-h1(body)
  let resolved-title = if title != auto {
    title
  } else if h1 != none {
    h1
  } else {
    default-title
  }
  let emit-auto-h1 = (
    h1 == none and wrap-main and resolved-title != none and (title != auto or shell-hook != none)
  )
  let home-langs = resolve-page-langs(lang, default-lang: lang, scan-nodes: (
    resolved-title,
    description,
    body,
  ))
  let source-label = if expose-source == false or expose-source == none {
    none
  } else if expose-source == true {
    ".typ"
  } else {
    str(expose-source)
  }
  let site-typ-path = if type(src) == path { unwrap-typ-path(src) } else {
    none
  }
  let root-raw-source = if source-label != none and src != none {
    if type(src) == path { read(src) } else { str(src) }
  } else {
    none
  }

  // Normalize stylesheets (`path("styles.css")` or `(path: ..., data: ..., href?: ..., label?: ...)`)
  let norm-sheets = stylesheets.map(s => {
    if type(s) == path {
      let rel = relative-typ-path(unwrap-typ-path(s), site-path: site-typ-path)
      let out-p = if rel != none { rel } else { "styles.css" }
      (path: out-p, href: out-p, data: read(s, encoding: none), label: none)
    } else if type(s) == dictionary {
      let out-p = str(s.path).trim("/")
      (
        path: out-p,
        href: str(s.at("href", default: out-p)).trim("/"),
        data: if type(s.data) == path { read(s.data, encoding: none) } else {
          s.data
        },
        label: s.at("label", default: none),
      )
    } else {
      panic(
        "`stylesheets` entries must be `path(...)` or `(path: ..., data: ...)` dictionaries.",
      )
    }
  })
  let sheet-hrefs = norm-sheets.map(s => s.href)

  // Normalize optional favicon
  let norm-fav = if favicon == none {
    none
  } else if type(favicon) == path {
    let rel = relative-typ-path(
      unwrap-typ-path(favicon),
      site-path: site-typ-path,
    )
    let out-p = if rel != none { rel } else { "favicon.svg" }
    (
      path: out-p,
      data: read(favicon, encoding: none),
      mime: if out-p.ends-with(".svg") { "image/svg+xml" } else { none },
    )
  } else if type(favicon) == dictionary {
    let out-p = str(favicon.path).trim("/")
    (
      path: out-p,
      data: if type(favicon.data) == path {
        read(favicon.data, encoding: none)
      } else { favicon.data },
      mime: favicon.at("type", default: if out-p.ends-with(".svg") {
        "image/svg+xml"
      } else { none }),
    )
  } else {
    none
  }

  // `site()` emits the mounted pages and the built-in 404 itself, so it needs the same
  // resolved theme `webpage()` derives: a preset (e.g. `blog`) supplies it through
  // `_preset-config`, a plain core site keeps `theme-default`.
  let shell-theme = if ext.at("_preset-config", default: none) != none {
    ext.at("_preset-config").at("theme", default: theme-default)
  } else {
    theme-default
  }
  let site-config = (
    title: resolved-title,
    description: description,
    url: url,
    author: author,
    lang: lang,
    stylesheet-paths: sheet-hrefs,
    favicon-href: if norm-fav != none { norm-fav.path } else { none },
    favicon-type: if norm-fav != none { norm-fav.mime } else { none },
    source-label: source-label,
    rss-path: rss-path,
    atom-path: atom-path,
    sitemap-path: sitemap-path,
    heading-permalinks: heading-permalinks,
    backlinks: backlinks,
    open-graph: open-graph,
    scholar-meta: scholar-meta,
    // A preset (e.g. `blog`) contributes extra keys and its own top-bar styling.
    is-preset: ext.at("_preset-config", default: none) != none,
    ..ext.at("_preset-config", default: (:)),
  )
  [#metadata(site-config)<site-config>]

  let body-mounts = extract-mounts(body)
  let body-raw-files = extract-raw-files(body)
  let clean-home-body = transform-mounts(body, if mount-card-hook != none {
    mount-card-hook
  } else { _ => [] })

  context {
    let pre-mount-els = query(selector(metadata).before(here())).filter(el => (
      type(el.value) == dictionary and el.value.at("thyme-mounted", default: false)
    ))
    let pre-raw-els = query(selector(metadata).before(here())).filter(el => (
      type(el.value) == dictionary and el.value.at("thyme-raw-file", default: false)
    ))
    let all-mounts = (
      pre-mount-els.map(el => (
        el: el,
        val: el.value,
        lbl: el.at("label", default: none),
      ))
        + body-mounts
    ).map(rec => resolve-core-mount(
      rec,
      site-typ-path: site-typ-path,
      default-route-fn: default-route-hook,
    ))
    let all-raw-files = (
      pre-raw-els.map(el => (val: el.value, lbl: el.at("label", default: none))) + body-raw-files
    )

    // Build `<thyme-source-map>` mapping `doc-path -> sibling .typ asset path`
    let src-map = (:)
    if source-label != none {
      if root-raw-source != none {
        src-map.insert("index.html", source-path-for("index.html"))
      }
      for m in all-mounts {
        if m.raw-source != none {
          src-map.insert(m.path, source-path-for(m.path))
        }
      }
    }
    [#metadata(src-map)<thyme-source-map>]

    // `document()` and bundle assets only exist in the `bundle` target. In `html` mode
    // (single-page preview, `typst compile --format html`) fall back to rendering the
    // home page inline so the site still previews instead of disappearing.
    //
    // The inline shell builds `html.*` elements, so it must run only when the target is
    // `html`. `paged` is not `html`: `png`, `svg` and `pdf` output falls through to the
    // paged preview below, which needs no `html` module. Some embedders (notably the
    // Typst Universe package checker) compile with the HTML feature disabled, so an
    // `html.*` call in paged mode fails with `unknown variable: html`.
    let single-page = target() == "html"
    let home-src-href = if root-raw-source != none { "site.typ" } else { none }

    let home-doc-content = {
      emit-doc-marker("index.html", <site>)
      context {
        let site-docs = query(<site>)
        let home-doc = if site-docs.len() > 0 { site-docs.first() } else {
          none
        }
        let eff-home-langs = resolve-page-langs(
          lang,
          default-lang: lang,
          scan-nodes: (resolved-title, description, body),
          queried-codes: query-doc-tr-codes(home-doc),
        )
        assert-complete-translations(
          (resolved-title, description, body),
          eff-home-langs,
        )
        let home-inner = {
          show: with-html-headings.with(
            shift: if emit-auto-h1 { 1 } else { 0 },
            permalinks: heading-permalinks,
          )
          set text(lang: eff-home-langs.first())
          if emit-auto-h1 {
            html.h1(resolved-title)
          }
          clean-home-body
        }
        if shell-hook != none {
          shell-hook(
            title: resolved-title,
            site-title: resolved-title,
            description: description,
            author: author,
            site-url: url,
            doc-path: "index.html",
            langs: eff-home-langs,
            alternates: alternates,
            stylesheet-paths: sheet-hrefs,
            favicon-href: if norm-fav != none { norm-fav.path } else { none },
            favicon-type: if norm-fav != none { norm-fav.mime } else { none },
            source-href: home-src-href,
            source-label: source-label,
            include-feeds: true,
            rss-path: rss-path,
            atom-path: atom-path,
            open-graph: open-graph,
            extra-head: head,
            home-inner,
          )
        } else {
          render-core-shell(
            title: resolved-title,
            site-title: resolved-title,
            description: description,
            author: author,
            site-url: url,
            doc-path: "index.html",
            langs: eff-home-langs,
            alternates: alternates,
            stylesheet-paths: sheet-hrefs,
            favicon-href: if norm-fav != none { norm-fav.path } else { none },
            favicon-type: if norm-fav != none { norm-fav.mime } else { none },
            source-href: home-src-href,
            source-label: source-label,
            include-feeds: true,
            rss-path: rss-path,
            atom-path: atom-path,
            open-graph: open-graph,
            extra-head: head,
            wrap-main: wrap-main,
            theme-config: if site-config != none {
              site-config.at("theme", default: theme-default)
            } else { theme-default },
            home-inner,
          )
        }
      }
    }

    if (
      target() == "bundle" and not-found-page != false and not-found-page != none
    ) {
      [#document(
        "404.html",
        title: [404],
        {
          emit-doc-marker("404.html", <thyme-not-found>)
          if type(not-found-page) == content {
            // A user-supplied body is not a document, so it gets no `<head>` of its own;
            // wrap it so it still carries the stylesheet, meta and `theme-color` tags.
            render-core-shell(
              title: "404",
              site-title: resolved-title,
              doc-path: "404.html",
              langs: home-langs,
              stylesheet-paths: sheet-hrefs,
              favicon-href: if norm-fav != none { norm-fav.path } else { none },
              favicon-type: if norm-fav != none { norm-fav.mime } else { none },
              wrap-main: true,
              theme-config: shell-theme,
              not-found-page,
            )
          } else if not-found-hook != none {
            not-found-hook(resolved-title, home-langs.first(), sheet-hrefs)
          } else {
            html.html(lang: home-langs.first(), {
              html.head({
                html.meta(charset: "utf-8")
                html.meta(
                  name: "viewport",
                  content: "width=device-width, initial-scale=1",
                )
                html.meta(name: "robots", content: "noindex")
                html.title(
                  "404 - " + to-plain-text(resolved-title, lang: home-langs.first()),
                )
                html.meta(
                  name: "theme-color",
                  content: css-hex(shell-theme.paper-light),
                  media: "(prefers-color-scheme: light)",
                )
                html.meta(
                  name: "theme-color",
                  content: css-hex(shell-theme.paper-dark),
                  media: "(prefers-color-scheme: dark)",
                )
                for css-p in sheet-hrefs {
                  html.link(rel: "stylesheet", href: "/" + str(css-p).trim("/"))
                }
              })
              html.body({
                html.main(class: "notfound", {
                  html.elem(
                    "nav",
                    attrs: (
                      class: "back-home",
                      "aria-label": "Site navigation",
                    ),
                    html.a(href: "/", "/.."),
                  )
                  html.h1("404")
                  html.p("No such page.")
                })
              })
            })
          }
        },
      )<thyme-not-found>]
    }

    // Mounted pages become extra bundle documents. In single-page (`html`) mode they
    // are already inlined into the home body by `mount-card-hook` / the paged
    // fallback, and the html target can only carry one `<html>` root anyway.
    for m in (if target() == "bundle" { all-mounts } else { () }) {
      let doc-body = {
        emit-doc-marker(m.path, m.label)
        if m.is-wrapped {
          m.body
        } else {
          context {
            let src-href = if source-label != none and m.raw-source != none {
              rel-href(m.path, source-path-for(m.path))
            } else {
              none
            }
            render-core-shell(
              title: m.title,
              site-title: resolved-title,
              author: author,
              site-url: url,
              doc-path: m.path,
              langs: resolve-page-langs(auto, default-lang: lang, scan-nodes: (
                m.body,
              )),
              stylesheet-paths: sheet-hrefs,
              include-core-topbar-css: shell-hook == none,
              favicon-href: if norm-fav != none { norm-fav.path } else { none },
              favicon-type: if norm-fav != none { norm-fav.mime } else { none },
              source-href: src-href,
              source-label: source-label,
              back-content: html.a(
                href: rel-root(m.path) + "index.html",
                "/..",
              ),
              open-graph: open-graph,
              theme-config: shell-theme,
              {
                show: with-html-headings.with(
                  shift: 0,
                  permalinks: heading-permalinks,
                )
                m.body
              },
            )
          }
        }
      }
      [#document(m.path, title: m.title, doc-body)#m.label]
      for pa in m.assets {
        emit-bundle-asset(join-path(m.dir, pa.path), pa.data, lbl: pa.at(
          "label",
          default: none,
        ))
      }
    }

    // Preset-generated extra documents (tag archives, `pages:`) are bundle-only.
    if target() == "bundle" and extra-docs-hook != none {
      extra-docs-hook(
        all-mounts: all-mounts,
        resolved-title: resolved-title,
        site-url: url,
        author: author,
        default-lang: home-langs.first(),
        sheet-hrefs: sheet-hrefs,
        favicon-href: if norm-fav != none { norm-fav.path } else { none },
        favicon-type: if norm-fav != none { norm-fav.mime } else { none },
      )
    }

    if target() == "bundle" {
      for s in norm-sheets {
        emit-bundle-asset(s.path, s.data, lbl: s.label)
      }
      if norm-fav != none {
        emit-bundle-asset(norm-fav.path, norm-fav.data)
      }

      let explicit-paths = (
        assets.map(a => str(a.path).trim("/")) + all-raw-files.map(r => r.val.path)
      )
      for a in assets {
        emit-bundle-asset(str(a.path).trim("/"), a.data, lbl: a.at(
          "label",
          default: none,
        ))
      }
      for r in all-raw-files {
        emit-bundle-asset(r.val.path, r.val.data, lbl: r.lbl)
      }

      if root-raw-source != none {
        emit-bundle-asset("site.typ", root-raw-source, lbl: <source>)
      }
      for m in all-mounts {
        if source-label != none and m.raw-source != none {
          emit-bundle-asset(source-path-for(m.path), m.raw-source)
        }
      }
    }

    // Emit the home page: a `<document>` in bundle mode, an inline shell otherwise.
    if target() == "bundle" {
      [#document("index.html", title: resolved-title, home-doc-content)<site>]
    } else if single-page {
      [#metadata(none)<site>]
      home-doc-content
    } else if paged-fallback-hook != none {
      // `png` / `svg` / `pdf` targets: render the paged preview of the site body.
      paged-fallback-hook(
        all-mounts,
        pre-mount-els,
        home-langs.first(),
        emit-auto-h1,
        resolved-title,
        clean-home-body,
      )
    } else {
      set text(lang: home-langs.first())
      show: with-smart-refs
      if emit-auto-h1 {
        heading(level: 1, resolved-title)
      }
      clean-home-body
    }
  }

  // Emit `sitemap.xml` (`<sitemap>`), `rss.xml` (`<rss>`), and `atom.xml` (`<atom>`)
  context {
    if target() == "bundle" {
      let public-pages = query-pages()
      let feed-entries = if feed-collection != none {
        query-pages(collection: feed-collection)
      } else {
        public-pages
      }
      let bundle-label-urls = {
        let m = (:)
        for d in query(document) {
          if d.has("label") and d.path != none {
            m.insert(str(d.label), canonical-page-url(url, d.path))
          }
        }
        for a in query(asset) {
          if a.has("label") and a.path != none {
            m.insert(str(a.label), canonical-page-url(url, a.path))
          }
        }
        m
      }
      if sitemap-path != none {
        let sm-xml = sitemap-xml(
          site-url: url,
          entries: public-pages,
          root-alternates: alternates,
        )
        [#asset(sitemap-path, bytes(sm-xml))<sitemap>]
      }
      // Both files are the author's. They have formats this package would only guess at,
      // so nothing is generated: a `path` is copied, byte for byte, and `none` emits
      // nothing. `robots-txt(...)` is exported for an author who wants a starting point.
      if type(robots) == path {
        [#asset("robots.txt", read(robots, encoding: none))<robots>]
      }
      if type(llms) == path {
        [#asset("llms.txt", read(llms, encoding: none))<llms>]
      }
      if rss-path != none {
        let rss-xml = rss-xml(
          site-title: resolved-title,
          site-subtitle: description,
          site-url: url,
          language: home-langs.first(),
          rss-path: rss-path,
          feed-content: feed-content,
          label-urls: bundle-label-urls,
          posts: feed-entries,
        )
        [#asset(rss-path, bytes(rss-xml))<rss>]
      }
      if atom-path != none {
        let atom-xml = atom-xml(
          site-title: resolved-title,
          site-subtitle: description,
          site-url: url,
          author: author,
          atom-path: atom-path,
          feed-content: feed-content,
          feed-epoch: feed-epoch,
          label-urls: bundle-label-urls,
          posts: feed-entries,
        )
        [#asset(atom-path, bytes(atom-xml))<atom>]
      }
    }
  }
}
