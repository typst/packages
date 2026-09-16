// to-commonmark: Convert content to CommonMark strings.
//
// Usage:
//   #import "@preview/to-commonmark:0.1.0": to-commonmark
//   #to-commonmark(my-content)

// ─── Safe join (empty array → "") ───────────────────────────────────────────

/// Join an array of strings, returning "" for empty arrays (not none).
#let _join(arr, sep) = {
  if arr.len() > 0 { arr.join(sep) } else { "" }
}

// ─── Escape helpers ──────────────────────────────────────────────────────────

/// Check if a character needs escaping in inline context.
#let _is-inline-special(ch) = (
  ch == "\\" or ch == "`" or ch == "*" or ch == "_" or
  ch == "[" or ch == "]" or ch == "<"
)

/// Escape special characters for inline contexts.
#let _escape-inline(text) = {
  let result = ""
  for ch in text.codepoints() {
    result += if _is-inline-special(ch) {
      "\\" + ch
    } else {
      ch
    }
  }
  result
}

/// Check if a URL needs angle brackets (contains spaces, parens, etc.)
#let _needs-angle-brackets(url) = {
  let special = (" ", "(", ")", "<", ">", "\\", "\"", "'")
  special.any(s => url.contains(s))
}

/// Find the longest run of consecutive backtick characters in a string.
#let _longest-backtick-run(text) = {
  let max-run = 0
  let current-run = 0
  for ch in text.codepoints() {
    if ch == "`" {
      current-run += 1
      max-run = calc.max(max-run, current-run)
    } else {
      current-run = 0
    }
  }
  max-run
}

// ─── Context helpers ─────────────────────────────────────────────────────────

/// Build a default context for the walker.
#let _default-ctx() = (
  mode: "block",
  emph-depth: 0,
  list-indent: "",
)

/// Create a child context, inserting one override (copies to avoid mutation).
#let _ctx-set(ctx, key, value) = {
  let result = (:..ctx)
  result.insert(key, value)
  result
}

// ─── Block/Inline classification ─────────────────────────────────────────────

/// Check if a content element is an item (from markup-mode list).
#let _is-item-element(elem) = {
  if type(elem) != content { return false }
  let fn = elem.func()
  fn == list.item or fn == enum.item or repr(fn) == "item"
}

/// Check if a content element is inherently block-level (includes items).
#let _is-block-element(elem) = {
  if _is-item-element(elem) { return true }
  if type(elem) != content { return false }
  let fn = elem.func()
  fn == heading or fn == list or fn == enum or fn == parbreak or fn == quote
}

// ─── Walk (single-function recursive walker) ─────────────────────────────────

/// Recursively walk a content tree, producing a CommonMark string.
/// The returned string has no leading/trailing whitespace.
#let walk(elem, ctx) = {
  /// Render an emph/strong body with marker alternation by nesting depth.
  /// Outer level uses `outer-marker`, nested levels use `inner-marker`.
  let render-emph(body, outer-marker, inner-marker) = {
    let inner-body = walk(body, _ctx-set(ctx, "emph-depth", ctx.emph-depth + 1))
    if inner-body == "" {
      ""
    } else if ctx.emph-depth == 0 {
      outer-marker + inner-body + outer-marker
    } else {
      inner-marker + inner-body + inner-marker
    }
  }

  /// Render a sequence of (marker, item-child) pairs as a Markdown list.
  let render-list-elems = (numbered) => {
    let indent = ctx.list-indent
    let parts = ()
    for (marker, child) in numbered {
      let child-indent = indent + marker + " "
      let inner-indent = indent + "  "
      let child-ctx = _ctx-set(_ctx-set(ctx, "mode", "block"), "list-indent", inner-indent)
      let body = walk(child.body, child-ctx)
      if body != "" {
        let lines = body.split("\n")
        let first = child-indent + lines.at(0)
        let rest = (first,)
        for l in lines.slice(1) {
          rest.push(if l == "" { "" } else { inner-indent + l })
        }
        parts.push(_join(rest, "\n"))
      }
    }
    _join(parts, "\n")
  }

  // ── Pre-dispatch: non-element, non-content values ──

  if type(elem) == str {
    _escape-inline(elem)
  } else if elem == none {
    ""
  } else if type(elem) == array {
    let parts = ()
    for child in elem {
      let s = walk(child, ctx)
      if s != "" {
        parts.push(s)
      }
    }
    if ctx.mode == "block" {
      _join(parts, "\n\n")
    } else {
      _join(parts, "")
    }
  } else if type(elem) == label {
    ""
  } else if type(elem) == content {
    let fn = elem.func()

    // ── Text (leaf) ──
    if fn == text {
      _escape-inline(elem.text)
    }

    // ── Space ──
    else if repr(fn) == "space" {
      " "
    }

    // ── Sequence ──
    else if repr(fn) == "sequence" {
      if ctx.mode == "inline" {
        // In inline mode, concatenate everything
        let parts = ()
        for child in elem.children {
          let s = walk(child, ctx)
          if s != "" {
            parts.push(s)
          }
        }
        _join(parts, "")
      } else {
        // In block mode, group consecutive inline elements into
        // paragraphs, group consecutive items into lists,
        // separated by \n\n from block elements.
        let blocks = ()
        let inline-buf = ()
        let item-buf = ()

        // Render a buffer of items as a bullet list
        let render-items(items) = {
          render-list-elems(items.map(i => ("-", i)))
        }

        for child in elem.children {
          // Skip space/parbreak elements between items (don't break list grouping)
          let child-fn = if type(child) == content { repr(child.func()) } else { "" }
          let is-ws-between-items = (
            item-buf.len() > 0 and inline-buf.len() == 0 and
            (child-fn == "space" or child-fn == "parbreak")
          )
          if is-ws-between-items {
            // Skip: whitespace between list items
          } else if _is-item-element(child) {
            // Flush inline buffer first
            if inline-buf.len() > 0 {
              let text = inline-buf.join("")
              if text.trim() != "" {
                blocks.push(text.trim())
              }
              inline-buf = ()
            }
            item-buf.push(child)
          } else if _is-block-element(child) {
            // Flush inline and item buffers
            if inline-buf.len() > 0 {
              let text = inline-buf.join("")
              if text.trim() != "" {
                blocks.push(text.trim())
              }
              inline-buf = ()
            }
            if item-buf.len() > 0 {
              blocks.push(render-items(item-buf))
              item-buf = ()
            }
            // Walk the block element
            let s = walk(child, ctx)
            if s != "" {
              blocks.push(s)
            }
          } else {
            // Inline element: accumulate
            if item-buf.len() > 0 {
              // We had items, flush them before inline content
              blocks.push(render-items(item-buf))
              item-buf = ()
            }
            let s = walk(child, ctx)
            if s != "" {
              inline-buf.push(s)
            }
          }
        }
        // Flush remaining buffers
        if inline-buf.len() > 0 {
          let remainder = inline-buf.join("")
          if remainder.trim() != "" {
            blocks.push(remainder.trim())
          }
        }
        if item-buf.len() > 0 {
          blocks.push(render-items(item-buf))
          item-buf = ()
        }
        if blocks.len() > 0 { blocks.join("\n\n") } else { "" }
      }
    }

    // ── Linebreak ──
    else if fn == linebreak {
      "\\\\\n"
    }

    // ── Parbreak ──
    else if fn == parbreak {
      ""
    }

    // ── Heading ──
    else if fn == heading {
      let h-fields = elem.fields()
      // Markup headings use "depth", code-mode headings use "level"
      let lvl = calc.min(h-fields.at("depth", default: h-fields.at("level", default: 1)), 6)
      let body = walk(h-fields.at("body", default: []), _ctx-set(ctx, "mode", "inline"))
      if body == "" { "" } else { "#" * lvl + " " + body }
    }

    // ── Strong ──
    else if fn == strong {
      render-emph(elem.body, "**", "__")
    }

    // ── Emphasis ──
    else if fn == emph {
      render-emph(elem.body, "*", "_")
    }

    // ── Raw / Code ──
    else if fn == raw {
      let code = elem.text
      let fields = elem.fields()
      let lang-str = fields.at("lang", default: "")
      let is-block = fields.at("block", default: false) == true

      if is-block {
        let fence-len = calc.max(3, _longest-backtick-run(code) + 1)
        let fence = "`" * fence-len
        fence + lang-str + "\n" + code + "\n" + fence
      } else {
        let fence-len = calc.max(1, _longest-backtick-run(code) + 1)
        let fence = "`" * fence-len
        let padded = if (
          code.starts-with("`") or code.ends-with("`") or
          code.starts-with(" ") or code.ends-with(" ")
        ) {
          " " + code + " "
        } else {
          code
        }
        fence + padded + fence
      }
    }

    // ── List ──
    else if fn == list {
      let numbered = ()
      for child in elem.children { numbered.push(("-", child)) }
      render-list-elems(numbered)
    }

    // ── Enum (ordered list) ──
    else if fn == enum {
      let numbered = ()
      for (i, child) in elem.children.enumerate() { numbered.push((str(i + 1) + ".", child)) }
      render-list-elems(numbered)
    }

    // ── List/Enum item ──
    else if fn == list.item or fn == enum.item {
      walk(elem.body, ctx)
    }

    // ── Block quote ──
    else if fn == quote {
      let q-fields = elem.fields()
      let is-block = q-fields.at("block", default: false) == true
      if not is-block {
        walk(q-fields.at("body", default: []), _ctx-set(ctx, "mode", "inline"))
      } else {
        let body = walk(q-fields.at("body", default: []), _ctx-set(ctx, "mode", "block"))
        if body == "" {
          ""
        } else {
          let lines = body.split("\n")
          lines.map(l => {
            if l == "" { ">" } else { "> " + l }
          }).join("\n")
        }
      }
    }

    // ── Link ──
    else if fn == link {
      let link-fields = elem.fields()
      let dest = link-fields.at("dest", default: "")
      let body = walk(link-fields.at("body", default: []), _ctx-set(ctx, "mode", "inline"))

      // Auto-link: body text == destination
      if body == dest {
        "<" + dest + ">"
      } else {
        let dest-encoded = if _needs-angle-brackets(dest) {
          "<" + dest + ">"
        } else {
          dest
        }
        "[" + body + "](" + dest-encoded + ")"
      }
    }

    // ── Image ──
    else if fn == image {
      let img-fields = elem.fields()
      let src = img-fields.at("source", default: "")
      let alt = _escape-inline(img-fields.at("alt", default: ""))
      "![" + alt + "](" + src + ")"
    }

    // ── Ref (cross-reference): emit as literal text ──
    else if fn == ref {
      _escape-inline("@" + repr(elem.target).slice(1, -1))
    }

    // ── Everything else: drop comment ──
    else {
      "<!-- dropped: " + repr(fn) + " -->"
    }
  }

  // ── Unknown type ──
  else {
    ""
  }
}

// ─── Public API ──────────────────────────────────────────────────────────────

/// Convert arbitrary Typst content to a CommonMark string.
#let to-commonmark(content) = {
  walk(content, _default-ctx())
}
