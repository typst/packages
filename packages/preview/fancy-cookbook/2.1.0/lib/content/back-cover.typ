#import "../colors/colors.typ": *
#import "../assets/fonts.typ": *

// Back cover image
#let back-cover-image = image.with(width: 60%)

#let back-cover(title, book-author, back-cover-content,back-cover-image,palette) = {
  pagebreak(to:"even", weak:true)
    page(margin: 5cm, header: none, footer: none)[

      #set par(spacing: 3em)
      
      #place(center + horizon)[

        // Title
        #text(font: fonts.header, weight: "bold", fill: palette.dark, size: 2em, title)

        // Back cover image
        #if back-cover-image != none {
          back-cover-image
        }
        // separation line
        #if back-cover-content != none and back-cover-image != none {
           line(length: 5cm, stroke: 0.5pt + palette.dark)
        }
        // back cover content
        #if back-cover-content != none {  
          text(font: fonts.header, size: 1em, tracking: 2pt, back-cover-content)
        }
        // author
        #par(
            text(font: fonts.header, style: "italic", fill: palette.dark, size: 1.2em, book-author)
          )
      ]
    ]
}