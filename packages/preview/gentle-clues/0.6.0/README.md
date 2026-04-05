# gentle-clues 

Simple admonitions for typst. Add predefined or define your own. 

Inspired from [mdbook-admonish](https://tommilligan.github.io/mdbook-admonish/).


## Usage

Import the package
```typst
#import "@preview/gentle-clues:0.6.0": *
```
Change the default settings.
```typst
#show: gentle-clues.with(
  lang: "de", // set header title language (default: "en")
)
```
[See the docs.pdf for all options](https://github.com/jomaway/typst-admonish/blob/main/docs.pdf)

### Use predefined clues

```typst
// info clue
#info[ This is the info clue ... ] 

// or a tip
#tip(title: "Best tip ever")[Check out this cool package]
```

Overview of the predefined clues:

![Overview of the predefined clues](gc_overview.svg)

`abstract`, `info`, `question`, `memo`, `task`, `idea`, `tip`, `quote`, `success`, `warning`, `error`, `example`.

### Define your own clue

But it is very easy to define your own. 

```typst 
//When you import the package, include clue
#import "@preview/gentle-clues:0.5.0": clue

//Define it
#let ghost-admon(..args) = clue(
  title: "Buuuuh", 
  _color: gray,
  icon: emoji.ghost, 
  ..args
)
// Use it
#ghost-admon[Huuuuuh.]
```

The icon can be an `emoji`, `symbol` or `.svg`-file. 

## License 

[MIT License](LICENSE)

## Changelog

[See CHANGELOG.md](CHANGELOG.md)