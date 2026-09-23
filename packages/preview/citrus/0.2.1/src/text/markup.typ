// citrus - HTML-like inline markup support
//
// CSL-JSON processors commonly recognize a small HTML-like subset in text
// variables. This is not a general HTML parser; unsupported or unclosed tags
// are preserved as literal text.

#let _tag-pattern = regex(
  "(?i)</?(?:i|b|sc|sup|sub)>|<span(?:\\s+[^>]*)?>|</span>",
)

#let _span-attr-double = regex("(?i)([a-z][a-z0-9_-]*)\\s*=\\s*\"([^\"]*)\"")
#let _span-attr-single = regex("(?i)([a-z][a-z0-9_-]*)\\s*=\\s*'([^']*)'")

#let _has-formatting-attr(attrs) = {
  (
    attrs.at("font-style", default: none) != none
      or attrs.at("font-weight", default: none) != none
      or attrs.at("font-variant", default: none) != none
      or attrs.at("text-decoration", default: none) != none
      or attrs.at("vertical-align", default: none) != none
      or attrs.at("display", default: none) != none
  )
}

#let has-inline-markup(value) = {
  (
    type(value) == str
      and value.contains("<")
      and value.contains(">")
      and value.match(_tag-pattern) != none
  )
}

#let _span-attrs(tag) = {
  let attrs = (:)
  for m in tag.matches(_span-attr-double) {
    attrs.insert(lower(m.captures.at(0)), m.captures.at(1))
  }
  for m in tag.matches(_span-attr-single) {
    attrs.insert(lower(m.captures.at(0)), m.captures.at(1))
  }
  attrs
}

#let _span-has-class(attrs, name) = {
  let value = attrs.at("class", default: none)
  if value == none { return false }
  value.split(regex("\\s+")).any(part => lower(part) == name)
}

#let _span-style-has(attrs, prop, value) = {
  let style = attrs.at("style", default: none)
  if style == none { return false }
  for decl in style.split(";") {
    let parts = decl.split(":")
    if parts.len() >= 2 {
      let key = lower(parts.first().trim())
      let val = lower(parts.slice(1).join(":").trim())
      if key == prop and val == value {
        return true
      }
    }
  }
  false
}

#let _tag-info(tag) = {
  let t = lower(tag)
  if t == "<i>" {
    (name: "i", close: "i", attr: "font-style", value: "italic")
  } else if t == "<b>" {
    (name: "b", close: "b", attr: "font-weight", value: "bold")
  } else if t == "<sc>" {
    (name: "sc", close: "sc", attr: "font-variant", value: "small-caps")
  } else if t == "<sup>" {
    (name: "sup", close: "sup", attr: "vertical-align", value: "sup")
  } else if t == "<sub>" {
    (name: "sub", close: "sub", attr: "vertical-align", value: "sub")
  } else if t.starts-with("<span") {
    let attrs = _span-attrs(tag)
    if _span-has-class(attrs, "nodecor") {
      (name: "nodecor", close: "span", attr: none, value: none)
    } else if _span-style-has(attrs, "font-variant", "small-caps") {
      (name: "sc", close: "span", attr: "font-variant", value: "small-caps")
    } else if _span-has-class(attrs, "nocase") {
      (name: "nocase", close: "span", attr: none, value: none)
    } else {
      none
    }
  } else {
    none
  }
}

#let _closing-name(tag) = {
  let t = lower(tag)
  if t == "</i>" {
    "i"
  } else if t == "</b>" {
    "b"
  } else if t == "</sc>" {
    "sc"
  } else if t == "</sup>" {
    "sup"
  } else if t == "</sub>" {
    "sub"
  } else if t == "</span>" {
    "span"
  } else {
    none
  }
}

#let _append-node(frames, node) = {
  let frame = frames.pop()
  let children = frame.children
  children.push(node)
  frame.insert("children", children)
  frames.push(frame)
  frames
}

#let _nodes-to-source(nodes) = {
  let out = ()
  for node in nodes {
    if node.kind == "text" {
      out.push(node.text)
    } else {
      out.push(node.opener)
      out.push(_nodes-to-source(node.children))
      out.push(node.closer)
    }
  }
  out.join("")
}

#let parse-inline-markup(source) = {
  if type(source) != str or source == "" {
    return ((kind: "text", text: str(source)),)
  }

  let frames = (
    (tag: "root", close: none, opener: "", closer: "", children: ()),
  )
  let last = 0

  for m in source.matches(_tag-pattern) {
    if m.start > last {
      frames = _append-node(
        frames,
        (kind: "text", text: source.slice(last, m.start)),
      )
    }

    let tag = m.text
    let opener = _tag-info(tag)
    if opener != none {
      frames.push((
        tag: opener.name,
        close: opener.close,
        opener: tag,
        closer: if opener.close == "span" {
          "</span>"
        } else {
          "</" + opener.close + ">"
        },
        attr: opener.attr,
        value: opener.value,
        children: (),
      ))
    } else {
      let close = _closing-name(tag)
      if close != none and frames.len() > 1 and frames.last().close == close {
        let frame = frames.pop()
        frames = _append-node(frames, (
          kind: "tag",
          tag: frame.tag,
          close: frame.close,
          opener: frame.opener,
          closer: tag,
          attr: frame.at("attr", default: none),
          value: frame.at("value", default: none),
          children: frame.children,
        ))
      } else {
        frames = _append-node(frames, (kind: "text", text: tag))
      }
    }
    last = m.end
  }

  if last < source.len() {
    frames = _append-node(frames, (kind: "text", text: source.slice(last)))
  }

  while frames.len() > 1 {
    let frame = frames.pop()
    frames = _append-node(
      frames,
      (kind: "text", text: frame.opener + _nodes-to-source(frame.children)),
    )
  }

  frames.first().children
}

#let _nodes-plain(nodes) = {
  let out = ()
  for node in nodes {
    if node.kind == "text" {
      out.push(node.text)
    } else {
      out.push(_nodes-plain(node.children))
    }
  }
  out.join("")
}

#let inline-markup-plain-text(nodes) = _nodes-plain(nodes)

#let strip-inline-markup(value) = {
  if not has-inline-markup(value) { return value }
  _nodes-plain(parse-inline-markup(value))
}

#let _protects-text-case(node) = {
  ("nocase", "nodecor", "sc", "sup", "sub").contains(node.tag)
}

#let _case-nodes(nodes, cased, pos, protected) = {
  let out = ()
  let cursor = pos
  for node in nodes {
    if node.kind == "text" {
      let text = node.text
      let next = cursor + text.len()
      let updated = if protected {
        text
      } else {
        cased.slice(cursor, next)
      }
      out.push((kind: "text", text: updated))
      cursor = next
    } else {
      let child = _case-nodes(
        node.children,
        cased,
        cursor,
        protected or _protects-text-case(node),
      )
      let updated = node
      updated.insert("children", child.nodes)
      out.push(updated)
      cursor = child.pos
    }
  }
  (nodes: out, pos: cursor)
}

#let _quote-nodes(nodes, quote-func, ctx, level, protected) = {
  let out = ()
  for node in nodes {
    if node.kind == "text" {
      out.push((
        kind: "text",
        text: if protected { node.text } else {
          quote-func(node.text, ctx, level)
        },
      ))
    } else {
      let updated = node
      updated.insert(
        "children",
        _quote-nodes(node.children, quote-func, ctx, level, true),
      )
      out.push(updated)
    }
  }
  out
}

#let prepare-inline-markup(
  source,
  attrs,
  ctx,
  case-func: none,
  quote-func: none,
  quote-level: 0,
  has-quotes: false,
) = {
  let nodes = parse-inline-markup(source)

  if case-func != none and attrs.at("text-case", default: none) != none {
    let plain = _nodes-plain(nodes)
    let cased = case-func(plain, attrs, ctx)
    nodes = _case-nodes(nodes, cased, 0, false).nodes
  }

  if quote-func != none {
    let level = if has-quotes { quote-level + 1 } else { quote-level }
    nodes = _quote-nodes(nodes, quote-func, ctx, level, false)
  }

  nodes
}

#let _style-from-attrs(attrs) = {
  let style = (:)
  let font-style = attrs.at("font-style", default: none)
  if font-style == "italic" or font-style == "oblique" {
    style.insert("font-style", "italic")
  }
  if attrs.at("font-weight", default: none) == "bold" {
    style.insert("font-weight", "bold")
  }
  if attrs.at("font-variant", default: none) == "small-caps" {
    style.insert("font-variant", "small-caps")
  }
  let vertical = attrs.at("vertical-align", default: none)
  if vertical == "sup" or vertical == "sub" {
    style.insert("vertical-align", vertical)
  }
  style
}

#let _flip-value(attr, value, inherited) = {
  let current = inherited.at(attr, default: "normal")
  if attr == "font-style" and value == "italic" {
    if current == "italic" { "normal" } else { "italic" }
  } else if attr == "font-weight" and value == "bold" {
    if current == "bold" { "normal" } else { "bold" }
  } else if attr == "font-variant" and value == "small-caps" {
    if current == "small-caps" { "normal" } else { "small-caps" }
  } else {
    value
  }
}

#let _wrap-html-or-native(attr, value, body, output-target) = context {
  let effective-target = if output-target == "auto" { target() } else {
    output-target
  }
  if effective-target == "html" {
    if attr == "font-style" and value == "italic" {
      html.elem("i", body)
    } else if attr == "font-style" and value == "normal" {
      html.elem("span", attrs: (style: "font-style:normal;"), body)
    } else if attr == "font-weight" and value == "bold" {
      html.elem("b", body)
    } else if attr == "font-weight" and value == "normal" {
      html.elem("span", attrs: (style: "font-weight:normal;"), body)
    } else if attr == "font-variant" and value == "small-caps" {
      html.elem("span", attrs: (style: "font-variant:small-caps;"), body)
    } else if attr == "font-variant" and value == "normal" {
      html.elem("span", attrs: (style: "font-variant:normal;"), body)
    } else if attr == "vertical-align" and value == "sup" {
      html.elem("sup", body)
    } else if attr == "vertical-align" and value == "sub" {
      html.elem("sub", body)
    } else {
      body
    }
  } else {
    if attr == "font-style" and value == "italic" {
      emph(body)
    } else if attr == "font-style" and value == "normal" {
      text(style: "normal", body)
    } else if attr == "font-weight" and value == "bold" {
      strong(body)
    } else if attr == "font-weight" and value == "normal" {
      text(weight: "regular", body)
    } else if attr == "font-variant" and value == "small-caps" {
      smallcaps(body)
    } else if attr == "vertical-align" and value == "sup" {
      super(body)
    } else if attr == "vertical-align" and value == "sub" {
      sub(body)
    } else {
      body
    }
  }
}

#let _render-nodes(nodes, inherited, output-target) = {
  let out = ()
  for node in nodes {
    if node.kind == "text" {
      out.push(node.text)
    } else if node.tag == "nocase" {
      out.push(_render-nodes(node.children, inherited, output-target))
    } else if node.tag == "nodecor" {
      let child-inherited = inherited
      let resets = ()
      for attr in ("font-style", "font-weight", "font-variant") {
        if inherited.at(attr, default: "normal") != "normal" {
          child-inherited.insert(attr, "normal")
          resets.push((attr: attr, value: "normal"))
        }
      }
      let body = _render-nodes(node.children, child-inherited, output-target)
      for reset in resets.rev() {
        body = _wrap-html-or-native(
          reset.attr,
          reset.value,
          body,
          output-target,
        )
      }
      out.push(body)
    } else {
      let attr = node.attr
      let value = _flip-value(attr, node.value, inherited)
      let child-inherited = inherited
      child-inherited.insert(attr, value)
      let body = _render-nodes(node.children, child-inherited, output-target)
      out.push(_wrap-html-or-native(attr, value, body, output-target))
    }
  }
  out.join()
}

#let render-inline-markup(
  source,
  attrs: (:),
  nodes: none,
  output-target: "auto",
) = {
  let parsed = if nodes == none { parse-inline-markup(source) } else { nodes }
  _render-nodes(parsed, _style-from-attrs(attrs), output-target)
}

#let should-defer-inline-value(attrs) = {
  (
    attrs.len() <= 1
      or (
        not _has-formatting-attr(attrs)
          and attrs.at("text-case", default: none) == none
          and attrs.at("quotes", default: "false") != "true"
          and attrs.at("prefix", default: "") == ""
          and attrs.at("suffix", default: "") == ""
          and attrs.at("strip-periods", default: "false") != "true"
      )
  )
}
