#import "../gen/gen.typ": default-tuning
#import "smart-chord.typ": smart-chord, red-missing-fifth, shift-chord-tonality
#import "draw-chord.typ": get-chordgram-width-scale

/// 1. A simple function to place chord over text. Attaches <chord> tag to the text to apply tonality and make a chordlib. May be replaced with any custom.
/// 
/// Just add chord labels above lyrics in arbitrary place, don't think about what letter exactly it should be located. By default `overchord` aligns the chord label to the left, so it produces pretty results out-of-box. You can pass other alignments to `align` argument, or use the chords straight inside words.
/// 
/// Feel free to use it for your purposes outside of the package. \
/// It takes on default `-0.25em` width to remove one adjacent space, so
/// - To make it work on monospace/other special fonts, you will need to adjust `width` argument. The problem is that I can't `measure` space, but maybe that will be eventually fixed.
/// - To add chord inside word, you have to add _one_ space, like `wo #chord[Am]rd`.
/// -> chord
#let overchord(
  /// chord name to attach. Should be plain string for tagging to work -> str
  text,
  /// styling function that is applied to the string -> (text <chord>) => content
  styling: strong,
  /// alignment of the word above the point -> alignment
  align: start,
  /// height of the chords -> length
  height: 1em,
  /// width of space in current font,
  /// may be set to zero if you don't put
  /// any spaces between chords and words -> length
  width: -0.25em) = box(place(align, box(styling([#text <chord>]), width: float("inf")*1pt)), height: 1em + height, width: width)

/// 1a. A replacement for overchord, displays chords inline in (double) square brackets
/// -> content
#let inlinechord(
  text,
  styling: strong
) = styling[\[\[#text<chord>\]\]]

/// 7. get current tonality in document
/// -> int
#let get-tonality(
  ///  Element that has location or `location` -> content | location
  loc
  ) = {
  if type(loc) != location {
    loc = loc.location()
  }
  query(selector(<tonality>).before(loc)).at(-1, default: (value: 0)).value
}

/// 6. Smart chord that changes tonality automatically
/// -> chord
#let auto-tonality-chord(
  /// chord name -> str
  name,
  /// smart chord method to use -> function(name, ..args) → chord
  smart-chord: smart-chord,
  /// arguments for smart-chord -> any
  ..args) = {
  context smart-chord(shift-chord-tonality(name, get-tonality(here())), ..args)
}

/// 1b. An overchord alternative, displays a chord above line that is changed with tonality 
/// -> content
#let fulloverchord(
  /// chord name -> string
  name,
  /// styling function that is applied to the string -> (text <chord>) => content
  styling: strong,
  /// alignment of the word above the point -> alignment
  align: start,
  /// height of the chords -> length
  height: 40pt,
  /// width of space in current font,
  /// may be set to zero if you don't put
  /// any spaces between chords and words -> length
  width: -0.25em,
  smart-chord: smart-chord,
  scale-length: 0.5pt,
  ..args) = box(place(align, auto-tonality-chord(name, smart-chord: smart-chord, scale-l: scale-length, ..args)) + place(hide[#name <chord>]), height: 1em + height, width: width)

/// 5. Changes current tonality shift to given number
/// This is just metadata, so you need to put into document to have any effect
/// -> content
#let change-tonality(
  /// number of halftones to move tonality -> int
  tonality-shift) = {
  [#metadata(tonality-shift) <tonality>]
}

/// 2. Use `#show: chordify` in your document to allow auto square chords formatting and automatic tonality change
/// inspired by soxfox42's chordish
///  
/// -> content
#let chordify(
  /// the document to apply show rule -> content
  doc,
  /// enable square brackets for chords writing -> boolean
  squarechords: true,
  /// function applying to the chord names when square brackets are used -> function(name) → content
  line-chord: overchord,
  // heading level to reset tonality at -> int | none
  heading-reset-tonality: none) = {
  show <chord>: c => if get-tonality(c) == 0 {c} else {shift-chord-tonality(c.text, get-tonality(c))}

  let doc = if heading-reset-tonality != none {
    show heading.where(level: heading-reset-tonality): it => it + change-tonality(0)
    doc
  } else {doc}

  if squarechords {
    show "[[": "[" 
    show "]]": "]"

    let chord-regex = regex("\\[([^\[\]]+?)\\]")
    show chord-regex: it => line-chord(it.text.match(chord-regex).captures.at(0))

    doc
  } else {
    doc
  }
}

/// Utility function
/// Selects all things inside current "chapter"
/// -> selector
#let inside-level-selector(select, heading-level) = {
  if heading-level == none {
    select
  } else {
    let last-heading = query(selector(heading.where(level: heading-level)).before(here()))
    let next-headers = query(selector(heading.where(level: heading-level)).after(here()))
    let base-selector = if last-heading.len() == 0 {
      select
    }
    else {
      select.after(last-heading.at(-1).location())
    }
    if next-headers.len() == 0 {
      base-selector
    } else {
      base-selector.before(next-headers.at(0).location())
    }
  }
}

/// 3. Render all chords of current song.
/// - Set `header-level` to set headings that separate the different songs.
///   If none, all chords in document will be rendered.
/// 
/// _This must be inside `context` to work_
/// -> sequence[content]  
#let chordlib(
  /// smart chord function to use
  smart-chord: smart-chord,
  /// chordgen for smart-chord
  chordgen: red-missing-fifth,
  /// tuning to use in "A1 B2 C3 D4" format -> str
  tuning: default-tuning,
  /// whether to require the lowest note to be the root note 
  true-bass: true,
  /// chords not to draw, can be added manually 
  /// in format ("Am", ...) -> array[str]
  exclude: (),
  /// versions of chords to use (default zero is the "best")
  /// in format (Am: 2, ...) -> dictionary[int] 
  switch: (:),
  /// at witch fret to find the best chord
  /// in format (Am: 5, ...) -> dictionary[int|none]
  at: (:),
  /// scale length, see `draw-chord` -> length
  scale-l: 1pt,
  /// heading level to search chords within -> int
  heading-level: none) = {
  // select fitting chord
  let chords-selector = inside-level-selector(selector(<chord>), heading-level)
  let rendered = ()
  for (i, c) in query(chords-selector)
      .map(c => shift-chord-tonality(c.text.trim(), get-tonality(c)))
      .dedup()
      .enumerate() {
    if c in exclude {
      continue
    }
    let n = switch.at(c, default: 0)
    let at = at.at(c, default: none)
    box(align(center+horizon, smart-chord(c, chordgen: chordgen, tuning: tuning, true-bass: true-bass, n: n, at: at, scale-l: scale-l)), width: get-chordgram-width-scale(tuning.split().len()) * scale-l, height: 80* scale-l)
  }
}

/// 4. Draw a nice box with chords inside
/// -> content
#let sized-chordlib(
  /// number of chords inside one line -> int
  N: 2,
  /// width of the box -> length
  width: 130pt,
  /// content to add to chordbox start -> content
  prefix: none,
  /// content to add to chords end (e.g., some excluded chords) -> content
  postfix: none,
  /// inset for block to use
  inset: 10pt,
  /// all the other args of `chordlib`
  ..args) = {
  let scale = get-chordgram-width-scale(args.named().at("tuning", default: default-tuning).split().len())
  context block(stroke: gray + 0.2pt, inset: inset, width: width + 2em, prefix + chordlib(..args, scale-l: width / N / scale) + postfix)
}

