#import "@preview/touying-brandred-uobristol:0.2.0": *
#import callout: *

#show: uobristol-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    logo: emoji.city,
  ),
)

#title-slide()

#outline-slide([Outline])

= First Section

A slide without a title but with some *important* information.

=== Heading of level next to the "slide level"

If the "slide level" is 2, the level-2 heading will be renderred as a new slide, and the level-3 heading will be shown as a special heading.

==== Other headings are renderred as normal

Headings of levels greater than $"slide level" + 1$ are shown as normal.

=== Highlight

The `highlight` is changed to show text like #highlight[this].

#pagebreak()

=== Tables

The lines of tables are shown with the primary color.

#table(
  columns: (1fr, ) * 3,
  align: center,
  inset: .5em,
  table.header[*Column1*][*Column2*][*Column2*],
  [Content], [Content], [Content],
  [Content], [Content], [Content],
)

== Callouts

```typ
#import "@preview/touying-brandred-uobristol:0.2.0": *
#import callout: *
```

#grid(columns: 2, gutter: 1em, align: top)[
  ```typ
  #callout(title: lorem(2))[#lorem(10)]
  ```
  #callout(title: lorem(2))[#lorem(10)]
][
  ```typ
  #callout[#lorem(10)]
  ```
  #callout[#lorem(16)]
]

#grid(columns: 2, gutter: 1em)[
  ```typ
  #tip(title: lorem(2))[#lorem(10)]
  ```
  #tip(title: lorem(2))[#lorem(10)]
][
  ```typ
  #tip[#lorem(10)]
  ```
  #tip[#lorem(16)]
]

#grid(columns: 2, gutter: 1em)[
  ```typ
  #example(title: lorem(2))[#lorem(10)]
  ```
  #example(title: lorem(2))[#lorem(10)]
][
  ```typ
  #example-i[#lorem(10)]
  ```
  #example-i[#lorem(16)]
]

#grid(columns: 2, gutter: 1em)[
  ```typ
  #important(title: lorem(2))[#lorem(10)]
  ```
  #important(title: lorem(2))[#lorem(10)]
][
  ```typ
  #important-i[#lorem(10)]
  ```
  #important-i[#lorem(16)]
]

#pagebreak()

#grid(columns: 2, gutter: 1em)[
  ```typ
  #warning(title: lorem(2))[#lorem(10)]
  ```
  #warning(title: lorem(2))[#lorem(10)]
][
  ```typ
  #warning-i[#lorem(10)]
  ```
  #warning-i[#lorem(16)]
]

#grid(columns: 2, gutter: 1em)[
  ```typ
  #caution(title: lorem(2))[#lorem(10)]
  ```
  #caution(title: lorem(2))[#lorem(10)]
][
  ```typ
  #caution-i[#lorem(10)]
  ```
  #caution-i[#lorem(16)]
]

#pagebreak()

#grid(columns: 2, gutter: 1em)[
  ```typ
  #note(title: lorem(2))[#lorem(10)]
  ```
  #note(title: lorem(2))[#lorem(10)]
][
  ```typ
  #note-i[#lorem(10)]
  ```
  #note-i[#lorem(16)]
]

#grid(columns: 2, gutter: 1em)[
  ```typ
  #refer(title: lorem(2))[#lorem(10)]
  ```
  #refer(title: lorem(2))[#lorem(10)]
][
  ```typ
  #refer-i[#lorem(10)]
  ```
  #refer-i[#lorem(16)]
]

== A long long long long long long long long long long long long long long long long long long long long long long long long Title

A slide with equation:

$ x_(n+1) = (x_n + a/x_n) / 2 $

#lorem(200)

= Second Section

#focus-slide[
  Wake up!
]

== Simple Animation

We can use `#pause` to #pause display something later.

#meanwhile

Meanwhile, #pause we can also use `#meanwhile` to display other content synchronously.

#speaker-note[
  + This is a speaker note.
  + You won't see it unless you use `#let s = (s.math.show-notes-on-second-screen)(self: s, right)`
]

#show: appendix

= Appendix

Please pay attention to the current slide number.