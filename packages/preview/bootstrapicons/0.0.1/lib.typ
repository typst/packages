
/// Function to create a Boostrap icon
/// 
/// - file (str): The file to load
/// - height (height unit): the target height
/// - color (typst color): the target color
#let bsicon(file, height: 0.66em, color: "black", baseline: 0%,..args) = {
  let svg_content = read("icons/" + file + ".svg")

  let color_hex = if type(color) == str {
    color
  } else {
    color.to-hex()
  }

  let svg_modified = svg_content.replace("currentColor", color_hex)
  
  box(image(bytes(svg_modified), height: height), baseline: baseline, ..args)
}
