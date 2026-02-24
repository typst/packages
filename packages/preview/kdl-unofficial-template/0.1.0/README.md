# KULT: Divinity Lost unofficial scenario template

This is a typst template for the horror tabletop RPG 'KULT: Divinity Lost'.
It has been designed based on the LaTeX scenario template for Ryan Northcott's memorial scenarios.
The scenario is made for A4 paper and uses the [Mathison](https://www.dafontfree.io/mathison-typeface/) and the [Ubuntu Sans](https://github.com/canonical/Ubuntu-Sans-fonts/releases) font.

To publish a scenario for 'KULT: divinity lost' you must follow the [Helmgast AB - fan content policy](https://helmgast.se/en/meta/fan-content-policy)

> ## Warning
>
> Fonts are not included please download them from the links above and install
> them on your system OR unpack them in a local folder, e.g. `./main/assets/`
> and use the `--font-paths` command line option to compile.

The printer friendly version can be compiled with

```sh
typst compile my-scenario.typ --input printer-friendly=true
```

With a version

```sh
typst compile my-scenario.typ --input version="0.1.0"
```

Or combined

```sh
typst compile my-scenario.typ --input version="0.1.0" --input printter-friendly=true
```

This package provides a template and a few functions, see the example section for more details:

## Basic usage

```typst
#import "preview/kdl-unofficial-template:<version>" as kdl

#show: kdl.template

#kdl.pages.title.with(
  title: "A tall tale",
  author: "Baron von Münchhausen",
  size: 64pt // optional
)()

#kdl.pages.blank
#kdl.pages.blank

#include("./chapters/01-intro.typ")
#include("./chapters/02-pre-gen.typ")
#include("./chapters/03-story.typ")

#bibliography("/template/bibliography.bib", full: true, style: "pensoft")
```

## extra functionality and customization

### Skill stuff

- `skill-tree( fort: 2, will: 1, refl: "0")` has named arguments `fort`, `will`, `refl`, `reas`, `char`, `intu`, `viol`, `perc`, `cool`, `soul` omitted arguments will just be left empty for the player to be filled in, when printing the skill tree.
- `attrs` a dictionary with `name` and `move` for each attribute (`fort`, `will`, `refl`, `reas`, `char`, `intu`, `viol`, `perc`, `cool`, `soul`, and `dis` for disadvantages), example usage `kdl.attrs.intu.name`, this is to mostly for consistency.

### Pageref

- `pageref(<label>)`: will display the page the label is found

### Styling

- `colors`: defines the following colors, these respect `printer-friendly`
  - `primary`
  - `secondary`
  - `accent`
  - `light`
  - `dark`
  - `text`
- `fonts` - defines the fonts for this template
  - `title`: Mathison
  - `normal`: Ubuntu
- `pages`
  - `toc`: table of contents
  - `blank`: a blank red page (omitted in printer friendly version)
  - `title`: best use as follows
    ```
    #kdl.pages.title.with(
      title: "A tall tale",
      author: "Baron von Münchhausen",
      size: 64pt // optional
    )()
    ```
- `is-printer-friendly`, if the printer-friendly option has been passed in
- `initialized` for initial letters/drop captions
- `move( title: [], tag: "", description: [])` allows you to define custom moves, advantages, disadvantages or custom moves, title and description can be any formatted content and will be left empty if omitted, label needs to be globally unique and is used to refer to a move e.g. with `pageref`.
  Optionally you move has the following named fields:
  - `attribute`: the attribute to roll for this move (e.g. `kdl.attrs.char.name`)
  - `success`: description of the move's outcome on a success (15+), this can be any formatted content, including text, lists etc.
  - `complications`: description of the move's outcome on a success with complications (10-14), this can be any formatted content
  - `failure`: description of the move's outcome when the roll is failed (9-), this can be any formatted content
  - `more`: any additional formatted content, e.g. list of options or edges

### Trackers

Boxes to tick

- `experience`
- `advancements`
- `stability`
- `wounds`

#
