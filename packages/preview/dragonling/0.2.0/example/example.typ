#import "@preview/dragonling:0.2.0": *

#show: dndmodule.with(
  title: "A Date with Destiny",
  subtitle: "A one-shot adventure for 4 players of levels 1-4 - with dinosaurs",
  author: "Colin Jacobs",
  cover: image("img/party.png", height: 100%),
  paper: "a4",
  logo: image("img/GenericLogo.png", width: 13%),
  fancy_author: true
)

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

#dnd#super("TM") is a role playing game.
#lorem(180) OK!

== A location

#lorem(233)

== A hook

#lorem(233)

=== This person

#lorem(45)

=== That person

#lorem(85)

#dndtab("Random occurences", [*d10*], [*Result*], [1], [A tingling in the extremities], [2-8], [Nothing interesting occurs], [10], [All the PCs burst into flame])

#lorem(150)

*And now we want a page with a big image at the top.*

#topfig(image("img/dragongold.png", width: 140%))

And here it is.
#lorem(100)

= More things!

#lorem(204)

#lorem(115)



And more here!
#breakoutbox("Look here!")[#lorem(44)]

#lorem(390)

// #lorem(402)
#breakoutbox("Something to note")[#lorem(133)]
#lorem(300)

#bottomfig(image("img/swordtorn.png", width: 140%))

#lorem(400)
#statbox((
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

= Spells

#spell((
  name: "Dancing Legs",
  spell_type: [2nd level evocation],
  properties: (
    ("Casting time", [Special]), 
    ("Range", [Self]), 
    ("Duration", [Until long rest]), 
    ("Components", [V, S]), 
  ),
  description: [Your legs start dancing, and you dance compulsively, and in an experimental fashion. #lorem(20)]
  )
)

#spell((
  name: "Clapping Hands",
  spell_type: [2nd level evocation],
  properties: (
    ("Casting time", [Special]), 
    ("Range", [Self]), 
    ("Duration", [Until long rest]), 
    ("Components", [V, S]), 
  ),
  description: [Your legs start dancing, and you dance compulsively, and in an experimental fashion. #lorem(20)]
  )
)
