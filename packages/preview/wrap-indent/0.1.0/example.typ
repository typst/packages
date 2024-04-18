// ---- initialization ---- //

#import "@preview/wrap-indent:0.1.0": wrap-term-item, wrap-in

#show terms.item: wrap-term-item


// ---- example document ---- //

#set page(width: 5.5in, margin: 0.5in, height: auto)

// A function for wrapping some text:
#let custom-quote(body) = rect(
  body,
  fill: luma(95%),
  stroke: (left: 2pt + luma(30%))
)

*Normal function call:*

#custom-quote[
  Some text in a _custom quote_ spread over
  multiple lines so it actually looks like
  it was typed in a document.
]

*Wrappped function call!*

/ #wrap-in(custom-quote):
  Some text in a _custom quote_ spread over
  multiple lines so it actually looks like
  it was typed in a document.

Some text outside the indented section
that isn't included.

*Arbitrary functions should _just work#emoji.tm;_ :*

/ #wrap-in(
    x => rect(x, stroke: gradient.linear(..color.map.flare))
  ):
  Some text in a _custom rect_ spread over
  multiple lines so it actually looks like
  it was typed in a document.

*One-line syntax looks great!*

/ #wrap-in(underline): Here's one line underlined

*Final thoughts:*

/ Note\: :
  Regular term lists still work!

/ Disclaimer\: :
  There may be issues if other term list show rules
  conflict with this rule. However, set rules should
  be unaffected.

*That's a wrap!*
