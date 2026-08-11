# Implementation

## Files

* `data.typ` contains config and hard-coded values relating to musical scales and SVG images
* `core.typ` contains the implementation of the final functions that get exposed (`stave`, `major-scale` etc)
* `utils.typ` contains helper functions calculating things, e.g. add N semitones to a given note
* `lib.typ` is a stub that just selectively imports only what we want to export
* `test.typ` contains unit tests for calculations in `utils.typ`

## Coordinates

`y` height is defined as:

- 0 = bottom line
- y=1, second-bottom line
- y=1.5 between 2nd-bottom and middle line

`x=0` is the left end of the bottom line. Positive `x` towards the right.

## Data Structures

Representing notes is surprisingly hard.
If you point to a note on the keyboard, or name a frequency in Hz, that could be one of two (or more) notes. e.g. B flat or A sharp.

Sometimes we want specific notes, other times we want untethered ones. e.g. C vs middle C.

We represent notes (at a specific octave) either as letter-based or integer-based.

### Letter Based

```
(
  type: "letter-note",
  letter: letter, // always uppercase
  accidental: accidental, // none, "n", "#", or "b"
  octave: octave
)
```

Where middle C is:

```
(
  type: "letter-note",
  letter: "C",
  accidental: none,
  octave: 4
)
```

The octave boundaries are between each C and the B below it. (Not between A and G).

Middle C is octave 4. The B one semitone below it is octave 3.
(The B one semitone below it is also a C flat. We say it's Cb4, not Cb3.)

### Index Based

```
(
  type: "index-note",
  index: int,
  side: "flat" or "sharp"
)
```

e.g. middle C is:

```
(
  type: "index-note",
  index: 60,
  side: "flat" // could be either
)
```

e.g. A semitone above middle C is either C#:

```
(
  type: "index-note",
  index: 61,
  side: "sharp"
)
```

or Db

```
(
  type: "index-note",
  index: 61,
  side: "flat"
)
```


## Scale Arithmetic

For calculating which notes to put into scales, we trust that the key signature handles most accidentals, and generally just increment the letter.
Accidentals for minor scales are handled based on intervals to the top root note, without explicit consideration of the key signature.
