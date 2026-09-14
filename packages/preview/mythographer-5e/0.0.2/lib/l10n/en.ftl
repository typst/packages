part = Part

chapter = { $t ->
  *[sing] Chapter
   [plur] Chapter
   [short] Ch.
}

## Spell
casting-time = Casting Time
range = Range
component = { $t ->
  *[sing] Component
   [plur] Components
}
duration = duration

## Feat
prerequisite = Prerequisite


###############################################
##### Monster

### Size
# F: Fine,  D: Diminutive,  T: Tiny,  S: Small,  M: Medium,  L: Large,  H: Huge,  G: Gargantuan,  C: Colossal,  V: Varies.
msize =
    { $msize ->
         [F]
            { $mtype ->
               [aberration] Fine
               [beast] Fine
               [celestial] Fine
               [construct] Fine
               [dragon] Fine
               [elemental] Fine
               [fey] Fine
               [fiend] Fine
               [giant] Fine
               [humanoid] Fine
               [monstrosity] Fine
               [ooze] Fine
               [plant] Fine
               [undead] Fine
               *[other] Fine
            }
         [D]
            { $mtype ->
               [aberration] Diminutive
               [beast] Diminutive
               [celestial] Diminutive
               [construct] Diminutive
               [dragon] Diminutive
               [elemental] Diminutive
               [fey] Diminutive
               [fiend] Diminutive
               [giant] Diminutive
               [humanoid] Diminutive
               [monstrosity] Diminutive
               [ooze] Diminutive
               [plant] Diminutive
               [undead] Diminutive
               *[other] Diminutive
            }
         [T]
            { $mtype ->
               [aberration] Tiny
               [beast] Tiny
               [celestial] Tiny
               [construct] Tiny
               [dragon] Tiny
               [elemental] Tiny
               [fey] Tiny
               [fiend] Tiny
               [giant] Tiny
               [humanoid] Tiny
               [monstrosity] Tiny
               [ooze] Tiny
               [plant] Tiny
               [undead] Tiny
               *[other] Tiny
            }
         [S]
            { $mtype ->
               [aberration] Small
               [beast] Small
               [celestial] Small
               [construct] Small
               [dragon] Small
               [elemental] Small
               [fey] Small
               [fiend] Small
               [giant] Small
               [humanoid] Small
               [monstrosity] Small
               [ooze] Small
               [plant] Small
               [undead] Small
               *[other] Small
            }
         [M]
            { $mtype ->
               [aberration] Medium
               [beast] Medium
               [celestial] Medium
               [construct] Medium
               [dragon] Medium
               [elemental] Medium
               [fey] Medium
               [fiend] Medium
               [giant] Medium
               [humanoid] Medium
               [monstrosity] Medium
               [ooze] Medium
               [plant] Medium
               [undead] Medium
               *[other] Medium
            }
         [L]
            { $mtype ->
               [aberration] Large
               [beast] Large
               [celestial] Large
               [construct] Large
               [dragon] Large
               [elemental] Large
               [fey] Large
               [fiend] Large
               [giant] Large
               [humanoid] Large
               [monstrosity] Large
               [ooze] Large 
               [plant] Large
               [undead] Large
               *[other] Large
            }
         [H]
            { $mtype ->
               [aberration] Huge
               [beast] Huge
               [celestial] Huge
               [construct] Huge
               [dragon] Huge
               [elemental] Huge
               [fey] Huge
               [fiend] Huge
               [giant] Huge
               [humanoid] Huge
               [monstrosity] Huge
               [ooze] Huge
               [plant] Huge
               [undead] Huge
               *[other] Huge
            }
         [G]
            { $mtype ->
               [aberration] Gargantuan
               [beast] Gargantuan
               [celestial] Mastodontico
               [construct] Mastodontico
               [dragon] Mastodontico
               [elemental] Mastodontico
               [fey] Mastodontico
               [fiend] Mastodontico
               [giant] Mastodontico
               [humanoid] Mastodontico
               [monstrosity] Gargantuan
               [ooze] Gargantuan
               [plant] Gargantuan
               [undead] Mastodontico
               *[other] Mastodontico
            }
         [C]
            { $mtype ->
               [aberration] Colossal
               [beast] Colossal
               [celestial] Colossal
               [construct] Colossal
               [dragon] Colossal
               [elemental] Colossal
               [fey] Colossal
               [fiend] Colossal
               [giant] Colossal
               [humanoid] Colossal
               [monstrosity] Colossal
               [ooze] Colossal
               [plant] Colossal
               [undead] Colossal
               *[other] Colossal
            }  
         [V]
            { $mtype ->
               [aberration] Varies
               [beast] Varies
               [celestial] Varies
               [construct] Varies
               [dragon] Varies
               [elemental] Varies
               [fey] Varies
               [fiend] Varies
               [giant] Varies
               [humanoid] Varies
               [monstrosity] Varies
               [ooze] Varies
               [plant] Varies
               [undead] Varies
               *[other] Varies
            }
       *[other] Unknown
    }



### type
mtype =
    { $mtype ->
         [aberration] Aberration
         [beast] Beast
         [celestial] Celestial
         [construct] Construct
         [dragon] Dragon
         [elemental] Elemental
         [fey] Fay
         [fiend] Fiend
         [giant] Giant
         [humanoid] Humanoid
         [monstrosity] Monstrosity
         [ooze] Ooze
         [plant] Plany
         [undead] Undead
         *[other] Creature
    }

creature-description =
     { mtype } { msize }


### Alignment
L = Legal
N = Neutral
NX = Neutral
NY = Neutral
C = Chaotic
G = Good
E = Evil
U = Unaligned
A = Any Alignment

LNXCNYE = Any Non-Good Alignment
LNXCNYG = Any Good Alignment

### Speed
stype = 
   { $stype ->
      [walk] walk
      [burrow] burrow
      [climb] climb
      [fly] fly
      [swim] swim
      *[other] unknown
   }



### Misc
dc = CD
armor-class = Armor Class
hit-points = Hit Points
speed = Speed




### Ability Score
str = { $t ->
   *[short] STR
   [long] strength
}
dex = { $t ->
   *[short] dex
   [long] dexterity
}
con = { $t ->
   *[short] con
   [long] constitution
}
int = { $t ->
   *[short] int
   [long] intelligence
}
wis = { $t ->
   *[short] wis
   [long] wisdom
}
cha = { $t ->
   *[short] cha
   [long] charisma
}

### Attacks
ms = Magic Melee Attack
rs = Magic Ranged Attack
mw = Melee Weapon Attack
rw = Ranged Weapon Attack

### TRAITS
saving-throw = { $t ->
   [sing] Saving Thow
   *[plur] Saving Throws
}

skill = { $t ->
   *[sing] Ability
   [plur] Abilities
   [acrobatics] acrobatics
   [animal] animal handling
   [arcana] arcana
   [athletics] athletics
   [deception] deception
   [history] history
   [insight] insight
   [intimidation] intimidation
   [investigation] investigation
   [medicine] medicine
   [nature] nature
   [perception] perception
   [performance] performance
   [persuasion] persuasion
   [religion] religion
   [sleightofhand] sleight of hand
   [stealth] stealth
   [survival] survival
}

senses = { $t ->
   *[sing] Sense
   [plur] Senses
   [blindsight] blindsight
   [darkvision] darkvision
   [tremorsense] tremorsense
   [truesight] truesight
   [passive] passive perception
}


 
languages = { $t ->
   *[sing] Language
   [plur] Languages
   [X] Any (Choose)
   [XX] All
   [CS] Can't Speak Known Languages
   [LF] Languages Known in Life
   [TP] Telepathy
   [OTH] Other
   [AB] Abyssal
   [AQ] Aquan
   [AU] Auran
   [C] Common
   [CE] Celestial
   [CSL] Common Sign Language
   [D] Dwarvish
   [DR] Draconic
   [DS] Deep Speech
   [DU] Druidic
   [E] Elvish
   [G] Gnomish
   [GI] Giant
   [GO] Goblin
   [GTH] Gith
   [H] Halfling
   [I] Infernal
   [IG] Ignan
   [O] Orc
   [P] Primordial
   [S] Sylvan
   [T] Terran
   [TC] Thieves' cant
   [U] Undercommon
}


damage-type = { $t ->
   [acid] acid
   [bludgeoning] bludgeoning
   [cold] cold
   [fire] fire
   [force] force
   [lightning] lightning
   [necrotic] necrotic
   [piercing] piercing
   [poison] poison
   [psychic] psychic
   [radiant] radiant
   [slashing] slashing
   [thunder] thunder
   *[other] other damage
}



vulnerable = { $t ->
  *[sing] Damage Vulnerability
   [plur] Damage Vulnerability
}

resist = { $t ->
  *[sing] Damage Resistance
   [plur] Damage Resistance
} 

immune = { $t ->
   *[sing] Damage Immunity
    [plur] Damage Immunity
}

data-condition = { $t -> 
   [blinded] blinded
   [charmed] charmed 
   [deafened] deafened 
   [exhaustion] exhaustion 
   [frightened] frightened 
   [grappled] grappled 
   [incapacitated] incapacitated 
   [invisible] invisible 
   [paralyzed] paralyzed
   [petrified] petrified 
   [poisoned] poisoned 
   [prone] prone
   [restrained] restrained 
   [stunned] stunned 
   [unconscious] unconscious 
   [disease] disease
   *[other] other condition
} 

condition-immune = { $t ->
  *[sing] Condition Immunity
   [plur] Condition Immunities
}

in-lair = or {$experience} XP in Lair
in-laira = or {$experience} XP in Lair

xp = XP
cr = CR
proficiency-bonus = Proficiency Bonus


################################################
#### Actions | Reactions | Bonus | Legendary
action = Actions
reaction = Reactions
bonus = Bonus Actions
legendary = Legendary Actions

legendary-header = Legendary Action Uses: {$amount}. Immediately after another creature's turn, {$shortName} can expend a use to take one of the following actions. {$shortName} regains all expended uses at the start of each of its turns.

legendary-header-lair = Legendary Action Uses: {$amount} ({$lairAmount} in Lair). Immediately after another creature's turn, {$shortName} can expend a use to take one of the following actions. {$shortName} regains all expended uses at the start of each of its turns.



attack = Attack
to-hit = to hit
hit = Hit
or = or
when = when

## Innate
innate-spellcasting = Innate Spellcasting
at-will = At will
day-each = each day
day = day

## Spellcasting
spellcasting = Spellcasting
cantrips = Cantrips (at will)

slot = { $t ->
  *[sing] slot
   [plur] slots
}

level = { $n ->
   *[other] { $n }° level
}

## Bonus Action
bonus-actions = Bonus Actions

## Legendary Action
legendary-actions = Legendary Actions