// A leaf that becomes a hub, and compass placement.
#import "@preview/sprig:0.1.0": *
#set page(width: 19cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 9.5pt)

#mindmap([*Grammaire*], leaf-width: 3.4,
  branch(title: [Le nom], children: (
    branch[commun], branch[propre], branch[composé],
  ))[Il désigne un être ou une chose.],
  branch(title: [Le verbe], children: (
    branch[action], branch[état],
  ))[Il exprime une action.],
  branch(title: [L'adjectif], at: "south")[Il qualifie le nom.],
  branch(title: [L'adverbe], children-at: "east", children: (
    branch[temps], branch[lieu], branch[manière],
  ))[Il modifie le verbe.],
)
