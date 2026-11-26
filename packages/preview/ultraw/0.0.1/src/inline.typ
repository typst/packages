#import "content.typ" as ct
#import "highlight.typ" as hl
#import "../styling/highlights.typ" as hs
#import "config.typ" as cf
#import "utils.typ" as ut

#let inline-bounds(h, length) = {
  let (start, end) = if "range" in h {
    assert(
      type(h.range) == array and h.range.len() == 2,
      message: "The `range` of a highlight of inline code must be a pair `(start, end)`.",
    )
    h.range
  } else { (h.at("start", default: 0), h.at("end", default: length)) }
  assert(
    type(start) == int and type(end) == int,
    message: "The start and the end of a highlight of inline code must be integers (character positions).",
  )
  (start, end)
}

/// The highlights of some inline code, as dictionaries with a `start`, an `end` (character positions, the end being excluded), a `fill`, a `radius` and a `code-style`.
///
/// - manual (array): The manual highlights.
/// - delimited (array): The highlights read from delimiters.
/// - defaults (dictionary): The `highlight` settings, giving the missing style fields of the manual highlights.
/// - lines (array): The lines of the code.
/// -> array
#let inline-highlights(manual, delimited, defaults, lines) = {
  let length = ct.text-len(lines.join("\n", default: ""))
  // The position of the start of each line in the code
  let line-starts = lines.fold(
    (0,),
    (acc, l) => acc + (acc.last() + ct.text-len(l) + 1,),
  )
  let simplify(h, start, end) = (
    start: calc.max(0, start),
    end: calc.min(length, end),
    fill: h.at("fill", default: none),
    radius: h.at("radius", default: 0pt),
    stroke: h.at("stroke", default: none),
    code-style: h.at("code-style", default: it => it),
  )

  // (the delimited highlights are positioned by line and column)
  let delimited = delimited.map(h => simplify(
    h,
    line-starts.at(h.start.first()) + h.start.last(),
    line-starts.at(h.end.first()) + h.end.last(),
  ))
  let manual = ut
    .single-to-list(manual)
    .map(h => {
      let h = ut.known-keys(
        h,
        defaults.keys() + ("start", "end", "range", "line", "ldel", "rdel"),
      )
      simplify(defaults + h, ..inline-bounds(h, length))
    })

  (delimited + manual).filter(h => h.start < h.end)
}

/// Highlight a line of inline code: it is split in parts at the bounds of the highlights and after the spaces and dashes (where the line can break), each part being styled and boxed by the highlights covering it (the later highlights being on top). The sides of a box are only closed at the ends of its highlight, so that the highlights are open at the line breaks.
///
/// - body (content): The content of the line.
/// - text (str): The text of the line.
/// - highlights (array): The simplified highlights.
/// - with-dst (function): Give a thickness to the strokes given without one.
/// -> content
#let highlight-inline(body, text, highlights, with-dst) = {
  if highlights.len() == 0 { return body }

  let clusters = text.clusters()
  let bounds = (0, clusters.len())
  for h in highlights { bounds += (h.start, h.end) }
  for (i, c) in clusters.enumerate() {
    if c in (" ", "-") { bounds.push(i + 1) }
  }
  bounds = bounds.dedup().sorted()

  let rest = body
  let result = []
  for k in range(bounds.len() - 1) {
    let (a, b) = (bounds.at(k), bounds.at(k + 1))
    let (part, after) = ct.content-split-pos(rest, b - a)
    rest = after

    let covering = highlights.filter(h => h.start <= a and b <= h.end)
    // The styles are applied together on each text, the later ones wrapping the earlier ones (a style applied on already styled content would rebuild its elements without their fields)
    // (the styling functions can return strings, which are converted to content)
    part = [#ct.content-map-text(part, t => covering.fold(t, (acc, h) => (
      h.code-style
    )(acc)))]
    // The later highlights wrap the earlier ones, so that they are drawn on top of them
    for h in covering.filter(h => h.fill != none or h.stroke != none) {
      // The corners are only rounded and the sides only stroked at the ends of the highlight
      let radius = ut.full-radius(h.radius)
      let s = with-dst(h.stroke)
      let stroke = if s == none { none } else {
        (top: s, bottom: s, left: s, right: s)
      }
      if a != h.start {
        radius.top-left = 0pt
        radius.bottom-left = 0pt
        if stroke != none { stroke.left = none }
      }
      if b != h.end {
        radius.top-right = 0pt
        radius.bottom-right = 0pt
        if stroke != none { stroke.right = none }
      }
      // (the box goes from the baseline to the top of the capital letters, extended as the highlights of raw blocks)
      part = box(
        fill: h.fill,
        radius: radius,
        stroke: stroke,
        outset: (top: .24em, bottom: .25em),
        part,
      )
    }
    result += part
  }
  result
}

/// Display inline code with the same settings as `uraw`.
///
/// #example(```
/// #uraw-inline(lang: "py", `print("*|Hello|* world!")`)
/// ```)
///
/// - lang (none, str): The language of the code.
///
/// - highlights (array, dictionary): For each highlight, the range it covers is given either by `start (int)` and `end (int)` or `range ((int, int))`. Default values of `start` and `end` are the first and the last characters. Each highlight can have specific styling parameters (`fill`, `stroke`, `radius`, `code-style`, see `set-uraw` for more details).
///
/// - body (str, raw, content): The code to be displayed.
///
/// -> content
#let uraw-inline(lang: none, highlights: (), body) = {
  // The code displayed by this function is not displayed again (when it is used in a show rule)
  if (
    type(body) == content
      and body.at("label", default: none) == <uraw-inline-code>
  ) {
    return body
  }
  assert(
    type(body) == str or (type(body) == content and body.func() == raw),
    message: "`uraw-inline` takes a string or an inline raw element.",
  )
  let (text, lang) = if type(body) == str { (body, lang) } else {
    (body.text, body.at("lang", default: lang))
  }
  // In a show rule, the raw element is already displayed (so its size is applied twice)
  let shown = type(body) == content and body.location() != none

  context {
    let highlight = cf.uncontext-category-getter("highlight", lang)
    let pre-highlights = hs.list()
    let phls = pre-highlights.map(h => hl.format-pre-highlight(h, highlight))
    let (dels, lines) = hl.parse-delimiters(text.split("\n"), phls)
    let delimited = dels.map(del => hl.make-highlight(phls.at(del.idx), del))
    let code = lines.join("\n", default: "")

    // The code is shown as a raw element, to get its highlighted lines
    show <uraw-inline-code>: it => context {
      let thickness = cf
        .uncontext-category-getter("general", lang)
        .default-stroke-thickness
      let with-dst(s) = ut.with-default-thickness(s, thickness)
      let hls = inline-highlights(
        highlights,
        delimited,
        highlight,
        lines,
      )
      // The lines of the code (with their position in the code)
      let start = 0
      let parts = ()
      for l in it.lines {
        let n = ct.text-len(l.text)
        let line-hls = hls
          .filter(h => h.start < start + n and h.end > start)
          .map(h => (
            h
              + (
                start: calc.max(0, h.start - start),
                end: calc.min(n, h.end - start),
              )
          ))
        parts.push(highlight-inline(
          l.body,
          l.text,
          line-hls,
          with-dst,
        ))
        start += n + 1
      }
      parts.join(linebreak())
    }
    set std.text(if shown { 1.25em } else { 1em })
    [#raw(code, lang: lang, block: false)<uraw-inline-code>]
  }
}
