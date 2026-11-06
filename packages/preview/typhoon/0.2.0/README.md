# TailwindCSS-Typst

Tailwind CSS generation for Typst powered by [encre-css](https://docs.rs/encre-css).
This plugin only works in the HTML target. It would not work in paged (i.e. PNG, PDF, SVG) targets.
You can checkout more examples at <https://wensimehrp.github.io/tailwindcss-typst/>.

## Getting started

It just works. Enter your classes as follows:

```typst
// First import the library
#import "@preview/typhoon:0.2.0": *
#import html: *
// then define your HTML:
#html({
  head({
    // don't remember those metas!
    meta(charset: "utf-8")
    meta(name: "viewport", content: "width=device-width,initial-scale=1")
    title[Typhoon Main Page Showcase]
    // the tailwind-css() function produces a css string
    context { style(tailwind-css()) }
    // Or, if you want to specify your own configuration
    // context { style(tailwind-css(config: ..)) }
  })
  show std.html.elem: update-elem
  body(class: "bg-neutral-800", {
    // Then define your elements. No special notation needed. The plugin would
    // read the classes.
    html.div(
      class: {
        "p-10 w-full h-screen border-1 bg-neutral-300 overflow-x-scroll "
        " grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-10"
      },
      div(class: "p-5 border-1 border-neutral-500")[Hi from grid!] * 5
    )
    // You can also use the typography plugin
    html.article(class: "prose")[
      // Now write your content here...
    ]
  })
})
```

Remember to compile the document using the following arguments:

```sh
$ typst c <filename> --features html --format html
# Or, if using the bundle target
$ typst c <filename> --features html,bundle --format bundle
```

## Extensions

This plugin comes with the [`typography` plugin](https://docs.rs/encre-css-typography) by default. There are currently
no ways for defining custom plugins.

## Building

Run `make` to bundle everything including LICENSE, README, .typ files, and the wasm file.
