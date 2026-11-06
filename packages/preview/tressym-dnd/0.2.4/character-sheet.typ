#import "@preview/one-liner:0.3.0": fit-to-width

/* * * CALCULATIONS * * */
// Format alignment code to long form
#let alignment-long(code: str) = {
  if code == "LG" {return "Lawful Good"}
  else if code == "NG" {return "Neutral Good"}
  else if code == "CG" {return "Chaotic Good"}
  else if code == "LN" {return "Lawful Neutral"}
  else if code == "NN" {return "True Neutral"}
  else if code == "CN" {return "Chaotic Neutral"}
  else if code == "LE" {return "Lawful Evil"}
  else if code == "NE" {return "Neutral Evil"}
  else if code == "CE" {return "Chaotic Evil"}
  else {return code}
}

#let calculate-modifier(stat: int)  = {
  return calc.floor((stat -10)/2)
}

#let calc-proficiency-bonus(lvl: int) = {
  if lvl <= 4 { return 2 }
  else if 5 <= lvl and lvl <= 8 { return 3 }
  else if 9 <= lvl and lvl <= 12 { return 4 }
  else if 13 <= lvl and lvl <= 16 { return 5 }
  else if 17 <= lvl { return 6 }
}

/* * * HEADER * * */
#let print-header(
  class: str, 
  subclass: str, 
  level: int, 
  background: str, 
  player: str, 
  species: str, 
  alignment: str, 
  xp: int,
  xp-type: str
) = {
  place(
    top + left,
    dx: 271pt,
    dy: 65.5pt,
    text([CLASS & LEVEL], size: 7pt, font: "Gillius ADF")
  )
  place(
    top + left,
    dx: 270pt,
    dy: 77pt,
    block(
        height: 2cm,
        width: 3.8cm,
        fit-to-width(species, max-text-size: 14pt)
    )
  )
  place(
    top + left,
    dx: 271pt,
    dy: 91.6pt,
    text([RACE], size: 7pt, font: "Gillius ADF")
  )
  place(
    top + left,
    dx: 382pt,
    dy: 77pt,
    block(
        height: 2cm,
        width: 3.3cm,
        fit-to-width(alignment-long(code: alignment), max-text-size: 14pt)
    )
  )
  place(
    top + left,
    dx: 383.7pt,
    dy: 91.6pt,
    text([ALIGNMENT], size: 7pt, font: "Gillius ADF")
  )

  if xp-type == "none" {
    place(
      top + left,
      dx: 270pt,
      dy: 51pt,
      block(
        height: 2cm,
        width: 3.8cm,
        fit-to-width([#class -- #level], max-text-size: 14pt)
      )
    )
    place(
      top + left,
      dx: 382pt,
      dy: 51pt,
      block(
        height: 2cm,
        width: 3.3cm,
        fit-to-width(subclass, max-text-size: 14pt)
      )
    )
    place(
      top + left,
      dx: 383.7pt,
      dy: 65.5pt,
      text([SUBCLASS], size: 7pt, font: "Gillius ADF")
    )
    place(
      top + left,
      dx: 480pt,
      dy: 51pt,
      block(
        height: 2cm,
        width: 3.2cm,
        fit-to-width(background, max-text-size: 14pt)
      )
    )
    place(
      top + left,
      dx: 480.5pt,
      dy: 65.5pt,
      text([BACKGROUND], size: 7pt, font: "Gillius ADF")
    )
    place(
      top + left,
      dx: 480pt,
      dy: 77pt,
      block(
        height: 2cm,
        width: 3.2cm,
        fit-to-width(player, max-text-size: 14pt)
      )
    )
    place(
      top + left,
      dx: 480.5pt,
      dy: 91.6pt,
      text([PLAYER NAME], size: 7pt, font: "Gillius ADF")
    )
  } else {
    place(
      top + left,
      dx: 270pt,
      dy: 51pt,
      block(
        height: 2cm,
        width: 3.8cm,
        fit-to-width(
          if subclass == "" {
            [#class -- #level]
          } else {
            [#class (#subclass) -- #level]
          },
          max-text-size: 14pt
        )
      )
      
    )

    place(
      top + left,
      dx: 382pt,
      dy: 51pt,
      block(
        height: 2cm,
        width: 3.3cm,
        fit-to-width(background, max-text-size: 14pt)
      )
    )
    place(
      top + left,
      dx: 383.7pt,
      dy: 65.5pt,
      text([BACKGROUND], size: 7pt, font: "Gillius ADF")
    )
    place(
      top + left,
      dx: 480pt,
      dy: 51pt,
      block(
        height: 2cm,
        width: 3.2cm,
        fit-to-width(player, max-text-size: 14pt)
      )
    )
    place(
      top + left,
      dx: 480.5pt,
      dy: 65.5pt,
      text([PLAYER NAME], size: 7pt, font: "Gillius ADF")
    )
    if xp-type == "milestone" {
      place(
        top + left,
        dx: 480pt,
        dy: 77pt,
        block(
          height: 2cm,
          width: 3.2cm,
          fit-to-width([#xp], max-text-size: 14pt)
        )
      )
      place(
        top + left,
        dx: 480.5pt,
        dy: 91.6pt,
        text([MILESTONES], size: 7pt, font: "Gillius ADF")
      )
    } else {
      place(
        top + left,
        dx: 480pt,
        dy: 77pt,
        block(
          height: 2cm,
          width: 3.2cm,
          fit-to-width([#xp], max-text-size: 14pt)
        )
      )
      place(
        top + left,
        dx: 480.5pt,
        dy: 91.6pt,
        text([EXPERIENCE POINTS], size: 7pt, font: "Gillius ADF")
      )
    }
  }
}

/* * * STATS * * */
#let print-big-stats(
  stat-list,
  mod-yn
) = {
  let pos_y
  // calculate y coordinate based on position in list
  for i in range(6) {
    pos_y = 158pt + (71.6pt*i)
    place(
      center,
      dx: -249pt,
      dy: pos_y,
      
      {
        // add + sign if non-negative number
        if stat-list.at(i) >= 0 and mod-yn {
          text([+#stat-list.at(i)], size: 26pt)
        } else {
          text([#stat-list.at(i)], size: 26pt)
        }
      }
    )
  }
}

#let print-small-stats(
  stat-list,
  mod-yn
) = {
  let pos_y
  // calculate y coordinate based on position in list
  for i in range(6) {
    pos_y = 188pt + (71.6pt*i)
    place(
      center,
      dx: -250pt,
      dy: pos_y,
      {
        // add + sign if non-negative number
        if stat-list.at(i) >= 0 and mod-yn {
          text([+#stat-list.at(i)], size: 12pt)
        } else {
          text([#stat-list.at(i)], size: 12pt)
        }
      }
    )
  }
}

/* * * HALF & DOUBLE PROFICIENCIES * * */
#let half-prof = tiling(
  size: (8pt, 8pt),
  relative: "parent",
  spacing: (5.77pt, 0pt),
    square(
      size: 8pt,
      fill: black,
    )
)

#let onehalf-prof = tiling(
  size: (8pt, 8pt),
  relative: "parent",
  spacing: (3.1pt, 0pt),
    square(
      size: 8pt,
      fill: black,
    )
)

/* * * ATTACKS & SPELLCASTING * * */
#let add-weapon(
  name,
  atk-bonus,
  damage,
  position
) = {
  place(
    top + left,
    dx: 225.3pt,
    dy: 392.2pt + (20.5pt*position),
    polygon(
      fill: gray.lighten(70%),
      stroke: none,
      (-2.3pt, 15.7pt),
      (-2.3pt, 2.3pt),
      (0pt, 0pt),
      (61.6pt, 0pt),
      (61.6pt, 13.4pt),
      (59.3pt, 15.7pt)
    )
  )
  place(
    top + left,
    dx: 224pt,
    dy: 396pt + (20.5pt*position),
    block(
      height: 3cm,
      width: 2.18cm,
      fit-to-width(name, max-text-size: 12pt)
    )
  )
  place(
    top + left,
    dx: 293.75pt,
    dy: 392.2pt + (20.5pt*position),
    polygon(
      fill: gray.lighten(70%),
      stroke: none,
      (-2.3pt, 15.7pt),
      (-2.3pt, 2.3pt),
      (0pt, 0pt),
      (28.65pt, 0pt),
      (28.65pt, 13.4pt),
      (26.35pt, 15.7pt)
    )
  )
  place(
    center,
    dx: -1.5pt,
    dy: 395pt + (20.5pt*position),
    { // add + sign if non-negative number
      if type(atk-bonus) == int and atk-bonus >= 0 {
        text([+#atk-bonus], size: 12pt)
      } else { text([#atk-bonus], size: 12pt) }
    }
  )
  place(
    top + left,
    dx: 329.45pt,
    dy: 392.2pt + (20.5pt*position),
    polygon(
      fill: gray.lighten(70%),
      stroke: none,
      (-2.3pt, 15.7pt),
      (-2.3pt, 2.3pt),
      (0pt, 0pt),
      (59.6pt, 0pt),
      (59.6pt, 13.4pt),
      (57.3pt, 15.7pt)
    )
  )
  if type(damage) == str {
    place(
      top + left,
      dx: 330pt,
      dy: 396.5pt + (20.5pt*position),
      block(
        height: 3cm,
        width: 2.02cm,
        fit-to-width(damage, max-text-size: 12pt)
      )
    )
  } else {
    place(
      top + left,
      dx: 330pt,
      dy: 396.5pt + (20.5pt*position),
      {text(damage.at(0), size: 10pt)
      { // add + sign if non-negative number
        if type(damage.at(1)) == int and damage.at(1) >= 0 { text([+#damage.at(1) ], size: 10pt)
        } else { text([#damage.at(1) ], size: 10pt)}
      }
      text(damage.at(2), size: 10pt)}
    )
  }
}

// Generate character page
#let character-sheet(
/* * * HEADER * * */
  name: "", // name of the character
  class: "", 
  subclass: "", // may be displayed differently based on xp-type
  level: 1, 
  level-print: "",
  background: "",
  player: "", // name of the player
  species: "", // species (5e-2024) or race (5e-2014)
  alignment: "NN", // accepts a text or a code of format LG, NG, CG, LN, NN, CN, LE, NE, CE
  xp: 0, //may not be shown if xp-type is none
  xp-type: "xp", // supports xp, milestone, none

/* * * STATS * * */
  strength: 10, // can't call this str, since str is string
  dexterity: 10,
  constitution: 10,
  intelligence: 10, // can't call this int, since int is integer
  wisdom: 10,
  charisma: 10,
  strmod: none, 
  dexmod: none,
  conmod: none,
  intmod: none,
  wismod: none,
  chamod: none,
  prof-bonus: none,
  big-number-big-field: true,

/* * * SAVES * * */
  strsave: false,
  dexsave: false,
  consave: false,
  intsave: false,
  wissave: false,
  chasave: false,

  strsavemod: none,
  dexsavemod: none,
  consavemod: none,
  intsavemod: none,
  wissavemod: none,
  chasavemod: none,

/* * * SKILLS * * */
  // half- and double-proficiencies are a planned future features
  acrobatics: false,
  animal-handling: false,
  arcana: false,
  athletics: false,
  deception: false,
  history: false,
  insight: false,
  intimidation: false,
  investigation: false,
  medicine: false,
  nature: false,
  perception: false,
  performance: false,
  persuasion: false,
  religion: false,
  sleight-of-hand: false,
  stealth: false,
  survival: false,

  acrobaticsmod: none,
  animal-handlingmod: none,
  arcanamod: none,
  athleticsmod: none,
  deceptionmod: none,
  historymod: none,
  insightmod: none,
  intimidationmod: none,
  investigationmod: none,
  medicinemod: none,
  naturemod: none,
  perceptionmod: none,
  performancemod: none,
  persuasionmod: none,
  religionmod: none,
  sleight-of-handmod: none,
  stealthmod: none,
  survivalmod: none,

/* * * HEALTH * * */
  armorclass: none,
  initiative: none,
  speed: 30,
  hp-max: 0,
  hp-current: none,
  hp-temp: none,
  hitdice-total: none,
  hitdice-type: none,
  deathsave-s: 0,
  deathsave-f: 0,

/* * * MISC * * */
  inspiration: none,
  passive-perception: none,
  passive-insight: none,
  passive-investigation: none,
  more-passive: false,

/* * * ATTACKS & SPELLCASTING * * */
  weapons: (),
  attacks-text: str,
/* * * OTHER PROFICIENCIES & LANGUAGES * * */
  prof-lang-text: str,
/* * * EQUIPMENT * * */
  equipment-text: str,
  display-money: true,
  money: (none,none,none,none,none),
  big-equip: false,
/* * * PERSONALITY * * */
  personality-traits: str,
  ideals: str,
  bonds: str,
  flaws: str,
/* * * FEATURES & TRAITS * * */
  features-traits: str,
/* * * for rendering * * */
  settings: (
    language: "en", // only changes built-in lang features, no changes are made to the sheet text
    printer-mono: false, // true for black outlines, false for colored
    spell-rainbows: false, // changes the paper rules to rainbow gradients
    body-font: "Vollkorn"
  ),
  body: none
) = {
  set text(lang: settings.at("language", default: "en"), size:13pt, font: settings.at("body-font", default: "Vollkorn"))
  set page(
    paper: "us-letter",
    margin: (x: 0%, y: 0%, top: 0%, bottom: 0%)
  )
  
  body = {

  // Set string to append at the end of files names when getting graphics
  let svg-color
  if settings.at("printer-mono", default: false) {
    svg-color = "-mono.svg"
  } else {
    svg-color = "-col.svg"
  }

  /* * * HEADER * * */
  print-header(class: class, subclass: subclass, level: {if level-print != "" {level-print} else {level}}, background: background, player: player, species: species, alignment: alignment, xp: xp, xp-type: xp-type)

  /* * * STATS * * */
  let stat-list = ( strength, dexterity, constitution, intelligence, wisdom, charisma )
  let statmod-list = ( strmod, dexmod, conmod, intmod, wismod, chamod )
  // Calculate Stat Modifiers
  for i in range(6) {
    if statmod-list.at(i) == none { // If not overwritten by user, auto-calculate
      statmod-list.at(i) = calc.floor((stat-list.at(i) -10)/2)
    }
  }

  if big-number-big-field {
    print-big-stats(stat-list, false)
    print-small-stats(statmod-list, true)
  } else {
    print-big-stats(statmod-list, true)
    print-small-stats(stat-list, false)
  }

  if prof-bonus == none { // If not overwritten by user, auto-calculate
    prof-bonus = calc-proficiency-bonus(lvl: level)
  }
  place(
    top + left,
    dx: 97.5pt,
    dy: 169.5pt,
    text([+#prof-bonus], size: 18pt)
  )

  /* * * SKILLS & SAVES * * */
  let calc-skill-mod(skill-prof: none, base-stat-mod: int) = {
    // Check whether simple or advanced proficiency entry
    if type(skill-prof) == bool { // simple proficiency entry
      if skill-prof { // proficient
        return base-stat-mod + prof-bonus
      } else {
        return base-stat-mod
      }
    } else if type(skill-prof) == float or type(skill-prof) == int { // advanced proficiency entry
      return calc.floor(base-stat-mod + (prof-bonus * skill-prof))
    } else {
      return none
    }
  }

  let print-skill-mod(skill-prof: none, skill-mod: int, position: int) = {
    // calculate y coordinate based on position in list
    let pos_y = 319.9pt + (13.5pt*position)
    // Print appropiate dot
    if type(skill-prof) == bool { // if simple proficiency entry
      // if proficient, add proficiency bonus and print dot
      if skill-prof {
        place(
          center,
          dx: -201.7pt,
          dy: pos_y+3.7pt,
          circle(radius: 3pt, fill: black)
        )
      }
    } else if type(skill-prof) == float or type(skill-prof) == int { // if advanced proficiency entry
      if skill-prof > 1.8 { // around 2 and above
        place(
          center,
          dx: -201.7pt,
          dy: pos_y+3.7pt,
          circle(radius: 3pt, fill: black)
        )
        place(
          center,
          dx: -201.7pt + 3.5pt,
          dy: pos_y+3.7pt,
          circle(radius: 3pt, stroke: 0.7pt + gray, fill: black)
        )
      } else if skill-prof > 1.3 { // around 1.5
        place(
          center,
          dx: -201.7pt,
          dy: pos_y+3.7pt,
          circle(radius: 3pt, fill: black)
        )
        place(
          center,
          dx: -201.7pt + 3.5pt,
          dy: pos_y+3.7pt,
          circle(radius: 3pt, stroke: 0.7pt + gray, fill: onehalf-prof)
        )
      } else if skill-prof > 0.8 { // around normal 1
        place(
          center,
          dx: -201.7pt,
          dy: pos_y+3.7pt,
          circle(radius: 3pt, fill: black)
        )
      } else if skill-prof > 0.3 { // around 0.5
        place(
          center,
          dx: -201.7pt,
          dy: pos_y+3.7pt,
          circle(radius: 3pt, fill: half-prof)
        )
      }
    }
    // Print actual modifier
    place(
      center,
      dx: -187pt,
      dy: pos_y,
      {
        // add + sign if non-negative number
        if skill-mod >= 0 {
          text([+#skill-mod], size: 12pt)
        } else {
          text([#skill-mod], size: 12pt)
        }
      }
    )
  }

  /* * * SAVES * * */
  // put all saves in an array
  let save_list = ( strsave, dexsave, consave, intsave, wissave, chasave )
  let savemod_list = ( strsavemod, dexsavemod, consavemod, intsavemod, wissavemod, chasavemod )
  // iterate over save list with calculation and printing
  for i in range(6) {
    if savemod_list.at(i) == none { // If not overwritten by user, auto-calculate
      savemod_list.at(i) = calc-skill-mod(skill-prof: save_list.at(i), base-stat-mod: statmod-list.at(i))
    }
    print-skill-mod(skill-prof: save_list.at(i), skill-mod: savemod_list.at(i), position: (i -8.54))
  }

  /* * * SKILLS * * */
  // put all skills in an array
  let skill_list = ( acrobatics,animal-handling,arcana,athletics,deception,history,insight,intimidation,investigation,medicine,nature,perception,performance,persuasion,religion,sleight-of-hand,stealth,survival )
  let skillmod_list = ( acrobaticsmod,animal-handlingmod,arcanamod,athleticsmod,deceptionmod,historymod,insightmod,intimidationmod,investigationmod,medicinemod,naturemod,perceptionmod,performancemod,persuasionmod,religionmod,sleight-of-handmod,stealthmod,survivalmod )
  // hardcode which stat corresponds to which skill
  let skill_bases = ( 1,4,3,0,5,3,4,5,3,4,3,4,5,5,3,1,1,4 ) // relative to statmod-list
  // iterate over skill list with calculation and printing
  for i in range(18) {
    if skillmod_list.at(i) == none { // If not overwritten by user, auto-calculate
      skillmod_list.at(i) = calc-skill-mod(skill-prof: skill_list.at(i), base-stat-mod: statmod-list.at(skill_bases.at(i)))
    }
    print-skill-mod(skill-prof: skill_list.at(i), skill-mod: skillmod_list.at(i), position: i) 
  }

  /* PASSIVE STATS */
  if passive-perception == none { // If not overwritten by user, auto-calculate
    passive-perception = 10 + skillmod_list.at(11)
  }
  place(
    center,
    dx: -264pt,
    dy: 592.5pt,
    text([#passive-perception], size: 17pt)
  )

  if more-passive  == true {
    place(
      top + left,
      dx: 27pt,
      dy: 585.86pt,
      image("/outlines/passive-all"+svg-color)
    )
    place(
      top + left,
      dx: 88.7pt,
      dy: 597.7pt,
      text([PASSIVE PERCEPTION], size: 6pt, font: "Gillius ADF", tracking:0.1pt)
    )
    place(
      center,
      dx: -220pt,
      dy: 622.05pt,
      text([PASSIVE \ INSIGHT], size: 6pt, font: "Gillius ADF", tracking:0.1pt)
    )
    if passive-insight == none { // If not overwritten by user, auto-calculate
      passive-insight = 10 + skillmod_list.at(6)
    }
    place(
      center,
      dx: -264pt,
      dy: 621pt,
      text([#passive-insight], size: 17pt)
    )
    place(
      center,
      dx: -130pt,
      dy: 622.05pt,
      text([PASSIVE \ INVESTIGATION], size: 6pt, font: "Gillius ADF", tracking:0.1pt)
    )
    if passive-investigation == none { // If not overwritten by user, auto-calculate
      passive-investigation = 10 + skillmod_list.at(8)
    }
    place(
      center,
      dx: -174pt,
      dy: 621pt,
      text([#passive-investigation], size: 17pt)
    )
  } else {
    place(
      top + left,
      dx: 27pt,
      dy: 585.86pt,
      image("/outlines/passive-percept"+svg-color)
    )
  }

  /* * * HEALTH * * */
  if armorclass == none {
    armorclass = 10 + statmod-list.at(1)
  }
  place(
    center,
    dx: -58pt,
    dy: 146pt,
    text([#armorclass], size: 21pt)
  )

  if initiative == none {
    initiative = statmod-list.at(1)
  }
  place(
    center,
    dx: -4pt,
    dy: 146pt,
    {
      // add + sign if non-negative number
      if initiative >= 0 {
        text([+#initiative], size: 26pt)
      } else {
        text([#initiative], size: 26pt)
      }
    }
  )

  place(
    center,
    dx: 56.5pt,
    dy: 148pt,
    {
      if type(speed) == int {
        text([#speed], size: 22pt)
        text([ft], size: 17pt)
      } else {
        text([#speed], size: 22pt)
      }
    }
  )

  place(
    center,
    dx: -2pt,
    dy: 196pt,
    text([#hp-max], size: 14pt)
  )
  if hp-current != none {
    place(
      center,
      dx: -5pt,
      dy: 221.5pt,
      text([#hp-current], size: 14pt)
    )
  }
  if hp-temp != none {
    place(
      center,
      dx: -5pt,
      dy: 274pt,
      text([#hp-temp], size: 14pt)
    )
  }
  if hitdice-total == none {
    if level-print != "" {
      hitdice-total = level-print
    } else {
      hitdice-total = level
    }
  }
  place(
    center,
    dx: -43pt,
    dy: 319pt,
    text([#hitdice-total], size: 10pt)
  )
  place(
    center,
    dx: -43pt,
    dy: 337pt,
    text([#hitdice-type], size: 18pt)
  )

  for i in range(deathsave-s) {
    place(
      center,
      dx: 44.5pt + (12.85pt*i),
      dy: 323.3pt,
      circle(radius: 3.5pt, fill: black)
    )
  }
  for i in range(deathsave-f) {
    place(
      center,
      dx: 44.5pt + (12.85pt*i),
      dy: 338.3pt,
      circle(radius: 3.5pt, fill: black)
    )
  }

  /* * * MISC * * */
  place(
    center,
    dx: -198.5pt,
    dy: 134.5pt,
    text([#inspiration], size: 13pt)
  )

  /* * * ATTACKS & SPELLCASTING * * */
  let weaponnr = 0
  for weapon in weapons {
    if type(weapon.at(2)) != str {
      if type(weapon.at(1)) == int {
        weapon.at(2) = (weapon.at(2).at(0),weapon.at(1),weapon.at(2).at(1))
      } else if weapon.at(1) == "sp" or weapon.at(1) == "s" {
        weapon.at(2) = (weapon.at(2).at(0),statmod-list.at(0),weapon.at(2).at(1))
      } else if weapon.at(1) == "dp" or weapon.at(1) == "d" {
        weapon.at(2) = (weapon.at(2).at(0),statmod-list.at(1),weapon.at(2).at(1))
      } else {
        atk = ""
      }
    }
    let atk
    if type(weapon.at(1)) == int {
      atk = weapon.at(1)
    } else if weapon.at(1) == "sp" {
      atk = statmod-list.at(0) + prof-bonus
    } else if weapon.at(1) == "dp" {
      atk = statmod-list.at(1) + prof-bonus
    } else if weapon.at(1) == "s" {
      atk = statmod-list.at(0)
    } else if weapon.at(1) == "d" {
      atk = statmod-list.at(1)
    } else {
      atk = weapon.at(1)
    }
    add-weapon(weapon.at(0),atk,weapon.at(2), weaponnr)
    weaponnr += 1
  }
  // Display Attacks & Spellcasting Text below Weapons Table
  place(
    top + left,
    dx: 224pt,
    dy: 396pt + (20.5pt*weaponnr),
    block(width: 163pt,par(justify: true, leading:3.5pt, text(attacks-text, size: 10pt)))
  )

  /* * * OTHER PROFICIENCIES & LANGUAGES * * */
  place(
    top + left,
    dx: 35.2pt,
    dy: if more-passive {629pt + 20.25pt} else {629pt},
    block(width: 163pt, par(justify: true, leading:5.5pt, text(prof-lang-text, size: 10pt)))
  )

  /* * * EQUIPMENT * * */
  let equip_x = 0pt

  if big-equip  == true {
    place(
      top + left,
      dx: 216pt,
      dy: 380.4pt,
      image("/outlines/equipment-big"+svg-color)
    )
  } else {
    place(
      top + left,
      dx: 216pt,
      dy: 380.4pt,
      image("/outlines/equipment-small"+svg-color)
    )
  }
  
  if display-money {
    equip_x = 45pt
    place(
      top + left,
      dx: 211.35pt,
      dy: 596.45pt,
      image("/outlines/money"+svg-color)
    )
    for i in range(5) {
      place(
        center,
        dx: -62.5pt,
        dy: 599.5pt + i*26.3pt,
        text([#money.at(i)], size: 18pt)
      )
    }
  }

  place(
    top + left,
    dx: 223.5pt + equip_x,
    dy: 595pt,
    if big-equip {
      block(width: 352pt-equip_x, height: 167pt, columns(2, gutter: 8pt)[#par(justify: true, leading:4.8pt, text(equipment-text, size: 10pt))])
    } else {
      block(width: 163pt-equip_x,par(justify: true, leading:4.5pt, text(equipment-text, size: 10pt)))
    }
  )

  /* * * PERSONALITY * * */
  place(
    top + left,
    dx: 418pt,
    dy: 142pt,
    block(width: 153pt,par(justify: true, leading:4.5pt, text(personality-traits, size: 9pt)))
  )
  let personality = (ideals, bonds, flaws)
  for i in range(3) { 
    place(
      top + left,
      dx: 418pt,
      dy: 210.5pt + i*55.5pt,
      block(width: 153pt,par(justify: true, leading:4.5pt, text(personality.at(i), size: 9pt)))
    )
  }

  /* * * FEATURES & TRAITS * * */
  place(
    top + left,
    dx: 412pt,
    dy: 387pt,
    block(width: 164pt,par(justify: true, leading:4.6pt, text(features-traits, size: 10pt)))
  )
  }

  // Place Background and all info added to body above
  if settings.at("printer-mono", default: false) {
    set page(
      background: image("/outlines/page-1-mono.svg", width: 100%)
    )
    place(
      top + left,
      dx: 49pt,
      dy: 65pt,
      block(
        height: 3cm,
        width: 7.3cm,
        fit-to-width(name, max-text-size: 21pt)
      )
    )
    body
  } else {
    set page(
      background: image("/outlines/page-1-col.svg", width: 100%)
    )
    place(
      top + left,
      dx: 49pt,
      dy: 65pt,
      block(
        height: 3cm,
        width: 7.3cm,
        fit-to-width(name, max-text-size: 21pt)
      )
    )
    body
  }
}


