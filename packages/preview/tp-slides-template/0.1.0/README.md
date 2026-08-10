# tp-slides-template

A [Télécom Paris](https://en.wikipedia.org/wiki/T%C3%A9l%C3%A9com_Paris) themed [Touying](https://github.com/touying-typ/touying) presentation template for Typst.

Based on [gh-minimal-slides](https://github.com/xingjian-zhang/gh-minimal-slides) by Jimmy Zhang.

## Features

- Télécom Paris color scheme, automatically passed to [Lilaq](https://github.com/lilaq-project/lilaq) plots
- Boxes for different purposes (theorems, results, remarks, warnings)
- Bibliography slide
- Adjusted title padding

## Usage

```typst
#import "@preview/touying:0.7.3": *
#import "@preview/tp-slides-template:0.1.0" as tp

#show: tp.register.with(
  theme:   "light",
  accent:  "telecom-paris",
  density: "comfy",
)
```

## License

MIT — see [LICENSE](LICENSE).
