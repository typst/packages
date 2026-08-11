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
  name: "Person MacPersonface",
  class: "Cleric", 
  subclass: "Life",
  level: 3,
  /* MULTICLASSING
  -> put your TOTAL level (e.g. 8) above, so the proficiency bonus, etc. are calculated correctly
  -> put the text to print as level (e.g. "3 + 5") here:
  level-print: "",
  */
  background: "Journeyman",
  player: "Person",
  species: "Leonin",
  alignment: "LN", // accepts text or a code of format LG, NG, CG, LN, NN, CN, LE, NE, CE
  xp: 0, 
  xp-type: "xp", // supports: xp, milestone, none (if none, space will be used by other fields)

/* * * STATS * * */
  strength: 14,
  dexterity: 12,
  constitution: 16,
  intelligence: 12,
  wisdom: 16,
  charisma: 8,

  // true: Stat in big field; false: Modifier in big field
  big-number-big-field: false,

/* * * SAVES * * */
  // set all saving throws that your character is proficient in to true
  consave: true,
  chasave: true,

/* * * SKILLS * * */
  // set all skills that your character is proficient in to true
  // you may delete any lines that would be "false"
  acrobatics: true,
  arcana: 0.5,
  athletics: 1,
  deception: 1.5,
  history: 2,
  nature: true,
  persuasion: true,
  sleight-of-hand: true,

  /* Half or Double Proficiency:
  -> Number instead of true/false.
  -> 0.5 for half, 2 for double, 1.5, 2.5, etc. 1 == true, 0 == false.
  -> Can be any float, results are rounded down.
  -> Circles will change to indicate the extra proficiency, up to 2
  */

  more-passive: true, // false: Passive Perception only, true: plus Passive Insight & Investigation

/* * * HEALTH * * */
  // "default" indicates what value this will be set to if the line is deleted (auto-calculation)
  armorclass: 14, // default = 10+Dex (i.e. not wearing armor)
  initiative: 0, // default = Dex mod
  speed: 30, //default = 30ft
  hp-max: 40, // hp-current and hp-temp are available as well
  hitdice-total: 5, // default = Level (or level-print, for multiclassers)
  hitdice-type: "d6",
  deathsave-s: 0, // successes; default = 0
  deathsave-f: 0, // failures; default = 0

/* * * MISC * * */
  inspiration: "1d4", // number or string

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
  ("Mace", "sp", ("1d6", "slash.")),
  ("Shortbow", 3, "1d6+1 piercing" ),
  ("Longbow", "d", "1d8+1 pierc."),
  ("Dagger", "dp", ("1d4", "pierc.")),
  ),
  // Freeform Text to display below weapons list
  attacks-text: [
    Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
  ],

/* * * OTHER PROFICIENCIES & LANGUAGES * * */
  prof-lang-text: [
    #strong[Languages:] Common \
    #strong[Armor:] light, medium, shields \
    #strong[Weapons:] simple \
    #strong[Tools:] Thieves' tools, Herbalism kit
  ],

/* * * EQUIPMENT * * */
  equipment-text: [
    Mace, Shortbow, Quiver (20 arrows) \
    Waterskin, Mess Kit, 10 rations \
    50ft Hempen Rope
  ],
  display-money: true, // true: display money boxes; false: no boxes; default: true
  money: (4,11,"-",29,0), // cp, sp, ep, gp, pp
  big-equip: false, // Gives you a bigger equipment box with two columns, making the Features & Traits box smaller in exchange

/* * * PERSONALITY * * */
  personality-traits: [I take great pains to always look my best and follow the latest fashions.],
  ideals: [#strong[Knowledge.] Knowledge is power, and knowing which horse to back is the key to success.],
  bonds: [Growing up, I had an imaginary friend I could always count on. That friend is still with me. ],
  flaws: [I don't know when to quit. Especially when everyone else is telling me to.],

/* * * FEATURES & TRAITS * * */
  features-traits: [
    #lorem(80)]
)

#details-sheet(
  settings: settings,
  // Everything for this page is a string.
  // Use "" or [] as you like, [] will be needed for linebreaks and text styling to work
/* * * HEADER * * */
  name: "Person MacPersonface", // Yes, you have to enter it again, sorry
  age: "24 years",
  height: [6'9½" (207cm)],
  weight: "258lbs (117kg)",
  eyes: "golden",
  skin: "blue",
  hair: "long wavy white",
/* * * IMAGES * * */
  // Image paths are relative to this file
  // If you leave the other options as they are, the image will be fitted to the boxes on the sheet without distortion
  appearance: image("./img/person.png", width:162pt,height:220pt, fit: "contain"),
  symbol: image("./img/symbol.png", width:140.5pt,height:121pt, fit: "contain"),
  symbol-name: "Symbol of the Direction Club",
/* * * TEXT FIELDS * * */
  backstory: [
    #lorem(164)],
  allies-organizations: [
    #lorem(100)],
  additional-features-traits: [
    #lorem(170)],
  treasure: [
    #lorem(130)],
)

#spell-sheet(
  settings: settings,
/* * * HEADER * * */
  spellcasting-class: "Magician",
  spellcasting-ability: "Charisma",
  spell-save-dc: 18, // String or Int
  spell-attack-bonus: "+3", // String or Int, Int automatically adds "+"

/* * * SPELLS * * */
  /* In the () for the appropiate level, place a list of spells, each spell name in "".
  The spell list for each level is sized automatically.
  To mark some spells prepared, wrap them in extra () and add a boolean for preparedness
  -> like so: (true, "Spell Name 1") or so ("Spell Name 2", true)
  -> This can be mixed with simple string spells.
  If you'd like a line with no text to be printed, add "",
  When you leave a () empty or delete the parameter entirely, no header for that spell level will be printed. */ 
  cantrips: ("Dancing Lights", "Shillelagh", "Vicious Mockery"),
  lvl1-spells: ((true, "Absorb Elements"), "Aid", "Alarm", (false, "Animal Friendship"), ("Animal Messenger", true), "Barkskin", "Beast Bond", "Beast Sense", "Commune with Nature", "Conjure Animals", "Conjure Barrage", "Conjure Volley", "Conjure Woodland Beings", "Cordon of Arrows", "Cure Wounds", "Darkvision", "Daylight", "Detect Magic", "Detect Poison and Disease"),
  lvl2-spells: ("Dominate Beast", "Elemental Weapon", "Enhance Ability", "Ensnaring Strike", "Entangle", "Find Traps", ("Flame Arrows", true), "Fog Cloud", "Freedom of Movement", "Goodberry", "Grasping Vine", "Greater Restoration", "Guardian of Nature", "Gust of Wind", "Hail of Thorns", "Healing Spirit", "Hunter's Mark", "Jump", "Lesser Restoration"),
  lvl3-spells: ("Lightning Arrow", "Locate Animals or Plants", "Locate Creature", "Locate Object", "Longstrider", "Magic Weapon", "Meld into Stone", "Nondetection", "Pass without Trace", "Plant Growth", "Protection from Energy", "Protection from Poison", "Revivify", "Searing Smite", "Silence", "Snare"),
  lvl4-spells: ("Speak with Animals", "Speak with Plants", "Spike Growth", "Steel Wind Strike", "Stoneskin", "Summon Beast", "Summon Elemental", "Summon Fey"),
  lvl5-spells: ("Swift Quiver", "Tree Stride", "Water Breathing", "Water Walk", "Wind Wall", "Wrath of Nature", "Zephyr Strike"),
  lvl6-spells: ("Tasha's Otherworldly Guys", "Otto's Irresistible Dance"),
  lvl7-spells: ("Mordenkainens Funny Hideout", "Reverse Gravy"),
  lvl8-spells: ("Abi-Dalzim's Horrid Quilting", "Glibness"),
  lvl9-spells: ("Glade of Disaster", "Power Word Feel", "Weird"),

  /* * * SPELL SLOTS * * */
  // enter the number of total/expended slots in order of spell level, adding a 0 to skip a level
  slots-total: (4,3,3,3,3,2,2,1,1),
  slots-expended: (1,2,3,0,0,1)
)

// If you'd like, you can continue with a normal document before, after or inbetween the character sheet!
#set page(
  paper: "us-letter",
)
= Notes
My character is very cool!
== Backstory
Person MacPersonface grew up in a village with many cats and liked to drink applejuice as a kid.
