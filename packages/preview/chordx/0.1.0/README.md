# chordx

A library to write song lyrics with chord diagrams in Typst. This library uses [CeTZ](https://github.com/johannes-wolf/typst-canvas) (aka typst-canvas) to generate the diagrams.

**Table of Contents**

- [Usage](#usage)
  - [Typst Packages](#typst-packages)
  - [Local Packages](#local-packages)
- [Documentation](#documentation)
  - [Function: new-graph-chords](#function-new-graph-chords)
  - [Function: new-single-chords](#function-new-single-chords)
- [License](#license)

## Usage

`chordx` has two implementations, one using [CeTZ](https://github.com/johannes-wolf/typst-canvas) and another using native functions.

The native functions work the same way as the main implementation, in a future it will replace the main implementation, for now you can use both.

```js
// Using main implementation
#let graph-chord = new-graph-chords()
#let single-chord = new-single-chords(style: "italic", weight: "semibold")

// Using native implementation
#let graph-chord = new-graph-chords-native()
#let single-chord = new-single-chords-native(style: "italic", weight: "semibold")
```

### Typst Packages

Typst added an experimental package repository and you can import `chordx` as follows:

```js
#import "@preview/chordx:0.1.0": *
```

### Local Packages

If the package hasn't been released yet, or if you just want to use it from this repository, you can use `local-packages`

You can read the documentation about typst [local-packages](https://github.com/typst/packages#local-packages) and learn about the path folders used in differents operating systems (Linux / MacOS / Windows).

In Linux you can do:

```sh
$ git clone https://github.com/ljgago/typst-chords ~/.local/share/typst/packages/local/chordx-0.1.0
```

And import the lib in your file:

```js
#import "@local/chordx:0.1.0": *
```

## Documentation

With `chordx` you can use 2 functions `new-graph-chords` and `new-single-chords`. These functions returns other functions (a closure) with a preset setting.

### Function: `new-graph-chords`

```js
// Chord with diagram
// Return a function with these settings
#let guitar-chord = new-graph-chords(
  strings: number,
  font: string,
)
```

- `strings`: number of strings of the instrument (columns of the grid), default: 6, `Optional`
- `font`: text font name, default: "Linux Libertine", `Optional`

The returned function from `new-graph-chords` has the following parameters:

```js
// Generates a chord diagram
#guitar-chord(
  frets: number,
  fret-number: number or none,
  capos: array(array) or array(dictionary),
  fingers: array,
  notes,
  chord-name
)
```

- `frets`: number of frets (rows of the grid), default: 5, `Optional`
- `fret-number`: shows the fret position, default: none, `Optional`
- `capos`: adds one o many capos on the graph, default: (), `Optional`

  ```js
    // array(array) or array(dictionary)
    ((
      fret: number,
      start: number,  // the first string
      end: number     // the last string
    ),)
  ```

  - `fret`: number of the fret position relative to grid, `Required`
  - `start`: number of the first string, `Required`
  - `end`: number of the last string, `Required`

- `fingers`: shows the finger numbers, default: (), (0: without finger, number: one finger), `Optional`
- `notes`: shows the notes on the graph ("x": mute note, "n": without note, 0: air note, number: one note), `Required`
- `chord-name`: shows the chord name, `Required`

Examples:

```js
#import "@preview/chordx:0.1.0": *

#let guitar-chord = new-graph-chords()
#let ukulele-chord = new-graph-chords(strings: 4)

// Guitar B chord
#guitar-chord(
  capos: ((fret: 2, start: 1, end: 5),), // capos: ((2, 1, 5),)
  fingers: (0, 1, 2, 3, 4, 1),
  ("x", "n", 4, 4, 4, "n")
)[B]

// Ukulele B chord
#ukulele-chord(
  capos: ((2, 1, 2),), // capos: ((fret: 2, start: 1, end: 2),)
  fingers: (3, 2, 1, 1),
  (4, 3, "n", "n")
)[B]
```

<h3 align="center">
  <img
    alt="Graph Chord"
    src="https://raw.githubusercontent.com/ljgago/typst-chords/main/examples/graph-chords.svg"
    style="max-width: 100%; width: 200pt; padding: 10px 20px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 8pt; box-sizing: border-box; background: white"
  >
</h3>

### Function: `new-single-chords`

```js
// A single chord (without diagram)
// Return a function with these settings
#let chord = new-single-chords(
  style: "italic",
  weight: "semibold",
  ...
)
```

The chord without diagram is used to write the chord over a word. All parameters of `new-single-chords` are the same of `text` of `typst`.

The returned function from `new-single-chords` has the following parameters:

```js
#chord(
  body,
  chord-name,
  body-char-pos
)
```

- `body`: is the word or words where the chord goes, `Required`
- `chord-name`: displays the chord name over the selected words in the body, `Required`
- `body-char-pos`: positions the chord over a specific character in the body, `[]` or `[0]`: chord centered above the body, `[number]`: chord above character in body, `Required`

Examples:

```js
#import "@preview/chordx:0.1.0": *

#let chord = new-single-chords(style: "italic", weight: "semibold")

#chord[Jingle][G][2] bells, jingle bells, jingle #chord[all][C][2] the #chord[way!][G][2] \
#chord[Oh][C][] what fun it #chord[is][G][] to ride \
In a #chord[one-horse][A7][2] open #chord[sleigh,][D7][3] hey!
```

<h2 align="center">
  <img
    alt="Single Chord"
    src="https://raw.githubusercontent.com/ljgago/typst-chords/main/examples/single-chords.svg"
    style="max-width: 100%; width: 400pt; padding: 10px 20px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 8pt; box-sizing: border-box; background: white"
  >
</h2>

## License

[MIT License](./LICENSE)
