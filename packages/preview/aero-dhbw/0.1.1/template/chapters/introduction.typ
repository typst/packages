// use these imports for all your files:
#import "@preview/glossy:0.9.0"

// pa-figure lets you define two different titles for your figures.
// The "long" name is for the page its displayed on and
// the "short" name is for the List of Tables/Figures
// This is how you use it:
//
// #pa-figure(
//    s<your-image-or-table>,
//    caption: (
//      short: [This is displayed in the List of Figures/Tables],
//      long: [This is the description under the figure/table]
//    ), 
// )
// 
// If you need other functions of the #figure function, you can add
// them here as well. They will be piped to the backend figure function.
#import "@preview/aero-dhbw:0.1.1": pa-figure

= introduction

#pa-figure(
  table([Hi],[Hello]),
  caption: (
    short: [This is in the List of Tables!],
    long: [This is under the table!]
  )
)
