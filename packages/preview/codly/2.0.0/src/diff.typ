#let language(lang) = {
  if lang == none or not (lang.starts-with("diff-") or lang.starts-with("diff,")) {
    return none
  }
  let language = lang.slice(5).trim()
  assert(
    language != "" and not language.contains(","),
    message: "codly: diff requires one nonempty language after `diff-` or `diff,`",
  )
  language
}

// Each hunk has independent old/new syntax state. Metadata never enters either
// source view; within a hunk only the single patch prefix is removed.
#let parse(source, old-offset: 0, new-offset: 0) = {
  let source = source.split(regex("\r\n|\r|\n"))
  let patch = source.any(line => line.starts-with("diff --git ") or line.starts-with("@@"))
  assert(
    not source.any(line => (
      line.starts-with("diff --cc ")
        or line.starts-with("diff --combined ")
        or line.starts-with("@@@ ")
    )),
    message: "codly: combined merge diffs are not supported",
  )
  let rows = ()
  let groups = ((old: (), new: ()),)
  let old-number = old-offset + 1
  let new-number = new-offset + 1
  let old-left = 0
  let new-left = 0
  let in-hunk = false
  let hunk = regex("^@@ -([0-9]+)(?:,([0-9]+))? \\+([0-9]+)(?:,([0-9]+))? @@")
  for original in source {
    let kind = if original.starts-with("\\ No newline at end of file") { "meta" } else { "context" }
    let text = original
    if patch {
      let match = original.match(hunk)
      if match != none {
        assert(not in-hunk, message: "codly: incomplete unified diff hunk")
        if groups.last().old.len() > 0 or groups.last().new.len() > 0 {
          groups.push((old: (), new: ()))
        }
        old-number = int(match.captures.at(0)) + old-offset
        new-number = int(match.captures.at(2)) + new-offset
        let old-count = match.captures.at(1)
        let new-count = match.captures.at(3)
        old-left = if old-count == none { 1 } else { int(old-count) }
        new-left = if new-count == none { 1 } else { int(new-count) }
        in-hunk = old-left > 0 or new-left > 0
        kind = "meta"
      } else if original.starts-with("@@") {
        panic("codly: invalid unified diff hunk header")
      } else if original.starts-with("diff --git ") {
        assert(not in-hunk, message: "codly: incomplete unified diff hunk")
        in-hunk = false
        kind = "meta"
      } else if not in-hunk or original.starts-with("\\ No newline at end of file") {
        kind = "meta"
        assert(
          not original.starts-with(regex("^[ +\\-]"))
            or original.starts-with("--- ")
            or original.starts-with("+++ "),
          message: "codly: unified diff hunk counts do not match its lines",
        )
      }
    }
    if kind != "meta" {
      if original.starts-with("+") {
        kind = "added"
        text = original.slice(1)
      } else if original.starts-with("-") {
        kind = "removed"
        text = original.slice(1)
      } else if original.starts-with(" ") {
        text = original.slice(1)
      } else if patch {
        panic("codly: unified diff code lines must have a context, added, or removed prefix")
      }
    }
    let old = none
    let new = none
    let old-index = none
    let new-index = none
    if kind in ("removed", "context") {
      old = old-number
      old-number += 1
      old-index = groups.last().old.len()
      groups.last().old.push(text)
      if patch { old-left -= 1 }
    }
    if kind in ("added", "context") {
      new = new-number
      new-number += 1
      new-index = groups.last().new.len()
      groups.last().new.push(text)
      if patch { new-left -= 1 }
    }
    if patch {
      assert(
        old-left >= 0 and new-left >= 0,
        message: "codly: unified diff hunk counts do not match its lines",
      )
      if old-left == 0 and new-left == 0 { in-hunk = false }
    }
    rows.push((
      kind: kind,
      text: text,
      original: original,
      old: old,
      new: new,
      old-index: old-index,
      new-index: new-index,
      group: if kind == "meta" { none } else { groups.len() - 1 },
    ))
  }
  assert(not in-hunk, message: "codly: incomplete unified diff hunk")
  (rows: rows, groups: groups)
}

#let sublangs(segments, rows, group, side) = {
  if segments == none { return none }
  let mapped = ()
  for segment in segments {
    let indices = ()
    for (index, row) in rows.enumerate() {
      let at = row.at(side + "-index")
      if (
        index + 1 >= segment.start
          and index + 1 <= segment.end
          and row.group == group
          and at != none
      ) {
        indices.push(at + 1)
      }
    }
    if indices.len() > 0 {
      mapped.push((start: indices.first(), end: indices.last(), lang: segment.lang))
    }
  }
  mapped
}

#let resource(value, inherited, name) = {
  let safe = type(value) != str and (type(value) != array or value.all(v => type(v) != str))
  assert(
    safe or value == inherited,
    message: "codly: diff cannot copy an explicit string `raw."
      + name
      + "`; use `path(...)` or `read(..., encoding: none)`",
  )
  if safe { ((name): value) } else { (:) }
}

#let capture(tag, lines) = [#metadata((tag: tag, lines: lines))<__codly-diff-pass>]

// Re-enter Codly with a raw block for each syntax pass. Retain only styled
// raw.lines so references, callouts, and gutters render once.
#let prepare(source, args, settings, lang, constructor, style, column) = context {
  let origin = here()
  let model = parse(source.text, old-offset: settings.old-offset, new-offset: settings.new-offset)
  let resources = (
    resource(source.theme, style.theme, "theme")
      + resource(source.syntaxes, style.syntaxes, "syntaxes")
  )
  let base = args + (alias: none, __diff: none, diff: none)
  let make(text) = raw(
    text,
    block: true,
    lang: lang,
    align: source.align,
    tab-size: source.tab-size,
    ..resources,
  )
  set text(size: style.size)
  for (index, group) in model.groups.enumerate() {
    for side in ("old", "new") {
      let rows = group.at(side)
      if rows.len() == 0 { continue }
      constructor(
        make(rows.join("\n")),
        ..(
          base
            + (
              __diff-pass: (origin: origin, group: index, side: side),
              sublangs: sublangs(args.sublangs, model.rows, index, side),
            )
        ),
      )
    }
  }
  context {
    let passes = (:)
    for record in query(selector(<__codly-diff-pass>).after(origin).before(here())) {
      let tag = record.value.tag
      if tag.origin == origin {
        passes.insert(str(tag.group) + "-" + tag.side, record.value.lines)
      }
    }
    let lines = ()
    for (index, row) in model.rows.enumerate() {
      // Native raw.line text expands tabs. Keep that exact text paired with
      // its styled body so character highlights and pointers stay aligned.
      let text = if row.kind == "meta" { source.lines.at(index).text } else { row.text }
      let body = std.text(text)
      if row.group != none {
        let side = if row.kind == "removed" { "old" } else { "new" }
        let pass = passes.at(str(row.group) + "-" + side, default: ())
        let line = pass.at(row.at(side + "-index"), default: none)
        if line != none {
          text = line.text
          body = line.body
        }
      }
      lines.push(raw.line(index + 1, model.rows.len(), text, body))
    }
    let gutters = args.gutters
    if gutters == auto {
      gutters = ()
      for side in ("old", "new") {
        if settings.numbers and args.number-enabled {
          gutters.push(column(values: model.rows.map(row => row.at(side))))
        }
      }
      if settings.markers {
        gutters.push(column(
          values: model.rows.map(row => if row.kind == "added" {
            settings.added-marker
          } else if row.kind == "removed" { settings.removed-marker } else { none }),
          align: center,
        ))
      }
    }
    constructor(
      make(model.rows.map(row => row.text).join("\n")),
      ..(
        args
          + (
            __diff: (rows: model.rows, lines: lines, settings: settings, original: source.text),
            gutters: gutters,
            sublangs: none,
          )
      ),
    )
  }
}

#let fill(row, data) = {
  if row.kind != "code" or row.source-line == none { return auto }
  let diff = data.rows.at(row.source-line - 1)
  let fill = data.settings.at(diff.kind + "-fill")
  if type(fill) == function { fill(row + (diff: diff)) } else { fill }
}
