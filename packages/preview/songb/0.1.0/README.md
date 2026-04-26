<!--
SPDX-FileCopyrightText: 2024 Olivier Charvin <git@olivier.pfad.fr>
SPDX-License-Identifier: CC0-1.0 -->

# songb: Songbook package for [Typst](https://typst.app)

Attempt at creating a songbook package to replace [patacrep](https://github.com/patacrep/patacrep) (which is based on LaTeX + [Songs](https://songs.sourceforge.net/)).

## Quickstart

First, create a `main.typ` file, like the following:

```typ
#set page(paper: "a6",margin: (inside: 14mm, outside: 6mm, y: 10mm))

#import "@preview/songb:0.1.0": autobreak, index-by-letter

// helper function, to include you own songs (feel free to customize)
#let song(path) = {
    // WARNING: autobreak is currently broken (does not converge)
    // see https://github.com/typst/typst/discussions/4530
    autobreak(include path)
    v(-1.19em)
}

// indexes (put them wherever you want, or comment them out)
= Song Index
#index-by-letter(<song>)

= Singer Index
#index-by-letter(<singer>)

#pagebreak()

// include all you songs, in the right order
#song("./songs/first_song.typ")

#song("./songs/other_song.typ")

// ...
```

Then, create your song files, like `songs/first_song.typ`:
```typ
#import "@preview/songb:0.1.0": song, chorus, verse, chord

#show: doc => song(
  title: "First Song",
  singer: "Sing",
  doc,
)

#chorus[
  #chord[Am]First line,#chord[G][ ]of the chorus\
  #chord[Am]Second line,#chord[G][ ]of the chorus.
]


#verse[
  #chord[Em]First verse\
  With multiple\
  #chord[C]Lines
]

If there is #chord[D][a] bridge\
you can write it directly
```

## Writing a song

### song

```typ
#let song(
  title: none,
  title-index: none,
  singer: none,
  singer-index: none,
  references: (),
  line-color: rgb(0xd0, 0xd0, 0xd0),
  header-display: (number, title, singer) => (...),
  doc
)
```

### chord
```typ
// first argument: chord name
// optional second argument: text below the chord (useful for whitespace for instance)
#let chord(..content)
```

### verse
```typ
#let verse(body)
```

### chorus
```typ
#let chorus(body)
```


## Organizing songs

### autobreak
> [!WARNING]
> Currently broken (lack of convergence for bigger documents)
> See https://github.com/typst/typst/discussions/4530

This function aims at putting the content on a single page (or on facing pages), by introducing pagebreaks when needed.
```typ
#let autobreak(content)
```

### index-by-letter

```typ
#let index-by-letter(label, letter-highlight: (letter) => (...))
```
label: `<song>` or `<singer>` are provided by the `song` function.
