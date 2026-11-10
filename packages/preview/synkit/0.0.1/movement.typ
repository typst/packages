// Movement module for synkit
// Draws inline movement notation with subscripted bracket labels
// and rectangular arrows below the text.
// Usage: #move("[CP Who do you think [(CP)[TP<who>saw Mary]]]",
//              arrows: ((from: "who2", to: "who1"),))

#import "@preview/cetz:0.4.2"
#import "_symbols.typ": apply-symbols as _apply-symbols, symbol-map as _symbol-map

// Draw a delink mark (two perpendicular bars) at a point along a line.
#let _draw-delink(mx, my, tang-x, tang-y, sw) = {
  let len = calc.sqrt(tang-x * tang-x + tang-y * tang-y)
  if len == 0 { return }
  let dir-x = tang-x / len
  let dir-y = tang-y / len
  let perp-x = -dir-y
  let perp-y = dir-x
  let bar = 0.15
  let gap = 0.03
  for sign in (-1, 1) {
    let cx = mx + sign * gap * dir-x
    let cy = my + sign * gap * dir-y
    cetz.draw.line(
      (cx - bar * perp-x, cy - bar * perp-y),
      (cx + bar * perp-x, cy + bar * perp-y),
      stroke: sw,
    )
  }
}

/// Render a blank underline, representing an empty position (e.g. where
/// something used to be before moving).  Use standalone in regular text.
#let blank(width: 2em) = box(
  width: width, height: 0.8em, baseline: 50%,
  stroke: (bottom: 0.5pt + black),
)

// Internal helpers — shared between _move-layout and move() rendering
// so measurements stay consistent.
#let _blank-box() = box(width: 2em, height: 0.8em, stroke: (bottom: 0.5pt + black))

#let _t-trace-box(subscript, fsz, sub-fsz) = {
  text(size: fsz, style: "italic", "t") + text(size: sub-fsz, baseline: 0.2em, style: "italic", _apply-symbols(subscript))
}

// ── Classify a word buffer into word / blank / t-trace ────────────────────
#let _classify-word(buf) = {
  if buf == "__" {
    (type: "blank")
  } else if buf.len() >= 3 and buf.starts-with("t_") {
    (type: "t-trace", subscript: buf.slice(2))
  } else {
    (type: "word", text: buf)
  }
}

// ── Move tokenizer ──────────────────────────────────────────────────────────
// Splits inline movement notation into tokens:
//   [LABEL  → bracket-open with label
//   [(LABEL) → bracket-open with parenthesized label
//   ]       → bracket-close
//   <name>  → trace marker (visible, creates anchor)
//   word    → bare word
#let _move-tokenize(input) = {
  let tokens = ()
  let chars = input.clusters()
  let i = 0
  let buf = ""
  let n = chars.len()

  while i < n {
    let ch = chars.at(i)

    if ch == "[" {
      // Flush word buffer
      if buf != "" {
        tokens.push(_classify-word(buf))
        buf = ""
      }
      // Scan label after [
      i = i + 1
      let label = ""
      if i < n and chars.at(i) == "(" {
        // Parenthesized label: [(LABEL)
        let paren-buf = "("
        i = i + 1
        while i < n and chars.at(i) != ")" {
          paren-buf = paren-buf + chars.at(i)
          i = i + 1
        }
        if i < n {
          paren-buf = paren-buf + ")"
          i = i + 1
        } // consume )
        label = paren-buf
      } else {
        // Regular label: [LABEL (until whitespace, [, ], <, or end)
        while i < n and chars.at(i) != " " and chars.at(i) != "[" and chars.at(i) != "]" and chars.at(i) != "<" {
          label = label + chars.at(i)
          i = i + 1
        }
      }
      tokens.push((type: "bracket-open", label: label))
    } else if ch == "]" {
      if buf != "" {
        tokens.push(_classify-word(buf))
        buf = ""
      }
      tokens.push((type: "bracket-close"))
      i = i + 1
    } else if ch == "<" {
      if buf != "" {
        tokens.push(_classify-word(buf))
        buf = ""
      }
      // Scan trace name until >
      i = i + 1
      let name = ""
      while i < n and chars.at(i) != ">" {
        name = name + chars.at(i)
        i = i + 1
      }
      if i < n { i = i + 1 } // consume >
      tokens.push((type: "trace", name: name))
    } else if ch == " " {
      if buf != "" {
        tokens.push(_classify-word(buf))
        buf = ""
      }
      i = i + 1
    } else {
      buf = buf + ch
      i = i + 1
    }
  }
  if buf != "" { tokens.push(_classify-word(buf)) }
  tokens
}

// ── Assign anchors to move tokens ───────────────────────────────────────────
// Words and traces share a common counter pool (case-insensitive).
// Bracket labels get their own anchors too.
// Strip punctuation and symbol shortcuts for anchor naming
// \lambda → lambda, chocolate? → chocolate
#let _strip-anchor(s) = {
  let result = s
  // Strip subscript suffix: Who_i → Who
  let upos = result.position("_")
  if upos != none and upos > 0 {
    result = result.slice(0, upos)
  }
  // Strip formatting markers
  for p in ("**", "*", "@", "&", "~") {
    result = result.replace(p, "")
  }
  for p in ("?", "!", ".", ",", ";", ":", "'", "'") {
    result = result.replace(p, "")
  }
  // Strip backslash from symbol shortcuts: \lambda → lambda
  for (key, _val) in _symbol-map {
    if result.contains(key) {
      result = result.replace(key, key.slice(1))
    }
  }
  result
}

// ── Format a word for move(): handles *italic*, **bold**, @smallcaps@,
// &underline&, ~strike~, and Word_i subscripts.
// Returns Typst content ready for rendering.
#let _move-format-word(raw, fsz, sub-fsz) = {
  // Split subscript: Who_i → main="Who", sub-text="i"
  let main = raw
  let sub-text = none
  let upos = raw.position("_")
  if upos != none and upos > 0 {
    main = raw.slice(0, upos)
    sub-text = raw.slice(upos + 1)
  }

  // Detect formatting markers
  let is-bold = main.starts-with("**") and main.ends-with("**") and main.len() >= 5
  let is-italic = not is-bold and main.starts-with("*") and main.ends-with("*") and main.len() >= 3
  let is-smallcaps = main.starts-with("@") and main.ends-with("@") and main.len() >= 3
  let is-underline = main.starts-with("&") and main.ends-with("&") and main.len() >= 3
  let is-strike = main.starts-with("~") and main.ends-with("~") and main.len() >= 3

  // Strip markers
  let inner = if is-bold { main.slice(2, main.len() - 2) }
    else if is-italic { main.slice(1, main.len() - 1) }
    else if is-smallcaps { main.slice(1, main.len() - 1) }
    else if is-underline { main.slice(1, main.len() - 1) }
    else if is-strike { main.slice(1, main.len() - 1) }
    else { main }

  // Apply symbol substitution
  let display = _apply-symbols(inner)

  // Apply formatting
  let body = if is-bold { text(size: fsz, weight: "bold", display) }
    else if is-italic { text(size: fsz, style: "italic", display) }
    else if is-smallcaps { text(size: fsz, smallcaps(display)) }
    else if is-underline { text(size: fsz, underline(display)) }
    else if is-strike { text(size: fsz, strike(display)) }
    else { text(size: fsz, _apply-symbols(main)) }

  // Append subscript
  if sub-text != none {
    body + text(size: sub-fsz, baseline: 0.2em, style: "italic", _apply-symbols(sub-text))
  } else {
    body
  }
}

#let _move-assign-anchors(tokens) = {
  let counts = (:)
  let result = ()
  for tok in tokens {
    if tok.type == "word" {
      let key = _strip-anchor(lower(tok.text)).replace("'", "bar").replace("'", "bar").replace(" ", "-")
      let c = counts.at(key, default: 0) + 1
      counts.insert(key, c)
      result.push((..tok, anchor: key + str(c)))
    } else if tok.type == "trace" {
      let key = lower(tok.name).replace("'", "bar").replace("'", "bar").replace(" ", "-")
      let c = counts.at(key, default: 0) + 1
      counts.insert(key, c)
      result.push((..tok, anchor: key + str(c)))
    } else if tok.type == "blank" {
      let key = "trace"
      let c = counts.at(key, default: 0) + 1
      counts.insert(key, c)
      result.push((..tok, anchor: key + str(c)))
    } else if tok.type == "t-trace" {
      let key = "trace"
      let c = counts.at(key, default: 0) + 1
      counts.insert(key, c)
      result.push((..tok, anchor: key + str(c)))
    } else if tok.type == "bracket-open" and tok.label != "" {
      // Strip parens for anchor naming: (CP) → cp
      let raw = tok.label.replace("(", "").replace(")", "")
      let key = lower(raw).replace("'", "bar").replace("'", "bar").replace(" ", "-")
      let c = counts.at(key, default: 0) + 1
      counts.insert(key, c)
      result.push((..tok, anchor: key + str(c)))
    } else {
      result.push((..tok, anchor: none))
    }
  }
  result
}

// ── Compute layout positions for move tokens (measure-based) ────────────────
// Must be called inside a context block. Uses measure() for accurate widths.
// Returns array of layout entries with x-positions, plus total width.
#let _move-layout(tokens, fsz, sub-fsz, scale-factor) = {
  let unit = scale-factor * 1cm // canvas unit length
  let space-w = measure(text(size: fsz, " ")).width / unit
  let x = 0.0
  let entries = ()
  let prev-type = none

  for tok in tokens {
    if tok.type == "bracket-open" {
      // Space before bracket if preceded by word, trace, or bracket-close
      if prev-type == "word" or prev-type == "trace" or prev-type == "bracket-close" or prev-type == "blank" or prev-type == "t-trace" {
        x = x + space-w
      }
      let entry-x = x
      let bw = measure(text(size: fsz, "[")).width / unit
      x = x + bw
      // Subscript label width
      let sub-w = 0.0
      if tok.label != "" {
        sub-w = measure(text(size: sub-fsz, _apply-symbols(tok.label))).width / unit
        x = x + sub-w
      }
      entries.push((..tok, x: entry-x, width: bw + sub-w, bw: bw, anchor-x: entry-x + bw * 0.5))
      prev-type = "bracket-open"
    } else if tok.type == "bracket-close" {
      // No space before closing bracket
      let entry-x = x
      let bw = measure(text(size: fsz, "]")).width / unit
      x = x + bw
      entries.push((..tok, x: entry-x, width: bw, anchor-x: entry-x))
      prev-type = "bracket-close"
    } else if tok.type == "trace" {
      if prev-type != none { x = x + space-w }
      let entry-x = x
      let display = "⟨" + _apply-symbols(tok.name) + "⟩"
      let w = measure(text(size: fsz, display)).width / unit
      x = x + w
      entries.push((..tok, x: entry-x, width: w, anchor-x: entry-x + w * 0.5))
      prev-type = "trace"
    } else if tok.type == "word" {
      if prev-type != none { x = x + space-w }
      let entry-x = x
      let w = measure(_move-format-word(tok.text, fsz, sub-fsz)).width / unit
      x = x + w
      entries.push((..tok, x: entry-x, width: w, anchor-x: entry-x + w * 0.5))
      prev-type = "word"
    } else if tok.type == "blank" {
      if prev-type != none { x = x + space-w }
      let entry-x = x
      let w = measure(_blank-box()).width / unit
      x = x + w
      entries.push((..tok, x: entry-x, width: w, anchor-x: entry-x + w * 0.5))
      prev-type = "blank"
    } else if tok.type == "t-trace" {
      if prev-type != none { x = x + space-w }
      let entry-x = x
      let w = measure(_t-trace-box(tok.subscript, fsz, sub-fsz)).width / unit
      x = x + w
      entries.push((..tok, x: entry-x, width: w, anchor-x: entry-x + w * 0.5))
      prev-type = "t-trace"
    }
  }
  (entries: entries, total-width: x)
}

/// Draw inline movement notation with subscripted bracket labels and
/// rectangular arrows below the text.
///
/// - input (string): Bracket notation with movement markers.
///   - `[LABEL ...]` — opening bracket with subscript label
///   - `[(LABEL)...]` — bracket with parenthesized subscript label
///   - `<name>` — visible trace/copy marker; creates a named anchor
///   - bare words — rendered as plain text; auto-create anchors
///
/// - arrows (array): Movement arrows drawn below the text.
///   Each entry is a dict with `from`, `to`, and optional `dash`, `color`,
///   `line-width`. Anchors are auto-numbered by occurrence (case-insensitive):
///   "Who" → `who1`, `<who>` → `who2`.
/// - protect (bool): When `true`, reserves vertical space for arrows below the
///   text. Use this for standalone output such as gallery PNG exports. The
///   default `false` keeps baseline alignment cleaner inside table cells and
///   numbered examples. (default: `false`)
///
/// Example:
/// ```
/// #move(
///   "[CP Who do you think [(CP)[TP<who>saw Mary]]]",
///   arrows: ((from: "who2", to: "who1", dash: "solid", color: black),),
/// )
/// ```
#let move(
  input,
  arrows: (),
  delinks: (),
  scale: 1.0,
  content-size: 1,
  line-width: 1.0,
  protect: false,
) = {
  let scale-factor = scale

  // Tokenize and assign anchors
  let tokens = _move-tokenize(input)
  let tokens = _move-assign-anchors(tokens)

  // Render (layout computed inside context for accurate measure())
  context {
    let fsz = content-size * 1em / scale-factor
    let sub-fsz = fsz * 0.65

    // Layout with real measurements
    let layout = _move-layout(tokens, fsz, sub-fsz, scale-factor)
    let entries = layout.entries

    // Build name-to-pos mapping: anchor → x-center
    let name-to-pos = (:)
    for e in entries {
      if e.anchor != none {
        name-to-pos.insert(e.anchor, e.anchor-x)
      }
    }
    let _norm = luma(15%)
    let sw = 0.018 * line-width
    let arrow-mark-scale = 0.5

    // Render the canvas, then trim it to text-only height so table cells
    // with bottom alignment put "b." at the text level.
    let unit = scale-factor * 1cm
    let box-w = layout.total-width * unit

    let canvas-body = cetz.canvas(length: unit, {
        import cetz.draw: *

        // ── Render text elements ──────────────────────────────
        // Fixed-height box ensures consistent baseline alignment across all elements.
        let ref-h = measure(text(size: fsz, "Hgy[")).height
        let _aligned(body) = box(height: ref-h, align(horizon, body))

        for e in entries {
          if e.type == "bracket-open" {
            content(
              (e.x, 0),
              _aligned(text(size: fsz, "[")),
              anchor: "west",
            )
            // Draw subscript label
            if e.label != "" {
              content(
                (e.x + e.bw, -0.08),
                text(size: sub-fsz, _apply-symbols(e.label)),
                anchor: "north-west",
              )
            }
          } else if e.type == "bracket-close" {
            content(
              (e.x, 0),
              _aligned(text(size: fsz, "]")),
              anchor: "west",
            )
          } else if e.type == "trace" {
            content(
              (e.x, 0),
              _aligned(text(size: fsz, "⟨" + _apply-symbols(e.name) + "⟩")),
              anchor: "west",
            )
          } else if e.type == "word" {
            content(
              (e.x, 0),
              _aligned(_move-format-word(e.text, fsz, sub-fsz)),
              anchor: "west",
            )
          } else if e.type == "blank" {
            content(
              (e.x, 0),
              _aligned(_blank-box()),
              anchor: "west",
            )
          } else if e.type == "t-trace" {
            content(
              (e.x, 0),
              _aligned(_t-trace-box(e.subscript, fsz, sub-fsz)),
              anchor: "west",
            )
          }
        }

        // ── Draw rectangular arrows below text ────────────────
        let head-back = 0.12
        let base-drop = 0.35 // gap below text baseline to start arrow
        let rect-count = 0

        for arrow in arrows {
          let is-dict = type(arrow) == dictionary
          let raw-from = if is-dict { arrow.at("from") } else { arrow.at(0) }
          let raw-to = if is-dict { arrow.at("to") } else { arrow.at(1) }
          let paint = if is-dict { arrow.at("color", default: _norm) } else { _norm }
          let dash-style = if is-dict { arrow.at("dash", default: "solid") } else { "solid" }
          let arrow-lw = if is-dict { arrow.at("line-width", default: 1.0) } else { 1.0 }

          if raw-from in name-to-pos and raw-to in name-to-pos {
            let fx = name-to-pos.at(raw-from)
            let tx = name-to-pos.at(raw-to)

            let a-sw = sw * arrow-lw
            let is-wavy = dash-style == "wavy"
            let shaft-stroke = if dash-style == "solid" or is-wavy {
              (paint: paint, thickness: a-sw)
            } else {
              (paint: paint, thickness: a-sw, dash: dash-style)
            }
            let head-stroke = (paint: paint, thickness: a-sw)
            let mark-style = (end: ">", fill: paint, scale: arrow-mark-scale)

            // Rectangular arrow below text
            let stagger = rect-count * 0.35
            rect-count = rect-count + 1

            let bar-y = -(base-drop + 0.5 + stagger)
            let drop-y = -(base-drop)

            if is-wavy {
              // Wavy: smooth sine wave along each leg
              let amp = 0.035  // wave amplitude
              let wlen = 0.10  // wave length (one full cycle)
              let samples-per-cycle = 12 // points per cycle for smoothness

              // Sine-wave along a vertical segment
              let _wavy-v(x0, y0, y1, stk) = {
                let dist = calc.abs(y1 - y0)
                let sgn = if y1 > y0 { 1 } else { -1 }
                let cycles = calc.max(1, calc.round(dist / wlen))
                let total = int(cycles * samples-per-cycle)
                for k in range(total) {
                  let t0 = k / total
                  let t1 = (k + 1) / total
                  let py0 = y0 + sgn * t0 * dist
                  let py1 = y0 + sgn * t1 * dist
                  let px0 = x0 + amp * calc.sin(t0 * cycles * 2 * calc.pi)
                  let px1 = x0 + amp * calc.sin(t1 * cycles * 2 * calc.pi)
                  line((px0, py0), (px1, py1), stroke: stk)
                }
              }

              // Sine-wave along a horizontal segment
              let _wavy-h(y0, x0, x1, stk) = {
                let dist = calc.abs(x1 - x0)
                let sgn = if x1 > x0 { 1 } else { -1 }
                let cycles = calc.max(1, calc.round(dist / wlen))
                let total = int(cycles * samples-per-cycle)
                for k in range(total) {
                  let t0 = k / total
                  let t1 = (k + 1) / total
                  let px0 = x0 + sgn * t0 * dist
                  let px1 = x0 + sgn * t1 * dist
                  let py0 = y0 + amp * calc.sin(t0 * cycles * 2 * calc.pi)
                  let py1 = y0 + amp * calc.sin(t1 * cycles * 2 * calc.pi)
                  line((px0, py0), (px1, py1), stroke: stk)
                }
              }

              // From: drop down (wavy)
              _wavy-v(fx, drop-y, bar-y, shaft-stroke)
              // Horizontal bar (wavy)
              _wavy-h(bar-y, fx, tx, shaft-stroke)
              // To: rise up (wavy stops early, straight into arrowhead)
              let clear = 0.18 // clearance for a clean arrowhead
              _wavy-v(tx, bar-y, drop-y - clear, shaft-stroke)
              line((tx, drop-y - clear), (tx, drop-y - head-back), stroke: shaft-stroke)
              let tiny = 0.01
              line((tx, drop-y - head-back - tiny), (tx, drop-y), stroke: head-stroke, mark: mark-style)
            } else {
              // From: drop down
              line((fx, drop-y), (fx, bar-y), stroke: shaft-stroke)
              // Horizontal bar
              line((fx, bar-y), (tx, bar-y), stroke: shaft-stroke)
              // To: rise up with arrowhead
              line((tx, bar-y), (tx, drop-y - head-back), stroke: shaft-stroke)
              let tiny = 0.01
              line((tx, drop-y - head-back - tiny), (tx, drop-y), stroke: head-stroke, mark: mark-style)
            }

            // Delink mark on horizontal bar
            if (rect-count - 1) in delinks {
              let mid-x = (fx + tx) / 2
              _draw-delink(mid-x, bar-y, 1.0, 0.0, (paint: paint, thickness: a-sw))
            }
          }
        }
      })

    // When protect is true, extend the box downward to cover arrows
    // so subsequent content doesn't overlap.  When false (default),
    // keep the box text-height only — correct for table cells with
    // align: bottom.
    if protect and arrows.len() > 0 {
      let base-drop = 0.35
      let depth = base-drop + 0.5 + (arrows.len() - 1) * 0.35
      let arrow-depth = (depth + 0.15) * unit
      let ref-content = text(size: fsz, "Hgy[")
      let ref-height = measure(ref-content).height
      box(
        width: box-w,
        height: ref-height + arrow-depth,
        baseline: arrow-depth,
        clip: false,
        {
          hide(ref-content)
          place(top + left, canvas-body)
        },
      )
    } else {
      box(width: box-w, clip: false, {
        hide(text(size: fsz, "Hgy["))
        place(top + left, canvas-body)
      })
    }
  }
}
