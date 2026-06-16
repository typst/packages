#import  "/template.typ": fix-later-compact

#let metadata = toml("../metadata.toml")

#align(center)[
  #set text(font: "Onest")

  #v(4fr)

  = #metadata.title

  == #metadata.subtitle

  #v(10fr)

  = Dissertation

  #v(2fr)

  For the purpose of obtaining the degree of doctor \ 
  at Delft University of Technology \
by the authority of the Rector Magnificus, Prof.dr.ir. H. Bijl, \
  Chair of the Board for Doctorates \
  to be defended publicly on #fix-later-compact()[Add date in format: Monday 1 June 2030 at 10:00]   
  
  #v(1fr)

  by 

  #v(1fr)

  // must be in format "firstname FAMILYNAME"
  = #metadata.author.first() #upper(metadata.author.at(1))  \

  #v(6fr)

]

#pagebreak()