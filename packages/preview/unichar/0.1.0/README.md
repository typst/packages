# Unichar

This package ports part of the [Unicode Character Database](https://www.unicode.org/reports/tr44/) to Typst. Notably, it includes information from [UnicodeData.txt](https://unicode.org/reports/tr44/#UnicodeData.txt) and [Blocks.txt](https://unicode.org/reports/tr44/#Blocks.txt).


## Usage

This package defines a single function: `codepoint`. It lets you get the information related to a specific codepoint. The codepoint can be specified as a string containing a single character, or with its value.

```typ
#codepoint("√").name \
#codepoint(sym.times).block \
#codepoint(0x00C9).general-category
```

![image](examples/example-1.svg)

You can display a codepoint in the style of [Template:Unichar](https://en.wikipedia.org/wiki/Template:Unichar) using the `show` entry:

```typ
#codepoint("¤").show \
#codepoint(sym.copyright).show \
#codepoint(0x1249).show \
#codepoint(0x100000).show
```

![image](examples/example-2.svg)


## Changelog

### Version 0.1.0

- Add the `codepoint` function.