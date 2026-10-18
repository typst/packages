#import "./skills.typ": attrs

#let experience = block(breakable: false)[
*Mark 1 XP $square.stroked$ $square.stroked$ $square.stroked$ $square.stroked$ $square.stroked$ for:*
- Have we discovered anything new about the Truth?
- Have we learned anything new about our characters?
- Have we challenged ourselves?
- Each resolved dramatic hook.

After 5 XP pick one Advancement.
]

#let advancements = block(breakable: false)[
#strong[Choose One of These:]

- $square.stroked.medium$ $square.stroked.medium$ $square.stroked.medium$ $square.stroked.medium$ $square.stroked.medium$ $square.stroked.medium$ Increase one active Attribute +1 (to max +3).
- $square.stroked.medium$ $square.stroked.medium$ Increase one passive Attribute +1 (to max +3).
- $square.stroked.medium$ Increase any one Attribute +1 (to max +4).
- $square.stroked.medium$ $square.stroked.medium$ $square.stroked.medium$ Select a new Advantage from your Archetype.

#strong[After 5 Advancements You May Also Choose:]

- $square.stroked.medium$ $square.stroked.medium$ Increase any one Attribute +1 (to max +4).
- $square.stroked.medium$ $square.stroked.medium$ Select a new Advantage from any Aware Archetype.
- $square.stroked.medium$ End your character’s story arc as you see fit, and create a new Aware character, who starts with 2 Advancements.
- $square.stroked.medium$ Replace your current Archetype with another Aware Archetype, and erase one of your starting 3 Advantages.

#strong[After 10 Advancements You May Also Choose:]
- $square.stroked.medium$ Advance your character to an Enlightened Archetype.
]

#let stability = block(breakable: false)[
  #let numberbox(number) = box(height: 2.95mm, width: 2.95mm, inset: 0.8mm, stroke: 0.4pt, text(size: 6pt, [#number]))
  #table(
    inset: 0% + 4pt,
    stroke: (x,y) => 
     if (0,2,5,9).contains(y) { (bottom: black + 1pt) },
    columns: (5mm, 20mm, 100% - 25mm),
    align: (x,y) => 
      if x == 2 {
        if (1,3,6).contains(y){ right } else { left}
      } else {
        (center)
      },
    numberbox([10]),[Composed],[],
    numberbox([ 9]),[Uneasy],[*Moderate Stress*],
    numberbox([ 8]),[Unfocused],emph[-1 to #attrs.dis.move rolls],
    numberbox([ 7]),[Shaken],[*Serious Stress*],
    numberbox([ 6]),[Distressed],emph[-1 to #attrs.will.move rolls],
    numberbox([ 5]),[Neurotic],emph[-2 to #attrs.dis.move rolls],
    numberbox([ 4]),[Anxious],[*Critical Stress*],
    numberbox([ 3]),[Irrational],emph[-2 to #attrs.will.move rolls],
    numberbox([ 2]),[Frantic],emph[-3 to #attrs.dis.move rolls],
    numberbox([ 1]),[Unhinged],emph[+1 to #attrs.soul.move rolls],
    numberbox([ 0]),[Broken],emph[The GM makes a Move],
)]

#let wounds = block(breakable: false)[
  #table(
    inset: 0% + 4pt,
    stroke: (x,y) => if ((0,5).contains(y) or x == 0) { (bottom: black + 1pt)},
    align: (left, center),
    columns: (100% - 20mm, 17mm),
    row-gutter: 1mm,
    [*Serious Wound* (-1 ongoing)],[Stabilized],
    [],[$square.stroked.big$],
    [],[$square.stroked.big$],
    [],[$square.stroked.big$],
    [],[$square.stroked.big$],
    [*Moderate Stress* (-1 ongoing)],[],
    [],[$square.stroked.big$],
)]

