# Bullseye

This library helps you write target-dependent Typst code, particularly target-dependent content and show rules.

This package consists of two parts:
- At the foundation, it contains a wrapper around the currently unstable Typst features for target detection and HTML output.
- Built on top of that are a few helpful functions that allow package and document authors to easily write content and show rules that behave differently based on the target.

Bullseye makes sure that your code compiles even when HTML support is not enabled (e.g. in the web app or when previewing using Tinymist) _as long as_ no HTML specific content ends up in the rendered document, and automatically switches to Typst's HTML support when it is enabled.

## Getting Started

To add this package to your project, use this:

```typ
#import "@preview/bullseye:0.1.0": *

// apply styling only for non-HTML output
#show: show-target(paged: doc => {
  set page(height: auto)

  import "@preview/codly:1.3.0"
  show: codly.codly-init
  doc
})

// apply image styling only for html output
#show image: show-target(html: img => {
  html.elem("img", attrs: ("src": img.source, "alt": img.alt))
})

// insert content only for HTML output
#context on-target(html: {
  html.elem("a", attrs: (href: "#"))[(back to top)]
})
```

## Usage

See the [manual](docs/manual.pdf) for details.
