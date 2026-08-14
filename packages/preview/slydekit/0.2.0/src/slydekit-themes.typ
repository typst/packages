#import "slydekit-defaults.typ": *
#import "themes/metropolis.typ": *
#import "themes/fancy.typ": *
#import "themes/simple.typ": *
#import "themes/cambfurt.typ": *
#import "themes/chalkboard.typ": *

// Title slide
#let title-slide = context sk-states.theme.get().title

// Table of contents
#let tableofcontents = context sk-states.theme.get().toc

// Focus slide
#let focus-slide(body) = context (sk-states.theme.get().focus-slide)(body)

// Link box
#let link-box(..args) = context (sk-states.theme.get().link-box)(..args)

// Box equation
#let boxeq(body) = context (sk-states.theme.get().boxeq)(body)

// Custom box
#let custom-box(title: none, icon: "info", color: rgb(29, 144, 208), body) = context (sk-states.theme.get().custom-box)(title: title, icon: icon, color: color, body)

// Information box
#let info-box = custom-box.with(title: context sk-states.localization.get().note)

// Tip box
#let tip-box = custom-box.with(title: context sk-states.localization.get().tip, icon: "tip", color: rgb(0, 166, 81))

// Warning box
#let warning-box = custom-box.with(title: context sk-states.localization.get().warning, icon: "alert", color: orange)

// Important box
#let important-box = custom-box.with(title: "Important", icon: "stop", color: rgb("#f74242"))

// Proof box
#let proof-box = custom-box.with(title: context sk-states.localization.get().proof, icon: "report", color: eastern)

// Question box
#let question-box = custom-box.with(title: "Question", icon: "question", color: purple)

// Code box
#let code-box = custom-box.with(title: "Code", icon: "code", color: rgb(152, 101, 202))