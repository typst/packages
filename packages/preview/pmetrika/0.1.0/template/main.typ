#import "@preview/pmetrika:0.1.0": conf

#show: conf.with(
  // These arguments are optional, but you likely need all of them in a paper.
  title: [A Typst Template for _Psychometrika_],
  abstract: lorem(50),
  section: "application and case studies - original",
  keywords: ("Typst", [_Psychometrika_], "typesetting"),
)

= Start Writing as You Normally Would!

And they will be styled by the template automatically.

#lorem(50)

== Headings Are in Psychometrika Style

// A workaround to make sure the Note sticks together with the figure with
// auto placement
#place(
  auto,
  float: true,
  block(breakable: false)[
    #align(left, lorem(20))
    #figure(
      table(
        columns: 5,
        table.header(
          [Oct 2025], [Oct 2024], [Programming Language], [Ratings], [Change]
        ),
        [1], [1], [Python], [24.45%], [+2.55%],
        [2], [4], [C], [9.29%], [+0.91%],
        [3], [2], [C++], [8.84%], [-2.77%],
        [4], [3], [Java], [8.35%], [-2.15%],
        [5], [5], [C\#], [6.94%], [+1.32%],
      ),
      caption: [Most popular languages in October 2025: the fierce battle for
        second place in TIOBE Index],
    )

    / Note: Term lists with a single term named `Note` will be treated as a
      figure note.

  ],
)

$ H(X) = -sum_(i=1)^n p(x_i) log_2 p(x_i) $

Citations and references displayed in APA style: @delatorreDINAModelParameter2009.

= Advanced Styling

You may want to import some of the predefined style elements:

```typst
#import "@preview/pmetrika:0.1.0": color-heading
#text(fill: color-heading)[word]
```

When in doublt, consult the
#link("https://github.com/sghng/pmetrika/blob/main/lib.typ")[source code] to
see how things work.

#bibliography("refs.bib") // pass the actual path to your bib file!

= Sections After Bib Are Treated as Appendices

#lorem(64)
