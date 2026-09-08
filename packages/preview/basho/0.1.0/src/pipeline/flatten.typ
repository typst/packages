// src/flatten.typ
// Content tree traversal for Typst native markup

#import "../pipeline/parser.typ": tokenize
#import "../pipeline/token.typ": merge-token, token

// ---------------------------------------------------------------------------
// Element Handlers
// ---------------------------------------------------------------------------

#let _handle-heading(c, config, flatten-fn) = {
  let tokens = ()
  tokens.push(token("newline", fields: (text: "\n")))
  let level = c.at("depth", default: c.at("level", default: 1))
  tokens.push(token("heading-anchor", fields: (level: level, body: c.body)))
  let inner = flatten-fn(c.body, config)
  inner = inner.map(t => merge-token(t, (heading: level)))
  tokens += inner
  tokens.push(token("parbreak", fields: (text: "\n")))
  tokens
}

#let _handle-link(c, config, flatten-fn) = {
  let dest = c.dest
  let inner = flatten-fn(c.body, config)
  inner.map(t => merge-token(t, (dest: dest)))
}

#let _handle-style(c, config, flatten-fn, fname) = {
  let inner = flatten-fn(c.body, config)
  if fname == "strong" {
    inner.map(t => merge-token(t, (bold: true)))
  } else if fname == "emph" {
    inner.map(t => merge-token(t, (italic: true)))
  } else {
    inner
  }
}

#let _handle-enum(c, config, flatten-fn) = {
  let tokens = ()
  let items = ()
  if c.has("children") {
    if c.children.len() == 1 {
      let only = c.children.at(0)
      if type(only) == content and repr(only.func()) == "item" {
        let inner = only.body
        if (
          type(inner) == content
            and repr(inner.func()) == "sequence"
            and inner.has("children")
        ) {
          for child in inner.children {
            if type(child) == content and repr(child.func()) == "item" {
              items.push(child)
            }
          }
        }
      }
    } else {
      for child in c.children {
        if type(child) == content and repr(child.func()) == "item" {
          items.push(child)
        }
      }
    }
  }

  if items.len() > 0 {
    let start = c.at("start", default: 1)
    for i in range(items.len()) {
      if i > 0 { tokens.push(token("newline", fields: (text: "\n"))) }
      let num = (config.list.numbered.format)(start + i)
      tokens.push(token("tcy", fields: (
        text: num,
        forced: true,
        list-marker: true,
      )))
      let gap = config.list.numbered.gap
      if gap != 0pt { tokens.push(token("spacing", fields: (width: gap))) }
      tokens += flatten-fn(items.at(i).body, config)
    }
  } else {
    tokens += (config.list.numbered.flatten)(c, flatten-fn, config)
  }
  tokens
}

#let _handle-sequence(c, config, flatten-fn) = {
  let tokens = ()
  let seen-item = false
  for child in c.children {
    if type(child) == content and repr(child.func()) == "item" {
      if seen-item { tokens.push(token("newline", fields: (text: "\n"))) }
      tokens.push(token("bullet-list-marker"))
      tokens += flatten-fn(child.body, config)
      seen-item = true
    } else if type(child) == content and repr(child.func()) == "space" {
      // Ignore whitespace nodes inserted by list syntax.
    } else if (
      type(child) == content
        and child.has("children")
        and child.children.len() == 0
    ) {
      // Ignore empty sequence children from list syntax.
    } else if (
      type(child) == content and child.has("text") and child.text == ""
    ) {
      // Ignore empty text nodes.
    } else {
      tokens += flatten-fn(child, config)
    }
  }
  tokens
}

// ---------------------------------------------------------------------------
// Main Flatten Logic
// ---------------------------------------------------------------------------

/// Flattens a native Typst content tree into an array of Basho tokens.
/// This enables support for inline macros (like `#ruby`) and native styling (like `*bold*`).
///
/// - c (content | str | array): The content to flatten.
/// - config (dictionary): The layout configuration.
/// -> array: An array of token dictionaries.
#let flatten(c, config) = {
  let tokens = ()

  if type(c) == array {
    for child in c {
      tokens += flatten(child, config)
    }
  } else if type(c) == str {
    tokens += tokenize(c, config)
  } else if type(c) == content {
    let fname = repr(c.func())
    // Be tolerant to list element shapes to avoid falling back to hblock.
    let is-bullet-list = (
      fname == "list" or (c.has("children") and c.has("marker"))
    )
    let is-numbered-list = (
      fname == "enum" or (c.has("children") and c.has("numbering"))
    )

    if fname == "metadata" {
      if type(c.value) == dictionary and "type" in c.value {
        // Custom macros like ruby() or tcy() injected via metadata
        tokens.push(c.value)
      }
    } else if fname == "equation" {
      let is-block = c.at("block", default: false)
      if is-block {
        tokens.push(token("vblock", fields: (text: c)))
      } else {
        tokens.push(token("turn", fields: (text: c)))
      }
    } else if fname == "space" {
      tokens.push(token("char", fields: (text: " ")))
    } else if fname == "parbreak" {
      tokens.push(token("parbreak", fields: (text: "\n")))
    } else if fname == "linebreak" {
      tokens.push(token("newline", fields: (text: "\n")))
    } else if fname == "heading" {
      tokens += _handle-heading(c, config, flatten)
    } else if fname == "link" {
      tokens += _handle-link(c, config, flatten)
    } else if (
      fname
        in ("strong", "emph", "underline", "strike", "overline", "highlight")
    ) {
      tokens += _handle-style(c, config, flatten, fname)
    } else if fname == "enum" {
      tokens += _handle-enum(c, config, flatten)
    } else if fname == "sequence" and c.has("children") {
      tokens += _handle-sequence(c, config, flatten)
    } else if is-bullet-list {
      tokens += (config.list.bullet.flatten)(c, flatten, config)
    } else if is-numbered-list {
      tokens += (config.list.numbered.flatten)(c, flatten, config)
    } else if c.has("children") {
      for child in c.children {
        tokens += flatten(child, config)
      }
    } else if c.has("text") {
      // Native text elements
      tokens += tokenize(c.text, config)
    } else {
      // Anything else (figures, images, shapes, unhandled blocks)
      tokens.push(token("hblock", fields: (text: c)))
    }
  }

  tokens
}
