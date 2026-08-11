#import "themes/fancy.typ": *
#import "themes/modern.typ": *
#import "themes/classic.typ": *
#import "themes/orly.typ": *

// Part
#let part = it => context if states.theme.get().contains("fancy") {
  part-fancy(it)
} else if states.theme.get().contains("modern") {
  part-modern(it)
} else if states.theme.get().contains("classic") {
  part-classic(it)
} else if states.theme.get().contains("orly") {
  part-orly(it)
} else {
  part-classic(it)
}

// Mini table of contents
#let minitoc = context if states.theme.get().contains("fancy") {
  minitoc-fancy
} else if states.theme.get().contains("modern") {
  minitoc-modern
} else if states.theme.get().contains("classic") {
  minitoc-classic
} else if states.theme.get().contains("orly") {
  minitoc-orly
} else {
  minitoc-classic
}

// Custom box
#let custom-box(title: none, icon: "info", color: rgb(29, 144, 208), body) = context if states.theme.get().contains("fancy") {
  custom-box-fancy(title: title, icon: icon, color: color, body)
} else if states.theme.get().contains("modern") {
  custom-box-modern(title: title, icon: icon, color: color, body)
} else if states.theme.get().contains("classic") {
  custom-box-classic(title: title, icon: icon, color: color, body)
} else if states.theme.get().contains("orly") {
  custom-box-orly(title: title, icon: icon, color: color, body)
} else {
  custom-box-classic(title: title, icon: icon, color: color, body)
}

// Information box
#let info-box = custom-box.with(title: context states.localization.get().note)

// Tip box
#let tip-box = custom-box.with(title: context states.localization.get().tip, icon: "tip", color: rgb(0, 166, 81))

// Warning box
#let warning-box = custom-box.with(title: context states.localization.get().warning, icon: "alert", color: orange)

// Important box
#let important-box = custom-box.with(title: "Important", icon: "stop", color: rgb("#f74242"))

// Proof box
#let proof-box = custom-box.with(title: context states.localization.get().proof, icon: "report", color: eastern)

// Question box
#let question-box = custom-box.with(title: "Question", icon: "question", color: purple)