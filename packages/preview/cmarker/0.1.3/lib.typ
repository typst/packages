#let _p = plugin("./plugin.wasm")
#let render(
  markdown,
  smart-punctuation: true,
  blockquote: none,
  math: none,
  h1-level: 1,
  raw-typst: true,
  html: (:),
  scope: (:),
  show-source: false,
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
  let untag-children(content, tag) = {
    if type(tag) != array {
      tag = (tag,)
    }
    if tag.any(t => is-tagged(content, t)) {
      (untag-content(content),)
    } else {
      content.children.filter(c => tag.any(t => is-tagged(c, t))).map(untag-content)
    }
  }

  if type(markdown) == content and markdown.has("text") {
    markdown = markdown.text
  }

  scope = (rule: line.with(length: 100%), ..scope)

  html = (
    sub: (attrs, body) => sub(body),
    sup: (attrs, body) => super(body),
    mark: (attrs, body) => highlight(body),
    h1: (attrs, body) => scope.at("heading", default: heading)(level: h1-level + 0, body),
    h2: (attrs, body) => scope.at("heading", default: heading)(level: h1-level + 1, body),
    h3: (attrs, body) => scope.at("heading", default: heading)(level: h1-level + 2, body),
    h4: (attrs, body) => scope.at("heading", default: heading)(level: h1-level + 3, body),
    h5: (attrs, body) => scope.at("heading", default: heading)(level: h1-level + 4, body),
    h6: (attrs, body) => scope.at("heading", default: heading)(level: h1-level + 5, body),

    li: (attrs, body) => tag-content(body, "<li>"),
    ul: (attrs, body) => list(..untag-children(body, "<li>").map(((_, _, c)) => c)),
    ol: (attrs, body) => enum(..untag-children(body, "<li>").map(((_, _, c)) => c)),

    dt: (attrs, body) => tag-content(body, "<dt>"),
    dd: (attrs, body) => tag-content(body, "<dd>"),
    dl: (attrs, body) => terms(..(
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
      let start_i = 0
      for (k, section) in rows {
        rows.insert(k, section.enumerate().map(((i, row)) => {
          row = row.map(((_, attrs, td)) => {
            let rowspan = int(attrs.at("rowspan", default: "1"))
            let colspan = int(attrs.at("colspan", default: "1"))
            table.cell(rowspan: rowspan, colspan: colspan, y: start_i + i, td)
          })
          row
        }))
        start_i += section.len()
      }
      let args = ()
      if rows.header.len() != 0 {
        args.push(table.header(..rows.header.flatten()))
      }
      args += rows.body.flatten()
      if rows.footer.len() != 0 {
        args.push(table.footer(..rows.footer.flatten()))
      }
      table(columns: columns, ..args)
    },


    hr: ("void", (attrs) => (scope.rule)()),
    a: (attrs, body) => scope.at("link", default: link)(
      if attrs.href.starts-with("#") { label(attrs.href.slice(1)) } else { attrs.href },
      body,
    ),
    em: (attrs, body) => scope.at("emph", default: emph)(body),
    strong: (attrs, body) => scope.at("strong", default: strong)(body),
    s: (attrs, body) => scope.at("strike", default: strike)(body),
    code: ("raw-text", (attrs, body) => scope.at("raw", default: raw)(body)),
    br: ("void", (attrs) => scope.at("linebreak", default: linebreak)()),
    img: ("void", (attrs) => scope.at("image", default: image)(attrs.src, alt: attrs.at("alt", default: none))),
    ..html,
  )

  let options = 0
  if smart-punctuation {
    options += 0b00000001
  }
  if blockquote != none {
    options += 0b00000010
    scope += (blockquote: blockquote)
    html += (blockquote: (attrs, body) => blockquote(body), ..html)
  }
  if raw-typst {
    options += 0b00000100
  }
  if math != none {
    options += 0b00001000
    scope += (inlinemath: math.with(block: false), displaymath: math.with(block: true))
  }

  let options-bytes = (options, h1-level)

  scope.html = (:)
  for (tag-name, value) in html {
    let (kind, callback) = if type(value) == function { ("normal", value) } else { value };
    scope.html.insert(tag-name, callback)
    for byte in bytes(tag-name) {
      options-bytes.push(byte)
    }
    options-bytes.push(if kind == "void" {
      0xFC
    } else if kind == "raw-text" {
      0xFD
    } else if kind == "escapable-raw-text" {
      0xFE
    } else if kind == "normal" {
      0xFF
    })
  }

  let rendered = str(_p.render(bytes(markdown), bytes(options-bytes)))
  if show-source {
    raw(rendered, block: true, lang: "typ")
  } else {
    eval(rendered, mode: "markup", scope: scope)
  }
}
