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
)
```

Then, create your song with `song`, and add the lyrics with chords written between square brackets. Make sure to place a `\` at the end of each line to create a line break. `section` is useful for marking choruses and similar sections of song.

```typ
#song(
    title: "Swing Low Sweet Chariot",
    artist: "Wallace Willis"
)

#section[Refrain]
Swing [D]low, sweet [G]chari[D]ot, \
Comin’ for to carry me [A7]home. \
Swing [D7]low, sweet [G]chari[D]ot, \
Comin’ for to [A7]carry me [D]home. \
```

Instrumental sections with only a sequence of chords to play should be created with `seq`:
```typ
#seq[C G Am F]
```

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

## Attributions

Chord definitions are converted from https://github.com/tombatossals/chords-db.
