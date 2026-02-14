#import "@preview/gentle-clues:1.3.0": *

#heading(outlined: true, bookmarked: true, numbering: none)[Index] 

An index is created by adding index keys to the text at the respective pages, e.g. using `#index[key]` where `key` is the word that will show up in the index along with the pages where it was referenced. To include the index you add code similar to the following one.

#warning[You'll need to import the respective package in every file that makes use of it ...]



```
#heading(outlined: false, bookmarked: true, numbering: none)[Index] 
#import "@preview/in-dexter:0.7.2": *
#columns(3)[
  #make-index(title: none)
]

```

#import "@preview/in-dexter:0.7.2": *

#columns(3)[
  #make-index(title: none)
]


