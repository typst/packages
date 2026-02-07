// citrus - Punctuation Collapsing
//
// Implements CSL punctuation collapsing rules based on citeproc-js LtoR_MAP.

// =============================================================================
// Module-level regex patterns (avoid recompilation in hot loops)
// =============================================================================

// Replace patterns
#let _re-digit-comma-paren = regex("(\\d),\\s*\\(")
#let _re-dot-before-rdquote = regex("^\\.\\s*\\u{201D}")
#let _re-rsquote-end = regex("\u{2019}$")
#let _re-digit-comma-end = regex("\\d,\\s*$")
#let _re-comma-end = regex(",\\s*$")

// Show rule patterns: multi-space / digit-comma-paren
#let _re-multi-space = regex(" {2,}")

// Duplicate punctuation collapse
#let _re-dup-dot = regex("[.。]{2,}")
#let _re-dup-comma = regex("[,，、]{2,}")
#let _re-dup-semi = regex("[;；]{2,}")
#let _re-dup-colon = regex("[:：]{2,}")
#let _re-dup-bang = regex("[!！]{2,}")
#let _re-dup-qmark = regex("[?？]{2,}")

// Duplicate across closing quotes
#let _re-dot-q-dot = regex("[.。][\u{201D}\"][.。]")
#let _re-comma-q-comma = regex("[,，、][\u{201D}\"][,，、]")
#let _re-semi-q-semi = regex("[;；][\u{201D}\"][;；]")
#let _re-colon-q-colon = regex("[:：][\u{201D}\"][:：]")
#let _re-bang-q-bang = regex("[!！][\u{201D}\"][!！]")
#let _re-qmark-q-qmark = regex("[?？][\u{201D}\"][?？]")

// Absorption rules
#let _re-bang-dot = regex("[!！][.。]")
#let _re-bang-colon = regex("[!！][:：]")
#let _re-qmark-dot = regex("[?？][.。]")
#let _re-qmark-colon = regex("[?？][:：]")
#let _re-colon-dot = regex("[:：][.。]")
#let _re-colon-bang = regex("[:：][!！]")
#let _re-colon-qmark = regex("[:：][?？]")
#let _re-semi-dot = regex("[;；][.。]")
#let _re-semi-colon = regex("[;；][:：]")
#let _re-semi-bang = regex("[;；][!！]")
#let _re-semi-qmark = regex("[;；][?？]")

// Absorption across closing quotes
#let _re-bang-q-colon = regex("[!！][\u{201D}\"][:：]")
#let _re-qmark-q-colon = regex("[?？][\u{201D}\"][:：]")
#let _re-semi-q-colon = regex("[;；][\u{201D}\"][:：]")

// Punctuation-in-quote patterns
#let _re-qmark-rdq-dot = regex("[?？]\u{201D}\\.")
#let _re-bang-rdq-dot = regex("[!！]\u{201D}\\.")
#let _re-dot-rdq-dot = regex("[.。]\u{201D}[.。]")
#let _re-comma-rdq-comma = regex("[,，、]\u{201D}[,，、]")

/// Get the punctuation-in-quote setting from a parsed CSL style
///
/// - style: Parsed CSL style
/// Returns: Boolean indicating whether punctuation should be moved inside quotes
#import "../parsing/locales/mod.typ": create-fallback-locale

#let get-punctuation-in-quote(style) = {
  // Check style.locale.options first (merged locale)
  let locale = style.at("locale", default: (:))
  let options = locale.at("options", default: (:))
  if "punctuation-in-quote" in options {
    return options.at("punctuation-in-quote", default: false)
  }
  // Fallback to the default locale options if missing
  let default-locale = style.at("default-locale", default: "en-US")
  let fallback = create-fallback-locale(default-locale)
  let fallback-options = fallback.at("options", default: (:))
  fallback-options.at("punctuation-in-quote", default: false)
}

/// Apply CSL punctuation collapsing to content
///
/// Based on citeproc-js LtoR_MAP logic. The map defines what happens when
/// two punctuation marks are adjacent (left + right → result).
///
/// Absorption rules (from citeproc-js):
/// - "!" absorbs "." and ":"    → !. → !,  !: → !
/// - "?" absorbs "." and ":"    → ?. → ?,  ?: → ?
/// - ":" absorbs "."            → :. → :
/// - ":" absorbed by "!" "?"    → :! → !,  :? → ?
/// - ";" absorbs "." and ":"    → ;. → ;,  ;: → ;
/// - ";" absorbed by "!" "?"    → ;! → !,  ;? → ?
/// - "," absorbs "."            → ,. → ,
///
/// All other combinations keep both characters.
///
/// punctuation-in-quote option (CSL locale setting):
/// When true, periods and commas are moved inside closing quotation marks.
/// - "Title". → "Title."
/// - "Title", → "Title,"
///
/// This wrapper limits the show rules to CSL output only.
#import "../core/utils.typ": is-empty
#import "helpers.typ": content-to-string

#let _is-plain-text(content) = {
  if content == none or content == [] { return true }
  if type(content) == str { return true }
  if type(content) == array { return content.all(_is-plain-text) }
  let func = content.func()
  let fields = content.fields()

  if func == text {
    let body = fields.at("body", default: fields.at("text", default: ""))
    return _is-plain-text(body)
  }

  if "children" in fields {
    return fields.children.all(_is-plain-text)
  }

  false
}

#let _flatten-content(content) = {
  if content == none { return () }
  if type(content) == array {
    let flat = ()
    for item in content {
      for sub in _flatten-content(item) { flat.push(sub) }
    }
    return flat
  }
  if type(content) == str { return (content,) }
  let fields = content.fields()
  if "children" in fields {
    let flat = ()
    for child in fields.children {
      for sub in _flatten-content(child) { flat.push(sub) }
    }
    return flat
  }
  (content,)
}

#let _insert-punct-before-quote(text, punct) = {
  let clusters = text.clusters()
  if clusters.len() == 0 { return none }
  let last = clusters.last()
  if last == "\u{201D}" {
    if clusters.len() >= 2 and clusters.at(clusters.len() - 2) == "\u{2019}" {
      let base = clusters.slice(0, clusters.len() - 2).join()
      return base + punct + "\u{2019}\u{201D}"
    }
    let base = clusters.slice(0, clusters.len() - 1).join()
    return base + punct + last
  }
  none
}

#let _move-punct-into-quoted(content, punct) = {
  if type(content) == array and content.len() > 0 {
    let last = content.last()
    let updated-last = _move-punct-into-quoted(last, punct)
    if updated-last != none {
      let updated = content.slice(0, content.len() - 1)
      updated.push(updated-last)
      return updated.join()
    }
  }

  if type(content) == str {
    return _insert-punct-before-quote(content, punct)
  }

  if _is-plain-text(content) {
    let text = content-to-string(content)
    let updated = _insert-punct-before-quote(text, punct)
    if updated != none { return updated }
  }

  let func = content.func()
  let fields = content.fields()

  if "children" in fields and fields.children.len() > 0 {
    let kids = fields.children
    let updated-last = _move-punct-into-quoted(kids.last(), punct)
    if updated-last != none {
      let updated = kids.slice(0, kids.len() - 1)
      updated.push(updated-last)
      return updated.join()
    }
  }

  if "body" in fields and type(fields.body) == str {
    let updated = _insert-punct-before-quote(fields.body, punct)
    if updated != none {
      if func in (emph, strong, underline, smallcaps, super, sub) {
        return func(updated)
      }
      return func(..fields, body: updated)
    }
  }
  if "body" in fields and type(fields.body) != str {
    let updated-body = _move-punct-into-quoted(fields.body, punct)
    if updated-body != none {
      if func in (emph, strong, underline, smallcaps, super, sub) {
        return func(updated-body)
      }
      return func(..fields, body: updated-body)
    }
  }

  if "text" in fields and type(fields.text) == str {
    let updated = _insert-punct-before-quote(fields.text, punct)
    if updated != none {
      if func == text {
        return text(updated)
      }
      if func in (emph, strong, underline, smallcaps, super, sub) {
        return func(updated)
      }
      return func(..fields, body: updated)
    }
  }
  if "text" in fields and type(fields.text) != str {
    let updated-text = _move-punct-into-quoted(fields.text, punct)
    if updated-text != none {
      if func == text {
        return text(updated-text)
      }
      if func in (emph, strong, underline, smallcaps, super, sub) {
        return func(updated-text)
      }
      return func(..fields, body: updated-text)
    }
  }

  if "children" in fields and fields.children.len() > 0 {
    let kids = fields.children
    let last = kids.last()
    let updated-last = _move-punct-into-quoted(last, punct)
    if updated-last != none {
      let updated = kids.slice(0, kids.len() - 1)
      updated.push(updated-last)
      let rebuilt = updated.join()
      if func in (emph, strong, underline, smallcaps, super, sub) {
        return func(rebuilt)
      }
      return rebuilt
    }
  }

  none
}

#let _literal-text(content) = {
  if type(content) == array and content.len() > 0 {
    let first = content.first()
    if type(first) == str { return first }
    let first-fields = first.fields()
    if "body" in first-fields and type(first-fields.body) == str {
      return first-fields.body
    }
    if "text" in first-fields and type(first-fields.text) == str {
      return first-fields.text
    }
  }
  if type(content) == str { return content }
  let fields = content.fields()
  if "body" in fields and type(fields.body) == str { return fields.body }
  if "text" in fields and type(fields.text) == str { return fields.text }
  if "children" in fields and fields.children.len() > 0 {
    let first = fields.children.first()
    if type(first) == str { return first }
    let first-fields = first.fields()
    if "body" in first-fields and type(first-fields.body) == str {
      return first-fields.body
    }
    if "text" in first-fields and type(first-fields.text) == str {
      return first-fields.text
    }
  }
  none
}

#let _leading-punct(text) = {
  let clusters = text.clusters()
  for c in clusters {
    if c != " " and c != "\t" and c != "\n" {
      if c in (".", ",") { return c }
      return none
    }
  }
  none
}

#let _normalize-nested-double-quotes(text) = {
  if type(text) != str { return text }
  let clusters = text.clusters()
  let quote-count = 0
  for ch in clusters {
    if ch == "“" or ch == "”" or ch == "\"" { quote-count += 1 }
  }
  if quote-count < 4 { return text }
  let result = ""
  let level = 0
  for (i, ch) in clusters.enumerate() {
    if ch == "“" or ch == "\"" {
      let prev = if i > 0 { clusters.at(i - 1) } else { "" }
      let can-open = i == 0 or prev in (" ", "\t", "\n", "(", "[")
      if can-open {
        result += if level == 0 { "“" } else { "‘" }
        level += 1
      } else {
        level = calc.max(level - 1, 0)
        result += if level == 0 { "”" } else { "’" }
      }
    } else if ch == "”" {
      level = calc.max(level - 1, 0)
      result += if level == 0 { "”" } else { "’" }
    } else {
      result += ch
    }
  }
  result
}

#let _trailing-punct(text) = {
  let clusters = text.clusters()
  let idx = clusters.len() - 1
  while idx >= 0 {
    let c = clusters.at(idx)
    if c != " " and c != "\t" and c != "\n" {
      if c in (".", ",", ";", ":", "!", "?") { return c }
      return none
    }
    idx -= 1
  }
  none
}

#let _strip-leading-punct(text) = {
  let clusters = text.clusters()
  if clusters.len() == 0 { return text }
  let index = 0
  while (
    index < clusters.len()
      and (
        clusters.at(index) == " "
          or clusters.at(index) == "\t"
          or clusters.at(index) == "\n"
      )
  ) {
    index += 1
  }
  if index < clusters.len() and clusters.at(index) in (".", ",") {
    let prefix = clusters.slice(0, index).join()
    let rest = clusters.slice(index + 1).join()
    prefix + rest
  } else {
    text
  }
}

#let _strip-leading-punct-content(content) = {
  if type(content) == array and content.len() > 0 {
    let first = content.first()
    let first-text = _literal-text(first)
    if first-text != none {
      let stripped = _strip-leading-punct(first-text)
      if stripped != first-text {
        let updated = (stripped,)
        for item in content.slice(1) { updated.push(item) }
        return updated.join()
      }
    }
  }
  if type(content) == str {
    return _strip-leading-punct(content)
  }

  let func = content.func()
  let fields = content.fields()

  if "body" in fields and type(fields.body) == str {
    let updated = _strip-leading-punct(fields.body)
    return func(..fields, body: updated)
  }

  if "text" in fields and type(fields.text) == str {
    let updated = _strip-leading-punct(fields.text)
    if func == text {
      return text(updated)
    }
    return func(..fields, body: updated)
  }
  if "children" in fields and fields.children.len() > 0 {
    let kids = fields.children
    let first = kids.first()
    let first-text = if type(first) == str { first } else {
      _literal-text(first)
    }
    if first-text != none {
      let stripped = _strip-leading-punct(first-text)
      if stripped != first-text {
        let rebuilt = ()
        if type(first) == str {
          rebuilt.push(stripped)
        } else {
          let first-fields = first.fields()
          if "body" in first-fields and type(first-fields.body) == str {
            rebuilt.push(first.func()(..first-fields, body: stripped))
          } else if "text" in first-fields and type(first-fields.text) == str {
            rebuilt.push(first.func()(..first-fields, text: stripped))
          } else {
            rebuilt.push(first)
          }
        }
        for child in kids.slice(1) { rebuilt.push(child) }
        return func(..fields, children: rebuilt)
      }
    }
  }

  if "children" in fields and fields.children.len() > 0 {
    let kids = fields.children
    let first = kids.first()
    let first-text = _literal-text(first)
    if first-text != none {
      let stripped = _strip-leading-punct(first-text)
      if stripped != first-text {
        let updated = (stripped,)
        for item in kids.slice(1) { updated.push(item) }
        return updated.join()
      }
    }
  }

  content
}

#let collapse-punctuation(content, punctuation-in-quote: false) = {
  if type(content) == str {
    let normalized = content.replace(_re-digit-comma-paren, "$1 (")
    if normalized != content { content = normalized }
  }
  // Apply punctuation rules inside links by recursing into the body
  if content != none and type(content) != str and content.func() == link {
    let fields = content.fields()
    let dest = fields.at("dest", default: none)
    let body = fields.at("body", default: [])
    let collapsed = collapse-punctuation(
      body,
      punctuation-in-quote: punctuation-in-quote,
    )
    if _is-plain-text(collapsed) {
      let s = content-to-string(collapsed)
      let normalized = s.replace(_re-digit-comma-paren, "$1 (")
      if normalized != s {
        collapsed = text(normalized)
      }
    }
    return link(dest, collapsed)
  }
  if content != none and type(content) != str and type(content) != array {
    let fields = content.fields()
    if "child" in fields {
      let updated-child = collapse-punctuation(
        fields.child,
        punctuation-in-quote: punctuation-in-quote,
      )
      if updated-child != fields.child {
        if "styles" in fields {
          return content.func()(updated-child, fields.styles)
        }
        return content.func()(..fields, child: updated-child)
      }
    }
    if "body" in fields and type(fields.body) != str {
      let updated-body = collapse-punctuation(
        fields.body,
        punctuation-in-quote: punctuation-in-quote,
      )
      if updated-body != fields.body {
        if "styles" in fields {
          return content.func()(updated-body, fields.styles)
        }
        let updated-fields = (:)
        for (k, v) in fields.pairs() {
          if k != "body" { updated-fields.insert(k, v) }
        }
        return content.func()(updated-body, ..updated-fields)
      }
    }
  }

  let flat = _flatten-content(content)
  if flat.len() > 0 {
    let updated = ()
    let changed = false
    for item in flat {
      if type(item) == str {
        let normalized = item.replace(_re-digit-comma-paren, "$1 (")
        if normalized != item { changed = true }
        updated.push(normalized)
        continue
      }
      let fields = item.fields()
      if "body" in fields and type(fields.body) == str {
        let normalized = fields.body.replace(_re-digit-comma-paren, "$1 (")
        if normalized != fields.body { changed = true }
        if item.func() == text {
          updated.push(text(normalized))
        } else {
          updated.push(item.func()(..fields, body: normalized))
        }
        continue
      }
      if "text" in fields and type(fields.text) == str {
        let normalized = fields.text.replace(_re-digit-comma-paren, "$1 (")
        if normalized != fields.text { changed = true }
        if item.func() == text {
          updated.push(text(normalized))
        } else {
          updated.push(item.func()(..fields, text: normalized))
        }
        continue
      }
      if "children" in fields {
        let kids = ()
        let changed-kids = false
        for child in fields.children {
          if type(child) == str {
            let normalized = child.replace(_re-digit-comma-paren, "$1 (")
            if normalized != child { changed-kids = true }
            kids.push(normalized)
          } else {
            kids.push(child)
          }
        }
        if changed-kids {
          changed = true
          updated.push(item.func()(..fields, children: kids))
          continue
        }
      }
      updated.push(item)
    }
    if changed { return updated.join() }
  }

  if punctuation-in-quote {
    let flat = _flatten-content(content)
    if flat.len() >= 2 {
      let updated = ()
      let changed = false
      for item in flat {
        if updated.len() > 0 {
          let prev = updated.last()
          let curr-text = _literal-text(item)
          if curr-text == none {
            curr-text = content-to-string(item)
          }
          let punct = if curr-text != none { _leading-punct(curr-text) } else {
            none
          }
          if punct != none {
            let moved-prev = _move-punct-into-quoted(prev, punct)
            if moved-prev != none {
              updated = updated.slice(0, updated.len() - 1)
              updated.push(moved-prev)
              let stripped = _strip-leading-punct-content(item)
              updated.push(stripped)
              changed = true
              continue
            }
            if _is-plain-text(prev) {
              let prev-str = content-to-string(prev)
              let updated-prev = _insert-punct-before-quote(prev-str, punct)
              if updated-prev != none {
                updated = updated.slice(0, updated.len() - 1)
                updated.push(updated-prev)
                let stripped = _strip-leading-punct-content(item)
                updated.push(stripped)
                changed = true
                continue
              }
            }
          }
        }
        updated.push(item)
      }
      if changed {
        return updated.join()
      }
    }

    if flat.len() > 0 {
      let updated = ()
      let changed = false
      for item in flat {
        if type(item) == str {
          let swapped = item.replace("\u{201D},", ",\u{201D}")
          swapped = swapped.replace("\u{2019}\u{201D}.", "\u{2019}.\u{201D}")
          swapped = swapped.replace("\u{2019}.\u{201D}", ".\u{2019}\u{201D}")
          swapped = swapped.replace(_re-digit-comma-paren, "$1 (")
          swapped = _normalize-nested-double-quotes(swapped)
          if swapped != item { changed = true }
          updated.push(swapped)
          continue
        }
        let fields = item.fields()
        if "body" in fields and type(fields.body) == str {
          let swapped = fields.body.replace("\u{201D},", ",\u{201D}")
          swapped = swapped.replace(
            "\u{2019}\u{201D}.",
            "\u{2019}.\u{201D}",
          )
          swapped = swapped.replace("\u{2019}.\u{201D}", ".\u{2019}\u{201D}")
          swapped = swapped.replace(_re-digit-comma-paren, "$1 (")
          let normalized = _normalize-nested-double-quotes(swapped)
          if normalized != fields.body { changed = true }
          if item.func() == text {
            updated.push(text(normalized))
          } else {
            updated.push(item.func()(..fields, body: normalized))
          }
          continue
        }
        if "text" in fields and type(fields.text) == str {
          let swapped = fields.text.replace("\u{201D},", ",\u{201D}")
          swapped = swapped.replace(
            "\u{2019}\u{201D}.",
            "\u{2019}.\u{201D}",
          )
          swapped = swapped.replace("\u{2019}.\u{201D}", ".\u{2019}\u{201D}")
          swapped = swapped.replace(_re-digit-comma-paren, "$1 (")
          let normalized = _normalize-nested-double-quotes(swapped)
          if normalized != fields.text { changed = true }
          if item.func() == text {
            updated.push(text(normalized))
          } else {
            updated.push(item.func()(..fields, text: normalized))
          }
          continue
        }
        updated.push(item)
      }
      if changed {
        return collapse-punctuation(
          updated.join(),
          punctuation-in-quote: punctuation-in-quote,
        )
      }
    }
  }

  // Collapse duplicate punctuation across content boundaries
  let flat = _flatten-content(content)
  if flat.len() >= 2 {
    let updated = ()
    let changed = false
    for i in range(flat.len()) {
      let item = flat.at(i)
      if updated.len() > 0 {
        let prev = updated.last()
        let prev-text = content-to-string(prev)
        let curr-text = _literal-text(item)
        if curr-text == none {
          curr-text = content-to-string(item)
        }
        let curr-full = content-to-string(item)
        let next-text = none
        if i + 1 < flat.len() {
          next-text = _literal-text(flat.at(i + 1))
          if next-text == none {
            next-text = content-to-string(flat.at(i + 1))
          }
        }
        if punctuation-in-quote and curr-full != none {
          let prev-index = updated.len() - 1
          while prev-index >= 0 and is-empty(updated.at(prev-index)) {
            prev-index -= 1
          }
          let prev-item = if prev-index >= 0 {
            updated.at(prev-index)
          } else {
            none
          }
          let prev-text = if prev-item != none {
            content-to-string(prev-item)
          } else {
            none
          }
          let punct = _leading-punct(curr-full)
          if (
            prev-text != none
              and punct != none
              and prev-text.trim().ends-with("\u{201D}")
          ) {
            let moved = _move-punct-into-quoted(prev-item, punct)
            if moved != none {
              if prev-index >= 0 {
                let tail = updated.slice(prev-index + 1)
                updated = updated.slice(0, prev-index)
                updated.push(moved)
                for t in tail { updated.push(t) }
              } else {
                updated = updated.slice(0, updated.len() - 1)
                updated.push(moved)
              }
              updated.push(_strip-leading-punct-content(item))
              changed = true
              continue
            }
          }
        }
        if (
          prev-text != none
            and curr-text != none
            and prev-text.trim().ends-with("\u{2019}")
            and curr-text.match(_re-dot-before-rdquote) != none
        ) {
          let updated-prev = prev-text.replace(_re-rsquote-end, ".\u{2019}")
          if updated-prev != prev-text {
            updated = updated.slice(0, updated.len() - 1)
            if type(prev) == str {
              updated.push(updated-prev)
            } else if prev.func() == text {
              let fields = prev.fields()
              if "body" in fields and type(fields.body) == str {
                let updated-body = fields.body.replace(
                  _re-rsquote-end,
                  ".\u{2019}",
                )
                updated.push(text(updated-body))
              } else if "text" in fields and type(fields.text) == str {
                let updated-text = fields.text.replace(
                  _re-rsquote-end,
                  ".\u{2019}",
                )
                updated.push(text(updated-text))
              } else {
                updated.push(prev)
              }
            } else {
              updated.push(prev)
            }
            updated.push(_strip-leading-punct-content(item))
            changed = true
            continue
          }
        }
        if (
          prev-text != none
            and curr-full != none
            and prev-text.trim().ends-with(",")
            and curr-full.trim().starts-with("(")
            and prev-text.trim().match(_re-digit-comma-end) != none
        ) {
          let cleaned = prev-text.replace(_re-comma-end, " ")
          if cleaned != prev-text {
            updated = updated.slice(0, updated.len() - 1)
            if type(prev) == str {
              updated.push(cleaned)
            } else if prev.func() == text {
              let fields = prev.fields()
              if "body" in fields and type(fields.body) == str {
                let updated-body = fields.body.replace(_re-comma-end, " ")
                updated.push(text(updated-body))
              } else if "text" in fields and type(fields.text) == str {
                let updated-text = fields.text.replace(_re-comma-end, " ")
                updated.push(text(updated-text))
              } else {
                updated.push(prev)
              }
            } else {
              updated.push(prev)
            }
            updated.push(item)
            changed = true
            continue
          }
        }
        let prev-punct = if prev-text != none {
          _trailing-punct(prev-text)
        } else {
          none
        }
        let curr-punct = if curr-text != none {
          _leading-punct(curr-text)
        } else {
          none
        }
        if prev-punct != none and curr-punct == prev-punct {
          let prev-trim = prev-text.trim()
          let prev-only-punct = (
            prev-trim.len() == 1 and prev-trim in (".", ",", ";", ":", "!", "?")
          )
          let curr-delim = false
          if curr-text != none {
            let trimmed = curr-text.trim()
            if trimmed.len() > 1 {
              let rest = trimmed.slice(1).trim()
              if rest.starts-with("–") or rest.starts-with("-") {
                curr-delim = true
              }
            }
          }
          let prev-has-trailing-space = (
            prev-text.ends-with(" ")
              or prev-text.ends-with("\t")
              or prev-text.ends-with("\n")
          )
          if (
            (not prev-only-punct or curr-delim) and not prev-has-trailing-space
          ) {
            updated.push(_strip-leading-punct-content(item))
            changed = true
            continue
          }
        }
      }
      updated.push(item)
    }
    if changed {
      return updated.join()
    }
  }

  if punctuation-in-quote and content != none and type(content) != str {
    let kids = if type(content) == array {
      content
    } else {
      let fields = content.fields()
      if "children" in fields { fields.children } else { none }
    }
    if kids != none {
      if kids.len() >= 2 {
        let last-text = _literal-text(kids.last())
        if last-text == none {
          last-text = content-to-string(kids.last())
        }
        let punct = if last-text != none { _leading-punct(last-text) } else {
          none
        }
        if punct != none {
          let prev = kids.at(kids.len() - 2)
          let moved = _move-punct-into-quoted(prev, punct)
          if moved != none {
            let updated = kids.slice(0, kids.len() - 2)
            updated.push(moved)
            return updated.join()
          }
        }
      }
      let updated = ()
      for item in kids {
        if updated.len() > 0 {
          let prev = updated.last()
          let curr-text = content-to-string(item)
          let punct = if curr-text != none { _leading-punct(curr-text) } else {
            none
          }
          if punct != none {
            let moved-prev = _move-punct-into-quoted(prev, punct)
            if moved-prev != none {
              updated = updated.slice(0, updated.len() - 1)
              updated.push(moved-prev)
              let stripped = _strip-leading-punct-content(item)
              updated.push(stripped)
              continue
            }
          }
        }
        updated.push(item)
      }
      if updated != kids {
        return updated.join()
      }
    }
  }

  // Flatten plain text to allow punctuation rules across boundaries
  let normalized = if _is-plain-text(content) {
    content-to-string(content)
  } else {
    content
  }

  // Rule 0: Multiple spaces collapse to single space
  // This handles cases like delimiter ". " + prefix " (" → ". (" not ".  ("
  show _re-multi-space: " "
  // Rule 0b: Drop comma before parenthetical after a number
  show _re-digit-comma-paren: "$1 ("

  // Rule 1: Duplicate punctuation collapses (keeps first character)
  show _re-dup-dot: it => it.text.first()
  show _re-dup-comma: it => it.text.first()
  show _re-dup-semi: it => it.text.first()
  show _re-dup-colon: it => it.text.first()
  show _re-dup-bang: it => it.text.first()
  show _re-dup-qmark: it => it.text.first()

  // Rule 1b: Duplicate punctuation across closing quotes (keep first)
  show _re-dot-q-dot: it => it.text.clusters().slice(0, 2).join()
  show _re-comma-q-comma: it => it.text.clusters().slice(0, 2).join()
  show _re-semi-q-semi: it => it.text.clusters().slice(0, 2).join()
  show _re-colon-q-colon: it => it.text.clusters().slice(0, 2).join()
  show _re-bang-q-bang: it => it.text.clusters().slice(0, 2).join()
  show _re-qmark-q-qmark: it => it.text.clusters().slice(0, 2).join()

  // Rule 2: Absorption rules from citeproc-js LtoR_MAP
  // "!" absorbs "." and ":"
  show _re-bang-dot: it => it.text.first()
  show _re-bang-colon: it => it.text.first()

  // "?" absorbs "." and ":"
  show _re-qmark-dot: it => it.text.first()
  show _re-qmark-colon: it => it.text.first()

  // ":" absorbs "." only
  show _re-colon-dot: it => it.text.first()

  // ":" is absorbed by "!" and "?"
  show _re-colon-bang: it => it.text.clusters().last()
  show _re-colon-qmark: it => it.text.clusters().last()

  // ";" absorbs "." and ":"
  show _re-semi-dot: it => it.text.first()
  show _re-semi-colon: it => it.text.first()

  // ";" is absorbed by "!" and "?"
  show _re-semi-bang: it => it.text.clusters().last()
  show _re-semi-qmark: it => it.text.clusters().last()

  // Absorption across closing quotes
  show _re-bang-q-colon: it => it.text.clusters().slice(0, 2).join()
  show _re-qmark-q-colon: it => it.text.clusters().slice(0, 2).join()
  show _re-semi-q-colon: it => it.text.clusters().slice(0, 2).join()

  // punctuation-in-quote: move periods and commas inside closing quotes
  if punctuation-in-quote {
    // If a question/exclamation mark is already inside the quote,
    // drop a trailing period after the closing quote.
    show _re-qmark-rdq-dot: it => it.text.clusters().slice(0, 2).join()
    show _re-bang-rdq-dot: it => it.text.clusters().slice(0, 2).join()
    // Right double quote + period/comma → swap them
    // Collapse duplicate period/comma before swapping
    show _re-dot-rdq-dot: it => it.text.clusters().slice(0, 2).join()
    show _re-comma-rdq-comma: it => it.text.clusters().slice(0, 2).join()
    show "\u{201D}.": ".\u{201D}"
    show "\u{201D},": ",\u{201D}"
    normalized
  } else {
    normalized
  }
}
