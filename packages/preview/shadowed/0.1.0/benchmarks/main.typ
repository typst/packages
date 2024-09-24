#import "../lib.typ": shadowed

#set par(justify: true)
 
#for i in range(100) [
  #page[
    #for j in range(6) [
      #let color = rgb(i, j, 127)

      #shadowed(inset: 12pt, radius: 4pt, color: color)[
        #lorem(50)
      ]
    ]
  ]
]
