// It's recommended to always import these!
#import "@preview/thesist:1.0.2": flex-caption, subfigure-grid

// You will usually also want a glossary package.
#import "@preview/glossarium:0.5.6": gls, glspl

// Optionally use more packages, depending on the chapter's needs. In the case of this chapter, we will also import this:
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "@preview/lovelace:0.3.0": *
// Check Typst Universe to look for new packages you might need, and always read their description page to know how to handle them.

= A quick guide to using this template

== About this chapter

This chapter is a tutorial on how to use this template's features. This is _not_ about Typst itself, but rather about how to make full and correct use of this thesis package. If you're reading this just from the PDF, please look at the code too.

You already saw the `import` statements and the `//comments` in the code, right? Let's keep reading and comparing with the code, then!

== Kinds of content and how to properly include them

=== Images

As you probably know if you've already used Typst, this is a simple image call:

#figure(
  image("../Images/0-Quick-guide/example.jpg", width: 40%),
  caption: [An image]
)<example_image>

This is a different one, with a different number:

#figure(
  image("../Images/0-Quick-guide/example.jpg", width: 40%),
  caption: [The same image again]
)<example_image_2>

To number, index and center the contents of @example_image and @example_image_2, we need to *always* make them part of a `figure()` and give them a `caption`. This is mandatory for all the images in the thesis!

*Note 1:* If you want to draw images using Typst packages like #link("https://typst.app/universe/package/cetz")[CeTZ], you can still index them as if they were normal images, by making them part of a `figure()`. You may have to manually specify that figure's `kind` parameter as `image` (_no quotation marks_), but Typst usually detects that automatically.

*Note 2:* Remember that you can erase or customize the "Figure" supplement if you want, by using square brackets right after the `@reference`. This allows you to say things like "Figures @example_image[] and @example_image_2[]".

=== Tables

Tables also have to be numbered, indexed and centered. Although they are not figures in the usual sense of the word, from a coding point of view they are when they are indexed with the `figure` function.

// Using a [content block] right outside of the #figure() is equivalent to putting the content directly inside the #figure().
// You might prefer this form for multi-line content.
// Note: This has nothing to do with the position of the caption.
#figure(
  caption: [A table]
)[
  #table(
    columns: 2,
    [*First name*], [*Last name*],
    [Foo], [Bar],
    [Bar], [Foo]
  )
]

Typst automatically detects that this is a different kind of `figure`, and so calls it "Table" instead of "Figure", numbers it differently and respects this template's instruction to put the caption for tables on top!

=== Listings

Like tables, listings will be automatically interpreted as their own kind of figure - in this case, `raw`. You can call one like this:

#figure(
  caption: [A piece of code]
)[
  ```rust
  pub fn main() {
      println!("Hello world!");
  }
  ```
]

Optionally, you can use a package like #link("https://typst.app/universe/package/codly")[Codly] for some extra formatting:

#show: codly-init.with()
#codly(languages: codly-languages)

#figure(
  caption: [A fancy piece of code]
)[
  ```rust
  pub fn main() {
      println!("Hello world!");
  }
  ```
]

#codly-disable()

*Note:* This is just an example. To know how to use a certain package to its full extent, including any that is used in this guide, be sure to read its documentation.

=== Algorithms

Depending on what your thesis is about, you might want to display algorithms. Algorithm figures are not native to Typst and were specified in this package for your convenience. Since they are custom, they are not detected automatically, and as such you need to specify its `kind` parameter _with quotation marks_ (you need them because it's not a default kind).

You can define an algorithm with `raw text`:

#figure(
  kind: "algorithm",
  caption: [A simple algorithm]
)[
  ```
  1: Do stuff
  2: Do more stuff
  3: Stuff <- stuff
  ...
  N: You get stuff
  ```
]

Or use a package like #link("https://typst.app/universe/package/lovelace")[Lovelace] to make it fancier:

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

=== Equations

Equations don't need to be indexed, but they still need to be numbered and centered, just like figures.

#linebreak()

This is wrong:

$E = m c^2$   // don't do this!

This is also wrong:

#align(center, $E = m c^2$)  // don't do this!

This is right:

$
E = m c^2
$

== Content subfigures

Subfigures, despite not being native to Typst yet, are implemented in this template via the function `subfigure-grid`. This is a slightly modified version of the `grid` function of the #link("https://typst.app/universe/package/subpar")[Subpar] package for subfigures. The modifications allow it to work with the numbering used by figures in this template.

This is `subfigure-grid` in action:

#subfigure-grid(
  figure(
    image("../Images/0-Quick-guide/example.jpg", width: 90%),
    caption: [An image on the left.]
  ), <sub-left-example>,

  figure(
    image("../Images/0-Quick-guide/example.jpg", width: 90%),
    caption: [An image on the right.]
  ), <sub-right-example>,

  kind: image,
  align: top,
  columns: (1fr, 1fr),
  rows: (auto),
  caption: [A figure composed of two subfigures],
  label: <subfigure-grid-example>
)

In @subfigure-grid-example, we see a figure which is composed of two other figures, namely @sub-left-example and @sub-right-example.

Alternatively, you can use more subfigures, by tweaking the `columns` and `rows` parameters:

#subfigure-grid(
  figure(
    image("../Images/0-Quick-guide/example.jpg", width: 60%),
    caption: []
  ),

  figure(
    image("../Images/0-Quick-guide/example.jpg", width: 60%),
    caption: []
  ),

  figure(
    image("../Images/0-Quick-guide/example.jpg", width: 60%),
    caption: []
  ),

  figure(
    image("../Images/0-Quick-guide/example.jpg", width: 60%),
    caption: []
  ),

  kind: image,
  align: top,
  columns: (1fr, 1fr),
  rows: (4cm, 3.5cm),
  caption: [A figure composed of four subfigures]
)

Contrary to normal figures, subfigure grids don't automatically detect the `kind` that should be used. You must change that field yourself if you want to do something like this:

#subfigure-grid(
  figure(
    caption: [Code on the left.]
  )[
    ```c
    #include <stdio.h>

    int main() {
      printf("Hello world!\n");
      return 0;
    }
    ```
  ], <sub-left-example-listing>,

  figure(
    caption: [Different code on the right.]
  )[
    ```java
    public class HelloWorld {
      public static void main(String[] args) {
        System.out.println("Hello world!");
      }
    }
    ```
  ], <sub-right-example-listing>,

  kind: raw,
  align: top,
  columns: (1fr, 1fr),
  rows: (auto),
  caption: [A comparison of two pieces of code],
  label: <subfigure-grid-example-listing>
)

@subfigure-grid-example-listing, composed of Listings @sub-left-example-listing[] and @sub-right-example-listing[], is not being treated as an image figure, thanks to `kind: raw`.

If you have any other doubts about how to use subfigures, be sure to check the documentation of the Subpar package.

== Flexible captions

The package of this thesis also includes the function `flex-caption`. Consider the following figure:

#figure(
  image("../Images/0-Quick-guide/example.jpg", width: 80%),
  caption: flex-caption(
    [This is a very long figure caption that goes into detail about some things. #lorem(20)],
    [A short version of the caption]
  )
)<example_flex_caption>

Look now at the image index back at the beginning of the thesis, and see the caption @example_flex_caption has in there. Instead of it being cluttered with this long caption, it has the short version in there. Might be useful!

== Using the Glossary

This template's Glossary feature is implemented by default with the #link("https://typst.app/universe/package/glossarium")[Glossarium] package. With it, you use `#gls()` for singular forms and `#glspl()` for plural forms. Some example references are #gls("mu_0"), #glspl("potato"), #glspl("DM") and #gls("IST"). The latter two become just #glspl("DM") and #gls("IST") by default after their first usage. Be aware that glossary terms typically don't show up in the glossary until you reference them!

Glossary entries and titles are set up in the `Glossary.typ` file.

== Using the Bibliography

You can also reference bibliography items, like this @Madje_Typst or like this #cite(<Madje_Typst>). Like with the Glossary, entries will usually only show up after being referenced.

Paste LaTeX-style (BibLaTeX) references into the included `refs.bib`, or switch to a `.yml` file with Typst's own format (Hayagriva) if you want.

== Afterword

You can keep this file in the project while removing it from `main.typ` if you want to keep it as a reference.

Keep in mind that this template may receive new features in the future. This will be influenced, in part, by the evolution of both the package ecosystem and Typst itself. Just like with your other imported packages, you can update the `thesist` version number in your `.typ` files. Instructions will be given on the new version's changelog if you need to take any extra steps after that.

*Feel free to contribute to this package's repository if you so wish.*
