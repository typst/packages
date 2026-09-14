// Skills (English)
// Exports functions that render skill sections for the sidebar

#import "@preview/mrbogo-cv:1.0.5": item-with-level, side-block
#import "labels.typ": *

#let skills-technical = {
  side-block(label-technical, first: true)[
    #item-with-level("Skill One", 5)
    #item-with-level("Skill Two", 4)
    #item-with-level("Skill Three", 4)
    #item-with-level("Skill Four", 3)
  ]
}

#let skills-soft = {
  side-block(label-soft)[
    #item-with-level("Communication", 5)
    #item-with-level("Leadership", 4)
    #item-with-level("Problem Solving", 5)
    #item-with-level("Teamwork", 4)
  ]
}

#let skills-languages-spoken = {
  block(breakable: false, above: 0.8em)[
    = #label-spoken-languages
    #item-with-level(lang-english, 5)
    #item-with-level(lang-spanish, 3)
  ]
}
