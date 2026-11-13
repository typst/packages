// Zero-JavaScript CSS language switching (`#tr(en: [...], de: [...])` or
// `@preview/linguify`-compatible `lang.toml` lookup `#tr("key", from: toml("lang.toml"))`),
// multi-route `hreflang` alternate link helpers, keyboard-accessible radio state inputs,
// and top-bar switcher labels.

#import "paths.typ": canonical-page-url
#import "text.typ": _tr-nonprimary-depth, to-plain-text
#import "tree.typ": any-content, collect-content

#let _block-funcs = (
  par,
  parbreak,
  heading,
  list.item,
  enum.item,
  terms.item,
  table,
  grid,
  block,
  quote,
  figure,
)

// Detect whether a Typst content value contains block-level elements so `#tr(...)`
// chooses `html.div` vs `html.span` automatically.
#let _has-block-content(c) = any-content(c, n => (
  n.func() in _block-funcs or (n.func() == raw and n.at("block", default: false))
))

// Resolve a nested dotted key (`"nav.contact"` or `"abstract"`) inside a dictionary.
#let _lookup-dict-key(dict, key) = {
  if type(dict) != dictionary {
    return none
  }
  if key in dict {
    return dict.at(key)
  }
  let cur = dict
  for part in str(key).split(".") {
    if type(cur) == dictionary and part in cur {
      cur = cur.at(part)
    } else {
      return none
    }
  }
  cur
}

// Extract `(code: value)` entries from a `@preview/linguify`-compatible database
// (`[conf] default-lang = "en"` + `[lang.en]` / `[lang.de]`, or a flat `(en: (...), de: (...))` dict).
#let _entries-from-db(db, key) = {
  if type(db) != dictionary {
    panic(
      "`tr(..., from: db)` expects a dictionary (e.g. `toml(\"lang.toml\")`).",
    )
  }
  let lang-table = if "lang" in db and type(db.lang) == dictionary {
    db.lang
  } else {
    db
  }
  let default-code = if "conf" in db and type(db.conf) == dictionary {
    db.conf.at("default-lang", default: none)
  } else {
    none
  }
  let ordered-codes = ()
  if default-code != none and str(default-code) in lang-table {
    ordered-codes.push(str(default-code))
  }
  for k in lang-table.keys() {
    if k != "conf" and k not in ordered-codes {
      ordered-codes.push(k)
    }
  }
  let out = (:)
  for code in ordered-codes {
    let val = _lookup-dict-key(lang-table.at(code), key)
    if val != none {
      out.insert(code, if type(val) == content { val } else { [#str(val)] })
    }
  }
  out
}

/// Normalize a `lang` configuration (`"en"`, `("en", "de")`, or `auto`) plus any
/// `#tr(...)` language codes discovered in a page's content tree into a deduplicated
/// array of BCP-47 language strings (primary language first).
/// -> array
#let resolve-page-langs(
  /// Explicit page `lang` (`auto`, `"en"`, or `("en", "de")`).
  /// -> auto | str | array
  lang,
  /// Fallback primary language from `site.with(lang: ...)`.
  /// -> str | array
  default-lang: "en",
  /// Content nodes to scan for `#tr(...)` blocks when `lang == auto`.
  /// -> array
  scan-nodes: (),
  /// Additional language codes discovered via `query(<thyme-tr-meta>)` inside `context`.
  /// -> array
  queried-codes: (),
) = {
  let base-default = if type(default-lang) == array {
    if default-lang.len() > 0 { str(default-lang.first()) } else { "en" }
  } else {
    str(default-lang)
  }

  let collect-tr-codes(c) = collect-content(c, n => (
    if n.func() == metadata and type(n.value) == dictionary and n.value.at("thyme-tr", default: false) {
      n.value.entries.keys()
    } else {
      ()
    }
  ))

  let discovered = (
    scan-nodes.fold((), (acc, n) => acc + collect-tr-codes(n)) + queried-codes
  )

  let raw-list = if lang == auto or lang == none {
    if discovered.len() > 0 { discovered } else { (base-default,) }
  } else if type(lang) == str {
    (lang,) + discovered
  } else if type(lang) == array {
    lang.map(str) + discovered
  } else {
    (base-default,)
  }

  let uniq = ()
  for code in raw-list {
    let s = str(code).trim()
    if s != "" and s not in uniq {
      uniq.push(s)
    }
  }
  if uniq.len() == 0 { (base-default,) } else { uniq }
}

/// Normalize `alternates` (`("de": "/de/about/", "en": "/about/")` or
/// `((hreflang: "de", href: "..."),)`) into canonical `(hreflang: str, href: str)` records
/// for `<link rel="alternate" hreflang="...">` and `sitemap.xml` `xhtml:link`.
/// -> array
#let normalize-alternates(
  /// Dictionary (`(de: "de/contact/index.html")`) or array of `(hreflang: ..., href: ...)` records.
  /// -> dictionary | array | none
  alternates,
  /// Optional site origin URL used to expand relative bundle paths into absolute URLs.
  /// -> str | none
  site-url: none,
) = {
  if alternates == none or alternates == () or alternates == (:) {
    return ()
  }
  let resolve-href(h) = {
    let s = str(h).trim()
    if (
      s.starts-with("http://") or s.starts-with("https://") or site-url == none
    ) {
      s
    } else {
      canonical-page-url(site-url, s)
    }
  }
  if type(alternates) == dictionary {
    alternates.pairs().map(((code, h)) => (hreflang: str(code), href: resolve-href(h)))
  } else if type(alternates) == array {
    alternates.map(a => (
      hreflang: str(a.at("hreflang", default: a.at(
        "lang",
        default: "x-default",
      ))),
      href: resolve-href(a.at("href")),
    ))
  } else {
    panic(
      "`alternates` expects a dictionary or an array of `(hreflang: ..., href: ...)` records.",
    )
  }
}

/// Report every `#tr(...)` block whose entries do not cover all of `langs`.
///
/// A page-level guard, called from `site` and `blog.post` once the page's language set is
/// known. Content is scanned for the `#thyme-tr-meta` metadata that `tr` emits, so a block
/// that is missing a language is found even when it sits deep inside a post body.
///
/// Returns an array of human-readable messages, so a caller can decide whether to panic or
/// only warn. An empty array means every block covers every language.
/// -> array
#let missing-translations(
  /// Content nodes to scan, usually the page body.
  /// -> array
  nodes,
  /// Language codes the page declares (e.g. `("en", "de", "fr")`).
  /// -> array
  langs,
) = {
  if langs.len() < 2 {
    return ()
  }
  let wanted = langs.map(l => str(l).trim()).filter(l => l != "")
  if wanted.len() < 2 {
    return ()
  }
  // `collect-content` walks one content value, so unwrap an array of them first.
  let roots = if type(nodes) == array { nodes } else { (nodes,) }
  let found = roots.fold((), (acc, root) => (
    acc
      + collect-content(
        root,
        n => {
          if not (
            n.func() == metadata and type(n.value) == dictionary and n.value.at("thyme-tr", default: false)
          ) {
            return ()
          }
          let have = n.value.entries.keys().map(k => str(k).trim())
          let absent = wanted.filter(l => l not in have)
          if absent.len() == 0 {
            return ()
          }
          // Use the first entry as a stand-in for the block's position in the text. It tells a
          // reader which block to look for without dumping the whole content value.
          let first-entry = n.value.entries.pairs().first()
          let sample = to-plain-text(first-entry.at(1)).trim()
          if sample.len() > 40 {
            sample = sample.slice(0, 40) + "..."
          }
          (
            (
              "`#tr(...)` block is missing "
                + absent.map(l => "`" + l + "`").join(", ")
                + " (page declares "
                + wanted.map(l => "`" + l + "`").join(", ")
                + "; block text: \""
                + sample
                + "\")"
            ),
          )
        },
      )
  ))
  found
}

/// Panic unless every `#tr(...)` block in `nodes` has an entry for each language in `langs`.
///
/// A page with two languages shows a missing translation as an obvious gap. A page with six
/// shows four empty strings in the middle of a long post, which is easy to ship. This turns
/// that silence into a compile error. Call it once the page's language set is resolved.
#let assert-complete-translations(
  /// Content nodes to scan, usually the page body.
  /// -> array
  nodes,
  /// Language codes the page declares (e.g. `("en", "de", "fr")`).
  /// -> array
  langs,
) = {
  let gaps = missing-translations(nodes, langs)
  if gaps.len() > 0 {
    panic(
      "incomplete translations:\n  "
        + gaps.join("\n  ")
        + "\nEvery `#tr(...)` block on a page must cover "
        + langs.map(l => "`" + l + "`").join(", ")
        + ". Add the missing branches, or remove the language from the page's `lang`.",
    )
  }
}

/// Declare inline or block multilingual content (`#tr(en: [Hello], de: [Grüezi])`), or
/// look up all translations for a key from a `@preview/linguify`-compatible `lang.toml`
/// dictionary (`#tr("abstract", from: toml("lang.toml"))`).
///
/// Inside each branch, `text.lang` is set to that branch's BCP-47 language code so both
/// Typst's native localized smartquotes/supplements and `@preview/linguify` calls resolve
/// per branch automatically. In HTML export, emits `<span class="thyme-tr" lang="...">`
/// (or `<div class="thyme-tr" lang="...">` when containing block elements) toggled at zero
/// runtime cost via keyboard-accessible CSS radio inputs. In paged PDF export, renders the
/// branch matching active `text.lang` (falling back to the primary declared branch).
///
/// ```example
/// #tr(en: [Programming languages], de: [Programmiersprachen])
/// ```
/// -> content
#let tr(
  /// Optional `@preview/linguify`-compatible dictionary (`toml("lang.toml")`) when looking up a string key.
  /// -> dictionary | none
  from: none,
  /// Positional string key (when `from` is provided) or named language branches (`en: [...], de: [...]`).
  /// -> any
  ..branches,
) = {
  let pos = branches.pos()
  let entries = if from != none {
    if pos.len() == 0 {
      panic("`tr(from: db, \"key\")` requires a lookup key.")
    }
    _entries-from-db(from, str(pos.first())) + branches.named()
  } else {
    branches.named()
  }
  if entries.len() == 0 {
    panic(
      "`tr(...)` expects named language branches (e.g. `tr(en: [Hello], de: [Grüezi])`) or `from: db` with a valid key.",
    )
  }
  let is-block = entries.values().any(_has-block-content)
  let first-pair = entries.pairs().first()

  [#metadata((thyme-tr: true, entries: entries))<thyme-tr-meta>]
  context {
    if target() == "html" {
      for (idx, (code, val)) in entries.pairs().enumerate() {
        let scoped = {
          set text(lang: code)
          if idx > 0 { _tr-nonprimary-depth.update(d => d + 1) }
          val
          if idx > 0 { _tr-nonprimary-depth.update(d => d - 1) }
        }
        if is-block {
          html.div(class: "thyme-tr", lang: code, scoped)
        } else {
          html.span(class: "thyme-tr", lang: code, scoped)
        }
      }
    } else {
      let chosen-code = if text.lang in entries { text.lang } else {
        first-pair.at(0)
      }
      set text(lang: chosen-code)
      entries.at(chosen-code)
    }
  }
}

/// Generate the minimal CSS stylesheet rules driving zero-JavaScript, keyboard-accessible
/// `<input type="radio">` language switching for a page's `langs` array, which holds two
/// or more language codes.
/// -> str
#let i18n-css(
  /// Ordered list of active language codes on the page (e.g. `("en", "de")`).
  /// -> array
  langs,
) = {
  if langs.len() < 2 {
    return ""
  }
  let hide-rules = (
    langs
      .map(l => (
        ":root:has(#thyme-lang-" + l + ":not(:checked)) .thyme-tr[lang=\"" + l + "\"]"
      ))
      .join(",\n")
      + " { display: none !important; }"
  )
  let active-rules = (
    langs
      .map(l => (
        ":root:has(#thyme-lang-" + l + ":checked) .thyme-lang-switch label[for=\"thyme-lang-" + l + "\"]"
      ))
      .join(",\n")
      + " { color: var(--fg, inherit); text-decoration: underline; text-underline-offset: 0.2em; text-decoration-thickness: 1px; }"
  )
  let focus-rules = (
    langs
      .map(l => (
        ":root:has(#thyme-lang-" + l + ":focus-visible) .thyme-lang-switch label[for=\"thyme-lang-" + l + "\"]"
      ))
      .join(",\n")
      + " { outline: 1.5px solid var(--fg, currentColor); outline-offset: 3px; border-radius: 2px; }"
  )

  (
    ".thyme-lang-state { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip-path: inset(50%); white-space: nowrap; border: 0; }",
    hide-rules,
    ".thyme-lang-switch { display: inline-flex; align-items: baseline; gap: 0.35em; }",
    ".thyme-lang-switch label { cursor: pointer; color: var(--muted, inherit); transition: color 0.15s ease; }",
    ".thyme-lang-switch label:hover { color: var(--fg, inherit); }",
    ".thyme-lang-switch .sep { color: var(--muted, inherit); user-select: none; }",
    active-rules,
    focus-rules,
    "@media print { .thyme-lang-state, .thyme-lang-switch { display: none !important; } }",
  ).join("\n")
}

/// Emit visually-hidden, keyboard-accessible top-of-`<body>` radio `<input>` controls
/// for zero-JS language switching when `langs` has two or more languages.
/// -> content
#let render-lang-inputs(langs) = {
  if langs.len() >= 2 {
    html.div(class: "thyme-lang-state", {
      for (idx, code) in langs.enumerate() {
        html.elem(
          "input",
          attrs: (
            type: "radio",
            name: "thyme-lang",
            id: "thyme-lang-" + code,
            class: "thyme-lang-input",
            "aria-label": "Language: " + code,
            ..if idx == 0 { (checked: "") } else { (:) },
          ),
        )
      }
    })
  }
}

/// Render the clickable `en · de` `<label>` switcher bar for zero-JS CSS language toggling.
/// Emits nothing when `langs` has fewer than two languages or outside HTML targets.
/// -> content
#let lang-switcher(
  /// Language codes (`("en", "de")`).
  /// -> array
  langs,
) = context {
  if target() == "html" and langs.len() >= 2 {
    html.elem(
      "span",
      attrs: (
        class: "thyme-lang-switch",
        role: "group",
        "aria-label": "Language",
      ),
      {
        for (idx, code) in langs.enumerate() {
          if idx > 0 {
            html.span(class: "sep")[·]
          }
          html.label(..("for": "thyme-lang-" + code), code)
        }
      },
    )
  }
}
