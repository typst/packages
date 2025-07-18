# Typst DND5E template

This is a [Typst](https://typst.app) template for DND 5E content, suitable for [DMs Guild](https://www.dmsguild.com) and the like.

The template is called "dragonling" and can be imported as: `#import "@preview/dragonling:0.2.0": *`

**Note:** This package has been updated for compatibility with the latest version of Typst (0.13) and is ready for submission to Typst Universe.

See the [example](https://github.com/coljac/typst-dnd5e) which should mostly be self explanatory - it includes examples of tables, stat blocks and breakout boxes, and should serve as a good starting point for your own content.

![example_img](https://github.com/coljac/typst-dnd5e/assets/191407/76bbb6fc-70fb-4766-b40c-37b1a090422b)

## Basic usage

The `dndmodule` template sets up your document for you. The arguments you may want to specify up front are as follows:

- `title`: The document's title, this will be rendered as text. Omit if you already have cover art with the title.
- `subtitle`: A slug line for down the bottom of the front cover.
- `author`: Your name.
- `cover`: An `image` to use on the front cover
- `fancy_author`: This will put the author's name in that red flame thingy that D&D books tend to have.
- `logo`: Supply an `image` to put the logo on the front page.
- `font_size`: Defaults to `12pt`.
- `paper`: Defaults (sensibly) to `a4` (Americans, you might want `us-letter`).
- `add_title`: (bool) Whether to print the title on the front page. Set to false if you've made your own image, for instance. 

From there, just about everything you need can be done with basic Typst markup. Some convenience functions are provided in the template:

`dnd`: Prints "Dungeons & Dragons" in small caps, as required per the official style guide.

`dndtab(name, columns: (1fr, 4fr), ..contents)`: A table with the conventional formatting. Defaults to 2 columns with ratio 1:4 as shown.

`breakoutbox(title, contents)`: Inserts a box with coloured background, and the optional title in small caps.

`statbox(stats)`: Accepts a dictionary with the following format. The `skillblock` and `traits` can contain arbitrary keys. After the traits, any of "Actions", "Reactions", "Limited Usage", "Equipment", or "Legendary Actions" will be subsequently shown if present.

```
#statbox((
  name: "Creature name",
  description: [Size creature, alignment],
  ac: [20 (natural armor)],
  hp: [29 (1d10 + 33)],
  speed: [10ft, climb 10ft.],
  stats: (STR: 13, DEX: 14, CON: 18, INT: 5, WIS: 4, CHA: 7),  // Modifiers will be auto-calculated
  skillblock: (
      Skills: [Perception +6, Stealth +5],
      Senses: [passive Perception 13],
      Languages: [Gnomish],
      Challenge: [5 (1800 XP)]
  ),
  traits: (
    ("Trait name", [Trait desription]),
    // ..
    ("Trait name", [Trait desription])
),
  Actions: (
    ("Multiattack", [While the monster remains alive, it is a thorn in the party's side.]),
    ("Saliva", [If a character is eaten by the monster, it takes 1d10 saliva damage per round.]),
    ("Tentacle squeeze", [If the monster has captured an enemy, it can squeeze them for 1d12 crushing damage.])
  )
))
```

`spell`: Accepts a dictionary as follows; the properties are all optional:

```
#spell((
  name: "",
  spell_type: [2nd level ...],
  properties: (
    ("Casting time", []),
    ("Range", []),
    ("Duration", []),
    ("Components", []),
  ),
  description: [Spell effects description]
  )
)
```

## Page-wide images and tables

There are two helper functions included with the template, `topfig` and `bottomfig`. This code:

```typst
#bottomfig(image("swordtorn.png", width=140%))
```

will insert the image at the bottom of the page, spanning both columns like so, and will suppress the footer for that page.

![Bottom fig](https://github.com/user-attachments/assets/8ed0d215-245c-49d9-987a-4c8faf3392c7)

## Acknowledgements

Inspiration from the [DND LaTeX module](https://github.com/rpgtex/DND-5e-LaTeX-Template).
