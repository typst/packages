#import "global.typ": *

= Background

#lorem(45)


#todo([

In the background section you might give explanations which are necessary to read the remainder of the thesis.

For example define and/or explain the terms used. Optionally, you might provide a glossary (index of terms used with/without explanations).

#v(1cm)

*Hints for equations in Typst*:

The notation used for #textbf([calculating]) of #textit([code performance]) might typically look like the one in @slow and @veryslow, which demonstrates what *(very) slow*
algorithms mean.

$ O(n) = n^2 $ <slow>

$ O(n) = 2^n $ <veryslow>


*Hints for footnotes in Typst*:

As shown in #footnote[Visit https://typst.app/docs for more details on formatting the document using typst. Note, _typst_ is written in the *Rust* programming language.] we migth discuss the alternatives.


*Hints for formatting in Typst*:

+ You can use built-in styles:
  + with underscore (\_) to _emphasise_ text
  + forward dash (\`) for `monospaced` text
  + asterisk (\*) for *strong* (bold) text

You can create and use your own (custom) formatting macros:

+ check out the custom style (see in file `lib.typ`):
  + `\#textit` for #textit([italic]) text
  + `\#textbf` for #textbf([bold face]) text


])
