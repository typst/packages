# Open-science icons for Typst

SVG icons for open-science articles

## Usage

```typst
#import "@preview/scienceicons:0.0.6": open-access-icon

This article is Open Access #open-access-icon(color: orange, height: 1.1em, baseline: 20%)
```

![](https://github.com/curvenote/scienceicons/blob/main/typst/docs/example.png?raw=true)

## Arguments

The arguments for each icon are:

- `color`: A typst color, `red`, `red.darken(20%)`, `color(#FF0000)`, etc. Default is `black`.
- `height`: The height of the icon, by default this is slightly larger than the text height at `1.1em`
- `baseline`: Change the baseline of the box surrounding the icon, moving the icon up and down. Default is `13.5%`.

Additionally the raw SVG text for each icon can be found by replacing `Icon` with `Svg`.

## List of Icons

- arxiv-icon
- cc-by-icon
- cc-nc-icon
- cc-nd-icon
- cc-sa-icon
- cc-zero-icon
- cc-icon
- curvenote-icon
- discord-icon
- email-icon
- github-icon
- jupyter-book-icon
- jupyter-text-icon
- jupyter-icon
- linkedin-icon
- mastodon-icon
- myst-icon
- open-access-icon
- orcid-icon
- osi-icon
- ror-icon
- slack-icon
- twitter-icon
- website-icon
- youtube-icon

## See All Icons

You can browse and see all icons here:

https://github.com/curvenote/scienceicons/tree/main/typst/docs/scienceicons.pdf

![](https://github.com/curvenote/scienceicons/blob/main/typst/docs/icons.png?raw=true)

## Contributing

To add or request an icon to be added to this package see: \
https://github.com/curvenote/scienceicons
