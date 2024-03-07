#import "../templates/ifscyan.typ": *

#show: body => ifscyan-theme(aspect-ratio: "16-9", body)

#title-slide(title: "Slide Massa")[
  Gabriel Luiz Espindola Pedro\
  #text(.8em, link("gabrielluizep.glep@gmail.com"))

  #align(bottom)[
    20/09/2023
  ]
]

#slide(title: "Slide Massa")[
  #text([Título]) \ \

  // #uncover(2)[
  //   #text([Subtítulo])
  // ]
]