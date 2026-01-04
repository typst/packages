# Typst Package for Pathfinder 2nd Edition

Have full control over your Pathfinder 2nd Edition (PF2e) content with this easy-to-use [Typst](https://typst.app/docs) template. With print-friendly design, customizable themes, and Pathfinder specific elements like the Three Action Economy icons, this kit provides almost everything you need to get your adventure documents looking perfect for next session.

Check out the example [document]() and the resulting [PDF file]().

This was made to really capture the look and feel of PF2e Remastered. While sites like [scribe](https://scribe.pf2.tools/) offers incredible markdown formatting for PF2e materials, it's color set is still based on the prior version of PF2e. This project provides that updated color scheme as well as takes advantage of Typst's superior markup language. 

## Example

If you are familiar with Markdown or the MediaWiki syntax, typst won't feel too different. You can check out the [typst syntax](https://typst.app/docs/tutorial/) for reference. Here is what a very simple document might look like:

```typst
#import "@preview/pf2e-style:0.1.0": *
#show: pf-stylization

= Getting Started

Read or paraphrase the following to begin the adventure. <s>

#readAloud[The autumn wind carries the scent of woodsmoke and baked goods as you crest the hill overlooking Palo Monte. Below, the city's lanterns flicker to life against the twilight, their glow reflecting in the River Sable that cuts through the city like a silver scar. But the journey has been long, and the chill bites deeper with each passing mile.
== Palo Monte
```

This would render like this:

![docs/img/snippet.png](https://gitlab.com/Jed_Hed/pf2e-typst/-/raw/main/docs/img/snippet.png?ref_type=heads)

## Usage

To use the template, simply import and use it in your Typst document:

```typst
#import "@preview/pf2e-style:0.1.0": *
#show: pf-stylization // These two lines apply the template
```

## Models

This is what Typst calls different elements in the document. This package includes several tailored towards PF2e materials, but there are bunch of additional functions that Typst offers.

### Action Icons

The staple iconography for the Pathfinder combat. These can be triggered at any time using their corresponding variable.

```typst
Single Action = #A
Double Action = #AA
Triple Action = #AAA
Reaction = #R
Free Action = #F
```

![docs/img/action-chart.png](https://gitlab.com/Jed_Hed/pf2e-typst/-/raw/main/docs/img/action-chart.png?ref_type=heads)

### Creature Statblock

The best way to show off what those actions can do is by putting them against an enemy. Pathfinder has a very unique way of displaying combatants, and this style can be achieved with `statbox`

```typst
#statbox((
  name: "Griznik Sizzlepaw",
  creature: 1,
  trait: ("unique", "small", "goblin", "humanoid"),
  description: "Male goblin baker and entrepreneur",
  details: (([*Perception*], [+7]), ([*Languages*], [Goblin, Common]), ([*Skills*], [Crafting +9, Deception +6, Stealth +8, Survival +7]), ([*Senses*], [Darkvision])),
  extra: (([*Items*], [flour-dusted apron, rolling pin (improvised club), bag of special spices, 3 hot cross buns, small ledger]),),
  stats: (Str: +1, Dex: +4, Con: +1, Int: +0, Wis: +2, Cha: +1),  
  other: (),
  defense: (AC: 16, Fort: +4, Reflex: +9, Will: +7),
  hp: [18],
  traits: (
    ("Goblin Scuttle", [#R *Trigger* A creature ends its movement within 10 feet of Griznik. *Effect* Griznik Strides up to 10 feet without triggering reactions. He must end this movement farther from the triggering creature.]),
    ("Culinary Alchemist", [ #F Griznik can identify any edible substance with a successful DC 15 Crafting check. He gains a +2 circumstance bonus to Crafting checks related to baking or cooking.]),
  ),
  actions: (
    ("Melee", [Rolling Pin #A +9 (agile, nonlethal), *Damage* 1d4+1 bludgeoning]),
    ("Ranged", [Hot Bun Toss #A +9 (range 30 ft.), *Damage* 1d6+1 fire plus 1 persistent fire]),
    ("Flour Bomb", [#AA Griznik throws a handful of specially prepared flour that explodes in a 10-foot burst within 20 feet. Creatures in the area must attempt a DC 17 Fortitude save. \ *Critical Success* No effect. \ *Success* The creature is dazzled for 1 round. \ *Failure* The creature is dazzled for 1 minute and sneezes uncontrollably for 1 round, becoming off-guard. \ *Critical Failure* As failure, plus the creature is blinded for 1 round.]),
    ("Knead Dough", [#AAA Griznik prepares special dough. At the start of his next turn, the dough animates as a Tiny dough golem under his control for 1 minute. The dough golem has AC 14, 10 HP, and can make a Slam attack #AA (+8, 1d4 bludgeoning). Once the golem is defeated or the time runs out, it deflates.]),
  )
))
```

![docs/img/griznik-stats.png](https://gitlab.com/Jed_Hed/pf2e-typst/-/raw/main/docs/img/giznik-stats.png?ref_type=heads)

### Feats

Aside from the action economy, one of the other pinnacle aspects of PF2e is its feats which allow you to build almost whatever possible character you wanted to. 

```typst
#feat((
  name: [Battle Medicine #A],
  level: 1,
  trait: ("General",),
  reqs: ([*Prerequisites* trained in Medicine], [*Requirements* You're holding or wearing a healer's toolkit (page 288).],),
  effect: [You can patch up wounds, even in combat. Attempt a Medicine check with the same DC as for Treat Wounds and restore the corresponding amount of HP; this doesn't remove the wounded condition. As with Treat Wounds, you can attempt checks against higher DCs if you have the minimum proficiency rank. The target is them immune to your Battle Medicine for 1 day. This does not make them immune to, or otherwise count as, Treat Wounds.],
  special: [],
))
```

![doc/img/feat.png](https://gitlab.com/Jed_Hed/pf2e-typst/-/raw/main/docs/img/feat.png?ref_type=heads)

### Spells

Depending on your class, spells can be just as important as feats.

```typst
#spell((
    name: [Fireball #AA],
    level: 3,
    trait: ("Concentrate", "Fire", "Manipulate"),
    reqs: ([*Traditions* arcane, primal], [*Range* 500 feet; *Area* 20-foot burst], [*Defense* basic Reflex]),
    effect: [A roaring blast of fire detonates at a spot you designate, dealing 6d6 fire damage.],
    crit: [],
    heightened: [*Heightened (+1)* The damage increases by 2d6.],
))
```

![doc/img/spell.png](https://gitlab.com/Jed_Hed/pf2e-typst/-/raw/main/docs/img/spell.png?ref_type=heads)

### Complications

Sometimes the encounter is necessarily a combatants. When these sorts of complications arise, having an easy way to notice and deal with it ought to be handy.

```typst
#complication((
  name: [Crust Catastrophe], 
  trigger: [*Trigger* The party asks about the baker or mentions baked goods within the Undermarket],
  effect: [A sudden cascade of burnt rolls comes tumbling down from a nearby bakery stall, creating a 10-foot square area of difficult terrain. Each party member must attempt a DC 14 Reflex save. \ *Critical Success* The character elegantly dodges the cascade. \ *Success* The character avoids the rolls but slips, landing prone. \ *Failure* The character is buried in burnt pastries, taking 1d4 bludgeoning damage and becoming grabbed]
))
```

![doc/img/complication.png](https://gitlab.com/Jed_Hed/pf2e-typst/-/raw/main/docs/img/complication.png?ref_type=heads)

### Chapter Headers

To really make the title of your work or section stand out since the document will be two columns, you can use `chapHeader`.

```typst
#chapHeader("Chapter 1", "The Introduction", [An excellent way to draw in a reader's attention when they're flipping through your work.])
```

![doc/img/header.png](https://gitlab.com/Jed_Hed/pf2e-typst/-/raw/main/docs/img/header.png?ref_type=heads)

### Tables

PF2e, like other games, have a certain way to lay out tables. While you honestly can put whatever table you want and have it work great, I figured I might as well add an extra component to get that official sort of feel.

```typst
#pftab(
  "Possible Things for the Players",
  columns: 1,
  [The scent of a fresh-baked bread is overpoweringly and inexplicably tinged with the sharp odor of ozone and rust.],
  [The party hears a sudden collective gasp from a crowd as the hands of the great public clock begin to spin backwards],
  [The musky smell of a ruffian kicked out of the local bar catches the party off-guard],
)
```

![doc/img/pfTable.png](https://gitlab.com/Jed_Hed/pf2e-typst/-/raw/main/docs/img/pfTable.png?ref_type=heads)

### Note

A little comment never hurts to add to clear things up.

```typst
#note[
    #boxTop[Where did all of this come from?]
  A local goblin baker, Griznik Sizzlepaw, has recently set up shop in the city. He has been in steep competition with another baker across the street, and the two have essentially been at war since. As of late, the tensions have been getting more heated. If the players make fun of how burnt the rolls are, Griznik will become enraged and hostile towards the party. <s>
]
```

![doc/img/note.png](https://gitlab.com/Jed_Hed/pf2e-typst/-/raw/main/docs/img/note.png?ref_type=heads)

### Attention

Sometimes a note's not enough. For then, it might be important to have something a little more in your face.

```typst
#attention[
    #boxTop[The Bag of Special Spices]
The bag contains Griznik's proprietary "Dragon's Breath Blend"—a mixture of powdered fire-pepper, crushed glow-moss, and crystallized lightning bug extract. When sprinkled on food, the spices cause the meal to crackle with harmless crimson sparks and emit a soft, coppery glow. The consumer feels a warming sensation spreading from their core, gaining resistance 2 to cold damage for the next hour. However, the blend is potent; anyone consuming more than a pinch must succeed at a DC 14 Fortitude save or become Stupefied 1 for 1 minute, seeing harmless flames dance across surfaces and friendly faces appear as grinning devils.
]
```

![doc/img/attention.png](https://gitlab.com/Jed_Hed/pf2e-typst/-/raw/main/docs/img/attention.png?ref_type=heads)

### Read Aloud

When you write, there might be things you need to tell directly to your players. When you do, having a way to distinguish it will make running things a lot easier.

```typst
#readAloud[The autumn wind carries the scent of woodsmoke and baked goods as you crest the hill overlooking Palo Monte. Below, the city's lanterns flicker to life against the twilight, their glow reflecting in the River Sable that cuts through the city like a silver scar. But the journey has been long, and the chill bites deeper with each passing mile.

As you approach the city gates, a most peculiar scent cuts through the evening damp: the warm, yeasty fragrance of fresh bread, but laced with something else—cinnamon that crackles like static, and sugar that glows faintly in the gathering dark. It emanates from a narrow storefront in the Undermarket district, where a hand-painted sign swings in the breeze: "Griznik's Glowing Buns." Perhaps a moment's respite, a warm meal, and a local's knowledge might guide your search better than cold suspicion alone.]
```

![doc/img/readAloud.png](https://gitlab.com/Jed_Hed/pf2e-typst/-/raw/main/docs/img/readAloud.png?ref_type=heads)

## Known Limitation

### Chapter Header does not reach the top of the page

I've been looking for away to adjust the height of the box without affecting the whole x-axis. I have the header placed such that it's covers an adequate portion of the top, but I just can't have it reach the very top of the page without engulfing most everything below it.

I intend to continue looking for ways to remedy that in my free time, but till then it's just something that I'm not sure how to correct.

### First line of the text indents

If you look at official Paizo materials, you'll notice that the first line of text following anything but another paragraph is not indented. Typst doesn't have an easy way to generate this sort of a stylization. To circumvent such, I added a [label](https://typst.app/docs/reference/foundations/label/), `<s>` that you can apply onto a paragraph that you **don't** want to indent. 

If an update to Typst offers an easier way to do this, I'll be swift to get it implemented here.

## Contributing

Feel free to open an Issue to report any bugs, suggest new features, general comments, or help requests. Don't be afraid to share your work either. I would love to see people using this toolkit or making their own tweaks to it!

## License

This project is licensed under the [MIT-0 License](https://fedoraproject.org/wiki/Licensing/MIT-0). As such, you are welcome to use this toolkit to your heart's content:

- Change it however you see fit
- Fork it and redistribute it as you like
- No attribution towards me is necessary (but I wouldn't mind the appreciation 🤣)

Seeing that I am specifically using Paizo's *Pathfinder 2nd Edition Remastered* as influence and a guideline for producing this template, this particular project is licensed under their [Fan Content Policy](https://paizo.com/licenses/fancontent). That policy extends specifically to this toolkit and, as such, does not extend to material generated with it. Please consult [Paizo's licenses](https://paizo.com/licenses) to see what extends to your content generated.

`pf2e-style` uses trademarks and/or copyrights owned by Paizo Inc., used under Paizo's Fan Content Policy (paizo.com/licenses/fancontent). `pf2e-style` is not published, endorsed, or specifically approved by Paizo. For more information about Paizo Inc. and Paizo products, visit paizo.com.”
