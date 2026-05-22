// src/flatten.typ
// Content tree traversal for Typst native markup

#import "../core/parser.typ": tokenize

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
    let is-bullet-list = fname == "list" or (c.has("children") and c.has("marker"))
    let is-numbered-list = fname == "enum" or (c.has("children") and c.has("numbering"))

    if fname == "metadata" {
      if type(c.value) == dictionary and "type" in c.value {
        // Custom macros like ruby() or tcy() injected via metadata
        tokens.push(c.value)
      }
    } else if fname == "equation" {
      let is-block = c.at("block", default: false)
      if is-block {
        tokens.push((type: "vblock", text: c))
      } else {
        tokens.push((type: "turn", text: c))
      }
    } else if fname == "space" {
      tokens.push((type: "char", text: " "))
    } else if fname == "parbreak" or fname == "linebreak" {
      tokens.push((type: "newline", text: "\n"))
    } else if fname == "heading" {
      tokens.push((type: "newline", text: "\n"))
      let level = c.at("depth", default: c.at("level", default: 1))
      tokens.push((type: "heading-anchor", level: level, body: c.body))
      let inner = flatten(c.body, config)
      inner = inner.map(t => t + (heading: level))
      tokens += inner
      tokens.push((type: "newline", text: "\n"))
    } else if fname == "link" {
      let dest = c.dest
      let inner = flatten(c.body, config)
      inner = inner.map(t => t + (dest: dest))
      tokens += inner
    } else if fname in ("strong", "emph", "underline", "strike", "overline", "highlight") {
      // Inline formatting elements
      let inner = flatten(c.body, config)
      if fname == "strong" {
        inner = inner.map(t => t + (bold: true))
      } else if fname == "emph" {
        inner = inner.map(t => t + (italic: true))
      }
      tokens += inner
    } else if fname == "enum" {
      let items = ()
      if c.has("children") {
        if c.children.len() == 1 {
          let only = c.children.at(0)
          if type(only) == content and repr(only.func()) == "item" {
            let inner = only.body
            if type(inner) == content and repr(inner.func()) == "sequence" and inner.has("children") {
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
          if i > 0 { tokens.push((type: "newline", text: "\n")) }
          let num = (config.list.numbered.format)(start + i)
          tokens.push((type: "tcy", text: num, forced: true))
          let gap = config.list.numbered.gap
          if gap != 0pt { tokens.push((type: "spacing", width: gap)) }
          tokens += flatten(items.at(i).body, config)
        }
      } else {
        tokens += (config.list.numbered.flatten)(c, flatten, config)
      }
    } else if fname == "sequence" and c.has("children") {
      let seen-item = false
      for child in c.children {
        if type(child) == content and repr(child.func()) == "item" {
          if seen-item { tokens.push((type: "newline", text: "\n")) }
          tokens.push((type: "bullet-list-marker"))
          tokens += flatten(child.body, config)
          seen-item = true
        } else if type(child) == content and repr(child.func()) == "space" {
          // Ignore whitespace nodes inserted by list syntax.
        } else if type(child) == content and child.has("children") and child.children.len() == 0 {
          // Ignore empty sequence children from list syntax.
        } else if type(child) == content and child.has("text") and child.text == "" {
          // Ignore empty text nodes.
        } else {
          tokens += flatten(child, config)
        }
      }
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
      tokens.push((type: "hblock", text: c))
    }
  }

  tokens
}
