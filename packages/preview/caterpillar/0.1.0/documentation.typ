#set document(title: "typst caterpillar documentation")
#let version = "0.1.0"

#import "lib.typ": *
#import parsers as p
#import "lib.typ" as lib
#import "@preview/tidy:0.4.3"

#set page(numbering: "~1~")

#let mono = text.with(font: "Iosevka Minimal", weight: "light")

#set text(font: "Cormorant Garamond")
#show raw: set text(font: "Iosevka Minimal", weight: "light")

#show title: set text(font: "Iosevka Minimal", weight: "light")
#show title: align.with(center)
#show title: set text(size: 2em)

#show heading: set text(font: "Iosevka Minimal", weight: "bold")
#set heading(numbering: "1.")
#show heading.where(level: 1): set block(above: 2em, below: 1em)
#show heading.where(level: 2): set block(above: 1.7em, below: 1em)
// #show: tidy.render-examples.with(scope: (example: example, gloss: gloss, subexample: subexample, judge: judge,))
#show link: set text(fill: rgb("#3d4ee5"))

#let code-ex(contents, output: true) = {
  set text(size: 0.9em)

  let kwargs = contents.fields()
  let text = kwargs.remove("text").replace("{version}", version)
  let contents = raw(text, ..kwargs)

  block(stroke: 1pt + luma(140), inset: (left: 8pt, right: 8pt, top: 10pt, bottom: 12pt), width: 100%, breakable: false, radius: 5pt)[
    #contents
    #if output {[
      #line(length: 100%, stroke: 1pt + luma(140))
      #eval(
        text,
        mode: "markup",
        scope: (parse: parse, crawl: crawl, p: parsers)
      )
    ]}
  ]
}

#let nb = it => [
  *N.B.* #it
]

#v(6em)
#title[Caterpillar]
#align(center, text(size: 1.1em, mono[Typst content parser and custom syntax processor]))
#align(center, text(size: 0.8em, mono[Version #version]))
#v(1.5em)
#align(center, text(size: 1.2em)[#datetime.today().display("[month repr:long] [year]")])
#align(center, mono[https://github.com/retroflexivity/typst-caterpillar])
#v(5em)

Caterpillar is a package that provides tools to parse Typst content. It is primarily made for defining custom syntactic rules, but can be used for various purposes, hopefully. This is a documentation on Caterpillar.

#pagebreak()

= Introduction <intro>

Suppose you are writing some notes for personal use. You keep them in raw text, and you care primarily about how they look in raw text. So you use syntactic conventions like this:

#code-ex(output: false,
  ```typst
  > Blah blah blah blah _blah_ blah
                              -- Plato

  This seems to contradict the following

  Axiom 114'. Bleh bleh bleh bleh bleh.

  because

  a. bluh bluh
  b. bluh bluh bluh
  ```
)

Suppose then that a collegue who is afraid of raw text asks you to share your notes. Or you urgently need to present something on a lab meeting. Anyway, you want to compile _this_ to PDF. Given that you are reading these docs, you would probably prefer doing it with Typst.

Typst's syntactic sugar, while impressive for a PDF compiler engine, is nevertheless quite limited. It will not handle greater-than quotes, axioms, or letter-based lists. So how do you achieve a fancy-looking PDF without sacrificing your markup habits? You write a custom processor. This is what Caterpillar is for.

This package is primarily a parser engine for Typst content. You define a parser and combine it with a function (handler) that says what to do with the results of parsing, should it succeed. Caterpillar runs the parser and applies the function. Apart from this rather simple algorithm, Caterpillar provides primitives for writing parsers over content, which is sometimes more complicated than what one might expect.

This documentation consists of two parts: @tutorial is a tutorial that introduces the reader to writing parsers, and @api is an API reference.

= Tutorial <tutorial>

This chapter shows how to write a parser and use it for parsing custom markup syntax. We begin with the simplest case: interpreting paragraphs that start with `> ` as quotes, as in the following example.

#code-ex(output: false,
  ```typst
  There once was a saying,
  
  > Blah blah blah blah blah blah
  ```
)

== Getting started

First import the package.

#code-ex(output: false,
  ```typst
  #import "@preview:caterpillar:{version}": *
  #import parsers as p
  ```
)

There are several functions in Caterpillar. The central one is `crawl`: it takes any number of parser-handler pairs and some content, runs the parsers one by one over the content, and if a parser succeeds, applies the corresponding function to its output. It is designed to be used in a show rule, like this:

#code-ex(output: false,
  ```typst
  #show par: crawl.with()
  ```
)

Naturally, it will not do anything yet, with no parsers supplied.

The supporting function `parse` is there to simply run a parser over content and obtain the result.

The `parsers` module, which we abbreviate as `p`, contains some predefined parsers and parser combinators --- functions used for building complex parsers from simpler ones.

== Parsers

A Caterpillar parser is a function that takes an array of contents and returns a *match result* --- a dictionary with keys `matched`, `match`, and `rest`.

- `matched` is a boolean, telling whether the parser has succeeded.
- `match` is the part of the content that corresponds to the parser --- the content that the parser has _consumed_. Its type is determined by the parser --- a content, an array, or `none`.
- `rest` is the part of the content that the parser has not consumed. It is an array of contents.

Thus, `match` and `rest` combined roughly correspond to the input.

Conceptually, a parser defines conditions on content: what can be parsed. A parser goes through contents from left to right. If the parser stumbles across something that does not correspond to its condition, it fails, returning a match result with `matched: false`. If the beginning of contents corresponds to the parser's condition, it returns a match result with `matched: true`.

To grasp the idea of how parsers work, imagine we have a parser that parses one or more `a`'s from a string (in regex, we would write ```regex a+```).
- Given a string `aaaaa`, the parser will succeed, consuming it all.
- Given a string `aaaabaa`, the parser will succeed, too, consuming the first `aaaa`. It will not go further, because it does not parse `b`'s, so `baa` will stay as the rest.
- Given a string `baaaa`, the parser will fail: going left to right, it will bump into a `b` that it cannot parse, and will not satisfy its requirement that there be at least one `a`.

There are several kinds of functions in the `parsers` submodule. First, there are constants: unflexible parsers that parse certain hard-coded values. For example, there is a constant `space`, which parses spaces, and a constant `end`, which only succeeds when there is nothing more to parse.

Second, there are primitive parser operators that handle values of certain types. They are two-place curried functions: they accept a value that tells them what they should parse and by this means become parsers (functions from content to match results). There is a parser `string` that defines how to search content for strings, and `exact` that defines how to search content for other content. In your parsers, you do not have to write `string` or `exact`: you just pass strings or contents, and Caterpillar figures out what to do itself.

Third, there are parser combinators. They take other parsers and modify them in a certain way. `multiple` is the simplest combinator, running several parsers one after another#footnote[You can also just pass an array.]. Another example, `repeat`, runs a parser a specified or unspecified number of times (it does the job of regex's `*`, `+`, and `{x,y}`).

== Inside the content <content>

Let us look at what the content we want to parse consists of. Typst exposes convenient methods `fields` to understand the structure of contents and `func` to see its type.

#code-ex(
  ```typst
  #let c = [> Blah blah blah blah blah blah]
  a #c.func() with fields #c.fields()
  ```
)

This line consists of a single piece of #link("https://typst.app/docs/reference/text/text/")[text]-type content. A text is Typst's default textual structure with one field, eponymously named `text`, of type `string`. But let us look at something more complex.

#code-ex(
  ```typst
  #let c = [> _Blah_ blah blah blah blah blah]
  a #c.func() with fields #c.fields()
  ```
)

When content contains something other than text, it becomes a multipart structure of type `sequence`. A sequence has children, which are pieces of content, too. The first child of our sequence is still a text, but now it only includes the `>`. The space has got separated!

#code-ex(
  ```typst
  #let c = [> _Blah_ blah blah blah blah blah]
  a #c.children.at(0).func() and a #c.children.at(1).func()
  ```
)

When a single space is surrounded by text, Typst joins them together for performance considerations. However, in all other cases, such as when there is a non-text content on one of the sides, the space becomes a separate `space` element. The same happens if you happen to type a double space: it is because Typst fixes double spaces for you.

#code-ex(
  ```typst
  #let c = [>  Blah blah blah blah blah blah]
  #c.fields()
  ```
)

Caterpillar is designed to take care of these inconsistencies by itself. The aforementioned `space` parser parses both the space element and the string space. Caterpillar also handles the difference between a `text` and a `sequence`, so the same parser can parse both simple and complex contents.

This brief introduction to Typst's content structure is enough to write our first parser.

== Writing the parser

As a reminder, we need to write a parser that will parse the second paragraph in the text below, extracting the greater-then sign and the space. It should also handle the variations mentioned in @content.

#code-ex(output: false,
  ```typst
  There once was a saying,
  
  > Blah blah blah blah blah blah
  ```
)

Our parser, thus, will consist of two parts: a greater-than sign parser and the `space` parser. Parsing a piece of text is done with the `exact` parser.#footnote[`string` can also be used here with no real difference.] To chain multiple parsers, we use the `multiple` combinator: it runs parsers one by one, each parser taking the previos one's rest, and fails if any of its subparsers fails.

#code-ex(
  ```typst
  #let parser = p.multiple(p.exact[>], p.space)

  #parse(parser)[> Blah blah blah blah blah blah]
  ```
)

The parser has succeeded: the prefix is in the `match` fields, and the quotation body is in `rest`. When given a text that is longer than what the `exact` parser should parse, it gets the string out of it and tries comparing prefixally: thus, it extracts the ```typc ">"``` from the text ```typc "> Blah blah blah blah blah blah"```. Let us verify this works when the space is a separate content:

#code-ex(
  ```typst
  #let parser = p.multiple(p.exact[>], p.space)

  #parse(parser)[> _Blah_ blah blah blah blah blah]
  ```
)

Note the types of the return values. `match` is an array, because `multiple` produces an array. Other parsers produce other types: as you can see, the outputs of `exact` and `space` inside the array are of type `content`. Parsers that do not match anything by design produce `none`. You can always consult the API in @api or via the language server: the type declaration is written in the end of the description. E.g. `multiple` is `..parser => array(content) => match-result(array)`, meaning that it takes any number of parsers, then the content to run the parsers on (it is always an array in Caterpillar internally --- this is handled by `parse`) and returns a `match-result` where `match` is of type `array`.

`rest` is also an array. This is because Caterpillar works on arrays instead of sequences for simplicity. `crawl` then joins the rest, creating a content --- you can try it yourself with `rest.join()`.

As mentioned above, Caterpillar exposes some syntactic sugar to let you avoid writing trivial `multiple` and `exact`. Arrays are passed to `multiple`, and content to `exact`. Cleaning up the parser:

#code-ex(
  ```typst
  #let parser = ([>], p.space)

  #parse(parser)[> Blah blah blah blah blah blah]
  ```
)

What if we run the parser on something that is not a quote? Let us do a sanity check.

#code-ex(
  ```typst
  #let parser = ([>], p.space)

  #parse(parser)[There once was a saying,]

  #parse(parser)[>5 experts validated this.]
  ```
)

Neither matches, which is exactly what we need --- no false positives meaning no unexpected quotes in the resulting document.

== Using the parse results

Having written the parser, we can now make Caterpillar turn the match results into actual quotes. For this, we use a show rule with `crawl`.

#code-ex(
  ```typst
  #let parser = ([>], p.space)
  #let handler(match, rest) = quote(rest, block: true)
  #show par: crawl.with(
    (parser, handler)
  )

  There once was a saying,
  
  > Blah blah blah blah blah blah
  ```
)

`crawl` needs to be run on paragraphs: a paragraph is the structure that gets parsed. We pass to it a parser-handler pair. The handler is a two-place function: if the parser succeeds, `crawl` runs it with the `match` and `rest` (the latter gets joined) from the match result. 

== A more complex example

So far so good. Now let us try to also get the attribution of the quote, as in the following.

#code-ex(output: false,
  ```typst
  > Blah blah blah blah _blah_ blah
                              -- Plato
  ```
)

First we inspect it.

#code-ex(
  ```typst
  #let c = [> Blah blah blah blah _blah_ blah
                              -- Plato]
  #c.fields()
  ```
)

As you can see, Typst joined the newline and spaces into a single `space` element. While it takes away some flexibility, we can still handle this.

Let us first write a helper parser for the attribution.

#code-ex(output: false,
  ```typst
  #let attr-parser = (space, [--], space, repeat(anything, min: 1))
  ```
)

The parser will consume the newline and the tabulation, and then the attribution marker#footnote[Note that two dashes are interpreted as an en dash by the Typst compiler. But so do they in the parser, which means an em dash will match against an en dash.]. `anything` is a constant that parses a single piece of content --- any content. This way, we can include anything we want in an attribution, including non-textual elements. `repeat` will repeat `anything` any number of times, but at least one.

What we want the parser to do is parse the content _until_ it encounters an attribution, then stop and parse the rest as an attribution. Luckily, there is a combinator `until` precisely for this purpose.

#code-ex(output: false,
  ```typst
  #let attr-parser = (p.space, [--], p.space, p.repeat(p.anything, min: 1))

  #let parser = (
    [>], p.space,
    p.until(p.anything, attr-parser),
    attr-parser
  )

  ```
)

`until` takes two parsers --- read `until(a, b)` as "parse _a_ until you can parse _b_". It first tries to parse _b_. If parsing _b_ succeeds, it stops immediately, without consuming _b_. If it fails, it parses _a_ and repeats (or, if parsing _a_ fails, fails as a whole).

Here, _b_ is complex: it contains multiple parsers and even another parser combinator. It is never a problem for Caterpillar: parsers can be nested as deeply as needed.

Running the parser:

#code-ex(
  ```typst
  #let attr-parser = (p.space, [--], p.space, p.repeat(p.anything, min: 1))

  #let parser = (
    [>], p.space,
    p.until(p.anything, attr-parser),
    attr-parser
  )

  #parse(parser)[> Blah blah blah blah _blah_ blah
                              -- Plato]
  ```
)

Everything we need is now in `match` instead of `rest` (we parse to the end with `repeat(anything)`). The third item is always the body of the citation, and the fourth item of the fourth item is the attribution.

Let us see if the parser works on attribution-less quotes.

#code-ex(
  ```typst
  #let attr-parser = (p.space, [--], p.space, p.repeat(p.anything, min: 1))

  #let parser = (
    [>], p.space,
    p.until(p.anything, attr-parser),
    attr-parser
  )

  #parse(parser)[> Blah blah blah blah _blah_ blah]
  ```
)

Unfortunately, it does not: it parses everything but then breaks. This is because `until` never encounters its second parser, hitting the end of content. There are two ways to avoid this issue: either allow `until` to parse the end as well, or make the whole piece that was added in this section optional. We will proceed with option 1: implementing option 2 should be easy after reading the following section.

=== Disjunction and optionality

`end` is a special constant that matches empty content: that is, the content that has come to its end. We want `until` to stop either on the attr-parser or at the end. Disjunctive parsing is done by the `one-of` combinator.

The other piece that we need is `optional`. It attempts to parse, but doesn't break if it fails: in that case, it simply parses nothing. We need it to prevent `attr-parser` from breaking the parse after `until` finishes at the end#footnote[A cleaner implementation would actually repeat `p.one-of(attr-parser, p.end)` instead, but I need to demonstrate the behavior of `optional`.].

#code-ex(
  ```typst
  #let attr-parser = (p.space, [--], p.space, p.repeat(p.anything, min: 1))
  #let parser = (
    [>], p.space,
    p.until(p.anything, p.one-of(attr-parser, p.end)),
    p.optional(attr-parser)
  )

  #parse(parser)[> Blah blah blah blah _blah_ blah
                              -- Plato]

  #parse(parser)[> Blah blah blah blah _blah_ blah]
  ```
)

The parser now succeeds on both kinds of quotes, returning `none` if no attribution is present. It is now time to add a handler.

#code-ex(
  ```typst
  #let attr-parser = (p.space, [--], p.space, p.repeat(p.anything, min: 1))
  #let parser = (
    [>], p.space,
    p.until(p.anything, p.one-of(attr-parser, p.end)),
    p.optional(attr-parser)
  )
  #let handler(match, rest) = {
    let attr = if match.at(3) != none {match.at(3).at(3).join()} else {none}
    quote(
      match.at(2).join(),
      attribution: attr,
      block: true
    )
  }
  #show par: crawl.with(
    (parser, handler)
  )

  Plato once said,

  > Blah blah blah blah _blah_ blah
                              -- Plato

  Someone else once said,

  > Blah blah blah blah _blah_ blah
  ```
)

== Conclusion

This concludes the tutorial. The material given here should be sufficient for parsing all other syntax given in @intro, as well as most of what you might need.

For more information on parsers, consult the API reference below. And if this is not enough for you, you can always write your own parser function: it should receive an array of contents and return a match result. That is all.


#pagebreak()

= API reference <api>

#show heading.where(level: 4): set heading(numbering: none)
#show heading.where(level: 5): set heading(numbering: none)

#let show-tidy = (file, name) => tidy.show-module(
  tidy.parse-module(
    read(file),
    name: name,
    // scope: (parse: parse, crawl: crawl, p: parsers),
    scope: (lib: lib),
    preamble: "#import lib: *\n#import parsers as p\n"
  ),
  style: tidy.styles.default, show-outline: false, first-heading-level: 2, sort-functions: none)

#show-tidy("lib.typ", "Primary API")
#show-tidy("src/parsers.typ", "Parsers")
#show-tidy("src/utils.typ", "Utility")
