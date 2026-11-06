#import "../utils/scripts.typ": *


#let focus-box(
  color: none, 
  body
) = {
    locate(loc =>     
    {
      let primary-color = color-primary.get()
      show heading: it => [
                            #block(width: 100%, height: 1em,
                              // stroke: primary-color,
                              align(center+bottom)[
                                #it.body
                                #v(-1.2em)
                                #line(length: 100%, stroke: 0.0625em)]  
                              )
                          ]
      
      if color != none [
        #let focus-color = color
        #box(
          width: 100%,
          stroke: black+0.0625em, 
          fill: color,
          inset: 0%,
          [
            #box(
              inset: (top: 4%, left: 4%, right: 4%, bottom: 4%),
              body
              )
          ]
        )
      ] else [
        #let focus-color = color-accent.get() 
        #box(
          width: 100%,
          stroke: black+0.0625em, 
          fill: focus-color,
          inset: 0%,
          [
            #box(
              inset: (top: 4%, left: 4%, right: 4%, bottom: 4%),
              body
              )
          ]
        )
      ]
  })
}


#let normal-box(
  color: none, 
  body
) = {
    locate(loc =>     
    {
      let primary-color = color-primary.get()
      // show heading: set text(fill: primary-color)
      show heading: it => [
                            #block(width: 100%, height: 1em,
                              // stroke: primary-color,
                              align(center+bottom)[
                                #it.body
                                #v(-1.2em)
                                #line(length: 100%, stroke: 0.0625em)]  
                              )
                          ]

      
      if color != none [
        #let focus-color = color
        #box(
          width: 100%,
          stroke: black+0.0625em, 
          fill: focus-color,
          inset: 0%,
          [
            #box(
              inset: (top: 4%, left: 4%, right: 4%, bottom: 4%),
              body
              )
          ]
        )
      ] else [
        #let focus-color = color
        #box(
          width: 100%,
          stroke: none,//primary-color+0.2em, 
          fill: color,
          inset: 0%,
          [
            #box(
              inset: (top: 0%, left: 4%, right: 4%, bottom: 4%),
              body
              )
          ]
        )
      ]
  })
}


#let poster-content(
  col: 3, 
  body
)={
    locate(loc =>     
    {
      let primary-color = color-primary.get()
      let bg-color = color-background.get()
      let titletext-color = color-titletext.get()
      let titletext-size = size-titletext.get()

      let current-title = context title-content.get()
      let current-subtitle = context subtitle-content.get()
      let current-author = context author-content.get()
      let current-affiliation = context affiliation-content.get()
      let current-logo-1 = context logo-1-content.get()
      let current-logo-2 = context logo-2-content.get()
      let current-footer = context footer-content.get()

      // Table captions go above
      // TO DO: Numbering is not working properly
      show figure.where(kind:table) : set figure.caption(position:top)
      show figure.caption: it => [
        // #context it.counter.display(it.numbering)
        #it.body
      ]
      
      // Need to call body (hidden) to update header and footer
      block(height: 0pt, hide[#body])
      v(0pt, weak: true)
      
      grid(
        columns: 1,
        rows: (16%, 80%, 4%),
        
        // Top = title row
        [
          #box(
            stroke: none,
            fill: primary-color,
            height: 100%,
            width: 100%,
            inset: 4%,

            grid(
              columns: (10%, 80%, 10%),
              rows: 100%,
              stroke: none,
                    
              // Left
              [
                #place(horizon+left)[#current-logo-2]                
              ],
              // Center
              [
                #place(horizon+center)[
                    #set text(size: titletext-size,
                    fill: titletext-color,
                    )
                    *#current-title* #current-subtitle \
                    #set text(size: 0.5em)
                    #current-author \
                    #current-affiliation
                  ]  
              ],
              [
                #place(horizon+right)[#current-logo-1]
              ]
            )
          )
        ],
        
        // Middle = body
        [
          #box(
            height: 100%,    
            inset: 4%,
            fill: bg-color,
            
            columns(col)[#body]
          )
        ],
        
        // Bottom = footer
        [
          #box(
            stroke: none,
            fill: primary-color,
            height: 100%,
            width: 100%,
            inset: 4%,

            align(horizon+center)[#current-footer]
          )
        ]
      )
      
    })
}
