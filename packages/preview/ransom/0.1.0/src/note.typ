// The public `ransom` function: text in, cut-out letters out.

#import "rng.typ"
#import "tile.typ": cutout, roll-look, document-text
#import "presets.typ": palettes, faces as face-sets

// ==========================================================================
// Helpers

/// Flattens content to a plain string. Anything without a textual form
/// (images, equations …) becomes an empty string.
#let _to-str(it) = {
  if type(it) == str { it }
  else if type(it) != content { if it == none { "" } else { str(it) } }
  else if it == [ ] { " " }
  else if it.func() == parbreak { "\n\n" }
  else if it.func() == linebreak { "\n" }
  else if it.func() == smartquote { if it.double { "\"" } else { "'" } }
  else if it.has("text") { _to-str(it.text) }
  else if it.has("children") { it.children.map(_to-str).fold("", (a, b) => a + b) }
  else if it.has("body") { _to-str(it.body) }
  else if it.has("child") { _to-str(it.child) }
  else { "" }
}

/// Whether content contains a strong or emphasized chunk.
#let _has-markup-chunk(it) = {
  if type(it) != content { false }
  else if it.func() == strong or it.func() == emph { true }
  else if it.has("children") { it.children.any(_has-markup-chunk) }
  else if it.has("body") { _has-markup-chunk(it.body) }
  else if it.has("child") { _has-markup-chunk(it.child) }
  else { false }
}

/// Applies the `case` option to one piece of text. `shout` is the random coin
/// flip that decides between upper and lower case in `"mixed"` mode.
#let _apply-case(s, mode, shout) = {
  if mode == "upper" { upper(s) }
  else if mode == "lower" { lower(s) }
  else if mode == "mixed" { if shout { upper(s) } else { lower(s) } }
  else { s }
}

/// Looks `choice` up in `presets` when it is a name, and passes anything else
/// through, so users can supply their own arrays.
#let _resolve(choice, presets, what) = {
  if type(choice) != str { return choice }
  assert(
    choice in presets,
    message: "unknown " + what + " `" + choice + "`; choose one of: "
      + presets.keys().join(", ") + " – or pass your own array",
  )
  presets.at(choice)
}

// ==========================================================================
// ransom

#let _max-word = 10

/// Sets text as a ransom note: every letter is "cut out" of a different piece
/// of paper, in a different typeface, at a slightly different angle.
///
/// The look is fully determined by `seed`, so the result is identical on every
/// compile. Change the seed to reshuffle all letters; edit the text and only
/// the words you touched change.
///
/// - body (str, content): the text to set. Formatting is dropped except
///   strong and emphasized chunks, which are cut as one piece.
/// - seed (int, str): picks one of the endless possible arrangements.
/// - size (length): the base size of the letters. Relative lengths such as
///   `1.5em` follow the surrounding text size.
/// - palette (str, array): a name from `palettes`, or an array of `scrap`s.
/// - faces (str, array): a name from `faces`, or an array of `face`s.
/// - case (str): `"mixed"`, `"upper"`, `"lower"` or `"keep"`.
/// - tilt (angle): the largest rotation of a single letter.
/// - sway (ratio): the largest vertical wobble, as a share of `size`.
/// - scale (array): smallest and largest letter size, as ratios of `size`.
/// - cut-words (ratio): the share of words cut out whole, from a single
///   headline, instead of letter by letter.
/// - backing (ratio): the share of letters that keep a white paper margin.
/// - ragged (ratio): how uneven the scissor cuts are.
/// - shadow (bool): whether the paper scraps cast a faint shadow.
/// - tracking (ratio): the gap between letters, as a share of `size`.
/// - word-gap (ratio): the gap between words, as a share of `size`.
/// -> content
#let ransom(
  body,
  seed: 1,
  size: 1.0em,
  palette: "classic",
  faces: "embedded",
  case: "mixed",
  tilt: 8deg,
  sway: 12%,
  scale: (90%, 120%),
  cut-words: 10%,
  backing: 25%,
  ragged: 7%,
  shadow: true,
  tracking: 4%,
  word-gap: 80%,
) = context {
  let base = size.to-absolute()
  let cfg = (
    palette: _resolve(palette, palettes, "palette"),
    faces: _resolve(faces, face-sets, "face set"),
    tilt: tilt,
    sway: float(sway),
    scale: scale.map(float),
    backing: float(backing),
  )
  let look = (size: base, ragged: float(ragged), shadow: shadow)
  let letter-gap = h(base * float(tracking))
  let word-space = h(base * float(word-gap), weak: true)

  // One printed piece: a single letter, or a whole word cut as one headline.
  let tile(piece, state) = {
    let roll = roll-look(state, cfg)
    cutout(_apply-case(piece, case, roll.shout), roll, ..look)
  }

  // A word is kept in unbreakable boxes, or Typst would happily wrap between
  // two of its letters. Only an extremely long word, such as a URL, is split
  // into several boxes so that it can wrap instead of running off the page.
  let word-box(word, state) = {
    let clusters = word.clusters()
    let short = clusters.len() > 1 and clusters.len() <= _max-word
    let whole = short and rng.draws(state, 1).first() < float(cut-words)
    let pieces = if whole { (word,) } else { clusters }
    pieces
      .enumerate()
      .chunks(_max-word)
      .map(chunk => box(chunk
        .map(((i, piece)) => tile(piece, rng.fork(state, i)))
        .join(letter-gap)))
      .join()
  }

  let line-of(s, state) = s
    .split(" ")
    .filter(w => w != "")
    .enumerate()
    .map(((i, w)) => word-box(w, rng.fork(state, i)))
    .join(word-space)

  let render-plain(s, root) = _to-str(s)
    .split("\n\n")
    .enumerate()
    .map(((p, paragraph)) => paragraph
      .split("\n")
      .enumerate()
      .map(((l, line)) => line-of(line, rng.fork(rng.fork(root, p), l)))
      .join(linebreak()))
    .join(parbreak())

  let whole-piece(s, state) = {
    let roll = roll-look(state, cfg)
    cutout(_apply-case(s, case, roll.shout), roll, ..look)
  }

  if _has-markup-chunk(body) {
    show strong: it => context {
      whole-piece(_to-str(it.body), rng.seed((seed, "strong", it.body)))
    }
    show emph: it => context {
      whole-piece(_to-str(it.body), rng.seed((seed, "emph", it.body)))
    }
    show document-text: it => context {
      render-plain(it.text, rng.seed((seed, it.text)))
    }
    show smartquote: it => context {
      render-plain(
        if it.double { "\"" } else { "'" },
        rng.seed((seed, "quote", it.double)),
      )
    }
    body
  } else {
    // Each paragraph, line, and word has a state derived from its position,
    // so edits don't reshuffle the rest of the text.
    render-plain(_to-str(body), rng.seed(seed))
  }
}
