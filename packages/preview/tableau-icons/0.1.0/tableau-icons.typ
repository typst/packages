#import "@preview/based:0.2.0": base64

// preload the icon lists
#let _json-filled = json("icons/tabler-filled.json")
#let _json-outlined = json("icons/tabler-outline.json")


/* -------------------------------------------------------------------------- */
/*                              General Functions                             */
/* -------------------------------------------------------------------------- */

/// The base function used for the other functions to draw icons from Tabler.io
///
/// - body (str): icon name
/// - fill (color): color of the icon
/// - icon-type (str): style type of the icon (either "filled" or "outline")
/// - width (length): width of the icon (icon is contained)
/// - height (length): height of the icon (icon is contained)
/// ->
#let render-icon(body, fill: rgb("#000000"), icon-type: "outline", width: 1em, height: auto) = {
  if (type(body) != str) {
    panic("'icon' not set")
  }
  if ((icon-type != "filled") and (icon-type != "outline")) {
    panic("'icon' not set to either 'outline' or 'filled'")
  }

  let result-svg = ""
  if icon-type == "outline" {
    result-svg = _json-outlined.at(body)
  } else {
    result-svg = _json-filled.at(body)
  }

  image.decode(
    str(base64.decode(result-svg)).replace("currentColor", color.to-hex(fill)),
    width: width,
    height: height,
    fit: "contain",
    alt: body,
    format: "svg",
  )
}


/* -------------------------------------------------------------------------- */
/*                              Special Functions                             */
/* -------------------------------------------------------------------------- */

/// Renders the filled version of the given icon
///
/// - body (str): icon name
/// - fill (color): color of the icon
/// - width (length): width of the icon (icon is contained)
/// - height (length): height of the icon (icon is contained)
/// -> the desired icon with the parameters applied
#let filled(body, fill: rgb("#000000"), width: 1em, height: auto) = {
  render-icon(body, fill: fill, icon-type: "filled", width: width, height: height)
}

/// Renders the outlined version of the given icon
///
/// - body (str): icon name
/// - fill (color): color of the icon
/// - width (length): width of the icon (icon is contained)
/// - height (length): height of the icon (icon is contained)
/// -> the desired icon with the parameters applied
#let outlined(body, fill: rgb("#000000"), width: 1em, height: auto) = {
  render-icon(body, fill: fill, icon-type: "outline", width: width, height: height)
}

/// Renders the filled version of the given icon as an inline object
///
/// - body (str): icon name
/// - baseline (relative): the baseline position of the icon
/// - fill (color): color of the icon
/// - width (length): width of the icon (icon is contained)
/// - height (length): height of the icon (icon is contained)
/// -> the desired icon with the parameters applied
#let inline-filled(body, baseline: 15%, fill: rgb("#000000"), width: 1em, height: auto) = {
  box(
    baseline: baseline,
    render-icon(body, fill: fill, icon-type: "filled", width: width, height: height),
  )
}


/// Renders the contained version of the given icon as an inline object
///
/// - body (str): icon name
/// - baseline (relative): the baseline position of the icon
/// - fill (color): color of the icon
/// - width (length): width of the icon (icon is contained)
/// - height (length): height of the icon (icon is contained)
/// -> the desired icon with the parameters applied
#let inline-outlined(body, baseline: 15%, fill: rgb("#000000"), width: 1em, height: auto) = {
  box(
    baseline: baseline,
    render-icon(body, fill: fill, icon-type: "outline", width: width, height: height),
  )
}

