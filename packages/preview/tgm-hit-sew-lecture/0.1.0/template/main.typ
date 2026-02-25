#import "@preview/tgm-hit-sew-lecture:0.1.0": *

// #set text(lang: "de")
#set document(
  title: [Template for SEW lecture documents],
  author: "Clemens Koza",
  // you may keep a log of published versions here
  // 2025-11-28: template created
  date: datetime(year: 2025, month: 11, day: 28),
)

#show: template(
  header-left: [SEW X. Jahrgang],
  header-center: [Template],
  footer-right: [TGM-HIT],
  license: licenses.cc-by-4-0,
  // font: "Noto Sans",
)

// the bibliography is not shown, but you can cite from it (chicago-notes is a footnote style)
#bibliography("bibliography.bib")

#title()

// useful to give attribution if this is an adaptation
// #place(hide(footnote(numbering: "*")[Based on earlier work by Jane Doe]))
// #counter(footnote).update(i => i - 1)

This template is intended to simplify crafting well-presented learning resources for our software engineering students.
The examples here are meant to be read along with the document's source code, e.g. in the web app or using Tinymist's preview.
Typst code snippets will only be presented in rare circumstances.

I recommend using semantic line breaks when writing, since it makes versioning easier:

#quote(block: true)[
  When writing text with a compatible markup language, add a line break after each substantial unit of thought.
  #footnote[https://github.com/sembr/specification]
]

= Attention

Among the tools in this template is the `colorbox`, an opinionated wrapper around `showybox`#footnote[https://typst.app/universe/package/showybox].
You can pass a named `color: ...` argument (which sets all relevant showybox colors), as well as all arguments accepted by showybox itself, to customize it.

#colorbox[
  Color boxes are great to *summarize* and *focus attention* on key concepts.
]

I don't prescribe a color philosophy, but red is useful to call out Don'ts, e.g.:

#colorbox(color: red)[
  *Don't overdo* color boxes.
  In moderation, interrupting the text helps keep attention, but:
  *if everything is highlighted, nothing is!*
]

I like to add *emphasis* so that the bold parts form a *shortened message* on their own;
useful for getting points across even when students only *skim* the document.

= Code

Code snippets are highlighted using `zebraw`#footnote[https://typst.app/universe/package/zebraw], with a bit of styling applied.
You can also select a subset of lines, as these two examples show:

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  ```java
  public class Main {
    public static void main(String[] args){
      System.out.println("Hello World!");
    }
  }
  ```,
  {
    show: zebraw.with(line-range: lines("2-4"))
    ```java
    public class Main {
      public static void main(String[] args){
        System.out.println("Hello World!");
      }
    }
    ```
  },
)

`zebraw` specifies ranges in $["lower", "upper")$ form (i.e. half-open as usual in programming).
To make this more convenient, the `lines()` function accepts strings like `"2-4, 6, 9-11"` that produces the appropriate ranges---but note that multiple ranges are not supported until pull request #link("https://github.com/hongjr03/typst-zebraw/pull/32")[typst-zebraw\#32] lands.
Only strings like `"2-4"` will work for now.
If you want to use disjoint ranges right now, install the development branches of this template and `zebraw`,
e.g. using `typship`#footnote[https://github.com/sjfhsjfh/typship]:

#zebraw(
  numbering: false,
  ```sh
  typship download https://github.com/TGM-HIT/typst-sew-lecture -c zebraw-next
  typship download https://github.com/SillyFreak/typst-zebraw -c issue/multiple-range
  ```
)

You would then import the template from the `@local` namespace:

#zebraw(
  numbering: false,
  ```typ
  #import "@local/tgm-hit-sew-lecture:0.1.0
  ```
)

== Notes in code

This template adds some handling for putting notes onto code, powered by `pinit`#footnote[https://typst.app/universe/package/pinit]:
write `PINn` somewhere (replacing `n` by a number), and it will form an anchor for your notes.
You should just take care of two things:

- notes must appear on the same page as the anchors, so wrapping the code block in `block(breakable: false)` is recommended, and
- the `PINn` is part of the code when syntax highlighting happens, so avoid making it part of another token:
  ```java int foo;``` and ```java intPIN1 PIN2foo;``` look differently.

#block(breakable: false, {
  ```java
  public class Main {PIN1
    public static void main(String[] args) {PIN2
      System.out.println("Hello World!");PIN3
    }

    intPIN4 PIN5foo;
  }
  ```

  pinit-code-from(1)[Boring]
  pinit-code-from(2)[Boilerplate]
  pinit-code-from(3, color: green.darken(20%), width: 45%)[
    What it's all about
    (if your note is longer than a line, you can specify a `width` to avoid overflowing the page!)
  ]
  pinit-code-from(4, color: red.darken(20%), pin: (-1, -0.1, top+right), offset: (5, -1, left))[not great: not a keyword]
  pinit-code-from(5, color: red.darken(20%), pin: (1, 0.1, bottom+right), offset: (4, 1, left))[This color is used for upper-case identifiers (e.g. constants)---also wrong!]
})

The `pin-code-from` function works a bit differently from `pinit`'s `pinit-point-from`, in that its `pin` etc. parameters accept a pair of _numbers_ instead of there being separate `pin-dx` and `pin-dy` numbers accepting _lengths_.
The distances are specified in terms of the monospace font grid: 1 in x direction is equal to \~4.8pt, for example.
The `pin` and `offset` arrays can further contain an alignment as a third parameter.
For example, `top+left` would make the arrow start or end at that corner of the letter.
More details can be found in the manual.

The pinning functionality is tuned for this template: changing the font or other parts of the raw block geometry will result in the pins not fitting anymore---beware!

= Wrapping text around figures

This is not really a feature of this template, just a tutorial on using `meander`#footnote[https://typst.app/universe/package/meander] for what I found useful in my documents.


#meander.reflow({
  import meander: *

  placed(top+right, boundary: contour.margin(left: 4mm, bottom: 4mm), block(width: 30%)[
    #figure(
      rect(),
      caption: [A rectangle. The figure caption wraps thanks to the fixed width.]
    ) <fig:rect>
  ])

  container()

  content[
    A useful parameter for wrapping figures is `placed(boundary: contour.margin(..), ..)`.
    The `boundary` defines how text should avoid the placed figure, and `contour.margin()` is a simple such boundary that adds a bit of space around your figure.
    I also like to put my figures into fixed-width `block()`s.
    It means that the text may be slightly narrower than necessary to fit the figure, but it makes the layout more robust when writing long figure captions.
  ]
})

== Wrapping text over pagebreaks

#meander.reflow({
  import meander: *

  container(height: 1.3cm)
  pagebreak()

  placed(top+right, boundary: contour.margin(left: 4mm, bottom: 4mm), block(width: 30%)[
    #figure(
      rect(),
      caption: [Another rectangle, at the to of the page.]
    ) <fig:rect2>
  ])

  container()

  content[
    One final trick with `meander` is using multiple containers when the wrapping content overflows a page.
    This is an example of that: the paragraph starts on this page, but flows down onto the next one.
    We also want @fig:rect2 to wrap around that paragraph, to appear at the top of the new page.

    We can't just _not_ make the first paragraph part of the `meander.reflow()` call, since then the figure wouldn't be at the top of the page, but we also can't have all content in a single Meander `container()`.

    However, meander allows multiple containers with explicit pagebreaks in between, and the content will flow between these!
    It's not fully automatic---you have to specify the space left on the page as the height of the first container---but it can achieve this layout.
  ]
})

= Bibliography

This template uses the "chicago-notes" bibliography style.
The bibiliography itself is not rendered, but you can still add citations, like here@arrgh, and will get a footnote.

= License

The `licenses` dictionary contains clickable links to various creative commons licenses, displayed as the corresponding icon (powered by `ccicons`#footnote[https://typst.app/universe/package/ccicons]): #licenses.cc-by-sa-4-0, #licenses.cc-zero-1-0.
If you specify a license through the template, it will be shown in the footer by default.

This document itself is CC-BY, but under normal circumstances (replacing the text with your own material) that license will not apply to you.
The scaffolding alone (calling `set document()` etc.) is too trivial to entail copyright.

= Customization

Some customization knobs are provided, but feel free to fork this template (MIT licensed) if you need more freedom.

== Font

The template uses Noto Sans by default.
Changing the font is supported, but the code note feature may be impacted:
the `pinit-code-from()` function configures line spacing that makes multiline notes line up with code lines.
The used measurements would need to change, which is only supported via forking.
Likewise, changing the raw font via `show raw: set text(..)` will mess up the monospace grid measurements that `pin-code-from()` is based on.

== Header & footer

Both header and footer are divided into three equal-width parts;
some of them have default values which you can find in the manual.
The template further overrides some of these defaults, so that the outcome is this:

- Header: course/audience description; short version of the title; date-based version number
- Footer: copyright note including author, year and license; page number; institution

You are of course free to use any other header/footer content you like.
