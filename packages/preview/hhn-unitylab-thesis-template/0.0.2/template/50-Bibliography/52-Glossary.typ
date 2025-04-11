#import "../../src/config.typ": *
//#import "@preview/unitylab-thesis-template:0.0.1": *

// Glossary
#let entry-list = (
  (
    key: "gpu",
    group: "Glossary Group 1", 
    short: "GPU",
    //plural: "", 
    long: "Graphical Processing Unit",
    //longplural: "",
    description: [ 
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
    description: [ 
      Write down the definition here. If you write in German, please add the English term as well.
    ],
  ),
)
#register-glossary(entry-list)
