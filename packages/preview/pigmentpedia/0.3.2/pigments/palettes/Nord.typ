
// Nord Theme by Sven Greb <development@svengreb.de>
// https://github.com/nordtheme/nord

// An arctic, north-bluish color palette.

// Created for the clean and minimal flat design
// pattern to achieve a optimal focus and
// readability for code syntax highlighting and UI.

// It consists of a total of sixteen, carefully
// selected, dimmed pastel colors for a
// eye-comfortable, but yet colorful ambiance.

/*
Base component color of "Polar Night".

Used for texts, backgrounds, carets and structuring characters like curly- and square brackets.
*/
#let nord0 = rgb("#2E3440") // Polar Night

/*
Lighter shade color of the base component color.

Used as a lighter background color for UI elements like status bars.
*/
#let nord1 = rgb("#3B4252") // Polar Night Light 1

/*
Lighter shade color of the base component color.

Used as line highlighting in the editor.
In the UI scope it may be used as selection- and highlight color.
*/
#let nord2 = rgb("#434C5E") // Polar Night Light 2

/*
Lighter shade color of the base component color.

Used for comments, invisibles, indent- and wrap guide marker.
In the UI scope used as pseudoclass color for disabled elements.
*/
#let nord3 = rgb("#4C566A") // Polar Night Light 3

/*
Base component color of "Snow Storm".

Main color for text, variables, constants and attributes.
In the UI scope used as semi-light background depending on the theme shading design.
*/
#let nord4 = rgb("#D8DEE9") // Snow Storm

/*
Lighter shade color of the base component color.

Used as a lighter background color for UI elements like status bars.
Used as semi-light background depending on the theme shading design.
*/
#let nord5 = rgb("#E5E9F0") // Snow Storm Light

/*
Lighter shade color of the base component color.

Used for punctuations, carets and structuring characters like curly- and square brackets.
In the UI scope used as background, selection- and highlight color depending on the theme shading design.
*/
#let nord6 = rgb("#ECEFF4") // Snow Storm White

/*
Bluish core color.

Used for classes, types and documentation tags.
*/
#let nord7 = rgb("#8FBCBB") // Frost 1

/*
Bluish core accent color.

Represents the accent color of the color palette.
Main color for primary UI elements and methods/functions.

Can be used for
  - Markup quotes
  - Markup link URLs
*/
#let nord8 = rgb("#88C0D0") // Frost Accent

/*
Bluish core color.

Used for language-specific syntactic/reserved support characters and keywords, operators, tags, units and
punctuations like (semi)colons,commas and braces.
*/
#let nord9 = rgb("#81A1C1") // Frost 2

/*
Bluish core color.

Used for markup doctypes, import/include/require statements, pre-processor statements and at-rules (`@`).
*/
#let nord10 = rgb("#5E81AC") // Frost 3

/*
Colorful component color.

Used for errors, git/diff deletion and linter marker.
*/
#let nord11 = rgb("#BF616A") // Aurora 1

/*
Colorful component color.

Used for annotations.
*/
#let nord12 = rgb("#D08770") // Aurora 2

/*
Colorful component color.

Used for escape characters, regular expressions and markup entities.
In the UI scope used for warnings and git/diff renamings.
*/
#let nord13 = rgb("#EBCB8B") // Aurora 3

/*
Colorful component color.

Main color for strings and attribute values.
In the UI scope used for git/diff additions and success visualizations.
*/
#let nord14 = rgb("#A3BE8C") // Aurora 4

/*
Colorful component color.

Used for numbers.
*/
#let nord15 = rgb("#B48EAD") // Aurora 5



#let nord = (
  output: (caps: "each", hyphen: false),
  "polar-night-1": nord0,
  "polar-night-2": nord1,
  "polar-night-3": nord2,
  "polar-night-4": nord3,
  "snow-storm": nord4,
  "snow-storm-light": nord5,
  "snow-storm-white": nord6,
  "frost-1": nord7,
  "frost-2": nord8,
  "frost-3": nord9,
  "frost-4": nord10,
  "aurora-red": nord11, // Aurora 1
  "aurora-orange": nord12, // Aurora 2
  "aurora-yellow": nord13, // Aurora 3
  "aurora-green": nord14, // Aurora 4
  "aurora-purple": nord15, // Aurora 5
)
