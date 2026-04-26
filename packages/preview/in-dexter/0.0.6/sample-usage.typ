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
    #text(size: 12pt)[Version 0.0.6 (30. September 2023)]
    #linebreak() #v(.5em)
    #text(size: 10pt)[Rolf Bremer, Jutta Klebe]
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
    #import "@preview/in-dexter:0.0.6": *
```

Note, that the version number of the typst package has to be adapted to get the wanted
version.


== Marking of Entries

We have marked several words to be included in an index page at the end of the document.
#index[Sample] The markup for the entry stays invisible#index[Invisible]. Its location in
the text gets recorded, and later it is shown as a page reference in the index page.
#index[Index Page]

```typ
    #index[The Entry Phrase]
```


=== Marker Classes

#index(class: classes.main)[Classes]
#index(class: classes.main)[Marker Classes]

The entries support a class. This class determines the
visualization for the page number of the entry. Currently, we distinguish between class
"simple" #index[Simple] and class "main" #index[Main]. The first one is the default. The
second is provided to mark the main reference for that entry -- its page number will be
printed in *bold*.

```typ
    #index(class: classes.main)[The Entry Phrase]
```

In future versions of this package there may be more marker classes for additional cases.
It is recommended to use the `classes` definition of the package.

- `classes.simple`
- `classes.main`


==== More Convenience

There is also a convenience #index-main[Convenience] function, to ease the usage of main
entries. Instead of the main entry syntax used above, one can use the following:

```typ
    #index-main[The Entry Phrase]
```


#pagebreak()


== The Index Page

#index(class: classes.main)[Index Page]

To actually create the index page, the `make-index()` function has to be called. Of course,
it can be embedded into an appropriately formatted #index[Formatting]
environment#index[Environment], like this:

```typ
    #columns(3)[
        #make-index()
    ]
```


= Why Having an Index in Times of Search Functionality?

#index(class: classes.main)[Searching vs. Index]

A _hand-picked_ #index[Hand Picked] or _handcrafted_ #index[Handcrafted] Index in times of
search functionality #index[Search Functionality] seems a bit old-fashioned
#index[Old-fashioned] at the first glance. But such an index allows the author to direct
the reader, who is looking for a specific topic#index[Topic], to exactly the right
places. Especially in larger documents #index[Large Documents] and books #index[Books]
this becomes very useful, since search engines #index[Search Engines] may provide
#index[Provide] too many locations of specific words. The index #index[Index] is much more
comprehensive#index[Comprehensive], assuming that the author #index[Authors
responsibility] has its content #index[Content] selected well. Authors know best where a
specific topic is explained #index[Explained] thoroughly #index[Thoroughly] (using the
`index-main` function to point there) or merely noteworthy #index[Noteworthy] mentioned
(using the `index` function). Note, that this document is not necessarily a good example
of the index. Here we just need to have as many index entries #index[Entries] as possible
to demonstrate #index-main[Demonstrate] the functionality #index[Functionality] and have a
properly #index[Properly] filled index at the end.

#line(length: 100%, stroke: .1pt + gray)

= Index

Here we generate the Index page in three columns:

#columns(3)[
    #make-index()
]
