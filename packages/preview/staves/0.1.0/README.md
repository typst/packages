# Staves Typst Package

Author: Matthew Davis

This Typst package is used to draw musical scales. This package can be
used to write arbitrary notes, but is not intended to be used for entire
songs.

## Quickstart Examples

Example: D Major Scale

``` typ
#import "@preview/staves:0.1.0": major-scale
#major-scale("treble", "D", 4)
```

![D Major
Scale](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/D-major.png)

Example: G Minor Arpeggio

``` typ
#import "@preview/staves:0.1.0": arpeggio
#arpeggio("bass", "g", 2, note-duration: "crotchet")
```

![G Minor
Arpeggio](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/G-minor-arpeggio.png)

Example: Custom Notes

``` typ
#import "@preview/staves:0.1.0": stave
#stave("alto", "c", notes: ("C3", "D#4", "F3"), width: 7cm)
```

![Custom
Notes](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/custom-notes.png)

## Documentation and Examples

A PDF version of this documentation (with slightly better formatting) is
available [here](docs/docs.pdf).

To see a showcase of what this package can do, see this example of a
normal scale book: [PDF](examples/scale-book.pdf) and [Typst source
code](examples/scale-book.typ).

Another example is a scale book which is a random mix of all scales:
[PDF](examples/random-scales.pdf) and [Typst source
code](examples/random-scales.typ). The purpose of this second one is to
provide variety during your scales practices.

## Stave

The foundational function is called `stave`. This is for writing just
clefs, clefs and key signatures, or clefs, key signatures and custom
notes. Typically as a user you should use the higher-level abstractions
such as `arpeggio` and `major-scale` (documented further down), if they
suit your needs. `staves` is exposed for creating custom scales which
are not yet supported (e.g. broken chords, scales in thirds etc). This
documentation section also explains parameters which are common to all
functions.

### Usage

The arguments are:

`clef`: (Required) Allowed values are “treble", "bass", "alto", "tenor”. Drawing
a treble clef above a bass clef, linked as a double-stave (like for a
piano) is not yet supported.

`key`: (Required) Two possible forms.

- Letter based: Uppercase for major, lowercase for minor, with `#` or
  `b` appended. e.g. `"C"`, `"Db"`, `"f#"`

- Number based, with a symbol: “5#” (or “5s”) for 5 sharps, “2b” for 2
  flats

`notes`: An (optional) array of strings representing notes to play sequentially.
Chords are not supported. e.g.

- “C4” is middle C

- “C5” is the C an octave above middle C.

- “Db4” or “C#4” is a semitone above middle C

- “B3” is a semitone below middle C

- “Bn3” has an explicit natural accidental ♮ infront of it

- “Fx3” is an F3 with a double sharp, drawn as an 𝄪

  (Formats such as “F##3” to show ♯♯ are not supported yet.)

- double flats are not yet supported.


`notes-per-stave`: (Optional) Used to break a long scale over multiple lines. Line breaks
will be inserted after every group of this many notes. If omitted, all
notes will be placed on the first stave. Page breaks are blocked between
staves of the same scale.


`note-duration`: (optional) Allowed values are “whole", "quarter", "semibreve",
"crotchet”. Default is “whole” note. All notes are the same duration.


`width`: (Optional) If provided, sets the length of the stave lines. It omitted
(or `auto`), the stave lines will be stretched to the available space.
If the page width itself is `auto`, a sensible default will be used.


`line-sep`: (Optional) A
<u>[length](https://typst.app/docs/reference/layout/length/)</u> used to
set the vertical spacing of the 5 stave lines (within a given stave).
Note that this is a length with units, e.g. `3cm`, not just `3`.


`equal-note-head-space`: `true` or `false`. Defaults to `true`. If true, note heads will be
equally spaced. Some of this space will be taken up with accidentals. If
`false`, adding an accidental to a note will shift the note head further
right. `true` looks better (in my opinion), but `false` is useful when
trying to squish many notes into one stave, to avoid accidentals
overlapping with previous note heads.

### Examples

To draw just a key signature, omit the `notes` argument

``` typ
#import "@preview/staves:0.1.0": stave
#stave("treble", "D")
```

![](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/D-major-key.png)

Here is an example of including `notes`. Legerlines are supported.

``` typ
#stave("treble", "F", notes: ("F4",  "C5", "F5", "C6", "F6", "C6", "F5", "C5", "F4"))
```

![](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/F-major-notes.png)

Note that accidentals are independent of the key signature. For the
example of F major, the key contains B flat. A “B” note will be drawn
with no accidental, so it is flattenned by the key signature. A “Bb”
will have a redundant flat accidental drawn. “Bn” will have an explicit
natural accidental. This behavior may change in future versions.

``` typ
#stave("bass", "F", notes: ("C2", "B2", "Bb2", "B2", "Bn2"))
```

![](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/accidentals-and-key.png)

The `note-duration` argument can be used to change the note symbol.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr>
<td><p>note-duration: whole</p>
<p><img
src="https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/note-durations-whole.png"
alt="whole" /></p></td>
<td><p>note-duration: quarter</p>
<p><img
src="https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/note-durations-quarter.png"
alt="quarter" /></p></td>
</tr>
<tr>
<td><p>note-duration: semibreve</p>
<p><img
src="https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/note-durations-semibreve.png"
alt="semibreve" /></p></td>
<td><p>note-duration: crotchet</p>
<p><img
src="https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/note-durations-crotchet.png"
alt="crotchet" /></p></td>
</tr>
</tbody>
</table>

### Spacing and Sizing

The `notes-per-stave` argument can be used to split up long scales into
multiple lines.

``` typ
#major-scale("treble", "D", 4, num-octaves: 2, notes-per-stave: 16)
```

![](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/scale-long.png)

The `width` argument can be used to adjust the overall width.

``` typ
#stave("treble", "f", width: 7cm)
```

![](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/width.png)

The `line-sep` argument can be used to adjust the vertical spacing
between stave lines. Note that this must be a
<u>[`length`](https://typst.app/docs/reference/layout/length/)</u> (i.e.
includes a unit like “cm”, “inches” etc) not just a
<u>[`float`](https://typst.app/docs/reference/foundations/float/)</u>.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr>
<td><p>line-sep: 0.2cm</p>
<p><img
src="https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/line-sep-0-2cm.png"
alt="0.2cm" /></p></td>
<td><p>line-sep: 0.5cm</p>
<p><img
src="https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/line-sep-0-5cm.png"
alt="0.5cm" /></p></td>
</tr>
</tbody>
</table>

`equal-note-head-space` is used to adjust the spacing based on whether
there are accidentals. `True` means the space between notes is equal
regardless of whether there is an accidental. `False` means there is an
equal space between each note and the accidental of the next note. (i.e.
unequal space between each note head.)

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr>
<td><p>equal-note-head-space: true</p>
<p><img
src="https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/equal-note-head-space-true.png"
alt="true" /></p></td>
<td><p>equal-note-head-space: false</p>
<p><img
src="https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/equal-note-head-space-false.png"
alt="false" /></p></td>
</tr>
</tbody>
</table>

## Major Scales

The `major-scale` function is for writing major scales.

### Usage

`clef`: (Required) Allowed values are “treble", "bass", "alto", "tenor”. (Same
as for `stave`.)

`key`: (Required) e.g. “A”, “Bb”, “C#”. Uppercase only.

`start-octave`: (Required) integer. e.g. 4 is the octave starting from middle C. 5 is
the octave above that.

`num-octaves`: Optional, defaults to 1.


`notes-per-stave`: (Optional) Used to break a long scale over multiple lines. Line breaks
will be inserted after every group of this many notes. If omitted, all
notes will be placed on the first stave. Page breaks are blocked between
staves of the same scale.


`note-duration`: (optional) Allowed values are “whole", "quarter", "semibreve",
"crotchet”. Default is “whole” note. All notes are the same duration.


`width`: (Optional) If provided, sets the length of the stave lines. It omitted
(or `auto`), the stave lines will be stretched to the available space.
If the page width itself is `auto`, a sensible default will be used.


`line-sep`: (Optional) A
<u>[length](https://typst.app/docs/reference/layout/length/)</u> used to
set the vertical spacing of the 5 stave lines (within a given stave).
Note that this is a length with units, e.g. `3cm`, not just `3`.


`equal-note-head-space`: `true` or `false`. Defaults to `true`. If true, note heads will be
equally spaced. Some of this space will be taken up with accidentals. If
`false`, adding an accidental to a note will shift the note head further
right. `true` looks better (in my opinion), but `false` is useful when
trying to squish many notes into one stave, to avoid accidentals
overlapping with previous note heads.

### Examples

Example: D Major Scale

``` typ
#import "@preview/staves:0.1.0": major-scale
#major-scale("treble", "D", 4)
```

![D Major
Scale](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/D-major.png)

You can write a 2 octave scale with `num-octaves: 2`.

## Minor Scale

The `minor-scale` function is for writing natural and harmonic minor
scales. The usage is the same as for `major-scale`, plus an additional
`minor-type` argument.

### Usage

`clef`: (Required) Allowed values are “treble", "bass", "alto", "tenor”. (Same
as for `stave`.)

`key`: (Required) e.g. “A”, “Bb”, “c#”. Uppercase or lowercase.

`start-octave`: (Required) integer. e.g. 4 is the octave starting from middle C. 5 is
the octave above that.

`num-octaves`: Optional, defaults to 1.

`minor-type`: Defaults to “harmonic”. Allowed values are “natural", "harmonic”.
Melodic minor scales are not yet supported.

`seventh`: Where the raised seventh would be a double sharp, configure how it is
shown. Allowed values are “n", "x”. See examples below.


`notes-per-stave`: (Optional) Used to break a long scale over multiple lines. Line breaks
will be inserted after every group of this many notes. If omitted, all
notes will be placed on the first stave. Page breaks are blocked between
staves of the same scale.


`note-duration`: (optional) Allowed values are “whole", "quarter", "semibreve",
"crotchet”. Default is “whole” note. All notes are the same duration.


`width`: (Optional) If provided, sets the length of the stave lines. It omitted
(or `auto`), the stave lines will be stretched to the available space.
If the page width itself is `auto`, a sensible default will be used.


`line-sep`: (Optional) A
<u>[length](https://typst.app/docs/reference/layout/length/)</u> used to
set the vertical spacing of the 5 stave lines (within a given stave).
Note that this is a length with units, e.g. `3cm`, not just `3`.


`equal-note-head-space`: `true` or `false`. Defaults to `true`. If true, note heads will be
equally spaced. Some of this space will be taken up with accidentals. If
`false`, adding an accidental to a note will shift the note head further
right. `true` looks better (in my opinion), but `false` is useful when
trying to squish many notes into one stave, to avoid accidentals
overlapping with previous note heads.

### Examples

Example: D Harmonic Minor Scale

``` typ
#import "@preview/staves:0.1.0": minor-scale
#minor-scale("treble", "D", 4)
```

![D Harmonic Minor
Scale](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/D-harmonic-minor.png)

Example: Bb Natural Minor Scale

``` typ
#minor-scale("bass", "Bb", 2, minor-type: "natural")
```

![Bb Natural Minor
Scale](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/Bb-natural-minor.png)

Note that for keys with a sharp, the raised 7th can be written as a
double sharp, or a natural of the next note.

``` typ
#minor-scale("treble", "F#", 4, seventh: "n")
```

![](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/Fs-harmonic-minor-n.png)

``` typ
#minor-scale("treble", "F#", 4, seventh: "x")
```

![](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/Fs-harmonic-minor-x.png)

## Arpeggio

The `arpeggio` function is for writing arpeggios.

### Usage

The arguments are the same as for `major-scale`.

`clef`: (Required) Allowed values are “treble", "bass", "alto", "tenor”. (Same
as for `stave`.)

`key`: (Required) e.g. “A”, “Bb”, “C#”. Uppercase for major, lowercase for
minor. Do not include a number for the octave.

`start-octave`: (Required) integer. e.g. 4 is the octave starting from middle C. 5 is
the octave above that.

`num-octaves`: Optional, defaults to 1.


`notes-per-stave`: (Optional) Used to break a long scale over multiple lines. Line breaks
will be inserted after every group of this many notes. If omitted, all
notes will be placed on the first stave. Page breaks are blocked between
staves of the same scale.


`note-duration`: (optional) Allowed values are “whole", "quarter", "semibreve",
"crotchet”. Default is “whole” note. All notes are the same duration.


`width`: (Optional) If provided, sets the length of the stave lines. It omitted
(or `auto`), the stave lines will be stretched to the available space.
If the page width itself is `auto`, a sensible default will be used.


`line-sep`: (Optional) A
<u>[length](https://typst.app/docs/reference/layout/length/)</u> used to
set the vertical spacing of the 5 stave lines (within a given stave).
Note that this is a length with units, e.g. `3cm`, not just `3`.


`equal-note-head-space`: `true` or `false`. Defaults to `true`. If true, note heads will be
equally spaced. Some of this space will be taken up with accidentals. If
`false`, adding an accidental to a note will shift the note head further
right. `true` looks better (in my opinion), but `false` is useful when
trying to squish many notes into one stave, to avoid accidentals
overlapping with previous note heads.

### Example

Example: F Major Arpeggio

``` typ
#arpeggio("bass", "F", 2, num-octaves: 2)
```

![F Major
Arpeggio](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/F-major-arpeggio.png)

## Chromatic Scales

`chromatic-scale` is used to write chromatic scales (every semitone
between two notes). The arguments are:

### Usage

`clef`: (Required) Allowed values are “treble", "bass", "alto", "tenor”. (Same
as for `stave`.)

`key`: (Required) e.g. “A”, “Bb”, “C#”. Uppercase for major, lowercase for
minor. Do not include a number for the octave.

`start-octave`: (Required) integer. e.g. 4 is the octave starting from middle C. 5 is
the octave above that.

`num-octaves`: Optional, defaults to 1.

`side`: ”sharp", "flat”


`notes-per-stave`: (Optional) Used to break a long scale over multiple lines. Line breaks
will be inserted after every group of this many notes. If omitted, all
notes will be placed on the first stave. Page breaks are blocked between
staves of the same scale.


`note-duration`: (optional) Allowed values are “whole", "quarter", "semibreve",
"crotchet”. Default is “whole” note. All notes are the same duration.


`width`: (Optional) If provided, sets the length of the stave lines. It omitted
(or `auto`), the stave lines will be stretched to the available space.
If the page width itself is `auto`, a sensible default will be used.


`line-sep`: (Optional) A
<u>[length](https://typst.app/docs/reference/layout/length/)</u> used to
set the vertical spacing of the 5 stave lines (within a given stave).
Note that this is a length with units, e.g. `3cm`, not just `3`.


`equal-note-head-space`: `true` or `false`. Defaults to `true`. If true, note heads will be
equally spaced. Some of this space will be taken up with accidentals. If
`false`, adding an accidental to a note will shift the note head further
right. `true` looks better (in my opinion), but `false` is useful when
trying to squish many notes into one stave, to avoid accidentals
overlapping with previous note heads.

### Examples

Example: D Chromatic Scale

``` typ
#chromatic-scale("treble", "D", 4, notes-per-stave: semitones-per-octave + 1)
```

![D Chromatic
Scale](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/D-chromatic.png)

Example: G Chromatic Scale

``` typ
#chromatic-scale("bass", "G", 2, side: "flat", note-duration: "crotchet", notes-per-stave: semitones-per-octave + 1)
```

![G Chromatic
Scale](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/G-chromatic.png)

## Modes

`mode-by-index` is used to write modal scales. This function takes the
key of the corresponding major scale (ionian), and an integer
(one-indexed) to specify which mode relative to that ionian.

This function is designed so that users can easily write all modes of a
given key signature with a simple for loop. If you know the word (e.g.
“phrygian”) and want to programatically convert that to the relevant
integer, use the constant `mode-names` (documented below). Watch out
though. Typst indexes lists from 0, whereas this function treats 1 as
the first mode (ionian), because musicians tend to count from 1.

### Usage

`clef`: (Required) Allowed values are “treble", "bass", "alto", "tenor”. (Same
as for `stave`.)

`key`: (Required) e.g. “A”, “Bb”, “C#”. Uppercase for major, lowercase for
minor. Do not include a number for the octave.

`start-octave`: (Required) integer. e.g. 4 is the octave starting from middle C. 5 is
the octave above that. This refers to the octave of the ionian, not the
first note of the mode.

`mode-index`: (Required) integer. one-indexed. 1 is ionian, 0 is dorian etc.

`num-octaves`: Optional, defaults to 1.

`side`: ”sharp", "flat”


`notes-per-stave`: (Optional) Used to break a long scale over multiple lines. Line breaks
will be inserted after every group of this many notes. If omitted, all
notes will be placed on the first stave. Page breaks are blocked between
staves of the same scale.


`note-duration`: (optional) Allowed values are “whole", "quarter", "semibreve",
"crotchet”. Default is “whole” note. All notes are the same duration.


`width`: (Optional) If provided, sets the length of the stave lines. It omitted
(or `auto`), the stave lines will be stretched to the available space.
If the page width itself is `auto`, a sensible default will be used.


`line-sep`: (Optional) A
<u>[length](https://typst.app/docs/reference/layout/length/)</u> used to
set the vertical spacing of the 5 stave lines (within a given stave).
Note that this is a length with units, e.g. `3cm`, not just `3`.


`equal-note-head-space`: `true` or `false`. Defaults to `true`. If true, note heads will be
equally spaced. Some of this space will be taken up with accidentals. If
`false`, adding an accidental to a note will shift the note head further
right. `true` looks better (in my opinion), but `false` is useful when
trying to squish many notes into one stave, to avoid accidentals
overlapping with previous note heads.

### Examples

Example: G Dorian

``` typ
#mode-by-index("treble", "G", 4, 2)
```

![G
Dorian](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/G-dorian.png)

To write all modes with 2 sharps use a `for` loop:

``` typ
#for mode-index in range(1, num-letters-per-octave + 1) {
mode-by-index("treble", "D", 4, mode-index)
}
```

![](https://raw.githubusercontent.com/mdavis-xyz/staves-typst/refs/heads/0.1.0/docs/examples/all-D-modes.png)

## Constants

There are some constants which are exposed by the library. They may make
it easier to write scale books. However the structure, value and
presence of these should be considered unstable, and is likely to change
in future versions.

`all-clefs`: ("treble", "bass", "alto", "tenor")

`key-data`: (major: ("Cb", "Gb", "Db", "Ab", "Eb", "Bb", "F", "C", "G",
"D", "A", "E", "B", "F#", "C#"), minor: ("ab", "eb", "bb", "f", "c",
"g", "d", "a", "e", "b", "f#", "c#", "g#", "d#", "a#"))

`all-notes-from-c`: (sharp: ("C", "C#", "D", "D#", "E", "F", "F#", "G",
"G#", "A", "A#", "B"), flat: ("C", "Db", "D", "Eb", "E", "F", "Gb", "G",
"Ab", "A", "Bb", "B"))

`semitones-per-octave`: 12

`middle-c-octave`: 4

`all-letters-from-c`: ("C", "D", "E", "F", "G", "A", "B")

`num-letters-per-octave`: 7

`sharp-order`: ("F", "C", "G", "D", "A", "E", "B")

`mode-names`: ("ionian", "dorian", "phrygian", "lydian", "mixolydian",
"aeolian", "locrian")

## Setting Defaults

To set a default, such as the same `note-duration` for your whole
document, use <u>[the with
approach](https://forum.typst.app/t/how-to-apply-set-rules-to-custom-functions/1657/2?u=mdavis_xyz)</u>
(for each different scale type):

``` typ
#let major-scale = major-scale.with(note-duration: "crotchet")
#let minor-scale = minor-scale.with(note-duration: "crotchet")
```

## Implementation Details

This package uses a `canvas` from the
<u>[CeTZ](https://typst.app/universe/package/cetz)</u> package.

## License Details

This library uses SVG images for clefs, accidentals etc. These files
came from Wikipedia, and are in the public domain. They are not covered
by the same license as the rest of the package. Source URLs for these
SVGs are listed in
<u>[`/assets/README.md`](https://github.com/mdavis-xyz/staves-typst/tree/master/assets)</u>
