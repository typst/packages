#import "../src/lib.typ" as linphon

#set page(margin: 1.5cm, numbering: "1")
#set heading(numbering: "1.1")
#show outline.entry: it => link(
  it.element.location(),
  it.indented(it.prefix(), [#it.body() #h(0.5em) _#it.page()_]),
)
#let extable = table.with(columns: (40%, 1fr), gutter: 1em, stroke: none, inset: 0.5em)

#[
  #set align(center)
  #text(size: 2em, weight: 500)[The `linphon` Reference]
  #v(1em, weak: true)
  Version 0.1.0
]


#outline(depth: 2)

= Installation and import

== Importing from Typst Universe
The easiest way to use `linphon` is to just import it from the Typst Universe with
```typ
#import "@preview/linphon:0.1.0"
```

== Local installation
To install `linphon` locally, download the latest version from
#link("https://github.com/thatfloflo/typst-linphon/releases")[the `linphon` GitHub repository]
and unpack it inside Typst's data dir, as follows:

/ Linux: `$XDG_DATA_HOME/typst/packages/local/`
/ MacOS: `~/Library/Application Support/typst/packages/local/`
/ Windows: `%APPDATA%\typst\packages\local\`

You can then import the local package with
```typ
#import "@local/linphon:0.1.0"
```

#pagebreak()

= Feature matrices

== Binary/equipollent features
Give binary/equipollent features as an array of `(feature-value, feature-name)`.
#extable()[
  ```typm
  #linphon.fmat(
    ("+", "voice"),
    ("-", "nasal"),
    ("+", "coronal"),
    ("-", "back"),
  )
  ```
][
  #linphon.fmat(
    ("+", "voice"),
    ("-", "nasal"),
    ("+", "coronal"),
    ("-", "back"),
  )
]

== Privative/monovalent features
Give privative/monovalent features as an array consisting only of the feature name (NB: a trailing comma is needed to unambiguously tell Typst that the parentheses denote an array, i.e. `(feature-name,)`). These will be typeset left-aligned.
#extable()[
  ```typm
  #linphon.fmat(
    ("consonantal",),
    ("voice",),
    ("coronal",),
  )
  ```
][
  #linphon.fmat(
    ("consonantal",),
    ("voice",),
    ("coronal",),
  )
]

== Categorial placeholders
Simply give these as bare string/content arguments and they will be typeset centred within the feature matrix.
#extable()[
  ```typm
  #linphon.fmat(
    "C",
    ("+", "nasal"),
    ("+", "coronal"),
  )
  ```
][
  #linphon.fmat(
    "C",
    ("+", "nasal"),
    ("+", "coronal"),
  )
][
  ```typm
  #linphon.fmat(
    linphon.dash(length: 3.5em),
    ("+", "nasal"),
    ("+", "coronal"),
  )
  ```
][
  #linphon.fmat(
    linphon.dash(length: 3.5em),
    ("+", "nasal"),
    ("+", "coronal"),
  )
]

== Conditional submatrices (for if-then conditions)
You can pass an array of arrays to include a submatrix, which is set in angle brackets by default and typically used to indicate if-then conditions (e.g. if back, then also round), esp. across several feature matrices in a rule.
#extable()[
  ```typm
  #linphon.fmat(
    ("+", "syllabic"),
    ("+", "high"),
    ("-", "low"),
    (
      ("+", "back"),
      ("+", "round"),
    )
  )
  ```
][
  #linphon.fmat(
    ("+", "syllabic"),
    ("+", "high"),
    ("-", "low"),
    (
      ("+", "back"),
      ("+", "round"),
    )
  )
]

#pagebreak()
== Different types of feature values

When given as feature values, the strings `"+"`, `"-"`, `"plus"`, `"minus"`, `"plus.minus"`, `"minus.plus"`, `"m"` _(marked)_, `"u"` _(unmarked)_, names of lower-case greek letters (`"alpha"`, `"beta"`, ..., `"omega"`, incl. `".alt"`-variants) and numerals will be set as though they had been written in math mode.

#extable()[
  ```typm
  #linphon.fmat(
    ("+", "F"),
    ("-", "F"),
    ("plus.minus", "F"),
  )
  ```
][
  #linphon.fmat(
    ("+", "F"),
    ("-", "F"),
    ("plus.minus", "F"),
  )
][
  ```typm
  #linphon.fmat(
    ("m", "F"),
    ("u", "F"),
    ("0", "F"),
  )
  ```
][
  #linphon.fmat(
    ("m", "F"),
    ("u", "F"),
    ("0", "F"),
  )
][
  ```typm
  #linphon.fmat(
    ("alpha", "F"),
    ("beta", "F"),
    ("gamma", "F"),
  )
  ```
][
    #linphon.fmat(
    ("alpha", "F"),
    ("beta", "F"),
    ("gamma", "F"),
  )
][
  ```typm
  #linphon.fmat(
    ("-alpha", "F"),
    ("+beta", "F"),
    ("-sigma.alt", "F"),
  )
  ```
][
  #linphon.fmat(
    ("-alpha", "F"),
    ("+beta", "F"),
    ("-sigma.alt", "F"),
  )
]

== Inline feature matrices

These can be specified in the same manner as the tabular feature matrices above, but will be set as normal text instead. They are also breakable across lines between features.

#extable()[
  ```typm
  #linphon.fmat-inline(
    ("+", "voice"),
    ("-", "nasal"),
    ("+", "coronal"),
  )
  ```
][
  #linphon.fmat-inline(
    ("+", "voice"),
    ("-", "nasal"),
    ("+", "coronal"),
  )
][
  ```typm
  #linphon.fmat-inline(
    ("+", "syllabic"),
    (
      ("alpha", "back"),
      ("alpha", "round"),
    ),
    ("-", "high"),
    linphon.dash()
  )
  ```
][
  #linphon.fmat-inline(
    ("+", "syllabic"),
    (
      ("alpha", "back"),
      ("alpha", "round"),
    ),
    ("-", "high"),
    linphon.dash()
  )
]


#pagebreak()
= Cases / Option statements

== Two-sided
#extable()[
  ```typm
  X
  #linphon.cases[
    Case 1
  ][
    Case 2
  ][...]
  Y
  ```
][
  X
  #linphon.cases[
    Case 1
  ][
    Case 2
  ][...]
  Y
]

== One-sided
#extable()[
  ```typm
  X
  #linphon.cases-left[
    Case 1
  ][
    Case 2
  ][...]
  ```
][
  X
  #linphon.cases-left[
    Case 1
  ][
    Case 2
  ][...]
][
  ```typm
  #linphon.cases-left[
    Case 1
  ][
    Case 2
  ][...]
  X
  ```
][
  #linphon.cases-right[
    Case 1
  ][
    Case 2
  ][...]
  X
]

= Rewrite rules

== Context-free rules

#extable()[
  ```typm
  #linphon.rule[
    Input
  ][
    Output
  ]
  ```
][
  #linphon.rule[Input][Output]
][
  ```typm
  #linphon.rule[CCV][CəCV]
  ```
][
  #linphon.rule[CCV][CəCV]
]

== Rules with contextual specification

#extable()[
  ```typm
  #linphon.rule[
    Input
  ][
    Output
  ][
    Context
  ]
  ```
][
  #linphon.rule[Input][Output][Context]
][
  ```typm
  #linphon.rule[
    #sym.emptyset
  ][
    ə
  ][
    C#linphon.dash()C
  ]
  ```
][
  #linphon.rule[#sym.emptyset][ə][C#linphon.dash()CV]
]

= Constraints


#extable()[
  ```typm
  #linphon.constraint[
    Illicit stuff
  ]
  ```
][
  #linphon.constraint[Illicit stuff]
][
  ```typm
  #linphon.constraint[VCCV]
  ```
][
  #linphon.constraint[VCCV]
][
  ```typm
  #linphon.constraint[
    #linphon.fmat(
      ("+", "syll"), ("+", "high")
    )
    $("C"_0"V"_0)_0$
    #linphon.fmat(
      ("+", "syll"), ("-", "high")
    )
  ]
  ```
][
  #linphon.constraint[
    #linphon.fmat(("+", "syll"), ("+", "high"))
    $("C"_0"V"_0)_0$
    #linphon.fmat(("+", "syll"), ("-", "high"))
  ]
]

= Custom brackets
It is possible to specify custom delimiters (brackets) for both feature matrices
and case/option statements. The `linphon.fmat()` and `linphon.fmat-inline()`
functions take both a `delim` and a `submatrix-delim` argument, while
`linphon.cases()` takes only a `delim` argument.

Possible `delim` values are always an array specifying a left and a right
bracket as a pair, each of which can be one of:
```typc "("```, ```typc ")"```, ```typc "{"```, ```typc "}"```, ```typc "["```,
```typc "]"```, ```typc "<"```, ```typc ">"```, ```typc "/"```, ```typc "|"```,
or to not set a bracket at all, ```typc none```.

#extable()[
  ```typm
  #linphon.fmat(
    delim: ("[", none),
    submatrix-delim: ("(", "|"),
    ("-", "syllabic"),
    ("+", "nasal"),
    ("-", "voice"),
    (
      ("alpha", "coronal"),
      ("-alpha", "dorsal")
    )
  )
  ```
][
  #linphon.fmat(
    delim: ("[", none),
    submatrix-delim: ("(", "|"),
    ("-", "syllabic"),
    ("+", "nasal"),
    ("-", "voice"),
    (
      ("alpha", "coronal"),
      ("-alpha", "dorsal")
    )
  )
][
  ```typm
  #linphon.cases(
    delim: ("(", ")")
  )[Case 1][Case 2][...]
  ```
][
  #linphon.cases(
    delim: ("(", ")")
  )[Case 1][Case 2][...]
][
  ```typm
  #linphon.cases(
    delim: ("}", "{")
  )[Case 1][Case 2][...]
  ```
][
  #linphon.cases(
    delim: ("}", "{")
  )[Case 1][Case 2][...]
][
  ```typm
  #linphon.cases(
    delim: ("/", "/")
  )[Case 1][Case 2][...]
  ```
][
  #linphon.cases(
    delim: ("/", "/")
  )[Case 1][Case 2][...]
][
  ```typm
  #linphon.cases(
    delim: ("|", ">")
  )[Case 1][Case 2][...]
  ```
][
  #linphon.cases(
    delim: ("|", ">")
  )[Case 1][Case 2][...]
]

= Examples of rules

== _l_-deletion

#extable()[
  ```typm
  #linphon.rule[
    l
  ][
    #sym.emptyset
  ][
    C #linphon.dash() \#
  ]
  ```
][
  #linphon.rule[l][#sym.emptyset][C #linphon.dash() \#]
]

== Tapping rule

#extable()[
  ```typm
  #linphon.rule[
    #linphon.fmat(
      ("-", "cont"),
      ("+", "cor"),
      ("-", "nas")
    )
  ][
    #linphon.fmat(("+", "tap"))
  ][
    #linphon.fmat(
      ("+", "syll"),
      ("+", "stress")
    )
    #linphon.dash()
    #linphon.fmat(
      ("+", "syll"),
      ("-", "stress")
    )
  ]
  ```
][
  #linphon.rule[
    #linphon.fmat(
      ("-", "cont"),
      ("+", "cor"),
      ("-", "nas")
    )
  ][
    #linphon.fmat(("+", "tap"))
  ][
    #linphon.fmat(
      ("+", "syll"),
      ("+", "stress")
    )
    #linphon.dash()
    #linphon.fmat(
      ("+", "syll"),
      ("-", "stress")
    )
  ]
]

== SPE, Chapter 4, Rule 60 (p. 200)

Note that this is not the best way to set the example numbers (60a,b), it would
be much better instead to use a package such as
#link("https://typst.app/universe/package/eggs")[`eggs`] for that.

#extable()[
  ```typm
  #grid(
    columns: (1.5cm, 1fr)
  )[
    $lr((60), size: #250%)$
  ][
    (a) ~ #linphon.rule[
      #linphon.cases[æ][u]
    ][
      #linphon.fmat-inline(
        ("+", "tense"),
      )
    ][
      #linphon.fmat(
        (linphon.dash-horizon(
          length: 3.5em
        )),
        ("+", "stress")
      )
      _nge_
    ]
    
    (b) ~ #linphon.rule()[ɔ][ɔ̄][
      #linphon.dash-horizon()CV#linphon.fmat-inline(("-", "seg"))
    ]
  ]
  ```
][
  #grid(
    columns: (1.5cm, 1fr)
  )[
    $lr((60), size: #250%)$
  ][
    (a) ~ #linphon.rule[
      #linphon.cases[æ][u]
    ][
      #linphon.fmat-inline(("+", "tense"))
    ][
      #linphon.fmat(
        (linphon.dash-horizon(length: 3.5em)),
        ("+", "stress")
      )
      _nge_
    ]
    
    (b) ~ #linphon.rule()[ɔ][ɔ̄][
      #linphon.dash-horizon()CV#linphon.fmat-inline(("-", "seg"))
    ]
  ]
]

== SPE, Chapter 3, Rule 82 (p. 99)

Note that this is not the best way to set the example number (82), it would
be much better instead to use a package such as
#link("https://typst.app/universe/package/eggs")[`eggs`] for that.

#extable()[
  ```typm
  #grid(
    columns: (1.2cm, 1fr)
  )[
    $lr((82), size: #250%)$
  ][
    #linphon.rule()[
      V
    ][
      #linphon.fmat-inline(
        ("1", "stress")
      )
    ][
      \[_X_#linphon.dash-horizon()$"C"_0$
      (
        #linphon.fmat(
          ("-", "tense"),
          "V"
        )
        $"C"_0^1$
        $#linphon.fmat(
          ("alpha", "voc"),
          ("alpha", "cons"),
          ("-", "ant")
        )_(thin 0)$
      )
    ]
    #h(6.75em)
    $slash.big$
    #linphon.dash-horizon()
    #sym.angle.l
    #linphon.cases()[
      #linphon.fmat(
        delim: ("<", ">"),
        ("+", $"C"_0$),
      )
      #linphon.fmat(
        ("-", "stress"),
        ("-", "tense"),
        ("V")
      )
    ][
      #linphon.cases(
        delim: ("<", ">"),
      )[
        #linphon.fmat-inline(("-", "seg"))
      ]
      $"C"_0$ #math.attach(math.limits("V"), t: "1")
    ]
    $"C"_0$#sym.angle.r
    \]#sub[
      $angle.l
      "N" angle.l "A" angle.r
      angle.r$
    ]
  ]
  ```
][
  #block(breakable: false)[
  #grid(
    columns: (1.2cm, 1fr)
  )[
    $lr((82), size: #250%)$
  ][
    #linphon.rule()[
      V
    ][
      #linphon.fmat-inline(
        ("1", "stress")
      )
    ][
      \[_X_#linphon.dash-horizon()$"C"_0$
      (
        #linphon.fmat(
          ("-", "tense"),
          "V"
        )
        $"C"_0^1$
        $#linphon.fmat(
          ("alpha", "voc"),
          ("alpha", "cons"),
          ("-", "ant")
        )_(thin 0)$
      )
    ]
    #block(breakable: false, width: 130%)[
    #h(6.75em)
    $slash.big$
    #linphon.dash-horizon()
    #sym.angle.l
    #linphon.cases()[
      #linphon.fmat(
        delim: ("<", ">"),
        ("+", $"C"_0$),
      )
      #linphon.fmat(
        ("-", "stress"),
        ("-", "tense"),
        ("V")
      )
    ][
      #linphon.cases(
        delim: ("<", ">"),
      )[
        #linphon.fmat-inline(("-", "seg"))
      ]
      $"C"_0$ #math.attach(math.limits("V"), t: "1")
    ]
    $"C"_0$#sym.angle.r
    \]#sub[
      $angle.l
      "N" angle.l "A" angle.r
      angle.r$
    ]
  ]
  ]
  ]
]
