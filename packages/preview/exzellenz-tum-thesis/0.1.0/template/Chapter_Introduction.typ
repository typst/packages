#import "utils.typ": todo

= Introduction <chapter_introduction>

== Motivation

#todo[Write the thesis]

Because I have to @cite_todo. This is a abbreviation @oidc explained in the glossary.

#lorem(100)

#lorem(100)


== Research Gap

As shown in @figure_dummy, this is wonderful. Typst documentation #footnote(link("https://typst.app/docs")) or that way #footnote[Google einfach]. Look at @eq_einstein or write it $E = M C^2$ inline.

#figure(
    grid(
        columns: 3,     // 2 means 2 auto-sized columns
        row-gutter: 2mm,    // space between columns
        [#image("dummy_image.svg", width: 70%)],
        [#image("dummy_image.svg", width: 70%)],
        [#image("dummy_image.svg", width: 70%)],
        [#image("dummy_image.svg", width: 70%)],
        [#image("dummy_image.svg", width: 70%)],
        [#image("dummy_image.svg", width: 70%)],
    ),
  caption: [
    #lorem(10)
  ]
) <figure_dummy>

#lorem(40)

$
E = M C^2
$ <eq_einstein>

#lorem(60)


#figure(
  {
    set text(size: 0.8em, hyphenate: false, weight: "medium");
    set par(justify: false);
    let gut(it) = [#text(fill: rgb("006600"))[#it]];
    let mittel(it) = [#text(fill: rgb("333300"))[#it]];
    let schlecht(it) = [#text(fill: rgb("660000"))[#it]];
    table(
      columns: (12.2em, 1fr, 1fr, 1fr, 1fr),
      rows: 5em,
      fill: (col, row) => if row == 0 or col == 0 { luma(240) } else { none },
      inset: 5pt,
      align: horizon,
      [], [*Method A*], [*Method B*], [*Method C*], [*Method D*],
      [_property_], [#schlecht[No] #footnote[#lorem(10)] <fntable1>], [#gut[Yes] #footnote[#lorem(10)] <fntable2>], [#gut[Yes] #footnote(<fntable2>)], [#gut[Yes] #footnote(<fntable2>)],
      [_memory_], [#schlecht[No] #footnote(<fntable1>)], [#gut[Yes] #footnote(<fntable2>)], [#gut[Yes] #footnote(<fntable2>)], [#gut[Yes] #footnote(<fntable2>)],
      [_complexity_], [#gut[Low] #footnote[#lorem(10)] <fntable4>], [#gut[Low] #footnote(<fntable4>)], [#schlecht[High] #footnote(<fntable6>)], [#schlecht[High] #footnote(<fntable6>)],
      [_runtime_], [#gut[Low] #footnote(<fntable4>)], [#gut[Low] #footnote(<fntable4>)], [#schlecht[High] #footnote[#lorem(10)] <fntable6>], [#schlecht[High] #footnote(<fntable6>)],
    )
  },
  caption: [
    #lorem(30)
  ]
) <table-comparative-overview-uncertainty-categories>

#lorem(50)

$
W_l = cases(
  c dot  W_l thick \/ thick hat(lambda) #h(2em) & "if" c < hat(lambda) ,
  W_l                                 & thick "otherwise")
$

#lorem(30)


```rust
fn main() {
    println!("Hello World!");
}
```

#lorem(30)

$ mat(
  r_(1,1),r_(1,1), r_(1,1), t_x;
  r_(2,1),r_(2,1), r_(2,1), t_y;
  r_(3,1),r_(3,1), r_(3,1), t_z;
  0,0,0, 1
) $

#lorem(50)