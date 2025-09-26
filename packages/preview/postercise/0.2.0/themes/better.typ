/*
betterposter originally developed by Mike Morrison
https://osf.io/ef53g/
*/

#import "../utils/scripts.typ": *


// Different behavior than for basic.typ
#let theme(   
  primary-color: rgb(28,55,103), // Dark blue
  background-color: white,
  accent-color: rgb(243,163,30), // Yellow
  titletext-color: black,
  titletext-size: 2em,
  body,
) = {
  set page(
    margin: 0pt,
  )

  color-primary.update(primary-color)
  color-background.update(background-color)
  color-accent.update(accent-color)
  color-titletext.update(color-titletext => titletext-color)
  size-titletext.update(size-titletext => titletext-size)
 
  body  
}


#let focus-box(
  footer-kwargs: none,
  body
) = {
  focus-content.update(focus-body => body)
}


#let normal-box(
  color: none, 
  body
) = {
    context[
      #let primary-color = color-primary.get()
      #let accent-color = color-accent.get()
      #if color != none [
        #let accent-color = color
        #box(
          stroke: none, //primary-color+0.2em, 
          width: 100%,
          fill: accent-color,
          inset: 0%,
          [
            #box(
              inset: (top: 4%, left: 4%, right: 4%, bottom: 4%),
              body
              )
          ]
        )
      ] else [
        // #let accent-color = color
        #box(
          stroke: none, //primary-color+0.0625em, 
          width: 100%,
          fill: accent-color,
          inset: 0%,
          [
            #box(
              inset: (top: 4%, left: 4%, right: 4%, bottom: 4%),
              body
              )
          ]
        )
      ]
  ]
}


#let poster-content(
  col: 1,
  
  title: none, 
  subtitle: none,
  authors: none,
  affiliation: none,
  
  left-logo: none,
  right-logo: none,

  textcolor: black,
  
  body
)={
    context[
      #let edge-color = color-background.get()
      #let center-color = color-primary.get()
      #let titletext-color = color-titletext.get()
      #let titletext-size = size-titletext.get()

      #let current-title = context title-content.get()
      #let current-subtitle = context subtitle-content.get()
      #let current-author = context author-content.get()
      #let current-affiliation = context affiliation-content.get()
      #let current-focus = context focus-content.get()
      #let current-footer = context footer-content.get()

      // Table captions go above
      #show figure.where(kind:table) : set figure.caption(position:top)
      #show figure.caption.where(kind:image): it => [
        // #context it.counter.display(it.numbering)
        // Since the #body is called twice (+1?), subtract half of the total figures to get the correct number
        Fig.
        #let last-counter = it.counter.final()
        #context {it.counter.get().at(0) - (last-counter.at(0)-1)/2}:
        #it.body
      ]
      #show figure.caption.where(kind:table): it => [
        Table
        #let last-counter = it.counter.final()
        #context {it.counter.get().at(0) - (last-counter.at(0)-1)/2}:
        #it.body
      ]

      // First, need body (hidden) to update header and footer
      #block(height: 0pt, hide[#body])
      #v(0pt, weak: true)
      
      
      #grid(
        columns: (12.5/52*100%, 28.5/52*100%, 11/52*100%),
        rows: (100%),
        
        // Left = title and main text
        [
          #grid(
             columns: (100%),
             rows: (auto, 1fr),
             [
               #box(
                stroke: none,
                fill: edge-color,
                // height: 100%,
                width: 100%,
                inset: 6%,
    
                [
                  #align(top+left)[
                  \
                  #set text(size: titletext-size/(7/5), 
                  fill: titletext-color,
                  )
                  *#current-title* 
                  #current-subtitle  \
                  // i.e. (6/7 = 0.857), which converts 1.4 -> 1.2, or (5/7 = 714) 1.4 -> 1.0
                  #set text(size: 0.714em)
                  \ 
                  #current-author \
                  #current-affiliation
                  ]
  
                ]
              )  
                #v(0pt, weak: true)    
              ],
              [
                #align(top+left)[
                #box(   
                inset: 6%,
                fill: edge-color,
                columns(col)[
                  #body
                  ]
                )
              ]
              ]
          )
        ],
        
        // Center = focus box
        [
          #box(
            height: 100%, 
            width: 100%,
            inset: 10%,
            fill: center-color,
            align(left+horizon)[
              #set text(size: 2em, 
                        fill: white)
              #current-focus
            ]
          )
        ],
        
        // Right = declarations and affiliation
        [
          #box(
            stroke: none,
            fill: edge-color,
            height: 100%,
            width: 100%,
            inset: 6%,

            align(bottom+left)[#current-footer]
          )  
        ]
      )
      
    ]
}

