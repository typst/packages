// Capability-carrying `path(...)` inspection, route/URL manipulation, Tadi `.typ`
// source path mapping, date formatting, deduplicated HTML heading anchors, O(1)
// document boundary markers, compile-time backlink graph tracking, and universal
// cross-bundle `@label` routing.

#import "text.typ": to-plain-text

/// Safely resolve a `length` or `relative` length to an absolute `length`.
/// -> length
#let resolve-abs-length(
  /// Length value (`length`, `relative`, `auto`, or `none`).
  /// -> length | relative | auto | none
  val,
  /// Fallback length when `val` is `auto` or `none`.
  /// -> length
  fallback: 0pt,
) = {
  if val == auto or val == none {
    fallback
  } else if type(val) == length {
    val.to-absolute()
  } else if type(val) == relative {
    val.length.to-absolute()
  } else {
    fallback
  }
}

/// Convert a string or content value into a URL-safe kebab-case slug.
/// -> str
#let slugify(
  /// Title or identifier to slugify.
  /// -> content | str
  input,
) = {
  lower(to-plain-text(input)).replace(regex("[^a-z0-9]+"), "-").trim("-")
}

/// Humanize a kebab-case slug or label name for fallback link display.
/// -> str
#let humanize-slug(s) = {
  str(s).replace("-", " ").replace("_", " ")
}

/// Join path segments with single `/` separators and no leading or trailing slash.
/// -> str
#let join-path(..parts) = {
  let segs = parts.pos().map(p => str(p).trim("/")).filter(p => p.len() > 0)
  if segs.len() > 0 { segs.join("/") } else { "" }
}

/// Extract the normalized project-root path string from a Typst `0.15` `path(...)` value
/// (e.g. `path("posts/impli.typ")` -> `"posts/impli.typ"`), unescaping string escapes.
/// -> str | none
#let unwrap-typ-path(p) = {
  if type(p) != path {
    return none
  }
  let r = repr(p).trim()
  if r.starts-with("path(\"") and r.ends-with("\")") {
    let inner = r.slice(6, r.len() - 2).replace("\\\"", "\"").replace("\\\\", "\\").trim("/")
    if inner.starts-with("./") { inner.slice(2) } else { inner }
  } else {
    none
  }
}

/// Derive a URL slug from a `.typ` source path (`"posts/impli.typ"` -> `"impli"`,
/// `"posts/gol/index.typ"` -> `"gol"`).
/// -> str | none
#let slug-from-typ-path(raw-path) = {
  if raw-path == none {
    return none
  }
  let parts = str(raw-path).trim("/").split("/").filter(s => s.len() > 0)
  if parts.len() == 0 {
    return none
  }
  let last = parts.last()
  if last == "site.typ" and parts.len() >= 2 {
    parts.at(parts.len() - 2)
  } else if last.ends-with(".typ") {
    last.slice(0, last.len() - 4)
  } else {
    last
  }
}

/// Strip the directory prefix of `site-src` (`path("site.typ")`) from a mounted
/// `.typ` path so routes stay relative to the site root even when compiled from a parent `--root`.
/// -> str | none
#let relative-typ-path(file-path, site-path: none) = {
  if file-path == none {
    return none
  }
  let clean = str(file-path).trim("/")
  if site-path != none {
    let site-dir = {
      let sp = str(site-path).trim("/").split("/")
      if sp.len() <= 1 { "" } else { sp.slice(0, sp.len() - 1).join("/") + "/" }
    }
    if site-dir != "" and clean.starts-with(site-dir) {
      return clean.slice(site-dir.len())
    }
  }
  clean
}

/// Canonical bundle HTML output path for a post (`posts/<slug>/index.html` by default).
/// -> str
#let post-html-path(slug, posts-dir: "posts") = {
  join-path(posts-dir, slug, "index.html")
}

/// Convert a relative `.typ` page path into its canonical bundle HTML path
/// (`"contact.typ"` -> `"contact/index.html"`, `"docs/intro/index.typ"` -> `"docs/intro/index.html"`).
/// -> str
#let route-html-path(rel-typ) = {
  let clean = str(rel-typ).trim("/")
  if clean == "index.typ" {
    "index.html"
  } else if clean.ends-with("/site.typ") {
    clean.slice(0, clean.len() - "/site.typ".len()) + "/index.html"
  } else if clean.ends-with(".typ") {
    clean.slice(0, clean.len() - 4) + "/index.html"
  } else if clean.ends-with(".html") {
    clean
  } else {
    join-path(clean, "index.html")
  }
}

/// Compute the sibling Tadi Web `.typ` bundle path for any HTML document path:
/// - `"index.html"` -> `"site.typ"`
/// - `"posts/impli/index.html"` -> `"posts/impli.typ"`
/// - `"contact/index.html"` -> `"contact.typ"`
/// -> str
#let source-path-for(
  /// Bundle HTML document path.
  /// -> str
  doc-path,
) = {
  let clean = str(doc-path).trim("/")
  if clean == "index.html" {
    "site.typ"
  } else if clean.ends-with("/index.html") {
    clean.slice(0, clean.len() - "/index.html".len()) + ".typ"
  } else if clean.ends-with(".html") {
    clean.slice(0, clean.len() - 5) + ".typ"
  } else {
    clean + ".typ"
  }
}

/// Return the parent directory of a bundle document path (e.g. `"posts/gol"`).
/// -> str
#let parent-dir(doc-path) = {
  if doc-path == none {
    return ""
  }
  let parts = str(doc-path).trim("/").split("/")
  if parts.len() <= 1 {
    ""
  } else {
    parts.slice(0, parts.len() - 1).join("/")
  }
}

/// Derive a page/post slug from its bundle HTML document path (`"posts/foo/index.html"` -> `"foo"`).
/// -> str | none
#let slug-from-path(doc-path) = {
  if doc-path == none {
    return none
  }
  let parts = str(doc-path).trim("/").split("/")
  let last = parts.last()
  if last == "index.html" and parts.len() >= 2 {
    parts.at(parts.len() - 2)
  } else if last == "index.html" {
    "index"
  } else if last.ends-with(".html") {
    last.slice(0, last.len() - 5)
  } else {
    last
  }
}

/// Compute the relative root prefix (`""`, `"../"`, `"../../"`) for a bundle HTML path.
/// -> str
#let rel-root(doc-path) = {
  if doc-path == none {
    return ""
  }
  let parts = str(doc-path).trim("/").split("/")
  if parts.len() <= 1 {
    ""
  } else {
    "../" * (parts.len() - 1)
  }
}

/// Compute a clean relative href from a bundle HTML document (`from-doc`) to another bundle file (`to-path`).
/// -> str
#let rel-href(from-doc, to-path) = {
  if from-doc == none {
    return str(to-path).trim("/")
  }
  let from-dir = parent-dir(from-doc)
  let from-parts = if from-dir == "" { () } else { from-dir.split("/") }
  let to-parts = str(to-path).trim("/").split("/").filter(s => s.len() > 0)
  let common = 0
  while (
    common < from-parts.len() and common < to-parts.len() - 1 and from-parts.at(common) == to-parts.at(common)
  ) {
    common += 1
  }
  let ups = "../" * (from-parts.len() - common)
  let tail = to-parts.slice(common)
  ups + (if tail.len() > 0 { tail.join("/") } else { "" })
}

/// Convert a canonical origin URL + bundle HTML path into a clean public URL
/// (`"posts/foo/index.html"` -> `"https://example.com/posts/foo/"`).
/// -> str
#let canonical-page-url(site-url, doc-path) = {
  let base = str(site-url).trim("/", at: end)
  let raw-str = if doc-path == none { "index.html" } else {
    str(doc-path).trim()
  }
  let had-trailing = raw-str.ends-with("/")
  let clean = raw-str.trim("/")
  if clean == "" or clean == "index.html" {
    base + "/"
  } else if clean.ends-with("/index.html") {
    base + "/" + clean.slice(0, clean.len() - "index.html".len())
  } else if had-trailing {
    base + "/" + clean + "/"
  } else {
    base + "/" + clean
  }
}

/// Extract domain authority from an HTTP(S) URL (`"https://blog.example.org/foo"` -> `"blog.example.org"`).
/// -> str
#let url-authority(url) = {
  let clean = str(url).replace(regex("^https?://"), "")
  clean.split("/").first().split(":").first()
}

/// Format a `datetime` or string into ISO `YYYY-MM-DD`.
/// -> str | none
#let format-date(d, fmt: "[year]-[month]-[day]") = {
  if d == none {
    none
  } else if type(d) == datetime {
    d.display(fmt)
  } else {
    to-plain-text(d)
  }
}

/// Sort key for dates (ascending ISO timestamp; reverse for newest-first).
/// -> str
#let date-sort-key(d) = {
  if type(d) == datetime {
    let norm = if d.hour() == none {
      datetime(
        year: d.year(),
        month: d.month(),
        day: d.day(),
        hour: 0,
        minute: 0,
        second: 0,
      )
    } else {
      d
    }
    norm.display("[year]-[month]-[day]T[hour]:[minute]:[second]")
  } else if d != none {
    to-plain-text(d)
  } else {
    "0000-00-00T00:00:00"
  }
}

/// Emit a zero-footprint `<thyme-doc-marker>` at the start of every bundle `document(...)`
/// so enclosing-document lookup runs in $O(1)$ without cross-document `<thyme-page-meta>` bleed.
/// -> content
#let emit-doc-marker(doc-path, doc-label) = [#metadata((
  path: doc-path,
  doc-label: doc-label,
))<thyme-doc-marker>]

/// Find the enclosing `document` element for an arbitrary location in $O(1)$ inside `context`.
/// -> content | none
#let find-doc-containing(loc) = {
  let markers = query(selector(<thyme-doc-marker>).before(loc))
  if markers.len() > 0 {
    let dlbl = markers.last().value.doc-label
    if dlbl != none {
      let candidates = query(dlbl).filter(el => repr(el.func()) == "document")
      if candidates.len() > 0 {
        return candidates.first()
      }
    }
  }
  for d in query(document) {
    if query(selector(<thyme-page-meta>).within(d.location())).any(m => (
      m.location() == loc
    )) {
      return d
    }
  }
  none
}

/// Find the enclosing `document` element in bundle mode for a metadata or body location.
/// -> content | none
#let find-enclosing-doc(
  meta-loc,
  meta-label: <thyme-page-meta>,
) = find-doc-containing(meta-loc)

/// Resolve a `<label>` across the bundle, preferring emitted `document` / `asset` / `heading`
/// targets over mount-marker `metadata` nodes, while falling back to mounted-page
/// `metadata` in paged preview mode so `@slug` still displays the target's real title.
/// -> content | none
#let resolve-bundle-label(lbl) = {
  let all = query(lbl)
  let non-meta = all.filter(el => el.func() != metadata)
  if non-meta.len() > 0 {
    return non-meta.first()
  }
  let mount-meta = all.filter(el => (
    el.func() == metadata
      and type(el.value) == dictionary
      and (
        el.value.at("thyme-mounted", default: false) or el.value.at("thyme-paged-ref", default: false)
      )
  ))
  if mount-meta.len() > 0 {
    return mount-meta.first()
  }
  none
}

/// Look up `<thyme-page-meta>` inside a `document` element if present.
/// -> dictionary | none
#let doc-page-meta(doc-el) = {
  let metas = query(selector(<thyme-page-meta>).within(doc-el.location()))
  if metas.len() > 0 {
    metas.first().value
  } else {
    none
  }
}

#let _base-heading-slug(it, auto-slug: true) = {
  if it.has("label") {
    str(it.label)
  } else if auto-slug {
    let s = slugify(it.body)
    if s != "" { s } else { "section" }
  } else {
    none
  }
}

/// Derive a deterministic, collision-free HTML `id` attribute for a `heading` element
/// (`str(it.label)` when explicitly labeled, otherwise `slugify(it.body)` with `"section"`
/// fallback and `-2`, `-3`, ... suffixing across `prior-headings` in the same document).
/// -> str | none
#let heading-anchor-id(
  /// Target `heading` element.
  /// -> content
  it,
  /// Generate an automatic slug when `it` has no explicit `<label>`.
  /// -> bool
  auto-slug: true,
  /// Prior `heading` elements within the same document used to deduplicate identical slugs.
  /// -> array
  prior-headings: (),
) = {
  let base = _base-heading-slug(it, auto-slug: auto-slug)
  if base == none or it.has("label") or prior-headings.len() == 0 {
    return base
  }
  let used = ()
  let it-loc = it.location()
  for ph in prior-headings {
    // Callers derive `prior-headings` with `before(here())`, and Typst's
    // `before` is inclusive: the heading being processed is itself in the
    // list. Skipping it keeps that heading from being treated as a duplicate
    // of itself, which otherwise suffixed every auto-slugged heading with -2.
    // Detached headings (not placed in a document) have no location; two of
    // those compare equal as `none`, so only compare real locations.
    let ph-loc = ph.location()
    if it-loc != none and ph-loc != none and ph-loc == it-loc {
      continue
    }
    let pb = _base-heading-slug(ph, auto-slug: true)
    if pb == none {
      continue
    } else if ph.has("label") {
      used.push(pb)
    } else {
      let cand = pb
      let k = 2
      while cand in used {
        cand = pb + "-" + str(k)
        k += 1
      }
      used.push(cand)
    }
  }
  let cand = base
  let k = 2
  while cand in used {
    cand = base + "-" + str(k)
    k += 1
  }
  cand
}

/// Install HTML heading rules mapping Typst headings (`level: 1..6`) to `<h1>`..`<h6>`
/// (with optional `+1` level `shift` when `<header><h1>` already renders the page title),
/// preserving collision-free `id` attributes for `#anchor` links and optional `§` permalinks.
/// -> content
#let with-html-headings(
  shift: 0,
  permalinks: false,
  permalink-symbol: "§",
  body,
) = context {
  if target() != "html" {
    return body
  }
  let html-dict = dictionary(html)
  show heading: it => context {
    let eff-level = calc.min(6, calc.max(1, it.level + shift))
    let prior = if not it.has("label") and eff-level >= 2 {
      let markers = query(selector(<thyme-doc-marker>).before(it.location()))
      let priors = if markers.len() > 0 {
        query(
          selector(heading).after(markers.last().location()).before(it.location()),
        )
      } else {
        query(selector(heading).before(it.location()))
      }
      priors.filter(ph => calc.min(6, calc.max(1, ph.level + shift)) >= 2)
    } else {
      ()
    }
    let hid = heading-anchor-id(
      it,
      auto-slug: eff-level >= 2,
      prior-headings: prior,
    )
    let tag-fn = html-dict.at("h" + str(eff-level))
    let inner = if permalinks and eff-level >= 2 and hid != none {
      (
        it.body
          + html.a(
            href: "#" + hid,
            class: "heading-anchor",
            ..("aria-label": "Permalink to this section"),
            permalink-symbol,
          )
      )
    } else {
      it.body
    }
    if hid != none {
      tag-fn(id: hid, inner)
    } else {
      tag-fn(inner)
    }
  }
  body
}

/// Install universal cross-bundle `link` and `ref` (`@tag` / `<tag>`) rules,
/// recording outbound page references (`<thyme-outbound-ref>`) for compile-time backlinks
/// and scoping bibliography checks to the current document.
/// -> content
#let with-smart-refs(
  ink: luma(18%),
  muted: luma(52%),
  body,
) = {
  show link: it => {
    if type(it.dest) == label {
      let el = resolve-bundle-label(it.dest)
      if el != none {
        [#metadata((target: str(it.dest)))<thyme-outbound-ref>]
        link(el.location(), it.body)
      } else {
        it.body
      }
    } else {
      it
    }
  }

  show ref: it => {
    // Only emitted `document`/`asset` elements produce a real anchor. A mount marker
    // (`#post(...)`) is plain `metadata` and cannot be linked in HTML mode, so fall
    // back to unlinked text instead of failing with "failed to determine link anchor".
    let el = resolve-bundle-label(it.target)
    if el != none and el.func() == metadata and target() != "bundle" {
      el = none
    }
    let custom-text = if it.supplement != auto and it.supplement != none {
      it.supplement
    } else {
      none
    }

    if el != none {
      let func = el.func()
      let func-name = repr(func)
      if func-name == "document" or func-name == "asset" {
        [#metadata((target: str(it.target)))<thyme-outbound-ref>]
        let label-text = if custom-text != none {
          custom-text
        } else if func-name == "document" {
          let pm = doc-page-meta(el)
          if pm != none and pm.title != none {
            pm.title
          } else if el.title != none {
            el.title
          } else {
            humanize-slug(it.target)
          }
        } else {
          humanize-slug(it.target)
        }
        link(el.location(), label-text)
      } else if (
        func == metadata
          and type(el.value) == dictionary
          and (
            el.value.at("thyme-mounted", default: false) or el.value.at("thyme-paged-ref", default: false)
          )
      ) {
        [#metadata((target: str(it.target)))<thyme-outbound-ref>]
        let pm = el.value.at("meta", default: none)
        let label-text = if custom-text != none {
          custom-text
        } else if pm != none and pm.at("title", default: none) != none {
          pm.title
        } else {
          humanize-slug(it.target)
        }
        // Bundle mode: the mounted page's own `<document>` carries this label, so the
        // marker's location resolves to that anchor.
        link(el.location(), label-text)
      } else if func == heading and el.numbering == none {
        let label-text = if custom-text != none {
          custom-text
        } else {
          el.body
        }
        link(el.location(), label-text)
      } else {
        it
      }
    } else {
      let enc-doc = find-doc-containing(here())
      let has-local-bib = if enc-doc != none {
        query(selector(bibliography).within(enc-doc.location())).len() > 0
      } else {
        query(bibliography).len() > 0
      }
      if not has-local-bib {
        let fallback = if custom-text != none {
          custom-text
        } else {
          humanize-slug(it.target)
        }
        if target() == "html" {
          html.span(
            class: "thyme-unresolved-ref",
            title: "@" + str(it.target),
            fallback,
          )
        } else {
          underline(
            stroke: (paint: muted, thickness: 0.6pt, dash: "dashed"),
            offset: 2pt,
            text(fill: ink, fallback),
          )
        }
      } else {
        it
      }
    }
  }

  body
}

/// Query all public (non-draft, non-unlisted) pages/posts in the bundle that reference
/// `target-slug` via `@slug` or `link(<slug>)`, sorted newest-first.
/// Must be called inside `context`.
/// -> array
#let query-backlinks(
  /// Target page/post slug or label name (e.g. `"rabbit-holes"`).
  /// -> str
  target-slug,
  /// Optional current document path to exclude self-references.
  /// -> str | none
  exclude-doc-path: none,
) = {
  let clean-target = str(target-slug)
  let clean-excl = if exclude-doc-path != none {
    str(exclude-doc-path).trim("/")
  } else { none }
  let hits = ()
  for d in query(document) {
    let dp = if d.path != none { str(d.path).trim("/") } else { "" }
    if (
      dp.ends-with(".html") and dp != "404.html" and dp != "index.html" and dp != clean-excl
    ) {
      let metas = query(selector(<thyme-page-meta>).within(d.location()))
      if metas.len() > 0 {
        let m = metas.first().value
        if (
          not m.at("draft", default: false) and not m.at("unlisted", default: false)
        ) {
          let refs = query(selector(<thyme-outbound-ref>).within(d.location()))
          if refs.any(r => r.value.target == clean-target) {
            let derived-slug = if m.slug != none { m.slug } else {
              slug-from-path(dp)
            }
            hits.push((
              ..m,
              slug: derived-slug,
              doc-loc: d.location(),
              doc-path: dp,
              html-path: dp,
            ))
          }
        }
      }
    }
  }
  hits.sorted(key: p => p.sort-key).rev()
}
