# chordx

A package to write song lyrics with chord diagrams in Typst.

**Table of Contents**

- [Introduction](#introduction)
- [Usage](#usage)
  - [Typst Packages](#typst-packages)
  - [Local Packages](#local-packages)
- [Documentation](#documentation)
- [Examples](#examples)
  - [Chart Chords](#chart-chords)
  - [Piano Chords](#piano-chords)
  - [Single Chords](#single-chords)
- [Changelog](#changelog)
- [License](#license)

## Introduction

With `chordx` you can easily generate song lyrics with chords for writing songbooks.

`chordx` generates chord charts for stringed instruments (e.g. guitar, ukulele, etc.), piano chords (with diferent piano layouts) and single chords that are chords without charts used to write the chords over a word to write songbooks.

## Usage

`chordx` exports 3 functions that return others with default settings:

- `new-chart-chords`: used to generate chart chords for stringed instruments.
- `new-piano-chords`: used to generate piano chords.
- `new-single-chords`: used to show the chord name over a word.

### Typst Packages

Typst added an experimental package repository and you can import `chordx` as follows:

```typ
#import "@preview/chordx:0.3.0": *
```

### Local Packages

If the package hasn't been released yet, or if you just want to use it from this repository, you can use _*local-packages*_.

You can read the documentation about typst [local-packages](https://github.com/typst/packages#local-packages) and learn about the path folders used in differents operating systems (Linux / MacOS / Windows).

In Linux you can do:

```sh
git clone https://github.com/ljgago/typst-chords ~/.local/share/typst/packages/local/chordx/0.3.0
```

And import the package in your file:

```typ
#import "@local/chordx:0.3.0": *
```

## Documentation

Here [chordx-docs](https://github.com/ljgago/typst-chords/blob/v0.3.0/docs/chordx-docs.pdf) you have the reference documentation that describes the functions and parameters used in this package. (_Generated with [tidy](https://github.com/Mc-Zen/tidy)_)

## Examples:

### Chart Chords

```typ
#import "@preview/chordx:0.3.0": *

#let chart-chord = new-chart-chords(size: 18pt)
#let chart-chord-round = new-chart-chords(style: "round", size: 1.5em)

// Style "normal"
#chart-chord(tabs: "x32o1o", fingers: "n32n1n")[C]
#chart-chord(tabs: "ooo3", fingers: "ooo3")[C]

// Style "round"
#chart-chord-round(tabs: "xn332n", fingers: "o13421", fret: 3, capos: "115")[Cm]
#chart-chord-round(tabs: "onnn", fingers: "n111", capos: "313")[Cm]
```

<h3 align="center">
  <a href="https://github.com/ljgago/typst-chords/blob/v0.3.0/examples/chart-chords.typ">
    <img
      alt="Chart Chord"
      src="https://github.com/ljgago/typst-chords/blob/v0.3.0/examples/chart-chords.svg"
      style="max-width: 100%; width: 450pt;"
    >
  </a>
</h3>

### Piano Chords

```typ
#import "@preview/chordx:0.3.0": *

#let piano-chord = new-piano-chords(layout: "F", size: 18pt)
#let piano-chord-round = new-piano-chords(layout: "F", size: 1.5em, style: "round")

#piano-chord(keys: "B1, D2#, F2#", fill: blue)[B]
#piano-chord-round(keys: "B1, D2#, F2#", fill: red)[B]
```

<h3 align="center">
  <a href="https://github.com/ljgago/typst-chords/blob/v0.3.0/examples/piano-chords.typ">
    <img
      alt="Piano Chord"
      src="https://github.com/ljgago/typst-chords/blob/v0.3.0/examples/piano-chords.svg"
      style="max-width: 100%; width: 450pt;"
    >
  </a>
</h3>

### Single Chords

```typ
#import "@preview/chordx:0.3.0": *

#let chord = new-single-chords(style: "italic", weight: "semibold")

#chord[Jingle][G][2] bells, jingle bells, jingle #chord[all][C][2] the #chord[way!][G][2] \
#chord[Oh][C][] what fun it #chord[is][G][] to ride \
In a #chord[one-horse][A7][2] open #chord[sleigh,][D7][3] hey!
```

<h2 align="center">
  <a href="https://github.com/ljgago/typst-chords/blob/v0.3.0/examples/single-chords.typ">
    <img
      alt="Single Chord"
      src="https://github.com/ljgago/typst-chords/blob/v0.3.0/examples/single-chords.svg"
      style="max-width: 100%; width: 450pt;"
    >
  </a>
</h2>

## Changelog

You can read the latest changes in [CHANGELOG.md](./CHANGELOG.md)

## License
[MIT License](./LICENSE)
