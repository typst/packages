
// Colors used on the web
#import "../pigments/standards/CSS.typ": *

/*
  PANTONE® Colors; over 10,000 altogether

  Note:
  1\ The same color on one screen will vary
  from screen to screen.

  2\ Pantone® colors viewed on computer screens
  and printed to InkJet printers will not match
  actual colors precisely. In general, Pantone®
  inks tend to print slightly darker and flatter
  than they appear on computer monitors.

  Pantone®/PANTONE® is a registered trademark
  of Pantone, Inc.
*/
#import "../pigments/standards/Pantone/Pantone.typ": Pantone
#import "../pigments/standards/Pantone/PantoneC.typ": Pantone-C // Coated
#import "../pigments/standards/Pantone/PantoneCP.typ": Pantone-CP // Coated Process
#import "../pigments/standards/Pantone/PantoneU.typ": Pantone-U // Uncoated
#import "../pigments/standards/Pantone/PantoneUP.typ": Pantone-UP // Uncoated Process
#import "../pigments/standards/Pantone/PantoneXGC.typ": Pantone-XGC // Extended Gamut Coated
#import "../pigments/standards/Pantone/PantonePMS.typ": Pantone-PMS // Pantone Matching System

// RAL Colors
#import "../pigments/standards/RAL/RAL-Classic.typ": RAL, RAL-Classic
#import "../pigments/standards/RAL/RAL-Design.typ": RAL-Design
#import "../pigments/standards/RAL/RAL-Effect.typ": RAL-Effect

// DIC Digital Color Guide®
#import "../pigments/standards/DIC/DIC.typ": DIC

// HKS® Colors (Hostmann-Steinberg Druckfarben, Kast & Ehinger Druckfarben and H. Schmincke & Co.)
#import "../pigments/standards/HKS/HKS.typ": HKS
// below colors are included in HKS
// #import "../pigments/standards/HKS/HKSE.typ": HKS-E // Coated
// #import "../pigments/standards/HKS/HKSK.typ": HKS-K // Coated
// #import "../pigments/standards/HKS/HKSN.typ": HKS-N // Uncoated
// #import "../pigments/standards/HKS/HKSZ.typ": HKS-Z // Special

// ISCC–NBS System of Color Designation
#import "../pigments/standards/ISCC-NBS/ISCC-NBS.typ": ISCC-NBS

// Natural Colour System®
#import "../pigments/standards/NCS/NCS.typ": NCS

// Catppuccin community-driven pastel theme <https://github.com/catppuccin/catppuccin>
#import "../pigments/palettes/Catppuccin.typ": Catppuccin

// Chinese Traditional Colors <https://colors.ichuantong.cn>
#import "../pigments/eastern-traditional/Chinese/zhcn-trad.typ": Zhongguo

// Japanese Traditional Colors <https://nipponcolors.com>
#import "../pigments/eastern-traditional/Japanese/jajp-trad.typ": Nippon

// Nippon Paint
#import "../pigments/standards/NipponPaint.typ": NipponPaint

// Nord Theme by Sven Greb <https://github.com/nordtheme/nord>
#import "../pigments/palettes/Nord.typ": NordTheme

// Crayola® colors
#import "../pigments/misc/Crayola.typ": Crayola

// Shades of Colors
// undecided as to whether or not these should be included
// #import "../pigments/misc/ColorShades.typ": ShadesOf

#let pigmentpedia = (
  "CSS": CSS,
  "Pantone": Pantone,
  "Pantone-C": Pantone-C,
  "Pantone-CP": Pantone-CP,
  "Pantone-U": Pantone-U,
  "Pantone-UP": Pantone-UP,
  "Pantone-XGC": Pantone-XGC,
  "Pantone-PMS": Pantone-PMS,
  "DIC": DIC,
  "RAL": RAL,
  "RAL-Classic": RAL-Classic,
  "RAL-Design": RAL-Design,
  "RAL-Effect": RAL-Effect,
  "HKS": HKS,
  // "HKS-E": HKS-E,
  // "HKS-K": HKS-K,
  // "HKS-N": HKS-N,
  // "HKS-Z": HKS-Z,
  "ISCC-NBS": ISCC-NBS,
  "NCS": NCS,
  "Catppuccin": Catppuccin,
  "Zhongguo": Zhongguo,
  "Nippon": Nippon,
  "NipponPaint": NipponPaint,
  "NordTheme": NordTheme,
  "Crayola": Crayola,
  // "ShadesOf": ShadesOf,
)

// Standard color signs // not ready for release
// #let pmt = (
//   critical: NCS.S-1085-Y80R,
//   fail: NCS.S-1085-Y80R,
//   information: NCS.S-2065-R90B,
//   success: NCS.S-2570-G20Y,
//   warning: NCS.S-1080-Y10R,
// )

// Suitable for inline highlighting of coloring of content
#let pigment(color, content) = {
  set text(color)
  content
}
