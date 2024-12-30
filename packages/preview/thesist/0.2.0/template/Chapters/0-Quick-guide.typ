// It's recommended to always import these!
#import "@preview/thesist:0.2.0": flex-caption, subfigure-grid
#import "@preview/glossarium:0.5.0": gls, glspl

// Optionally import more packages, depending on the chapter's needs. In the case of this chapter, we will use these:
#import "@preview/codly:1.0.0": *
#import "@preview/lovelace:0.3.0": *
// Check Typst Universe to look for new packages you might need, and always read their description page to know how to handle them.

= A quick guide to using this template

== About this chapter

This chapter is a tutorial on how to use this template's features. This is _not_ about Typst itself, but rather about how to make full and correct use of this thesis package. If you're reading this just from the PDF, please look at the code too.

This is a new paragraph. You already saw the `import` statements and the `//comments` in the code, right?

Let's move on, then!

== Figures

This is a simple image call:

#figure(
  image("../Images/0-Quick-guide/andromeda.jpg", width: 80%),
  caption: [An image]
)<example_simple_image>

In order to index @example_simple_image, we need to *always* wrap it in a `figure()` call and give it a `caption`. Indexing all the image calls in the thesis is mandatory!

*Note:* If you want to draw images using Typst packages like #link("https://typst.app/universe/package/cetz")[CeTZ], you can still index them as if they were normal images, by wrapping them in a `figure()` call. You may have to manually specify that figure's `kind` parameter as `image` (_no quotation marks_), but Typst usually detects that automatically.

=== Flexible captions

The first function of this thesis package that will be presented here is `flex-caption`. Consider the following picture:

#figure(
  image("../Images/0-Quick-guide/andromeda.jpg", width: 80%),
  caption: flex-caption(
    [This is a very long picture caption that goes into detail about some things. #lorem(20)],
    [A short version of the caption]
  )
)<example_flex_caption>

Look now at the image index back at the beginning of the thesis, and see the caption @example_flex_caption has in there. Instead of it being cluttered with this long caption, it has the short version in there. Might be useful!

=== Tables

Tables also have to be indexed. Although they are not figures in the usual sense of the word, from a coding point of view they are when they are indexed with the `figure` function.

#figure(
  table(
    columns: 2,
    [*First name*], [*Last name*],
    [Foo], [Bar],
    [Bar], [Foo],
  ),
  caption: [A table]
)

Typst automatically detects that this is a different type of `picture`, and as such calls it "Table" instead of "Figure" and numbers it differently.

=== Code snippets

Like tables, code figures will be automatically interpreted as their own type - in this case, `raw`.

You can either call one in the traditional way, like this:

#figure(
  caption: [A piece of code],
  ```
  pub fn main() {
      println!("Hello, world!");
  }
  ```
)

Or use an imported package which function call will be interpreted by `figure` as a `raw`. An example of such a package is #link("https://typst.app/universe/package/codly")[`codly`]:

// Notice that the content block can go either inside #figure() or right after it.
// Pick whichever form you prefer. What's important is that #figure() affects that block by making it numbered.
#figure(
  caption: [A fancy piece of code]
)[
  // This show rule would normally be at the top of the document, but putting it here to prevent it from affecting other examples
  #show: codly-init.with()

  #codly(
    languages: (
      rust: (
        name: "Rust",
        //icon: text(font: "tabler-icons", "\u{fa53}"),
        color: rgb("#CE412B")
      ),
    )
  )
  ```rust
  pub fn main() {
      println!("Hello, world!");
  }
  ```
]

*Note:* This is just an example. To know how to use a certain package to its full extent, including any that is used in this guide, be sure to read its documentation.

=== Algorithms

Depending on what your thesis is about, you might want to display and index algorithms. Algorithm pictures are not native to Typst and were specified in this package for your convenience. Since they are custom, they are not detected automatically, and as such you need to specify its `kind` parameter _with quotation marks_ (you need them because it's not a default type).

You can either define an algorithm with `raw text`:

#figure(
  kind: "algorithm",
  caption: [A simple algorithm],
  [
    ```
    1: Do stuff
    2: Do more stuff
    3: Stuff <- stuff
    ...
    N: You get stuff
    ```
  ]
)

Or use a package like #link("https://typst.app/universe/package/lovelace")[`lovelace`] to make it fancier:

#figure(
  kind: "algorithm",
  caption: [A very smart algorithm]
)[
  #pseudocode-list[
    + do something
    + do something else
    + *while* still something to do
      + do even more
      + *if* not done yet *then*
        + wait a bit
        + resume working
      + *else*
        + go home
      + *end*
    + *end*
  ]
]

=== Subfigures

Subfigures are implemented in this template via the function `subfigure-grid`. This is a slightly modified version of the `grid` function of the #link("https://typst.app/universe/package/subpar")[`subpar`] package for subfigures. The modifications allow it to work with the numbering used by figures in this thesis.

This is `subfigure-grid` in action:

#subfigure-grid(
  in-appendix: false,
  figure(
    image("../Images/0-Quick-guide/andromeda.jpg", width: 90%),
    caption: [An image on the left.]
  ), <sub-left-example>,
  figure(
    image("../Images/0-Quick-guide/andromeda.jpg", width: 90%),
    caption: [An image on the right.#v(1em)]
  ), <sub-right-example>,
  align: top,
  columns: (1fr, 1fr),
  caption: [A figure composed of two subfigures],
  label: <subfigure-grid-example>,
)

Above in @subfigure-grid-example, we see a figure which is composed of two other figures, namely @sub-left-example and @sub-right-example.

*Important note:* Subfigures are still an experimental feature. As such, there are two things to keep an eye for if you use them:

- If the subfigures or their captions aren't positioned in the way you want, try messing with the `align` parameter and `#v()` spacers above or below text. This was done in @subfigure-grid-example.

- Subfigure grids, contrary to other figures, don't show up with the correct numbering by default (check this template's homepage for more details on why). As such, you will have to manually specify whether the figure is inside an appendix or not, with the `in-appendix` argument.

== A note about equations

Like figures, equations also need to be centered and numbered.

#linebreak()

This is wrong:

$E = m c^2$   // don't do this!

This is also wrong:

#align(center, $E = m c^2$)  // don't do this!

This is right:

$
E = m c^2
$

== Using the Glossary

This template's Glossary feature is implemented by default with the #link("https://typst.app/universe/package/glossarium")[`glossarium`] package. To reference glossary entries, you use the `#gls()` and `#glspl()` commands, depending on whether you want to write the singular or the plural form.

Some example references are #gls("mu_0"), #glspl("potato"), #glspl("dm") and #gls("ist"). The latter two become just #glspl("dm") and #gls("ist") after their first usage. Glossary entries are set up in the `Glossary.typ` file, which guides you on how to manage entries.

== Using the Bibliography

Simply reference the bibliography items in the same way you would do for figures. Like this: @Madje_Typst Paste LaTeX-style references in `refs.bib`, or switch to a `.yaml` file based on Typst's native format if you want.

== Afterword

You can keep this file in the project while removing it from `main.typ` if you want to keep it as a reference.

Keep in mind that this template may receive new features in the future; this will be influenced, in part, by the evolution of both the package ecosystem and Typst itself. You can always check for updates and update the package in your document. Instructions will be given on the template's changelog if you need to take any extra steps besides just changing the version in your import statements.

*Feel free to contribute to this package's repository if you so wish.*
