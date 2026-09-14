# ENS Rennes template for presentations

This package provides a slide template to write presentation in [typst](https://typst.app/home/) based on [touying](https://touying-typ.github.io/).
The template follows the guidelines described in the ENS Rennes graphic charter.

## Font

The ENS Rennes graphic charter require using the Univers font, which you can download at https://font.download/font/univers.

If it is not installed, the font falls back on New Computer Modern Sans, and then CMU Sans Serif.

You can still use the template if none of the above fonts are installed; but the theme will use an arbitrary installed font.

## Configurations

The main function exported by the theme is `ens-rennes-theme`.

```typst
#show: ens-rennes-theme.with(
  aspect-ratio: "4-3",
  config-info(
    title: [ENS Rennes presentation theme],
    subtitle: [You can also add a subtitle],
    mini-title: [ENS Rennes presentation],
    authors: [Janet Doe],
    mini-authors: [Doe],
    date: datetime.today(),
  ),
  department: "info",
  display-dpt: false,
  named-index: true
)
```

It has the following optional arguments:
- `aspect-ratio`: the aspect-ratio of each slide; `"16-9"` by default;
- `department`: your department as a string (`"info"`, `"mktro"`, `"dem"`, `"2sep"`, `"maths"`, `"spen"`);
- `display-dpt`: set to `true` if you want the theme to align with the graphic charter of the department rather than the school's; `false` by default;
- `section-style`: several options to display sections in the header: `"named subsection"` to display section and subsection titles, `"subsection"` to display section titles, and subsection as bullets and `"compact section only"` for a more compact header, with only sections and current subsection displayed. `"named subsection"` and `"subsection"` options are meant to be used with the `slide` function whereas `"compact section only"` is meant to be used with typst titles.

Examples:
```typst
// with "named subsection" or "subsection"
= Section 1

== Subsection 1.1

#slide(title:[Slide 1])[
  Content
]
```
```typst
// with "compact section only"
= Section 1

== Slide 1

Content
```

You can provide additional information in the config-info dictionary:
- `title`: the title of the presentation;
- `subtitle`: the subtitle of the presentation;
- `mini-title`: a shortened version of the title, displayed in the footer. If undefined, the title is displayed in the footer.
- `authors`: the author(s) as content;
- `mini-authors`: a shortened version of the authors, displayed in the footer. If undefined, the authors are displayed in the footer.
- `date`: the date you want to appear in the title page.


## Personalization

### Title of each slide

There are several possibilities for each slide's title:
- `auto` by default, displays the subsection title;
- `none` displays nothing;
- or any custom content, via the optional argument `title` of the `slide` function.

### Add content in the title

The `title-slide` function has an optional argument `additional-content`, if you want to display some other content in the title page, which will appear below the title and other informations.

### Blocks

The template provides two functions for Beamer-like blocks:
- `new-block(kind:content, color:color)`: for a theorem-like block, the title will always be of the form "kind (the title of this particular block)". For instance, here's how to get some usual beamer blocks:
  ```typst
  #let definition = new-block(kind: [Definition], color: rgb("#324c98"))
  #let theorem = new-block(kind: [Theorem], color: rgb("#bf0000"))
  #let corollary = new-block(kind: [Theorem], color: rgb("#bf0000"))
  #let proposition = new-block(kind: [Proposition], color: rgb("#006000"))
  #let lemma = new-block(kind: [Lemma], color: rgb("#324c98"))
  #let example = new-block(kind: [Example], color: rgb("#006000"))
  #let remark = new-block(kind: [Remark], color: rgb("#555555"))
  ```
- `tblock(color:color, title: content, body)`: for a more personalizable block.
