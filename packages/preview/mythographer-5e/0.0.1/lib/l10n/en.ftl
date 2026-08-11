part = Part

chapter = { $t ->
  *[sing] Chapter
   [plur] Chapters
   [short] Ch.
}

## Spell
casting-time = Casting Time
range = Range
component = { $t ->
  *[sing] Component
   [plur] Components
}
duration = Duration

## Feat
prerequisite = Prerequisite

## Monster
armor-class = Armor Class
hit-points = Hit Points
speed = Speed
str = str
dex = dex
con = con
int = int
wis = wis
cha = cha
saving-throw = { $t ->
  *[sing] Saving Throw
   [plur] Saving Throws
}
skill = { $t ->
  *[sing] Skill
   [plur] Skills
}
damage-vulnerability = { $t ->
  *[sing] Damage Vulnerability
   [plur] Damage Vulnerabilities
}
damage-resistance = { $t ->
  *[sing] Damage Resistance
   [plur] Damage Resistances
} 
damage-immunity = { $t ->
   *[sing] Damage Immunity
    [plur] Damage Immunities
}
sense = { $t ->
  *[sing] Sense
   [plur] Senses
}
language = { $t ->
  *[sing] Language
  [plur] Languages
}
challenge = Challenge Rating
proficiency-bonus = Proficiency Bonus

## Actions
actions = Actions
attack = Attack
to-hit = to hit
hit = hit
or = or
when = when

## Innate
innate-spellcasting = Innate Spellcasting
at-will = At will
day-each = day each
day = day

## Spellcasting
spellcasting = Spellcasting
cantrips = Cantrips (at will)

slot = { $t ->
  *[sing] slot
   [plur] slots
}

level = { $n ->
    [1] { $n }st level
    [2] { $n }nd level
    [3] { $n }rd level
   *[other] { $n }th level
}


## Bonus Action
bonus-actions = Bonus Actions

## Legendary Action
legendary-actions = Legendary Actions