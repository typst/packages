#import "../templates/ifsclean.typ": *

#show: body => ifsclean-theme(aspect-ratio: "16-9", body)

#title-slide(title: "Polylux", subtitle: "A simple presentation tool")

#slide()[
  #text([Título]) \ \
  #uncover(2)[
    #text([Subtítulo])
  ]
]

#new-section-slide(name: "Seção 1")

#slide()[
  #text([Título]) \ \
  #uncover(2)[
    #text([Subtítulo])
  ]
]