#import "/src/lib.typ": stave, major-scale, minor-scale, arpeggio, chromatic-scale, all-clefs, all-note-durations, _allowed-sides, _minor-types, _symbol-data

= Staves Typst Package

Author: Matthew Davis

This Typst package is used to draw musical scales.

For now this is restricted to only one stave (set of lines).
This package can be used to write arbitrary notes, but is not intended to be used for entire songs.


#figure(
  major-scale("treble", "D", 4),
  caption: [D Major Scale]
)

#figure(
  arpeggio("bass", "g", 2, note-duration: "crotchet"),
  caption: [G Minor Arpeggio]
)


#figure(
  stave("alto", "c", notes: ("C3", "D#4", "F3")),
  caption: [Custom Notes]
)


== Stave

The foundational function is called `stave`.
This is for writing just clefs, clefs and key signatures, or clefs, key signatures and custom notes.

=== Usage

The arguments are:

#let kwarg_defs = (
  "geometric-scale": [(optional) Number e.g. 0.5 or 2 to draw the content at half or double the size. This is about visual scale, not musical scales.],
  "note-duration": [(optional) Allowed values are "#all-note-durations.join("\", \"")". Default is "whole" note. All notes are the same duration.],
  "note-sep": [(optional) Used to adjust the horizontal spacing between notes. If you shrink below `note-sep: 0.7`, leger lines will overlap. At that point if it's still too big, use `geometric-scale` as well.],
  "equal-note-head-space": [`true` or `false`. Defaults to `true`. If true, note heads will be equally spaced. Some of this space will be taken up with accidentals. If `false`, adding an accidental to a note will shift the note head further right. `true` looks better (in my opinion), but `false` is useful in combination with the other spacing arguments, to avoid accidentals overlapping with previous note heads.]
)

/ `clef`: Allowed values are "#all-clefs.join("\", \"")". Drawing a treble clef above a bass clef, linked as a double-stave (like for a piano) is not yet supported.
/ `key`: Two possible forms. 
  - Letter based: Uppercase for major, lowercase for minor, with `#` or `b` appended. e.g. `"C"`, `"Db"`, `"f#"`
  - Number based, with a symbol: "5\#" (or "5s") for 5 sharps, "2b" for 2 flats
/ `notes`: An (optional) array of strings representing notes to play sequentially. Chords are not supported. e.g.
  - "C4" is middle C
  - "C5" is the C an octave above middle C. 
  - "Db4" or "C\#4" is a semitone above middle C
  - "B3" is a semitone below middle C
  - "Bn3" has an explicit natural accidental ♮ infront of it
  - "Fx3" is an F3 with a double sharp, drawn as an #box(height: 0.7em, image(_symbol-data.double-sharp-x.image)) (Formats such as "F\#\#3" to show ♯♯ are not supported yet.)
  - double flats are not yet supported.
#for (k, v) in kwarg_defs.pairs(){
  [
    / #raw(k): #v
  ]
}

=== Examples

To draw just a key signature, omit the `notes` argument

```typst
#import "@preview/staves:0.1.0": stave

#figure(
  stave("treble", "D"),
  caption: [D Major Key Signature]
)
```

#figure(
  stave("treble", "D"),
  caption: [D Major Key Signature]
)


Here is an example of including `notes`. Legerlines are supported.

```typst
#figure(
  stave("treble", "F", notes: ("F4", "A4", "C5", "F5", "C5", "A4", "F4")),
  caption: [F Major Arpeggio]
)
```

#figure(
  stave("treble", "F", notes: ("F4", "A4", "C5", "F5", "A5", "C6", "F6", "C6", "A5", "F5", "C5", "A4", "F4")),
  caption: [F Major Arpeggio]
)

Note that accidentals are independent of the key signature. 
For the example of F major, the key contains B flat. A "B" note will be drawn with no accidental, so it is flattenned by the key signature. A "Bb" will have a redundant flat accidental drawn. "Bn" will have an explicit natural accidental.
This behavior may change in future versions.


```typst
#figure(
  stave("bass", "F", notes: ("C2", "B2", "Bb2", "B2", "Bn2")),
  caption: [Lack of interaction between accidentals and key signature]
)
```

#figure(
  stave("bass", "F", notes: ("C2", "B2", "Bb2", "B2", "Bn2")),
  caption: [Lack of interaction between accidentals and key signature]
)

The `note-duration` can be used to change the note symbol.

#let canvases = ()
#for note-duration in all-note-durations {
  canvases.push([
    #figure(
      stave("treble", "C", notes: ("C5", "B4", "A4"), note-duration: note-duration),
      caption: [`note-duration`: #note-duration]
    )
  ])
}


#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 1em,
  align: horizon,
  ..canvases
)

=== Spacing and Sizing

The `geometric-scale` argument can be used to adjust the overall size:


#grid(
  columns: (2fr, 1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 1em,
  align: horizon,
  figure(
    stave("bass", "F", notes: ("C#3",), geometric-scale: 2),
    caption: [`geometric-scale: 2`]
  ),
  figure(
    stave("bass", "F", notes: ("C#3",)),
    caption: [default (omitted `geometric-scale`)]
  ),
  figure(
    stave("bass", "F", notes: ("C#3",), geometric-scale: 0.5),
    caption: [`geometric-scale: 0.5`]
  )
)

`note-sep` can be used to adjust the horizontal separation between notes, whilst keeping the height of the stave the same:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 1em,
  align: horizon,
  figure(
    stave("bass", "G", notes: ("C3", "D3", "C3")),
    caption: [default (omitted `note-sep`)]
  ),
  figure(
    stave("bass", "G", notes: ("C3", "D3", "C3"), note-sep: 0.6),
    caption: [`note-sep: 0.7`]
  )
)

`equal-note-head-space` is used to adjust the spacing based on whether there are accidentals.

#let canvases = ()

#for e in (true, false) {
  canvases.push(
    figure(
      stave("treble", "C", notes: ("C5", "C#5", "D5", "D#5"), equal-note-head-space: e),
      caption: [`equal-note-head-space` = #e]
    )
  )
}


#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 1em,
  align: horizon,
  ..canvases
)


== Major Scales

The `major-scale` function is for writing major scales.

=== Usage

/ `clef`: Allowed values are "#all-clefs.join("\", \"")". (Same as for `stave`.)
/ `key`: e.g. "A", "Bb", "C\#". Uppercase only.
/ `start-octave`: integer. e.g. 4 is the octave starting from middle C. 5 is the octave above that.
/ `num-octaves`: Optional, defaults to 1.
#for (k, v) in kwarg_defs.pairs(){
  [
    / #raw(k): #v
  ]
}

=== Examples

```typst
#import "@preview/staves:0.1.0": major-scale

#figure(
  major-scale("treble", "D", 4),
  caption: [D Major scale]
)
```

#figure(
  major-scale("treble", "D", 4),
  caption: [D Major scale]
)

You can write a 2 octave scale with `num-octaves: 2`.
This is probably too wide for your page. Shrink it horizontally with `note-sep`, or shrink in both dimensions with `geometric-scale`.

```typst
#figure(
  major-scale("bass", "F", 2, num-octaves: 2, note-sep: 0.7, geometric-scale: 0.7),
  caption: [F Major scale]
)
```

#figure(
  major-scale("bass", "F", 2, num-octaves: 2, note-sep: 0.7, geometric-scale: 0.7),
  caption: [F Major scale]
)

== Minor Scale

The `minor-scale` function is for writing natural and harmonic minor scales.
The usage is the same as for `major-scale`, plus an additional `minor-type` argument.


=== Usage

/ `clef`: Allowed values are "#all-clefs.join("\", \"")". (Same as for `stave`.)
/ `key`: e.g. "A", "Bb", "c\#". Uppercase or lowercase.
/ `start-octave`: integer. e.g. 4 is the octave starting from middle C. 5 is the octave above that.
/ `num-octaves`: Optional, defaults to 1.
/ `minor-type`: Defaults to "harmonic". Allowed values are "#_minor-types.join("\", \"")". Melodic minor scales are not yet supported.
#for (k, v) in kwarg_defs.pairs(){
  [
    / #raw(k): #v
  ]
}

=== Examples


```typst
#import "@preview/staves:0.1.0": minor-scale

#figure(
  minor-scale("treble", "D", 4),
  caption: [D Harmonic Minor scale]
)
```

#figure(
  minor-scale("treble", "D", 4),
  caption: [D Harmonic Minor scale]
)


```typst
#import "@preview/staves:0.1.0": minor-scale

#figure(
  minor-scale("bass", "Bb", 2, minor-type: "natural"),
  caption: [Bb Natural Minor scale]
)
```

#figure(
  minor-scale("bass", "Bb", 2, minor-type: "natural"),
  caption: [Bb Natural Minor scale]
)


Note that for keys with a sharp, the raised 7th can be written as a double sharp, or a natural of the next note.

```typst
#figure(
  minor-scale("treble", "F#", 4, seventh: "n"),
  caption: [F\# Harmonic Minor scale with 7th written as F natural]
)

#figure(
  minor-scale("treble", "F#", 4, seventh: "x"),
  caption: [F\# Harmonic Minor scale with 7th written as E double sharp]
)
```

#figure(
  minor-scale("treble", "F#", 4, seventh: "n"),
  caption: [F\# Harmonic Minor scale with 7th written as F natural]
)

#figure(
  minor-scale("treble", "F#", 4, seventh: "x"),
  caption: [F\# Harmonic Minor scale with 7th written as E double sharp]
)

== Arpeggio

The `arpeggio` function is for writing arpeggios.

=== Usage

The arguments are the same as for `major-scale`.


/ `clef`: Allowed values are "#all-clefs.join("\", \"")". (Same as for `stave`.)
/ `key`: e.g. "A", "Bb", "C\#". Uppercase for major, lowercase for minor. Do not include a number for the octave.
/ `start-octave`: integer. e.g. 4 is the octave starting from middle C. 5 is the octave above that.
/ `num-octaves`: Optional, defaults to 1.
#for (k, v) in kwarg_defs.pairs(){
  [
    / #raw(k): #v
  ]
}

=== Example

```typst
#import "@preview/staves:0.1.0": arpeggio

#figure(
  arpeggio("bass", "F", 2, num-octaves: 2),
  caption: [F Major Arpeggio]
)
```
#figure(
  arpeggio("bass", "F", 2, num-octaves: 2),
  caption: [F Major Arpeggio]
)

== Chromatic Scales

`chromatic-scale` is used to write chromatic scales (every semitone between two notes).
The arguments are:

=== Usage

/ `clef`: Allowed values are "#all-clefs.join("\", \"")". (Same as for `stave`.)
/ `start-note`: e.g. "C4" for middle C, "C5" for the C above that, "Db4" for a semitone above middle C
/ `num-octaves`: Optional, defaults to 1.
/ `side`: "#_allowed-sides.join("\", \"")"
#for (k, v) in kwarg_defs.pairs(){
  [
    / #raw(k): #v
  ]
}

These scales tend to be quite long, so you probably want to use `note-sep` and `geometric-scale`, and perhaps a landscape page.

=== Examples

```typst
#import "@preview/staves:0.1.0": chromatic-scale

#figure(
  chromatic-scale("treble", "D4", note-sep: 0.8, geometric-scale: 0.7),
  caption: [D Chromatic Scale]
)
```

#figure(
  chromatic-scale("treble", "D4", note-sep: 0.8, geometric-scale: 0.7),
  caption: [D Chromatic Scale]
)

```typst
#figure(
  chromatic-scale("bass", "F2", side: "flat", geometric-scale: 0.6, note-duration: "crotchet"),
  caption: [F Chromatic Scale]
)
```

#figure(
  chromatic-scale("bass", "F2", side: "flat", geometric-scale: 0.6, note-duration: "crotchet"),
  caption: [F Chromatic Scale]
)

== Implementation Details

This package uses a `canvas` from the #link("https://typst.app/universe/package/cetz", "CeTZ") package.

== License Details

This library uses SVG images for clefs, accidentals etc.
These files came from Wikipedia, and are in the public domain.
They are not covered by the same license as the rest of the package.
Source URLs for these SVGs are listed in #link("https://github.com/mdavis-xyz/staves-typst/tree/master/assets", `/assets/README.md`)