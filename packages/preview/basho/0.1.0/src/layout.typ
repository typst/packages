// src/layout.typ
// Vertical layout with auto-pagination, RTL multi-column, and kinsoku shori

#import "renderer/renderer.typ": render-char-token
#import "core/token.typ": merge-token, token

/// Renders a single column of tokens as a top-to-bottom vertical stack.
///
/// - tokens (array): Array of token dictionaries for this column.
/// - config (dictionary): Layout configuration.
/// -> content: A vertical stack of rendered character boxes.
#let render-column(tokens, config) = {
  if tokens.len() == 0 {
    return box(width: config.sizing.char-box, height: config.sizing.char-box)
  }

  let rendered = tokens.map(token => render-char-token(token, config))

  stack(
    dir: ttb,
    spacing: 0pt,
    ..rendered,
  )
}

#import "core/kinsoku.typ": apply-spacing-compression, is-forbidden-start, is-valid-line-end, justify-line

/// Splits a flat token array into column groups based on a maximum height
/// (absolute length). Uses pre-measured token heights for accuracy,
/// and consults config.kinsoku.resolve for line-breaking decisions.
///
/// - tokens (array): Array of token dictionaries.
/// - heights (array): Parallel array of absolute heights per token.
/// - max-height (length): Maximum column height as absolute length.
/// - config (dictionary): The layout configuration.
/// -> array: Array of arrays, each sub-array is one column's tokens.
#let paginate(tokens, heights, max-height, config) = {
  let columns = ()
  let current-col = ()
  let current-height = 0pt

  let i = 0
  while i < tokens.len() {
    let token = tokens.at(i)
    let h = heights.at(i)

    if token.type == "newline" {
      columns.push(current-col)
      current-col = ()
      current-height = 0pt
      i += 1
      continue
    }

    if token.type == "vblock" or token.type == "hblock" {
      if current-col.len() > 0 {
        columns.push(current-col)
      }
      columns.push((token,))
      current-col = ()
      current-height = 0pt
      i += 1
      continue
    }

    if current-height > 0pt and current-height + h > max-height {
      config.kinsoku.insert("next-token", if i + 1 < tokens.len() { tokens.at(i + 1) } else { none })
      let decision = (config.kinsoku.resolve)(current-col, token, h, config, current-height, max-height)

      if decision.action == "burasagari" {
        let hanging-token = merge-token(token, (type: "hanging"))
        current-col.push(hanging-token)
        columns.push(current-col)
        current-col = ()
        current-height = 0pt
        i += 1
        continue
      }

      if decision.action == "oikomi" {
        current-col = apply-spacing-compression(current-col, decision.compression-amount, config)
        current-col.push(token)
        columns.push(current-col)
        current-col = ()
        current-height = 0pt
        i += 1
        continue
      }

      if decision.action == "push-previous" {
        let popped = ()
        let popped-height = 0pt
        let popped-start = i - current-col.len()
        while current-col.len() > 0 {
          let p = current-col.pop()
          let ph = heights.at(popped-start + current-col.len())
          popped.insert(0, p)
          popped-height += ph

          let new-last = if current-col.len() > 0 { current-col.last() } else { none }
          if is-valid-line-end(new-last, config.kinsoku.forbidden-end) {
            // If the overflow token is forbidden-start and the new column
            // would start with one too, cascade further to prevent a
            // column-start kinsoku violation.
            let tok-start = is-forbidden-start(token, config.kinsoku.forbidden-start)
            let pop-start = popped.len() > 0 and is-forbidden-start(popped.first(), config.kinsoku.forbidden-start)
            let needs-more = tok-start and pop-start
            if not needs-more {
              break
            }
          }
        }

        let exhausted = current-col.len() == 0
        current-col = justify-line(current-col, max-height - (current-height - popped-height))
        columns.push(current-col)
        if exhausted {
          // All tokens were popped but the violation persists.
          // Force oidashi to prevent infinite loop.
          current-col = (token,)
          current-height = h
          i += 1
        } else {
          current-col = popped
          current-height = popped-height
        }
        continue
      }

      // oidashi — break normally before the current token
      current-col = justify-line(current-col, max-height - current-height)
      columns.push(current-col)
      current-col = (token,)
      current-height = h
    } else {
      current-col.push(token)
      current-height += h
    }

    i += 1
  }

  if current-col.len() > 0 {
    columns.push(current-col)
  }

  columns
}

/// Renders a single page worth of columns arranged RTL.
///
/// - cols (array): Array of column token arrays for this page.
/// - gap (length): Horizontal gap between columns.
/// - config (dictionary): The layout configuration.
/// -> content: RTL-arranged vertical columns.
#let render-page(cols, gap, config) = {
  if config.layout.hooks.len() > 0 {
    return config.layout.hooks.last()(cols, config.font, gap, config)
  }
  let rendered = cols.map(col => render-column(col, config))
  align(right + top, stack(
    dir: rtl,
    spacing: gap,
    ..rendered,
  ))
}

/// Main layout entry point. Two-pass approach:
/// Pass 1: layout() measures page dims + actual token heights, paginates into columns.
/// Pass 2: context block reads pre-computed columns and renders with pagebreaks.
///
/// - tokens (array): Array of token dictionaries.
/// - config (dictionary): Configuration dictionary.
/// -> content: Fully paginated vertical text.
#let layout-tate(tokens, config) = {
  if tokens.len() == 0 {
    return []
  }

  [
    #set par(spacing: 0pt)
    #set block(spacing: 0pt)

    // Measure and render within the current flow so height is respected.
    #layout(size => context {
      let heights = tokens.map(token => {
        if token.type == "newline" or token.type == "heading-anchor" {
          0pt
        } else {
          measure(render-char-token(token, config)).height
        }
      })

      let col-gap-abs = measure(v(config.layout.column-gap)).height
      let top-margin = if type(page.margin) == dictionary { page.margin.top } else { page.margin }
      let top-margin-abs = measure(box(height: top-margin)).height
      let bottom-margin = if type(page.margin) == dictionary { page.margin.bottom } else { page.margin }
      let bottom-margin-abs = measure(box(height: bottom-margin)).height
      let page-height-abs = measure(box(height: page.height)).height
      let page-body-height = page-height-abs - top-margin-abs - bottom-margin-abs
      let y-in-body = here().position().y - top-margin-abs
      let in-page-context = size.height >= page-body-height - 5pt and size.height <= page-body-height + 5pt
      let available-height = if in-page-context and y-in-body >= 0pt and y-in-body <= size.height {
        size.height - y-in-body
      } else {
        // Clamp to container height when the margin assumption is invalid
        // (e.g., inside box or table cells, not on a page body).
        size.height
      }
      let gap-abs = measure(h(config.layout.gap)).width

      let cfg = config
      // Resolve char-box to absolute for kinsoku compression calculations
      let char-box-abs = measure(box(width: config.sizing.char-box, height: config.sizing.char-box)).height
      cfg.insert("char-box-abs", char-box-abs)

      let num-segments = cfg.layout.columns

      // First page columns divide remaining height after any preceding content
      // (e.g. headings). Subsequent pages divide the full page body height.
      let first-usable = (available-height - (num-segments - 1) * col-gap-abs) / num-segments
      let full-usable = (size.height - (num-segments - 1) * col-gap-abs) / num-segments

      let result = []

      // Helper: render one page's segments from a column array
      let render-page-from-cols(cols, col-widths, start-idx, height) = {
        let ri = start-idx
        let page-rows = ()
        let seg = 0
        while seg < num-segments {
          if ri >= cols.len() { break }
          let seg-cols = ()
          let seg-w = 0pt
          while ri < cols.len() {
            let w = col-widths.at(ri)
            let add = if seg-cols.len() == 0 { w } else { w + gap-abs }
            if seg-w > 0pt and seg-w + add > size.width { break }
            seg-cols.push(cols.at(ri))
            seg-w += add
            ri += 1
          }
          if seg-cols.len() > 0 {
            page-rows.push(render-page(seg-cols, cfg.layout.gap, cfg))
          }
          seg += 1
        }
        (new-idx: ri, rows: page-rows)
      }

      if first-usable >= full-usable {
        // Single phase — no heading offset (or negative), use full height.
        cfg.insert("usable-height", full-usable)
        let cols = paginate(tokens, heights, full-usable, cfg)
        let col-widths = cols.map(col => measure(render-column(col, cfg)).width)

        let i = 0
        while i < cols.len() {
          if i > 0 { result += colbreak() }
          let page = render-page-from-cols(cols, col-widths, i, full-usable)
          i = page.new-idx
          if page.rows.len() > 0 {
            result += stack(dir: ttb, spacing: cfg.layout.column-gap, ..page.rows)
          }
        }
      } else {
        // Two-phase: first page uses remaining height, rest use full page height.

        // Phase 1 — paginate with first-page height
        cfg.insert("usable-height", first-usable)
        let cols = paginate(tokens, heights, first-usable, cfg)
        let col-widths = cols.map(col => measure(render-column(col, cfg)).width)

        // Count columns on the first page
        let first-count = 0
        let tmp = 0
        for segment in range(num-segments) {
          if tmp >= cols.len() { break }
          let seg-w = 0pt
          while tmp < cols.len() {
            let w = col-widths.at(tmp)
            let add = if seg-w == 0pt { w } else { w + gap-abs }
            if seg-w > 0pt and seg-w + add > size.width { break }
            seg-w += add
            tmp += 1
            first-count += 1
          }
        }

        // Count tokens consumed on the first page.
        // paginate() skips newline tokens (they are not put into columns),
        // so we must advance past them to keep the slice aligned.
        let consumed = 0
        for col-idx in range(first-count) {
          let remaining = cols.at(col-idx).len()
          while remaining > 0 {
            if tokens.at(consumed).type == "newline" {
              consumed += 1
            } else {
              consumed += 1
              remaining -= 1
            }
          }
        }

        // Render first page
        let first-page = render-page-from-cols(cols, col-widths, 0, first-usable)
        if first-page.rows.len() > 0 {
          result += stack(dir: ttb, spacing: cfg.layout.column-gap, ..first-page.rows)
        }

        // Phase 2 — paginate remaining tokens with full page height
        if consumed < tokens.len() {
          result += colbreak()
          cfg.insert("usable-height", full-usable)
          let rest-cols = paginate(tokens.slice(consumed), heights.slice(consumed), full-usable, cfg)
          let rest-col-widths = rest-cols.map(col => measure(render-column(col, cfg)).width)

          let ri = 0
          while ri < rest-cols.len() {
            if ri > 0 { result += colbreak() }
            let page = render-page-from-cols(rest-cols, rest-col-widths, ri, full-usable)
            ri = page.new-idx
            if page.rows.len() > 0 {
              result += stack(dir: ttb, spacing: cfg.layout.column-gap, ..page.rows)
            }
          }
        }
      }

      result
    })
  ]
}


