#import "@local/mantys:0.0.2": *

#show: mantys.with(
    name:       "codelst",
    title:      "The codelst Package",
    subtitle:   [A *Typst* package to render source code],
    authors:    "Jonas Neugebauer",
    url:        "https://github.com/jneug/typst-codelst",
    version:    "0.0.3",
    date:       "2023-07-19",
    abstract:   [
        #pkg[codelst] is a *Typst* package inspired by LaTeX package like #pkg[listings]. It adds functionality to render source code with line numbers, highlighted lines and more.
    ],
    example-imports: ("@local/codelst:0.0.3": "*")
)

#import "codelst.typ"

#let footlink( url, label ) = [#link(url, label)#footnote(link(url))]
#let gitlink( repo ) = footlink("https://github.com/" + repo, repo)

// End preamble

= About

This package was created to render source code on my exercise sheets for my computer science classes. The exercises required source code to be set with line numbers that could be referenced from other parts of the document, to highlight certain lines and to load code from files into my documents.

Since I used LaTeX before, I got inspired by packages like #footlink("https://ctan.org/pkg/listings", pkg("listings")) and attempted to replicate some of its functionality. CODELST is the result of this effort.

= Usage

== Use as a package (Typst 0.6.0 and later)

For Typst 0.6.0 and later CODELST can be imported from the preview repository:

#sourcecode(linenos: false)[```typ
#import "@preview/codelst:0.0.3": sourcecode
```]

Alternatively, the package can be downloaded and saved into the system dependent local package repository.

Either download the current release from GitHub#footnote[#link("https://github.com/jneug/typst-codelst/releases/latest")] and unpack the archive into your system dependent local repository folder#footnote[#link("https://github.com/typst/packages#local-packages")] or clone it directly:

#sourcecode(linenos: false)[
```shell-unix-generic
git clone https://github.com/jneug/typst-codelst.git codelst-0.0.3
```]

In either case, make sure the files are placed in a folder with the correct version number: `codelst-0.0.3`

After installing the package, just import it inside your `typ` file:

#sourcecode(linenos: false)[```typ
#import "@local/codelst:0.0.3": sourcecode
```]

== Use as a module

To use CODELST as a module for one project, get the file `codelst.typ` from the repository and save it in your project folder.

Import the module as usual:
#sourcecode(linenos: false)[```typ
#import "codelst.typ": sourcecode
```]

== Rendering source code

CODELST adds the #cmd[sourcecode] command with various options to render code blocks. It wraps around any #cmd-[raw] block to add some functionality and formatting options to it:

#example(raw("#sourcecode[```typ
#show \"ArtosFlow\": name => box[
  #box(image(
    \"logo.svg\",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```]"))

Line numbers are added to the output, but not much more. CODELST refrains from adding formatting to allow easy integration in templates. On the other hand, the package gives some easy ways to change the output of the source code.

Line numbers can be formatted in different ways:

#example(raw("#sourcecode(
    numbers-side: right,
    numbers-format: \"I\",
    numbers-start: 10,
    numbers-style: (i) => align(right, text(fill:blue, emph(i))),
)[```typ
#show \"ArtosFlow\": name => box[
  #box(image(
    \"logo.svg\",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```]"))

It is common to highlight code blocks by putting them inside a #cmd-[block] element. This can be done individually or for all source code with a #var-[show] rule:

#example(raw("#show <codelst>: (code) => block(fill:luma(245), stroke:1pt+luma(120), radius: 4pt, inset:(x:10pt, y: 5pt), code)

#sourcecode[```typ
#show \"ArtosFlow\": name => box[
  #box(image(
    \"logo.svg\",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```]"))

Line numbers can be formatted globally in a similar way:

#example(raw("#show <lineno>: (no) => no.counter.display((n, ..args) => text(fill:luma(120), size:10pt, emph(str(n)) + sym.arrow.r))

#sourcecode(gutter:2em)[```typ
#show \"ArtosFlow\": name => box[
  #box(image(
    \"logo.svg\",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```]"))

CODELST handles whitespace in the code to save space and view the code as intended (and indented), even if tabs are used:

#example(raw("#sourcecode[```java
class HelloWorld {
    public static void main( String[] args ) {
        System.out.println(\"Hello World!\");
    }
}
```]"))

Unnecessary blank lines at the beginning and end will be removed, alongside superfluous indention:

#example(raw("#sourcecode[```java

        class HelloWorld {
            public static void main( String[] args ) {
                System.out.println(\"Hello World!\");
            }
        }


```]"))[#codelst.sourcecode[```java

class HelloWorld {
    public static void main( String[] args ) {
        System.out.println("Hello World!");
    }
}


```]]

This behavior can be disabled or modified:

#example(raw("#sourcecode(showlines:true, gobble:false)[```java

        class HelloWorld {
            public static void main( String[] args ) {
                System.out.println(\"Hello World!\");
            }
        }


```]"))[#codelst.sourcecode(showlines:true, gobble:false, tab-indent:2)[```java

        class HelloWorld {
            public static void main( String[] args ) {
                System.out.println("Hello World!");
            }
        }


```]]

To show code from a file load it with #cmd[read] and pass the result to #cmd[sourcefile]:

#example(raw("#sourcefile(read(\"typst.toml\"), lang:\"toml\")"))[
	#codelst.sourcefile(read("typst.toml"), lang:"toml")
]

#cmd-[sourcefile] takes the same arguments as #cmd-[sourcecode]. For example, to limit the output to a range of lines:

#example(raw("#sourcefile(
    showrange: (2, 4),
    read(\"typst.toml\"),
	lang:\"toml\"
)"))[
#codelst.sourcefile(
    showrange: (2, 4),
    read("typst.toml"),
	lang:"toml"
)
]

Specific lines can be highlighted:

#example(raw("#sourcefile(
    highlighted: (2, 3, 4),
    read(\"typst.toml\"),
	lang:\"toml\"
)"))[
#codelst.sourcefile(
    highlighted: (2, 3, 4),
    read("typst.toml"),
	lang:"toml",
)
]

To reference a line from other parts of the document, CODELST looks for labels in the source code and makes them available to Typst. The regex to look for labels can be modified to accommodate different syntaxes:

#example(raw("#sourcefile(
    label-regex: regex(\"\\\"(codelst.typ)\\\"\"),
    highlight-labels: true,
    highlight-color: lime,
    read(\"typst.toml\"),
	lang:\"toml\"
)

See #lineref(<codelst.typ>) for the _entrypoint_."))[
#codelst.sourcefile(
    label-regex: regex("(codelst.typ)"),
    highlight-labels: true,
    highlight-color: lime,
    read("typst.toml"),
	lang:"toml"
)

See #codelst.lineref(<codelst.typ>) for the _entrypoint_.
]

== Formatting

As shown above, source code and line numbers can be formatted using #var-[show] rules.

#sourcecode(```typ
#show <lineno>: (i) => i.counter.display("I")
#show <codelst>: (code) => block(fill:luma(245), code)
```)

Though CODELST does not impose some default formatting by default, it provides the two commands #cmd[number-style] and #cmd[code-frame] to quickly apply some styling to source code:

#sourcecode(```typ
#show <lineno>: number-style
#show <codelst>: code-frame
```)
#ibox[Remember to import the commands first:
```typ
#import "@preview/codelst:0.0.3": sourcecode, number-style, code-frame
```]

If #cmd-[sourcecode] is used inside #cmd[figure], it is recommended to also allow page breaks for that kind of figure:
#sourcecode[```typ
#show figure.where(kind: raw): set block(breakable: true)
```]

To quickly apply these styles to a document, the #cmd[codelst-styles] command is provided as a shortcut:
#sourcecode(```typ
#show: codelst-styles
```)

Instead of the build in styles, custom functions can be used:
#example(```typ
#show <lineno>: (i) => i.counter.display(
    (n, ..args) => text(
        fill:rgb(220, 65, 241),
        font:("Comic Sans MS"),
        str(n)
    )
)
#show <codelst>: (code) => block(
    width:100%,
    inset:(x:10%, y:0pt),
    block(fill: green, width:100%, code)
)

#sourcecode(raw("*some*
_source_
= code", lang:"typc"))
```)

Note that the style function for line numbers receives the result of a call to #cmd-[counter.display]. The #doc("meta/counter") can be accessed via the `counter` attribute.

== Command overview

#command("sourcecode", ..args(line-numbers: true,
    numbers-format: "1",
    numbers-start: auto,
    numbers-side: left,
    numbers-style: (i) => i.counter.display((no, ..args) => raw(str(no))),
	continue-numbering: false,
    gutter: 10pt,
    tab-indent: 4,
    gobble: auto,
    highlighted: (),
    highlight-color: rgb(234, 234,189),
    label-regex: regex("// <([a-z-]{3,})>$"),
    highlight-labels: false,
    showrange: none,
    showlines: false,
    [code]))[

    #argument("line-numbers", default:true)[
        Set to #value(false) to disable line numbers.
    ]
    #argument("numbers-format", type:"string", default: "1")[
        The #doc("meta/numbering") format to use for line numbers.
    ]
    #argument("numbers-start", default: auto)[
        The number of the first code line. If set to #value(auto), the first line will be set to the start of #arg[showrange] or #value(1) otherwise.
    ]
    #argument("numbers-side", default:choices(left, right, default:left), type:"alignment")[
        On which side of the code the line numbers should appear.
    ]
    #argument("numbers-style", default:"(i) => i", type:"function")[
        A function of one argument to format the line numbers. Should return #dtype[content].
    ]
	#argument("continue-numbering", default:false)[
		If set to #value(true), the line numbers will continue from the last call of #cmd-[sourcecode].

		#example(raw("#sourcecode[```
one
two
```]
#lorem(10)
#sourcecode(continue-numbering: true)[```
three
four
```]
"))
	]
    #argument("gutter", default:10pt)[
        Gutter between line numbers and code lines.
    ]
    #argument("tab-indent", default:4)[
        Number of spaces to replace tabs at the start of each line with.
    ]
    #argument("gobble", default:auto, type:(auto, "integer", "boolean"))[
        How many whitespace characters to remove from each line. By default, the number is automatically determined by finding the maximum number of whitespace all lines have in common. If #arg(gobble: false), no whitespace is removed.
    ]
    #argument("highlighted", default:())[
        Line numbers to highlight.

        Note that the numbers will respect #arg[numbers-start]. To highlight the second line with #arg(numbers-start: 15), pass #arg(highlighted: (17,))
    ]
    #argument("highlight-color", default:rgb(234, 234,189))[
        Color for highlighting lines.
    ]
    #argument("label-regex", type:"regular expression")[
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
    #argument("showrange", default:none, type:(none,"array"))[
        If set to an array with exactly two #dtype("integer")s, the code-lines will be sliced to show only the lines within that range.

        For example, #arg(showrange: (5, 10)) will only show the lines 5 to 10.

        If settings this and #arg(numbers-start: auto), the line numbers will start at the number indicated by the first number in #arg[showrange]. Otherwise, the numbering will start as specified with #arg[numbers-start].
    ]
    #argument("showlines", default:false)[
        If set to #value(true), no blank lines will be stripped from the start and end of the code. Otherwise, those lines will be removed from the output.

        Line numbering will not be adjusted to the removed lines (other than with #arg[showrange]).
    ]
]

#command("sourcefile", arg[code], arg(filename: none), arg(lang: auto), sarg[args])[
    Takes a text string #arg[code] loaded via the #cmd[read] function and passes it to #cmd-[sourcecode] for display. If #arg[filename] is given, the code language is guessed by the file's extension. Otherwise, #arg[lang] can be provided explicitly.

	Any other #arg[args] will be passed to #cmd-[sourcecode].

    #example(raw("#sourcefile(read(\"typst.toml\"), lang:\"toml\")"))[
		#codelst.sourcefile(read("typst.toml"), lang:"toml")
	]

	#ibox[
		The original intend for #cmd-[sourcefile] was, to raed the provided filename, without the need for the user to call #cmd-[read]. Due to the security measure, that packages can only read files from their own directory, the call to #cmd-[read] needs to happen outside of #cmd-[sourcefile] in the document.

		For this reason, the command differs from #cmd-[sourcecode] only insofar as it accepts a #dtype("string") instead of `raw` #dtype("content").

		Future releases might use the #arg[filename] for other purposes, though.
	]
]

#command("lineref", arg[label], arg(supplement: "line"))[
    Creates a reference to a labeled line in the source code. #arg[label] is the label to reference.

    #example(raw("#sourcecode[```java
class HelloWorld {
	public static void main( String[] args ) { // <main-method>
		System.out.println(\"Hello World!\");
	}
}
```]

See #lineref(<main-method>) for a main method in Java."))

    How to set labels for lines, refer to the documentation of #arg[label-regex] at #refcmd("sourcecode").
]

#command("code-frame", ..args(fill:      luma(250),
    stroke:    1pt + luma(200),
    inset:     (x: 5pt, y: 10pt),
    radius:    4pt,
    [code]))[
    Applies the CODELST default styles to the document. Source code will be wrapped in #cmd[code-frame] and numbers styled with #cmd[numbers-style].


    #example(raw("#show <codelst>: code-frame.with(
	fill: gray,
	stroke: 2pt + lime,
	radius: 8pt
)
#sourcecode[```
some code
```]"))
]

#command("numbers-style", arg[no])[
    Applies the default CODELST style for line numbers. Can be used in a #var-[show] rule or as a value to #arg[numbers-style].

    #example[```typ
    #for i in range(3,6) [
        - #numbers-style([#i])
    ]
    ```]
]

#command("codelst-styles", barg[body])[
    Applies the CODELST default styles to the document. Source code will be wrapped in #cmd[code-frame] and numbers styled with #cmd[numbers-style].


    #sourcecode[```typ
    #show: codelst-styles
    ```]
]

= Limiations and alternatvies

== How it works

CODELST renders the code lines in a #cmd-[table] and not as a block. This might lead to problems in certain PDF viewers, when selecting the code for copy&paste, since some viewers select tables row-by-row and not columns first.

Furthermore, since the code is split into individual lines and each line is rendered as its own #cmd-[raw] block, sometimes the syntax highlighting will not work correctly. This hopefully will be fixed in future releases.

== Alternatives

There are some alternatives to CODELST that fill similar purposes, but have more or other functionality. If CODELST does not suit your needs, one of those might do the trick.

/ #gitlink("platformer/typst-algorithms"): _Typst module for writing algorithms. Use the algo function for writing pseudocode and the code function for writing code blocks with line numbers._
/ #gitlink("hugo-s29/typst-algo"): _This package helps you typeset [pseudo] algorithms in Typst._

