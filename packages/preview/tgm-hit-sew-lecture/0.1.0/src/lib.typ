#import "libs.typ": ccicons, showybox.showybox, zebraw.zebraw, zebraw.zebraw-init, meander, pinit

#let _zebraw = zebraw

/// A wrapper around `zebraw.zebraw()` that applies a few extra settings that would otherwise reset
/// when calling `zebraw()` again (e.g. for setting the range of displayed lines)
///
/// #example(
///   mode: "markup",
///   scale-preview: 100%,
///   ````typ
///   >>> #import tgm-hit-sew-lecture: *
///   >>> #show: fake-template()
///   ```typ
///   as
///   df
///   ```
///   Only line 2, same styles:
///   #{
///     show: zebraw.with(line-range: lines("2"))
///     ```typ
///     as
///     df
///     ```
///   }
///   ````
/// )
///
/// -> content
#let zebraw(
  /// any custom zebraw arguments
  /// -> arguments
  ..args,
  /// the content that should be styled
  /// -> content
  body,
) = {
  show: _zebraw.with(
    // smart-skip: true,
    // skip-text: [#"    ..."],
    ..args
  )
  show raw.where(block: true): block.with(
    stroke: luma(245) + 2pt,
    radius: 4pt,
  )
  show raw.where(block: true): it => {
    show regex("PIN\d+"): it => pinit.pin(eval(it.text.slice(3)))
    it
  }
  body
}

/// Manually resets the raw code display settings configured by @@zebraw().
///
/// #example(
///   mode: "markup",
///   scale-preview: 100%,
///   ````typ
///   >>> #import tgm-hit-sew-lecture: *
///   >>> #show: fake-template()
///   ```typ
///   as
///   df
///   ```
///   Don't use styled code blocks:
///   #no-zebraw[
///     ```typ
///     as
///     df
///     ```
///   ]
///   >>> #v(2pt)
///   ````
/// )
///
/// -> content
#let no-zebraw(
  /// the content that should be styled
  /// -> content
  body,
) = _zebraw(
  background-color: luma(255).transparentize(100%),
  inset: (top: 0.34em, bottom: 0.34em),
  numbering: false,
  body,
)

/// Helper function for specifying zebraw line numbers.
/// It converts a string of the form `"2-4"` into the array `(2, 5)`:
/// lower bound inclusive, upper bound exclusive line range.
///
/// Note the line numbers in this example:
///
/// #example(
///   mode: "markup",
///   scale-preview: 100%,
///   ````typ
///   >>> #import tgm-hit-sew-lecture: *
///   >>> #show: fake-template()
///   >>>
///   >>> #let code = ```typ
///   >>>   a
///   >>>   b
///   >>>   c
///   >>>   d
///   >>>   e
///   >>>   f
///   >>>   g
///   >>> ```
///   >>>
///   #zebraw(line-range: lines("2-4"))[
///   >>>   #code
///   <<<  ```typ
///   <<<  ...
///   <<<  ```
///   ]
///   >>> #v(2pt)
///   ````
/// )
///
/// -> array
#let lines(spec) = {
  let result = spec.split(",").map(part => {
    let bounds = part.split("-").map(str.trim)
    if bounds.len() == 1 and bounds.first() != "" {
      // a single page
      let page = int(bounds.first())
      (page, page + 1)
    } else if bounds.len() == 2 {
      // a page range
      let (lower, upper) = bounds
      lower = if lower != "" { int(lower) }
      upper = if upper != "" { int(upper) }
      (lower, upper + 1)
    } else {
      panic("invalid page range: " + spec)
    }
  })
  if result.len() == 1 { result.first() }
  else { result }
}

/// A dictionary of links to various Creative Commons licenses.
/// Each link is displayed using `ccicons`.
///
/// #example(
///   mode: "markup",
///   scale-preview: 100%,
///   ````typ
///   >>> #import tgm-hit-sew-lecture: *
///   >>> #show: zebraw
///   >>> #show: zebraw-init.with(
///   >>>   extend: false,  // hide empty headers and footers
///   >>>   lang: false,  // hide language tag, I don't like the style
///   >>>   background-color: (luma(255), luma(245)),
///   >>>   inset: (top: 0.48em, bottom: 0.48em),
///   >>>   // highlight-color: blue.lighten(90%),
///   >>>   // comment-color: blue.lighten(93%),
///   >>> )
///   >>>
///   #licenses.cc-by-4-0 ---
///   #licenses.cc-by-nc-sa-4-0 ---
///   #licenses.cc-zero-1-0
///   ````
/// )
///
/// -> dictionary
#let licenses = {
  let cc-link(category, name, version, body) = link(
    "https://creativecommons.org/" + category + "/" + name + "/" + version + "/",
    text(black, body),
  )
  let publicdomain = ("zero",)
  (:
    ..for l in ("by", "by-nc", "by-nc-nd", "by-nc-sa", "by-nd", "by-sa") {
      let icon = dictionary(ccicons).at("cc-" + l)
      ("cc-" + l + "-4-0": cc-link("licenses", l, "4.0", icon))
    },
    ..for l in ("zero",) {
      let icon = dictionary(ccicons).at("cc-" + l)
      ("cc-" + l + "-1-0": cc-link("publicdomain", l, "1.0", icon))
    },
  )
}

/// The main template function. Your document will generally start with
/// ```typ
/// #set document(..)  // title etc.
/// #show: template(..)
/// ```
/// which it already does after initializing the template.
///
/// -> function
#let template(
  /// The license to show in the footer (by default)
  /// -> content
  license: none,
  /// The content for the left header column; empty by default
  /// -> content | auto
  header-left: auto,
  /// The content for the center header column; contains the title by default
  /// -> content | auto
  header-center: auto,
  /// The content for the right header column; contains a date-based version number by default
  /// -> content | auto
  header-right: auto,
  /// The content for the left footer column; contains copyright information by default
  /// -> content | auto
  footer-left: auto,
  /// The content for the center footer column; contains the page number and count by default
  /// -> content | auto
  footer-center: auto,
  /// The content for the right footer column; empty by default
  /// -> content | auto
  footer-right: auto,
  /// The main font to use; note that even though this can be configured, some measurements,
  /// particularly those used by @@pinit-code-from(), may be wrong if you change it.
  /// -> string
  font: "Noto Sans",
) = doc => {
  show: zebraw
  show: zebraw-init.with(
    extend: false,  // hide empty headers and footers
    lang: false,  // hide language tag, I don't like the style
    background-color: (luma(255), luma(245)),
    inset: (top: 0.48em, bottom: 0.48em),
    // highlight-color: blue.lighten(90%),
    // comment-color: blue.lighten(93%),
  )

  show raw.where(block: true): set text(0.9em)

  set text(font: font)
  set par(justify: true)
  show link: it => {
    if type(it.dest) == str {
      set text(blue.darken(20%))
      show: underline
      it
    } else {
      show: underline.with(stroke: text.fill.transparentize(50%))
      it
    }
  }
  // show link: underline

  let resolve-auto(value, default) = {
    if value != auto { value }
    else if type(default) == function { default() }
    else { default }
  }
  set page(
    header: {
      set text(0.9em)
      grid(
        columns: 3*(1fr,),
        align: (left, center, right),
        resolve-auto(header-left, none),
        resolve-auto(header-center, context document.title),
        resolve-auto(header-right, context [v#document.date.display().slice(2)]),
      )
    },
    footer: {
      set text(0.9em)
      grid(
        columns: 3*(1fr,),
        align: (left, center, right),
        resolve-auto(footer-left)[
          #sym.copyright
          #context document.author.join[, ],
          #context document.date.year()
          #license
        ],
        resolve-auto(footer-center, context counter(page).display("1 / 1", both: true)),
        resolve-auto(footer-right, none),
      )
    },
  )

  set bibliography(style: "chicago-notes")
  show bibliography: none

  show quote.where(block: true): set block(spacing: 1.2em)

  show list: pad.with(left: 0.5em)

  show figure.caption: set text(0.9em)

  doc
}

/// A colored box powered by `showybox`.
///
/// #example(
///   mode: "markup",
///   scale-preview: 100%,
///   ````typ
///   >>> #import tgm-hit-sew-lecture: *
///   >>> #show: fake-template()
///   #grid(columns: 2,
///     colorbox[foo],
///     colorbox(color: red)[bar],
///   )
///   >>> #v(2pt)
///   ````
/// )
///
/// -> dictionary
#let colorbox(
  /// the content that should be displayed
  /// -> content
  body,
  /// the color to base border and background on
  /// -> color
  color: green,
  /// any custom showybox arguments
  /// -> arguments
  ..args,
) = {
  set align(center)
  showybox(
    frame: (
      border-color: color,
      title-color: color.lighten(30%),
      body-color: color.lighten(95%),
      footer-color: color.lighten(80%)
    ),
    width: 95%,
    ..args,
    body,
  )
}

/// A wrapper around `pinit.pinit-point-from()`.
/// It handles placing the note differently, based on a raster aligned to the raw code block.
/// Pins inside the raw block are automatically set when a string of the form `PINn` (where `n` is a
/// number) appears in the code, and `pinit-code-from()` can then refer to it.
///
/// // proper #example() doesn't work due to nonconvergence :(
/// // tidy measures and lays out the preview,
/// // and pinit depends on the allocated space
/// #simple-example(
///   ````typ
///   >>> #import tgm-hit-sew-lecture: *
///   >>> #show: fake-template()
///   >>>
///   ```typ
///   as     v- the note starts 6 monospace
///   dfPIN1              chars over by default
///     ^^^^^--- the arrow takes up 5 chars
///            by default
///   ```
///   #pinit-code-from(1)[here]
///   >>>
///   >>> (The monospace grid alignment is more exact when using the template's fonts instead of the
///   >>> manuals'.)
///   ````,
/// )
///
/// #simple-example(
///   ````typ
///   >>> #import tgm-hit-sew-lecture: *
///   >>> #show: fake-template()
///   >>>
///   ```typ
///   as
///   dfPIN2
///   gh
///   ```
///   #pinit-code-from(2,
///     pin: (0, 0, top+right),
///     offset: (5, -1, left),
///     width: 70%,
///   )[The anchor can be offset from the char
///     it's at. Automatic line breaking is
///     possible with `width`.]
///   >>> #v(2pt)
///   ````,
/// )
///
/// -> content
#let pinit-code-from(
  color: blue,
  pin: (0, 0, right),
  offset: (6, 0, left),
  body: (0.3, 0),
  looseness: 4pt,
  width: auto,
  ..args,
  bod,
) = {
  // Computes a linear combination of the form `a*A+b*B+c*C`.
  // All a, b, c must be numbers or arrays and all A, B, C arrays where the arrays all have the same length.
  // When the first ("lowercase") parameter in a pair is an array, it is pairwise multiplied with the second array.
  // The return value is an array of the same length.
  // For example, to compute `A-B`, use `lin(1, A, -1, B)`
  let lin(..args) = {
    assert.eq(args.named(), (:), message: "no named arguments allowed")
    assert(
      args.pos().len() > 0 and calc.even(args.pos().len()),
      message: "number of arguments must be even and nonzero",
    )
    let pairs = args.pos().chunks(2)
    assert(
      pairs.all(((a, b)) => type(a) in (int, float, array) and type(b) == array),
      message: "all pairs must contain a number or array, and an array",
    )
    let len = pairs.first().last().len()
    assert(
      pairs.all(((a, b)) => (type(a) != array or a.len() == len) and b.len() == len),
      message: "all arrays must match in length",
    )

    range(len).map(i => pairs.map(((a, b)) => if type(a) == array { a.at(i) } else { a } * b.at(i)).sum())
  }

  let dx-dy(name, values) = {
    let (dx, dy) = values
    (name + "-dx": dx, name + "-dy": dy)
  }

  let align-offset(def) = {
    let value = def.at(2, default: center)
    let values = (-looseness, 0pt, 0pt, looseness)
    (
      values.at((left, none, center, right).position(x => x == value.x)),
      values.at((top, none, horizon, bottom).position(x => x == value.y)),
    )
  }

  let dims = (
    // how much to move from pinit's pin coordinate to arrive at the center of the anchoring monospace letter
    // how much to shift to get from one monospace character to the next
    grid-cell: (4.77pt, 13.62pt),
    // how big a character actually is;
    // pinit's pin coordinate needs to be offset by -character/2 to find the center of the character,
    // and arrows are drawn around bounds defined by these dimensions
    character: (4.77pt, 5.8pt),
  )

  pinit.pinit-point-from(
    ..dx-dy("pin", lin(
      -1/2, dims.character,
      pin.slice(0, 2), dims.grid-cell,
      1, align-offset(pin),
    )),
    ..dx-dy("offset", lin(
      -1/2, dims.character,
      offset.slice(0, 2), dims.grid-cell,
      1, align-offset(offset),
    )),
    ..dx-dy("body", lin(
      -1/2, dims.character,
      body, dims.grid-cell,
      -1, align-offset(offset),
    )),
    fill: color,
    thickness: 0.8pt,
    ..args,
    block(width: width, {
      set text(0.85em, color)
      set par(leading: 0.75em, justify: false)
      bod
    })
  )
}
