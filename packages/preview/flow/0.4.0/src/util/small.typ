// Various smaller utilities.
#import "../palette.typ": *
#import "@preview/oxifmt:1.0.0": strfmt as fmt

#let golden-ratio = (1 + calc.sqrt(5)) / 2

/// Vertical dots.
#let vvv = $dots.v$
/// Horizontal dots, centered.
#let ccc = $dots.c$

/// Both horizontally and vertically centered.
#let mid = center + horizon

/// Quote with the attribution as positional argument.
#let qi(attribution, body, lang: none, ..args) = context {
  let body = if lang == none { body } else { text(lang: lang, body) }
  quote(
    attribution: attribution,
    body,
    ..args,
  )
}

/// Like `qi`, but as block.
/// This makes typing a lot of quotes at once easier:
///
/// ```typ
/// #qb[https://whisperpair.eu/][
///   _[I]f a problem can be solved at the top,
///   it should be solved at the top._
/// ]
///
/// #qb(lang: "de")[Theodor W. Adorno, 1944][
///   Der neutestamentarische Satz:
///   "Wer nicht für mich ist, ist wider mich"
///   war von jeher dem Antisemitismus
///   aus dem Herzen gesprochen.
/// ]
///
/// #qb(<powderpaint-ego>)[
///   know what you know \
///   don't just think so
/// ]
///
/// #bibliography(bytes("
/// powderpaint-ego:
///   type: audio
///   title: Ego
///   author: Powderpaint
///   date: 2020-06-30
///   url: https://powderpaint.bandcamp.com/track/ego
/// "))
/// ```
#let qb = qi.with(block: true)

/// Full-width dimmed line.
/// Useful for a conceptual or logical split.
#let separator = box(height: 0.1em, align(horizon + center, line(
  length: 100%,
  stroke: gamut.sample(25%),
)))

/// Displays the given content highlighted and only when compiled in dev mode.
#let todo(it) = if cfg.dev {
  text(duality.green, emph(it))
}

/// Returns the given amount of samples on the unit range [0%, 100%].
/// The returned samples are an array of percentages,
/// beginning with 0 and ending with 1 (if there is more than one item).
/// All samples are equally spaced.
#let quantify-unit-range(samples) = {
  if samples <= 1 {
    return (0%,) * samples
  }
  range(samples).map(i => i / (samples - 1)).map(x => x * 100%)
}

/// Maps the given strings linearly across the full width of the given colors.
/// Returns a dictionary with the strings as keys and their sampled colors as values.
/// Useful for feeding into `keywords`.
#let gradient-map(items, targets) = {
  let pos = quantify-unit-range(items.len())
  if type(targets) != gradient {
    targets = gradient.linear(..targets, space: oklch)
  }
  let values = targets.samples(..pos)
  items.zip(values).to-dict()
}


/// Swaps keys and values of the given dictionary.
/// Both keys and values need to be keys.
#let swap-kv(it) = it.pairs().map(array.rev).to-dict()

/// Returns an array of all combination possibilities
/// of the given `n` equally long arrays.
///
/// Each possibility is represented by an array again
/// where the `i`-th element
/// is from the `i`-th input array.
///
/// If no arguments are provided,
/// an empty array is returned.
#let cartesian-product(..args) = {
  // could theoretically merge the n=2 and n>=3 cases
  // but the distinction of concerns looks cleaner to me
  // (n=2 is pairing up, n>=3 is recursing + flattening)
  let args = args.pos()

  if args.len() == 0 {
    // trivial, see docs
    return ()
  }
  if args.len() == 1 {
    // also trivial, each possibility is just each element
    return args.first().map(ele => (ele,))
  }
  if args.len() == 2 {
    // bit more complicated, need to pair each up
    let (a, b) = args
    return a.map(x => b.map(y => (x, y))).join()
  }

  // n >= 3
  // recurse down and flatten other
  let first = args.first()
  let rest = cartesian-product(..args.slice(1))

  cartesian-product(first, rest) // delegating to the n - 1 case
    .map(((a, b)) => (a,) + b) // flatten down
}

/// Return the `action` function if `condition`,
/// else return `default`.
/// Shorthand `if` statement for use in show rules,
/// since `default` defaults to the identity function.
#let maybe-do(condition, action, default: x => x) = if condition {
  action
} else {
  default
}

/// Zips all given dictionaries together
/// such that returned dict
/// holds all keys present in the given dicts,
/// mapping them to arrays of the given dicts' values.
///
/// This is essentially zipAttrs from nixpkgs
/// if the reader knows nix.
///
/// Panics if not all arguments are dictionaries.
#let zip-dicts(..args) = (
  args
    .pos()
    .fold((:), (acc, attrs) => (
      acc
        + attrs
          .pairs()
          .map(((key, value)) => (
            (
              key,
              acc.at(key, default: ()) + (value,),
            ),
          ).to-dict())
          .join()
    ))
)

/// Shorthand for a nice repr to content.
#let dbg(it) = raw(repr(it), block: true)

/// Languages.
#let (en, de, ua, ru, kr, jp, cn) = {
  ("en", "de", "ua", "ru", "kr", "jp", "cn").map(lang => (..args) => [
    (#lang: #text(lang: lang, ..args))
  ])
}

// is this overengineered? yeah
// does it work? also yeah
/// Table and grid cells.
/// Typing out `table.cell` and `grid.cell` is just getting too tedious.
#let (thd, tcl, gcl) = (table.header, table.cell, grid.cell)
#let (tclr, tclc, gclr, gclc) = cartesian-product(
  (tcl, gcl),
  (
    fn => (y, ..args) => fn(rowspan: y, ..args),
    fn => (x, ..args) => fn(colspan: x, ..args),
  ),
).map(((fn, variant)) => variant(fn))

/// Rotate any content by 90 degrees clockwise.
#let flop = rotate.with(90deg, reflow: true)

/// Array map, but thought for content with some extra ergonomics.
///
/// You can use this function to easily put several similar notes into one document!
/// Imagine it a bit like a macro:
///
/// - Write out one concrete example first.
/// - Move the entire note as a function into this.
/// - Find the terms you want to be parametric over.
///   Those are your inputs, extract and use them accordingly in the body.
/// - Add more variants.
#let expand(inputs, transform, reduce: array.join) = {
  let variants = inputs.map(args => {
    if type(args) in (array, dictionary) {
      transform(..args)
    } else {
      transform(args)
    }
  })

  reduce(variants)
}


/// Forget the given keys from the dictionary, then return it.
#let forget-keys(lookup, keys) = {
  lookup.pairs().filter(((key, _)) => key not in keys).to-dict()
}

