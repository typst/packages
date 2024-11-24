///
/// (c) 2024-05 Yanwenyuan
///
/// This module does monster statblocks.
/// it should be imported as something and used qualified, to avoid polluting the global scope

#import calc
#import "colours.typ" as colour

#let title = ("TeX Gyre Bonum", "KingHwa_OldSong")
#let fonts = ("Scaly Sans Remake", "KingHwa_OldSong")
#let sc_fonts = ("Scaly Sans Caps", "KingHwa_OldSong")
#let fontsize = 10pt
#let dndred = colour.dndred
#let marginx = 2cm
#let marginy = 2.5cm
#let challenge_xp = (
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

#let smallconf(doc) = {
  set text(font: fonts, size: fontsize)

  set par(leading: 0.5em, first-line-indent: 0pt)

  show heading.where(level: 2) : hd => {
    set text(font: sc_fonts, fill: dndred, size: fontsize * 1.2)
    hd
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
#let diceRaw(numDice, diceFace, modifier) = {
  let average = calc.floor(((diceFace + 1)/2) * numDice + modifier)
  if (modifier > 0) {
    [#average (#numDice;d#diceFace + #modifier)]
  } else if (modifier < 0) {
    [#average (#numDice;d#diceFace - #(-modifier))]
  } else {
    [#average (#numDice;d#diceFace)]
  }
}

/// Calculates and displays a DnD dice average from a string formatted roll
/// accepts strings of the following form:
/// - 0d0 (where 0 means any integer number)
/// - 0d0+0 
/// and will accept strings with any number of spaces (but no other characters)
/// it is the user's responsibility to ensure that the formatting is correct
#let dice(value) = {
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
  // repr(numbers)
  let numDice = int(numbers.at(0))
  let diceValue = int(numbers.at(1))

  let modifier
  if (dice_mod.len() > 1) {
    modifier = int(dice_mod.at(1))
    if (negative) {
        modifier = -modifier
    }
    // repr(modifier)
  } else {
    modifier = 0
  }

  diceRaw(numDice, diceValue, modifier)
}

/// takes an integer CR and formats with experience
/// will do nothing if CR is not a standard number
/// represent non integer CRs as decimals
#let challenge(cr) = {
  if (str(cr) in challenge_xp.keys()) {
    [#cr (#challenge_xp.at(str(cr)) XP)]
  } else {
    [#cr]
  }
}


#let stroke() = {
  line(stroke: (paint: gradient.linear(dndred, colour.bgtan), thickness: 1.5pt), length: 100%)
}

/// header block for monster stats
#let statheading(
  titleText, desc: []
) = [
  #{
    set text(font: title, fill: dndred, size: fontsize * 1.8)
    smallcaps(titleText)
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
#let skill(title, contents) = [
  #set text(dndred) 
  *#title* #contents 
]

/// AC, HP, Speed stats
/// expects hp_dice as a valid dice value. If you don't want to use this just use hp_etc
#let mainstats(ac: "", hp_dice: "", speed: "30ft", hp_etc: "") = [
  #skill("Armor Class", ac) \
  #if (hp_dice != "") [
    #skill("Hit Points")[#dice(hp_dice) #hp_etc]
  ] else [
    #skill("Hit Points")[#hp_etc]
  ] \
  #skill("Speed", speed)
]

/// calculates and properly displays ability scores
#let ability(str, dex, con, int, wis, cha) = {
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
  stroke()
  v(-0.5em)
  set align(center)
  set table(stroke: none, align: center, row-gutter: -0.75em)
  set text(size: fontsize*0.9, fill: dndred)
  show table.cell.where(y: 0): strong
  table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    table.header(.."STR DEX CON INT WIS CHA".split(" ")),
    ..modifiers
  )
  v(-0.5em)
  stroke()
}



