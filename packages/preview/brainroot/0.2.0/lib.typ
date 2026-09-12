// brainroot -- mind maps from nested lists.
//
// The root sits in the middle or at the head, the branches fan out, and
// every branch carries its own colour down to its leaves. The pieces:
// `src/input.typ` reads branches and lists, `src/themes.typ` and
// `src/palettes.typ` hold the presets, `src/options.typ` the layout and
// spacing fields, `src/node.typ` draws and measures one box, `src/hand.typ`
// wobbles lines, `src/layout.typ` places subtrees by contour, `src/draw.typ`
// draws the tree layouts and `src/radial.typ` the rest.

#import "@preview/cetz:0.5.2"
#import "src/util.typ": _pt
#import "src/input.typ": branch, connect, _norm, _expand
#import "src/palettes.typ": palettes, _palette
#import "src/themes.typ": themes, theme-defaults, _theme
#import "src/options.typ": layout-defaults, spacing-defaults, _layout, _spacing
#import "src/node.typ": _measure-node
#import "src/layout.typ": _measure-tree, _split, _level-sizes, _arrangement-positions, _link-cost, _permutations, _reversed
#import "src/draw.typ": _draw-node, _draw-stack, _sizes-by-id, _draw-links
#import "src/radial.typ": _draw-star, _draw-radial, _draw-fishbone

// The tree as one line of text, for the alternative text.
#let _plain(c) = {
  if type(c) == str { c } else if type(c) != content { repr(c) }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(_plain).join("") }
  else if c.has("body") { _plain(c.body) }
  else if c.func() == [ ].func() { " " } else { "" }
}

#let _outline(root, trees) = {
  let sub(t) = if t.kids.len() == 0 { _plain(t.node.label) }
    else { _plain(t.node.label) + " (" + t.kids.map(sub).join(", ") + ")" }
  _plain(root.label) + ": " + trees.map(sub).join("; ")
}

/// Adds up the `points` of every node in a map. Takes the same branches,
/// lists and `title` as `brainroot()`, so the call can be repeated with the
/// same arguments, or the arguments kept in a variable and spread.
///
/// -> int | float
#let brainroot-points(..branches, title: none) = {
  let walk(n) = {
    let n = _norm(n)
    let own = if n.points == none { 0 } else { n.points }
    own + n.kids.map(walk).sum(default: 0)
  }
  branches.pos().map(_expand).flatten().map(walk).sum(default: 0)
}

/// Draws the mind map. The first-level branches come as positional
/// arguments: `branch(...)` calls, plain content, or a Typst list whose items
/// become branches and whose nested lists become children. In a list,
/// `<name>` at the end of an item gives the node an `id`, an item that is
/// nothing but `*bold*` marks it, one that is nothing but `_emphasised_`
/// makes it a gap.
///
/// Recurring settings go into a preset: `#let map = brainroot.with(theme:
/// "hand", palette: "ocean")`.
///
/// -> content
#let brainroot(
  /// First-level branches: `branch(...)`, content, or a list. Without
  /// `title`, the first positional argument is the root.
  /// -> content | dictionary
  ..branches,
  /// The root: content, or a `branch(...)` to give it an icon, a fill or
  /// an ink of its own.
  /// -> content | dictionary | none
  title: none,
  /// Arrangement of the branches: a name (`both`, `right`, `left`, `down`,
  /// `up`, `radial`, `star`, `fishbone`) or a dictionary with `kind` and
  /// the further fields of `layout-defaults`.
  /// -> str | dictionary
  layout: "both",
  /// How boxes and edges look: the name of a theme in `themes`, or a
  /// dictionary that overrides fields of one (`base:` picks the starting
  /// theme, otherwise `soft`); see `theme-defaults` for the fields.
  /// -> str | dictionary
  theme: "soft",
  /// The colours: the name of a palette in `palettes`, an array of colours,
  /// or a dictionary (`base:` picks the starting palette) with `colors`,
  /// `root`, `ink`, `ink-dark`, `ink-light` and `ink-threshold`.
  /// -> str | array | dictionary
  palette: "poster",
  /// Distances, overriding fields of `spacing-defaults`.
  /// -> dictionary
  spacing: (:),
  /// Strength of the wobble in hand-drawn themes, a factor on their
  /// `amplitude`; `0` draws straight, `2` twice as restless.
  /// -> float | ratio
  wobble: 1,
  /// Cross-links between nodes, each a `connect(...)`.
  /// -> array
  links: (),
  /// `"keep"` draws the branches in the order given; `"links"` orders the
  /// first-level branches, and turns the children of a branch around where
  /// that helps, so that nodes joined by cross-links come close together.
  /// Tree layouts only; up to seven branches are tried exhaustively, more
  /// by swapping neighbours.
  /// -> str
  arrange: "keep",
  /// Draws whole classes of nodes as gaps: `"leaves"`, `"branches"` (the
  /// first level) or `"all"`; `none` only honours each node's own `blank`.
  /// -> none | str
  blanks: none,
  /// `true` fills the gaps in: the solution of a map with blanks.
  /// -> bool
  solution: false,
  /// Text colour for filled-in gaps, so the solution stands out; `auto`
  /// uses the normal text colour.
  /// -> auto | color
  solution-ink: auto,
  /// Shows each node's `points` as a badge on its box.
  /// -> bool
  show-points: false,
  /// Which first-level branches are drawn: `auto` all, an integer the first
  /// so many, or a function of the branch index (from 0) returning a bool.
  /// The layout stays the same, so a map can build up branch by branch --
  /// in typstage: `build(from => brainroot(..., reveal: i => from(i + 2)))`.
  /// -> auto | int | function
  reveal: auto,
  /// `auto` draws the map at its natural size; a length or a ratio of the
  /// surrounding block scales the whole map, text included, to that width.
  /// -> auto | length | ratio
  width: auto,
  /// A factor on the whole map, applied on top of `width`; `zoom: 50%`
  /// halves it.
  /// -> ratio | float
  zoom: 100%,
  /// A colour behind the whole map, framed by `spacing.padding`; `none`
  /// leaves the page as it is.
  /// -> color | none
  background: none,
  /// Alternative text for the map in tagged PDFs: `auto` writes the tree
  /// out as text, a string is used as given, `none` adds nothing.
  /// -> auto | str | none
  alt: auto,
) = context {
  let theme = _theme(theme)
  if theme.hand != none { theme.hand.amplitude *= wobble }
  let pal = _palette(palette)
  let lay = _layout(layout)
  let sp = _spacing(spacing)
  let vertical = lay.kind in ("down", "up")
  // Lengths in em follow the surrounding font size, so a map in a footnote
  // and a map on a poster keep their proportions. Resolve them once here.
  let abs(l) = if type(l) == length { l.to-absolute() } else { l }
  let opts = (
    theme: theme, root-fill: pal.root,
    tint: theme.tint, tint-min: theme.tint-min, shade: theme.shade,
    ink: pal.ink, ink-dark: pal.ink-dark, ink-light: pal.ink-light, ink-threshold: pal.ink-threshold,
    scale: theme.scale, bold-depth: theme.bold-depth, thickness: theme.thickness.map(abs),
    inset: if type(theme.inset) == dictionary { theme.inset.pairs().map(((k, v)) => (k, abs(v))).to-dict() } else { abs(theme.inset) },
    level-gap: abs(sp.level), root-gap: abs(sp.root), sibling-gap: abs(sp.sibling), branch-gap: abs(sp.branch),
    max-width: abs(sp.max-width), brace-size: abs(sp.brace), summary-gap: abs(sp.summary), cloud-pad: abs(sp.cloud),
    edge-label-fill: theme.edge-label-fill, label-offset: abs(sp.label),
    blanks: blanks, solution: solution, solution-ink: solution-ink, show-points: show-points,
    levels: none, level-sizes: none,
  )
  // `..branches` would swallow a misspelt option in silence.
  assert(branches.named().len() == 0, message: "brainroot: unknown argument "
    + branches.named().keys().map(k => "`" + k + "`").join(", ")
    + "; looks like distances are `spacing: (...)`, box and edge looks are `theme: (...)`, and the root's icon or fill is `title: branch(...)`")
  let args = branches.pos()
  let root = title
  if root == none {
    assert(args.len() > 0, message: "brainroot: root missing (title: ... or first argument)")
    root = args.first()
    args = args.slice(1)
  }
  let root-node = _norm(root)
  let rm = _measure-node(root-node, 0, black, opts)

  let measure-branches(force) = args.map(_expand).flatten().enumerate().map(((i, b)) => {
    let b = _norm(b)
    let c = if b.color != none { b.color } else { pal.colors.at(calc.rem(i, pal.colors.len())) }
    let t = _measure-tree(b, 1, c, opts, vertical, force: force)
    let hidden = if reveal == auto { false } else if type(reveal) == int { i >= reveal } else { not reveal(i) }
    t + (hidden: hidden)
  })
  let trees = measure-branches(none)
  // `equal` on the root: the first-level branches at one size.
  if root-node.equal != false and trees.len() > 1 {
    trees = measure-branches((
      w: if root-node.equal in (true, "width") { trees.map(t => t.w).fold(0pt, calc.max) } else { none },
      h: if root-node.equal in (true, "height") { trees.map(t => t.h).fold(0pt, calc.max) } else { none },
    ))
  }
  // Arranging for the cross-links: try the orders, keep the cheapest.
  // A single `connect(...)` without the trailing comma is a dictionary,
  // not an array of one: take it as such.
  let links = if type(links) == dictionary { (links,) } else { links }
  let links = links.filter(l => type(l) == dictionary and l.at("brainroot-link", default: false))
  if arrange == "links" and links.len() > 0 and lay.kind not in ("radial", "star", "fishbone") {
    let root-m = if vertical { rm.h } else { rm.w } / 2
    let sides-of(ts) = if vertical {
      ((if lay.kind == "down" { -1 } else { 1 }, ts),)
    } else {
      let s = _split(ts, opts.branch-gap, lay.kind)
      ((1, s.right), (-1, s.left))
    }
    let cost(ts) = _link-cost(links, _arrangement-positions(sides-of(ts), root-m, opts))
    // Branch order: every permutation for up to seven, neighbour swaps
    // beyond that.
    let best = trees
    let best-cost = cost(trees)
    if trees.len() <= 7 {
      for p in _permutations(range(trees.len())) {
        let ts = p.map(i => trees.at(i))
        let c = cost(ts)
        if c < best-cost { best = ts; best-cost = c }
      }
    } else {
      let improved = true
      while improved {
        improved = false
        for i in range(best.len() - 1) {
          let ts = best
          (ts.at(i), ts.at(i + 1)) = (best.at(i + 1), best.at(i))
          let c = cost(ts)
          if c < best-cost { best = ts; best-cost = c; improved = true }
        }
      }
    }
    // Then each branch's children the other way round, where that helps.
    for i in range(best.len()) {
      let ts = best
      ts.at(i) = _reversed(best.at(i))
      let c = cost(ts)
      if c < best-cost { best = ts; best-cost = c }
    }
    trees = best
  }

  // Aligned levels: one line per depth, from the largest box on each.
  if lay.align-levels and lay.kind not in ("radial", "star", "fishbone") {
    let sizes = _level-sizes((depth: 0, w: rm.w, h: rm.h, kids: trees), ())
    let size-m = sizes.map(z => if vertical { z.h } else { z.w })
    let levels = (0pt, (if vertical { rm.h } else { rm.w }) / 2 + opts.root-gap)
    for d in range(2, sizes.len()) { levels.push(levels.at(d - 1) + size-m.at(d - 1) + opts.level-gap) }
    opts.levels = levels
    opts.level-sizes = size-m
  }

  let canvas = cetz.canvas(length: 1pt, {
    import cetz.draw: *
    if lay.kind == "radial" {
      _draw-radial(trees, rm, lay.start, opts)
    } else if lay.kind == "fishbone" {
      _draw-fishbone(trees, rm, opts)
    } else if lay.kind == "star" {
      _draw-star(trees, rm, lay.start, opts)
    } else if vertical {
      let dir = if lay.kind == "down" { -1 } else { 1 }
      _draw-stack(trees, dir, rm.h / 2, dir * (rm.h / 2 + opts.root-gap), opts, true)
    } else {
      let sides = _split(trees, opts.branch-gap, lay.kind)
      for (dir, side) in ((1, sides.right), (-1, sides.left)) {
        _draw-stack(side, dir, rm.w / 2, dir * (rm.w / 2 + opts.root-gap), opts, false)
      }
    }
    // The root last, so it lies on top of the lines.
    _draw-node(rm + (node: root-node, depth: 0, color: black, width: rm.width), 0pt, 0pt, opts)
    // Cross-links over everything.
    if links.len() > 0 {
      let sizes = (root: (w: rm.w, h: rm.h))
      for t in trees { sizes = _sizes-by-id(t, sizes) }
      _draw-links(links, sizes, opts)
    }
  })

  let canvas = if background == none { canvas } else {
    block(fill: background, inset: abs(sp.padding), radius: 0.6em, canvas)
  }
  // Alternative text: the tree written out, unless given or declined.
  let canvas = if alt == none { canvas } else {
    let text = if alt == auto { _outline(root-node, trees) } else { alt }
    figure(kind: "brainroot", supplement: none, alt: text, canvas)
  }
  if width == auto and zoom == 100% { return canvas }
  // Scale the finished drawing as a whole, text included, so `width` and
  // `zoom` never change the layout, only its size on the page.
  std.layout(size => context {
    let natural = measure(canvas).width
    let target = if width == auto { natural } else if type(width) == ratio { size.width * width } else { width.to-absolute() }
    let f = target / natural * zoom
    std.scale(f, reflow: true, canvas)
  })
}
