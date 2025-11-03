# Agregyst

Typst Template for writing a lesson presentation for the "concours de l'agrégation".


Here a very basic example
```typ
#import "@preview/agregyst:0.1.0" : tableau, dev, recap, item
#import "@preview/cetz:0.3.4" : *
#show : tableau

= Title of the lesson

#pagebreak()
== First Part

// Definition of a graph
#item("Définition")[A Graph][
    is
]

#pagebreak()
== Second Part

#pagebreak()
== Third Part


#recap()

#bibliography(bytes(```yaml
SIP:
  type : Book
  title: Introduction to the Theory of Computation
  author: Michael Sipser
NAN:
  type: Book
  title: NAN
  author: NAN
```))
```

More complete example with a full recap :

```typ
#import "../tableau.typ" : tableau, dev, recap, item
#import "@preview/cetz:0.3.4" : *
#show : content => tableau(content, nb_columns : 2)

#set text(lang: "eng")

= Management and Coordination of multiple execution thread @MOS

/ Goals: Understand how multithreading and multiprocess applications are build and how they work on top of the operating system. 

== Process @MOS[2.1.1]
#item("Definition")[A process][
  is an instance of an executing program, including the current values of the program counter, registers, and variables. It also has an address space an thread of execution associated to it.
]

#item("Definition")[The memory of a process][
  is divided into four parts :
  - the *data* segment that stores global variable
  - the *text* segment for the code of the program
  - the *stack* which is used for static allocation (like local variable)
  - the *heap* where dynamic allocated memory lives.
]

#item("Definition")[Multiprogramming.][
  If multiple processes are present on an operating system the OS can switch back and forth from one to an other for execution. This is called multiprogramming.
]

#item("Example")[][
  Multiprogramming four programs.
  Conceptual model of four independant processes.
  Only one program is active at once.
  #align(center, image("multiprogramming_interleaving.png", width: 330pt))
]

// ...
```

<!-- <picture> -->
<!--   <source media="(prefers-color-scheme: dark)" srcset="example-dark.png"> -->
<!--   <img alt="Example output" src="example-light.png"> -->
<!-- </picture> -->
![](thumbnail/thumbnail.png)


## Limitations
- bibliography is yaml only
- the format is made for 3 pages and no more. The final Recap will not work for
  more than 3 pages.
- adding the recap will add the warning that typst is using more than 5 passes

