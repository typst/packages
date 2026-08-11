#import "config.typ"
#import "core.typ"
#import "utils.typ"

#import "external.typ"

#let dnd-dice(body) = {
  assert(body.has("children") or body.has("text"))
  text[#body.fields()]

  let n-array = none
  if body.has("children") {
    n-array = (body.children.at(0).text).split(regex("[d]")).map(int)
  }
  if body.has("text") {
    n-array = body.text.split(regex("[d]")).map(int)
  }

  let hp-no-sum = int(n-array.at(0) * (n-array.at(1) / 2 + 0.5))
  if body.has("text") {
    return text[#hp-no-sum (#body)]
  } else {
    let modifier = int(body.children.at(body.children.len() - 1).text)
    let hp-no-sum = hp-no-sum + modifier
    return text[#hp-no-sum (#body)]
  }
  return none
}

#let monster-ability-scores(body) = {
  assert(type(body) == array and body.len() == 6)

  let modifiers = ()
  for i in body {
    modifiers.insert(modifiers.len(), int(i / 2) - 5)
  }

  let mod-names = ("str", "dex", "con", "int", "wis", "cha")

  let out = (:)
  for (i, val) in modifiers.enumerate() {
    let name = mod-names.at(i)
    // TODO: translate
    // let name = external.transl(mod-names.at(i), str)

    let point = body.at(i)

    if val > 0 {
      val = "+" + str(val)
    }

    let desc = str(point) + " (" + str(val) + ")"

    out.insert(name, desc)
    // out.insert(name, ("name": name, description: "description"))
  }

  return out
}


#let monster-red-bar(self) = {
  v(-0.5em)
  polygon(
    fill: self.fill.monster.bar,
    (0pt, 0pt),
    (100%, 1.5pt),
    (0pt, 3pt),
  )
  v(-0.5em)
}

#let monster-challenge-to-xp(body) = {
  assert(body.has("text") and body.text != "")

  let conversion = (
    "0": 10,
    "1/8": 25,
    "1/4": 50,
    "1/2": 100,
    "1": 200,
    "2": 450,
    "3": 700,
    "4": 1100,
    "5": 1800,
    "6": 2300,
    "7": 2900,
    "8": 3900,
    "9": 5000,
    "10": 5900,
    "11": 7200,
    "12": 8400,
    "13": 10000,
    "14": 11500,
    "15": 13000,
    "16": 15000,
    "17": 18000,
    "18": 20000,
    "19": 22000,
    "20": 25000,
  )

  return [#body (#conversion.at(body.text) XP)]
}

#let monster-line(title, self) = {
  v(-7pt)
  text(size: self.font.monster.subtitle.size, fill: self.fill.monster.title)[
    #utils.call-if-fn(self.font.monster.subtitle.style, [#title])
  ]
  v(-12pt)
  line(stroke: 0.7pt + self.fill.monster.title, length: 100%)
  v(-6pt)
}

#let monster(self, body) = [
  #text(
    size: self.font.monster.title.size,
    weight: self.font.monster.title.weight,
    font: self.font.monster.title.font,
    fill: self.fill.monster.title,
  )[
    #utils.call-if-fn(self.font.monster.title.style, body.name)
  ]
  #linebreak()
  #set text(font: self.font.monster.font, size: self.font.monster.size)
  #emph(body.type)
  #monster-red-bar(self)

  #for (k, e) in body.basics.pairs() {
    text(fill: self.fill.monster.title, weight: self.font.monster.title.weight)[
      #if k == "armor-class" {
        [#external.transl("armor-class"): ]
      } else if k == "hit-points" {
        [#external.transl("hit-points"): ]
      } else if k == "speed" {
        [#external.transl("speed"): ]
      }
    ]
    e
    linebreak()
  }
  #monster-red-bar(self)

  #let modifiers = ()
  #for key in body.ability-scores.keys() {
    modifiers.insert(modifiers.len(), external.transl(key))
  }


  #v(-4pt)
  #table(
    fill: none,
    align: center,
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    row-gutter: -0.7em,
    ..modifiers.map(pair => text(upper(pair), weight: "bold")),

    ..body.ability-scores.pairs().map(pair => pair.last())
  )
  #v(-4pt)
  #monster-red-bar(self)

  #for (k, e) in body.details.pairs() {
    if k == "challenge" or k == "proficiency-bonus" {
      break
    }

    text(fill: self.fill.monster.title, weight: self.font.monster.title.weight)[
      #if e != none {
        let sing-or-plur = "sing"
        if (e.text.split(regex("[,]")).len() > 1) {
          sing-or-plur = "plur"
        }
        if k == "saving-throw" {
          [#external.transl("saving-throw", t: sing-or-plur) ]
        } else if k == "skills" {
          [#external.transl("skill", t: sing-or-plur) ]
        } else if k == "damage-vulnerabilities" {
          [#external.transl("damage-vulnerability", t: sing-or-plur) ]
        } else if k == "damage-resistances" {
          [#external.transl("damage-resistance", t: sing-or-plur) ]
        } else if k == "damage-immunities" {
          [#external.transl("damage-immunity", t: sing-or-plur) ]
        } else if k == "senses" {
          [#external.transl("sense", t: sing-or-plur) ]
        } else if k == "languages" {
          [#external.transl("language", t: sing-or-plur) ]
        }
      }
    ]

    if e != none {
      [#e]
      linebreak()
    }
  }
  #v(-4pt)
  #grid(columns: (1fr, 1fr), align: (left, right))[
    #text(fill: self.fill.monster.title, weight: self.font.monster.title.weight)[#external.transl("challenge")]
    #body.details.challenge
  ][
    #if body.details.proficiency-bonus != none {
      text(fill: self.fill.monster.title, weight: self.font.monster.title.weight)[#external.transl(
        "proficiency-bonus",
      )]
      body.details.proficiency-bonus
    }
  ]
  #monster-red-bar(self)

  // Traits
  #if body.traits != none {
    for (k, e) in body.traits {
      [#emph[*#k.*] #e]
    }
  }

  // Actions
  #if body.actions != none or body.innate != none or body.spellcasting != none {
    monster-line([#external.transl("actions")], self)
    v(-12pt)
  }
  // Actions
  #if body.actions != none {
    for action in body.actions {
      // is it melee, ranged or both?
      let distance = none
      let reach = none
      if "melee" in action.distance.text and "ranged" in action.distance.text {
        distance = "Melee or Ranged"
        reach = [reach #action.reach ft. or range #action.range ft.]
      } else if "melee" in action.distance.text {
        distance = "Melee"
        reach = [reach #action.reach ft.]
      } else {
        distance = "Ranged"
        reach = [range #action.range ft.]
      }
      // weapon or spell?
      let weapon = none
      if "weapon" in action.distance.text {
        weapon = "Weapon"
      } else {
        weapon = "Spell"
      }

      linebreak(justify: true)
      [
        #emph[*#action.name.* #distance #weapon #external.transl("attack"):] #action.mod #external.transl("to-hit"), #reach, #action.targets.
        #emph[#external.transl("hit"):] #action.dmg #action.dmg-type
        #if action.plus-dmg != none {
          [and #action.plus-dmg #action.plus-dmg-type.]
        }
        #if action.or-dmg != none {
          [#external.transl("or") #action.or-dmg #action.or-dmg-type #external.transl("when") #action.or-dmg-when.]
        }
        #action.extra
      ]
    }
  }

  // Innate Spellcasting
  #if body.innate != none {
    [#emph[*Innate Spellcasting.*] #body.innate.description]
    v(-12pt)
    for s in body.innate.spells {
      linebreak()
      if s.amount == 0 {
        [#external.transl("at-will"): ]
      } else {
        // Check for comma
        if (s.name.text.split(regex("[,]"))).len() > 1 {
          [#s.amount/#external.transl("day-each"): ]
        } else {
          [#s.amount/#external.transl("day"): ]
        }
      }
      emph[#s.name]
    }
  }

  // Spellcasting
  #if body.spellcasting != none {
    [#emph[*#external.transl("spellcasting").*] #body.spellcasting.description]
    v(-12pt)
    for s in body.spellcasting.spells {
      linebreak()
      if s.level == 0 {
        [#external.transl("cantrips"): ]
      } else {
        // TODO: find an easy way to manage stuff like 1st, 2nd, 3rd, 4th, 5th, ...
        let single-slot = "sing"
        if s.slots > 1 {
          single-slot = "plur"
        }
        [#external.transl("level", n: s.level) (#s.slots #external.transl("slot", t: single-slot)): ]
      }
      emph[#s.name]
    }
  }

  // Bonus Actions
  #if body.bonus-actions != none {
    monster-line([#external.transl("bonus-actions")], self)
    v(-12pt)
    for a in body.bonus-actions {
      linebreak()
      if a.name != none {
        emph[*#a.name.*]
      }
      a.description
    }
  }

  // Legendary Actions
  #if body.legendary != none {
    monster-line([#external.transl("legendary-actions")], self)

    body.legendary.description

    for a in body.legendary.actions {
      linebreak()

      if a.name != none {
        emph[*#a.name. *]
      }
      a.description
    }
  }
]

#let dnd-monster(config: (:), col: 2, body) = core.fn-wrapper(self => {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  let formatted-monster = monster(self, body)
  let header = {
    place(top, dx: -5pt, dy: -5pt, float: true)[#rect(
      fill: self.fill.monster.ribbon,
      stroke: (top: 0.5pt + black, bottom: 0.5pt + black),
      height: 4pt,
      width: 100% + 10pt,
    )]
    v(-15pt)
  }
  let footer = {
    place(bottom, dx: -5pt, dy: +5pt, float: true)[#rect(
      fill: self.fill.monster.ribbon,
      stroke: (top: 0.5pt + black, bottom: 0.5pt + black),
      height: 4pt,
      width: 100% + 10pt,
    )]
  }

  utils.columns-balance(n-cols: col, fill: color.transparentize((self.fill.monster.background), self.fill.monster.transparency),[
    #header
    #columns(col)[
      #formatted-monster
    ]
    #footer
  ])
})


///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///// Monster Builder

#let dnd-monster-basics(name, type, armor-class, hit-points, speed, ability-scores, ..traits) = {
  return (
    name: name,
    type: type,
    basics: (
      armor-class: armor-class,
      hit-points: hit-points,
      speed: speed,
    ),
    ability-scores: monster-ability-scores(ability-scores),
    traits: traits,
  )
}

#let dnd-monster-details(
  saving-throws: none,
  skills: none,
  damage-vulnerabilities: none,
  damage-resistances: none,
  damage-immunities: none,
  senses: none,
  languages: none,
  challenge: none,
  proficiency-bonus: none,
) = {
  if senses == none or languages == none or challenge == none or proficiency-bonus == none {
    panic("A monster must have senses, languages, challenge rating and a proficiency bonus.")
  }

  challenge = monster-challenge-to-xp([#challenge])
  return (
    details: (
      saving-throws: saving-throws,
      skills: skills,
      damage-vulnerabilities: damage-vulnerabilities,
      damage-resistance: damage-resistances,
      damage-immunities: damage-immunities,
      senses: senses,
      languages: languages,
      challenge: challenge,
      proficiency-bonus: proficiency-bonus,
    ),
  )
}

#let dnd-monster-trait-entry(name, description) = {
  return (
    name: name,
    description: description,
  )
}

#let dnd-monster-traits(..traits) = (
  traits: traits.named(),
)

#let dnd-monster-innate-entry(
  amount,
  name,
) = {
  return (
    name: name,
    amount: amount,
  )
}

#let dnd-monster-innate-spellcasting(
  description: [],
  ..innate-spells,
) = {
  if innate-spells.pos().len() == 0 {
    return (
      innate: none,
    )
  }

  return (
    innate: (
      description: description,
      spells: innate-spells.pos(),
    ),
  )
}

#let dnd-monster-spell(description: [], ..spells) = {
  if spells.pos().len() == 0 {
    return (
      spellcasting: (
        description: description,
        spells: none,
      ),
    )
  }

  return (
    spellcasting: (
      description: description,
      spells: spells.pos(),
    ),
  )
}

#let dnd-monster-spell-entry(level, slot, name) = {
  return (
    level: level,
    slots: slot,
    name: name,
  )
}

#let dnd-monster-actions(..actions) = {
  if actions.pos().len() == 0 {
    return (
      actions: none,
    )
  }

  return (
    actions: actions.pos(),
  )
}

#let dnd-monster-action-entry(
  name: str,
  distance: [melee, ranged],
  type: [weapon], // or spell
  mod: none,
  reach: [5 ft.],
  range: [20/60 ft.],
  targets: [one target],
  dmg: none,
  dmg-type: none,
  plus-dmg: none,
  plus-dmg-type: none,
  or-dmg: none,
  or-dmg-type: none,
  or-dmg-when: none,
  extra: none,
) = {
  return (
    name: name,
    distance: distance,
    type: type,
    mod: mod,
    reach: reach,
    range: range,
    targets: targets,
    dmg: dmg,
    dmg-type: dmg-type,
    plus-dmg: plus-dmg,
    plus-dmg-type: plus-dmg-type,
    or-dmg: or-dmg,
    or-dmg-type: or-dmg-type,
    or-dmg-when: or-dmg-when,
    extra: extra,
  )
}

#let dnd-monster-action-melee-entry(
  name: str,
  distance: [melee],
  type: [weapon], // or spell
  mod: none,
  reach: [5 ft.],
  range: none,
  targets: [one target],
  dmg: none,
  dmg-type: none,
  plus-dmg: none,
  plus-dmg-type: none,
  or-dmg: none,
  or-dmg-type: none,
  or-dmg-when: none,
  extra: none,
) = {
  return (
    name: name,
    distance: distance,
    type: type,
    mod: mod,
    reach: reach,
    range: range,
    targets: targets,
    dmg: dmg,
    dmg-type: dmg-type,
    plus-dmg: plus-dmg,
    plus-dmg-type: plus-dmg-type,
    or-dmg: or-dmg,
    or-dmg-type: or-dmg-type,
    or-dmg-when: or-dmg-when,
    extra: extra,
  )
}

#let dnd-monster-action-ranged-entry(
  name: str,
  distance: [ranged],
  type: [weapon], // or spell
  mod: none,
  reach: none,
  range: [20/60 ft.],
  targets: [one target],
  dmg: none,
  dmg-type: none,
  plus-dmg: none,
  plus-dmg-type: none,
  or-dmg: none,
  or-dmg-type: none,
  or-dmg-when: none,
  extra: none,
) = {
  return (
    name: name,
    distance: distance,
    type: type,
    mod: mod,
    reach: reach,
    range: range,
    targets: targets,
    dmg: dmg,
    dmg-type: dmg-type,
    plus-dmg: plus-dmg,
    plus-dmg-type: plus-dmg-type,
    or-dmg: or-dmg,
    or-dmg-type: or-dmg-type,
    or-dmg-when: or-dmg-when,
    extra: extra,
  )
}

#let dnd-monster-bonus-actions(..actions) = {
  return (
    bonus-actions: actions.pos(),
  )
}

#let dnd-monster-bonus(name, description) = {
  return (
    name: name,
    description: description,
  )
}

#let dnd-monster-legendary(description, ..entries) = {
  if entries.pos().len() == 0 {
    return (
      legendary: none,
    )
  }

  return (
    legendary: (
      description: description,
      actions: (entries.pos()),
    ),
  )
}

#let dnd-monster-legendary-entry(name, description) = {
  return (
    name: name,
    description: description,
  )
}

