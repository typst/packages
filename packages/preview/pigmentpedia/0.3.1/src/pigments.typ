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
#import "../pigments/standards/Pantone.typ": pantone

// RAL Colors
#import "../pigments/standards/RAL.typ": ral, ral-classic

// DIC Digital Color Guide®
#import "../pigments/standards/DIC.typ": dic

// HKS® Colors (Hostmann-Steinberg Druckfarben, Kast & Ehinger Druckfarben and H. Schmincke & Co.)
#import "../pigments/standards/HKS.typ": hks

// ISCC–NBS System of Color Designation
#import "../pigments/standards/ISCC-NBS/ISCC-NBS.typ": iscc-nbs

// Natural Colour System®
#import "../pigments/standards/NCS.typ": ncs

// Catppuccin community-driven pastel theme <https://github.com/catppuccin/catppuccin>
#import "../pigments/palettes/Catppuccin.typ": catppuccin

// Chinese Traditional Colors <https://colors.ichuantong.cn>
#import "../pigments/misc/Chinese/zhcn-trad.typ": zhongguo

// Japanese Traditional Colors <https://nipponcolors.com>
#import "../pigments/misc/Japanese/jajp-trad.typ": nippon

// Nippon Paint
#import "../pigments/standards/NipponPaint.typ": nippon-paint

// Nord Theme by Sven Greb <https://github.com/nordtheme/nord>
#import "../pigments/palettes/Nord.typ": nord

// Crayola® colors
#import "../pigments/misc/Crayola.typ": crayola

// List of all pigments in `pigmentpedia`.
#let pigmentpedia = (
  output: (caps: "each", hyphen: true),
  "css": css,
  "pantone": pantone,
  "dic": dic,
  "ral": ral,
  "ral-classic": ral-classic,
  "hks": hks,
  "iscc-nbs": iscc-nbs,
  "ncs": ncs,
  "catppuccin": catppuccin,
  "zhongguo": zhongguo,
  "nippon": nippon,
  "nippon-paint": nippon-paint,
  "nord": nord,
  "crayola": crayola,
)

// For inline highlighting or coloring of content.
#let pigment(pigment, content) = {
  set text(pigment)
  content
}
