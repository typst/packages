#import "@preview/admon-blk:0.1.0": *

// For development purpose
//#import "lib.typ": *

= Predefined block

#note-blk()[Simple information message for reader]

#note-blk(title: "Information")[Another information with a user-defined title]

#tip-blk()[Tricks, cheats and other tips]

#question-blk()[Question or quiz]

#important-blk()[Important note and information]

#warm-blk()[Warning, alert and notification demanding user attention]

#caution-blk()[Alert, caution or negative consequences]

= Custom block

#admon-blk(color: black, icon-fa: "bell", icon-fa-solid: true)[With font awesome solid icon]

#admon-blk(color: red, icon-fa: "bell", icon-fa-solid: false)[With font awesome regular icon]

#admon-blk(color: green, icon-svg:"example_icon.svg")[With SVG icon]

#admon-blk(color: blue, icon: "👍")[With direct icon]

#admon-blk(color: purple)[Without icon]
