A simple module to write [tengwar](https://en.wikipedia.org/wiki/Tengwar) in [Typst](https://typst.app/).

## Requirements

- [Typst](https://github.com/typst/typst) version 0.11.0 or 0.11.1
- The [Tengwar Annatar](https://www.fontspace.com/tengwar-annatar-font-f2244) fonts version 1.20

To use this module with the [Typst web app](https://typst.app/), you need to upload the font files to your project.

## Usage

The main functionality of this module is provided by functions taking content and converting all text in Tenwar: 

* `quenya` converts text using the mode of Quenya,
* `gondor` converts text using the Sindarin mode of Gondor.

The original text is used as a phonetic transcription. (This module does not translate English into Quenya or Sindarin.) See the [manual](https://github.com/FlorentCLMichel/quetta/blob/main/manual.pdf) for more information. 

The following line may be used to convert the whole document below to Tengwar in Quenya mode (other `show` rules might interfere with it):
```
#show: quetta.quenya
```

**Example:**

```
#import "@preview/quetta:0.2.0"

// Use the function `quenya` to write a small amount of text in Tengwar (Quenya mode)
#text(size: 16pt, 
      fill: gradient.linear(blue, green)
     )[#box(quetta.quenya[_tengwar_])]

#v(1em)

// A `show` rule may be more convenient for larger contents; beware that it may interfere with other ones, though
#show: quetta.quenya

Namárië!

#h(1em) _Namárië!_

#h(2em) *Namárië!*
```

## Roadmap

* Number conversion: done
* Support for the Quenya mode: done
* Support for the mode of Gondor: done
* Support for the mode of Beleriand: backlog
* Support for the Black Speech: backlog

## Changelog

### v0.2.0

* Add support for Sindarin—Mode of Gondor
* **Breaking change:** The symbol used to prevent combination was changed from `:` to `|`.
* Small changes to the kerning between several tengwar and to tehtar positions.

### v0.1.0

Initial release with Quenya support.

## How can I contribute?

I (the original author) am definitely not en expert in either Typst nor Tengwar. I could thus use some help in all areas. I would especially welcome contributions or suggestions on the following: 

* Identify and resolve inefficiencies in the Typst code.
* Identify cases where the result differs from the expected one. (In particular, there are probably rules for writing in Tengwar that I either am not aware of or have not properly understood. Any advice on that is warmly welcome!)
* References on Tengar, Quenya, and Sindarin.
* Support for other Tengwar fonts. 
