#import "@preview/pmetrika:0.1.0": conf

#show: conf.with(
  // These arguments are optional, but you likely need all of them in a paper.
  title: [A Typst Template for _Psychometrika_],
  abstract: lorem(20),
  section: "application and case studies - original",
  keywords: ("Typst", [_Psychometrika_], "typesetting"),
)

// NOTE: Some of the files referenced in this template are not included in distribution,
// this file won't compile before you replace/remove them!

= Start Writing as You Normally Would!

And they will be styled by the template automatically.

== Headings Are in Psychometrika Style

#grid(
  columns: (1fr, 1fr),
  [
    #figure(
      image("data-point.png", width: 80%),
      caption: [XKCD Comic: When one of your data points is really cool, devote a
        whole figure to it. @data-point],
    )
  ],
  [
    // A workaround to make sure the Note sticks together with the figure with
    // auto placement
    #place(
      auto,
      float: true,
      block(breakable: false)[
        #figure(
          table(
            columns: 5,
            table.header(
              [Oct 2025],
              [Oct 2024],
              [Programming Language],
              [Ratings],
              [Change],
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

        / Note: Term lists with a single term named `Note` will be treated as a figure
          note.

        $ H(X) = -sum_(i=1)^n p(x_i) log_2 p(x_i) $
      ],
    )
  ],
)

= Advanced Styling

You may want to import some of the predefined style elements:

#import "@preview/pmetrika:0.1.0": color-heading

```typst
#import "@preview/pmetrika:0.1.0": color-heading
#text(fill: color-heading)[word]
```

So that you can have a #text(fill: color-heading)[word] colored like a heading!

When in doublt, consult the
#link("https://github.com/sghng/pmetrika/blob/main/lib.typ")[source code] to
see how things work.

#bibliography("refs.bib") // pass actual path to your bib!

= Sections After Bib Are Treated as Appendices

#lorem(64)
