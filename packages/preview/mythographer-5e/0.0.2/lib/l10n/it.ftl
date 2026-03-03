part = Parte

chapter = { $t ->
  *[sing] Capitolo
   [plur] Capitoli
   [short] Cap.
}

## Spell
casting-time = Tempo di Lancio
range = Gittata
component = { $t ->
  *[sing] Componente
   [plur] Componenti
}
duration = Durata

## Feat
prerequisite = Prerequisito


###############################################
##### Monster

### Size
# F = Infinitesimale, D = Minuscola, T = Minuscola, S = Piccola, M = Media, L = Grande, H = Enorme, G = Mastodontica, C = Colossale, V = Variabile
msize =
    { $msize ->
         [F]
            { $mtype ->
               [aberration] Infinitesimale
               [beast] Infinitesimale
               [celestial] Infinitesimale
               [construct] Infinitesimale
               [dragon] Infinitesimale
               [elemental] Infinitesimale
               [fey] Infinitesimale
               [fiend] Infinitesimale
               [giant] Infinitesimale
               [humanoid] Infinitesimale
               [monstrosity] Infinitesimale
               [ooze] Infinitesimale
               [plant] Infinitesimale
               [undead] Infinitesimale
               *[other] Infinitesimale
            }
         [D]
            { $mtype ->
               [aberration] Minuscola
               [beast] Minuscola
               [celestial] Minuscolo
               [construct] Minuscolo
               [dragon] Minuscolo
               [elemental] Minuscolo
               [fey] Minuscolo
               [fiend] Minuscolo
               [giant] Minuscolo
               [humanoid] Minuscolo
               [monstrosity] Minuscola
               [ooze] Minuscola
               [plant] Minuscola
               [undead] Minuscolo
               *[other] Minuscolo
            }
         [T]
            { $mtype ->
               [aberration] Minuscola
               [beast] Minuscola
               [celestial] Minuscolo
               [construct] Minuscolo
               [dragon] Minuscolo
               [elemental] Minuscolo
               [fey] Minuscolo
               [fiend] Minuscolo
               [giant] Minuscolo
               [humanoid] Minuscolo
               [monstrosity] Minuscola
               [ooze] Minuscola
               [plant] Minuscola
               [undead] Minuscolo
               *[other] Minuscolo
            }
         [S]
            { $mtype ->
               [aberration] Piccola
               [beast] Piccola
               [celestial] Piccolo
               [construct] Piccolo
               [dragon] Piccolo
               [elemental] Piccolo
               [fey] Piccolo
               [fiend] Piccolo
               [giant] Piccolo
               [humanoid] Piccolo
               [monstrosity] Piccola
               [ooze] Piccola
               [plant] Piccola
               [undead] Piccolo
               *[other] Piccolo
            }
         [M]
            { $mtype ->
               [aberration] Media
               [beast] Media
               [celestial] Medio
               [construct] Medio
               [dragon] Medio
               [elemental] Medio
               [fey] Medio
               [fiend] Medio
               [giant] Medio
               [humanoid] Medio
               [monstrosity] Media
               [ooze] Media
               [plant] Media
               [undead] Medio
               *[other] Medio
            }
         [L]
            { $mtype ->
               [aberration] Grande
               [beast] Grande
               [celestial] Grande
               [construct] Grande
               [dragon] Grande
               [elemental] Grande
               [fey] Grande
               [fiend] Grande
               [giant] Grande
               [humanoid] Grande
               [monstrosity] Grande
               [ooze] Grande 
               [plant] Grande
               [undead] Grande
               *[other] Grande
            }
         [H]
            { $mtype ->
               [aberration] Enorme
               [beast] Enorme
               [celestial] Enorme
               [construct] Enorme
               [dragon] Enorme
               [elemental] Enorme
               [fey] Enorme
               [fiend] Enorme
               [giant] Enorme
               [humanoid] Enorme
               [monstrosity] Enorme
               [ooze] Enorme
               [plant] Enorme
               [undead] Enorme
               *[other] Enorme
            }
         [G]
            { $mtype ->
               [aberration] Mastodontica
               [beast] Mastodontica
               [celestial] Mastodontico
               [construct] Mastodontico
               [dragon] Mastodontico
               [elemental] Mastodontico
               [fey] Mastodontico
               [fiend] Mastodontico
               [giant] Mastodontico
               [humanoid] Mastodontico
               [monstrosity] Mastodontica
               [ooze] Mastodontica
               [plant] Mastodontica
               [undead] Mastodontico
               *[other] Mastodontico
            }
         [C]
            { $mtype ->
               [aberration] Colossale
               [beast] Colossale
               [celestial] Colossale
               [construct] Colossale
               [dragon] Colossale
               [elemental] Colossale
               [fey] Colossale
               [fiend] Colossale
               [giant] Colossale
               [humanoid] Colossale
               [monstrosity] Colossale
               [ooze] Colossale
               [plant] Colossale
               [undead] Colossale
               *[other] Colossale
            }  
         [V]
            { $mtype ->
               [aberration] Variabile
               [beast] Variabile
               [celestial] Variabile
               [construct] Variabile
               [dragon] Variabile
               [elemental] Variabile
               [fey] Variabile
               [fiend] Variabile
               [giant] Variabile
               [humanoid] Variabile
               [monstrosity] Variabile
               [ooze] Variabile
               [plant] Variabile
               [undead] Variabile
               *[other] Variabile
            }
       *[other] Sconosciuta
    }



### type
mtype =
    { $mtype ->
         [aberration] Aberrazione
         [beast] Bestia
         [celestial] Celestiale
         [construct] Costrutto
         [dragon] Drago
         [elemental] Elementale
         [fey] Fatato
         [fiend] Demone
         [giant] Gigante
         [humanoid] Umanoide
         [monstrosity] Mostruosità
         [ooze] Melma
         [plant] Pianta
         [undead] Non Morto
         *[other] Creatura
    }

creature-description =
     { mtype } { msize }


### Alignment
L = Legale
N = Neutrale
NX = Neutrale
NY = Neutrale
C = Caotico
G = Buono
E = Malvagio
U = Non Allineato
A = Qualsiasi Allineamento

LNXCNYE = Qualsiasi Allineamento Non-Buono
LNXCNYG = Qualsiasi Allineamento Buono

### Speed
stype = 
   { $stype ->
      [walk] camminare
      [burrow] scavare
      [climb] arrampicarsi
      [fly] volare
      [swim] nuotare
      *[other] sconosciuto
   }



### Misc
dc = CD
armor-class = Classe Armatura
hit-points = Punti Vita
speed = Velocità




### Ability Score
str = { $t ->
   *[short] for
   [long] forza
}
dex = { $t ->
   *[short] des
   [long] destrezza
}
con = { $t ->
   *[short] cos
   [long] costituzione
}
int = { $t ->
   *[short] int
   [long] intelligenza
}
wis = { $t ->
   *[short] sag
   [long] saggezza
}
cha = { $t ->
   *[short] car
   [long] carisma
}

### Attacks
ms = Attacco Magico da Mischia
rs = Attacco Magico a Distanza
mw = Attacco con Arma da Mischia
rw = Attacco con Arma a Distanza

### TRAITS
saving-throw = { $t ->
   [sing] Tiro Salvezza
   *[plur] Tiri Salvezza
}

skill = { $t ->
   *[sing] Abilità
   [plur] Abilità
   [acrobatics] acrobatica
   [animal] addestrare Animali
   [arcana] arcana
   [athletics] atletica
   [deception] inganno
   [history] storia
   [insight] intuito
   [intimidation] intimidire
   [investigation] indagare
   [medicine] medicina
   [nature] natura
   [perception] percezione
   [performance] intrattenere
   [persuasion] persuasione
   [religion] religione
   [sleightofhand] rapidità di mano
   [stealth] furtività
   [survival] sopravvivenza
}

senses = { $t ->
   *[sing] Sensi
   [plur] Sensi
   [blindsight] vista cieca
   [darkvision] visione al buio
   [tremorsense] percezione tellurica
   [truesight] vista vera
   [passive] percezione passiva
}


 
languages = { $t ->
   *[sing] Lingua
   [plur] Lingue
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
   [acid] acido
   [bludgeoning] contundente
   [cold] freddo
   [fire] fuoco
   [force] forza
   [lightning] lightning
   [necrotic] necrotico
   [piercing] piercing
   [poison] poison
   [psychic] psichico
   [radiant] radiante
   [slashing] tagliente
   [thunder] thunder
   *[other] other damage
}



vulnerable = { $t ->
  *[sing] Vulnerabilità ai Danni
   [plur] Vulnerabilità ai Danni
}

resist = { $t ->
  *[sing] Resistenza ai Danni
   [plur] Resistenza ai Danni
} 

immune = { $t ->
   *[sing] Immunità ai Danni
    [plur] Immunità ai Danni
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
   [paralyzed] paralizzato
   [petrified] pietrificato 
   [poisoned] poisoned 
   [prone] prono
   [restrained] restrained 
   [stunned] stunned 
   [unconscious] unconscious 
   [disease] disease
   *[other] other condition
} 

condition-immune = { $t ->
  *[sing] Immunità alle Condizioni
   [plur] Immunità alle Condizioni
}

in-lair = o {$experience} PE nella tana
in-laira = o {$experience} PE nella tana

xp = PE
cr = Sfida
proficiency-bonus = Bonus di Competenza


################################################
#### Actions | Reactions | Bonus | Legendary
action = Azioni
reaction = Reazioni
bonus = Azioni Bonus
legendary = Azioni Leggendarie

legendary-header = Legendary Action Uses: {$amount}. Immediately after another creature's turn, {$shortName} can expend a use to take one of the following actions. {$shortName} regains all expended uses at the start of each of its turns.

legendary-header-lair = Legendary Action Uses: {$amount} ({$lairAmount} in Lair). Immediately after another creature's turn, {$shortName} can expend a use to take one of the following actions. {$shortName} regains all expended uses at the start of each of its turns.



attack = Attacco
to-hit = per colpire
hit = Colpito
or = o
when = quando

## Innate
innate-spellcasting = Incantesimi Innati
at-will = A volontà
day-each = ogni giorno
day = al Giorno

## Spellcasting
spellcasting = Incantesimi
cantrips = Trucchetti (a volontà)

slot = { $t ->
  *[sing] slot
   [plur] slot
}

level = { $n ->
   *[other] { $n }° livello
}

## Bonus Action
bonus-actions = Azioni Bonus

## Legendary Action
legendary-actions = Azioni Leggendarie