# tufte-memo
A memo document template inspired by the design of Edward Tufte's books for the Typst typesetting program.

For usage, see the usage guide [here](https://github.com/nogula/tufte-memo/blob/main/template/main.pdf).

The template provides handy functions: `template`, `note`, and `wideblock`. To create a document with this template, use:

```typst
#import "@preview/tufte-memo:0.1.0": *

#show: template.with(
    title: [Document Title],
    authors: (
        (
        name: "Author Name",
        role: "Optional Role Line",
        affiliation: "Optional Affiliation Line",
        email: "email@company.com"
        ),
    )
)
...
```
additional configuration information is available in the usage guide.

The `note()` function provides the ability to produce sidenotes next to the main body content. It can be called simply with `#note[...]`. Additionally, `wideblock()` expands the width of its content to fill the full 6.5-inch-wide space, rather than be compressed in to a four-inch column. It is simply called with `wideblock[...]`.
