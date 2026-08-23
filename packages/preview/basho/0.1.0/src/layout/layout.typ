// src/layout/layout.typ
// Vertical layout entry point

#import "paginate.typ": paginate
#import "page.typ": render-column, render-page
#import "../renderer/renderer.typ": render-char-token

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
        if (
          token.type == "newline"
            or token.type == "parbreak"
            or token.type == "heading-anchor"
        ) {
          0pt
        } else {
          measure(render-char-token(token, config)).height
        }
      })

      let col-gap-abs = measure(v(config.layout.column-gap)).height
      let top-margin = if type(page.margin) == dictionary {
        page.margin.top
      } else { page.margin }
      let top-margin-abs = measure(box(height: top-margin)).height
      let bottom-margin = if type(page.margin) == dictionary {
        page.margin.bottom
      } else { page.margin }
      let bottom-margin-abs = measure(box(height: bottom-margin)).height
      let page-height-abs = measure(box(height: page.height)).height
      let page-body-height = (
        page-height-abs - top-margin-abs - bottom-margin-abs
      )
      let y-in-body = here().position().y - top-margin-abs
      let in-page-context = (
        size.height >= page-body-height - 5pt
          and size.height <= page-body-height + 5pt
      )
      let available-height = if (
        in-page-context and y-in-body >= 0pt and y-in-body <= size.height
      ) {
        size.height - y-in-body
      } else {
        // Clamp to container height when the margin assumption is invalid
        // (e.g., inside box or table cells, not on a page body).
        size.height
      }
      let gap-abs = measure(h(config.layout.gap)).width

      let cfg = config
      // Resolve char-box to absolute for kinsoku compression calculations
      let char-box-abs = measure(box(
        width: config.sizing.char-box,
        height: config.sizing.char-box,
      )).height
      cfg.insert("char-box-abs", char-box-abs)

      // Resolve paragraph-indent and paragraph-spacing to absolute lengths
      let par-indent = cfg.layout.at("paragraph-indent", default: 1em)
      let par-indent-abs = measure(box(height: par-indent)).height
      cfg.insert("paragraph-indent-abs", par-indent-abs)

      let par-spacing = cfg.layout.at("paragraph-spacing", default: 0em)
      let par-spacing-abs = measure(box(height: par-spacing)).height
      cfg.insert("paragraph-spacing-abs", par-spacing-abs)

      let num-segments = cfg.layout.columns

      // First page columns divide remaining height after any preceding content
      // (e.g. headings). Subsequent pages divide the full page body height.
      let first-usable = (
        (available-height - (num-segments - 1) * col-gap-abs) / num-segments
      )
      let full-usable = (
        (size.height - (num-segments - 1) * col-gap-abs) / num-segments
      )

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
            result += stack(
              dir: ttb,
              spacing: cfg.layout.column-gap,
              ..page.rows,
            )
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
        // paginate() skips newline/parbreak tokens (they are not put into columns),
        // so we must advance past them to keep the slice aligned.
        // Also, parbreak handling injects synthetic spacing tokens into columns
        // that do not correspond to any source token — exclude those from the count.
        let consumed = 0
        for col-idx in range(first-count) {
          let col-tokens = cols.at(col-idx)
          let remaining = col-tokens
            .filter(t => t.at("text", default: "") != "" or t.type != "spacing")
            .len()
          while remaining > 0 {
            if consumed >= tokens.len() { break }
            if (
              tokens.at(consumed).type == "newline"
                or tokens.at(consumed).type == "parbreak"
            ) {
              consumed += 1
            } else {
              consumed += 1
              remaining -= 1
            }
          }
        }

        // Render first page
        let first-page = render-page-from-cols(
          cols,
          col-widths,
          0,
          first-usable,
        )
        if first-page.rows.len() > 0 {
          result += stack(
            dir: ttb,
            spacing: cfg.layout.column-gap,
            ..first-page.rows,
          )
        }

        // Phase 2 — paginate remaining tokens with full page height
        if consumed < tokens.len() {
          result += colbreak()
          cfg.insert("usable-height", full-usable)
          let rest-cols = paginate(
            tokens.slice(consumed),
            heights.slice(consumed),
            full-usable,
            cfg,
          )
          let rest-col-widths = rest-cols.map(col => {
            measure(render-column(col, cfg)).width
          })

          let ri = 0
          while ri < rest-cols.len() {
            if ri > 0 { result += colbreak() }
            let page = render-page-from-cols(
              rest-cols,
              rest-col-widths,
              ri,
              full-usable,
            )
            ri = page.new-idx
            if page.rows.len() > 0 {
              result += stack(
                dir: ttb,
                spacing: cfg.layout.column-gap,
                ..page.rows,
              )
            }
          }
        }
      }

      result
    })
  ]
}


