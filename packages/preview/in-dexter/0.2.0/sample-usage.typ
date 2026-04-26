#import "./in-dexter.typ": *

// This typst file demonstrates the usage of the in-dexter package.
#set text(lang: "en", font: "Arial", size: 10pt)
#set heading(numbering: "1.1")

// Index-Entry hiding : this rule makes the index entries in the document invisible.
#show figure.where(kind: "jkrb_index"): it => {}


// Front Matter
#align(center)[
    #text(size: 23pt)[in-dexter]
    #linebreak() #v(1em)
    #text(size: 16pt)[An index package for Typst]
    #linebreak() #v(.5em)
    #text(size: 12pt)[Version 0.1.0 (7. January 2024)]
    #linebreak() #v(.5em)
    #text(size: 10pt)[Rolf Bremer, Jutta Klebe]
    #linebreak() #v(.5em)
    #text(size: 10pt)[Contributors: \@epsilonhalbe, \@sbatial]
    #v(4em)
]

= Sample Document to Demonstrate the in-dexter package

Using the in-dexter package in a typst document consists of some simple steps:

+ Importing the package `in-dexter`.
+ Marking the words or phrases to include in the index.
+ Generating the index page by calling the `make-index()` function.


== Importing the Package

The in-dexter package is currently available on GitHub in its home repository
(https://github.com/RolfBremer/in-dexter). It is still in development and may have
breaking changes #index[Breaking Changes] in its next iteration.
#index[Iteration]#index[Development]

```typ
    #import "./in-dexter.typ": *
```

The package is also available via Typst's build-in Package Manager:

```typ
    #import "@preview/in-dexter:0.2.0": *
```

Note, that the version number of the typst package has to be adapted to get the wanted
version.


== Marking of Entries

We have marked several words to be included in an index page at the end of the document. The markup
for the entry stays invisible#index[Invisible]. Its location in the text gets recorded, and later it
is shown as a page reference in the index page.#index([Index Page])

```typ
    #index[The Entry Phrase]
```

or

```typ
    #index([The Entry Phrase])
```

or

```typ
    #index("The Entry Phrase")
```


== Advanced entries


=== Symbols

Symbols can be indexed to be sorted under `"Symbols"`, and be sorted at the top of the index like this

```typ
    #index(initial: (letter: "Symbols", sorty-by: "#"), [$(rho)$])
```


=== Nested entries

Entries can be nested. The `index` function takes multiple arguments - one for each nesting level.

```typ
    #index("Sample", "medical", "blood")
    #index("Sample", "medical", "tissue")
    #index("Sample", "musical", "piano")
```

#index("Sample", "medical", "blood")
#index("Sample", "medical", "tissue")
#index("Sample", "musical", "piano")


=== Skipping physical pages

If page number 1 is not the first physical page of the document, the parameter `
use-page-counter` of the make-index() function can be set to `true`. Default is `false`.


=== Formatting Entries

#index(fmt: strong, [Formatting Entries])

Entries can be formatted with arbitrary functions that map `content` to `content`

```typ
    #index(fmt: it => strong(it), [The Entry Phrase])
```

or shorter

```typ
    #index(fmt: strong, [The Entry Phrase])
```

For convenience in-dexter exposes `index-main` which formats the entry bold. It is
semantically named to decouple the markup from the actual style. One can decide to have
the main entries slanted or color formatted, which makes it clear that the style should
not be part of the function name in markup. Naming markup functions according to their
purpose (semantically) also eases the burden on the author, because she must not remember
the currently valid styles for her intent.

Another reason to use semantically markup functions is to have them defined in a central
place. Changing the style becomes very easy this way.

```typ
    #index-main[The Entry Phrase]
```

It is predefined in in-dexter like this:

```typ
    #let index-main = index.with(fmt: strong)
```

Here we define another semantical index marker, which adds an "ff." to the page number.

```typ
    #let index-ff = index.with(fmt: it => [#it _ff._])
```

#let index-ff = index.with(fmt: it => [#it _ff._])


== The Index Page

#index[Index Page]

To actually create the index page, the `make-index()` function has to be called. Of course,
it can be embedded into an appropriately formatted #index[Formatting]
environment#index[Environment], like this:

```typ
    #columns(3)[
        #make-index()
    ]
```


= Why Having an Index in Times of Search Functionality?
#index(fmt: strong, [Searching vs. Index])

A _hand-picked_#index[Hand Picked] or _handcrafted_#index[Handcrafted] Index in times of
search functionality#index[Search Functionality] seems a bit
old-fashioned#index[Old-fashioned] at the first glance. But such an index allows the
author to direct the reader, who is looking for a specific topic#index-main("Topic",
"specific") (using index-main ), to exactly the right places.

Especially in larger documents#index[Large Documents] and books#index[Books] this becomes
very useful, since search engines#index[Search Engines] may provide#index[Provide] too
many locations of specific words. The index#index[Index] is much more
comprehensive,#index[Comprehensive] assuming that the author#index[Authors responsibility]
has its content#index[Content] selected well. Authors know best where a certain
topic#index("Topic", "certain") is explained#index[Explained] thoroughly#index[Thoroughly]
or merely noteworthy #index[Noteworthy] mentioned (using the `index` function).

Note, that this document is not necessarily a good example of the index. Here we just need
to have as many index entries#index[Entries] as possible to
demonstrate#index-ff([Demonstrate]) (using a custom made `index-ff` function) the
functionality #index[Functionality] and have a properly#index[Properly] filled index at
the end.

Even for symbols like `(ρ)`.#index([$(rho)$], initial: (letter: "Symbols", sort-by: "#"))
Indexing should work for for any Unicode string like Cyrillic (Скороспелка#index(initial:
(letter: "С", sort-by: "Ss"), "Скороспелка")) or German
(Ölrückstoßabdämpfung).#index(initial: (letter: "Ö", sort-by: "Oo"),
"Ölrückstoßabdämpfung") - though we need to add initials `#index(initial: (letter: "С",
sort-by: "Ss"), "Скороспелка")` or `#index(initial: (letter: "Ö", sort-by: "Oo"),
"Ölrückstoßabdämpfung")`.

#line(length: 100%, stroke: .1pt + gray)

#pagebreak()


= Index

Here we generate the Index page in three columns:

#columns(3)[
    #make-index()
]
