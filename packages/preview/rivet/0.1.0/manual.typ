#import "@preview/tidy:0.3.0"
#import "@preview/codelst:2.0.1": sourcecode
#import "@preview/showybox:2.0.1": showybox
#import "src/lib.typ"
#import "src/schema.typ"
#import "docs/examples.typ"

#set heading(numbering: (..num) => if num.pos().len() < 4 {
  numbering("1.1", ..num)
})
#{
  outline(indent: true, depth: 3)
}

#set page(numbering: "1/1", header: align(right)[rivet #sym.dash.em v#lib.version])

#let doc-ref(target, full: false, var: false) = {
  let (module, func) = target.split(".")
  let label-name = module + func
  let display-name = func
  if full {
    display-name = target
  }
  if not var {
    label-name += "()"
    display-name += "()"
  }
  link(label(label-name))[#display-name]
}

#let note(it) = showybox(
  title: "Note",
  title-style: (
    color: white,
    weight: "bold"
  ),
  frame: (
    title-color: blue.lighten(30%),
    border-color: blue.darken(40%)
  ),
  it
)

#show link: set text(blue)

= Introduction

This package provides a way to make beautiful register diagrams using the CeTZ package. It can be used to document Assembly instructions or binary registers

This is a port of the #link("https://git.kb28.ch/HEL/rivet")[homonymous Python script] for Typst.

= Usage

Simply import `schema` from #link("src/lib.typ") and call `schema.load` to parse a schema description. Then use `schema.render` to render it, et voilà !
#pad(left: 1em)[```typ
#import "@preview/rivet:0.1.0": schema
#let doc = schema.load("path/to/schema.yaml")
#schema.render(doc)
```]

= Format

This section describes the structure of a schema definition. The examples given use the JSON syntax. For examples in different formats, see #link("https://git.kb28.ch/HEL/rivet-typst/src/branch/main/gallery/test.yaml")[test.yaml], #link("https://git.kb28.ch/HEL/rivet-typst/src/branch/main/gallery/test.json")[test.json] and #link("https://git.kb28.ch/HEL/rivet-typst/src/branch/main/gallery/test.xml")[test.xml]. You can also directly define a schema using Typst dictionaries and arrays.

Since the XML format is quite different from the other, you might find it helpful to look at the examples on GitHub to get familiar with it.

== Main layout

A schema contains a dictionary of structures. The must be at least one defined structure named "main".

It can also optionnaly contain a "colors" dictionary. More details about this in #link(<format-colors>)[Colors]

#sourcecode[```json
{
  "structures": {
    "main": {
      ...
    },
    "struct1": {
      ...
    },
    "struct2": {
      ...
    },
    ...
  }
}
```]

#pagebreak(weak: true)

== Structure <format-structure>

A structure has a given number of bits and one or multiple ranges. Each range of bits can have a name, a description and / or values with special meaning (see #link(<format-range>)[Range]). A range's structure can also depend on another range's value (see #link(<format-dependencies>)[Dependencies]).

The range name (or key) defines the left- and rightmost bits (e.g. `7-4` goes from bit 7 down to bit 4). Bits are displayed in big-endian, i.e. the leftmost bit has the highest value.

#sourcecode[```json
"main": {
  "bits": 8,
  "ranges": {
    "7-4": {
      ...
    },
    "3-2": {
      ...
    },
    "1": {
      ...
    },
    "0": {
      ...
    }
  }
}
```]

== Range <format-range>

A range represents a group of consecutive bits. It can have a name (displayed in the bit cells), a description (displayed under the structure) and / or values.

For values depending on other ranges, see #link(<format-dependencies>)[Dependencies].

#note[
  In YAML, make sure to wrap values in quotes because some values can be interpreted as octal notation (e.g. 010 #sym.arrow.r 8)
]

#sourcecode[```json
"3-2": {
  "name": "op",
  "description": "Logical operation",
  "values": {
    "00": "AND",
    "01": "OR",
    "10": "XOR",
    "11": "NAND"
  }
}
```]

#pagebreak(weak: true)

== Dependencies <format-dependencies>

The structure of one range may depend on the value of another. To represent this situation, first indicate on the child range the range on which it depends.

Then, in its values, indicate which structure to use. A description can also be added (displayed above the horizontal dependency arrow)

#sourcecode[```json
"7-4": {
  ...
  "depends-on": "0",
  "values": {
    "0": {
      "description": "immediate value",
      "structure": "immediateValue"
    },
    "1": {
      "description": "value in register",
      "structure": "registerValue"
    }
  }
}
```]

Finally, add the sub-structures to the structure dictionary:

#sourcecode[```json
{
  "structures": {
    "main": {
      ...
    },
    "immediateValue": {
      "bits": 4,
      ...
    },
    "registerValue": {
      "bits": 4,
      ...
    },
    ...
  }
}
```]

#pagebreak(weak: true)

== Colors <format-colors>

You may want to highlight some ranges to make your diagram more readable. For this, you can use colors. Colors may be defined in a separate dictionary, at the same level as the "structures" dictionary:

#sourcecode[```json
{
  "structures": {
    ...
  },
  "colors": {
    ...
  }
}
```]

It can contain color definitions for any number of ranges. For each range, you may then define a dictionary mapping bit ranges to a particular color:

#sourcecode[```json
"colors": {
  "main": {
    "31-28": "#ABCDEF",
    "27-20": "12,34,56"
  },
  "registerValue": {
    "19-10": [12, 34, 56]
  }
}
```]

Valid color formats are:
- hex string starting with `#`, e.g. `"#23fa78"`
- array of three integers (only JSON, YAML and Typst), e.g. `[35, 250, 120]`
- string of three comma-separated integers (useful for XML), e.g. `"35,250,120"`
- a Typst color (only Typst), e.g. `colors.green` or `rgb(35, 250, 120)`

#note[
  The XML format implements colors a bit differently. Instead of having a "colors" dictionary, color definitions are directly put on the same level as structure definitions. For this, you can use a `color` node with the attributes "structure", "color", "start" and "end", like so:
  #sourcecode[```xml
  <schema>
    <structure id="main" bits="8">
      ...
    </structure>
    ...
    <color structure="main" color="#FF0000" start="4" end="7" />
    <color structure="main" color="255,0,0" start="0" end="3" />
  </schema>
  ```]
]

#pagebreak(weak: true)

= Config presets

Aside from the default config, some example presets are also provided:
- #doc-ref("config.config", full: true): the default theme, black on white
  #examples.config-config
- #doc-ref("config.dark", full: true): a dark theme, with white text and lines on a black background
  #examples.config-dark
- #doc-ref("config.blueprint", full: true): a blueprint theme, with white text and lines on a blue background
  #examples.config-blueprint

#pagebreak(weak: true)

= Reference

#let doc-config = tidy.parse-module(
  read("docs/config.typ"),
  name: "config",
  scope: (
    doc-ref: doc-ref
  )
)
#tidy.show-module(doc-config, sort-functions: false)

#pagebreak()

#let doc-schema = tidy.parse-module(
  read("docs/schema.typ"),
  name: "schema",
  scope: (
    schema: schema,
    doc-ref: doc-ref
  )
)
#tidy.show-module(doc-schema, sort-functions: false)