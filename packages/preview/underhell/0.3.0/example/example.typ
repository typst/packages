#import "../lib.typ": *

#show: 地狱之下模板.with(
  title: "A Date with Destiny",
  subtitle: "A one-shot adventure for 4 players of levels 1-4 - with dinosaurs",
  author: "Colin Jacobs",
  cover: image("img/party.png", height: 100%),
  paper: "a4",
  logo: image("img/GenericLogo.png", width: 13%),
  fancy-author: true,
  元素系统数据: csv("../../文档/元素系统.csv"),
)

== Element-system demo

Elements are named by their 普通-system term (e.g. 怪动植物). #元素("怪动植物") = 怪动植物 (formal). Switch to the "别名" system for the alias:

#设置元素系统("别名")
Alias system: #元素("怪动植物"), #元素("怪动物"), #元素("地狱") (no alias, falls back to 普通)

#设置元素系统("academic")
Academic: #元素("超级系统") (怪动植物 missing there, falls back to 普通: #元素("怪动植物"))

#设置元素系统("普通")
Back to 普通: #元素("怪动植物")

#outline(title: "Table of Contents\n")
#colbreak()
#heading(outlined: false, level: 1)[Credits]

*Designer* Personface McHumanhead

*Template* Colin Jacobs

*Illustrations* Some artists

#lorem(25)
#pagebreak()

#place(
  top + center,
  float: true,
  scope: "parent",
  clearance: 2em,
)[
= A headline that grabs your attention
]



== Adventure awaits!

#品牌#super("TM") is a fictional world building game.
#lorem(180) OK!

== A location

#lorem(233)

== A hook

#lorem(233)

=== This person

#lorem(45)

=== That person

#lorem(85)

#表格("Random occurences", [*d10*], [*Result*], [1], [A tingling in the extremities], [2-8], [Nothing interesting occurs], [10], [All the PCs burst into flame])

#lorem(150)

*And now we want a page with a big image at the top.*

#顶部图(image("img/dragongold.png", width: 140%))

And here it is.
#lorem(100)

= More things!

#lorem(204)

#lorem(115)



And more here!
#提示框("Look here!")[#lorem(44)]

#lorem(390)

// #lorem(402)
#提示框("Something to note")[#lorem(133)]
#lorem(300)

#底部图(image("img/swordtorn.png", width: 140%))

#lorem(400)
#属性框((
  name: "Monster",
  description: [Large monstrosity, neutral evil],
  ac: [20 (natural armor)],
  hp: [29 (1d10 + 33)],
  speed: [10ft, climb 10ft.],
  stats: (STR: 13, DEX: 14, CON: 18, INT: 5, WIS: 4, CHA: 7),
  skillblock: (
      Skills: [Perception +6, Stealth +5],
      Senses: [darkvision 60ft, passive Perception 13],
      Languages: [-],
      Challenge: [5 (1800 XP)]
  ),
  traits: (
    ("Scary Appearance", [While the monster is being ferocious, enemies are at -2 to all WIS saving throws.]), 
    ("Reaching Tentacles", [The monster has six slimy tentacles. Each tentacle
    can be attacked (AC 20; 10 hit points; immune to psychic damage). Destroying a tentacle makes the monster angry.])
),
  Actions: (
    ("Multiattack", [While the monster remains alive, it is a thorn in the party's side.]), 
    ("Saliva", [If a character is eaten by the monster, it takes 1d10 saliva damage per round.]), 
    ("Tentacle squeeze", [If the monster has captured an enemy, it can squeeze them for 1d12 crushing damage.])
  )
))

== A monster

#lorem(200)

= Notable NPCs

#人物框((
  name: "Old Maggie of the Marsh",
  race: [Human],
  class: [Hedge witch],
  alignment: [Chaotic Good],
  stats: (STR: 9, DEX: 11, CON: 10, INT: 15, WIS: 17, CHA: 13),
  description: [A wizened crone with bright, knowing eyes and hands stained green from years of brewing. She wears a patched shawl and rarely steps outside without her crooked walking stick.],
  background: [Born and raised in the marsh village, Maggie has been the local wise-woman for as long as anyone can remember. Some say she once turned a tax collector into a frog; she neither confirms nor denies it.],
  roleplay: [
    - Speaks in proverbs and riddles ("A still pond hides the deepest fish.")
    - Always offers tea, and is mildly offended if it's refused.
    - Knows everyone's secrets, but only trades them for favours.
  ],
))

#人物框((
  name: "Captain Bren Holloway",
  race: [Half-elf],
  class: [Veteran],
  description: [A weather-beaten soldier with a missing left ear and a crooked smile. Wears a faded militia tabard over well-kept chain.],
  roleplay: [
    - Punctuates every sentence with "right then".
    - Trusts the party only after they've bought him a drink.
  ],
))

= Spells

#法术((
  name: "Dancing Legs",
  spell-type: [2nd level evocation],
  properties: (
    ("Casting time", [Special]), 
    ("Range", [Self]), 
    ("Duration", [Until long rest]), 
    ("Components", [V, S]), 
  ),
  description: [Your legs start dancing, and you dance compulsively, and in an experimental fashion. #lorem(20)]
  )
)

#法术((
  name: "Clapping Hands",
  spell-type: [2nd level evocation],
  properties: (
    ("Casting time", [Special]), 
    ("Range", [Self]), 
    ("Duration", [Until long rest]), 
    ("Components", [V, S]), 
  ),
  description: [Your legs start dancing, and you dance compulsively, and in an experimental fashion. #lorem(20)]
  )
)
