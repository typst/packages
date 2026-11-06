#let orly(
    font: "",
    color: blue,
    top-text: "",
    pic: none,
    title: "",
    title-align: left,
    subtitle: "",
    publisher: "",
    publisher-font: ("Noto Sans", "Arial Rounded MT"),
    signature: "",
    margin: (top: 0in)
) = {
    page(
        margin: margin,
        [
            /**************
            * VARIABLES
            ***************/

            // Layout
            #let top-bar-height = 0.33em          // how tall to make the colored bar at the top of the page

            // Title block
            #let title-text-color = white
            #let title-text-leading = 0.5em
            #let title-block-height = 12em

            // Subtitle
            #let subtitle-margin = 0.5em         // space between title block and subtitle text
            #let subtitle-text-size = 1.4em

            // "Publisher" / signature
            #let publisher-text-size = 2em
            #let signature-text-size = 0.9em

            // *********************************************************

            #set text(font: font) if font != ""

            #grid(
                rows: (
                    top-bar-height,
                    1em,                    // top text
                    1fr,                    // pre-image spacing
                    auto,                   // image
                    1fr,                    // spacing between image and title block
                    title-block-height,
                    subtitle-margin,        // spacing between title and subtitle
                    subtitle-text-size,     // subtitle
                    1fr,                    // spacing between subtitle and "publisher"
                    publisher-text-size
                ),
                rect(width: 100%, height: 100%, fill: color),                   // color bar at top
                align(center + bottom)[#emph[#top-text]],                                // top text
                [],                                                             // pre-image spacing
                pic,                                                            // image
                [],                                                             // spacing between image and title block
                block(width: 100%, height: title-block-height, inset: (x: 2em), fill: color)[    // title block
                    #set text(fill: title-text-color, size: 3em)
                    #set par(leading: title-text-leading)
                    #set align(title-align + horizon)
                    #title
                ],
                [],                                                             // spacing between title block and subtitle
                align(right)[
                    #set text(size: subtitle-text-size)
                    #emph[#subtitle]
                ],
                [],
                [
                    #text(font: publisher-font, weight: "bold", size: publisher-text-size)[
                        #if publisher == "" {
                            [O RLY#text(fill: color)[#super[?]]]
                        } else {
                            publisher
                        }
                    ]
                    #if signature != "" {
                        box(width: 1fr, height: 100%)[
                            #set align(right + bottom)
                            #set text(size: signature-text-size)
                            #emph[#signature]
                        ]
                    }
                ]
            )
        ]
    )
}


