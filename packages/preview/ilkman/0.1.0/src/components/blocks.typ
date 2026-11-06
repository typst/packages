// ilkman — layout and box components
#import "../core.typ": *

/// Practical columns.
///
/// ```typst
/// #im-grid("1/2", fill: "green", stroke: true)[narrow][wide]
/// ```
///
/// - ratio (str, array): "1/1" two equal, "1/2" one third / two thirds,
///   "1/1/1" three equal; or (1, 2). Extra bodies wrap to the next row.
/// - gutter (length): space between columns.
/// - stroke (none, bool, str, color): box border; `true` = palette border.
/// - fill (none, str, color, array): box background, always kept light;
///   an array gives one fill per column.
/// - radius, inset: box corner radius and inner padding.
/// - align (str, alignment): vertical alignment of column content.
#let im-grid(
  gutter: 1em,
  stroke: none,
  fill: none,
  radius: 4pt,
  inset: 0.8em,
  align: top,
  ..args,
) = context {
  let c = ctx()
  let pal = c.pal
  let pos = args.pos()
  let ratio = "1/1"
  if pos.len() > 0 and (type(pos.first()) == str or type(pos.first()) == array or type(pos.first()) == int) {
    ratio = pos.first()
    pos = pos.slice(1)
  }
  let cols = parse-ratio(ratio)
  let n = cols.len()
  let boxed = stroke not in (none, false) or fill != none
  let fill-of(i) = {
    let f = if type(fill) == array { fill.at(calc.rem(i, fill.len())) } else { fill }
    light-fill(pal, f)
  }
  let cells = pos.enumerate().map(((i, b)) => {
    if boxed {
      block(
        width: 100%,
        inset: inset,
        radius: radius,
        fill: fill-of(calc.rem(i, n)),
        stroke: soft-stroke(pal, stroke),
        { if fill-of(calc.rem(i, n)) != none { set text(fill: box-ink(c)); b } else { b } },
      )
    } else { b }
  })
  grid(
    columns: cols,
    column-gutter: gutter,
    row-gutter: gutter,
    align: to-align(align),
    ..cells,
  )
}

/// Callout box.
///
/// - kind (str): "info", "tip", "warn", "danger".
/// - title (auto, none, content): `auto` uses the translated kind name.
#let im-note(kind: "info", title: auto, body) = context {
  let c = ctx()
  let hue = note-hues.at(kind, default: kind)
  let t = hue-tones(c.pal, hue)
  let icon = (info: "i", tip: "✓", warn: "!", danger: "×").at(kind, default: "•")
  block(
    width: 100%,
    fill: t.z2,
    stroke: (left: 2.5pt + t.strong, rest: 0.5pt + t.z1.darken(5%)),
    inset: (x: 1em, y: 0.8em),
    breakable: true,
    {
      set text(fill: box-ink(c))
      if title != none {
        block(below: 0.6em, sticky: true, text(
          fill: t.text,
          weight: "bold",
          {
            box(
              baseline: 0.15em,
              circle(radius: 0.55em, fill: t.strong, align(center + horizon, text(fill: white, size: 0.75em, icon))),
            )
            h(0.45em)
            if title == auto { tr(c, kind) } else { title }
          },
        ))
      }
      body
    },
  )
}

/// Definition box.
#let im-term(term, body) = context {
  let c = ctx()
  block(
    width: 100%,
    inset: (x: 1em, y: 0.8em),
    fill: c.pal.wash,
    stroke: 0.5pt + c.pal.tint,
    radius: 4pt,
    {
      text(size: 0.8em, fill: c.pal.accent, weight: "bold", upper(tr(c, "term")))
      linebreak()
      text(..font-args(c.fonts, "heading"), weight: c.fonts.heading.weight, fill: c.pal.primary, size: 1.15em, term)
      v(0.3em)
      body
    },
  )
}

/// Numbered lab steps; write the steps as a `+` list.
#let im-steps(body) = context {
  let c = ctx()
  set enum(
    numbering: n => box(
      baseline: 0.25em,
      circle(radius: 0.75em, fill: c.pal.primary, align(center + horizon, text(fill: white, weight: "bold", size: 0.8em, str(n)))),
    ),
    body-indent: 0.7em,
    spacing: 1em,
  )
  body
}

/// Keyboard keys: im-kbd("Ctrl+Shift+P")
#let im-kbd(keys) = context {
  let c = ctx()
  let parts = keys.split("+").map(k => box(
    inset: (x: 0.35em, y: 0.1em),
    outset: (y: 0.15em),
    radius: 2.5pt,
    stroke: (rest: 0.6pt + c.pal.tint.darken(15%), bottom: 1.4pt + c.pal.tint.darken(15%)),
    fill: c.pal.wash,
    text(..font-args(c.fonts, "code"), size: 0.85em, fill: c.pal.ink, k.trim()),
  ))
  parts.join(text(fill: c.pal.ink.lighten(50%), size: 0.8em, h(0.15em) + "+" + h(0.15em)))
}

#let _as-image(src, width) = {
  if type(src) == content { return src }
  if type(src) == path { return image(src, width: 100%) }
  panic("ilkman: im-img needs image(\"file.png\") or path(\"file.png\"); a bare string would be resolved inside the package")
}

/// Image / figure.
///
/// ```typst
/// #im-img(image("diag.png"), width: 80%, caption: [Topoloji])
/// ```
#let im-img(src, width: 100%, caption: none) = {
  let body = box(width: width, _as-image(src, width))
  if caption != none {
    figure(body, kind: image, supplement: context tr(ctx(), "figure"), caption: caption)
  } else { align(center, body) }
}

/// Scale any drawing (mermaid, aa-draw, cetz, fletcher …) to `width`.
#let im-diagram(width: 100%, caption: none, body) = {
  let fitted = layout(size => {
    let target = if type(width) == ratio { size.width * width } else if type(width) == relative { width.length + size.width * width.ratio } else { width }
    let m = measure(body)
    if m.width == 0pt { return body }
    let f = target / m.width
    box(width: target, scale(f * 100%, reflow: true, body))
  })
  if caption != none {
    figure(fitted, kind: image, supplement: context tr(ctx(), "figure"), caption: caption)
  } else { align(center, fitted) }
}

/// Plots (e.g. lilaq) — same sizing as im-diagram.
#let im-plot = im-diagram
