#import "@preview/flyingcircus:3.3.0": *
#import "@preview/cetz:0.4.0"

#let title = "Sample Flying Circus Book"
#let author = "Tetragramm"

#show: FlyingCircus.with(
  Title: title,
  Author: author,
  CoverImg: image("images/Cover.png"),
  Dedication: [Look strange? You probably don't have the fonts installed.

    Download the fonts from #link("https://github.com/Tetragramm/flying-circus-typst-template/archive/refs/heads/Fonts.zip")[HERE].
    Install them on your computer, upload them to the Typst web-app (anywhere in the project is fine) or use the Typst
    command line option --font-path to include them.],
)

#FCPlane(
  json("./Basic Biplane_stats.json"),
  Nickname: "Bring home the bacon!",
  Img: image("images/Bergziegel_image.jpg"),
  BoxText: ("Role": "Fast Bomber", "First Flight": "1601", "Strengths": "Fastest Bomber"),
  BoxAnchor: "north-west",
)[
  _This text is where the description of the plane goes. Formatting is pretty simple. This is italic._

  #underline[Words get underlined.]

  Leave an *empty* line or it will be the same paragraph

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
#FCVehicleSimple(json("Sample Vehicle_stats.json"))[#lorem(120)]

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
  json("Sample Vehicle_stats.json"),
  Img: image("images/Wandelburg.jpg"),
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

#FCVehicleFancy(json("Sample Vehicle_stats.json"))[][#lorem(100)]

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

#HiddenHeading[= Playbooks]
#set heading(offset: 1)

#FCPlaybook(
  //Obvious
  Name: "A Worker",
  //Gotta go Somewhere
  Subhead: "Industrial Town",
  //This is the left column of the first page, all the character questions.
  Character: [
    #block()[
      #set par(justify: true)
      _The Old World might be gone, but many of its technological wonders persist, and to keep them going, those towns that can
      still support industry work double-hard. Many people, be they refugees from the old cities or poor folks from across the
      world, come to these places in hopes of steady work. They'll find it, more often than not, but that labour is frequently
      backbreaking and the compensation paltry. Compared to that, who wouldn't want to take to the skies?_
    ]
    #FCPSection("Name")[Choose, or write your own]
    _Anthony, Dietrich, Gunter, Hans, Hermann, Jan, Klaus, Werner, Willy_

    _Bertha, Emma, Gertrud, Hilda, Ilse, Ingrid, Karla, Mercédès_

    #h(1fr)_Moser, Scheffler, Hamann, Muller, Schmidt, Weber, Becker, Bauer_

    Age Range: _Youth (16-22), Adult (23-30)_
    #FCPSection("Current Residence", "Choose, or write your own")
    _Choose a town from another playbook, though it is far behind you now._
    #FCPSection("People", "Choose all that apply")
    _Städter, Himmilvolk, Rishonim, or any other._
    #FCPSection("Expectations", "Tell the table or write it out")
    This is an archetypical image of a Worker. What resonates with you? What doesn't?
    - _Masculine, feminine, or nonbinary._
    - _Responsible, organized, hardworking, never complains. Always tired._
    - _Worn, sore, gone to seed. Hands rough, stained, often scarred._
    - _Simple, drab, cheap clothing, hard-wearing enough for the job ahead._
    //These let you choose where to stretch the page.  The empty space gets put into these in proportion to the number.  2fr is twice as big as 1fr
    #v(1fr)
    #FCPSection("Character History")[Choose all that apply]

    I was taught to fly by...
    #columns(2, gutter: 0pt)[
      - ...an expensive training course.
      - ...an instructor when I was conscripted.
      #colbreak()
      - ...a family member, passing it on.
      - ...nobody, I'm just winging it.
    ]

    I left my home because...

    #columns(3, gutter: 0pt)[
      - ...jobs dried up.
      - ...I got hurt and fired.
      #colbreak()
      - ...it was killing me.
      - ...I want something better.
      #colbreak()
      - ...they learned I was queer.
      - ...I broke the law.
    ]

    I fly so I can make some money and so I can...

    #columns(2, gutter: 0pt)[
      - ...make sure my kids have it better.
      - ...do something with my life.
      - ...maybe retire, ever.
      - ...pay off some serious debts.
      #colbreak()
      - ...finally get on that adventure.
      - ...break free of my obligations.
      - ...escape the town I've been stuck in.
      - ...find a reason to keep going.
    ]
  ],
  //Top part of the right page
  Questions: [
    #FCPSection("Questions")[Write your answers, and speak them]
    - What were you, before you were another anonymous worker?
      - #underline[Take 2 Personal Moves] from another playbook (or 1 Student move) to represent this origin, or two additional
        Worker moves if this is all you've ever known.
    - What was your dream job, as a child? What job did you actually end up working?
    - Where are your family staying, if not with you?
    #v(1fr)
    #FCPSection("Trust")[Ask and record answers]
    You trust everyone. They're your co-workers, you're not here for drama.
    #v(1fr)
  ],
  //This is the starting assets, burdens, ect.
  //Note that we set the default marker and gutter size instead of specifying for each one, like we did above.
  //This can save a lot of typing, if your use is consistent.
  Starting: [
    #set list(marker: [○])
    #set columns(gutter: 0pt)
    #KochFont(size: 18pt)[Start With...]
    #FCPSection("Assets")[Choose 3]
    #columns(2)[
      - A plane large enough to carry your family.
      - A simple, robust sidearm.
      - A membership in a large union.
      #colbreak()
      - Two co-workers with special skills.
      - A house somewhere relatively safe.
      - A set of solid boots.
    ]

    #FCPSection("Dependents")[Choose 2]
    #columns(2)[
      - A spouse without meaningful income.
      - A parent, now old and infirm.
      - A number of small children.
      #colbreak()
      - A sibling, unable to work.
      - A close friend, disabled.
      - An apprentice, learning your trade.
    ]

    #FCPSection("Planes")[Choose 1, or a plane worth up to 15þ]
    #columns(2)[
      - Theler KanonenKobra MB (Used)
      - König-Werke Adler-N (Used)
      #colbreak()
      - Kreuzer Skorpion (Used)
      - Markgraf Volksfestung A (Used)
    ]

    #FCPSection("Familiar Vices")[Choose 3]
    #columns(4)[
      - Drinking
      - Opiates
      #colbreak()
      - Tobacco
      - Cannabis
      #colbreak()
      - Music
      - Bickering
      #colbreak()
      - Reading
      - Sleeping
    ]
  ],
  //This does in fact do magic, literally and figuratively, so you can use whatever stat names your playbook has, like witches do.  One of these shows Wild, as an example.
  Stats: [
    #FCPStatTable("Jobber", "Let's get paid and go home.", (Hard: "+1", Keen: "+1", Calm: "+1", Daring: "+1"))

    #FCPStatTable(
      "New Lease on Life",
      "Beats going back to the mines!",
      (Hard: "+2", Keen: "-1", Calm: "-1", Daring: "+2", Wild: "-"),
    )

    #colbreak()

    #FCPStatTable("Worn Down", "Just punching the clock.", (Hard: "+2", Keen: "+2", Calm: "+2", Daring: "-4"))

    #FCPStatTable(
      "Safety Inspector",
      "No point taking extra risks.",
      (Hard: "-2", Keen: "+2", Calm: "+4", Daring: "-2"),
    )
  ],
  //This is defining them so the circles show up right.  It does not check to make sure they're the same as the StatTables.
  StatNames: ("Hard", "Keen", "Calm", "Daring"),
  //This shows two useful things.
  //place lets you just stick stuff on top of other stuff.  Just define the position, either relative to here, or use float: true to set things absolute.
  //Also define a small function.  This is a less verbose way of doing things that you repeat a lot.
  Triggers: [
    #place(dx: 1.6cm, dy: -0.3cm)[_Start with 3 Stress_]
    #let dotfill() = {
      box(width: 1fr, repeat[.])
    }
    #FCPSection("Triggers")[]
    - If you took a life#dotfill() 1 Stress
    - If there was combat#dotfill() 1 Stress
    - If your plane got shot#dotfill() 1 Stress
    - If you were wounded#dotfill() 2 Stress
    - If a comrade was wounded#dotfill() 2 Stress
    - If your plane stopped working#dotfill() 2 Stress
    - If you had to wingwalk#dotfill() 1 Stress
    - If the job got out of hand#dotfill() 2 Stress
  ],
  //Vents.
  Vents: [
    #FCPSection("Vents")[]
    - Complain about your circumstances to a comrade.
    - Buy something nice for yourself.
    - Complain about pay to a comrade.
    - Stir up trouble with the employees.
    - Deliberately trigger End of Night by maxing out your Vice track.
  ],
  //The last move goes here.
  Intimacy: [
    #FCPSection("Intimacy Move")[Start with this Move]
    *Share the Burden*: _When you are intimate with comrades_, the Stress of all the characters participating can be freely
    redistributed between them. If there are any NPC participants, 1 Stress is also removed from each PC.

    _If you use this move in the air_, 1 additional Stress is removed from each character.
  ],
  //This is the whole right column.  Useful thing is the use of place and stack at the bottom to make the Mastery Progress tracker.
  //Also showing how to do one-off markers in lists, like a filled in bubble.
  Moves: [
    #FCPSection("Personal Moves")[Take Breadwinner and choose 3 more]
    - Breadwinner: Instead of personal upkeep, you have two Dependents. Write their names, and mark 1 on one and 2 on the
      other. Each Routine, during Expenses, choose to pay 0, 1, or 2 Thaler for each Dependent. If you pay 0, erase one mark.
      If you pay 2, mark their track and describe what special thing you do for them to make their lives easier.

      A Dependent at 2 Marks removes 1 Stress per routine. A Dependent losing a Mark gives 1 Stress, and at 0 Marks they cause
      2 Stress per routine.

    #stack(
      dir: ltr,
      spacing: 0.5em,
      box(width: 30%, stroke: (bottom: 1pt))[#circle(radius: 5pt, stroke: none)],
      circle(radius: 5pt),
      circle(radius: 5pt),
      circle(radius: 10pt, stroke: none),
      box(width: 30%, stroke: (bottom: 1pt))[#circle(radius: 5pt, stroke: none)],
      circle(radius: 5pt),
      circle(radius: 5pt),
    )
    #FCPRule()
    #[
      #set list(marker: "●", spacing: 1em)
      - *There for You*: _When you Get Real_, your target always loses 1 extra Stress.
      #set list(marker: "○")
      - *Get it Done*: Each Routine, hold 3. Spend that hold to score a partial hit on any roll, without rolling first.
      - *Time Out*: _When you intervene in a dispute_, #underline[roll +Calm]. On a hit, the conflict cannot escalate to
        violence. 16+, everyone names a compromise they would be willing to make.
      - *Hard Drinking*: You may reroll two dice in the End of Night roll.
      - *Old Reliable*: After 3 Routines in the same plane, without it being modified or upgraded, the plane gains +8 Toughness
        and +3 Reliability. This is once per plane, and the bonus is removed if the plane is modified.
      - *No Drama*: The first time each Routine that somebody Vents with you as the victim, instead of Stress you take 2 XP
        directly.
      - *Open Mind*: _When you perform a Move Exchange_, both sides can learn as many moves as they have XP for from one
        another, instead of just 1. Other playbook moves cost 1 less XP to learn, and this character can teach any move they've
        learned.
      - *Domestic Bliss*: While you have 0 Stress, take +1 ongoing to all rolls outside of air combat.
    ]
    #FCPRule()
    #FCPSection("Other Moves & Notes")[Start with 1 Mastery Move and 3þ]
    All your XP costs are doubled.

    #place(bottom + right)[
      #stack(
        dir: ltr,
        spacing: 0.2em,
        KochFont[Other Progress],
        circle(radius: 6pt),
        circle(radius: 6pt),
        circle(radius: 6pt),
        circle(radius: 6pt),
      )
      #stack(
        dir: ltr,
        spacing: 0.2em,
        KochFont[Mastery Progress],
        circle(radius: 6pt),
        circle(radius: 6pt),
        circle(radius: 6pt),
        circle(radius: 6pt),
        circle(radius: 6pt),
      )
    ]
  ],
)


#let BraunYA = (
  Name: "Braun YA Post Runner",
  Nickname: "Precious Lifelines",
  Price: 17,
  Used: 8,
  Upkeep: 1,
  Speeds: [23 - 15 - 12 - 8],
  Handling: 90,
  Structure: 21,
  Notes: [1 Crew. 2 Engines. Low radiator. Small cargo space. 20 Fuel Uses.],
)

#FCShortNPC(
  BraunYA,
  img: image("images/Bergziegel_image.jpg"),
  img_scale: 1.5,
  img_shift_dx: -10%,
  img_shift_dy: -10%,
)[Undoubtedly the most common sort of aircraft in the skies of Himmilgard are post runners, a ragtag mixture of disarmed
  obsolete fighters and purpose-built mail planes like this one.]

#let AirDestroyer = (
  Name: "Jörmungandr-class Air Destroyer",
  Nickname: "Ship of the Line",
  Speed: 12,
  Lift: 60,
  Handling: 40,
  Toughness: 100,
  Notes: [Luftane. 100-250 crew. x6 Engines. Armoured Skin 2, Armour 4/5+.\
    x8 Flak Cannons. Large number of machine gun turrets.\
    Pushes Weather Flak against attackers.],
)

#FCShortAirship(AirDestroyer)[The most common form of Air Destroyer in the war, forming the basis of the Gotha Empire's zeppelin fleet. A warlord
  repairing a downed Jörmungandr can threaten an entire region.]

