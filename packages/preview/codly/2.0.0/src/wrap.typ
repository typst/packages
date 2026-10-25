// Observe native line breaking with zero-width tags, without replacing source
// text, adding break opportunities, or splitting grapheme clusters.
#let standalone = regex("[\\p{Han}\\p{Hiragana}\\p{Katakana}\\p{Hangul}\\p{P}\\p{S}]")

#let annotate(body, owner, row) = {
  let probe(s) = [#text(s)#context [#metadata((
      owner: owner,
      row: row,
      width: measure(text(s)).width,
    ))<__codly-wrap-point>]]
  let visit(body) = {
    if body.has("text") {
      let parts = ()
      let token = ""
      // raw.line.text has normalized tabs to ASCII spaces. Avoid `trim()` on
      // every cluster; it allocated on the hottest wrap-marker path.
      for c in body.text.clusters() {
        let space = c == " "
        let ascii-word = (
          (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or (c >= "0" and c <= "9") or c == "_"
        )
        let separate = space or (not ascii-word and c.contains(standalone))
        if separate and token != "" {
          parts.push(probe(token))
          token = ""
        }
        if space { parts.push(text(c)) } else if separate { parts.push(probe(c)) } else {
          token += c
        }
      }
      if token != "" { parts.push(probe(token)) }
      parts.join()
    } else if body.has("children") {
      body.children.map(visit).join()
    } else if body.has("child") and body.has("styles") {
      (body.func())(visit(body.child), body.styles)
    } else if body.has("body") {
      let fields = body.fields()
      fields.body = visit(fields.body)
      (body.func())(..fields)
    } else { body }
  }
  visit(body)
}

// One query pair per block, shared by all of its page/column backgrounds.
#let marks(owner, end, regions) = {
  let rows = (:)
  for record in query(selector(<__codly-wrap-row>).after(owner).before(end)) {
    if record.value.owner == owner {
      rows.insert(str(record.value.row), record.value)
    }
  }
  let previous = (:)
  let result = ()
  let by-page = (:)
  for r in regions {
    let key = str(r.at.page)
    by-page.insert(key, by-page.at(key, default: ()) + (r,))
  }
  for point in query(selector(<__codly-wrap-point>).after(owner).before(end)) {
    if point.value.owner != owner { continue }
    let key = str(point.value.row)
    let row = rows.at(key, default: none)
    if row == none { continue }
    let at = point.location().position()
    let left = at.x - point.value.width
    let region = by-page
      .at(str(at.page), default: ())
      .find(r => r.at.x <= left and left < r.at.x + r.width and r.at.y <= at.y and at.y <= r.bottom)
    let region-key = if region == none { none } else { (region.at.x, region.at.y) }
    let before = previous.at(key, default: none)
    if (
      before != none
        and (
          at.page != before.at.page
            or region-key != before.region
            or (
              at.y - before.at.y > row.tolerance and left < before.at.x - 0.001pt
            )
        )
    ) {
      result.push((at: (page: at.page, x: left - row.advance, y: at.y), body: row.marker))
    }
    previous.insert(key, (at: at, region: region-key))
  }
  result
}

// Paint a single footer region without reconstructing every cell region. The
// points are still visited in document order so continuations from a previous
// page or column are detected correctly.
#let marks-region(owner, end, region) = {
  let rows = (:)
  for record in query(selector(<__codly-wrap-row>).after(owner).before(end)) {
    if record.value.owner == owner {
      rows.insert(str(record.value.row), record.value)
    }
  }
  let previous = (:)
  let result = ()
  for point in query(selector(<__codly-wrap-point>).after(owner).before(end)) {
    if point.value.owner != owner { continue }
    let key = str(point.value.row)
    let row = rows.at(key, default: none)
    if row == none { continue }
    let at = point.location().position()
    let left = at.x - point.value.width
    let before = previous.at(key, default: none)
    let inside = (
      at.page == region.page
        and left >= region.x
        and left < region.x + region.width
        and at.y >= region.top
        and at.y < region.bottom
    )
    if (
      inside
        and before != none
        and (
          at.page != before.page
            or at.y < before.y - row.tolerance
            or (at.y - before.y > row.tolerance and left < before.x - 0.001pt)
        )
    ) {
      result.push((at: (page: at.page, x: left - row.advance, y: at.y), body: row.marker))
    }
    previous.insert(key, (page: at.page, x: left, y: at.y))
  }
  result
}
