#let _plugin = plugin("hortulus.wasm")

// TeX points per Typst point: the generator works in TeX points.
#let _tex = 72.27 / 72

#let _list(pairs) = "{" + pairs.pairs().map(((k, v)) => k + "=" + str(v)).join(", ", default: "") + "}"

// Named options as the generator's settings list.
#let _settings(opts) = {
  let out = ()
  for (key, name) in (
    ("seed", "seed"), ("layout", "layout"), ("colourway", "colourway"), ("density", "density"),
    ("visitors", "visitors"), ("spin", "spin"), ("gilt", "gilt"), ("gilt-dpi", "giltdpi"), ("gilt-env", "giltenv"),
  ) {
    if key in opts { out.push(name + "=" + str(opts.at(key))) }
  }
  for (key, name) in (("mix", "mix"), ("palette", "palette"), ("ornaments", "ornaments"), ("gilt-look", "giltlook")) {
    if key in opts { out.push(name + "=" + _list(opts.at(key))) }
  }
  out.join(", ", default: "")
}

// The page's margins in pt, whichever way they were set.
#let _margins(number) = {
  let m = page.margin
  let short = calc.min(page.width, page.height)
  let side(v) = if v == auto { short * 2.5 / 21 } else { v.length.to-absolute() + short * (v.ratio / 100%) }
  if type(m) != dictionary { m = (top: m, bottom: m, left: m, right: m) }
  let get(key, other) = side(m.at(key, default: m.at(other, default: auto)))
  let odd = calc.rem(number, 2) == 1
  let (left, right) = if "inside" in m {
    if odd { (side(m.inside), side(m.outside)) } else { (side(m.outside), side(m.inside)) }
  } else { (get("left", "rest"), get("right", "rest")) }
  (top: get("top", "rest"), bottom: get("bottom", "rest"), left: left, right: right)
}

// Records how tall an element is. Where it stands is read from the mark's
// location when painting: `here()` is not yet reliable in the first layout pass.
#let _mark(it) = context {
  let m = _margins(1)
  let inner = page.width - m.left - m.right
  // Columns are set apart by their default gutter, 4% of the text's width.
  let gutter = inner * 0.04
  let width = (inner - gutter * (page.columns - 1)) / page.columns
  [#metadata((
    w: width.pt(),
    step: (width + gutter).pt(),
    cols: page.columns,
    h: (measure(block(width: width, it)).height + 1.2em.to-absolute()).pt(),
  )) <hortulus-mark>]
}

// The ink boxes on page `number`, flowing tall elements on to later columns and pages.
#let _lines(number, m) = {
  let (top, bottom) = (m.top.pt(), page.height.pt() - m.bottom.pt())
  let out = ()
  for el in query(<hortulus-mark>) {
    let v = el.value
    let pos = el.location().position()
    let (p, y, h) = (pos.page, pos.y.pt(), v.h)
    let col = calc.round((pos.x.pt() - _margins(p).left.pt()) / v.step)
    let x0 = pos.x.pt() - col * v.step
    while p <= number and h > 0 {
      if p == number {
        let x = x0 + col * v.step
        out.push((x, y, x + v.w, calc.min(y + h, bottom)))
      }
      h -= bottom - y
      y = top
      col += 1
      if col >= v.cols {
        col = 0
        p += 1
      }
    }
  }
  out
}

// Typst caches calls to Typst functions but not to plugins: through this wrapper a
// page whose spec has not changed skips growing again, in a later layout pass or
// after an edit elsewhere in the document.
#let _paint(spec, settings) = _plugin.page(bytes(spec), bytes(settings))

#let _background(base) = context {
  // The first layout pass has measured nothing yet: painting it would be wasted.
  if query(<hortulus-ready>).len() == 0 { return }
  let number = here().page()
  // Options in force: the document's, then each flora-setup up to this page.
  let opts = base
  for el in query(<hortulus-setup>) {
    if el.location().page() <= number { opts += el.value }
  }
  for el in query(<hortulus-page>) {
    if el.location().page() == number { opts += el.value }
  }
  if opts.at("draft", default: false) or not opts.at("enabled", default: true) { return }

  let m = _margins(number)
  let (w, h) = (page.width.pt(), page.height.pt())
  let box-of(q) = (q.at(0) * _tex, (h - q.at(3)) * _tex, q.at(2) * _tex, (h - q.at(1)) * _tex)
  let header = opts.at("header", default: auto)
  if header == auto { header = page.header not in (none, auto) }
  let header-y = if header {
    str((h - m.top.pt() * (1 - float(page.header-ascent.ratio / 100%))) * _tex)
  } else { "nan" }
  let titles = query(<hortulus-title>).filter(el => el.location().page() == number)
  let title = if titles.len() > 0 {
    let v = titles.first()
    let y = v.location().position().y.pt()
    box-of((m.left.pt(), y, w - m.right.pt(), y + v.value.h)).map(str)
  } else { ("nan", "nan", "nan", "nan") }
  let lines = _lines(number, m).map(box-of)
  let text-box = box-of((m.left.pt(), m.top.pt(), w - m.right.pt(), h - m.bottom.pt()))
  let numbers = (w * _tex, h * _tex, ..text-box).map(str)
  numbers += (header-y, str(number))
  numbers += title
  for l in lines { numbers += l.map(str) }
  image(
    _paint(numbers.join(" "), _settings(opts)),
    format: "pdf",
    width: 100%,
    height: 100%,
  )
}

/// Grows flora in the margins of every page. Use as a show rule:
/// `#show: flora.with(layout: "right", colourway: "spring")`. Give the plant
/// room: about 5 cm for a side margin, or 3 cm all round for `surround`.
///
/// - seed (int): which garden; each page varies it.
/// - layout (str): `"left"`, `"right"`, `"centered"`, `"split"`, `"title"` or `"surround"`.
/// - colourway (str): `"spring"`, `"summer"`, `"autumn"`, `"winter"`, `"ember"`, `"plum"`,
///   `"rose"` or `"original"`.
/// - palette (dictionary): what paints each part, such as `(hero: "kon-peki", leaves: "green")`.
/// - density (int, float): fuller above 1, airier below it.
/// - visitors (int, float): the weight of every visitor at once.
/// - mix (dictionary): how much of each kind of growth, such as `(lily: 2, umbel: 0)`.
/// - ornaments (dictionary): how often each ornament kind is picked, such as `(moon: 3, night: 0)`.
/// - spin (int): picks other inks for parts set to `"random"`; the shapes stay.
/// - gilt (str): `"raster"` computed gold, or `"vector"` gold built of strips.
/// - gilt-dpi (int): resolution of raster gilt, 50 to 1200.
/// - gilt-env (str): the look of raster gilt, `"studio"` or `"mirror"`.
/// - gilt-look (dictionary): changes keys of that look, such as `(grain: 0)`.
/// - header (auto, bool): draws the running-head rule and its mark; `auto` follows `page.header`.
/// - draft (bool): leaves the flora out, for fast previews while writing.
/// - body (content): the document.
#let flora(..options, body) = {
  if options.pos().len() > 0 { panic("flora takes named options only") }
  let base = options.named()
  set page(background: _background(base))
  show par: it => { _mark(it); it }
  show heading: it => { _mark(it); it }
  // A floating figure stands away from where it was written, so the mark goes inside the float.
  show figure: it => {
    if it.placement == none { _mark(it); it } else {
      show place: p => if p.has("label") { p } else {
        [#place(
          p.alignment, scope: p.scope, float: p.float, clearance: p.clearance, dx: p.dx, dy: p.dy,
          { _mark(p.body); p.body },
        ) <hortulus-float>]
      }
      it
    }
  }
  show bibliography: it => { _mark(it); it }
  show list: it => { _mark(it); it }
  show enum: it => { _mark(it); it }
  show terms: it => { _mark(it); it }
  show table: it => { _mark(it); it }
  show raw.where(block: true): it => { _mark(it); it }
  show math.equation.where(block: true): it => { _mark(it); it }
  [#metadata(none) <hortulus-ready>]
  body
}

/// Changes options from this page on, as `flora` takes them.
#let flora-setup(..options) = [#metadata(options.named()) <hortulus-setup>]

/// Changes options for this page only, as `flora` takes them.
#let flora-page(..options) = [#metadata(options.named()) <hortulus-page>]

/// Marks a title block: with `layout: "title"` the crown arches over it.
/// Without it, the crown takes the first block of lines on the page.
#let flora-title(body) = {
  context {
    let m = _margins(1)
    let width = page.width - m.left - m.right
    [#metadata((h: measure(block(width: width, body)).height.pt())) <hortulus-title>]
  }
  body
}
