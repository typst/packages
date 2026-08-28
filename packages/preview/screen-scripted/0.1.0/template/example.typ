#import "@preview/screen-scripted:0.1.0": *

/*
  Season 5, episode 10 of "Family Guy"

  Certain copyrighted materials appear in this work
  without permission from the copyright holder and is
  used under a good-faith claim of fair use
*/
#show: scripted.with(
  title: "Stuck Behind Robert Loggia",
  authors: "Seth Macfarlane",
  date: datetime(month: 8, day: 20, year: 2026),
  version: "0.0.1",
  info: [
    probablysethsemail\@domain.com \
    (555) 555-5555
  ],
  config: (
    /*
      Enable/disable input checking for some package functions
      Example: Sluglines should only expect "INT" or "EXT" 
    */
    check-strict: true,
    /*
      Control the slugline formatting
    */
    bold-slugs: true,
    /*
      Set to "false" for manual dialogue continuation.
    */
    dialogue-cont: true,
    /*
      Some templates use "--" whereas others use "-". Choose
      whichever version you prefer
    */
    slug-dashes: "single",  // "single" | "double"
    /*
      Customize the continued-dialogue marker if needed
    */
    cont-str: "CONT'D",
  )
)

/*
  The "character" function prepares variables ready to be
  reused throughout the document, which is ideal for placeholder
  names, or names that may change later.
*/
#let (char1, char1-fl) = character("Peter", "Griffin")
#let (char2, char2-fl, char2-full) = character("Lois", "Patrice", "Griffin")
#let (char3, char3-fl) = character("Chris", "Griffin")
#let (char4, char4-fl) = character("Robert", "Loggia")
#let (char5) = character("Meg")

#slugline[int][living room][day]

#char1, #char2, and #char3 sit on the family sofa. Meg quickly enters.

#dialogue[#char5][
  Mom? Dad? I decided I want a big party this year with all my friends. And maybe a band. Is that cool?
]

#dual-dialogue(
  dialogue[#char1][
    (mumbling) \
    Yeah, sure\... 
  ],
  dialogue[#char2][
    (mumbling) \
    Yeah, sure\... Why not? 
  ]
)

#dialogue[#char5][
  (excited) \
  Oh thanks guys, you're the best! 
]

Meg runs away in excitement.

#dialogue[#char2][
  What's she talking about, a party for what?
]

#dialogue[#char1][
  I don't know. She have her period or something? She getting married?
]

#dialogue[#char2][
  No, if she was getting married we probably would've seen a guy around, right?
]

#dialogue[#char1][
  Sound reasoning.
]

// https://www.youtube.com/watch?v=4-ohJ6oXGkI

#dialogue[#char3][
  You guys, it's #char5's birthday next week.
]

#dialogue[#char2][
  (gasps) \
  Oh my god it is! #char1 we got to put together a party!
]

#dialogue[#char1][
  Aw man, I hate kids birthday parties. It's going to be worse than that time when I got stuck behind #char4-fl at the airport.
]

#slugline[int][airport][day]

#char4-fl at the front of the line checks his bags in at the airport. #char1 is next in line to him. An attendant is assisting #char4-fl.

#dialogue[Attendant][
  May I have your name please?
]

#dialogue[#char4-fl][
  Robert Loggia.
]

#dialogue[Attendant][
  Can you spell that for me?
]

/*
  Remove this to see the template without any visual distractions
*/
#box(stroke: black, width: 100%)[
  #align(center)[
    #pad(
      top: 3in, bottom: 3in,
      left: 1in, right: 1in,
    )[
      This awkward space is added to showcase the auto-dialogue break feature.
    ]
  ] 
]

#dialogue[#char4-fl][
  Certainly. That's #char4-fl. \
  
  'R', as in "Robert Loggia". \
  'O', as in "Oh my god, it's Robert Loggia". \
  'B', as in "By god, that's Robert Loggia". \
  'E', as in "Everybody loves Robert Loggia". \
  'R', as in "Robert Loggia". \
  'T', as in "Tim, look over there, it's Robert Loggia". \
  
  Space. \
  
  'L', as in "Look, it's Robert Loggia"! 
]

/*
  There's also helpful shorthands that can be optionally used
*/
#d[#char1][  // dialogue
  Ugh\...
]

#sl[e][griffin house][d]  // slugline with EXT and DAY shorthands
#t[cut to]  // transition
#sl[i][kitchen][d]  // slugline with INT and DAY shorthands

Stewie prepares mail to be sent out while Brian reads the newspaper.
