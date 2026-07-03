# TailwindCSS-Typst

Tailwind CSS generation for Typst powered by [encre-css](https://docs.rs/encre-css).
This plugin only works in the HTML target. It would not work in paged (i.e. PNG, PDF, SVG) targets.

## Getting started

It just works. Enter your classes as follows:

```typst
// First import the library
#import "@preview/typhoon:0.1.2": *
// then use this show rule:
#show: tailwind-page
// Or, if you want to specify your own configuration
// #show: tailwind-page.with(config: (...))

// Then define your elements. No special notation needed. The plugin would 
// read the classes.
#html.div(
  class: "p-10 w-full h-screen border-1 bg-neutral-300 overflow-x-scroll "
    + "grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-10",
  html.div(class: "p-5 border-1 border-neutral-500")[Hi from grid!] * 5
)

// You can also use the typography plugin
#html.article(class: "prose")[
  // Now write your content here...
]
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
