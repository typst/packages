# Simple academic CV

A simple academic CV template.
Sections are whatever you want them to be.
Publications can be cited in place from a .bib file, and your own name can be set in bold wherever it appears.
See `example.typ` for, well, an example how to use this:

## Quickstart

Start a new CV from the template:

```sh
typst init @preview/simple-academic-cv:0.1.0  CV
```

or in an existing file:

```typ
#import "@preview/simple-academic-cv:0.1.0": *

#show: cv.with(
    name: "HUGH MANN",
    me: "Mann",
    // me: (first: "Hugh", last: "Mann"),   // also accepted
    header-columns: (
        [Department],
        [#link("mailto:email@email.email")[email\@email.email]],
    ),
    bib: bibliography("example.bib", style: "apa")
)

#section("Education")[
    #entry[*University*][Place]
    #details[_Degree_ in Subject][Month. Year]
]

#section("Publications")[
    #set enum(reversed: true)
    + #cite(<example1>, form: "full")
]
```


## Options for `cv`

| Option | Default | Function |
| ------ | ------- | -------- |
| `name` | `""` | Your name, goes up top |
| `me` | `none` | Your last name, or `(first: "First", last: "Last")` in case someone shares your name; emboldens names matching last name throughout the document  |
| `header-columns` | `()` | Any number of content blocks shown beside one another, under your name |
| `header-columns-separator` | `none` | Content that gets placed between each of `header-columns` |
| `paper` | `"a4"` | Paper size |
| `margin` | `1in` | Paper margins. Takes  whatever arguments `page(margin: ...)` does |
| `spacing` | `1.0` | Multiplicative vertical whitespace scaling factor |
| `fonts` | `(:)` | Dictionary with any of: `body`, `bold`, `name`, `heading`. `body` is for text body and defaults to New Computer Modern; `bold` names a separate family for bold text and defaults to `body`; `name` and `heading` are fonts for your name and for headings, and default to `bold`  |
| `font-sizes` | `(:)` | Dictionary with any of `body`,`name`, `section`, `subsection`. `body` is  for text body and defaults to `11pt`; the others are derived from `body` by default |
| `link-color` | dark blue | The color of links. Seeting this to `none` will leave them uncolored |
| `bib` |  `none` | The bibliography, e.g, `bibliography("example.bib", style: "apa")` |
| `bib-show` | `false` | Show the bibliography ? Default hidden because the idea is to cite entries in full where they appear |

Everything else is normal, everyday Typst.
You can put `set` and `show` rules above the
`#show:  cv.with(...)` line:

```typ
#set par(justify: true)
#set text(hyphenate: false, lang: "en")
#set page(numbering: "1 / 1")
#show link: underline

#show: cv.with(...)
```

## Helpers
There exist various small routines to produce different content blocks


### The `section(title, body)` and `subsection(title)` helpers

These simple helpers give section and subsection headings:

```typ
#section("Section Title")[
  #subsection("Section Subtitle")

  Content ...
]
```

### The `entry(textleft, ..therest)` and  `details(textleft, ..therest)` helpers

```typ
#entry[*University*][Somewhere]
#details[_Degree in Subject_][Date]
```

### The `job(place, dates, title, ..therest)` helper

```typ
#job[Institute of Stuff][Date – Range][Position Name][
  What I learned in boating school is:
  - bullet
  - points
  - etc
]
```

### The `rows(..rows)` helper

Simple collection of rows:

```typ
#rows(
  ([Referee], [Some Journal]),
  ([Referee], [Some Other Journal]),
  ([Organizer], [Some Conference], [Dates]),
  ([Person], [At a place], [At a time !]),
)
```

### The `talk(title, kind: none, author: none, ..venues)` helper

For showing off your talks and posters. Maybe you gave a talk

```typ
#talk(
  [Title],
  author: "You !",
  kind: "Contributed Talk",
  ([Some Meeting, Somewhere], [Date]),
)
```
or poster at several places

```typ
#talk(
  [Title],
  author: "You, et al.",
  kind: "Poster",
  ([Some Meeting, Somewhere], [Date]),
  ([Some Other Meeting, Somewhere Else], [Another Date]),
)
```

or a mix of talks and posters with the same title ?

```typ
#talk(
  [Title],
  author: "You, et al.",
  ([Invited Talk], [Meeting, Somewhere], [Date]),
  ("Contributed Talk", [Some Meeting, Somewhere], [Date]),
  ([Poster], [Some Other Meeting, Somewhere Else], [Another Date]),
)
```

### The `funding(title, budget: none, ..fields)` helper

Maybe you got some money ? Every named argument becomes a `Label: value` row
in the order that they are supplied

```typ
#funding(
  [Award title],
  budget: [000 007 EUR],
  Agency: [Some agency],
  Effective: [Date range],
)
```

## Citations and Publications

Publications are printed where you cite them, i.e.

```typ
+ #cite(<example1>, form: "full")
```

Pick your favorite bibliography style. You can pass whatever bibliography into `cv()`.
If a co-author has the same name as you, consider polluting their name with an invisible unicode character like U+2060 in your bibliography file.
I did not come up with anything smart, sorry.

BibTeX exported from journals will work ... unless there's math, in which case Typst will fail to properly parse your bibliography.
Use the `bin/tex2typst` script provided by the GitHub repo [https://github.com/banana-bred/simple-academic-cv](https://github.com/banana-bred/simple-academic-cv) to convert yours if that's the case and if your shell supports it (needs `perl` and `pandoc`):

```sh
./bin/tex2typst raw.bib > example.bib
```

If you have custom commands in your .bib file, it probably won't work.
Oh well.

## License

MIT.

See [LICENSE](LICENSE).
