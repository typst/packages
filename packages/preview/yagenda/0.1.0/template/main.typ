#import "@preview/yagenda:0.1.0": *

#show: agenda.with(
  name: "Pumpkins and peanuts committee", 
  date: "03/01/2000", 
  time: "2 pm",
  location: "baseball field", 
  invited: [Sally, Shroeder, Pig-pen, Marcie]
)

// load external yaml
#let topics = yaml("agenda.yaml")

// alternative: embed yaml in-place

// #let tmp = `
// "linus blanket workshop":
//   Topic: Linus and his blanket
//   Time: 20 mins
//   Lead: Lucy
//   Purpose: Understand, *Support*
//   Preparation: |
//     - Bring your own security blanket (optional)
//     - Reflect on the significance of Linus's blanket
//   Process: |
//     - Discuss the history and symbolism of Linus's security blanket
//     - Explore ways to help both Linus and Snoopy 
//     - Release a blanket statement

// "snoopy plane fights":
//   Topic: Snoopy vs the Baron
//   Time: 10 mins
//   Lead: Woodstock
//   Purpose: Support
//   Preparation: |
//     - Bring your favorite Snoopy flying ace memory
//     - Reflect on Snoopy's aerial prowess
//   Process: |
//     - Share anecdotes from Snoopy's battles
//     - Discuss the psychological implications of Snoopy's dogging of bullets`.text

// #let topics = yaml.decode(tmp)

#agenda-table(topics)

#set page(flipped: false)

== Appendix

#lorem(120)

