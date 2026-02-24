/// Creates a dictionary of all configuration parameters
///
/// - default-font-family (str): The default font family
/// - default-font-size (length): The absolute default font size
/// - italic-font-family (str): The italic font family (for value descriptions)
/// - italic-font-size (length): The absolute italic font size
/// - background (color): The diagram background color
/// - text-color (color): The default color used to display text
/// - link-color (color): The color used to display links and arrows
/// - bit-i-color (color): The color used to display bit indices
/// - border-color (color): The color used to display borders
/// - bit-width (float): The width of a bit
/// - bit-height (float): The height of a bit
/// - description-margin (float): The margin between descriptions
/// - dash-length (float): The length of individual dashes (for dashed lines)
/// - dash-space (float): The space between two dashes (for dashed lines)
/// - arrow-size (float): The size of arrow heads
/// - margins (tuple): TODO -> remove
/// - arrow-margin (float): The margin between arrows and the structures they link
/// - values-gap (float): The gap between individual values
/// - arrow-label-distance (float): The distance between arrows and their labels
/// - force-descs-on-side (bool): If true, descriptions are placed on the side of the structure, otherwise, they are placed as close as possible to the bit
/// - left-labels (bool): If true, descriptions are put on the left, otherwise, they default to the right hand side
/// - width (float): TODO -> remove
/// - height (float): TODO -> remove
/// - full-page (bool): If true, the page will be resized to fit the diagram and take the background color
/// - all-bit-i (bool): If true, all bit indices will be rendered, otherwise, only the ends of each range will be displayed
/// - ltr-bits (bool): If true, bits are placed with the LSB on the left instead of the right
/// -> dictionary
#let config(
  default-font-family: "Ubuntu Mono",
  default-font-size: 15pt,
  italic-font-family: "Ubuntu Mono",
  italic-font-size: 12pt,
  background: white,
  text-color: black,
  link-color: black,
  bit-i-color: black,
  border-color: black,
  bit-width: 30,
  bit-height: 30,
  description-margin: 10,
  dash-length: 6,
  dash-space: 4,
  arrow-size: 10,
  margins: (20, 20, 20, 20),
  arrow-margin: 4,
  values-gap: 5,
  arrow-label-distance: 5,
  force-descs-on-side: false,
  left-labels: false,
  width: 1200,
  height: 800,
  full-page: false,
  all-bit-i: true,
  ltr-bits: false
) = {}

/// Dark theme config
/// - ..args (any): see @@config()
#let dark(..args) = {}

/// Blueprint theme config
/// - ..args (any): see @@config()
#let blueprint(..args) = {}