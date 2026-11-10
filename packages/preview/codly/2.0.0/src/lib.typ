#import "@preview/elembic:1.1.1" as e
#import "geometry.typ" as geometry
#import "rainbow.typ" as rainbow
#import "indent.typ" as indent
#import "wrap.typ" as wrap
#import "callout.typ" as callout-impl
#import "gutter.typ" as gutter-impl
#import "diff.typ" as diff-impl
#import "padding.typ" as block-padding

#import "declarations.typ": __codly-prefix, __default

#let __codly-whitespace = regex("\\s")

/// Read the compact block record without querying reference figures.
#let __codly-block-info(target) = {
  let origin = query(target)
  assert(origin.len() == 1, message: "codly: expected a unique code block label: " + str(target))
  let blocks = query(selector(<__codly-block>).after(origin.first().location()))
  assert(blocks.len() > 0, message: "codly: no code block found after " + str(target))
  blocks.first().value
}

/// Resolve the nearest enclosing figure, never a preceding sibling or a
/// generated reference target. An unlabeled inner figure stops inheritance.
#let __codly-enclosing-label() = {
  let loc = here()
  if query(selector(loc).within(figure)).len() == 0 { return none }
  let parent = query(selector(figure).before(loc))
    .rev()
    .find(candidate => {
      query(selector(loc).within(candidate.location())).len() > 0
    })
  if parent != none { parent.at("label", default: none) }
}

#let __codly-inset(inset) = {
  if type(inset) == dictionary {
    let other = inset.at("rest", default: 0.32em)
    (
      top: inset.at("top", default: inset.at("y", default: other)),
      right: inset.at("right", default: inset.at("x", default: other)),
      bottom: inset.at("bottom", default: inset.at("y", default: other)),
      left: inset.at("left", default: inset.at("x", default: other)),
    )
  } else {
    (top: inset, right: inset, bottom: inset, left: inset)
  }
}

#let __codly-cell-args(align, fill, inset, stroke) = {
  let args = (:)
  if align != auto { args.insert("align", align) }
  if fill != auto { args.insert("fill", fill) }
  if inset != auto { args.insert("inset", inset) }
  if stroke != auto { args.insert("stroke", stroke) }
  args
}

/// Sort and merge ranges once, then advance through them alongside the lines.
#let __codly-ranges(ranges) = {
  let ordered = ()
  for r in ranges { ordered.push((r.start, if r.end == none { calc.inf } else { r.end })) }
  let merged = ()
  for (start, end) in ordered.sorted() {
    if merged.len() > 0 and start <= merged.last().last() + 1 {
      merged.last().at(1) = calc.max(merged.last().last(), end)
    } else {
      merged.push((start, end))
    }
  }
  merged
}

/// Resolve a paint, palette, or callback. The caller supplies the row's index.
#let __codly-row-fill(fill, row) = {
  if type(fill) == array {
    assert(fill.len() > 0, message: "codly: `fill` palettes must not be empty")
    return fill.at(calc.rem(row.index, fill.len()))
  }
  if type(fill) == function { return fill(row) }
  fill
}

// Select before slicing/ranging or splitting a span into styled fragments.
#let __codly-highlight-color(colors, index: 0) = {
  if type(colors) != array { return colors }
  assert(colors.len() > 0, message: "codly: highlight color palettes must not be empty")
  colors.at(calc.rem(index, colors.len()))
}

#let __codly-highlight-colors(highlights, colors) = {
  let result = (:)
  let next = 0
  let seen = (:)
  for hl in (if highlights == none { () } else { highlights }) {
    let key = str(hl.line)
    if key not in result { result.insert(key, ()) }
    let color = __codly-highlight-color(colors)
    if hl.fill == none or type(hl.fill) == function {
      let identity = repr(hl)
      color = seen.at(identity, default: none)
      if color == none {
        color = __codly-highlight-color(colors, index: next)
        seen.insert(identity, color)
        next += 1
      }
    }
    result.at(key).push(color)
  }
  result
}

#let __codly-lang-show(
  it,
) = {
  // The body is the language key as a string, e.g. "py".
  let lang-key = it.body

  let lang-def = if it.languages != none {
    it.languages.at(lang-key, default: none)
  } else {
    none
  }

  let style = (:)
  for name in ("display-name", "display-icon", "fill", "stroke", "inset", "radius") {
    style.insert(name, if lang-def != none and name in lang-def { lang-def.at(name) } else {
      it.at(name)
    })
  }

  let name = if not style.display-name {
    []
  } else if lang-def != none and lang-def.name != none {
    lang-def.name
  } else if lang-def != none {
    []
  } else {
    lang-key
  }
  let icon = if style.display-icon and lang-def != none and lang-def.icon != none {
    lang-def.icon
  } else {
    []
  }
  let color = if lang-def != none and lang-def.color != none {
    lang-def.color
  } else {
    it.default-color
  }

  let lang = (name: name, icon: icon, color: color)
  let fill = style.fill
  let fill = if type(fill) == function {
    fill(lang)
  } else if fill != none {
    fill
  } else {
    color
  }

  let stroke = style.stroke
  let stroke = if type(stroke) == function {
    stroke(lang)
  } else {
    stroke
  }

  let sep = if icon != [] and name != [] {
    h(0.2em)
  } else {
    []
  }
  let body = icon + sep + name
  if body == [] {
    return []
  }

  let padding = __codly-inset(style.inset)
  let b = measure(body)
  let badge = box(
    radius: style.radius,
    fill: fill,
    inset: padding,
    stroke: stroke,
    outset: 0pt,
    height: b.height + padding.top + padding.bottom,
    body,
  )

  return badge
}

/// Trims leading whitespace-only children from content, used for references.
#let __codly-trim(body) = {
  if type(body) == str {
    return body.trim()
  }

  if body.has("children") {
    let out = ()
    let start = true
    for child in body.children {
      if start and child.has("text") and child.text.trim().len() == 0 {
        continue
      } else if start and child == [ ] {
        continue
      }

      start = false
      out.push(child)
    }

    (body.func())(out)
  } else {
    body
  }
}

// Normalize native numbering patterns and callbacks, including optional labels.
#let __codly-numbering(format, ..numbers) = {
  if format == none { [] } else if type(format) == str {
    numbering(format, ..numbers)
  } else { (format)(..numbers) }
}

// Native figure targets emit these small elements instead of formatting their
// reference bodies inline. The shared settings remain compatible with ref-set_.
#let __codly-line-ref-show(codly-ref, it) = e.get(get => {
  let shared = get(codly-ref)
  let separator = if it.separator == auto { shared.sep } else { it.separator }
  let numbering = if it.numbering == auto { shared.numbering } else { it.numbering }
  if numbering == none { return ref(it.block) }
  [#ref(it.block)#separator#__codly-numbering(numbering, it.number)#if it.suffix != none {
      it.suffix
    }]
})

#let __codly-highlight-ref-show(codly-ref, it) = e.get(get => {
  let shared = get(codly-ref)
  let separator = if it.separator == auto { shared.sep } else { it.separator }
  let numbering = if it.numbering == auto { shared.numbering } else { it.numbering }
  if it.by == "line" and numbering == none { return ref(it.block) }
  let body = if it.by == "line" {
    __codly-numbering(numbering, it.line)
  } else {
    assert(it.item != none, message: "codly: tag is required for item reference")
    it.item
  }
  [#ref(it.block)#separator#__codly-trim(body)]
})

#let __codly-annotation-ref-show(codly-ref, it) = e.get(get => {
  let shared = get(codly-ref)
  let separator = if it.separator == auto { shared.sep } else { it.separator }
  let numbering = if it.numbering == auto { shared.numbering } else { it.numbering }
  if it.by == "line" and numbering == none { return ref(it.block) }
  let body = if it.by == "line" {
    __codly-numbering(numbering, it.line) + if it.suffix == none { [] } else { it.suffix }
  } else {
    it.item
  }
  [#ref(it.block)#separator#__codly-trim(body)]
})

/// Cache nesting and boundary events by geometry, independently of line styles.
#let __codly-highlight-layout(spans) = {
  let keys = ()
  for (start, end) in spans {
    let depth = 0
    for (other-start, other-end) in spans {
      if other-start <= start and other-end >= end and (other-start != start or other-end != end) {
        depth += 1
      }
    }
    keys.push((-depth, start, end, keys.len()))
  }
  let order = keys.sorted()
  let boundaries = ()
  let pending = ()
  for (_, start, end, _) in order {
    boundaries.push(start)
    boundaries.push(end)
    pending.push((start, pending.len()))
  }
  (order: order, boundaries: boundaries.sorted(), pending: pending.sorted())
}

/// The length in characters of a piece of content, where content labeled
/// `<codly-highlight>` (a tagged highlight) occupies no positions.
#let __codly-line-length(child) = {
  if child.has("label") and child.label == <codly-highlight> {
    0
  } else if child.has("text") {
    child.text.len()
  } else if child.has("children") {
    let length = 0
    for child in child.children {
      length += __codly-line-length(child)
    }
    length
  } else if child.has("child") {
    __codly-line-length(child.child)
  } else if child.has("body") {
    __codly-line-length(child.body)
  } else {
    0
  }
}

/// Splits text near highlight boundaries, keeping whitespace and graphemes whole.
#let __codly-line-body(elem, boundaries, offset: 0) = {
  if elem.has("label") and elem.label == <codly-highlight> {
    (elem,)
  } else if elem.has("children") {
    let children = ()
    for child in elem.children {
      children += __codly-line-body(child, boundaries, offset: offset)
      offset += __codly-line-length(child)
    }
    children
  } else if elem.has("child") and elem.has("styles") {
    let children = __codly-line-body(elem.child, boundaries, offset: offset)
    for index in range(children.len()) {
      children.at(index) = (elem.func())(children.at(index), elem.styles)
    }
    children
  } else if elem.has("text") {
    let next = 0
    while next < boundaries.len() and boundaries.at(next) < offset { next += 1 }
    if next == boundaries.len() or boundaries.at(next) > offset + elem.text.len() {
      return (elem,)
    }
    let out = ()
    let part = ""
    let token = ""
    let was-space = false
    let clusters = elem.text.clusters()
    clusters.push("")
    for cluster in clusters {
      let is-space = cluster.contains(__codly-whitespace)
      if token != "" and (not is-space or not was-space) {
        offset += token.len()
        if next < boundaries.len() and boundaries.at(next) <= offset {
          if part != "" {
            out.push(text(part))
            part = ""
          }
          out.push(text(token))
          while next < boundaries.len() and boundaries.at(next) <= offset { next += 1 }
        } else {
          part += token
        }
        token = ""
      }
      token += cluster
      was-space = is-space
    }
    if part != "" { out.push(text(part)) }
    out
  } else {
    (elem,)
  }
}

/// Render a span with per-highlight overrides, falling back to element fields.
/// References use `codly.ref` settings.
#let __codly-highlight-show(
  codly-ref,
  codly-highlight-ref,
  it,
) = {
  let hl = it.highlight
  let body = it.body
  if it.__continuation-indent != none {
    body = par(hanging-indent: it.__continuation-indent, body)
  }

  let color = __codly-highlight-color(it.color)
  let base = if hl != none and hl.fill != none { hl.fill } else { color }
  if type(base) == function { base = base(color) }
  let style = (:)
  for name in ("radius", "clip", "inset", "outset", "baseline") {
    style.insert(name, if hl != none and hl.at(name) != none { hl.at(name) } else { it.at(name) })
  }
  let fill = if it.fill != none { (it.fill)(base) }
  let stroke = if hl != none and hl.stroke != none { hl.stroke } else { it.stroke }
  if type(stroke) == function { stroke = stroke(base) }

  // Build the hidden reference figure if the highlight is labeled.
  let label = if hl != none and hl.label != none {
    e.get(get => {
      assert(
        hl.at("block-label", default: none) != none,
        message: "codly: for labels on highlights to work, you must have the code block contained within a figure and that figure must have a label.",
      )
      let ref-set = get(codly-ref)
      if ref-set.by == "item" {
        assert(hl.tag != none, message: "codly: tag is required for item reference")
      }

      let block-label = hl.at("block-label")
      place(hide(pdf.artifact[#figure(
          kind: "codly-referencer",
          supplement: none,
          numbering: (..) => codly-highlight-ref(
            [],
            block: block-label,
            line: hl.at("line-number"),
            item: hl.tag,
            by: ref-set.by,
          ),
          [],
        )#hl.label]))
    })
  }

  let tag = if hl != none { hl.tag } else { none }
  if tag == none {
    box(
      radius: style.radius,
      clip: style.clip,
      fill: fill,
      stroke: stroke,
      inset: style.inset,
      outset: style.outset,
      baseline: style.baseline,
      body + label,
    )
  } else {
    // Explicit widths prevent reflow at the weak break between body and tag.
    let inset-sep = __codly-inset(style.inset)
    let size-body = measure(body)
    let size-tag = measure(tag)
    let max-height = (
      calc.max(
        size-body.height,
        size-tag.height,
      )
        + inset-sep.top
        + inset-sep.bottom
    )
    let width-body = size-body.width + inset-sep.left + inset-sep.right
    let width-tag = size-tag.width + inset-sep.left + inset-sep.right
    let body-box = box(
      radius: (top-right: 0pt, bottom-right: 0pt, rest: style.radius),
      width: width-body,
      height: max-height,
      clip: style.clip,
      fill: fill,
      stroke: stroke,
      inset: style.inset,
      outset: style.outset,
      baseline: style.baseline,
      body,
    )
    let tag-box = box(
      radius: (top-left: 0pt, bottom-left: 0pt, rest: style.radius),
      width: width-tag,
      height: max-height,
      clip: style.clip,
      fill: fill,
      stroke: stroke,
      inset: style.inset,
      outset: style.outset,
      baseline: style.baseline,
      tag + label,
    )
    [#body-box#h(0pt, weak: true)#tag-box<codly-highlight>]
  }
}

/// Renders a single code line: smart indentation, per-character highlights
/// (delegated to `codly.highlight`), and line reference figures.
// Keep the shared rendering helpers out of each line's context captures.
// Its font-dependent work still runs inside the caller's deferred context.
#let __codly-line-render(codly-highlight, codly-ref, codly-line-ref, it, line-show) = {
  let line = it.body
  let line-highlights = it.highlights
  let smart-indent = it.smart-indent
  let block-label = it.block-label
  let highlights = ()
  let layout = none
  if line-highlights != none and line-highlights.len() > 0 {
    let spans = ()
    for (index, hl) in line-highlights.enumerate() {
      if hl.line == line.number {
        if it.__highlight-colors != none {
          hl.insert("__color", it.__highlight-colors.at(index))
        }
        if hl.at("label", default: none) != none {
          hl.insert("line-number", line.number)
          hl.insert("block-label", block-label)
        }
        highlights.push(hl)
        spans.push((hl.start, hl.end))
      }
    }
    if highlights.len() > 0 { layout = __codly-highlight-layout(spans) }
  }
  if layout != none {
    let sorted = ()
    for (depth, _, _, index) in layout.order {
      let hl = highlights.at(index)
      hl.insert("depth", -depth)
      sorted.push(hl)
    }
    highlights = sorted
  }

  // Keep empty and highlighted lines at a consistent height.
  let line-height = measure[1].height
  let body = line.body
  let wrap-data = none
  let needs-marker = false
  if smart-indent and it.__wrap != none {
    // Highlight insets can change the width. Measure their ordinary renderer
    // before deciding whether to add any probes to this source row.
    let natural = if highlights.len() == 0 { line.body } else {
      line-show(codly-highlight, codly-ref, codly-line-ref, it + (__wrap: none))
    }
    needs-marker = measure(natural).width > it.__wrap.width
  }
  if needs-marker {
    let row = it.__wrap.row
    let marker = it.__wrap.marker
    let advance = measure(marker).width + 0.3em.to-absolute()
    wrap-data = (
      owner: it.__wrap.owner,
      row: row,
      marker: marker,
      advance: advance,
      tolerance: line-height / 2,
    )
    body = wrap.annotate(body, it.__wrap.owner, row)
  }
  if it.__callout != none { body = callout-impl.annotate(body, it.__callout) }
  body = box(height: line-height, width: 0pt, baseline: 0pt) + body

  // Continue wrapped lines at their original indentation.
  let width = none
  let prefix = if smart-indent { line.text.match(indent.leading-spaces).text } else { "" }
  if smart-indent {
    if prefix != "" { width = measure(text(prefix)).width }
  }
  if wrap-data != none {
    wrap-data.insert("indent", if width == none { 0pt } else { width })
    width = wrap-data.indent + wrap-data.advance
  }
  let highlight-options(start) = {
    // Use the actual fragment start: highlight positions are one-based and
    // whitespace runs are atomic; crossing spans may also reopen later.
    let remaining = calc.max(prefix.len() - start, 0)
    if not smart-indent or (remaining == 0 and wrap-data == none) { return (:) }
    (
      __continuation-indent: measure(text(" " * remaining)).width
        + if wrap-data == none { 0pt } else { wrap-data.advance },
    )
  }
  let render-highlight(body, hl, start) = {
    let color = hl.remove("__color", default: none)
    let options = highlight-options(start)
    if color != none { options.insert("color", color) }
    codly-highlight(body, highlight: hl, ..options)
  }

  // Split before applying `set par`, which would otherwise wrap each fragment.
  let highlighted = body
  if highlights.len() > 0 {
    let source = __codly-line-body(body, layout.boundaries)
    let pending = layout.pending

    // Descending indices keep the outer highlights first without re-sorting.
    let next = 0
    let next-end = calc.inf
    let active = ()
    let open = ()
    let groups = ((),)
    let starts = ()
    let i = 0
    for child in source {
      let end = i + __codly-line-length(child)
      let changed = false
      if i >= next-end {
        let remaining = ()
        for index in active {
          if i < highlights.at(index).end { remaining.push(index) }
        }
        active = remaining
        changed = true
      }
      while next < pending.len() and pending.at(next).first() <= end {
        let index = pending.at(next).last()
        let hl = highlights.at(index)
        // Expired spans cannot rejoin; duplicate records apply only once.
        if i < hl.end {
          let position = 0
          let duplicate = false
          for other in active {
            if highlights.at(other) == hl {
              duplicate = true
              break
            }
            if other > index { position += 1 }
          }
          if not duplicate {
            active.insert(position, index)
            changed = true
          }
        }
        next += 1
      }

      if changed {
        next-end = calc.inf
        for index in active {
          next-end = calc.min(next-end, highlights.at(index).end)
        }

        // Keep shared outer highlights open across changes to their children.
        let shared = 0
        while (
          shared < calc.min(open.len(), active.len()) and open.at(shared) == active.at(shared)
        ) {
          shared += 1
        }
        while open.len() > shared {
          let hl = highlights.at(open.pop())
          let content = render-highlight(groups.pop().join(), hl, starts.pop())
          groups.last().push(content)
        }
        while open.len() < active.len() {
          open.push(active.at(open.len()))
          groups.push(())
          starts.push(i)
        }
      }
      groups.last().push(child)
      i = end
    }

    // Close spans that continue through or beyond the end of the line.
    while open.len() > 0 {
      let hl = highlights.at(open.pop())
      let content = render-highlight(groups.pop().join(), hl, starts.pop())
      groups.last().push(content)
    }

    highlighted = groups.first().join()
  }

  if width != none {
    highlighted = {
      set par(hanging-indent: width)
      highlighted
    }
  }

  if wrap-data != none { highlighted = [#metadata(wrap-data)<__codly-wrap-row>#highlighted] }
  let output = raw.line(line.number, line.count, line.text, highlighted)
  if block-label == none {
    // End the paragraph while its hanging indent is in scope. Unlike an
    // empty placement, this boundary needs no positioned frame.
    return output + parbreak()
  }

  let number = line.number
  let reference = it.reference
  if reference != none { number = reference.number }
  let line-label = label(
    str(block-label)
      + ":"
      + if reference == none {
        str(number)
      } else {
        reference.label
      },
  )
  [#output#place(hide(pdf.artifact[#figure(
        kind: "codly-line",
        supplement: none,
        caption: none,
        outlined: false,
        numbering: (..) => codly-line-ref(
          [],
          block: block-label,
          number: number,
          suffix: if reference == none { none } else { reference.suffix },
        ),
        [],
      )#line-label]))]
}

#let __codly-line-show(
  codly-highlight,
  codly-ref,
  codly-line-ref,
  it,
) = {
  let line = it.body

  // Skip placeholders and other non-line content are rendered as-is.
  if type(line) != content or line.func() != raw.line {
    return line
  }

  // The renderer needs no element metadata or grid-cell styling fields.
  let it = (
    body: line,
    highlights: it.highlights,
    smart-indent: it.smart-indent,
    block-label: it.block-label,
    reference: if it.block-label != none { it.reference },
    __wrap: if it.smart-indent { it.__wrap },
    __callout: it.at("__callout", default: none),
    __highlight-colors: it.at("__highlight-colors", default: none),
  )
  let smart-indent = it.smart-indent
  if smart-indent and it.__wrap != none and "width" not in it.__wrap {
    return layout(size => __codly-line-show(
      codly-highlight,
      codly-ref,
      codly-line-ref,
      it + (__wrap: it.__wrap + (width: size.width)),
    ))
  }
  context __codly-line-render(
    codly-highlight,
    codly-ref,
    codly-line-ref,
    it,
    __codly-line-show,
  )
}

#let __codly-annotation-cell(constructor, body, label, num, numbering) = {
  block(height: 1fr, layout(size => constructor(
    body,
    label,
    num: num,
    numbering: numbering,
    height: size.height,
  )))
}

/// Resolve syntax before constructing the line so hooks receive a raw.line.
#let __codly-sublang-line(constructor, line, source: none, ..args) = context {
  let record = query(selector(source).before(here())).last(default: none)
  let resolved = if record == none { line } else { record.value }
  constructor(
    raw.line(line.number, line.count, resolved.text, resolved.body),
    ..args,
  )
}

#let __codly-line-loop(
  codly-line,
  codly-number,
  smart-skip,
  lines,
  annotations,
  callouts,
  ranges,
  skips,
  skip-last-empty,
  number-enabled,
  skip-line,
  skip-number,
  codly-annotation,
  codly-callout,
  codly-bubble,
  codly-annotation-ref,
  ref-set,
  highlights,
  smart-indent,
  block-label,
  offset,
  lang-block,
  sublang-lines: (:),
  get: none,
  indentation: none,
  wrap-settings: none,
  unnumbered: (),
  parent: [],
  badge-row: none,
  gutter-columns: none,
  row-offset: 0,
  highlight-colors: (:),
) = {
  let gutter-columns = if gutter-columns == none {
    if number-enabled { (auto,) } else { () }
  } else { gutter-columns }
  let gutter-count = gutter-columns.len()
  let items = ()
  let lines_to_number = ()
  let rows = ()
  let guide-depths = ()
  let last-number = none
  let smart-skip-enabled = smart-skip.first or smart-skip.last or smart-skip.rest
  let current-annot = none
  let annotation-cell = none
  let annotation-rows = 0
  let annots = 0
  let in-skip = false
  let in-first = true
  let has-annots = annotations.len() > 0
  let skip-index = 0
  let formatted-skips = 0
  let line-array = type(skip-line) == array
  let number-array = type(skip-number) == array
  let fallback-line = if line-array {
    skip-line.at(-1, default: __default("new", "skip-line"))
  } else {
    skip-line
  }
  let fallback-number = if number-array {
    skip-number.at(-1, default: __default("new", "skip-number"))
  } else { skip-number }
  let unnumbered-by-line = (:)
  if unnumbered != none {
    for entry in unnumbered {
      unnumbered-by-line.insert(str(entry.line), entry.fill)
    }
  }
  let unnumbered-after = 0
  let range-index = 0
  let has-ranges = ranges != none and ranges.len() > 0
  let last-line = lines.len()
  if has-ranges and skip-last-empty and last-line > 0 and lines.last().text.trim() == "" {
    last-line -= 1
  }

  // Index once per block instead of passing every highlight to every line.
  let highlights-by-line = (:)
  let has-highlights = highlights != none and highlights.len() > 0
  if has-highlights {
    for hl in highlights {
      let key = str(hl.line)
      if key not in highlights-by-line {
        highlights-by-line.insert(key, ())
      }
      highlights-by-line.at(key).push(hl)
    }
  }

  // Callouts are keyed by source line so offsets and inserted skips do not
  // change the line they attach to. Preserve input order on each side.
  let callouts-by-line = (:)
  let callout-owner = if callouts != none and callouts.len() > 0 { here() }
  let callout-defaults = if callout-owner != none { get(codly-callout) }
  let bubble-defaults = if callout-owner != none { get(codly-bubble) }
  if callouts != none {
    for callout in callouts {
      callout += callout-impl.resolve(callout, callout-defaults, bubble-defaults: bubble-defaults)
      assert(
        callout.pointer == none or callout.pointer >= 0,
        message: "codly: callout pointer must be non-negative",
      )
      let key = str(callout.line)
      if key not in callouts-by-line { callouts-by-line.insert(key, ()) }
      callouts-by-line.at(key).push(callout)
    }
  }

  for line in lines {
    if has-annots {
      let annot = annotations.at(annotations.len() - 1, default: none)
      if annot != none and line.number == annot.start {
        current-annot = annot
        annots += 1
      }

      if current-annot != none and line.number > current-annot.end {
        if annotation-cell != none {
          items.at(annotation-cell) = grid.cell(
            rowspan: annotation-rows,
            align: left + horizon,
            items.at(annotation-cell),
          )
          annotation-cell = none
          annotation-rows = 0
        }
        current-annot = none
        _ = annotations.pop()
        let annot = annotations.at(annotations.len() - 1, default: none)
        if annot != none and line.number == annot.start {
          current-annot = annot
          annots += 1
        }
      }
    }

    let explicit-skip-data = skips.at(skip-index, default: none)
    let explicit-skip = explicit-skip-data != none and line.number == explicit-skip-data.position
    if has-ranges {
      while range-index < ranges.len() and ranges.at(range-index).last() < line.number {
        range-index += 1
      }
    }
    let interval = if has-ranges { ranges.at(range-index, default: none) }
    let in-range = not has-ranges or (interval != none and interval.first() <= line.number)
    let insert-skip = (
      smart-skip-enabled
        and not in-range
        and not in-skip
        and if in-first {
          smart-skip.first
        } else if interval != none and interval.first() <= last-line {
          smart-skip.rest
        } else {
          smart-skip.last
        }
    )

    if explicit-skip or insert-skip {
      let number = if explicit-skip and number-array {
        skip-number.at(formatted-skips, default: fallback-number)
      } else { fallback-number }
      items += gutter-impl.cells(
        gutter-columns,
        (index: rows.len() + row-offset, kind: "skip", source-line: none, number: none, text: none),
        if number == none { [] } else { number },
        codly-number,
        parent,
      )
      let body = if explicit-skip and line-array {
        skip-line.at(formatted-skips, default: fallback-line)
      } else { fallback-line }
      let body = codly-line(body)
      items.push(if has-annots {
        grid.cell(colspan: if annotation-cell == none { 2 } else { 1 }, body)
      } else { body })
      if annotation-cell != none { annotation-rows += 1 }
      lines_to_number.push(-99999999)
      rows.push((kind: "skip", source-line: none, number: none))
      if indentation != none { guide-depths.push(0) }
      if explicit-skip {
        formatted-skips += 1
        offset += explicit-skip-data.length
        skip-index += 1
        while skip-index < skips.len() and skips.at(skip-index) == explicit-skip-data {
          skip-index += 1
        }
      }
    }

    if not in-range {
      in-skip = true
      continue
    }
    in-skip = false

    if skip-last-empty and line.number == line.count and line.text.trim() == "" {
      continue
    }

    let row-callouts = callouts-by-line.at(str(line.number), default: ())
    let mapped-number = none
    let number = line.number + offset
    let fill = unnumbered-by-line.at(str(line.number), default: none)
    let unnumbered-line = fill != none
    let reference = none
    if unnumbered-line {
      unnumbered-after += 1
      number -= 1
      reference = (
        label: "l" + str(number) + "p" + str(unnumbered-after),
        number: number,
        suffix: [+#unnumbered-after],
      )
      // Keep subsequent displayed numbers contiguous with the prior line.
      offset -= 1
      mapped-number = -99999998
    } else {
      unnumbered-after = 0
      mapped-number = number
      last-number = number
    }
    let new-annotation = none
    if current-annot != none and annotation-cell == none {
      let label = if current-annot.label != none {
        place(hide(pdf.artifact[#figure(
            kind: "codly-referencer",
            supplement: none,
            numbering: (..) => codly-annotation-ref(
              [],
              block: block-label,
              line: number,
              item: if current-annot.content == none { str(annots) } else { current-annot.content },
              suffix: if reference == none { none } else { reference.suffix },
              by: ref-set.by,
            ),
            [],
          )#current-annot.label]))
      } else {
        []
      }

      new-annotation = __codly-annotation-cell(
        codly-annotation,
        current-annot.content,
        label,
        annots,
        current-annot.numbering,
      )
    }

    let callout-colspan = (
      gutter-count + 1 + (if has-annots and current-annot == none { 1 } else { 0 })
    )
    for row in callout-impl.row-cells(
      row-callouts.filter(c => c.placement == "above"),
      codly-callout,
      callout-defaults,
      callout-owner,
      line.number,
      callout-colspan,
      gutter-count: gutter-count,
      source-text: line.text,
    ) {
      items += row
      if new-annotation != none {
        annotation-cell = items.len()
        items.push(new-annotation)
        new-annotation = none
      }
      lines_to_number.push(-99999997)
      rows.push((kind: "callout", source-line: line.number, number: number))
      if indentation != none { guide-depths.push(0) }
      if annotation-cell != none { annotation-rows += 1 }
    }
    lines_to_number.push(mapped-number)
    rows.push((
      kind: "code",
      source-line: line.number,
      number: if unnumbered-line { none } else { number },
    ))
    if indentation != none { guide-depths.push(indentation.depths.at(line.number - 1)) }
    items += gutter-impl.cells(
      gutter-columns,
      (
        index: rows.len() - 1 + row-offset,
        kind: "code",
        source-line: line.number,
        number: if unnumbered-line { none } else { number },
        text: line.text,
      ),
      if unnumbered-line { fill } else { number },
      codly-number,
      parent,
    )

    // The line's number carries the offset, matching its displayed number.
    let numbered = if number == line.number { line } else {
      raw.line(number, line.count, line.text, line.body)
    }
    let line-source = sublang-lines.at(str(line.number), default: none)
    let render = if line-source == none { codly-line } else {
      __codly-sublang-line.with(codly-line, source: line-source)
    }
    let pointers = row-callouts.map(c => c.pointer).filter(p => p != none).dedup()
    assert(
      pointers.all(p => p <= line.text.len()),
      message: "codly: callout pointer exceeds source line length",
    )
    let rendered-line = render(
      numbered,
      highlights: if has-highlights {
        highlights-by-line.at(str(number), default: ())
      } else { highlights },
      __highlight-colors: highlight-colors.at(str(number), default: none),
      smart-indent: smart-indent,
      __wrap: if wrap-settings == none { none } else { wrap-settings + (row: line.number) },
      block-label: block-label,
      reference: reference,
      __callout: if pointers.len() > 0 {
        (owner: callout-owner, row: line.number, pointers: pointers)
      },
    )
    if in-first {
      in-first = false
      rendered-line = if badge-row == none { rendered-line + lang-block } else {
        (badge-row.render)(rendered-line)
      }
    }
    items.push(if has-annots {
      grid.cell(colspan: if current-annot != none { 1 } else { 2 }, rendered-line)
    } else {
      rendered-line
    })

    if new-annotation != none {
      annotation-cell = items.len()
      items.push(new-annotation)
    }
    if annotation-cell != none { annotation-rows += 1 }

    for row in callout-impl.row-cells(
      row-callouts.filter(c => c.placement == "below"),
      codly-callout,
      callout-defaults,
      callout-owner,
      line.number,
      callout-colspan,
      gutter-count: gutter-count,
      source-text: line.text,
    ) {
      items += row
      lines_to_number.push(-99999997)
      rows.push((kind: "callout", source-line: line.number, number: number))
      if indentation != none { guide-depths.push(0) }
      if annotation-cell != none { annotation-rows += 1 }
    }
  }

  if annotation-cell != none {
    items.at(annotation-cell) = grid.cell(
      rowspan: annotation-rows,
      align: left + horizon,
      items.at(annotation-cell),
    )
  }

  (
    items: items,
    lines_to_number: lines_to_number,
    rows: rows,
    last-number: last-number,
    guide-depths: guide-depths,
  )
}

#let __codly-annotation-show(
  it,
) = {
  // Preserve the equation's typography and unbreakable layout for accessible text.
  let body = text(
    font: "New Computer Modern Math",
    weight: 450,
  )[#__codly-numbering(it.numbering, it.num)
    #it.body
    #it.label]
  let body-size = measure(body)
  // Keep the existing baseline for single lines and explicitly authored blocks.
  // Multiline inline content needs its own box to keep every line beside the brace.
  if (
    (type(it.body) == content and it.body.func() == block)
      or body-size.height <= measure(text(font: "New Computer Modern Math", weight: 450)[M]).height
  ) {
    let annotation = text(font: "New Computer Modern Math", weight: 450)[
      #pdf.artifact[$lr(}, size: #it.height)$] #body
    ]
    return box(width: measure(annotation).width, annotation)
  }
  let annotation = text(font: "New Computer Modern Math", weight: 450)[
    #pdf.artifact[$lr(}, size: #it.height)$]
    #box(
      width: body-size.width,
      height: body-size.height,
      // Center on the equation's math axis rather than the final text line.
      baseline: -body-size.height / 2 + 0.25em,
      body,
    )
  ]
  box(width: measure(annotation).width, annotation)
}

// Share static captures across blocks while keeping the style lookup deferred.
#let __codly-block-render(
  get,
  block-show,
  codly-line,
  codly-highlight,
  codly-lang,
  codly-file,
  codly-header,
  codly-footer,
  codly-number,
  codly-annotation,
  codly-callout,
  codly-bubble,
  codly-annotation-ref,
  codly-ref,
  sublang-block,
  constructor,
  args,
  alias-style,
  it,
  prepared-lines: none,
  gutter-constructor: none,
  diff-defaults: (:),
) = {
  if args.__diff == none and args.__diff-pass == none and args.diff != none {
    let settings = if args.diff == auto { diff-defaults + args.__diff-colors } else {
      e.fields(args.diff)
    }
    if settings.enabled {
      let lang = diff-impl.language(it.lang)
      if lang != none {
        return diff-impl.prepare(
          it,
          args,
          settings,
          lang,
          constructor,
          alias-style,
          gutter-constructor,
        )
      }
    }
  }
  if args.alias == none and args.aliases != none {
    if it.lang != none {
      if it.lang in args.aliases {
        let aliased-args = args
        let _ = aliased-args.remove("alias")
        let target-lang = args.aliases.at(it.lang)
        let raw-args = (:)
        let safe-resource(value) = (
          type(value) != str
            and (
              type(value) != array or value.all(value => type(value) != str)
            )
        )
        if not safe-resource(it.theme) and it.theme != alias-style.theme {
          panic(
            "codly: aliases cannot safely copy an explicit string `raw.theme`; use `path(\"...\")` or `read(\"...\")`",
          )
        }
        if not safe-resource(it.syntaxes) and it.syntaxes != alias-style.syntaxes {
          panic(
            "codly: aliases cannot safely copy explicit string `raw.syntaxes`; use `path(\"...\")` or `read(\"...\")`",
          )
        }
        if safe-resource(it.theme) { raw-args.insert("theme", it.theme) }
        if safe-resource(it.syntaxes) { raw-args.insert("syntaxes", it.syntaxes) }
        return context {
          set text(size: alias-style.size)
          constructor(
            raw(
              it.text,
              block: true,
              align: it.align,
              lang: target-lang,
              tab-size: it.tab-size,
              ..raw-args,
            ),
            alias: it.lang,
            ..aliased-args,
          )
        }
      }
    }
  }

  if args.__diff == none and args.rainbow != none and args.rainbow.enabled {
    if args.rainbow.pairs.len() > 0 and it.text.contains(rainbow.delimiters) {
      let settings = e.fields(args.rainbow)
      let sublangs = args.sublangs
      let prepared = args + (rainbow: none, sublangs: none)
      // Resolve inherited guide colors before the delimiter pass clears rainbow.
      if args.indent-guides != none and args.indent-guides.enabled {
        let guides = e.fields(args.indent-guides)
        let style = indent.settings(guides, args.rainbow)
        prepared.indent-guides = (
          guides + (rainbow: true, palette: style.palette, depth-offset: style.depth-offset)
        )
      }
      return rainbow.prepare(it, settings, sublangs, lines => block-show(
        codly-line,
        codly-highlight,
        codly-lang,
        codly-file,
        codly-header,
        codly-footer,
        codly-number,
        codly-annotation,
        codly-callout,
        codly-bubble,
        codly-annotation-ref,
        codly-ref,
        sublang-block,
        constructor,
        prepared,
        alias-style,
        it,
        prepared-lines: lines,
        gutter-constructor: gutter-constructor,
        diff-defaults: diff-defaults,
      ))
    }
  }

  if args.block-label == auto {
    args.block-label = __codly-enclosing-label()
  }

  let lang = if args.alias == none {
    it.lang
  } else {
    args.alias
  }

  import "file.typ" as file-impl
  let badge-position = args.at("lang-position")
  let file-position = args.at("file-position")
  let inline-file = args.file != none and file-position != none and file-position.y == none
  if badge-position == auto and args.file != none and not inline-file {
    badge-position = top + right
  }
  let positioned = badge-position != auto and badge-position != none and badge-position.y != none
  if badge-position != auto and badge-position != none {
    assert(
      badge-position.x in (left, right, none) and badge-position.y in (top, bottom, none),
      message: "codly: lang-position must select left/right and top/bottom",
    )
  }
  let badge-bottom = positioned and badge-position.y == bottom
  let badge-side = if positioned and badge-position.x == left { left } else { right }
  if file-position != none {
    assert(
      file-position.x in (left, right, none) and file-position.y in (top, bottom, none),
      message: "codly: file-position must select left/right and top/bottom",
    )
  }
  let file-bottom = file-position != none and file-position.y == bottom
  let file-side = if file-position != none and file-position.x == right { right } else { left }
  let language-badge = if lang != none and positioned { codly-lang(lang) }
  let file-badge = if args.file != none and file-position != none and not inline-file {
    codly-file(args.file)
  }
  if (
    args.header == none
      and (
        (file-badge != none and not file-bottom)
          or (positioned and not badge-bottom and language-badge != none)
      )
  ) {
    args.header = []
  }
  if (
    args.footer == none
      and ((badge-bottom and language-badge != none) or (file-bottom and file-badge != none))
  ) { args.footer = [] }

  // Inline badges shorten only the first displayed code row. Explicit band
  // placements keep their independently reserved header/footer rows.
  let inline-lang = (
    badge-position == auto
      or (
        badge-position != none and badge-position.y == none
      )
  )
  let lang-content = if lang != none and inline-lang { codly-lang(lang) }
  let lang-settings = if lang-content != none { get(codly-lang) }
  let lang-dy = if lang-content != none {
    if args.leading == none { lang-settings.outset.y } else {
      calc.max(0em, 0.35em - args.leading)
    }
  }
  let lang-block = if lang-content != none and badge-position == auto and args.header != none {
    place(lang-settings.align, dx: lang-settings.outset.x, dy: lang-dy, lang-content)
  }
  let inline-badges = ()
  if inline-file {
    inline-badges.push((
      body: codly-file(args.file),
      align: file-side + horizon,
      dx: 0pt,
      dy: 0pt,
    ))
  }
  if lang-content != none and (args.header == none or badge-position != auto) {
    inline-badges.push((
      body: lang-content,
      align: if badge-position == auto { lang-settings.align } else {
        badge-position + lang-settings.align.y
      },
      dx: lang-settings.outset.x,
      dy: lang-dy,
    ))
  }
  let badge-row = if inline-badges.len() > 0 {
    file-impl.inline-row(inline-badges, __codly-inset(get(codly-line).inset))
  }

  let has-annotations = args.annotations != none and args.annotations.len() > 0
  let gutter-columns = gutter-impl.columns(args.gutters, args.number-enabled)
  let gutter-count = gutter-columns.len()
  let column-count = (
    gutter-count + 1 + (if has-annotations { 1 } else { 0 })
  )

  let header-block = if args.header != none {
    let fields = if e.eid(args.header) == e.eid(codly-header) { e.fields(args.header) } else {
      (body: args.header)
    }
    let body = fields.remove("body")
    let body = if (file-badge != none and not file-bottom) or (positioned and not badge-bottom) {
      file-impl.band(
        body,
        file: if not file-bottom { file-badge },
        file-side: file-side,
        language: if badge-bottom { none } else if positioned { language-badge },
        side: badge-side,
      )
    } else { body + lang-block }
    let header = codly-header(body, ..fields)
    let header-set = get(codly-header) + fields
    let cell-args = __codly-cell-args(
      header-set.align,
      if header-set.fill == auto { luma(240) } else { header-set.fill },
      header-set.inset,
      header-set.stroke,
    )

    (
      grid.header(
        repeat: header-set.repeat,
        grid.cell(
          header,
          colspan: column-count,
          rowspan: 1,
          x: 0,
          y: 0,
          ..cell-args,
        ),
      ),
    )
  } else {
    ()
  }

  let footer-block = if args.footer != none {
    let fields = if e.eid(args.footer) == e.eid(codly-footer) { e.fields(args.footer) } else {
      (body: args.footer)
    }
    let body = fields.remove("body")
    let body = if badge-bottom or (file-bottom and file-badge != none) {
      file-impl.band(
        body,
        file: if file-bottom { file-badge },
        file-side: file-side,
        language: if badge-bottom { language-badge },
        side: badge-side,
      )
    } else { body }
    let footer = codly-footer(body, ..fields)
    let footer-set = get(codly-footer) + fields
    let cell-args = __codly-cell-args(
      footer-set.align,
      if footer-set.fill == auto { none } else { footer-set.fill },
      footer-set.inset,
      footer-set.stroke,
    )

    (
      grid.footer(
        repeat: footer-set.repeat,
        grid.cell(
          footer,
          colspan: column-count,
          rowspan: 1,
          ..cell-args,
        ),
      ),
    )
  } else {
    ()
  }

  let skips = if args.skips != none {
    args.skips.sorted(key: x => x.position)
  } else {
    ()
  }

  let range = args.range
  let ranges = args.ranges
  if range != none and ranges != none {
    panic("codly: cannot specify both `range` and `ranges`")
  } else if range != none {
    ranges = (range,)
  }

  if ranges != none { ranges = __codly-ranges(ranges) }

  let annotations = if args.annotations == none { () } else {
    args.annotations.sorted(key: annot => -annot.start)
  }
  let previous = none
  for annot in annotations {
    if args.block-label == none and annot.label != none {
      panic(
        "codly: annotations with labels (" + str(annot.label) + ") require `block-label` to be set",
      )
    }
    if previous != none and annot.end >= previous {
      panic("codly: overlapping annotations")
    }
    previous = annot.start
  }

  // Resolve the numeric shift, automatic excerpt origin, or labeled block.
  let offset = if type(args.offset) == int { args.offset } else { 0 }
  if args.offset == auto and ranges != none {
    // Anchor to the first actual source line, not declaration order or an
    // empty/out-of-bounds interval. Only the displayed numbering is shifted.
    let first = ranges.find(interval => (
      interval.last() >= calc.max(1, interval.first()) and interval.first() <= it.lines.len()
    ))
    if first != none { offset -= calc.max(1, first.first()) - 1 }
  }
  if type(args.offset) == label {
    let last-number = __codly-block-info(args.offset).last-number
    if last-number != none {
      offset += last-number
    }
  }

  let highlighted-by-line = (:)
  if args.highlighted != none {
    let settings = get(codly-highlight)
    let next = 0
    for hl in args.highlighted {
      let fill = hl.color
      if fill == none {
        let color = __codly-highlight-color(settings.color, index: next)
        fill = if settings.fill == none { none } else { (settings.fill)(color) }
        next += 1
      }
      highlighted-by-line.insert(str(hl.line), fill)
    }
  }

  let ref-set = if annotations.len() > 0 and args.block-label != none {
    let settings = get(codly-ref)
    (by: settings.by, sep: settings.sep, numbering: settings.numbering)
  }

  // Resolve sublanguage syntax through metadata, retaining the original source
  // lines for range/skip/annotation processing. The line loop resolves each
  // displayed line before codly-line applies its character-level formatting.
  let output-blocks = ()
  let sublang-lines = (:)
  let lines = if prepared-lines != none { prepared-lines } else if args.__diff != none {
    args.__diff.lines
  } else { it.lines }
  if args.sublangs != none and args.sublangs.len() > 0 {
    let nl-regex = regex("(\r\n|\r|\n)")
    let raw-text-lines = it.text.split(nl-regex)
    for (idx, s) in args.sublangs.enumerate() {
      let source-lines = raw-text-lines.slice(s.start - 1, s.end)
      let new-block = raw(
        source-lines.join("\n"),
        block: true,
        lang: s.lang,
        align: it.align,
        tab-size: it.tab-size,
        theme: it.theme,
        syntaxes: it.syntaxes,
      )

      output-blocks.push(sublang-block(new-block, idx))
      let idx = str(idx)

      for i in std.range(source-lines.len()) {
        sublang-lines.insert(
          str(s.start + i),
          label("__codly_sublang_line_" + idx + "_" + str(i)),
        )
      }
    }
  }

  if args.__diff-pass != none {
    return (
      output-blocks.join()
        + context {
          let captured = lines
          for (index, line) in captured.enumerate() {
            let label = sublang-lines.at(str(index + 1), default: none)
            if label != none {
              let record = query(selector(label).before(here())).last(default: none)
              if record != none {
                captured.at(index) = raw.line(
                  line.number,
                  line.count,
                  record.value.text,
                  record.value.body,
                )
              }
            }
          }
          diff-impl.capture(args.__diff-pass, captured)
        }
    )
  }

  let smart-skip = args.smart-skip
  let guides = args.indent-guides
  let wrap-settings = if args.smart-indent and args.wrap-marker != none and args.wrap-marker != [] {
    (owner: here(), marker: args.wrap-marker)
  }
  let indentation = if guides != none and guides.enabled {
    indent.scan(lines.map(l => l.text), width: guides.width, blank-lines: guides.blank-lines)
  }
  let (
    items: items,
    lines_to_number: lines_to_number,
    rows: rows,
    last-number: last-number,
    guide-depths: guide-depths,
  ) = __codly-line-loop(
    codly-line,
    codly-number,
    smart-skip,
    lines,
    annotations,
    args.callouts,
    ranges,
    skips,
    args.skip-last-empty,
    args.number-enabled,
    args.skip-line,
    args.skip-number,
    codly-annotation,
    codly-callout,
    codly-bubble,
    codly-annotation-ref,
    ref-set,
    args.highlights,
    args.smart-indent,
    args.at("block-label", default: none),
    offset,
    if args.header == none { lang-block } else { [] },
    sublang-lines: sublang-lines,
    get: get,
    indentation: indentation,
    wrap-settings: wrap-settings,
    unnumbered: args.unnumbered,
    parent: it,
    badge-row: badge-row,
    gutter-columns: gutter-columns,
    row-offset: if args.header == none { 0 } else { 1 },
    highlight-colors: __codly-highlight-colors(args.highlights, get(codly-highlight).color),
  )

  // The header counts as a displayed row for palette compatibility.
  if args.header != none {
    lines_to_number.insert(0, -999999999)
    rows.insert(0, (kind: "header", source-line: none, number: none))
    if indentation != none { guide-depths.insert(0, 0) }
  }
  if args.footer != none {
    rows.push((kind: "footer", source-line: none, number: none))
  }

  let indexed-rows = ()
  for (index, row) in rows.enumerate() {
    indexed-rows.push(row + (index: index))
  }
  rows = indexed-rows
  let guide-offsets = if indentation != none and badge-row != none {
    let first = rows.position(row => row.kind == "code")
    std.range(rows.len()).map(index => if index == first { badge-row.left } else { 0pt })
  } else { () }

  let get-line = get(codly-line)
  let fill = if get-line.fill == auto { __default("line", "fill") } else { get-line.fill }

  let line-colors = rows.map(row => {
    // Header/footer cells own their fills and never invoke the line callback.
    if row.kind in ("header", "footer") { return none }
    let highlighted = if row.number == none { none } else {
      highlighted-by-line.at(str(row.number), default: none)
    }
    if highlighted != none { return highlighted }
    if args.__diff != none {
      let paint = diff-impl.fill(row, args.__diff)
      if paint != auto { return paint }
    }
    __codly-row-fill(fill, row)
  })

  let number-settings = get(codly-number)
  let numbers-outside = number-settings.placement == "outside"
  let numbers-enabled = args.number-enabled
  let annot-width = auto
  let line-padding = __codly-inset(get-line.inset)
  let padding = if args.leading == none {
    line-padding
  } else {
    (
      top: args.leading,
      right: line-padding.right,
      bottom: args.leading,
      left: line-padding.left,
    )
  }
  let grid-inset = (
    top: padding.top * 1.5,
    right: padding.right * 1.5,
    bottom: padding.bottom * 1.5,
    left: padding.left * 1.5,
  )
  let gutters = (:)
  if args.gutter != none { gutters.insert("gutter", args.gutter) }
  if args.column-gutter != none { gutters.insert("column-gutter", args.column-gutter) }
  if args.row-gutter != none { gutters.insert("row-gutter", args.row-gutter) }
  let numbers-alignment = number-settings.align
  let outside-column = gutter-count > 0 and numbers-outside
  let edge-padding = block-padding.resolve(args.padding)
  let number-fill = number-settings.fill
  let gutter-fills = if args.gutters == auto { () } else {
    gutter-impl.fills(
      gutter-columns,
      rows,
      line-colors,
      number-fill,
      source: it.lines.map(line => line.text),
    )
  }
  let cell-fill = (x, y) => {
    // Preserve the ordinary number-column paint on spanning callout rows.
    if args.gutters == auto and numbers-enabled and x == 0 {
      if number-fill == auto { line-colors.at(y, default: none) } else { number-fill }
    } else if x < gutter-count {
      gutter-fills.at(x).at(y, default: none)
    } else { line-colors.at(y, default: none) }
  }
  let stroke = get-line.stroke
  let stroke-inset = if stroke == none { 0pt } else if stroke.thickness == auto { 0.5pt } else {
    stroke.thickness / 2
  }

  let grid-content = (intrinsic: false) => {
    // Keep outside gutter widths unchanged: the left code-edge space belongs
    // inside the first code column, not in front of the outside numbers.
    let inset = if outside-column and edge-padding.left > 0pt {
      (x, _) => (
        grid-inset
          + (left: grid-inset.left + if x == gutter-count { edge-padding.left } else { 0pt })
      )
    } else { grid-inset }
    let code-width = if intrinsic { auto } else { 1fr }
    let columns = (
      gutter-columns.map(column => if column == auto { auto } else { column.width })
        + (code-width,)
        + (if has-annotations { (annot-width,) } else { () })
    )
    // Disabling numbers removes their column; column zero then contains code.
    let alignment = (x, _) => if x < gutter-count { numbers-alignment } else { left + horizon }
    set block(breakable: true)
    if (
      outside-column
        or wrap-settings != none
        or (indentation != none and guide-depths.any(d => d > 0))
        or edge-padding.values().any(value => value > 0pt)
    ) {
      geometry.outside(
        columns,
        inset,
        alignment,
        cell-fill,
        if outside-column { stroke } else { none },
        if outside-column { args.radius } else { 0pt },
        header-block,
        items,
        footer-block,
        code-column: gutter-count,
        outside: outside-column,
        padding: edge-padding,
        padding-fill: if type(fill) in (color, gradient, tiling) { fill } else { none },
        wraps: wrap-settings,
        ..gutters,
        guides: if indentation == none { none } else {
          (
            indent.settings(guides, args.rainbow)
              + (
                depths: guide-depths,
                offsets: guide-offsets,
                width: indentation.width,
                // Monospaced guides use whole space advances, measured once per block.
                step: measure(text(" " * indentation.width)).width,
                inset: grid-inset.left + if outside-column { edge-padding.left } else { 0pt },
                // Unindented continuation text must not run through a guide.
                max-height: if args.smart-indent { none } else {
                  (
                    measure[1].height
                      + grid-inset.top.to-absolute()
                      + grid-inset.bottom.to-absolute()
                  )
                },
              )
          )
        },
      )
    } else {
      grid(
        columns: columns,
        inset: grid-inset,
        stroke: none,
        align: alignment,
        fill: cell-fill,
        ..gutters,
        ..header-block,
        ..items,
        ..footer-block,
      )
    }
  }

  let render-block = (width, intrinsic: false) => block(
    breakable: args.breakable,
    clip: not outside-column,
    width: width,
    radius: args.radius,
    stroke: if outside-column { none } else { get-line.stroke },
    inset: (
      top: stroke-inset + edge-padding.top,
      right: stroke-inset + edge-padding.right,
      bottom: stroke-inset + edge-padding.bottom,
      left: stroke-inset + if outside-column { 0pt } else { edge-padding.left },
    ),
    outset: if outside-column { 0pt } else { -stroke-inset },
    grid-content(intrinsic: intrinsic),
  )

  let block_content = if args.width == auto {
    layout(size => {
      // A fractional code column collapses during an unconstrained measure.
      // Use an auto code column for the natural width, then cap the complete
      // rendered block (grid insets, number/annotation columns, and border)
      // to the width available after the surrounding margins.
      let natural-width = measure(render-block(auto, intrinsic: true)).width
      render-block(calc.min(natural-width, size.width))
    })
  } else {
    render-block(args.width)
  }

  // Empty native reference anchors need no figure layout.
  show figure.where(kind: "codly-line"): it => {
    set align(left + horizon)
    it.body
  }

  set par(justify: false, first-line-indent: 0pt)

  output-blocks.join()
  block_content

  [#metadata((last-number: last-number, lines: it.lines.len()))<__codly-block>]
}

#let __codly-show(
  codly-line,
  codly-highlight,
  codly-lang,
  codly-file,
  codly-header,
  codly-footer,
  codly-number,
  codly-annotation,
  codly-callout,
  codly-bubble,
  codly-annotation-ref,
  codly-ref,
  sublang-block,
  constructor,
  args,
  alias-style,
  it,
  prepared-lines: none,
  gutter-constructor: none,
  diff-defaults: (:),
) = e.get(get => __codly-block-render(
  get,
  __codly-show,
  codly-line,
  codly-highlight,
  codly-lang,
  codly-file,
  codly-header,
  codly-footer,
  codly-number,
  codly-annotation,
  codly-callout,
  codly-bubble,
  codly-annotation-ref,
  codly-ref,
  sublang-block,
  constructor,
  args,
  alias-style,
  it,
  prepared-lines: prepared-lines,
  gutter-constructor: gutter-constructor,
  diff-defaults: diff-defaults,
))

#let typst-icon = (
  typ: (
    name: "Typst",
    icon: pdf.artifact(box(
      image("typst-small.png", height: 0.8em),
      baseline: 0.1em,
      inset: 0pt,
      outset: 0pt,
    )),
    color: rgb("#239DAD"),
  ),
  typc: (
    name: "Typst code",
    icon: pdf.artifact(box(
      image("typst-small.png", height: 0.8em),
      baseline: 0.1em,
      inset: 0pt,
      outset: 0pt,
    )),
    color: rgb("#239DAD"),
  ),
)
