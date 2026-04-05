
#import "@preview/wenyuan-campaign:0.1.0": *
// #import "../campaign.typ": *

#show: conf.with()

#make-title(
  [The Holy Path],
  subtitle: [A sample wenyuan-campaign document],
  author: [燕文院 Yanwenyuan],
  date: [2024]
)

#outline(indent: 1em)

= A New Adventure

#drop-paragraph(small-caps: "This package is designed to aid you in")[
  writing _ahem_ possibly beautiful typeset documents for the fifth edition of the world's greatest roleplaying game (or any roleplaying game, for that matter).  It starts by
  adjusting the section formatting from the
  defaults in typst to something a bit more familiar
  to the reader. The chapter formatting is
  displayed above.
]

// unfortunately typst's paragraph indenting doesn't indent the paragraph after a drop cap paragraph
#bump() Most of this text is copied from #link("https://www.overleaf.com/latex/templates/d-and-d-5e-latex-template/vmfdkjfhfynv.pdf")[The DnD 5e LaTeX book] but adjusted for typst, to give an example of how this works. 

Top level titles are placed at the top as _chapter titles_. Please ensure you pagebreak before a new chapter title else it will be placed wonky.

This module uses various fonts (#link("https://github.com/yanwenywan/typst-packages/tree/master/wenyuan-campaign/0.1.0/template/fonts")[Download them here]):

- *TeX Gyre Bonum* is the main body and title text.
- *Scaly Sans* is the sans-serif font that is used in comments. (*Scaly Sans Caps* for small caps)
- *Royal Initalen* is the drop-caps title font. 
- *KingHwa_OldSong* is the CJK font.

`droplet` is needed for the drop caps.

== Section 

Sections break up chapters into large groups of
associated text. These are second level titles.

=== Subsection

Subsections further break down the information
for the reader. These are third level titles.

==== Subsubsection

Subsubsections are the furthest division of text
that still have a block header. These are fourth level titles. Titles below these are not styled, use at your own risk. Note that these and below will not appear in the outline.

#namedpar("Paragraph")[
  The `namedPar(title)[]` function creates a named paragraph, formatted how you'd expect it to be in the books. If this paragraph is below a block, then the auto-indenting wont work (due to typst's seeming lack of universal indent, PR if I'm wrong), use `bump()` at the start to bump it up.
  ]

#namedpar-block("Paragraph")[If you like your named paragraphs to not be indented, use `namedParBlock()`. This is a block though and requires the subsequent paragraph to be bumped.]

== Special Sections


This module also includes the `beginItem[]` environment for items and spells, with commands under the `item` name. The two main commands of note are `item.smalltext[]` and `item.flavourtext[]`. Named paragraphs are done with 3rd level headings.

#begin-item[
  = Automatic Titling Machine 

  #item.smalltext[Magic item, rare, requires attunement]

  #item.flavourtext[
    A wondrous machine of strange make, rusted yet somehow running smoothly. When put into a block on its own, it opens up a whole new world of styling.
  ]

  Automatic titling machines are scope-dependent mechanical devices that recreates show rules to make new environments for its text.

  === Automatic titling 
  Once per scope, the automatic titling machine silently can run a `show` command from a submodule, letting you use typst structures in new and interesting ways.
]

#begin-item[
  = Beautiful Typesetting
  
  #item.smalltext[4nd-level illusion]

  === Casting time
  1 action \
  === Range 
  5 feet \
  === Components
  M (an existing document) \
  === Duration
  Until the document is read

  You are able to transform a written message of
  any length into a beautiful scroll. All creatures
  within range that can see the scroll must make a
  wisdom saving throw or be charmed by you until
  the spell ends.

  While the creature is charmed by you, they
cannot take their eyes off the scroll and cannot
willingly move away from the scroll. Also, the
targets can make a wisdom saving throw at the
end of each of their turns. On a success, they
are no longer charmed.
]

// this is also necessary for good top level title alignment
#pagebreak()

= Text Boxes

This module has several text boxes for you to use. Different block environments can be used for different effect.

#readaloud[
  This is the `readAloud(content)` environment. Truly, a mysterious place that prompts the imagination.

  Supposedly, paragraphs do not indent here. I guess that is true.
]

== Besides, Becomments

Besides the readaloud, there are a couple other things which may be useful. Such as the comment box:

#comment-box(title: "This is a comment box!")[
  A `commentBox(title: [], content)` is a box for minimal highlighting of text. It lacks the ornamentation of `fancyCommentBox`. This is also themable.
]

#bump() If you want to go extra fancy, you can use the fancyCommentBox. This is a recreation of the `DndSidebar` of the latex module, but because of typst's flexibility, this should handle being breakable no problem. If you want, you can choose to float it too like any other block.

#fancy-comment-box(title: "This is a fancy comment box!")[
  This comment box is decorated to look fancier than usual. 

  The LaTeX DndSidebar is a float element, but this one is inline. You should be able to place it though.
]

== Tables and More Tables

By default tables have no stroke. You can make a DnD-style table by using `#dndtable()`, the _exact same way_ you'd make a regular table.#footnote[In a dndtable, you cannot set the stroke, fill, or inset.] Due to a current limitation in typst, the header row is not automatically bolded, you will have to do that yourself.

#sctitle[Make a nice title with `sctitle`]
#dndtable(
  columns: (auto, 1fr),
  table.header[*d2*][*Items*],
  [1], [An apple],
  [2], [Certain death]
)

It is recommended to `#place` figures (like #ref(<snakecaller>)) with `float: true, scope: "parent"` for best results, as that spans columns.

#place(
  bottom + center,
  float: true,
  scope: "parent",
  [
    #figure(
      image("snakecaller-guild.png", width: 100%),
      caption: [The Snakecallers of Ashralan]
    ) <snakecaller> 
  ]
) 


#pagebreak()

= Monsters and NPCs

Some time ago I made a simple statblocks module #link("https://github.com/yanwenywan/typst-packages/tree/master/dndstatblock")[which you can find here]. This is included in the project under the *`stat`* name. Use `beginStat[]` to start.


#begin-stat[
  #stat.statheading("Snakecaller Acolyte", desc: "Medium humanoid, neutral evil")

  #stat.mainstats(ac: "10 (natural armour)", hp-dice: "2d8")

  #stat.ability(10, 10, 11, 10, 14, 11)

  #stat.skill("Skills", [Insight +4, Persuasion +2, Religion +2]) \
  #stat.skill("Senses", [Passive perception 12]) \
  #stat.skill("Languages", [Common, Snake-tongue]) \
  #stat.skill("Challenge", stat.challenge(1))

  #stat.stroke()

  === Dark Devotion
  The snakecaller acolyte has advantage on saving throws against being charmed or frightened.

  === Speak with Snakes
  A snakecaller acolyte can speak with snakes within 30 ft., and can utter a one word command as an action. The snake must obey unless it would directly hurt itself.

  === Titanic Might 
  As a bonus action, a snakecaller acolye can expend a spell slot to cause its melee weapon attacks to magically deal an extra #stat.dice("3d6") poison damage to a target on hit. This benefit lasts until the end of the turn.

  === Spellcasting
  A cult acolyte is a 2nd level spellcaster. Its spellcasting ability is wisdom (spell save DC 12, +4 to hit with spell attacks). It has the following spells prepared:

  Cantrips (at will): _guidance, light, thaumaturgy_\
  1st level (3 slots): _bane, cure wounds, guiding bolt, sanctuary_

  == Actions 

  === Poison Dagger 
  _Melee weapon attack:_ +2 to hit, reach 5 ft., one target. Hit: #stat.dice("1d4") piercing damage. On a hit, the target must make a constitution saving throw (DC 12) and on a fail be poisoned.

  _Adapted from: Cult Acolyte_
]

Use of it is generally the same as the full statblock module, except all commands must be prepended with the `stat` qualifier. The initialisation, however, has been modified to fit into another document.

#pagebreak()

= Colours

Colours are awful, awful things? You might object: but they are pretty! And I would agree. However, there is one very tiny niggle with them: you can change the theme colour.#footnote[Please express surprise.]

Typst's layouting system is stateless, i.e. you cannot have global variables that change throughout the document. The only way you can do that is by using `state` and `context`, which comes with a very strict set of limitations that has made developing this rather much harder.

As such, there is less freedom with colours in my typst module (sorry). 

#set-theme-colour(colours.dmglavender)

By using the `setThemeColour(color)` command you can set the colour to any colour you want. This will affect the colours of tables, comments, and fancy comments. Whilst you can pick any colour, I recommend the colours included in the package:

#dndtable(
  columns: (1fr),
  table.header[*Colour*],
  [`colours.phbgreen`],
  [`colours.phbcyan`],
  [`colours.phbmauve`],
  [`colours.phbtan`],
  [`colours.dmglavender`],
  [`colours.dmgcoral`],
  [`colours.dmgslategrey (-ay)`],
  [`colours.dmglilac`],
)

The table above has been set to `dmglavender`. The default theme colour is `phbgreen`.

#fancy-comment-box[
  "It's lavender, darling" she said, "very sophisticated. You wouldn't know about it."

  "It's clearly... pinkish." her friend retorted.
]
