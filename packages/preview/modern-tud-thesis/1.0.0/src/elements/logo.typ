#let logo(color, style: "horizontal", crop: false, alt: none, ..args) = {
  let folder = "/src/assets/TUD-Logo_svg_RGB/"

  if style not in ("horizontal", "short", "vertical", "icon") {
    panic("Unsupported style for logo: " + style)
  }

  if crop and "height" not in args.named() {
    panic("Height must be specified when crop is true")
  }

  if type(color) != str and style == "icon" {
    let svg = read(folder + "/Schwarz/TUD_Bildmarke_RGB_schwarz.svg")
    svg = svg.replace("id=\"Logo\"", "id=\"Logo\" fill=\"" + color.to-hex() + "\"")
    return image(bytes(svg), format: "svg", ..args)
  }

  if color == "blue" {
    folder += "Blau/"
    color = "blau"
  } else if color == "white" {
    folder += "Weiss/"
    color = "weiß"
  } else if color == "black" {
    folder += "Schwarz/"
    color = "schwarz"
  } else {
    panic("Unsupported color for logo: " + color)
  }

  context {
    let element

    if not text.lang in ("de", "en") {
      panic("Unsupported language for logo: " + text.lang)
    }

    // Ensure that alt text is set, if not provided by user
    // Text of website of TU Dresden
    if alt == none {
      if text.lang == "de" {
        let alt = "Logo: Technische Universität Dresden"
      } else if text.lang == "en" {
        let alt = "Logo: TUD Dresden University of Technology"
      }
    }

    if style == "icon" {
      element =image(folder +"/TUD_Bildmarke_RGB_" + color + ".svg", ..args)
    }
    else if style == "short" {
      element = image(folder +"/TUD_Logo_RGB_kurz_" + color + ".svg", ..args)
    }
    else{
      if style == "vertical" {
        element = image(folder +"/TUD_Logo_RGB_vertikal_" + color + "_" + text.lang + ".svg", ..args)
      }
      else {
        element = image(folder +"/TUD_Logo_RGB_horizontal_" + color + "_" + text.lang + ".svg", ..args)
      }
    }

    if crop {
      let h = args.named().height
      let x = h / 5
      box(
        clip: true,
        inset: (
          top: -x,
          left: -x
        ),
        element
      )
    } else {
      element
    }
  }
}