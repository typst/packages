/*
  File: pigments.typ
  Author: neuralpain
  Date Modified: 2025-01-06

  Description: Centralized import of all pigments
  accessible within Pigmentpedia. All pigments
  from every group are imported here and then
  exported to the library.
*/

// Colors used on the web
#import "../pigments/standards/CSS.typ": *

// PANTONE® Colors • Pantone® and PANTONE® are registered trademarks of Pantone, Inc.
#import "../pigments/standards/Pantone.typ": Pantone

// RAL Colors
#import "../pigments/standards/RAL.typ": RAL, RAL-Classic

// DIC Digital Color Guide®
#import "../pigments/standards/DIC.typ": DIC

// HKS® Colors (Hostmann-Steinberg Druckfarben, Kast & Ehinger Druckfarben and H. Schmincke & Co.)
#import "../pigments/standards/HKS.typ": HKS

// ISCC–NBS System of Color Designation
#import "../pigments/standards/ISCC-NBS/ISCC-NBS.typ": ISCC-NBS

// Natural Colour System®
#import "../pigments/standards/NCS.typ": NCS

// Catppuccin community-driven pastel theme <https://github.com/catppuccin/catppuccin>
#import "../pigments/palettes/Catppuccin.typ": Catppuccin

// Chinese Traditional Colors <https://colors.ichuantong.cn>
#import "../pigments/misc/Chinese/zhcn-trad.typ": Zhongguo

// Japanese Traditional Colors <https://nipponcolors.com>
#import "../pigments/misc/Japanese/jajp-trad.typ": Nippon

// Nippon Paint
#import "../pigments/standards/NipponPaint.typ": Nippon-Paint

// Nord Theme by Sven Greb <https://github.com/nordtheme/nord>
#import "../pigments/palettes/Nord.typ": Nord

// Crayola® colors
#import "../pigments/misc/Crayola.typ": Crayola

// List of all pigments in `pigmentpedia`.
#let pigmentpedia = (
  "CSS": CSS,
  "Pantone": Pantone,
  "DIC": DIC,
  "RAL": RAL,
  "RAL-Classic": RAL-Classic,
  "HKS": HKS,
  "ISCC-NBS": ISCC-NBS,
  "NCS": NCS,
  "Catppuccin": Catppuccin,
  "Zhongguo": Zhongguo,
  "Nippon": Nippon,
  "Nippon-Paint": Nippon-Paint,
  "Nord": Nord,
  "Crayola": Crayola,
)

// For inline highlighting or coloring of content.
#let pigment(pigment, content) = {
  set text(pigment)
  content
}
