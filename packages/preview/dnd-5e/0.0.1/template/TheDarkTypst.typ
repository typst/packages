#import "@preview/dnd-5e:0.0.1": *

#show: dnd-template.with()

#title-page(
  title: [The Dark Typst],
  authors: (
    (name: [Sa1g],
    organization: [#link("github.com/sa1g/dnd-typst-template")]),
  ),
  date: datetime.today().display(),
)

#show-outline()

= Layout

== #flex-heading[Chapters (`==`)][Chapters]

#columns(2)[
  #dnd-dropcap[T][his package is heavily inspired][ by the excellent work of the #link("https://github.com/rpgtex")[*rpgTex*] team and their #link("https://github.com/rpgtex/DND-5e-LaTeX-Template")[*LaTeX D&D template*]. Like its predecessor, this template is designed to help you create beautifully typeset documents for the fifth edition of the world's greatest roleplaying game. It begins by adjusting Typst's default section formatting to a style more familiar to readers. The chapter formatting is displayed above.]

  === Section (`===`)
  Sections divide chapters into major thematic groups.

  ==== Subsection  (`====`)
  Subsections further organize content for clarity.

  ===== Subsubsection (`====`)
  Subsubsections represent the deepest level of division that still uses a block header. Deeper levels display headers inline.

  ====== Paragraph
  The paragraph format is rarely used in the core rulebooks but remains available as an alternative to the "normal" style. It can be set with `======` or the `dnd-par` function.
  // Example: #dnd-par[Paragraph]

  ======= Subparagraph
  The subparagraph format, which includes a paragraph indent, will likely feel more familiar to readers. It can be set with `=======` or `dnd-subpar`.
  // Example: #dnd-subpar[Subparagraph]

  === Special Sections
  This module also provides dedicated functions for multi-line section headers commonly found in rulebooks: `dnd-feat` for feats, `dnd-item` for magic items and traps, and `dnd-spell` for spells.

  #dnd-feat[
    = Typesetting Savant
    == Typst
    You have acquired a package that aids in typesetting source material for one of your favorite games. You have advantage on Intelligence checks to typeset new content. On a failed check, you can seek assistance online at the package's website.
  ]

  #dnd-item[
    = Foo's Quill
    == Wondrous item, rare
    The quill has 3 charges. While holding it, you can use an action to expend 1 charge, causing the quill to leap from your hand and draft a contract suited to your situation. The quill regains 1d3 expended charges daily at dawn.
  ]

  #dnd-spell[Beautiful Typesetting][4th level illusion][1 action][5 feet][S, M][Until dispelled][
    You transform a written message of any length into an exquisite scroll. Each creature within range that can see the scroll must succeed on a Wisdom saving throw or be charmed by you for the spell's duration.

    While charmed in this way, a creature cannot look away from the scroll or willingly move farther from it. A charmed creature can repeat the Wisdom saving throw at the end of each of its turns, ending the effect on itself on a success.
  ]

  === Map Regions
  The `dnd-area` function formats map regions. Numbering is automatic and resets with each new `dnd-area` block.

  #dnd-area[
    = Village of Hommlet
    A small, welcoming village.

    == Inn of the Welcome Wench
    The village's central gathering place.

    == Blacksmith's Forge
    The local blacksmith's workshop.

    = Foo's Castle
    Foo's modest residence, constructed of mud and sticks.

    == Moat
    A shallow ditch crossed by a single plank.

    == Entrance
    A five-foot opening leads to a dirt floor, dimly lit by a hole in the roof above.
  ]
]


== Text Boxes
#columns(2)[
  This module provides three distinct environments to visually set apart text and draw the reader’s attention. The `dnd-readaloud` environment is used for passages meant to be read aloud by the Game Master.


  #dnd-readaloud[
    As you approach this module, you sense that the blood and tears of generations have gone into its making. A welcoming warmth embraces you as you type your first words.
  ]

  #dnd-sidebar()[
    Behold the DndSidebar!
  ][
    The `dnd-sidebar` is designed for supplementary content, such as sidebars. It does not break across columns and works best when used with a figure environment to float it to a page corner, allowing surrounding text to wrap around it.
  ]

  === As an Aside
  The other two environments are `dnd-comment` and `dnd-sidebar`. The `dnd-comment` environment is breakable and can be safely used inline within the main text flow.

  #dnd-comment[This is a Comment Box!][
    A `dnd-comment` provides minimal visual highlighting for text. While it lacks the ornamentation of `dnd-sidebar`, it can be cleanly broken across columns.
  ]
  In contrast, the `dnd-sidebar` is not breakable and is ideally positioned as a floated element, as shown below.

  === Tables
  The `DndTable` style automatically colors even-numbered rows and defaults to the width of a text line.

  #figure(
    table(
      columns: (auto, 1fr),
      table.header[Table head][Table head],
      [January], [The Great Gatsby],
      [February], [To Kill a Mockingbird],
      [March], [1984],
      [April], [The Catcher in the Rye],
    ),
    caption: [Nice Table],
  )
  // To make a table span the full page width, define its columns using `fr` units.
]

== Monsters and NPCs
#columns(2)[
  The dnd-monster environment is used to format monster and NPC stat blocks. The module provides a variety of helper functions to simplify populating these stat blocks.

  While creating monster stat blocks is one of the more complex aspects of this template, we have strived to make the process as straightforward as possible.
  
  Monster sheets can be configured as either single-column or multi-column layouts, depending on your preference.

  The layout generally works well up to three columns, though occasional overshoot in the final column may occur.
]
#v(1fr)
#dnd-monster(
  col: 2,
  merge-dicts(
    dnd-monster-basics(
      [Monster Foo],
      [Medium aberration (metasyntactic variable), neutral evil],
      [9 (12 with #emph[mage armor])],
      [#dnd-dice[3d8 + 3]],
      [30 ft., fly 30 ft.],
      (12, 8, 13, 10, 14, 15),
    ),
    dnd-monster-details(
      senses: [darkvision 60 ft., passive Perception 10],
      languages: [Common, Goblin, Undercommon],
      challenge: 1,
      proficiency-bonus: [1],
    ),
    dnd-monster-innate-spellcasting(
      description: [Foo's spellcasting ability is Charisma (spell save DC 12, +4 to hit with spell attacks). It can innately cast the following spells, requiring no material components:],
      dnd-monster-innate-entry(0, [Misty Steps]),
      dnd-monster-innate-entry(3, [Fog Cloud, Rope Trick]),
      dnd-monster-innate-entry(1, [Identify]),
    ),
    dnd-monster-traits(
      dnd-monster-trait-entry(
        [Duergar Resilience],
        [The duergar has advantage on saving throws against spells and the charmed, paralyzed, and poisoned conditions.],
      ),
    ),
    dnd-monster-spell(
      description: [Foo is a 2nd-level spellcaster. Its spellcasting ability is Charisma (spell save DC 12, +4 to hit with spell attacks). It has the following sorcerer spells prepared:],
      dnd-monster-spell-entry(0, 0, [Blade Ward, Fire Bolt, Light, Shocking Grasp]),
      dnd-monster-spell-entry(1, 3, [Burning Hands, Mage Armor, Shield]),
    ),
    dnd-monster-actions(
      dnd-monster-action-entry(
        name: [Dagger],
        type: [weapon],
        mod: [+3],
        dmg: dnd-dice([1d4 + 1]),
        dmg-type: [piercing],
      ),
      dnd-monster-action-melee-entry(
        name: [Flame Tongue Longsword],
        mod: [+3],
        dmg: dnd-dice([1d8 + 1]),
        dmg-type: [slashing],
        plus-dmg: dnd-dice([2d6]),
        plus-dmg-type: [fire],
        or-dmg: dnd-dice([1d10 + 1]),
        or-dmg-when: [if used with two hands],
      ),
      dnd-monster-action-ranged-entry(
        name: [Assassin's Light Crossbow],
        mod: [+1],
        range: [80/320],
        dmg: dnd-dice([1d8]),
        dmg-type: [piercing],
        extra: [, and the target must make a DC 15 Constitution saving throw, taking 24 (7d6) poison damage on a failed save, or half as much damage on a successful one.],
      ),
    ),
    dnd-monster-bonus-actions(
      dnd-monster-bonus([Shadow Blend], [#lorem(10)]),
      dnd-monster-bonus([Shadow Blend1], [ASD]),
    ),
    dnd-monster-legendary(
      [The foo can take 3 legendary actions, choosing from the options below. Only one legendary action option can be used at a time and only at the end of another creature's turn. The foo regains spent legendary actions at the start of its turn.],
      dnd-monster-legendary-entry([Move], [The foo moves up to its speed.]),
      dnd-monster-legendary-entry([Danger Attack], [The foo makes a dagger attack.]),
      dnd-monster-legendary-entry(
        [Create Contract (Costs 3 Actions)],
        [The foo presents a contract in a language it knows and waves it in the face of a creature within 10 feet. The creature must make a DC 10 Intelligence saving throw. On a failure, the creature is incapacitated until the start of the foo's next turn. A creature who cannot read the language in which the contract is written has advantage on this saving throw.],
      ),
    ),
  ),
)

== Style and Colors
#columns(2)[
  #dnd-dropcap[S][tyle and color settings can be adjusted dynamically][ to suit your needs. You can apply custom configurations directly within functions like `dnd-area`, `dnd-comment`, `dnd-dropcap`, `dnd-feat`, `dnd-item`, `dnd-readaloud`, `dnd-sidebar`, `dnd-spell`, `dnd-monster`, and others.]
  This is accomplished by passing a configuration object to the function, similar to how you would configure the template using `dnd-template.with`. If you wish to define custom styles or colors, examine `config.typ` in the template and start with `default-config` and `easy-colors`—these will assist you in creating your own unique theme.

  #show: dnd-template.with(
    is-first: false,
    easy-colors(primary: rgb(100, 160, 40), secondary: rgb(140, 180, 20), tertiary: colors.PhbTan),
  )
  === Color Example
  As shown above, the color scheme has been thematically altered. This was achieved by modifying the `easy-colors` configuration within `dnd-template` for this section.

  #dnd-comment[This is a Comment Box!][
    A `dnd-comment` is a box for minimal highlighting of text. It lacks the ornamentation of `dnd-sidebar`, but it can be broken across columns.
  ]

  #dnd-readaloud[
    As you approach this module, you sense that the blood and tears of generations have gone into its making. A welcoming warmth embraces you as you type your first words.
  ]

  #dnd-sidebar()[
    Behold the DndSidebar!
  ][
    The `dnd-sidebar` is used as a sidebar. It does not break across columns and is best paired with a figure environment to float it to a page corner, allowing surrounding text to wrap around it.
  ]

  Colors can also be applied inline. Below is an example:
  #dnd-sidebar(
    config: easy-colors(tertiary: rgb(100, 0, 60)),
  )[
    #set text(fill: white)
    Behold the DndSidebar!
  ][
    #set text(fill: white)
    The `dnd-sidebar` is used as a sidebar. It does not break across columns and is best paired with a figure environment to float it to a page corner, allowing surrounding text to wrap around it.
  ]
  A future release will introduce more streamlined inline support for text color injection, making the process cleaner and more intuitive.
]

#show: dnd-template.with(
  is-first: false,
)

#dnd-image-heading-part(
  rect(fill: orange, height: 100%, width: 100%),
  [Stylized\ Level 1 Heading\ #text(size: 0.5em)[The orange background simulates an image #footnote[It's not a real image to reduce the size of the template.]]#v(7em)],
  title-unstyled: [Custom Images],
)
// #dnd-image-heading-part(image("/img/behind-header-example.jpg"), [Stylized\ Level 1 Heading #v(7em)], title-unstyled: [Custom Images])

#columns(2)[
  #dnd-dropcap[U][sing functions like `dnd-image-heading-section`][ and `dnd-image-heading-part`, you can easily overlay or place images behind your `level-1` (=) and `level-2` (==) headings.

    Due to Typst's internal layout behavior, a full-page image requires its own dedicated page. Therefore, the template only supports full-page images for level-1 headings.
  ]
]
#dnd-image-heading-section(rect(fill: red, height: 20em, width: 62em), 2, [A New Beginning'])
// #dnd-image-heading-section(image("<your-image>"), 2, [A New Beginning'], )
// #dnd-image-heading-section(image("/img/over-header-example.png", height: 39em), 2, [A New Beginning'], )
#columns(2)[
  // Currently, Typst has a #link("https://github.com/typst/typst/issues/4763")[*known bug*] where image heights are not measured correctly. As a result, when placing an image above a heading, you must explicitly specify its dimensions, as shown in the commented example above.

  *The red rectangle simulates an image.*

  Note that the chapter counter resets between parts, following the convention used in official D&D publications.

  === Image Credits
  The sample background image is sourced from #link("https://lostandtaken.com/")[Lost and Taken].
]