# dndcampaign

A template for writing RPG campaigns imitating the 5e theme. This was made as a typst version of the $\LaTeX$ package [DnD 5e LaTeX Template](https://github.com/rpgtex/DND-5e-LaTeX-Template), though it is not functionally nor entirely visually similar.

# Dependencies

Packages:
- `droplet:0.3.1`

Fonts: 
- TeX Gyre Bonum
- Scaly Sans
- Scaly Sans Caps
- Royal Initalen
- 京華老宋体 KingHwa OldSong

***Please note: in an effort to reduce the file size of the template, whilst fonts are included in the repository, they are excluded from download explicitly in the TOML.*** You may find the fonts in my [github repository in the fonts folder](https://github.com/yanwenywan/typst-packages/tree/master/dndcampaign/0.1.0/template/fonts).

# Usage

```
typst init @preview/dndcampaign:0.1.0
```

This will copy over all required fonts and comes prefilled with the standard template so you can see how it works. To use this you need to either install all the fonts locally or pass the folder into --font-path when compiling.

# Configuration

To initialise the style, do:

```typ
#import "@preview/dndcampaign:0.1.0": *

#show: conf.with() 
```

Very easy.

You are encouraged to copy the template files and modify them if they are not up to your liking.

# Main Functions

**setThemeColour**`(colour: color)`. 
sets a theme colours from the colours package of this module
or any other colour you want, on you if it looks bad :)
The colours recommended are:
> phbgreen, phbcyan, phbmauve, phbtan, dmglavender, dmgcoral, dmgslategrey (-ay), dmglilac

---

**makeTitle**`(title: content, subtitle: content = [], author: content = [], date: content = [], anythingBefore: content = [], anythingAfter: content = [])`. 
Makes a simple title page.

Parameters:
- title: main book title
- subtitle: (optional) subtitle
- author: (optional)
- date: (optional) -- just acts as a separate line, can be used for anything else
- anythingBefore: (optional) this is put before the title
- anythingAfter: (optional) this is put after the date

---

**dropParagraph**`(smallCapitals: string = "", body: content)`. 
Makes a paragraph with a drop captial

Parameters:
- smallCapitals: (optional) any text which you wish to be rendered in small caps, like how DnD Does it
- body: anything else


---
**bump**`()`. Manually does a 1em paragraph space

---

**namedPar**`(title: content, content: content)`.
A paragraph with a bold italic name at the start

Parameters;
- title: the bold italic name, a full stop / period is put immediately after for you
- content: everything else


---
**namedParBlock**`(title: content, content: content)`.
See namedPar but this one is in a block environment

---
**readAloud**`[]`. A tan coloured read-aloud box with some decorations

---
**commentBox**`(title: content = [], content: content)`.
A theme-coloured plain comment box

Parameters:
- title: (optional) a title in bold small caps
- content

---
**fancyCommentBox**`(title: content = [], content: content)`.
A theme-coloured fancy comment box with decorations

Parameters:
- title: (optional) a title in bold small caps
- content

---
**sctitle**`[]`. Makes a small caps header block

---
**beginStat**`[]`. begins the monster statblock environment

---
**beginItem**`[]`. begins the item environment

# Statblock

***Important.*** Statblocks are provided under the `stat` namespace, and will only work as intended in a `beginStat` block. All statblock functions must be prepended with `stat`.

## stat functions

**dice**`(value:str)` parses a dice string (e.g. `3d6` or `3d6+2` or `3d6-1`) and returns a formatted dice value (e.g. "10 (3d6)"). Specifically, the types of string it accepts are:

> `\d+d\d+([+-]\d+)?` (number `d` number `+/-` number)

(You need to make sure the string is correct)

---

**diceRaw**`(numDice:int, diceFace:int, modifier:int)` is a helper function of the above and can optionally be used -- it takes all values as integer values and prints the correct formatting.

---

**statheading**`(title, desc = [])` takes a title and description, and formats it into a top-level monster name heading. `desc` is the description of the monster, e.g. *Medium humanoid, neutral evil* but can be anything. 

---
**stroke**`()` draws a red stroke with a fading right edge.

---
**mainstats**`(ac = "", hp_dice = "", speed = "30ft", hp_etc = "")` produces the **Armor Class**, **Hit Points**, **Speed** in one go. All fields are optional. `hp_dice` takes a *valid dice string only* -- if you do not want to use dice leave it blank and use `hp_etc`. No restrictions on other fields.

---
**ability**`(str, dex, con, int, wis, cha)` Takes the six ability scores (base value) as integers and formats it into a table with appropriate modifiers.

---
**challenge**`(cr:str)` takes a numeric challenge (as a string) rating and formats it along with the XP (if the challenge rating is valid). All CRs between 0-30 are valid, along with the fractional `1/8`, `1/4`, `1/2` (which can be written in decimal form too, e.g. `0.125`).

---
**skill**`(title, contents)` takes a title and description, and is a single skills entry. For example, `#skill("Challenge", challenge(1))` will produce (in red)

> **Challenge** 1 (200 XP)

(This uses `challenge` from above)

---

**Section headers** such as *Actions* or *Reactions* are done using the second-level header `==`

**Action names** -- the names that go in front of actions / abilities are done using the third level header `===` (do not leave a blank line between the header and its body text) 

# Item

***Important.*** Basic item capability is provided under the `item` namespace, and will only work as intended in a `beginItem` block. All item functions must be prepended with `item`.

## item functions

**Item Name** is done with the top-level header `=`

**Section headers** are the second level header `==`

**Abilities and named paragraphs** are the third level header `===`

---

**smalltext**`[]`. Half-size text for item subheadings

**flavourtext**`[]`. Indented italic flavour text


## Acknowledgments

- The overall style is based on the [Dnd 5e LaTeX Template](https://github.com/rpgtex/DND-5e-LaTeX-Template), which in turn replicate the base DnD aesthetic.
- TeX Gyre Bonum by GUST e-Foundry is used for the body text
- Scaly Sans and Scaly Sans Caps are part of [Solbera's CC Alternatives to DnD Fonts](https://github.com/jonathonf/solbera-dnd-fonts) and are used for main body text. ***Note that these fonts are CC-BY-SA i.e. Share-Alike, so keep that in mind. This shouldn't affect homebrew created using these fonts (just like how a painting made with a CC-BY-SA art program isn't itself CC-BY-SA) but what do I know I'm not a lawyer.***
- [KingHwa_OldSong](https://zhuanlan.zhihu.com/p/637491623) (京華老宋体) is a traditional Chinese print font used for all CJK text (if present, mostly because I need it)

