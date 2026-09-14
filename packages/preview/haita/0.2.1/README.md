# Haita

Here's Haita Docs. A simple tool that
has a single requirement: [Typst](https://github.com/typst/typst). Here are some features:

- Pure Typst workflow
- Features inherited from Typst:
  - Simple yet expressive Typst syntax helping you focussing on your content
  - Native syntax highlighting
  - Native MathML output
  - Fast compliation
  - Native support for `watch` and `serve`
  - PDF and HTML generation from the same source (
      PDF generation is currently suspended. See <https://github.com/typst/typst/issues/8309> for details.
    )
  - HTML minification
- No client side JS by default, including when using Math.
- Good SEO
- Semantic output, and
- Minimal setup

## Example

![Haita with the default theme "New Hamber"](https://raw.githubusercontent.com/wensimehrp/haita/e2124e8066998db05db0b732ebc0d5d7f57d3e0d/demo.png)

(See [dist.typ in the Haita repository](https://github.com/wensimehrp/haita/blob/7b2b0183a9926375ed677d4e11addeb2ac048f27/dist.typ) for a more comprehensive example)

(See <https://wensimehrp.github.io/haita> for an online demo)

`main.typ`:

```typst
#!/usr/bin/env -S typst compile --features bundle,html --format bundle
#import "@preview/haita:0.2.1": *
// Optional markdown support
#import "@preview/cmarker:0.1.10"

#book(
  title: "My docs",
  canonical-url: "https://example.com",
  tree: (
    chapter("index"), // this would include content from `intro.typ`
    [= User Guide],   // A heading in the summary
    chapter("install"), // this would include content from `install.typ`
    // Use the `include` syntax if you want to manually specify the filename
    chapter("tutorial", content: include "docs/tutorial.typ", children: (
      // Set children chapters here
      chapter("integration"),
      chapter("custom-renderer"),
      chapter("continuous-integration", content: [
        // Directly write the content if you don't want to make a new file
        #title[CI]
        Foo bar baz fizz buzz #lorem(100)
      ]),
    )),
    separator(), // a separator in the summary
    chapter("changelog",
      content: title[Changelog]
        + cmarker.render(
          read("CHANGELOG.md"),
        ),
    ),
  ),
)
```

`index.typ`: 

```typst
// Always start your page with a title
#title[My title]

// and place your content afterwards
```

You can make a new project in Typst using Haita, set it to [bundle export](https://github.com/typst/typst/pull/7964),
and Haita would generate a site for you. You don't need to worry about setting up the toolchain – Typst
is the only tool required.

## An Unfinished Project

Haita is a decent choice for organizing long, comprehensive documentation. But just like Typst, Haita is an
unfinished project, and is (currently) not a serious tool. Specifically, it's missing these features:

- Internationalization support
- Built-in search functions

However, if you want pure Typst documentation, ease of use, and/or MathML formulae, you might want to give it a try. If
you want stability and extremely easy syntax, then maybe you should consider mdBook. If you have any issues, please feel
free to [open a ticket on GitHub](https://github.com/wensimehrp/haita/issues). If you would like to
contribute, please [open a pull request](https://github.com/wensimehrp/haita/pulls).

## Installation

You don't need to install anything! Just import the library then write docs!

## Licensing

The source and the documentation are available under [Apache License
  v2.0](https://www.apache.org/licenses/LICENSE-2.0).
