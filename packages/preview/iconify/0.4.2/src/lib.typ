#let collections = json("node_modules/@iconify/json/collections.json")


/// Get an icon's SVG
///
/// For most case, you should use the `icon` function instead, which gives directly an inline image.
///
/// ```example
/// = Icon inline with text #box(image(icon-svg("mdi:home", color: red), format: "svg"))
///
/// = Equivalent to #icon("mdi:home", color: red)
///
/// If you want an icon not inline:
///
/// #image(icon-svg("mdi:home", color: red), format: "svg")
///
/// Which is equivalent to:
///
/// #block-icon("mdi:home", color: red)
/// ```
///
/// - icon-name (str): The iconify name. Use [icones.js.org](https://icones.js.org) to find it.
/// - color (color): Color to use as the `currentColor` value.
/// -> String (SVG data)
#let icon-svg(icon-name, color: black) = {
  let parts = icon-name.split(":")
  assert(parts.len() == 2, message: "Invalid icon name format. Expected 'collection:name'.")


  let collection = parts.at(0, default: none)
  let name = parts.at(1, default: none)

  assert(collection != none and name != none, message: "Invalid icon name format. Expected 'collection:name'.")

  assert(collections.at(collection, default: none) != none, message: "Icon collection '" + collection + "' not found.")

  let json-path = "node_modules/@iconify/json/json/" + collection + ".json"
  let json-data = json(json-path)

  // get the default width and height from the JSON data, or use 16 if not specified
  let width = json-data.at("width", default: 16)
  let height = json-data.at("height", default: 16)

  assert(json-data != none, message: "Failed to load JSON data for collection '" + collection + "'.")

  let props = (
    left: 0,
    left-set: false,
    top: 0,
    top-set: false,
    width: json-data.at("width", default: 16),
    width-set: false,
    height: json-data.at("height", default: 16),
    height-set: false,
    rotate: 0,
    hflip: false,
    vflip: false,
  )

  let icon-data = json-data.icons.at(name, default: none)
  if icon-data == none {
    icon-data = json-data.aliases.at(name, default: none)
    assert(icon-data != none, message: "Icon '" + name + "' not found in collection '" + collection + "'.")
  }
  while true {
    // update props based on alias
    if icon-data.at("left", default: none) != none {
      props.left += icon-data.at("left", default: 0)
      props.left-set = true
    }
    if icon-data.at("top", default: none) != none {
      props.top += icon-data.at("top", default: 0)
      props.top-set = true
    }
    if icon-data.at("width", default: none) != none {
      props.width = icon-data.at("width", default: props.width)
      props.width-set = true
    }
    if icon-data.at("height", default: none) != none {
      props.height = icon-data.at("height", default: props.height)
      props.height-set = true
    }
    props.rotate = calc.rem(props.rotate + icon-data.at("rotate", default: 0), 360)
    props.hflip = (props.hflip != icon-data.at("hflip", default: false))
    props.vflip = (props.vflip != icon-data.at("vflip", default: false))

    let parent = icon-data.at("parent", default: none)
    if parent == none {
      break
    }

    icon-data = json-data.icons.at(parent, default: none)
    if icon-data == none {
      icon-data = json-data.aliases.at(name, default: none)
      assert(icon-data != none, message: "Icon '" + name + "' not found in collection '" + collection + "'.")
    }
  }

  let transform = ""
  if props.rotate != 0 {
    transform += " rotate(" + str(props.rotate) + " 8 8)"
  }
  if props.hflip and props.vflip {
    transform += " scale(-1, -1)"
  } else if props.hflip {
    transform += " scale(-1, 1)"
  } else if props.vflip {
    transform += " scale(1, -1)"
  }
  if transform != "" {
    transform = " transform=\"" + transform.trim() + "\" transform-origin=\"center\""
  }



  return (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewbox=\""
      + str(props.left)
      + " "
      + str(props.top)
      + " "
      + str(props.height)
      + " "
      + str(props.width)
      + "\" width=\""
      + str(props.width)
      + "\" height=\""
      + str(props.height)
      + "\" "
      + transform
      + ">"
      + icon-data.body.replace("currentColor", color.to-hex())
      + "</svg>"
  )
}


/// Get an icon which breaks text.
///
/// ```example
/// this is on a first line
/// #block-icon("mdi:home", color: red)
/// this is on a second line
/// ```
///
/// - icon-name (str): The iconify name. Use [icones.js.org](https://icones.js.org) to find it.
/// - color (color): Color to use as the `currentColor` value.
/// - image-props (dictionary): Props passed to the image.
/// -> image
#let block-icon(icon-name, color: black, ..image-props) = {
  return image(bytes(icon-svg(icon-name, color: color)), format: "svg", ..image-props)
}
}

/// Get an inline icon.
///
/// ```example
/// this is on the same line as this icon
/// #icon("mdi:home", color: red)
/// and this text is on the same line as well
/// ```
///
/// - icon-name (str): The iconify name. Use [icones.js.org](https://icones.js.org) to find it.
/// - color (color): Color to use as the `currentColor` value.
/// - y (length): Vertical offset to apply to the icon, relative to the text baseline. Positive values move the icon up, negative values move it down. Default is 0. In general, you will want to use a small negative value to align the icon better with the text, for example `-0.2em`.
/// - image-props (dictionary): Props passed to the image.
/// -> box(image)
#let icon(icon-name, color: black, y: 0pt, ..image-props) = {
  return box(block-icon(icon-name, color: color, ..image-props), inset: (y: y))
}
