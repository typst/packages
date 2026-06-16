#import  "style.typ": proposition-sheet, chap

#show: proposition-sheet

// load metadata from thesis. This assumes this repository is a submodule/subdirectory
// of the thesis. If not found; you can manually define it below
#let metadata = toml("../metadata.toml")
#set document(
    title: metadata.title,
    author: metadata.author.join(" "),
    keywords: metadata.keywords
)


// boilerplate

#align(center)[
=== Propositions

Accompanying the dissertation

= #text(hyphenate: false, metadata.title)

#v(0.15cm)
#text(size:11pt)[by *#metadata.author*]
]

// actual propositions

#v(0.15cm)
//#line(length: 100%, stroke: 0.5pt)

// thesis related

+ #lorem(44) #chap[Chapter 1]

+ #lorem(36) #chap[Chapter 2]

// other

+ #lorem(55)

+ #lorem(23)

// footer

#line(length: 100%, stroke: 0.5pt)


#set align(center) 
These propositions are regarded as opposable and defendable,
and have been approved as such by the #panic(add your promotors and remove this panic function)
