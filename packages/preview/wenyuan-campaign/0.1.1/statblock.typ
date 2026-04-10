///
/// (c) 2024-05 Yanwenyuan
///
/// This module does monster statblocks.
/// it should be imported as something and used qualified, to avoid polluting the global scope

#import "colours.typ" as colour

#let dndred = colour.dndred
#let challenge-xp = (
  "0":	"0",
  "0.125": "25",
  "1/8": "25",
  "0.25": "50",
  "1/4": "50",
  "0.5": "100",
  "1/2": "100",
  "1":	"200",
  "2":	"450",
  "3":	"700",
  "4":	"1,100",
  "5":	"1,800",
  "6":	"2,300",
  "7":	"2,900",
  "8":	"3,900",
  "9":	"5,000",
  "10":	"5,900",
  "11":	"7,200",
  "12":	"8,400",
  "13":	"10,000",
  "14":	"11,500",
  "15":	"13,000",
  "16":	"15,000",
  "17":	"18,000",
  "18":	"20,000",
  "19":	"22,000",
  "20":	"25,000",
  "21":	"33,000",
  "22":	"41,000",
  "23":	"50,000",
  "24":	"62,000",
  "25":	"75,000",
  "26":	"90,000",
  "27":	"105,000",
  "28":	"120,000",
  "29":	"135,000",
  "30":	"155,000",
)

#let default-title-font = ("TeX Gyre Bonum", "KingHwa_OldSong")
#let default-body-fonts = ("Scaly Sans Remake", "KingHwa_OldSong")
#let default-smallcaps-fonts = ("Scaly Sans Caps", "KingHwa_OldSong")
#let default-font-size = 10pt

#let current-title-font = state("title_font", default-title-font)
#let current-body-font = state("body_font", default-body-fonts)
#let current-smallcap-fonts = state("smallcap_font", default-smallcaps-fonts)
#let current-font-size = state("font_size", default-font-size)


#let smallconf(
  doc,
  fontsize: default-font-size,
  title-font: default-title-font,
  body-font: default-body-fonts,
  smallcap-font: default-smallcaps-fonts,
) = {

  current-title-font.update(title-font)
  current-body-font.update(default-body-fonts)
  current-smallcap-fonts.update(default-smallcaps-fonts)
  current-font-size.update(default-font-size)

  set text(font: body-font, size: fontsize)

  set par(leading: 0.5em, first-line-indent: 0pt)

  show heading.where(level: 2) : hd => {
    set text(font: smallcap-font, fill: dndred, size: fontsize * 1.3, weight: "regular")
    v(0.5em)
    hd.body
    v(-1em)
    line(length: 100%, stroke: 0.6pt + dndred)
    v(0.2em)
  }

  show heading.where(level: 3) : hd => text(
    size: fontsize, weight: "bold", style: "italic",
    hd.body + [.]
  )

  set heading(outlined: false)

  doc
}


/// displays a DnD dice average format, e.g. 19 (3d6 + 9) given the number of dice, the sides of dice, and a modifier (which can be set to 0 for no modifier)
/// 
/// Not necessarily recommended to be used directly; use `dice` for an easier interface.
#let dice-raw(
  /// -> int
  num-dice, 
  /// -> int
  dice-face,
  /// -> int 
  modifier
) = {
  let average = calc.floor(((dice-face + 1)/2) * num-dice + modifier)
  if (modifier > 0) {
    [#average (#num-dice;d#dice-face + #modifier)]
  } else if (modifier < 0) {
    [#average (#num-dice;d#dice-face - #(-modifier))]
  } else {
    [#average (#num-dice;d#dice-face)]
  }
}


/// Calculates and displays a DnD dice average from a string formatted roll
/// accepts strings of the following form:
/// - 0d0 (where 0 means any integer number)
/// - 0d0+0 
/// - `\d+d\d+(\+\d+)?`
/// and will accept strings with any number of spaces (but no other characters)
/// it is the user's responsibility to ensure that the formatting is correct
#let dice(
  /// -> str
  value
) = {
  let stripped = value.replace(regex("\\s"), "")

  let negative = false
  let dice_mod; 
  if (stripped.contains("-")) {
    negative = true
    dice_mod = stripped.split("-")
  } else {
    dice_mod = stripped.split("+")
  }

  let numbers = dice_mod.at(0).split("d")
  let numDice = int(numbers.at(0))
  let diceValue = int(numbers.at(1))

  let modifier
  if (dice_mod.len() > 1) {
    modifier = int(dice_mod.at(1))
    if (negative) {
        modifier = -modifier
    }
  } else {
    modifier = 0
  }

  dice-raw(numDice, diceValue, modifier)
}


/// takes an integer CR and formats with experience
/// will do nothing if CR is not a standard number
/// represent non integer CRs as decimals
#let challenge(
  /// -> int
  cr
) = {
  if (str(cr) in challenge-xp.keys()) {
    [#cr (#challenge-xp.at(str(cr)) XP)]
  } else {
    [#cr]
  }
}


/// Draws a stroke
#let stroke() = {
  line(stroke: (paint: gradient.linear(dndred, dndred.transparentize(100%)), thickness: 1.5pt), length: 100%)
}


/// Header block for monster stats.
#let statheading(
  /// Usually for the name of the monster. -> str|content
  title-text, 
  /// The little italic bit of description that says stuff like _Medium undead, lawful evil_. -> content
  desc: []
) = context [
  #{
    set text(font: current-title-font.get(), fill: dndred, size: current-font-size.get() * 1.8)
    smallcaps(title-text)
  }
  #v(-1.2em)
  _#block(inset: 1em, desc)_ 
  #v(-1.2em)
  #stroke()
]


/// a skills or stats entry like:
/// - *Hit Points* 60 (8d8 + 24)
/// - *Senses* Passive perception 15
/// the title is the thing in bold and the contents can be anything
#let skill(
  /// -> content
  title, 
  /// -> content
  contents
) = [
  #set text(dndred) 
  *#title* #contents 
]


/// AC, HP, Speed stats as one generated block.
/// 
/// Expects hp_dice as a valid dice value. If you don't want to use this just use hp_etc
#let mainstats(
  /// Armour class -> str
  ac: "", 
  /// Dice amount for HP, which will be calculated -> str
  hp-dice: "", 
  /// Speed -> str
  speed: "30ft", 
  /// Freeform HP text, can be used in conjunction or not -> str
  hp-etc: ""
) = [
  #skill("Armor Class", ac) \
  #if (hp-dice != "") [
    #skill("Hit Points")[#dice(hp-dice) #hp-etc]
  ] else [
    #skill("Hit Points")[#hp-etc]
  ] \
  #skill("Speed", speed)
]


/// calculates and properly displays ability scores
#let ability(
  /// -> int
  str, 
  /// -> int
  dex, 
  /// -> int
  con, 
  /// -> int
  int, 
  /// -> int
  wis, 
  /// -> int
  cha
) = {
  let abilities = (str, dex, con, int, wis, cha)
  let modifiers = ()
  for abil in abilities {
    let score = calc.floor((abil - 10) / 2)
    let score_str
    if (score >= 0) {
      score_str = [+#score]
    } else {
      score_str = [#score]
    }
    modifiers.push([#abil (#score_str)])
  }

  // main content
  context {
    stroke()
    v(-0.5em)
    set align(center)
    set table(stroke: none, align: center, row-gutter: -0.75em)
    set text(size: current-font-size.get()*0.9, fill: dndred)
    show table.cell.where(y: 0): strong
    table(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      table.header(.."STR DEX CON INT WIS CHA".split(" ")),
      ..modifiers
    )
    v(-0.5em)
    stroke()
  }
}



