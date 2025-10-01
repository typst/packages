// University of Melbourne Color Palette
// Based on Gen 3 Design System - https://designsystem.web.unimelb.edu.au/style-guide/colour-palette/
// Last updated: 11 September 2025

// Traditional Heritage (Blue) - Primary Brand Color
// Used for headings, links, and primary UI elements
#let traditional-heritage-100 = rgb("#000F46")  // Primary brand blue
#let traditional-heritage-75 = rgb("#404B74")   // Medium blue
#let traditional-heritage-50 = rgb("#8087A2")   // Light blue
#let traditional-heritage-25 = rgb("#BFC3D1")   // Very light blue

// Traditional Heritage Dark (Dark Blue)
#let traditional-heritage-dark-100 = rgb("#000B34")  // Dark navy

// Mt William Greenstone (Sage Green)
// Used for secondary elements and nature-inspired accents
#let mt-william-light-100 = rgb("#ABC1A7")     // Primary sage
#let mt-william-light-75 = rgb("#C0D0BD")      // Light sage
#let mt-william-light-50 = rgb("#D5E0D3")      // Very light sage
#let mt-william-light-25 = rgb("#EAEFE9")      // Pale sage
#let mt-william-dark-100 = rgb("#444A40")      // Dark sage
#let mt-william-dark-75 = rgb("#737770")       // Medium dark sage
#let mt-william-dark-50 = rgb("#A2A49F")       // Medium sage
#let mt-william-dark-25 = rgb("#D0D2CF")       // Light dark sage

// Magpie (Grey)
// Used for text, backgrounds, and neutral elements
#let magpie-light-100 = rgb("#C8C8C8")         // Medium grey
#let magpie-light-75 = rgb("#D6D6D6")          // Light grey
#let magpie-light-50 = rgb("#E4E4E4")          // Very light grey
#let magpie-light-25 = rgb("#F1F1F1")          // Off-white
#let magpie-dark-100 = rgb("#2D2D2D")          // Dark grey
#let magpie-dark-75 = rgb("#616161")           // Medium dark grey
#let magpie-dark-50 = rgb("#969696")           // Medium grey
#let magpie-dark-25 = rgb("#CACACA")           // Light grey

// Laughing Kookaburra (Blue)
// Used for accents and interactive elements
#let kookaburra-light-100 = rgb("#46C8F0")    // Bright blue
#let kookaburra-light-75 = rgb("#74D6F4")     // Light blue
#let kookaburra-light-50 = rgb("#A3E4F7")     // Very light blue
#let kookaburra-light-25 = rgb("#D1F1FB")     // Pale blue
#let kookaburra-dark-100 = rgb("#003C55")     // Dark teal
#let kookaburra-dark-75 = rgb("#406D80")       // Medium teal
#let kookaburra-dark-50 = rgb("#809DAA")       // Light teal
#let kookaburra-dark-25 = rgb("#BFCED5")       // Very light teal

// Possum (Pink/Purple)
// Used for accents and creative elements
#let possum-light-100 = rgb("#EB7BBE")         // Pink
#let possum-light-75 = rgb("#F09CCE")          // Light pink
#let possum-light-50 = rgb("#F5BDDF")          // Very light pink
#let possum-light-25 = rgb("#FADEEF")          // Pale pink
#let possum-dark-100 = rgb("#73234B")          // Maroon
#let possum-dark-75 = rgb("#965A78")           // Medium maroon
#let possum-dark-50 = rgb("#B991A5")           // Light maroon
#let possum-dark-25 = rgb("#DCC8D2")           // Very light maroon

// Black Sheoak (Red)
// Used for warnings, errors, and important notices
#let sheoak-light-100 = rgb("#FF2D3C")         // Bright red
#let sheoak-light-75 = rgb("#FF616D")          // Light red
#let sheoak-light-50 = rgb("#FF969D")          // Very light red
#let sheoak-light-25 = rgb("#FFCACE")          // Pale red
#let sheoak-dark-100 = rgb("#78000D")          // Dark red
#let sheoak-dark-75 = rgb("#9A4049")           // Medium dark red
#let sheoak-dark-50 = rgb("#BB8086")           // Medium red
#let sheoak-dark-25 = rgb("#DDBFC2")           // Light red

// Yam Daisy (Yellow/Orange)
// Used for highlights and attention-grabbing elements
#let yam-daisy-100 = rgb("#FFD629")            // Bright yellow
#let yam-daisy-75 = rgb("#FFE05E")             // Light yellow
#let yam-daisy-50 = rgb("#FFEA94")             // Very light yellow
#let yam-daisy-25 = rgb("#FFF5C9")             // Pale yellow
#let yam-brown-100 = rgb("#A84500")            // Brown
#let yam-brown-75 = rgb("#BE7440")             // Light brown
#let yam-brown-50 = rgb("#D4A280")             // Medium brown
#let yam-brown-25 = rgb("#E9D1BF")             // Very light brown

// River Red Gum (Green)
// Used for success states and environmental themes
#let red-gum-light-100 = rgb("#9FB825")         // Bright green
#let red-gum-light-75 = rgb("#B7CA5B")         // Light green
#let red-gum-light-50 = rgb("#CFDC92")          // Very light green
#let red-gum-light-25 = rgb("#E7EDC8")          // Pale green
#let red-gum-dark-100 = rgb("#2C421D")         // Dark green
#let red-gum-dark-75 = rgb("#617156")           // Medium dark green
#let red-gum-dark-50 = rgb("#95A08E")           // Medium green
#let red-gum-dark-25 = rgb("#CAD0C6")           // Light green

// System Colors
#let black = rgb("#000000")
#let white = rgb("#FFFFFF")
#let link = rgb("#083973")                      // Special link color

// Color aliases for easier use
#let colors = (
  primary: traditional-heritage-100,
  secondary: mt-william-light-100,
  accent: kookaburra-light-100,
  success: red-gum-light-100,
  warning: yam-daisy-100,
  error: sheoak-light-100,
  info: kookaburra-light-100,
  text: magpie-dark-100,
  text-light: magpie-light-100,
  background: white,
  background-light: magpie-light-25,
)
