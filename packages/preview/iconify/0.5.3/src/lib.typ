#let icons-store = state("iconify-icons-store", (:))
/// Provide icons for use with the `icon` function. Download them from https:
///
/// ```typ
/// provide-icons(json("assets/mdi.json"))
/// ```
///
/// - icon_jsons (dictionary): Dictionary of icons
/// -> none
#let provide-icons(..icon_jsons) = {
  icons-store.update(cache => {
    // If we provide a list if icon JSONs, add them all to the cache. Otherwise, add the single icon JSON to the cache.
    for icon_json in icon_jsons.pos() {
      assert(icon_json.at("prefix", default: none) != none, message: "Icon JSON missing 'prefix' field.")
      cache.insert(icon_json.at("prefix"), icon_json)
    }
    return cache
  })
}

/// Must be wrapped in context
///
/// - icon-name (str): "collection:icon" name, for example "mdi:home". Use [icones.js.org](https://icones.js.org) to find the icon name. The collection must have been provided using the `provide-icons` function.
/// -> str
#let icon-svg(icon-name) = {
  let parts = icon-name.split(":")
  assert(parts.len() == 2, message: "Invalid icon name format. Expected 'collection:name'.")

  let collection = parts.at(0, default: none)
  let name = parts.at(1, default: none)

  assert(collection != none and name != none, message: "Invalid icon name format. Expected 'collection:name'.")

  let json-data = icons-store.final().at(collection, default: none)

  assert(
    json-data != none,
    message: "Icon collection '"
      + collection
      + "' not found in cache. Make sure to provide the icon JSON using the 'provide-icons' function. Current collections are" + icons-store.final().keys().join(", ") + "."
  )

  let props = (
    left: 0,
    left-set: false,
    top: 0,
    top-set: false,
    // When width or height are not set, the default is 16, as per iconify's spec.
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
      props.left += icon-data.at("left")
      props.left-set = true
    }
    if icon-data.at("top", default: none) != none {
      props.top += icon-data.at("top")
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
      + icon-data.body.replace("currentColor", text.fill.to-hex())
      + "</svg>"
  )
}


/// Get an inline icon.
///
/// ```example
/// this is on the same line as this icon
/// #icon("mdi:home", y: -0.3em)
/// and this text is on the same line as well
/// ```
///
/// - icon-name (str): "collection:icon" name, for example "mdi:home". Use [icones.js.org](https://icones.js.org) to find the icon name. The collection must have been provided using the `provide-icons` function.
/// - y (length): Vertical offset to apply to the icon, relative to the text baseline. Positive values move the icon up, negative values move it down. Default is 0. In general, you will want to use a small negative value to align the icon better with the text, for example `-0.3em`.
/// - image-props (dictionary): Props passed to the image. Like width and height.
/// -> box(image)
#let icon(icon-name, y: 0em, ..image-props) = context {
  return box(image(bytes(icon-svg(icon-name)), format: "svg", ..image-props), inset: (y: y))
}
