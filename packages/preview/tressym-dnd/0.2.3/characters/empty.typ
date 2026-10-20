#import "@preview/tressym-dnd:0.2.3": *
/* * * SETTINGS * * */
#let settings = (
  language: "en", // only changes built-in lang features, no changes are made to the sheet text
  printer-mono: false, // true for black outlines, false for colored
  spell-rainbows: true, // changes the paper rules of the spell list to rainbow gradients
  body-font: "Vollkorn" // The spacing, leading, font sizes and placing in this template were optimized for Vollkorn font. You may of course experiment with different fonts if you like, a popular choice for character sheets is e.g. Kalam.
)

#character-sheet(
  settings: settings,
  /* * * HEADER * * */
  name: "", // name of the character
  class: "", 
  subclass: "",
  level: 1, 
  /* MULTICLASSING
  -> put your TOTAL level (e.g. 8) above, so the proficiency bonus, etc. are calculated correctly
  -> put the text to print as level (e.g. "3 + 5") here:
  level-print: "",
  */
  background: "",
  player: "", // name of the player
  species: "", // species (5e-2024) or race (5e-2014)
  alignment: "", // accepts text or a code of format LG, NG, CG, LN, NN, CN, LE, NE, CE
  xp: 0, 
  xp-type: "xp", // supports: xp, milestone, none (if none, space will be used by other fields)

/* * * STATS * * */
  strength: 10,
  dexterity: 10,
  constitution: 10,
  intelligence: 10,
  wisdom: 10,
  charisma: 10,

  // true: Stat in big field; false: Modifier in big field
  big-number-big-field: true,

/* * * SAVES * * */
  // set all saving throws that your character is proficient in to true
  // you may delete any lines that are set to "false"
  strsave: true,
  dexsave: true,
  consave: true,
  intsave: true,
  wissave: true,
  chasave: true,

/* * * SKILLS * * */
  // set all skills that your character is proficient in to true
  // you may delete any lines that would be "false"
  acrobatics: true,
  animal-handling: 0,
  arcana: 0.5,
  athletics: 1,
  deception: 1.5,
  history: 2,
  insight: 2.5,
  intimidation: true,
  investigation: true,
  medicine: true,
  nature: true,
  perception: true,
  performance: true,
  persuasion: true,
  religion: true,
  sleight-of-hand: true,
  stealth: true,
  survival: true,

  /* For Half Proficiency (Bard: Jack of All Trades) or Double Proficiency (Bard: Expertise, Ranger: Deft Explorer, Rogue: Expertise), use a number instead of true/false.
  -> 0.5 for half, 2 for double, 1.5, 2.5, etc. 1 == true, 0 == false.
  -> Can be any float, results are rounded down.
  -> Circles will change to indicate the extra proficiency, up to 2 */

  more-passive: false, // false: Passive Perception only, true: plus Passive Insight & Investigation
  
/* * * HEALTH * * */
  // "default" indicates what value this will be set to if the line is deleted (auto-calculation)
  armorclass: none, // default = 10+Dex (i.e. not wearing armor)
  initiative: none, // default = Dex mod
  speed: 30, //default = 30ft
  hp-max: 0, // hp-current and hp-temp are available as well
  hitdice-total: 0, // default = Level
  hitdice-type: "d",
  deathsave-s: 0, // successes; default = 0
  deathsave-f: 0, // failures; default = 0

/* * * MISC * * */
  inspiration: "", // number or string


/* * * ATTACKS & SPELLCASTING * * */
  /*
  + You may add as many weapons as the paper fits.
  + Field 1: Name (string)
  + Field 2: Attack Bonus; can be either a number
    OR "sp", "dp", "s" or "d" to indicate whether to use Strength or Dexterity and whether you are proficient in this weapon. This way the numbers update automatically on level up.
  + Field 3: Damage; can be either a freeform text
    OR an array of form (dice, type), e.g. ("1d4", "slash")
    -> the latter only works in combo with the "sp", etc. from above
  */
  weapons: (
  ("Weapon Name", 0, "1d6+1 slash." ),
  ),
  attacks-text: [
    // Freeform Text to display below weapons list
  ],

/* * * OTHER PROFICIENCIES & LANGUAGES * * */
  prof-lang-text: [
    #strong[Languages:] Common \
    #strong[Armor:] \
    #strong[Weapons:] \
    #strong[Tools:] 
  ],

/* * * EQUIPMENT * * */
  equipment-text: [
  ],
  display-money: true, // true: display money boxes; false: no boxes; default: true
  money: (0,0,"-",0,0), // cp, sp, ep, gp, pp
  big-equip: true, // Gives you a bigger equipment box with two columns, making the Features & Traits box smaller in exchange

/* * * PERSONALITY * * */
  personality-traits: [],
  ideals: [],
  bonds: [],
  flaws: [],

/* * * FEATURES & TRAITS * * */
  features-traits: [
  ]
)

#details-sheet(
  settings: settings,
  // Everything for this page is a string.
  // Use "" or [] as you like, [] will be needed for linebreaks and text styling to work
/* * * HEADER * * */
  name: "", // Yes, you have to enter it again, sorry
  age: "",
  height: ['" (cm)],
  weight: "lbs (kg)",
  eyes: "",
  skin: "",
  hair: "",
/* * * IMAGES * * */
  // Image paths are relative to this file
  // If you leave the other options as they are, the image will be fitted to the boxes on the sheet without distortion
  appearance: image("./img/person.png", width:162pt,height:220pt, fit: "contain"),
  symbol: image("./img/symbol.png", width:140.5pt,height:121pt, fit: "contain"),
  symbol-name: "Symbol of the Direction Club",
/* * * TEXT FIELDS * * */
  backstory: [
  ],
  allies-organizations: [
  ],
  additional-features-traits: [
  ],
  treasure: [
  ],
)

#spell-sheet(
  settings: settings,
/* * * HEADER * * */
  spellcasting-class: "",
  spellcasting-ability: "",
  spell-save-dc: "", // string or int
  spell-attack-bonus: "", // string or int, int automatically adds "+"

/* * * SPELLS * * */
  /* In the () for the appropiate level, place a list of spells, each spell name in "".
  The spell list for each level is sized automatically.
  To mark some spells prepared, wrap them in extra () and add a boolean for preparedness
  -> like so: (true, "Spell Name 1") or so ("Spell Name 2", true)
  -> This can be mixed with simple string spells.
  If you'd like a line with no text to be printed, add "",
  When you leave a () empty or delete the parameter entirely, no header for that spell level will be printed. */ 
  cantrips: (),
  lvl1-spells: (),
  lvl2-spells: (),
  lvl3-spells: (),
  lvl4-spells: (),
  lvl5-spells: (),
  lvl6-spells: (),
  lvl7-spells: (),
  lvl8-spells: (),
  lvl9-spells: (),

  /* * * SPELL SLOTS * * */
  // enter the number of total/expended slots in order of spell level, adding a 0 to skip a level
  slots-total: (),
  slots-expended: ()
)

// If you'd like, you can continue with a normal document before, after or inbetween the character sheet!
/*
#set page(
  paper: "us-letter",
)
= Notes
My character is very cool!
== Backstory
They grew up in a village with many cats and liked to drink applejuice as a kid.
*/
