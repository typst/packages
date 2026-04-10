#import "../utils/global.typ": *
#import "../utils/symbols.typ": LaTeX

This chapter will go into some basic features of the typst typesetting system, and how to use them in conjunction with this thesis template. Note that you should supplement this with the official guides on the typst website #footnote()[see #link("https://typst.app/docs/tutorial/")].

== Headings <subsec:headings>
We've already used headings a number of times in this template, and they are intuitive and easy to write. The syntax is markdown-like with `=` instead of `#` serving as its symbol. Chapters are the lowest depth headings, and this template styles them distinctly with a large graphic and new page, like we see here in @chp:typst_basics.

=== An even deeper heading <subsubsec:deepheading>
We can also create sections of various depths.

==== Super deep heading <subsubsubsec:superdeep>
@subsubsubsec:superdeep is an example of heading of depth 4. Note that we can also easily give headings labels and reference them anywhere in the document: We can for instance refer to @chp:introduction from here. The same applies to any kind of figure. We should also mention that the prefix in for instance `<subsec:headings>` is only a suggestion to keep your labels organized, you can call it whatever you want.

== Lists <subsec:lists>
As with headings, typst has syntactic sugar for lists so that we can use simple markdown-like syntax to create them. This goes for both ordered lists:
- One list item
- Another list item
  - A sub-item
  - Another sub-item

...as well as ordered lists:
+ A numbered list item
+ Another one
  - Sub-items can go here too

== Other Nifty Features <subsec:nifty>
Creating *bold*, _italic_ and _*bold italic*_ text segments is also easily available with markdown-like syntax along with `inline code blocks`. In addition to this, a number of functions are available to achieve most of the textual styling. We can add #strike[strikethrough to our text], easily add #text(orange)[color] to it. We get subscripts#sub[like this] and superscripts#super[like this]. Typst also makes it easy to move characters around, for example to create the #LaTeX symbol (Take a look in the function in utils to see how it's achieved).

Footnotes #footnote()[These are useful for clickable links: #link("https://typst.app/docs/reference/model/footnote/")] are another useful feature natively supported in typst. Note that any function that takes content (anything inside `[brackets]`) allows us to use other functions in the content we give it. Look for example at this footnote #footnote()[_We can do *all sorts*_ of stuff in #text(blue)[here]]

For further reference, the typst official library reference, tutorial and guides along with the unofficial _Typst Examples Book_ found here #footnote()[see #link("https://sitandr.github.io/typst-examples-book/book/about.html")] are great resources.

#pagebreak(weak: true)
== Citing References <subsec:citing>
We can cite references defined in our bibliography file easily @QayyumY-sac2022. Once a reference is cited, it will appear in the bibliography at the end of the thesis.
