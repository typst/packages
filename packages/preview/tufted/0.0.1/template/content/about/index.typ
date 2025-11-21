#import "../index.typ": *
#show: template

= About

This is an experimental template to build static websites with *pure* Typst. Consider the API to be unstable.

Currently, it uses Typst's experimental HTML export feature and modifies some definitions to produce more semantically correct and styled HTML output.

We use #link("https://edwardtufte.github.io/tufte-css/")[Tufte CSS] for styling; the CSS is not bundled but loaded from a CDN. The goal is to provide a Typst-native way to use it.

== API

Currently, three functions are implemented:

- `tufted-web` --- A main template.
- `margin-note` --- A function to place content in margin notes. This is limited as producing correct HTML requires introspection capabilities, which Typst currently lacks.
- `full-width` --- A function to place content in full-width containers. This does not currently work as expected, again, due to introspection limitations.

== Links

- Repository: #link("https://github.com/vsheg/tufted")[`tufted` on GitHub]
- Typst Universe: #link("https://typst.app/universe/package/tufted")[`tufted`]
