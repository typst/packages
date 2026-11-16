// Monochrome `oklch` blog & math components for the `blog` preset, built on top of
// `@preview/showybox:2.0.4`, `@preview/tablem:0.3.0`, `@preview/cheq:0.4.0`,
// and `@preview/zebraw:0.6.3`.

#import "@preview/cheq:0.4.0": checklist
#import "@preview/showybox:2.0.4": showybox
#import "@preview/tablem:0.3.0": tablem as _tablem, three-line-table as _three-line-table
#import "@preview/zebraw:0.6.3": zebraw as _zebraw, zebraw-init, zebraw-themes
#import "../paths.typ": find-doc-containing, heading-anchor-id, resolve-abs-length
#import "../text.typ": to-plain-text, word-hint
#import "theme.typ": active-theme

/// Markdown-like pipe table (`@preview/tablem:0.3.0`).
/// -> function
#let tablem = _tablem

/// Classic academic three-line table (`@preview/tablem:0.3.0`).
/// -> function
#let three-line-table = _three-line-table

/// Inner crosshair grid table built on `tablem` (`left` & `top` hairlines between cells).
/// -> content
#let grid-table(
  /// Markdown-style pipe table content block.
  /// -> content
  body,
  /// Additional arguments forwarded to `tablem`.
  /// -> any
  ..rest,
) = {
  [#metadata((
    thyme-feed-node: true,
    kind: "block",
    body: body,
  ))<thyme-feed-meta>]
  context {
    let t = active-theme()
    let inner = _tablem(
      render: (columns: auto, ..args) => table(
        columns: columns,
        stroke: (x, y) => (
          left: if x > 0 { 0.5pt + t.muted-light } else { none },
          top: if y > 0 { 0.5pt + t.muted-light } else { none },
          right: none,
          bottom: none,
        ),
        align: center + horizon,
        ..args,
      ),
      ..rest,
      body,
    )
    if target() == "html" {
      html.div(class: "blog-grid-table", inner)
    } else {
      inner
    }
  }
}

/// Monochrome-framed code block wrapper around `@preview/zebraw:0.6.3` with
/// native syntax highlighting, line numbers, line highlights, and HTML copy button.
/// -> content
#let zebraw(
  /// Code block and options forwarded to `@preview/zebraw`.
  /// -> any
  ..args,
  /// Highlighted line background (`auto` uses `theme.surface-2-light`).
  /// -> auto | color
  highlight-color: auto,
  /// Code block background (`auto` uses `theme.surface-1-light`).
  /// -> auto | color
  background-color: auto,
  /// Line-comment annotation fill (`auto` uses `theme.surface-2-light`).
  /// -> auto | color
  comment-color: auto,
  /// Language badge fill (`auto` uses `theme.surface-2-light`).
  /// -> auto | color
  lang-color: auto,
) = {
  let pos-args = args.pos()
  if pos-args.len() > 0 {
    [#metadata((
      thyme-feed-node: true,
      kind: "code",
      body: pos-args.last(),
    ))<thyme-feed-meta>]
  }
  [#metadata(true)<blog-has-code>]
  context {
    let t = active-theme()
    _zebraw(
      highlight-color: if highlight-color == auto { t.surface-2-light } else {
        highlight-color
      },
      background-color: if background-color == auto { t.surface-1-light } else {
        background-color
      },
      comment-color: if comment-color == auto { t.surface-2-light } else {
        comment-color
      },
      lang-color: if lang-color == auto { t.surface-2-light } else {
        lang-color
      },
      ..args,
    )
  }
}

/// Alias for `zebraw`.
/// -> function
#let codeblock = zebraw

#let _normalize-box-title(t) = {
  if t == none or t == [] {
    none
  } else if type(t) == content and t.func() == heading {
    t.body
  } else {
    t
  }
}

#let _sbox-paged-fill(variant, theme-config) = {
  if variant in ("definition", "theorem", "lemma", "proposition") {
    theme-config.surface-2-light
  } else if variant == "example" {
    theme-config.surface-1-light
  } else {
    theme-config.paper-light
  }
}

#let _sbox-html-head(kind, has-title, clean-title) = {
  if kind != none or has-title {
    html.div(class: "blog-sbox-head", {
      if kind != none { html.span(class: "blog-sbox-kind", kind + ".") }
      if has-title { html.span(class: "blog-sbox-title", clean-title) }
    })
  }
}

/// Multi-section monochrome environment box with uppercase sans-serif `kind` label.
/// Rendered as `<div class="blog-sbox">` in HTML so browser Reader Modes preserve
/// primary theorems, lemmas, definitions, and recipes verbatim.
/// -> content
#let sbox(
  /// Box title (`none` or `[]` omits the underlined title).
  /// -> content | str | none
  title,
  /// One or more body content blocks separated by dotted hairline rules.
  /// -> content
  ..sections,
  /// Visual surface variant (`"definition"`, `"theorem"`, `"example"`, `"recipe"`).
  /// -> str
  variant: "recipe",
  /// Uppercase sans-serif category label (e.g. `"Definition"`, `"Theorem"`).
  /// -> str | none
  kind: none,
) = {
  let clean-title = _normalize-box-title(title)
  let parts = sections.pos()
  [#metadata((
    thyme-feed-node: true,
    kind: "sbox",
    label: kind,
    title: clean-title,
    body: parts.join(parbreak()),
  ))<thyme-feed-meta>]
  context {
    let t = active-theme()
    let has-title = (
      clean-title != none and to-plain-text(clean-title).trim().len() > 0
    )
    word-hint(kind, clean-title, ..parts)

    if target() == "html" {
      html.elem(
        "div",
        attrs: (class: "blog-sbox", "data-variant": variant),
        {
          if parts.len() == 0 {
            if kind != none or has-title {
              html.div(class: "blog-sbox-part", _sbox-html-head(
                kind,
                has-title,
                clean-title,
              ))
            }
          } else {
            for (i, part) in parts.enumerate() {
              html.div(class: "blog-sbox-part", {
                if i == 0 { _sbox-html-head(kind, has-title, clean-title) }
                part
              })
            }
          }
        },
      )
    } else {
      let head-line = if kind != none or has-title {
        block(below: 0.45em, {
          if kind != none {
            text(
              font: t.sans-fonts,
              size: 0.78em,
              weight: "bold",
              tracking: 0.05em,
              fill: t.text-light,
              upper(kind) + ".",
            )
            if has-title { h(0.45em) }
          }
          if has-title {
            underline(
              stroke: 0.55pt + t.text-light,
              offset: 2pt,
              text(weight: "semibold", fill: t.text-light, clean-title),
            )
          }
        })
      } else {
        none
      }

      let sbox-parts = if parts.len() == 0 {
        if head-line != none { (head-line,) } else { ([],) }
      } else {
        parts
          .enumerate()
          .map(((i, part)) => {
            if i == 0 and head-line != none {
              head-line + part
            } else {
              part
            }
          })
      }

      showybox(
        frame: (
          border-color: t.frame-light,
          body-color: _sbox-paged-fill(variant, t),
          thickness: 0.65pt,
          radius: 2pt,
          inset: (x: 0.88em, y: 0.72em),
        ),
        body-style: (
          color: t.text-light,
        ),
        sep: (
          thickness: 0.5pt,
          dash: "dotted",
          gutter: 0.65em,
        ),
        above: 1.15em,
        below: 1.15em,
        ..sbox-parts,
      )
    }
  }
}

/// Mathematical definition environment (`DEFINITION.`).
///
/// ```example
/// #definition[Pointed CPO][
///   An $omega$-CPO $(D, subset.eq.sq)$ with least element $bot in D$.
/// ]
/// ```
/// -> content
#let definition(
  /// Definition title.
  /// -> content | str | none
  title,
  /// One or more body sections.
  /// -> content
  ..sections,
) = sbox(title, ..sections.pos(), variant: "definition", kind: "Definition")

/// Theorem environment (`THEOREM.`).
///
/// ```example
/// #theorem[Kleene Fixed Point][
///   Every Scott-continuous map $F : D -> D$ has $"lfp"(F) = union.sq.big_(n >= 0) F^n (bot)$.
/// ]
/// ```
/// -> content
#let theorem(
  /// Theorem title.
  /// -> content | str | none
  title,
  /// One or more body sections.
  /// -> content
  ..sections,
) = sbox(title, ..sections.pos(), variant: "theorem", kind: "Theorem")

/// Lemma environment (`LEMMA.`).
/// -> content
#let lemma(title, ..sections) = sbox(
  title,
  ..sections.pos(),
  variant: "lemma",
  kind: "Lemma",
)

/// Proposition environment (`PROPOSITION.`).
/// -> content
#let proposition(title, ..sections) = sbox(
  title,
  ..sections.pos(),
  variant: "proposition",
  kind: "Proposition",
)

/// Corollary environment (`COROLLARY.`).
/// -> content
#let corollary(title, ..sections) = sbox(
  title,
  ..sections.pos(),
  variant: "theorem",
  kind: "Corollary",
)

/// Example environment (`EXAMPLE.`).
/// -> content
#let example(title, ..sections) = sbox(
  title,
  ..sections.pos(),
  variant: "example",
  kind: "Example",
)

/// Recipe / procedure environment (`RECIPE.`).
/// -> content
#let recipe(title, ..sections) = sbox(
  title,
  ..sections.pos(),
  variant: "recipe",
  kind: "Recipe",
)

/// Remark environment (`REMARK.`).
/// -> content
#let remark(title, ..sections) = sbox(
  title,
  ..sections.pos(),
  variant: "recipe",
  kind: "Remark",
)

/// Proof block with subtle left rule and flush-right hollow Halmos square (`sym.square.stroked`).
///
/// ```example
/// #proof[
///   By induction on $n$, $F^n (bot) subset.eq.sq e$ for every pre-fixed point $e$.
/// ]
/// ```
/// -> content
#let proof(
  /// Uppercase sans-serif lead-in label (e.g. `[Proof]` or `[Proof sketch]`).
  /// -> content | str
  title: [Proof],
  /// Proof body.
  /// -> content
  body,
) = {
  [#metadata((
    thyme-feed-node: true,
    kind: "proof",
    label: to-plain-text(title),
    body: body,
  ))<thyme-feed-meta>]
  context {
    let t = active-theme()
    word-hint(title, body)
    if target() == "html" {
      html.div(class: "blog-proof", {
        html.div(class: "blog-proof-head", title + [.])
        body
        html.div(class: "blog-qed-row", html.span(class: "blog-qed", []))
      })
    } else {
      block(
        width: 100%,
        stroke: (left: 1.2pt + t.border-light),
        inset: (left: 0.9em, y: 0.15em),
        above: 1em,
        below: 1.15em,
        {
          block(
            below: 0.48em,
            text(
              font: t.sans-fonts,
              size: 0.78em,
              weight: "bold",
              tracking: 0.05em,
              fill: t.text-light,
              upper(to-plain-text(title)),
            ),
          )
          body
          h(1fr) + sym.square.stroked
        },
      )
    }
  }
}

#let _callout-labels = (
  note: "Note",
  tip: "Tip",
  warning: "Warning",
  important: "Important",
)

/// Monochrome left-bordered callout (`note`, `tip`, `warning`, `important`).
/// Rendered as `<div class="blog-callout" role="note">` in HTML so Reader Modes
/// preserve important/warning callouts inline.
/// -> content
#let callout(
  /// Callout kind (`"note"`, `"tip"`, `"warning"`, `"important"`).
  /// -> str
  kind: "note",
  /// Custom heading (`auto` uses `kind`, `none` omits heading).
  /// -> auto | content | str | none
  title: auto,
  /// Callout content.
  /// -> content
  body,
) = {
  let heading-text = if title == auto {
    _callout-labels.at(kind, default: "Note")
  } else { title }
  [#metadata((
    thyme-feed-node: true,
    kind: "callout",
    label: if heading-text != none { to-plain-text(heading-text) } else {
      none
    },
    body: body,
  ))<thyme-feed-meta>]
  context {
    let t = active-theme()
    word-hint(heading-text, body)

    if target() == "html" {
      html.elem(
        "div",
        attrs: (class: "blog-callout", "data-kind": kind, role: "note"),
        {
          if heading-text != none {
            html.div(class: "blog-callout-title", heading-text)
          }
          body
        },
      )
    } else {
      block(
        width: 100%,
        fill: t.surface-1-light,
        stroke: (left: 2.2pt + t.text-light),
        inset: (x: 0.95em, y: 0.72em),
        radius: (right: 2.5pt),
        above: 1.1em,
        below: 1.1em,
        {
          if heading-text != none {
            block(
              below: 0.4em,
              text(
                font: t.sans-fonts,
                size: 0.78em,
                weight: "bold",
                tracking: 0.05em,
                fill: t.text-light,
                upper(to-plain-text(heading-text)),
              ),
            )
          }
          body
        },
      )
    }
  }
}

#let note-box = callout.with(kind: "note")
#let tip-box = callout.with(kind: "tip")
#let warning-box = callout.with(kind: "warning")
#let important-box = callout.with(kind: "important")

/// Section-opening italic epigraph with optional right-aligned attribution.
///
/// ```example
/// #epigraph(source: [Edsger W. Dijkstra, EWD249])[
///   Simplicity is prerequisite for reliability.
/// ]
/// ```
/// -> content
#let epigraph(
  /// Optional attribution rendered flush-right in `Commit Mono`.
  /// -> content | str | none
  source: none,
  /// Quotation body.
  /// -> content
  body,
) = {
  [#metadata((
    thyme-feed-node: true,
    kind: "epigraph",
    title: source,
    body: body,
  ))<thyme-feed-meta>]
  context {
    let t = active-theme()
    word-hint(body, source)
    if target() == "html" {
      html.div(class: "blog-epigraph", {
        html.blockquote(body)
        if source != none {
          html.div(class: "blog-epigraph-source", "- " + source)
        }
      })
    } else {
      block(
        width: 92%,
        stroke: (left: 1.2pt + t.border-light),
        inset: (left: 0.95em, y: 0.2em),
        above: 1.1em,
        below: 1.35em,
        {
          emph(body)
          if source != none {
            v(0.35em)
            align(right, text(
              font: t.mono-fonts,
              size: 0.8em,
              fill: t.muted-light,
              "- " + source,
            ))
          }
        },
      )
    }
  }
}

/// Full-width container spanning both the prose column and the right sidenote margin.
/// Automatically clears any active right-margin sidenotes in both HTML (`clear: right`)
/// and paged mode (`@preview/marge` page state).
/// -> content
#let wide(
  /// Wide table, figure, or listing body.
  /// -> content
  body,
) = {
  [#metadata((
    thyme-feed-node: true,
    kind: "block",
    body: body,
  ))<thyme-feed-meta>]
  context {
    let t = active-theme()
    word-hint(body)
    if target() == "html" {
      html.div(class: "blog-wide", body)
    } else {
      let pg = here().page()
      let cur-y = here().position().y
      let notes = state("marge:0.1.0/page-" + str(pg), ()).get()
      let top-clear = if notes.len() > 0 {
        let max-note-y = notes.fold(0pt, (acc, n) => calc.max(
          acc,
          n.position.y + n.height,
        ))
        let clearance = 1.35em.to-absolute()
        calc.max(0pt, max-note-y + clearance - cur-y)
      } else {
        0pt
      }
      let default-right = resolve-abs-length(t.margin.right, fallback: 7.4cm)
      let default-left = resolve-abs-length(t.margin.left, fallback: 2.2cm)
      let right-m = if (
        type(page.margin) == dictionary and "right" in page.margin
      ) {
        resolve-abs-length(page.margin.right, fallback: default-right)
      } else {
        default-right
      }
      let extra = calc.max(0pt, right-m - default-left)
      block(
        width: 100% + extra,
        inset: (top: top-clear),
        above: 1.2em,
        below: 1.2em,
        body,
      )
    }
  }
}

/// Render arbitrary Typst graphics natively in paged previews and as inline `<svg>` in HTML
/// (automatically inverted in dark mode unless `invert-dark: false`).
/// -> content
#let diagram(
  /// Optional figure caption.
  /// -> content | str | none
  caption: none,
  /// Invert monochrome line-art `<svg>` automatically in dark mode (`false` preserves dark-native or multi-hue graphics).
  /// -> bool
  invert-dark: true,
  /// Typst drawing or diagram content.
  /// -> content
  body,
) = context {
  word-hint(caption)
  if target() == "html" {
    html.elem(
      "figure",
      attrs: (
        class: "blog-diagram",
        ..if not invert-dark { ("data-invert": "false") } else { (:) },
      ),
      {
        html.frame(body)
        if caption != none {
          html.figcaption(caption)
        }
      },
    )
  } else if caption != none {
    figure(body, kind: image, caption: caption)
  } else {
    align(center, body)
  }
}

/// Monochrome keyboard shortcut badge (`#kbd("Ctrl+P")`).
///
/// ```example
/// Press #kbd("Ctrl+P") for archival two-column print output.
/// ```
/// -> content
#let kbd(
  /// Key label text.
  /// -> content | str
  key,
) = context {
  let t = active-theme()
  if target() == "html" {
    html.kbd(key)
  } else {
    box(
      fill: t.surface-1-light,
      stroke: 0.6pt + t.frame-light,
      inset: (x: 0.34em, y: 0.13em),
      outset: (y: 0.12em),
      radius: 2pt,
      text(size: 0.82em, font: t.mono-fonts, raw(if type(key) == str {
        key
      } else { to-plain-text(key) })),
    )
  }
}

/// Minimalist horizontal rule (`<hr>` in HTML, hairline rule in paged previews).
/// -> content
#let hr = context {
  let t = active-theme()
  if target() == "html" {
    html.hr()
  } else {
    v(0.65em)
    line(length: 100%, stroke: 0.55pt + t.border-light)
    v(0.65em)
  }
}

/// General links layout (`direction: "row"` for horizontal, `direction: "col"` for vertical).
/// -> content
#let links(
  /// Direction of layout (`"row"` for horizontal, `"col"` for vertical).
  /// -> str
  direction: "row",
  /// Link elements (e.g. `link("https://example.org")[example.org]`, `[@rss[rss]]`).
  /// -> content
  ..items,
) = context {
  let t = active-theme()
  let entries = items.pos()
  if target() == "html" {
    html.ul(
      class: if direction == "row" { "links" } else { "links-col" },
      {
        for item in entries {
          html.li(item)
        }
      },
    )
  } else {
    if direction == "row" {
      block(above: 0.6em, below: 1.2em, {
        set text(font: t.mono-fonts, size: 0.8em, fill: t.muted-light)
        entries.join(" · ")
      })
    } else {
      block(above: 0.6em, below: 1.2em, {
        set text(font: t.mono-fonts, size: 0.8em, fill: t.muted-light)
        for item in entries {
          item
          v(0.2em)
        }
      })
    }
  }
}

/// Render a monochrome table of contents (`<nav class="blog-toc">` in HTML,
/// hairline-bordered outline in paged PDF) scoped to the enclosing page or post.
/// -> content
#let toc(
  /// Optional uppercase heading above the outline (`none` omits heading).
  /// -> content | str | none
  title: none,
  /// Maximum heading depth to include (`1` = top-level `=` sections, `2` = `=` + `==`, etc.).
  /// -> int
  depth: 2,
  /// Prefix top-level `=` entries with `01`, `02`, ... in `Commit Mono`.
  /// -> bool
  numbered: true,
) = context {
  let t = active-theme()
  let enc-doc = find-doc-containing(here())
  let all-headings = if enc-doc != none {
    let starts = query(selector(<thyme-body-start>).within(enc-doc.location()))
    let ends = query(selector(<thyme-body-end>).within(enc-doc.location()))
    if starts.len() > 0 and ends.len() > 0 {
      query(
        selector(heading).after(starts.first().location()).before(ends.first().location()),
      )
    } else {
      query(selector(heading).within(enc-doc.location()))
    }
  } else {
    let starts = query(selector(<thyme-body-start>).before(here()))
    let ends = query(selector(<thyme-body-end>).after(here()))
    if starts.len() > 0 and ends.len() > 0 {
      query(
        selector(heading).after(starts.last().location()).before(ends.first().location()),
      )
    } else {
      query(heading)
    }
  }
  let entries = all-headings.filter(h => h.level <= depth and h.outlined)
  if entries.len() == 0 {
    return []
  }

  if target() == "html" {
    let sec-idx = 0
    html.elem(
      "nav",
      attrs: (class: "blog-toc", "aria-label": "Table of contents"),
      {
        if title != none {
          html.div(class: "blog-toc-title", title)
        }
        html.ol({
          for h in entries {
            let h-pos = all-headings.position(x => x.location() == h.location())
            let prior = if h-pos != none { all-headings.slice(0, h-pos) } else {
              ()
            }
            let aid = heading-anchor-id(h, prior-headings: prior)
            if h.level == 1 {
              sec-idx += 1
            }
            let num-str = if numbered and h.level == 1 {
              if sec-idx < 10 { "0" + str(sec-idx) } else { str(sec-idx) }
            } else {
              none
            }
            html.elem(
              "li",
              attrs: ("data-level": str(h.level)),
              {
                if num-str != none {
                  html.span(class: "toc-num", num-str)
                }
                html.a(href: "#" + aid, h.body)
              },
            )
          }
        })
      },
    )
  } else {
    let sec-idx = 0
    block(
      width: 100%,
      stroke: (left: 1.2pt + t.border-light),
      inset: (left: 0.9em, y: 0.15em),
      above: 1em,
      below: 1.35em,
      {
        if title != none {
          block(
            below: 0.4em,
            text(
              font: t.sans-fonts,
              size: 0.75em,
              weight: "bold",
              tracking: 0.05em,
              fill: t.muted-light,
              upper(to-plain-text(title)),
            ),
          )
        }
        for h in entries {
          if h.level == 1 {
            sec-idx += 1
          }
          let pad = (h.level - 1) * 1em
          let num-str = if numbered and h.level == 1 {
            if sec-idx < 10 { "0" + str(sec-idx) } else { str(sec-idx) }
          } else {
            none
          }
          block(below: 0.28em, inset: (left: pad), {
            if num-str != none {
              text(
                font: t.mono-fonts,
                size: 0.78em,
                fill: t.muted-light,
                num-str,
              )
              std.h(0.45em)
            }
            link(h.location(), text(size: 0.92em, h.body))
          })
        }
      },
    )
  }
}
