#import "@preview/touying-au-unofficial:0.1.0": touying-au-unofficial

#show: touying-au-unofficial.with(
  aspect-ratio: "16-9",
  config-info(
    title: [A custom presentation theme for Aarhus University],
    subtitle: [Built with Touying],
    author: [Alexander A. Christensen],
    date: datetime.today(),
    institution: [Aarhus University],
    department: [Department of Engineering],
  ),
)

#title-slide()

= This is a section

== This is a subsection (Also used as slide titles)

We can write something as expected.

#pause

and the `#pause()` function also works.

== Here is another slide

We can write some math:
$
  1 + 1 = pause 4
$
#meanwhile

and the `pause` function works inside!

