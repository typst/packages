// Periodic Table of Elements for Typst
// Using cetz drawing with element-box function
//
// TWO VERSIONS AVAILABLE:
// 1. periodic-table() - Compact version for slides/handouts
// 2. periodic-table-detailed() - Professional ACS-style version with full details

#import "@preview/cetz:0.4.2": canvas, draw

// Element data: (number, symbol, name, mass, category)
// Categories: alkali, alkaline, transition, post-transition, metalloid, nonmetal, halogen, noble, lanthanide, actinide
#let elements = (
  // Period 1
  (1, "H", "Hydrogen", "1.008", "nonmetal"),
  (2, "He", "Helium", "4.003", "noble"),
  // Period 2
  (3, "Li", "Lithium", "6.968", "alkali"),  // [6.938, 6.997]
  (4, "Be", "Beryllium", "9.012", "alkaline"),
  (5, "B", "Boron", "10.814", "metalloid"),  // [10.806, 10.821]
  (6, "C", "Carbon", "12.01", "nonmetal"),
  (7, "N", "Nitrogen", "14.01", "nonmetal"),
  (8, "O", "Oxygen", "16.00", "nonmetal"),
  (9, "F", "Fluorine", "18.998", "halogen"),
  (10, "Ne", "Neon", "20.18", "noble"),
  // Period 3
  (11, "Na", "Sodium", "22.99", "alkali"),
  (12, "Mg", "Magnesium", "24.31", "alkaline"),
  (13, "Al", "Aluminum", "26.98", "post-transition"),
  (14, "Si", "Silicon", "28.09", "metalloid"),
  (15, "P", "Phosphorus", "30.974", "nonmetal"),
  (16, "S", "Sulfur", "32.068", "nonmetal"),  // [32.059, 32.076]
  (17, "Cl", "Chlorine", "35.45", "halogen"),
  (18, "Ar", "Argon", "39.95", "noble"),
  // Period 4
  (19, "K", "Potassium", "39.10", "alkali"),
  (20, "Ca", "Calcium", "40.08", "alkaline"),
  (21, "Sc", "Scandium", "44.96", "transition"),
  (22, "Ti", "Titanium", "47.87", "transition"),
  (23, "V", "Vanadium", "50.94", "transition"),
  (24, "Cr", "Chromium", "52.00", "transition"),
  (25, "Mn", "Manganese", "54.94", "transition"),
  (26, "Fe", "Iron", "55.85", "transition"),
  (27, "Co", "Cobalt", "58.93", "transition"),
  (28, "Ni", "Nickel", "58.69", "transition"),
  (29, "Cu", "Copper", "63.55", "transition"),
  (30, "Zn", "Zinc", "65.38", "post-transition"),
  (31, "Ga", "Gallium", "69.72", "post-transition"),
  (32, "Ge", "Germanium", "72.63", "metalloid"),
  (33, "As", "Arsenic", "74.92", "metalloid"),
  (34, "Se", "Selenium", "78.97", "nonmetal"),
  (35, "Br", "Bromine", "79.90", "halogen"),
  (36, "Kr", "Krypton", "83.80", "noble"),
  // Period 5
  (37, "Rb", "Rubidium", "85.47", "alkali"),
  (38, "Sr", "Strontium", "87.62", "alkaline"),
  (39, "Y", "Yttrium", "88.91", "transition"),
  (40, "Zr", "Zirconium", "91.222", "transition"),  // 2024 revision
  (41, "Nb", "Niobium", "92.91", "transition"),
  (42, "Mo", "Molybdenum", "95.95", "transition"),
  (43, "Tc", "Technetium", "(98)", "transition"),
  (44, "Ru", "Ruthenium", "101.1", "transition"),
  (45, "Rh", "Rhodium", "102.9", "transition"),
  (46, "Pd", "Palladium", "106.4", "transition"),
  (47, "Ag", "Silver", "107.9", "transition"),
  (48, "Cd", "Cadmium", "112.41", "post-transition"),
  (49, "In", "Indium", "114.8", "post-transition"),
  (50, "Sn", "Tin", "118.7", "post-transition"),
  (51, "Sb", "Antimony", "121.8", "metalloid"),
  (52, "Te", "Tellurium", "127.6", "metalloid"),
  (53, "I", "Iodine", "126.9", "halogen"),
  (54, "Xe", "Xenon", "131.3", "noble"),
  // Period 6
  (55, "Cs", "Cesium", "132.9", "alkali"),
  (56, "Ba", "Barium", "137.3", "alkaline"),
  (57, "La", "Lanthanum", "138.9", "transition"),  // La is d-block, not f-block
  (58, "Ce", "Cerium", "140.1", "lanthanoid"),
  (59, "Pr", "Praseodymium", "140.9", "lanthanoid"),
  (60, "Nd", "Neodymium", "144.2", "lanthanoid"),
  (61, "Pm", "Promethium", "(145)", "lanthanoid"),
  (62, "Sm", "Samarium", "150.4", "lanthanoid"),
  (63, "Eu", "Europium", "152.0", "lanthanoid"),
  (64, "Gd", "Gadolinium", "157.25", "lanthanoid"),  // 2024 revision: 157.249(2)
  (65, "Tb", "Terbium", "158.9", "lanthanoid"),
  (66, "Dy", "Dysprosium", "162.5", "lanthanoid"),
  (67, "Ho", "Holmium", "164.9", "lanthanoid"),
  (68, "Er", "Erbium", "167.3", "lanthanoid"),
  (69, "Tm", "Thulium", "168.9", "lanthanoid"),
  (70, "Yb", "Ytterbium", "173.0", "lanthanoid"),
  (71, "Lu", "Lutetium", "174.97", "lanthanoid"),  // 2024 revision: 174.96669(5)
  (72, "Hf", "Hafnium", "178.5", "transition"),
  (73, "Ta", "Tantalum", "180.9", "transition"),
  (74, "W", "Tungsten", "183.8", "transition"),
  (75, "Re", "Rhenium", "186.2", "transition"),
  (76, "Os", "Osmium", "190.2", "transition"),
  (77, "Ir", "Iridium", "192.2", "transition"),
  (78, "Pt", "Platinum", "195.1", "transition"),
  (79, "Au", "Gold", "197.0", "transition"),
  (80, "Hg", "Mercury", "200.59", "post-transition"),
  (81, "Tl", "Thallium", "204.4", "post-transition"),
  (82, "Pb", "Lead", "207.0", "post-transition"),  // [206.14, 207.94] varies by source
  (83, "Bi", "Bismuth", "208.98", "post-transition"),
  (84, "Po", "Polonium", "(209)", "metalloid"),
  (85, "At", "Astatine", "(210)", "halogen"),
  (86, "Rn", "Radon", "(222)", "noble"),
  // Period 7
  (87, "Fr", "Francium", "(223)", "alkali"),
  (88, "Ra", "Radium", "(226)", "alkaline"),
  (89, "Ac", "Actinium", "(227)", "transition"),  // Ac is d-block, not f-block
  (90, "Th", "Thorium", "232.0", "actinoid"),
  (91, "Pa", "Protactinium", "231.0", "actinoid"),
  (92, "U", "Uranium", "238.0", "actinoid"),
  (93, "Np", "Neptunium", "(237)", "actinoid"),
  (94, "Pu", "Plutonium", "(244)", "actinoid"),
  (95, "Am", "Americium", "(243)", "actinoid"),
  (96, "Cm", "Curium", "(247)", "actinoid"),
  (97, "Bk", "Berkelium", "(247)", "actinoid"),
  (98, "Cf", "Californium", "(251)", "actinoid"),
  (99, "Es", "Einsteinium", "(252)", "actinoid"),
  (100, "Fm", "Fermium", "(257)", "actinoid"),
  (101, "Md", "Mendelevium", "(258)", "actinoid"),
  (102, "No", "Nobelium", "(259)", "actinoid"),
  (103, "Lr", "Lawrencium", "(266)", "actinoid"),
  (104, "Rf", "Rutherfordium", "(267)", "transition"),
  (105, "Db", "Dubnium", "(268)", "transition"),
  (106, "Sg", "Seaborgium", "(269)", "transition"),
  (107, "Bh", "Bohrium", "(270)", "transition"),
  (108, "Hs", "Hassium", "(277)", "transition"),
  (109, "Mt", "Meitnerium", "(278)", "transition"),
  (110, "Ds", "Darmstadtium", "(281)", "transition"),
  (111, "Rg", "Roentgenium", "(282)", "transition"),
  (112, "Cn", "Copernicium", "(285)", "transition"),
  (113, "Nh", "Nihonium", "(286)", "post-transition"),
  (114, "Fl", "Flerovium", "(289)", "post-transition"),
  (115, "Mc", "Moscovium", "(290)", "post-transition"),
  (116, "Lv", "Livermorium", "(293)", "post-transition"),
  (117, "Ts", "Tennessine", "(294)", "halogen"),
  (118, "Og", "Oganesson", "(294)", "noble"),
)

// Color themes for periodic table
#let themes = (
  // Bright theme - light colors with black text (good for printing)
  bright: (
    text-color: black,
    colors: (
      alkali: rgb("#ff6b6b"),
      alkaline: rgb("#ffa94d"),
      transition: rgb("#ffd43b"),
      post-transition: rgb("#69db7c"),
      metalloid: rgb("#38d9a9"),
      nonmetal: rgb("#4dabf7"),
      halogen: rgb("#9775fa"),
      noble: rgb("#da77f2"),
      lanthanoid: rgb("#ff99cc"),
      actinoid: rgb("#c9b3ff"),
    ),
  ),
  // Dark theme - dark colors with white text (professional look)
  dark: (
    text-color: white,
    colors: (
      alkali: rgb("#c92a2a"),
      alkaline: rgb("#d9480f"),
      transition: rgb("#e67700"),
      post-transition: rgb("#2f9e44"),
      metalloid: rgb("#0ca678"),
      nonmetal: rgb("#1971c2"),
      halogen: rgb("#6741d9"),
      noble: rgb("#ae3ec9"),
      lanthanoid: rgb("#d6336c"),
      actinoid: rgb("#7950f2"),
    ),
  ),
  // Pastel theme - soft muted colors
  pastel: (
    text-color: rgb("#333333"),
    colors: (
      alkali: rgb("#ffccd5"),
      alkaline: rgb("#ffe5d9"),
      transition: rgb("#fff3bf"),
      post-transition: rgb("#d8f5a2"),
      metalloid: rgb("#c3fae8"),
      nonmetal: rgb("#d0ebff"),
      halogen: rgb("#e5dbff"),
      noble: rgb("#fcc2d7"),
      lanthanoid: rgb("#ffdeeb"),
      actinoid: rgb("#eebefa"),
    ),
  ),
  // Grayscale bright theme - light grays with black text
  grayscale: (
    text-color: black,
    colors: (
      alkali: luma(85%),
      alkaline: luma(80%),
      transition: luma(75%),
      post-transition: luma(70%),
      metalloid: luma(65%),
      nonmetal: luma(90%),
      halogen: luma(60%),
      noble: luma(95%),
      lanthanoid: luma(55%),
      actinoid: luma(50%),
    ),
  ),
  // Grayscale dark theme - dark grays with white text
  grayscale-dark: (
    text-color: white,
    colors: (
      alkali: luma(25%),
      alkaline: luma(30%),
      transition: luma(35%),
      post-transition: luma(40%),
      metalloid: luma(45%),
      nonmetal: luma(20%),
      halogen: luma(50%),
      noble: luma(15%),
      lanthanoid: luma(55%),
      actinoid: luma(60%),
    ),
  ),
  // Neon theme - vibrant colors on dark background
  neon: (
    text-color: white,
    colors: (
      alkali: rgb("#ff0055"),
      alkaline: rgb("#ff6600"),
      transition: rgb("#ffcc00"),
      post-transition: rgb("#00ff66"),
      metalloid: rgb("#00ffcc"),
      nonmetal: rgb("#0099ff"),
      halogen: rgb("#9933ff"),
      noble: rgb("#ff00ff"),
      lanthanoid: rgb("#ff3399"),
      actinoid: rgb("#cc66ff"),
    ),
  ),
)

// Get color for a category from a theme
#let get-category-color(cat, theme-name) = {
  let theme = themes.at(theme-name, default: themes.bright)
  theme.colors.at(cat, default: white)
}

// Get text color from a theme
#let get-text-color(theme-name) = {
  let theme = themes.at(theme-name, default: themes.bright)
  theme.text-color
}

// Legacy functions for backward compatibility
#let category-color(cat) = get-category-color(cat, "dark")
#let category-color-light(cat) = get-category-color(cat, "bright")

// Position mapping for standard periodic table layout
#let element-position(z) = {
  // Returns (column, row) for element with atomic number z
  if z == 1 { (0, 0) }
  else if z == 2 { (17, 0) }
  else if z <= 4 { (z - 3, 1) }
  else if z <= 10 { (z + 7, 1) }
  else if z <= 12 { (z - 11, 2) }
  else if z <= 18 { (z - 1, 2) }
  else if z <= 36 { (z - 19, 3) }
  else if z <= 54 { (z - 37, 4) }
  else if z == 55 { (0, 5) }
  else if z == 56 { (1, 5) }
  else if z == 57 { (2, 5) }  // La in period 6, group 3
  else if z >= 58 and z <= 71 { (z - 56, 8) }  // Lanthanoids: Ce-Lu
  else if z >= 72 and z <= 86 { (z - 69, 5) }  // Period 6: Hf-Rn
  else if z == 87 { (0, 6) }
  else if z == 88 { (1, 6) }
  else if z == 89 { (2, 6) }  // Ac in period 7, group 3
  else if z >= 90 and z <= 103 { (z - 88, 9) }  // Actinoids: Th-Lr
  else if z >= 104 and z <= 118 { (z - 101, 6) }  // Period 7: Rf-Og
  else { (0, 0) }
}

// First row for each group column (0-indexed column -> first row with element)
#let group-first-row(col) = {
  if col == 0 { 0 }        // Group 1: H
  else if col == 1 { 1 }   // Group 2: Be
  else if col <= 11 { 3 }  // Groups 3-12: Sc-Zn
  else if col <= 16 { 1 }  // Groups 13-17: B-F row
  else { 0 }               // Group 18: He
}

// Element box function for periodic table (compact version)
#let pt-element(x, y, number, symbol, mass, fill-color: white, text-color: black, size: 1.0, gap: 0.1, highlighted: false, highlight-stroke: luma(20%) + 3pt) = {
  import draw: *
  let s = size
  group({
    translate((x * (size + gap), -y * (size + gap)))
    rect((0, 0), (s, s), fill: fill-color, stroke: black + 0.3pt)
    content((0.1 * s, 0.85 * s), text(5pt, fill: text-color)[#number], anchor: "west")
    content((0.5 * s, 0.5 * s), text(10pt, weight: "bold", fill: text-color)[#symbol])
    content((0.5 * s, 0.15 * s), text(5.5pt, fill: text-color)[#mass])
    // Draw highlight border on top
    if highlighted {
      rect((0, 0), (s, s), fill: none, stroke: highlight-stroke)
    }
  })
}

// Professional element box with all details (ACS style)
#let pt-element-detailed(x, y, number, symbol, name, mass, fill-color: white, text-color: white, size: 1.8, gap: 0.15, highlighted: false, highlight-stroke: luma(20%) + 3pt) = {
  import draw: *
  let s = size
  group({
    translate((x * (size + gap), -y * (size + gap)))
    rect((0, 0), (s, s), fill: fill-color, stroke: black + 0.5pt)
    // Atomic number (top left)
    content((0.12 * s, 0.88 * s), text(7pt, fill: text-color, weight: "bold")[#number], anchor: "west")
    // Symbol (center, large)
    content((0.5 * s, 0.55 * s), text(16pt, weight: "bold", fill: text-color)[#symbol])
    // Name (below symbol)
    content((0.5 * s, 0.32 * s), text(6pt, fill: text-color)[#name])
    // Atomic mass (bottom)
    content((0.5 * s, 0.12 * s), text(7pt, fill: text-color)[#mass])
    // Draw highlight border on top
    if highlighted {
      rect((0, 0), (s, s), fill: none, stroke: highlight-stroke)
    }
  })
}

/// Draw the complete periodic table (compact version)
///
/// - length (length): The base length unit for the canvas (default: 0.8cm)
/// - size (float): The size of each element box (default: 1.0)
/// - gap (float): The gap between element boxes (default: 0.1)
/// - theme (string): Color theme - "bright", "dark", "pastel", "grayscale", "neon" (default: "bright")
/// - show-title (bool): Whether to show the title (default: true)
/// - show-legend (bool): Whether to show the category legend (default: true)
/// - highlighted (array): Array of atomic numbers to highlight (default: ())
/// - highlight-stroke (stroke): Stroke style for highlighted elements (default: luma(20%) + 3pt)
/// -> content
#let periodic-table(
  length: 0.8cm,
  size: 1.0,
  gap: 0.1,
  theme: "bright",
  show-title: true,
  show-legend: true,
  highlighted: (),
  highlight-stroke: luma(20%) + 3pt,
) = canvas(length: length, {
  import draw: *

  let text-color = get-text-color(theme)

  // Draw all elements
  for elem in elements {
    let (z, sym, name, mass, cat) = elem
    let (col, row) = element-position(z)
    let color = get-category-color(cat, theme)
    let is-highlighted = z in highlighted
    pt-element(col, row, z, sym, mass, fill-color: color, text-color: text-color, size: size, gap: gap, highlighted: is-highlighted, highlight-stroke: highlight-stroke)
  }

  // Title
  if show-title {
    content((10, 2.5), text(14pt, weight: "bold")[Periodic Table of Elements])
  }

  // Legend at top with 2 columns
  if show-legend {
    let legend-y = 1.5
    let legend-items = (
      ("Alkali Metals", "alkali"),
      ("Alkaline Earth Metals", "alkaline"),
      ("Transition Metals", "transition"),
      ("Other Metals", "post-transition"),
      ("Metalloids", "metalloid"),
      ("Non-metals", "nonmetal"),
      ("Halogens", "halogen"),
      ("Noble Gases", "noble"),
      ("Lanthanoids", "lanthanoid"),
      ("Actinoids", "actinoid"),
    )
    for (i, (label, cat)) in legend-items.enumerate() {
      let lx = calc.rem(i, 2) * 5 + 3  // 2 columns
      let ly = legend-y - calc.floor(i / 2) * 0.6
      rect((lx, ly), (lx + 0.5, ly - 0.5), fill: get-category-color(cat, theme), stroke: black + 0.3pt)
      content((lx + 0.7, ly - 0.25), text(8pt)[#label], anchor: "west")
    }
  }
})

/// Draw the professional periodic table with detailed element boxes (ACS style)
///
/// - length (length): The base length unit for the canvas (default: 0.8cm)
/// - size (float): The size of each element box (default: 1.8)
/// - gap (float): The gap between element boxes (default: 0.15)
/// - theme (string): Color theme - "bright", "dark", "pastel", "grayscale", "neon" (default: "dark")
/// - show-title (bool): Whether to show the title (default: true)
/// - show-labels (bool): Whether to show group/period labels (default: true)
/// - show-legend (bool): Whether to show the category legend (default: true)
/// - highlighted (array): Array of atomic numbers to highlight (default: ())
/// - highlight-stroke (stroke): Stroke style for highlighted elements (default: luma(20%) + 3pt)
/// -> content
#let periodic-table-detailed(
  length: 0.8cm,
  size: 1.8,
  gap: 0.15,
  theme: "dark",
  show-title: true,
  show-labels: true,
  show-legend: true,
  highlighted: (),
  highlight-stroke: luma(20%) + 3pt,
) = canvas(length: length, {
  import draw: *

  let text-color = get-text-color(theme)

  // Draw all elements with detailed boxes
  for elem in elements {
    let (z, sym, name, mass, cat) = elem
    let (col, row) = element-position(z)
    let color = get-category-color(cat, theme)
    let is-highlighted = z in highlighted
    pt-element-detailed(col, row, z, sym, name, mass, fill-color: color, text-color: text-color, size: size, gap: gap, highlighted: is-highlighted, highlight-stroke: highlight-stroke)
  }

  // Title
  if show-title {
    content((9 * (size + gap), 2.5), text(14pt, weight: "bold")[Periodic Table of Elements])
  }

  // Group and period labels
  if show-labels {
    // Group numbers (1-18) positioned above first element in each column
    for g in range(1, 19) {
      let col = g - 1
      let first-row = group-first-row(col)
      let x = col * (size + gap)
      let y = -first-row * (size + gap) + size + 0.3
      content((x + size/2, y), text(9pt, weight: "bold")[#g])
    }

    // GROUP label
    content((0.8, size + 0.8), text(8pt, weight: "bold")[GROUP])

    // Period numbers (1-7) on left
    for p in range(1, 8) {
      let row = p - 1
      let y = -row * (size + gap)
      let x = -0.5
      content((x, y + size/2), text(9pt, weight: "bold")[#p])
    }

    // PERIOD label (vertical)
    content((-1.2, -3 * (size + gap) + size/2), angle: 90deg, text(8pt, weight: "bold")[PERIOD])
  }

  if show-legend {
    // Legend box (example element) - keep at right side
    let legend-x = 16
    let legend-y = 0.3
    let legend-size = size * 1.2
    let legend-color = get-category-color("transition", theme)
    rect((legend-x, legend-y), (legend-x + legend-size, legend-y - legend-size),
         fill: legend-color, stroke: black + 0.5pt)
    content((legend-x + 0.12 * legend-size, legend-y - 0.12 * legend-size),
            text(7pt, weight: "bold", fill: text-color)[78], anchor: "west")
    content((legend-x + legend-size/2, legend-y - 0.45 * legend-size),
            text(16pt, weight: "bold", fill: text-color)[Pt])
    content((legend-x + legend-size/2, legend-y - 0.68 * legend-size),
            text(6pt, fill: text-color)[Platinum])
    content((legend-x + legend-size/2, legend-y - 0.88 * legend-size),
            text(7pt, fill: text-color)[195.1])

    // Legend labels - moved to top right
    let label-x = legend-x + legend-size + 0.3
    content((label-x, legend-y - 0.12 * legend-size), text(7pt)[Atomic Number], anchor: "west")
    content((label-x, legend-y - 0.45 * legend-size), text(7pt)[Symbol], anchor: "west")
    content((label-x, legend-y - 0.68 * legend-size), text(7pt)[Name], anchor: "west")
    content((label-x, legend-y - 0.88 * legend-size), text(7pt)[Average Atomic Mass], anchor: "west")

    // Category legend - moved to top, alongside Pt box
    let cat-legend-y = 1.0
    let legend-items = (
      ("Alkali Metals", "alkali"),
      ("Alkaline Earth Metals", "alkaline"),
      ("Transition Metals", "transition"),
      ("Other Metals", "post-transition"),
      ("Metalloids", "metalloid"),
      ("Non-metals", "nonmetal"),
      ("Halogens", "halogen"),
      ("Noble Gases", "noble"),
      ("Lanthanoids", "lanthanoid"),
      ("Actinoids", "actinoid"),
    )
    // Category legend with 2 columns at top
    for (i, (label, cat)) in legend-items.enumerate() {
      let lx = calc.rem(i, 2) * 5.5 + 5  // 2 columns
      let ly = cat-legend-y - calc.floor(i / 2) * 0.7
      rect((lx, ly), (lx + 0.6, ly - 0.6), fill: get-category-color(cat, theme), stroke: black + 0.4pt)
      content((lx + 0.8, ly - 0.3), text(8pt)[#label], anchor: "west")
    }
  }
})
