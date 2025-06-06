# Polylux SNS template
In your terminal, launch
```
typst init @preview/sns-polylux-template:0.2.0
```
Then, download the required fonts
- [Roboto Condensed](https://fonts.google.com/share?selection.family=Roboto+Condensed)
- [Raleway](https://fonts.google.com/share?selection.family=Raleway)
and put them into a folder;

[Make them available to the Typst compiler](https://typst.app/docs/reference/text/text/#parameters-font).
⚠️  Make sure to install the static versions, because Typst does not support variable fonts yet.

## Supported `sns-polylux-template` options
+ `aspect-ratio` (default: `16-9`). Also supported `4-3`.
+ `title` (default: `none`): presentation title.
+ `subtitle` (default: `none`): presentation subtitle.
+ `event` (default: `none`): presentation date and institute.
+ `short-title` and `short-event` (default: `title` and `event`, respectively).
+ `logo-1` (default: `none`). The logo must have a light color.
+ `logo-2` (default: `none`). The logo must have a dark color.
+ `authors` (default: `none`). It must be an array. Its elements are placed with a small horizontal displacement.
+ `txt-font` (default `Roboto`): text font.
+ `title-font` (default `Raleway`): title text font.
+ `txt-color1` (default `black`): main text color.
+ `txt-color2` (default `whilte`): second text color.
+ `title-color` (default `rbg(#444444)`): title text color.
+ `size` (default `20pt`): text size.
+ `bkgnd-color` (default `white`): background color.
+ `colormap` (default `sns-theme_sns-colormap`). Use something other than `sns-theme_sns-colormap` and `sns-theme_unipi-colormap` at your own risk. It wants an at least 6 elements array of colors.

## Supported functions
+ `title-slide(body: none, logo: none)`. It produces the title slide. That doesn't affect page counter. By default, if `logo` is `none`, `logo-1` is used.
+ `slide(title: none, subtitle: none, new-sec: false, page-number: true, hide-section: false, body)`. If `new-sec` is `true`, a new section with the name `title` is created. If `new-sec` is a string/a content, a new section is created and its name is `new-sec`. If `page-number` is set to `false`, page numbering is disabled for that slide. If `hide-section` is set to `true`, the section name and the section number is hidden in that slide.
+ `focus-slide(new-sec: none, page-number: true, hide-section: false, body)`. It produces a focus slide. If `new-sec` is not `none`, a new section with the name `new-sec` is created. If `page-number` is set to `false`, page numbering is disabled for that slide. If `hide-section` is set to `true`, the section name and the section number is hidden in that slide.
+ `toc-slide(title: none)`. It produces the Table of Contents. That doesn't affect page counter.
+ `new-section-slide(name)`. It creates a new section which name is `name`. That doesn't affect page counter.
+ `empty-slide(body)`. It creates a new empty slide. That doesn't affect page counter.
