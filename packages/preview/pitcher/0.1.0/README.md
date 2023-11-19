# Pitcher 
A simple and modern slideshow tool featuring configurable theme with automatic color palette selection.

---

## Usage

```typst
#import "@preview/pitcher:1.0.0": *

#let style = define_style(color: rgb("#3271a8"), font: "IBM Plex Sans")

#show: slides.with(
  title: "Pitcher Slides",
  description: "simple and modern",
  style: style,
  title_color: true,
)

#new_slide()

#outline()

#new_slide()

= My First Pitcher Slide
#figure(
  image("image.svg")
)

#new_slide()

#animated_slide(
  style,
  [= My Second Pitcher Slide],
  [1. my first point],
  [2. my #text(fill: style.secondary_color)[second] point],
)
```

![screenshot of the first generated slide](./assets/example_1.png)
![screenshot of the second generated slide](./assets/example_2.png)
![screenshot of the third generated slide](./assets/example_3.png)
![screenshot of the fourth generated slide](./assets/example_4.png)
![screenshot of the fifth generated slide](./assets/example_5.png)
![screenshot of the sixth generated slide](./assets/example_6.png)
