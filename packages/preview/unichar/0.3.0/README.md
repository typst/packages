# Unichar

This package ports part of the [Unicode Character Database](https://www.unicode.org/reports/tr44/) to Typst. Notably, it includes information from [UnicodeData.txt](https://unicode.org/reports/tr44/#UnicodeData.txt) and [Blocks.txt](https://unicode.org/reports/tr44/#Blocks.txt).


## Usage

This package defines a single function: `codepoint`. It lets you get the information related to a specific codepoint. The codepoint can be specified as a string containing a single character, or with its value.

```typ
#codepoint("√").name \
#codepoint(sym.times).block.name \
#codepoint(0x00C9).general-category \
#codepoint(sym.eq).math-class
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

### Version 0.3.0

- Add `math-class` attribute to codepoints.
    - Some codepoints have their math class overridden by Typst. This is the Unicode math class, not the one used by Typst.

- The `id` of codepoints now returns a string without the `"U+"` prefix.

### Version 0.2.0

- Codepoints now have an `id` attribute which is its corresponding "U+xxxx" string.

- The `block` attribute of a codepoint now contains a `name`, a `start`, and a `size`.

- Fix an issue that made some codepoints cause a panic.

- Include data from NameAlias.txt.

### Version 0.1.0

- Add the `codepoint` function.