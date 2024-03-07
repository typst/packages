#import "@local/mantys:0.0.3": *

#import "codelst.typ"

#show: mantys.with(
    name:       "codelst",
    title:      "The codelst Package",
    subtitle:   [A *Typst* package to render source code],
    authors:    "Jonas Neugebauer",
    url:        "https://github.com/jneug/typst-codelst",
    version:    "2.0.0",
    date:       "2023-07-19",
    abstract:   [
        #package[codelst] is a *Typst* package inspired by LaTeX packages like #package[listings]. It adds functionality to render source code with line numbers, highlighted lines and more.
    ],

    examples-scope: (
      codelst: codelst,
      sourcecode: codelst.sourcecode,
      sourcefile: codelst.sourcefile,
      code-frame: codelst.code-frame,
      lineref: codelst.lineref,
    )
)

#let footlink( url, label ) = [#link(url, label)#footnote(link(url))]
#let gitlink( repo ) = footlink("https://github.com/" + repo, repo)

// End preamble

= About

This package was created to render source code on my exercise sheets for my computer science classes. The exercises required source code to be set with line numbers that could be referenced from other parts of the document, to highlight certain lines and to load code from external files into my documents.

Since I used LaTeX before, I got inspired by packages like #footlink("https://ctan.org/package/listings", package("listings")) and attempted to replicate some of its functionality. CODELST is the result of this effort.

This document is a full description of all available commands and options. The first part provides examples of the major features. The second part is a command reference for CODELST.

See `example.typ`/`example.pdf` for some quick examples how to use CODELST.

= Usage

== Use as a package (Typst 0.9.0 and later)

For Typst 0.9.0 and later, CODELST can be imported from the preview repository:
#sourcecode(numbering:none)[```typ
#import "@preview/codelst:2.0.0": sourcecode
```]

Alternatively, the package can be downloaded and saved into the system dependent local package repository.

Either download the current release from GitHub#footnote[#link("https://github.com/jneug/typst-codelst/releases/latest")] and unpack the archive into your system dependent local repository folder#footnote[#link("https://github.com/typst/packages#local-packages")] or clone it directly:
#codesnippet[
```shell-unix-generic
git clone https://github.com/jneug/typst-codelst.git codelst-2.0.0
```]

In either case, make sure the files are placed in a folder with the correct version number: `codelst-2.0.0`

After installing the package, just import it inside your `typ` file:
#codesnippet[```typ
#import "@local/codelst:2.0.0": sourcecode
```]

== Use as a module

To use CODELST as a module for one project, get the file `codelst.typ` from the repository and save it in your project folder.

Import the module as usual:
#codesnippet[```typ
#import "codelst.typ": sourcecode
```]

== Rendering source code

CODELST adds the #cmd[sourcecode] command with various options to render code blocks. It wraps around any #cmd-[raw] block to adds some functionality and formatting options to it:

#example[````
#sourcecode[```typ
  #show "ArtosFlow": name => box[
    #box(image(
      "logo.svg",
      height: 0.7em,
    ))
    #name
  ]

  This report is embedded in the
  ArtosFlow project. ArtosFlow is a
  project of the Artos Institute.
```]
````]

CODELST adds line numbers and some default formatting to the code. Line numbers can be configured with a variety of options and #arg[frame] sets a custom wrapper function for the code. Setting #arg(frame: none) disables the code frame.

#example[````
#sourcecode(
    numbers-side: right,
    numbering: "I",
    numbers-start: 10,
    numbers-first: 11,
    numbers-step: 4,
    numbers-style: (i) => align(right, text(fill:blue, emph(i))),
    frame: none
)[```typ
#show "ArtosFlow": name => box[
  #box(image(
    "logo.svg",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```]
````]

Since it is common to highlight code blocks by putting them inside a #cmd-[block] element, CODELST does so with a light gray background and a border.

The frame can be modified by setting #arg[frame] to a function with one argument. To do this globally, an alias for the #cmd-[sourcecode] command can be created:

#example[````
#let codelst-sourcecode = sourcecode
#let sourcecode = codelst-sourcecode.with(
  frame: block.with(
    fill: fuchsia.lighten(96%),
    stroke: 1pt + fuchsia,
    radius: 2pt,
    inset: (x: 10pt, y: 5pt)
  )
)

#sourcecode[```typ
#show "ArtosFlow": name => box[
  #box(image(
    "logo.svg",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```]
````]

Line numbers can be formatted with the #opt[numbers-style] option:

#example[````
#sourcecode(
  gutter:2em,
  numbers-style: (lno) => text(fill:luma(120), size:10pt, emph(lno) + sym.arrow.r)
)[```typ
#show "ArtosFlow": name => box[
  #box(image(
    "logo.svg",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```]
````]

CODELST handles whitespace in the code to save space and display the code as intended (and indented). Unnecessary blank lines at the beginning and end will be removed, alongside superfluous indention:

#example[````
#sourcecode[```java

    class HelloWorld {
      public static void main( String[] args ) {
        System.out.println("Hello World!");
      }
    }


```]
````]

This behavior can be disabled or modified:

#example[````
#sourcecode(showlines:true, gobble:1, tab-size:4)[```java

		class HelloWorld {
			public static void main( String[] args ) {
				System.out.println("Hello World!");
			}
		}


```]
````]

To show code from a file, load it with #cmd[read] and pass the result to #cmd[sourcefile] alongside the filename:

#example(raw("#sourcefile(read(\"typst.toml\"), file:\"typst.toml\")"))[
	#codelst.sourcefile(read("typst.toml"), file:"typst.toml")
]

It is useful to define an alias for #cmd-[sourcefile]:
#codesnippet[```typc
let codelst-sourcefile = sourcefile
let sourcefile( filename, ..args ) = codelst-sourcefile(
  read(filename), file:filename, ..args
)
```]

#cmd-[sourcefile] takes the same arguments as #cmd-[sourcecode]. For example, to limit the output to a range of lines:

#example[```
#sourcefile(
  showrange: (2, 4),
  read("typst.toml"),
	file:"typst.toml"
)
```][
#codelst.sourcefile(
  showrange: (2, 4),
  read("typst.toml"),
	file:"typst.toml"
)
]

Specific lines can be highlighted:

#example[```
#sourcefile(
  highlighted: (2, 3, 4),
  read("typst.toml"),
	file:"typst.toml"
)
```][
#codelst.sourcefile(
  highlighted: (2, 3, 4, 8, 9),
  read("typst.toml"),
	file:"typst.toml"
)
]

To reference a line from other parts of the document, CODELST looks for labels in the source code and makes them available to Typst. The regex to look for labels can be modified to be compatible with different source syntaxes:

#example[```
#sourcefile(
  label-regex: regex("\"(codelst.typ)\""),
  highlight-labels: true,
  highlight-color: lime,
  read("typst.toml"),
  file:"typst.toml"
)

See #lineref(<codelst.typ>) for the _entrypoint_.

```][
#codelst.sourcefile(
  label-regex: regex("\"(codelst.typ)\""),
  highlight-labels: true,
  highlight-color: lime,
  read("typst.toml"),
	file:"typst.toml"
)

See line 4 for the _entrypoint_. (Note how the label was removed from the sourcecode before highlighting.)
]

== Formatting

#cmd-[sourcecode] can be used inside #cmd[figure] and will show the correct supplement. It is recommended to allow page breaks for `raw` figures:
#sourcecode[```typ
#show figure.where(kind: raw): set block(breakable: true)
```]

Instead of the build in styles, custom functions can be used:
#example(```typ
#sourcecode(
  numbers-style: (lno) => text(
    size: 2em,
    fill:rgb(220, 65, 241),
    font:("Comic Sans MS"),
    str(lno)
  ),
  frame: (code) => block(
    width:100%,
    inset:(x:10%, y:0pt),
    block(fill: green, width:100%, code)
), raw("*some*
_source_
= code", lang:"typc"))
```)

Using other packages like #package[showybox] is easy:
#example[````
#import "@preview/showybox:2.0.1": showybox

#let showycode = sourcecode.with(
  frame: (code) => showybox(
    frame: (
      title-color: red.darken(40%),
      body-color: red.lighten(90%),
      border-color: black,
      thickness: 2pt
    ),
    title: "Source code",
    code
  )
)

#showycode[```typ
*some*
_source_
= code
```]
````]

This is nice in combination with figures:

#example[````
#import "@preview/showybox:2.0.1": showybox

#show figure.where(kind: raw): (fig) => showybox(
  frame: (
    title-color: red.darken(40%),
    body-color: red.lighten(90%),
    border-color: black,
    thickness: 2pt
  ),
  title: [#fig.caption.body #h(1fr) #fig.supplement #fig.counter.display()],
  fig.body
)

#figure(
  sourcecode(frame: none)[```typ
    *some*
    _source_
    = code
  ```],
  caption: "Some code"
)
````]

=== Using CODELST for all raw text <sec-catchall>

#ibox[
  Since Typst 0.9.0 using a #var-[show] rule should become possible, but not yet fully implemented in CODELST.
]

Using a #var-[show] rule to set all #cmd-[raw] blocks inside #cmd-[sourcecode] is not possible, since the command internally creates a new #cmd-[raw] block and would cause Typst to crash with an overflow error. Using a custom #arg[lang] can work around this, though:

#example[````
#show raw.where(lang: "clst-typ"): (code) => sourcecode(lang:"typ", code)

```clst-typ
*some*
_source_
= code
```
````][
#show raw.where(lang: "clst-typ"): (code) => codelst.sourcecode(lang:"typ", code)

```clst-typ
*some*
_source_
= code
```]

CODELST provides two ways to get around this issue, however. One is to set up a custom language that is directly followed by a colon and the true language tag:

#sourcecode[```codelst:typ
*some*
_source_
= code
```]

This is a robust way to send anything to CODELST. But since this might prevent proper syntax highlighting in IDEs, a reversed syntax is possible:

#sourcecode[```typ:codelst
*some*
_source_
= code
```]

This will look at the first line of every `raw` text and if it matches `:codelst`, it will remove the activation tag and send the code to #cmd-[sourcecode].

Setting up one of these catchall methods is easily done by using the #cmd[codelst] function in a #var-[show] rule. Any arguments will be passed on to #cmd-[sourcecode]:

#sourcecode[```typ
#show: codelst( ..sourcecode-args )

// or

#show: codelst( reversed: true, ..sourcecode-args )
```]

== Command overview

#command("sourcecode", ..args(
    lang: auto,

    numbering: "1",
    numbers-start: auto,
    numbers-side: left,
    numbers-width: auto,
    numbers-style: "function",
    numbers-first: 1,
    numbers-step: 1,
    // continue-numbering: false,

    gutter: 10pt,

    tab-indent: 2,
    gobble: auto,

    highlighted: (),
    highlight-color: rgb(234, 234,189),
    label-regex: regex("// <([a-z-]{3,})>$"),
    highlight-labels: false,

    showrange: none,
    showlines: false,

    frame: "code-frame",
    [code]))[

    #argument("numbering", types:("string", "function", none), default:"1")[
        A #doc("meta/numbering", name:"numbering pattern") to use for line numbers. Set to #value(none) to disable line numbers.
    ]

    #argument("numbers-start", types:(1,auto), default: auto)[
        The number of the first code line. If set to #value(auto), the first line will be set to the start of #arg[showrange] or #value(1) otherwise.
    ]

    #argument("numbers-side", default:choices(left, right, default:left), types:"alignment")[
        On which side of the code the line numbers should appear.
    ]

    #argument("numbers-width", types:(auto, 1pt), default:auto)[
        The width of the line numbers column. Setting this to #value(auto) will measure the maximum size of the line numbers and size the column accordingly. Giving a negative length will move the numbers out of the frame into the margin.
    ]

    #argument("numbers-first", default:1)[
      The first line number to show. Compared to #arg[numbers-start], this will not change the numbers but hide all numbers before the given number.
    ]

    #argument("numbers-step", default:1)[
      The step size for line numbers.
      For #arg[numbers-step]: $n$ only every $n$-th line number is shown.
    ]

    #argument("numbers-style", default:"(i) => i", types:"function")[
        A function of one argument to format the line numbers. Should return #dtype[content].
    ]

    // #argument("continue-numbering", default:false)[
    //   If set to #value(true), the line numbers will continue from the last call of #cmd-[sourcecode].
    // ]
    // #side-by-side[````
    //   #sourcecode[```
    //     one
    //     two
    //   ```]
    //   #lorem(10)
    //   #sourcecode(continue-numbering: true)[```
    //     three
    //     four
    //   ```]
    // ````]

    #argument("gutter", default:10pt)[
        Gutter between line numbers and code lines.
    ]

    #argument("tab-indent", default:2)[
        Number of spaces to replace tabs at the start of each line with.
    ]

    #argument("gobble", default:auto, types:(auto, "integer", "boolean"))[
        How many whitespace characters to remove from each line. By default, the number is automatically determined by finding the maximum number of whitespace all lines have in common. If #arg(gobble: false), no whitespace is removed.
    ]

    #argument("highlighted", default:())[
        Line numbers to highlight.

        Note that the numbers will respect #arg[numbers-start]. To highlight the second line with #arg(numbers-start: 15), pass #arg(highlighted: (17,))
    ]

    #argument("highlight-color", default:rgb(234, 234,189))[
        Color for highlighting lines.
    ]

    #argument("label-regex", types:"regular expression")[
      A #dtype("regular expression") for matching labels in the source code. The default value will match labels with at least three characters at the end of lines, separated with a line comment (`//`). For example:

      ```typ
      #strong[Some text] // <my-line-label>
      ```

      If this line matches on a line, the full match will be removed from the output and the content of the first capture group will be used as the label's name (`my-line-label` in the example above).

      Note that to be valid, the expression needs to have at least one capture group.

      To reference a line, #cmd[lineref] should be used.
    ]

    #argument("highlight-labels", default:false)[
      If set to #value(true), lines matching #arg[label-regex] will be highlighted.
    ]

    #argument("showrange", default:none, types:(none,"array"))[
      If set to an array with exactly two #dtype("integer")s, the code-lines will be sliced to show only the lines within that range.

      For example, #arg(showrange: (5, 10)) will only show the lines 5 to 10.

      If settings this and #arg(numbers-start: auto), the line numbers will start at the number indicated by the first number in #arg[showrange]. Otherwise, the numbering will start as specified with #arg[numbers-start].
    ]

    #argument("showlines", default:false)[
      If set to #value(true), no blank lines will be stripped from the start and end of the code. Otherwise, those lines will be removed from the output.

      Line numbering will not be adjusted to the removed lines (other than with #arg[showrange]).
    ]

    #argument("frame", types:"function", default:"code-frame")[
      A function of one argument to frame the source code. The default is #cmd[code-frame]. #value(none) disables any frame.
    ]
]

#command("sourcefile", arg[code], arg(file: none), arg(lang: auto), sarg[args])[
    Takes a text string #arg[code] loaded via the #cmd[read] function and passes it to #cmd-[sourcecode] for display. If #arg[file] is given, the code language is guessed by the file's extension. Otherwise, #arg[lang] can be provided explicitly.

	  Any other #arg[args] will be passed to #cmd-[sourcecode].

    #example(raw("#sourcefile(read(\"typst.toml\"), file:\"typst.toml\")"))[
		#codelst.sourcefile(read("typst.toml"), lang:"toml")
	]

	#ibox[
		The idea for #cmd-[sourcefile] was to read the provided filename without the need for the user to call #cmd-[read]. Due to the security measure, that packages can only read files from their own directory, the call to #cmd-[read] needs to happen outside #cmd-[sourcefile] in the document.

		For this reason, the command differs from #cmd-[sourcecode] only insofar as it accepts a #dtype("string") instead of `raw` #dtype("content").

		Future releases might use the #arg[filename] for other purposes, though.

    To deal with this, simply add the following code to the top of your document to define a local alias for #cmd-[sourcefile]:

    ```typ
    #let codelst-sourcefile = sourcefile
    #let sourcefile( filename, ..args ) = codelst-sourcefile(read(filename), file:filename, ..args)
    ```
	]
]

#command("lineref", arg[label], arg(supplement: "line"))[
  Creates a reference to a code line with a label. #arg[label] is the label to reference.

  #example[````
  #sourcecode[```java
  class HelloWorld {
    public static void main( String[] args ) { // <main-method>
      System.out.println("Hello World!");
    }
  }
  ```]

  See #lineref(<main-method>) for a main method in Java.
  ````][
      #codelst.sourcecode[```java
      class HelloWorld {
        public static void main( String[] args ) { // <main-method>
          System.out.println("Hello World!");
        }
      }
      ```]

      See line 2 for a main method in Java.
  ]

  How to set labels for lines, refer to the documentation of #arg[label-regex] at #refcmd("sourcecode").
]

#command("code-frame", ..args(
  fill: luma(250),
  stroke: 1pt + luma(200),
  inset: (x: 5pt, y: 10pt),
  radius: 4pt,
  [code]
))[
  Convenience function to create a #cmd-[block] to wrap code inside. The arguments are passed to #doc("layout/block").

  The default values create the default gray box around source code.

  Should be used with the #arg[frame] argument in #cmd-[sourcecode].

  #example[```
  #code-frame(lorem(20))
  ```]

  #example[````
  #sourcecode(
    frame: code-frame.with(
      fill:   green.lighten(90%),
      stroke: green
    )
  )[```typc
  lorem(20)
  ```]
  ````]
]

#command("codelst", ..args(
  tag: "codelst",
  reversed: false
), sarg[sourcecode-args])[
  Sets up a default style for raw blocks. Read @sec-catchall for details on how it works.

  #sourcecode[```typ
  #show: codelst()
  ```]
]

= Limiations and alternatvies

== Limitations and Issues

To lay out the code and line numbers correctly, CODELST needs to know the available space before calculating the correct sizes. This will lead to problems when changing the layout of the code later on, for example with a #var-[show] rule.

The way line numbers are laid out, the alignment might drift off for large code blocks. Page breaks are a major cause for this. If applicable, it can help to split large blocks of code into smaller chunks, for example by using #arg[showrange].

The insets for line highlights are slightly off.

== Alternatives

There are some alternatives to CODELST that fill similar purposes, but have more or other functionality. If CODELST does not suit your needs, one of those might do the trick.

/ #gitlink("platformer/typst-algorithms"): _Typst module for writing algorithms. Use the algo function for writing pseudocode and the code function for writing code blocks with line numbers._
/ #gitlink("hugo-s29/typst-algo"): _This package helps you typeset [pseudo] algorithms in Typst._

