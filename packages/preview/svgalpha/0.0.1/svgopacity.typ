
/// This function takes the bytes of a SVG image and applies a global alpha value.
///
/// ```example
/// #import "@preview/svgalpha:0.0.1": transparent-svg
/// #let img = read("carrot.svg", encoding: "utf8")
/// #transparent-svg(img, 0.290, width: 40%)
/// ```
///
/// -> content
#let transparent-svg(img, alpha, ..image-args) = {
  assert(0.0 <= alpha and alpha <= 1.0, message: "Alpha value should be between 0 and 1.")

  let opacity-reg = "<svg[^>]*\b(opacity\s*=\s*[\"']?\d*\.?\d+[\"']?)"
  let img2
  if (img.contains(regex(opacity-reg))) {
    img2 = img.replace(regex("opacity\s*=\s*[\"']?\d*\.?\d+[\"']?"), { "opacity=\"" + str(alpha) + "\"" })
  } else { img2 = img.replace("<svg", "<svg opacity=\"" + str(alpha) + "\" ") }
  image(bytes(img2), ..image-args)
}


