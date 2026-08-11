#import "../gen/gen.typ": default-tuning
#import "smart-chord.typ": smart-chord, red-missing-fifth, shift-chord-tonality
#import "draw-chord.typ": get-chordgram-width-scale

#let get-text(it) = {
  if type(it) == str {
    return it
  }
  if "children" in it.fields() {
    it.children.map(c => get-text(c)).join()
  } else if "text" in it.fields() {
    it.text
  }
}

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
  width: -0.25em) = {
    box(place(align, box(styling([#text <chord>]), width: float("inf")*1pt)), height: 1em + height, width: width)
    sym.zwj
  }

/// 1a. A replacement for overchord, displays chords inline in (double) square brackets
/// -> content
#let inlinechord(
  text,
  /// styling function that is applied to the string -> (text <chord>) => content
  styling: strong
) = "[[" + styling[#text<chord>] + "]]"

/// 1b. A replacement for overchord that "smartly" spreads chords along the words, but requires more writing:
/// ```example
/// #let ac = aligned-chords 
/// #ac[A][Why] do #ac[B][birds] #ac[C][D][suddenly] 
/// #ac[E\#/D][appear]
/// #ac[E\#/D][?]
/// ```
/// -> content
#let aligned-chords(
  /// styling function that is applied to the string -> (text <chord>) => content
  styling: strong,
  /// spacing between rendered chord and word -> spacing
  gutter: 0.5em,
  /// placement of chords relative to words -> alignment
  align: center,
  /// where to align chords if the chord(s) is larger than word,
  /// by default the same alignment as `align` -> alignment | auto
  wrapping-align: auto, 
  /// the chords and the word to put them on
  ..args) = context {
  let chords = if align == left {} else {(h(0.5fr), )}  + args.pos().slice(0, -1).map(c => {
    // in case it is parsed as a sequence, we should join it back into a text
    if "children" in c.fields() {
      c = c.children.map(c => c.text).join()
    }
    styling([#c <chord>])
  }
    ) + if align == right {} else {(h(0.5fr), )} 
  let word = args.pos().last()
  let width_word = measure(word).width
  let width_chords = measure(chords.join()).width
  box(width: calc.max(width_word, width_chords), grid(align: if wrapping-align == auto {align.inv()} else {wrapping-align.inv()}, row-gutter: gutter, chords.intersperse(h(1fr)).join(), word))
}

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
/// -> context
#let auto-tonality-chord(
  /// chord name -> str
  name,
  /// chord displaying method to use -> function(name, ..args) → content
  smart-chord: smart-chord,
  /// if true, converts all note notation to sharp versions
  sharp-only: false,
  /// arguments for smart-chord -> any
  ..args) = context {
   smart-chord(shift-chord-tonality(name, get-tonality(here()), sharp-only: sharp-only), ..args)
}


/// 8a. Fancy styles given string into string -> str 
#let fancy-styling-plain(
  /// -> str
  chord) = {
  show regex("\d"): super
  chord.replace("#", "♯")
    .replace("b", "♭")
}

/// 8b. Fancy styles content, with automatic tonality change and chord library export -> content
#let fancy-styling-autotonality(
  /// -> content
  chord) = {
  auto-tonality-chord(get-text(chord), smart-chord: fancy-styling-plain)
  box(place(hide(chord)))
}

/// 1b. An overchord alternative, displays a chord above line that is changed with tonality 
/// -> content
#let fulloverchord(
  /// chord name -> string
  name,
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
  heading-reset-tonality: none,
  /// if true, converts all note notation to sharp versions
  /// if false, reuses notation for scaling  
  sharp-only: false,
  ) = {
  show <chord>: c => {
    if get-tonality(c) == 0 {c} else {shift-chord-tonality(get-text(c), get-tonality(c), sharp-only: sharp-only)}
  }

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
  heading-level: none,
  /// if true, converts all note notation to sharp versions
  /// if false, reuses notation for scaling 
  /// and if both notations are present, uses first one
  sharp-only: false,) = {
  // select fitting chord
  let chords-selector = inside-level-selector(selector(<chord>), heading-level)
  let rendered = ()
  for (i, c) in query(chords-selector)
      .map(c => shift-chord-tonality(get-text(c).trim(), get-tonality(c), sharp-only: sharp-only))
      .dedup(key: t => shift-chord-tonality(t, 0, sharp-only: true))
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

