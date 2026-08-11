#import "utils.typ": todo

= Introduction <chapter_introduction>
This is the first chapter of your thesis. Chapters are marked with = and should be contained in their own .typ file for cleanliness.
Chapters, sections, etc. Can be referenced like @chapter_introduction and @section_drafting
== Drafting, Citing and Abbreviating <section_drafting>
This is a section. Each = after the first denotes the level of the heading (== section, === subsection).

If there are things you haven't gotten to yet, it's useful to mark them as a TODO like this: #todo[Find the motivation]. TODOs are enabled when inwriting is enabled and will disappear if you disable it in utils.typ

This is likely the first place you have to list your citations. You can cite a paper in your items.bib like this @turing2021computing. While you are in inwriting mode, this will show up as chicago style so you can see the author and date directly, when you disable inwriting (e.g. when handing in a draft to your supervisor), or manually override the style, it will show as #cite(<turing2021computing>, style: "ieee") (@ieee:short style). A list of available styles and how to use them can be found at the #link("https://typst.app/docs/reference/model/cite/#parameters-style")[Typst documentation]. It is best to double check with your advisor which style to use. If you need to use a different style, change it in the call to the cite function in main.typ.

Another useful concept is the glossary (especially if your thesis is longer). A glossary contains a list of abbreviations, acronyms, etc. In standard fashion, an abbreviation needs to be established in its long version before it can be used. For example: this is a thesis written at the @tum and not @lmu and Typst automatically knows that these acronyms are now established and now I can use @tum and @lmu. However, if I wanted to have it written out in long form again, I can simply write @tum:long. The Glossarium package has a lot of features that might be useful and others that might be overkill, you can read about them on #link("https://typst.app/universe/package/glossarium/")[the package site].

Fun facts can often be expanded upon in footnotes #footnote[These go here and can contain #link("https://google.com")[links to somewhere]] if they don't really fit the bibliography.

== Equations and Code
Equations are either fully expanded and numbered:

$
E = m c^2
$ <eq_einstein>

so that you can cite @eq_einstein in your text, or inline if it's something brief or trivial like $F=m * a$.
These are, of course, simple examples, and if you are not familiar with typst equations, take a look at #link("https://typst.app/docs/reference/math/")[the Typst math reference]. Though if you understand LaTeX, this should not be that hard.

Sometimes it makes sense to write a pseudocode if you want to display the working of an algorithm. This is analogous to many other typesetting systems and supports syntax highlighting for different languages:

```python
def main():
  print('This is python')
```
```java
public static void main(String[] args) {
  System.out.println("This is Java")
}
```

These are blocks, but you can also use inline referencing to certain variables or functions with `main`, which makes it clear that they are not normal text.

Some more math examples:
$
W_l = cases(
  c dot  W_l thick \/ thick hat(lambda) #h(2em) & "if" c < hat(lambda) ,
  W_l                                 & thick "otherwise")
$

$ mat(
  r_(1,1),r_(1,1), r_(1,1), t_x;
  r_(2,1),r_(2,1), r_(2,1), t_y;
  r_(3,1),r_(3,1), r_(3,1), t_z;
  0,0,0, 1
) $

== Figures and Tables
Figures can be referenced easily with @figure_dummy and numbering is automatic based on the order in which they are defined (not referenced).


#figure(
    grid(
        columns: 3,     // 3 auto-sized columns
        row-gutter: 2mm,    // space between rows
        column-gutter: 2mm,    // space between columns
        [#image("figures/dummy_image.jpg", width: 90%)],
        [#image("figures/dummy_image.jpg", width: 90%)],
        [#image("figures/dummy_image.jpg", width: 70%)],
        [#image("figures/dummy_image.jpg", width: 70%)],
        [#image("figures/dummy_image.jpg", width: 70%)],
        [#image("figures/dummy_image.jpg", width: 100%)],
    ),
  caption: [
    A grid figure made up of the same sample image with varying scales.
  ]
) <figure_dummy>

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
    A complex table. Tables need to be inside of figures to make them referenceable.
  ]
) <table-comparative-overview-uncertainty-categories>