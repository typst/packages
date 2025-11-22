#import "@preview/flyingcircus:3.0.0" : *

#let title = "Sample Flying Circus Book"
#let author = "Tetragramm"

#show: FlyingCircus.with(Title: title, Author: author, CoverImg: image("images/Cover.png"), Dedication: [Look strange? You probably don't have the fonts installed.

Download the fonts from #link("https://github.com/Tetragramm/flying-circus-typst-template/archive/refs/heads/Fonts.zip")[HERE].  Install them on your computer, upload them to the Typst web-app (anywhere in the project is fine) or use the Typst command line option --font-path to include them.])

#FCPlane(
  read("Basic Biplane_stats.json"),
  Nickname: "Bring home the bacon!",
  Img: image("images/Bergziegel_image.png"),
)[
This text is where the description of the plane goes. Formatting is pretty simple, but bold and italic don't work yet, I
need to fake those.
 
#underline[Words get underlined.]

Leave an empty line or it will be the same paragraph
 
+ numbered list
  + Sub-Lists!
+ Things! But you can have multiple lines for an item by indenting the next one, or just one long line.
  - Sub-items!

- Unnumbered list
 
Break the column where you want it with `#colbreak()`

Images can be added by doing `#image(path)`. The FC functions do fancy stuff though, and may override some arguments
when you pass an image into them using an argument.

Find the full documentation for Typst on the website #link("https://typst.app/docs")[#text(fill: blue)[HERE]]
]

//If we don't want all our planes at the top level of the table of contents.  EX: if we want
// - Intro
// - Story
// - Planes 
//   - First Plane
// We break the page, and create a HiddenHeading, that doesn't show up in the document (Or a normal heading, if that's what you need)
//Then we set the heading offset to one so everything after that is indented one level in the table of contents.
#pagebreak()
#HiddenHeading[= Vehicles]
#set heading(offset: 1)

//Parameters
#FCVehicleSimple(read("Sample Vehicle_stats.json"))[#lorem(120)]

//We wrap this in a text box so that we can set a special rule to apply
#text[
  //Set it so that the headings are offset by a large amount, so they don't show up in the table of contents.
  #set heading(offset: 10)
  //
  #FCWeapon(
    (Name: "Rifle/Carbine", Cells: (Hits: 1, Damage: 2, AP: 1, Range: "Extreme"), Price: "Scrip", Tags: "Manual"),
    Img: image("images/Rifle.png"),
  )[
    Note that you can set the text in the cell boxes to whatever you want.
  ]
   
  #FCWeapon((
    Name: "Machine-Gun (MG)",
    Cells: (Hits: 4, Damage: 2, AP: 1, "Ammo Count": 10),
    Price: "2þ",
    Tags: "Rapid Fire, Jam 1/2",
  ))[
    Note that you can set the text in the cell boxes to whatever you want using the dictionary.
  ]
]


#FCVehicleFancy(
  read("Sample Vehicle_stats.json"),
  Img: image("images/Wandelburg.png"),
  TextVOffset: 6.2in,
  BoxText: ("Role": "Fast Bomber", "First Flight": "1601", "Strengths": "Fastest Bomber"),
  BoxAnchor: "north-east",
)[
  The project to build the first armoured attack vehicle in the Gotha Empire spanned nearly three decades. Largely
  considered a low priority during the war with the UWF, the fierce fighting against the Macchi Republics suddenly
  accelerated the project, which went from concept sketch to deployment in six short months.
   
  This development was accompanied by intense secrecy: the project was code-named “Wandering Castle”, which gave the
  impression it was a Leviathan-building enterprise.
   
  Used for the first time in the Battle of Reggiane in 1593, the Type 1 reflects the idea that the tank ought to be a sort
  of mobile form of the concrete pillboxes coming into use at the time. Though suffering frequent breakdowns, plagued with
  difficulties getting its main gun on target, and very vulnerable in the mountains, it was successful enough that it soon
  became the most-produced tank of the war.
   
  After the first six months the official name of the vehicle was changed from its codename to “Self-Propelled Assault
  Vehicle Type 1”, known by the acronym “SbRd-AnZg Ausf I”. This development was ignored by everyone outside of official
  communications.
][#lorem(100)]

#FCVehicleFancy(read("Sample Vehicle_stats.json"))[][#lorem(100)]

#let ship_stats = (
  Name: "Macchi Frigate",
  Speed: 5,
  Handling: 15,
  Hardness: 9,
  Soak: 0,
  Strengths: "-",
  Weaknesses: "-",
  Weapons: (
    (Name: "x2 Light Howitzer", Fore: "x1", Left: "x2", Right: "x2", Rear: "x1"),
    (Name: "x6 Pom-Pom Gun", Fore: "x2", Left: "x3", Right: "x3", Rear: "x2", Up: "x6"),
    (Name: "x2 WMG", Left: "x1", Right: "x1"),
  ),
  DamageStates: ("", "-1 Speed", "-3 Guns", "-1 Speed", "-3 Guns", "Sinking"),
)

#set heading(offset: 0)
#FCShip(
  Img: image("images/Macchi Frigate.png"),
  Ship: ship_stats,
)[
  Though remembered for large bombardment ships and airship tenders, the majority of the Seeheer was in fact these
  mid-sized frigates. These ships were designed for patrolling the seas for enemy airships and to escort Macchi cargo
  ships along the coast. They proved a deadly threat to landing barge attacks in the Caproni islands, as it was found
  their anti- aircraft guns were also effective against surface targets.
][
  160 crew
] 