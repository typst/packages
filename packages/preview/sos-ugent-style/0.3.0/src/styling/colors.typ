/* Source: https://styleguide.ugent.be/basic-principles/colours.html
 * Checked on 15/04/2024
 *
 * Usage:
 * `#import "colors.typ" as ug-clr: ugent-blue`
 * and then: `#ug-clr.lw` and `#ugent-blue`
 * Don't rename the module internally and use `#colors.lw`
 */
// Base colors
// tints in steps of 10% are allowed in certain situations
#let ugent-blue   = rgb(30, 100, 200)
#let ugent-yellow = rgb(255,210,0)
#let ugent-white  = rgb(255,255,255)
#let ugent-black  = rgb(0,0,0)

// Extracted from template posters on 27/09/2025
#let ugent-poster-grey = rgb("#e5e5e5")
#let background-color-to-foreground-map = (
  // None => (title: ugent-blue, body: ugent-black)
  ugent-blue: ugent-white,
  ugent-yellow: none,
  bw: ugent-white,
  di: ugent-white,
  ea: ugent-white,
  eb: ugent-white,
  fw: ugent-white,
  ge: ugent-white,
  lw: none,
  pp: ugent-white,
  ps: ugent-white,
  re: ugent-white,
  we: ugent-white,
)

/* from Dherse/masterproef
#let caribbean-current = rgb(30, 100, 101)
#let proper-purple = rgb("#6f006f")
#let federal-blue = rgb(31, 28, 92)
#let earth-yellow = rgb(224, 164, 88)
#let atomic-tangerine = rgb(222, 143, 110)
#let ugent-accent1 = rgb(139, 190, 232)
#let ugent-accent2 = rgb(137, 137, 137)
*/

// Convenience function to select color based on supplied faculty:
// `#let faculty = "ea"`
// `dictionary(ug-clr).at(faculty)`

// Faculty specific colors
// Faculty of Arts and Philosophy
#let lw = rgb(241,164,43)
// Faculty of Law and Criminology
#let re = rgb(220,78,40)
// Faculty of Sciences
#let we = rgb(45,140,168)
// Faculty of Medicine and Health Sciences
#let ge = rgb(232,94,113)
// Faculty of Engineering and Architecture
#let ea = rgb(139,190,232)
// Faculty of Economics and Business Administration
#let eb = rgb(174,176,80)
// Faculty of Veterinary Medicine
#let di = rgb(130,84,145)
// Faculty of Psychology and Educational Sciences
#let pp = rgb(251,126,58)
// Faculty of Bioscience Engineering
#let bw = rgb(39,171,173)
// Faculty of Pharmaceutical Sciences
#let fw = rgb(190,81,144)
// Faculty of Political and Social Sciences
#let ps = rgb(113,168,96)
