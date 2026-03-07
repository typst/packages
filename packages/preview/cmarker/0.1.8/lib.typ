#let _p = plugin("./plugin.wasm")
#let render-with-metadata(
  markdown,
  smart-punctuation: true,
  math: none,
  h1-level: 1,
  raw-typst: true,
  html: (:),
  label-prefix: "",
  prefix-label-uses: true,
  heading-labels: "github",
  scope: (:),
  show-source: false,
  blockquote: none,
  metadata-block: none
) = {
  // A simple system for tagging content with invisible metadata.
  // Used to implement various HTML tags that need some amount of structure.
  let tag-content(content, tag, data: none) = [#metadata((tag, data))#content]
  let is-tagged(content, tag) = (
    content.func() == [].func()
      and content.children.len() == 2
      and content.children.at(0).func() == metadata
      and content.children.at(0).value.len() == 2
      and content.children.at(0).value.at(0) == tag
  )
  let untag-content(content) = (..content.children.at(0).value, content.children.at(1))
  let take-tagged-children(content, tag) = {
    if type(tag) != array {
      tag = (tag,)
    }
    let tagged = ()
    let rest = ()
    if tag.any(t => is-tagged(content, t)) {
      tagged.push(untag-content(content))
    } else if content.func() == [].func() {
      for child in content.children {
        if tag.any(t => is-tagged(child, t)) {
          tagged.push(untag-content(child))
        } else {
          rest.push(child)
        }
      }
    } else {
      rest.push(content)
    }
    (tagged: tagged, rest: for r in rest { r })
  }
  let untag-children(content, tag) = take-tagged-children(content, tag).tagged

  if type(markdown) == content and markdown.has("text") {
    markdown = markdown.text
  }
  assert(type(markdown) == str, message: "Markdown must be a string")

  scope = (rule: line.with(length: 100%), ..scope)

  if blockquote != none {
    assert(type(blockquote) == function, message: "blockquote must be a function")
    scope += (
      quote: (block: false, ..rest) => if block { blockquote(..rest) } else { quote(..rest) },
    )
  }

  let labelify(content, attrs) = {
    if "id" in attrs {
      [#content #label(label-prefix + attrs.id)]
    } else {
      content
    }
  }

  assert(type(label-prefix) == str, message: "label-prefix must be a string")
  let label-use-prefix = if prefix-label-uses { label-prefix } else { "" }

  let heading-fn(level) = (attrs, body) => {
    let level = h1-level + level
    if level < 0 {
      body
    } else if level == 0 {
      set document(title: body)
      title()
    } else {
      labelify(scope.at("heading", default: heading)(level: level, body), attrs)
    }
  }

  html = (
    sub: (attrs, body) => scope.at("sub", default: sub)(body),
    sup: (attrs, body) => scope.at("sup", default: super)(body),
    mark: (attrs, body) => scope.at("highlight", default: highlight)(body),
    h1: heading-fn(0),
    h2: heading-fn(1),
    h3: heading-fn(2),
    h4: heading-fn(3),
    h5: heading-fn(4),
    h6: heading-fn(5),

    li: (attrs, body) => tag-content(body, "<li>"),
    ul: (attrs, body) => {
      scope.at("list", default: list)(..untag-children(body, "<li>").map(((_, _, c)) => c))
    },
    ol: (attrs, body) => {
      scope.at("enum", default: enum)(..untag-children(body, "<li>").map(((_, _, c)) => c))
    },

    dt: (attrs, body) => tag-content(body, "<dt>"),
    dd: (attrs, body) => tag-content(body, "<dd>"),
    dl: (attrs, body) => scope.at("terms", default: terms)(..(
      untag-children(body, ("<dt>", "<dd>"))
        .map(((_, _, c)) => c)
        .chunks(2, exact: true)
    )),

    tr: (attrs, body) => tag-content(body, "<tr>"),
    thead: (attrs, body) => tag-content(body, "<thead>"),
    tfoot: (attrs, body) => tag-content(body, "<tfoot>"),
    th: (attrs, body) => tag-content(body, "<td>", data: attrs),
    td: (attrs, body) => tag-content(body, "<td>", data: attrs),
    table: (attrs, body) => {
      let rows = (header: (), body: (), footer: ())
      for (tag, _, child) in untag-children(body, ("<tr>", "<thead>", "<tfoot>")) {
        if tag == "<thead>" {
          for (_, _, row) in untag-children(child, "<tr>") {
            rows.header.push(untag-children(row, "<td>"))
          }
        } else if tag == "<tfoot>" {
          for (_, _, row) in untag-children(child, "<tr>") {
            rows.footer.push(untag-children(row, "<td>"))
          }
        } else if tag == "<tr>" {
          rows.body.push(untag-children(child, "<td>"))
        }
      }
      // FIXME: This is likely buggy for exotic uses of rowspan and colspan.
      let columns = calc.max(
        ..rows.header.map(r => r.len()),
        ..rows.body.map(r => r.len()),
        ..rows.footer.map(r => r.len()),
      )
      let start-i = 0
      for (k, section) in rows {
        rows.insert(k, section.enumerate().map(((i, row)) => {
          row = row.map(((_, attrs, td)) => {
            let rowspan = int(attrs.at("rowspan", default: "1"))
            let colspan = int(attrs.at("colspan", default: "1"))
            table.cell(rowspan: rowspan, colspan: colspan, y: start-i + i, td)
          })
          row
        }))
        start-i += section.len()
      }
      let args = ()
      if rows.header.len() != 0 {
        args.push(table.header(..rows.header.flatten()))
      }
      args += rows.body.flatten()
      if rows.footer.len() != 0 {
        args.push(table.footer(..rows.footer.flatten()))
      }
      scope.at("table", default: table)(columns: columns, ..args)
    },

    figcaption: (attrs, body) => tag-content(body, "<figcaption>"),
    figure: (attrs, body) => {
      let (tagged: captions, rest) = take-tagged-children(body, "<figcaption>")
      let caption = if captions.len() >= 1 { captions.at(0).at(2) } else { none }
      labelify(figure(caption: caption, rest), attrs)
    },

    hr: ("void", (attrs) => (scope.rule)()),
    a: (attrs, body) => scope.at("link", default: link)(
      if attrs.href.starts-with("#") {
        label(label-use-prefix + attrs.href.slice(1))
      } else {
        attrs.href
      },
      body,
    ),
    em: (attrs, body) => scope.at("emph", default: emph)(body),
    strong: (attrs, body) => scope.at("strong", default: strong)(body),
    s: (attrs, body) => scope.at("strike", default: strike)(body),
    code: ("raw-text", (attrs, body) => scope.at("raw", default: raw)(body)),
    br: ("void", (attrs) => scope.at("linebreak", default: linebreak)()),
    img: ("void", (attrs) => scope.at("image", default: image)(attrs.src, alt: attrs.at("alt", default: none))),
    blockquote: (attrs, body) => scope.at("quote", default: quote)(block: true, body),

    svg: ("raw-text", (attrs, body) => {
      let escape(s) = {
        for c in s {
          if c == "\"" {
            "&quot;"
          } else if c == "&" {
            "&amp;"
          } else {
            c
          }
        }
      }

      let attrs = attrs.pairs().map(((k, v)) => k + "=\"" + escape(v) + "\"").join(" ")
      let svg = "<svg " + attrs + ">" + body + "</svg>"
      scope.at("image", default: image)(bytes(svg), format: "svg")
    }),

    ..html,
  )

  let flags = 0
  if smart-punctuation {
    flags += 0b00000001
  }
  if raw-typst {
    flags += 0b00000010
  }
  if math != none {
    assert(type(math) == function, message: "math must be a function")
    flags += 0b00000100
    scope += (inlinemath: math.with(block: false), displaymath: math.with(block: true))
  }

  let heading-labels = {
    if heading-labels == "github" { 0 }
    else if heading-labels == "jupyter" { 1 }
    else { assert(false, message: "invalid heading-labels") }
  }

  assert(type(h1-level) == int, message: "h1-level must be an integer")
  assert(-128 <= h1-level and h1-level <= 127, message: "h1-level must be in the range [-128, 127]")
  h1-level = if h1-level < 0 { 256 + h1-level } else { h1-level }

  let options-bytes = (flags, h1-level, heading-labels)

  options-bytes += array(bytes(label-prefix)) + (0xFF,)
  options-bytes += array(bytes(label-use-prefix)) + (0xFF,)

  scope.html = (:)
  for (tag-name, value) in html {
    let (kind, callback) = if type(value) == function { ("normal", value) } else { value }
    assert(type(callback) == function, message: "HTML callback must be a function")
    scope.html.insert(tag-name, callback)
    options-bytes += array(bytes(tag-name))
    options-bytes.push(if kind == "void" {
      0xFC
    } else if kind == "raw-text" {
      0xFD
    } else if kind == "escapable-raw-text" {
      0xFE
    } else if kind == "normal" {
      0xFF
    } else {
      assert(false, message: "invalid HTML tag kind for <" + tag-name + "> (expected void, raw-text, escapable-raw-text or normal)")
    })
  }

  // Transforms the following:
  // ```md
  // ---
  // frontmatter
  // ---
  // content
  // ```
  // into the tuple (frontmatter, content) of type (str, str).
  //
  // The frontmatter is left as a string to let the user
  // decide the metadata format i.e. yaml, toml, etc.
  //
  // A YAML metadata block is a valid YAML object,
  // [1] delimited by a line of three hyphens (---) at the top
  // [2] and a line of three hyphens (---) or three dots (...) at the bottom.
  // [3] The initial line --- must not be followed by a blank line.
  let extract-frontmatter(s) = {
    let original = s

    let start-match = s.match(regex("^---[ \t\r]*\n"))
    if start-match == none {
      return ("", original)
    }
    s = s.slice(start-match.end)

    if s.starts-with(regex("[ \t\r]*\n")) {
      return ("", original)
    }

    let end-match = s.match(regex("\n(---|\.\.\.)[ \t\r]*\n"))
    if end-match == none {
      return ("", original)
    }

    return (s.slice(0, end-match.start), s.slice(end-match.end))
  }

  let (markdown-frontmatter, markdown) = if metadata-block != none {
     extract-frontmatter(markdown)
  } else {
    (none, markdown)
  }
  let rendered = str(_p.render(bytes(markdown), bytes(options-bytes)))

  let body = if show-source {
    raw(rendered, block: true, lang: "typ")
  } else {
    eval(rendered, mode: "markup", scope: scope)
  }

  let metadata-block-content = if metadata-block == "frontmatter-raw" {
    markdown-frontmatter
  } else if metadata-block == "frontmatter-yaml" {
    yaml(bytes(markdown-frontmatter))
  } else if metadata-block != none {
    let message = "invalid metadata-block value `" + metadata-block + "` (expected `frontmatter-raw` or `frontmatter-yaml`)"
    assert(false, message: message)
  }

  (metadata-block-content, body)
}

#let render(
  markdown,
  smart-punctuation: true,
  math: none,
  h1-level: 1,
  raw-typst: true,
  html: (:),
  label-prefix: "",
  prefix-label-uses: true,
  heading-labels: "github",
  scope: (:),
  show-source: false,
  blockquote: none
) = {
  let (meta, body) = render-with-metadata(
    markdown,
    smart-punctuation: smart-punctuation,
    math: math,
    h1-level: h1-level,
    raw-typst: raw-typst,
    html: html,
    label-prefix: label-prefix,
    prefix-label-uses: prefix-label-uses,
    heading-labels: heading-labels,
    scope: scope,
    show-source: show-source,
    blockquote: blockquote,
    metadata-block: none,
  )
  body
}
