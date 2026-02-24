# subpar
Subpar is a [Typst] package for creating sub figures.

```typst
#import "@preview/subpar:0.2.2"

#set page(height: auto)
#set par(justify: true)

#subpar.grid(
  figure(image("/assets/andromeda.jpg"), caption: [
    An image of the andromeda galaxy.
  ]), <a>,
  figure(image("/assets/mountains.jpg"), caption: [
    A sunset illuminating the sky above a mountain range.
  ]), <b>,
  columns: (1fr, 1fr),
  caption: [A figure composed of two sub figures.],
  label: <full>,
)

Above in @full, we see a figure which is composed of two other figures, namely @a and @b.
```
![showcase]

## Contributing
Contributions are most welcome, make sure to let others know you're working on something beforehand so no two people waste their time working on the same issue.
It's recommended to have [`tytanic`][tt] installed to run tests locally.

## Documentation
A guide and API-reference for subpar can be found in its [manual].

[showcase]: /assets/showcase.png
[manual]: ./assets/manual.pdf

[Typst]: https://typst.app/
[tt]: https://github.com/tingerrr/tytanic
