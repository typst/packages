#import "@preview/codelst:1.0.0": sourcecode
#import "template.typ": *
#import "../chic-hdr.typ": *

#show link: it => text(blue, it)

#show:document-props

#title-page()

#pagebreak()

= Introduction

Chic-header (chic-hdr) is a Typst package for creating elegant headers and footers, similar as `fancyhdr` for LaTeX users.

Currently, chic-hdr is still on development, and all the code can be found at its GitHub repository #link("https://github.com/Pablo-Gonzalez-Calderon/chic-header-package", "here"). New features are welcome. So, if you have an idea that would improve this package, go on and send us the code as a Pull Request.

= Usage

To use this package through the Typst package manager (for Typst 0.6.0 or greater), write #line-raw(code: false, "#import \"@preview/chic-hdr:" + chic-version + "\": *") at the beginning of your Typst file.

Once imported, you can start using the package by writing the instruction #line-raw(code: false, "#show: chic.with(...)"), giving the chic-functions inside the parenthesis `()`.

#observation()[
  From now on, the #line-raw("#show: chic.with(...)") function is going to (also) be called _main function,_ while other functions that start with `chic-` will be referred _auxiliary functions,_ or _style functions._
]

= Main function parameters

In version #chic-version, all the parameters that the #line-raw("chic()") function can receive are:

#chic-parameters()

The usage and possible values of all the parameters are detailed in the next subsections.

== Width #type-block("relative-length")

Indicates the width of both headers and footers in all the document.

Default is #line-raw("100%").

== Skip #type-block("array")

Which pages must be skipped for setting its header and footer. Other properties changed with #link(<chic-height-section>, line-raw("chic-height()")) or #link(<chic-offset-section>, line-raw("chic-offset()")) are preserved.

If you want to skip some of the last pages of your document, you can use negative indexes. For instance, #line-raw("skip: (-1, 1)") will skip both first and last pages header and footer.

Default is #line-raw("()") (empty array).

== Even #type-block("array-of-functions") #type-block("none") <even-section>

Array of auxiliary functions that will set the header and footer for even pages. Here only #link(<chic-header-section>, line-raw("chic-header()")), #link(<chic-footer-section>, line-raw("chic-footer()")) and #link(<chic-separator-section>, line-raw("chic-separator()")) auxiliary functions will take effect. Other auxiliary functions _must_ be given as an argument of the main function to take the desired effect.

If it's #type-block("none"), even pages will have their headers and footers with the style and content given at the main function (obviously, if they have been given).

Default is #line-raw("none").

== Odd #type-block("array-of-functions") #type-block("none") <odd-section>

Similarly with #link(<even-section>, `even`) parameter, it can be an array of auxiliary functions that sets the header and footer for odd pages. Here only #link(<chic-header-section>, line-raw("chic-header()")), #link(<chic-footer-section>, line-raw("chic-footer()")) and #link(<chic-separator-section>, line-raw("chic-separator()")) auxiliary functions will take effect. Other auxiliary functions _must_ be given as an argument of the main function to take the desired effect.

If it's #type-block("none"), odd pages will have their headers and footers with the style and content given at the main function (obviously, if they have been given).

Default is #line-raw("none").

== Auxiliary functions #type-block("chic-function")

These are a variable number of positional arguments that corresponds to any chic-hdr's auxiliary function. All those functions are listed in @auxiliary-functions

#heading(numbering: none, level: 2, "Example")

This example illustrates how to create a document without any header or footer on the first page, and with custom header and footer for even and odd pages.

#sourcecode(
```typst
#set page("a7")
#show: chic.with(
  skip: (1,),
  even: (
    chic-header(center-side: [*Even page header*]),
    chic-separator(1pt)
  ),
  odd: (
    chic-footer(left-side: [_Odd page's footer_]),
    chic-separator(stroke(dash: "dashed"))
  ),
  chic-height(1.5cm)
)

= Introduction

#lorem(70)

== Details

#lorem(50)
```
)

#example-box(("example-1/ex-1.png", "example-1/ex-2.png", "example-1/ex-3.png"))

= Auxiliary functions parameters <auxiliary-functions>

== #line-raw("chic-header()") <chic-header-section>

Sets the header content.

#chic-header-footer-parameters("header")

=== v-center #type-block("boolean")

Whether to vertically center `left-side`, `center-side`, and `right-side`. This is useful when any of them is higher than the others.

Default is #line-raw("false").

=== side-width #type-block("length") #type-block("relative-length") 3-item-#type-block("array")

Custom width for the different sides (left, center and right). If it's a #type-block("length") or #type-block("relative-length"), indicates the width of all three sides. Otherwise, if it's a 3-item-#type-block("array") of #type-block("length")s or #type-block("relative-length")s, the values at indexes #line-raw("0"), #line-raw("1"), and #line-raw("2") correspond to the width of `left-side`, `center-side`, and `right-side` respectively.

=== left-side, center-side, and right-side #type-block("string") #type-block("content")

Content displayed in the left, center, and/or right side of the header.

Default is #line-raw("none") (not present).

== #line-raw("chic-footer()") <chic-footer-section>

#chic-header-footer-parameters("footer")

=== v-center #type-block("boolean")

Whether to vertically center `left-side`, `center-side`, and `right-side`. This is useful when any of them is higher than the others.

Default is #line-raw("false").

=== side-width #type-block("length") #type-block("relative-length") 3-item-#type-block("array")

Custom width for the different sides (left, center and right). If it's a #type-block("length") or #type-block("relative-length"), indicates the width of all three sides. Otherwise, if it's a 3-item-#type-block("array") of #type-block("length")s or #type-block("relative-length")s, the values at indexes #line-raw("0"), #line-raw("1"), and #line-raw("2") correspond to the width of `left-side`, `center-side`, and `right-side` respectively.

=== left-side, center-side, and right-side #type-block("string") #type-block("content")

Content displayed in the left, center, and/or right side of the footer.

Default is #line-raw("none") (not present).

== #line-raw("chic-separator()") <chic-separator-section>

Sets the separator for either the header, footer or both.

#chic-separator-parameters()

Depending of the given value's type, it'll be a different behavior:

#list(marker: sym.bullet, indent: 1.25cm)[
  If a #type-block("length") is given, it will correspond to the thickness of a #line-raw("line()") used as the separator.
][
  If a #type-block("stroke") is given it corresponds to the stroke of a #line-raw("line()") used as the separator.
][
  If a #type-block("content") is given (e.g. an image), that element is used _directly_ as the separator.
]

Also, there're custom separators that have unique styles and can be used calling the #link(<chic-styled-separator-section>, line-raw("chic-styled-separator()")) auxiliary function.

#observation()[
  This function will _only_ take effect if the header or the footer are present. And also, if #link(<even-section>, `even`)  or #link(<odd-section>, `odd`)  options are set, their separators _must_ be set apart from the global one to appear in the document.
]

=== on #type-block("string")

Where to apply the separator. It can be #line-raw("\"header\""), #line-raw("\"footer\"") or #line-raw("\"both\"").

Default is #line-raw("\"both\"").

=== outset #type-block("relative-length")

Space around the separator beyond the page margins. It's applied in both directions (left and right).

Default is #line-raw("0pt").

=== gutter #type-block("relative-length")

How much spacing insert around the separator (above and below).

Default is #line-raw("0.65em").

== #line-raw("chic-styled-separator()") <chic-styled-separator-section>

Returns a pre-made custom separator for using in #link(<chic-separator-section>, line-raw("chic-separator()")) auxiliary function.

#chic-styled-separator-parameters()

#box(
  columns(2)[
    === color #type-block("color")

    Color for the separator.

    Default is #line-raw("black").

    === style #type-block("string")

    A string describing which separator to get. It can be #line-raw("\"double-line\""), #line-raw("\"bold-center\""), #line-raw("\"center-dot\""), or #line-raw("\"flower-end\"").

    Examples of these styles are shown at right.

    #colbreak()

    #align(center)[
      `double-line`

      #chic-styled-separator("double-line")

      `bold-center`

      #chic-styled-separator("bold-center")

      `center-dot`

      #chic-styled-separator("center-dot")

      `flower-end`

      #chic-styled-separator("flower-end")
    ]
  ]
)

#heading(numbering: none, level: 2, "Example")

#sourcecode(
```typst
#set page("a7")
#show: chic.with(
  chic-header(center-side: "Economy report"),
  chic-footer(center-side: text(gray, "Online version")),
  chic-separator(on: "header", chic-styled-separator("bold-center")),
  chic-separator(on: "footer", stroke(dash: "loosely-dashed", paint: gray)),
  chic-height(2cm)
)

= Introduction
#lorem(70)

== Details
#lorem(50)

= Conclusion
#lorem(30)
```)

#example-box(("example-2/ex-1.png", "example-2/ex-2.png", "example-2/ex-3.png"))

== #line-raw("chic-height()") <chic-height-section>

Sets the height of either the header, the footer or both.

#chic-height-parameters()

=== on #type-block("string")

Where to change the height. It can be #line-raw("\"header\""), #line-raw("\"footer\"") or #line-raw("\"both\"").

Default is #line-raw("\"both\"").

== #line-raw("chic-offset()") <chic-offset-section>

Sets the offset of either the header, the footer or both (relative to the page content).

#chic-offset-parameters()

=== on #type-block("string")

Where to change the offset. It can be #line-raw("\"header\""), #line-raw("\"footer\"") or #line-raw("\"both\"").

== #line-raw("chic-page-number()")

Returns the current page number. Useful for header and footer sides. It doesn't take any parameters.

== #line-raw("chic-heading-name()")

Returns the next heading name in the `dir` direction. The heading must have a lower or equal level than the `level` value. If there're no more headings in that direction, and `fill` is #line-raw("true"), then headings are sought in the other direction.

#chic-heading-name-parameters()

=== dir #type-block("string")

Direction for searching the next heading: #line-raw("\"next\"") (from the current page's start, get the next heading) or #line-raw("\"prev\"") (from the current page's start, get the previous heading).

Default is #line-raw("\"next\"").

=== fill #type-block("boolean")

If there's no more headings in the `dir` direction, indicates whether to try to get a heading in the opposite direction (#line-raw("true")) or not (#line-raw("false")).

Default is #line-raw("false").

=== level #type-block("integer")

Up to what level of headings should this function search.

Default is #line-raw("2").

#observation()[
  Chic-hdr package also supports working with #link("https://github.com/tingerrr/hydra", "Hydra package"), so instead of using #line-raw("chic-heading-name()") auxiliary function you can give it a try to Hydra for fetching heading names ;).
]

#heading(level: 2, numbering: none, "Example")

#sourcecode(
```typst
#set page("a7")
#show: chic.with(
  chic-header(
    left-side: smallcaps("Thesis"),
    right-side: emph(chic-heading-name())
  ),
  chic-footer(
    center-side: "Page " + chic-page-number()
  ),
  chic-separator(1pt),
  chic-offset(40%),
  chic-height(2cm)
)

= Introduction

#lorem(70)

== Details

#lorem(50)

= Conclusion

#lorem(30)```
)

#example-box(("example-3/ex-1.png", "example-3/ex-2.png", "example-3/ex-3.png"))