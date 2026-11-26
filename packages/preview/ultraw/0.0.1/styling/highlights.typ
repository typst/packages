#import "../src/highlight.typ" as hl

// -----------------------------------------------------------------------------
// Style
// -----------------------------------------------------------------------------

/// The base highlight: its style is given by the `highlight` setting of `uraw` and `uraw-diff`.
#let base = (ldel: "*:", rdel: ":*")

/// The box highlight: a dimmed background and a plain border.
///
/// - color (color, gradient, tiling): The color of the highlight.
/// - radius (relative, dictionary): The radius of the highlight.
/// -> dictionary
#let box(color: yellow, radius: 3pt) = (
  ldel: "*|",
  rdel: "|*",
  fill: color.transparentize(70%),
  stroke: color,
  radius: radius,
)

/// The alert highlight: no border, a plain background and strong white highlighted code.
///
/// - color (color, gradient, tiling): The color of the highlight.
/// -> dictionary
#let alert(color: red) = (
  ldel: "*!",
  rdel: "!*",
  fill: color,
  stroke: none,
  radius: 0pt,
  code-style: it => strong(text(fill: white, it)),
)

/// The hole highlight: no background, hidden code and a dashed border.
///
/// - color (color, gradient, tiling): The color of the dashed border.
/// -> dictionary
#let hole(color: black) = (
  ldel: "*?",
  rdel: "?*",
  fill: none,
  stroke: (paint: color, dash: "dashed"),
  code-style: hide,
  expand: none,
)

/// A highlight that strikes through the code.
///
/// - color (color, gradient, tiling): The color of the strike line.
/// -> dictionary
#let strike(color: red) = (
  ldel: "*-",
  rdel: "-*",
  fill: none,
  stroke: none,
  code-style: std.strike.with(stroke: 1.5pt + color),
  expand: none,
)

/// A highlight that underlines the code.
///
/// - color (color, gradient, tiling): The color of the underlining line.
/// -> dictionary
#let underline(color: black) = (
  ldel: "*_",
  rdel: "_*",
  fill: none,
  stroke: none,
  code-style: std.underline.with(offset: 1.5pt, stroke: 1pt + color),
  expand: none,
)

/// A highlight that renders the code bold.
#let strong = (
  del: "***", // Third * needed for Markdown code
  fill: none,
  stroke: none,
  code-style: std.strong,
  expand: none,
)

// -----------------------------------------------------------------------------
// Management
// -----------------------------------------------------------------------------

/// The state storing highlights.
#let highlights-state = state("uraw-highlights", (base, alert()))

/// Add highlights to use them in raw text. A highlight with the same delimiters as a registered one replaces it.
///
/// #example(`
/// #import "@preview/ultraw:0.0.1": highlights
/// #highlights.add(
///   (ldel: "*~", rdel: "~*", fill: teal, code-style: it => text(white, strong(it))),
///   (del: "*-*", stroke: olive, radius: 0pt, expand: left),
///   (..highlights.box(color: red), ldel: "*r|", rdel: "|r*"),
/// )
/// `)
///
/// - highlights (arguments): Each highlight to register is given as a dictionary. If some keys are omitted, their default values are given by the `highlight` setting of `uraw` or `uraw-diff`. The keys of the dictionary are
///   - `ldel (str) + rdel (str)` or `del (str)` (shortcut when `ldel = rdel`) the delimiters of the highlight inside the raw text: writing `... ldelsome coderdel ...` will remove `ldel` and `rdel` from the code and highlight `some code`
///   - `fill (color | gradient | tiling | none)` the background color of the highlight block
///   - `stroke (length | color | gradient | stroke | tiling | none)` the border of the highlight block
///   - `radius (relative | dictionary)` the radius of the highlight block
///   - `code-style (function)` a styling function to apply to the highlighted content
///   - `sticky (bool)` whether the parts of the highlight merge from one line to the next (the stroke and radius are changed accordingly)
///   - `expand (alignment | none)` the side on which the highlight expands when going from one line to the next (`none` = no expansion, `left` = left side, `right` = right side, `center` = both sides)
///
/// -> content
#let add(..highlights) = {
  let added = highlights.pos().map(hl.pre-highlight)
  highlights-state.update(hls => {
    for h in added {
      // (a highlight with the same delimiters is replaced in place)
      let i = hls.position(g => (g.ldel, g.rdel) == (h.ldel, h.rdel))
      if i == none { hls.push(h) } else { hls.at(i) = h }
    }
    hls
  })
}

/// Remove highlights.
///
/// #example(`
/// #import "@preview/ultraw:0.0.1": highlights
/// #highlights.remove((ldel: "*!", rdel: "!*"), (del: "***"))
/// `)
///
/// - delimiters (arguments): The delimiters of each highlight are a dictionary with either two keys `ldel` and `rdel` representing the left and right delimiters or a single key `del` representing both delimiters.
/// -> content
#let remove(..delimiters) = {
  let delimiters = delimiters
    .pos()
    .map(ds => if "del" in ds { (ds.del, ds.del) } else if "ldel" in ds
      and "rdel" in ds { (ds.ldel, ds.rdel) })
    .filter(ds => ds != none)

  highlights-state.update(hls => hls.filter(h => {
    not (h.ldel, h.rdel) in delimiters
  }))
}

/// Return the parameters of a highlight. The context must be known to call this function.
///
/// #example(`
/// #import "@preview/ultraw:0.0.1": highlights
/// #context highlights.get(ldel: "*!", rdel: "!*")
/// `)
///
/// - del (str | none): `del` represents both delimiters of the highlight. It overrides `ldel` and `rdel` if given.
/// - ldel (str | none): The left delimiter of the highlight.
/// - rdel (str | none): The right delimiter of the highlight.
/// -> dictionary
#let get(del: none, ldel: none, rdel: none) = {
  assert(
    del != none or (ldel != none and rdel != none),
    message: "Either `del` or `ldel` and `rdel` must be fixed.",
  )
  if del != none { (ldel, rdel) = (del, del) }

  let h = highlights-state.get().filter(h => (h.ldel, h.rdel) == (ldel, rdel))
  assert(h.len() > 0, message: "There is no highlight with these delimiters.")
  h.first()
}

/// List highlights. The context must be known to call this function.
///
/// #example(`
/// #import "@preview/ultraw:0.0.1": highlights
/// #context highlights.list()
/// `)
///
/// -> array
#let list() = highlights-state.get()
