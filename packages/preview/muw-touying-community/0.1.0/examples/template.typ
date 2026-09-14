#import "@preview/touying:0.6.1": *
#import "@preview/muw-touying-community:0.1.0": *


#set text(lang: "en")

#show: muw-slides.with(
  config-common(slide-level: 2),
  config-info(
    title: [Title slide with a blue/white background],
    author: [Univ. Prof. Dr. Peter Strasser],
    institution: [Universitätsklinik für XY],
    organization: [Medizinische Universität Wien],
  ),
  page-numbering-start: 3,
  image: it => {align(center, it)}
)

// ///////////////////////////////////////////////


#title-slide-dunkelblau()


#title-slide-white()


== Slide „Titel und Inhalt“ (Title and Content)
- Enter text here
- You can place a chart, picture, ...
  #text(size: 16pt)[
  - Up to 5 text levels
    #text(size: 15pt)[
    - Indents increase level by level, font size decreases
      #text(size: 14pt)[
      - Should the text be too long for your slide, the font size is reduced automatically
        #text(size: 13pt)[
        - Note: Please try not to write too much copy onto your slides 
        ]
      ]
    ]
  ]


= Section Header
Version – white background
// Alternatively, use the folowing for a section header page with white background
// #focus-slide-white[Section Header][Version – white background]


#focus-slide-green[Section Header][Version – green background]


#focus-slide-coral[Section Header][Version – coral background]


#imaging-slide(
  title: [Slide „Titel und Inhalt – schwarz" (Title and content – black)],
  // subtitle: [Enter subtitle here],
  picture: image("example_brain_mri.png"),
  picture-width: 123pt, 
)[
  - Especially for images in radiology
  - Enter explanation text – e.g. what can be seen in the picture
    #text(size: 16pt)[
    - Placeholder can be moved / enlarged / ... as required
    ]
]


== Slide „Titel, Subtitel und Inhalt“ (Title, subtitle and content)
=== Enter subtitle here
- Enter text, charts, pictures, … here


== Slide „Bild mit Bildunterschrift“ (Picture and Caption)
#image("example_wide_picture.jpg",
       width: 92%)
       
#text(size: 12pt)[Default text colour black; can be changed to blue. Highlights: please use *bold* characters.]


== Slide „Zwei Inhalte“ (Two content)
#grid(
  columns: (auto, auto),
  column-gutter: 3em,
[- Left column for content \
  - Can contain text, charts, pictures, … 
],

[- Right column for content \
  - Can contain text, charts, pictures, … 
]
)


== Slide „Vergleich“ (Comparison)
#grid(
  columns: (auto, auto),
  column-gutter: 3em,
[
#text(size: 20pt, font: "georgia", fill: muw_colors.colors.hellblau)[Headline for left column] \ 
- Left column for content 
  - Can contain text, charts, pictures, … 
],

[
#text(size: 20pt, font: "georgia", fill: muw_colors.colors.hellblau)[Headline for left column] \
- Right column for content 
  - Can contain text, charts, pictures, … 
]
)


// Quick start for slide with an infobox
== Slide „Titel, Inhalt und Infobox“ (Title, content and infobox)
#grid(
  columns: (auto, auto),
  column-gutter: 4em,
[
#text(size: 17pt)[
- Main content of the slide
  #text(size: 16pt)[
  - Formatting as in other slide layouts    
    #text(size: 15pt)[
    - Up to 5 text levels
      #text(size: 14pt)[
      - Can contain text, picture, charts, …
      ]
      ]
    ]
  ]
],

[
#muw-box(
  height: 81%,
  inset: 1em,
  [
    #set text(fill: muw_colors.colors.black, size: 14pt, weight: "regular")
    #set align(left + top)
    - Infobox content 
      - Font size smaller than in other slide layouts (14pt or smaller)
        - Up to 5 text levels 
          - Can contain text, picture, charts, …
    
  ]
)
]
)


// Alternatively, wrap the column contents in a block for versatility
== Slide „Titel, Inhalt und Infobox" (Title, content and infobox)
#grid(
  columns: (7fr, 7fr),
  column-gutter: 4em,
  [
    #block[
      #set par(justify: true, leading: 1.3em, spacing: 1em)
      #text(size: 17pt)[
        - Main content of the slide
          #text(size: 16pt)[
          - Formatting as in other slide layouts    
            #text(size: 15pt)[
            - Up to 5 text levels
              #text(size: 14pt)[
              - Can contain text, picture, charts, …
              ]
            ]
          ]
        ]
    ]
  ],
  [
    #block(inset: (-1em))[
      #set par(justify: false, leading: 1.3em, spacing: 1em)
      #muw-box(
        height: 81%,
        inset: 1em,
        fill: muw_colors.colors.hellblau-3,
        [
          #set text(fill: muw_colors.colors.black, size: 14pt, weight: "regular")
          #set align(left + top)
          - Infobox content 
            - Font size smaller than in other slide layouts (14pt or smaller)
              - Up to 5 text levels 
                - Can contain text, picture, charts, …
        ]
      )
    ]
  ]
)


// Crop a picture with the infobox-shaped mask
== Slide „Titel, Inhalt und Infobox" (Title, content and infobox)
#grid(
  columns: (7fr, 8fr),
  column-gutter: 4em,
  [
    #block[
      #set par(justify: false, leading: 1.3em, spacing: 1em)
      #text(size: 17pt)[
        - Version with a cropped picture  
          #text(size: 16pt)[
          - Formatting as in other slide layouts    
            #text(size: 15pt)[
            - Up to 5 text levels
              #text(size: 14pt)[
              - Can contain text, picture, charts, …
              ]
            ]
          ]
        ]
    ]
  ],
  [
    #block(inset: (-0.5em))[
      #muw-box(        
        inset: 0em,
        image("example_infobox_picture.jpg"),
      )
    ]
  ]
)

