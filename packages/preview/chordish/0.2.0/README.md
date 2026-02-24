# Chordish: Chord sheets for Typst

A simple template for creating chord sheets (or collections of chord sheets) in Typst.

Start by importing the `songbook` template and using it for your main document:

```typ
#import "@preview/chordish:0.1.0": songbook, song, section
#show: songbook
```

You can also provide options to `songbook`:

```typ
#show: songbook.with(
    // "guitar" (default) or "ukulele"
    instrument: "ukulele",

    // "inline" (default) or "above"
    chords: "above",

    // Generate chord diagrams for each song. Enabled by default.
    diagrams: false,

    // Automatically insert chords where square brackets are found.
    // If you disable this, you need to manually insert chords using #chord.
    autochords: false,
)
```

Then, create your song with `song`, and add the lyrics with chords written between square brackets. Make sure to place a `\` at the end of each line to create a line break, and before `#` to escape it. `section` is useful for marking choruses and similar sections of song.

```typ
#song(
    title: "Swing Low Sweet Chariot",
    artist: "Wallace Willis",
)

#section[Refrain]
Swing [D]low, sweet [G]chari[D]ot, \
Comin’ for to carry me [A7]home. \
Swing [D7]low, sweet [G]chari[D]ot, \
Comin’ for to [A7]carry me [D]home. \
```

It's also possible to create chords manually using the `chord` function, like `#chord[C7]`. This is the only way to create chords if `autochord` is disabled.

Instrumental sections with only a sequence of chords to play should be created with `seq`:
```typ
#seq[C G Am F]
```

## Books / ToC

For multi-song books, I recommend creating a separate Typst file for every song, and including them all in the desired order in your main file:

```typ
#show: songbook

#include "songs/Song 1.typ"
#include "songs/Song 2.typ"
```

You can create a table of contents using Typst's `outline` function, configured with a depth of 1:

```typ
#outline(depth: 1)
```

## Custom Chords

If a chord is not defined in the built-in list, or you want to use an alternative version of the chord, custom definitions can be created using `define-chord`:

```typ
#define-chord("F", "xx3211")
[F]Different F is used in diagrams now.
```

A chord is defined with a simple notation where an "x" represents a closed string, "0" represents an open string, and any other digit represents that fret being held.

Chords using two-digit fret numbers should separate the strings with commas.

## Transposition

To transpose a song up or down, specify the number of semitones to transpose by in the `song` function:

```typ
#song(
    title: "Swing Low Sweet Chariot",
    artist: "Wallace Willis",
    transpose: 4, // Up 4 semitones
)
```

Transposition currently does not work on custom chords, and leaves them as is.

## Attributions

Chord definitions are converted from https://github.com/tombatossals/chords-db.
