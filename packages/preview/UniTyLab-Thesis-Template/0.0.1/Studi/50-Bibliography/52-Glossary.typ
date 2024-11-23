#import "../../Template/config.typ": *


// Variables
#let h-spacer = h(0.5cm)


// Glossary
#let entry-list = (
  (
    key: "gpu",
    group: "Glossary Group 1", 
    short: "GPU",
    //plural: "", 
    long: "Graphical Processing Unit",
    //longplural: "",
    desc: [ #h-spacer (engl.: Graphical Processing Unit) #linebreak()
      Write down the definition here. If you write in German, please add the English term as well.
    ],
  ), 
  (
    key: "cpu",
    group: "Glossary Group 2", 
    short: "CPU",
    //plural: "", 
    long: "Central Processing Unit",
    //longplural: "",
    desc: [ #h-spacer (engl.: Central Processing Unit) #linebreak()
      Write down the definition here. If you write in German, please add the English term as well.
    ],
  ),
)

#register-glossary(entry-list)
