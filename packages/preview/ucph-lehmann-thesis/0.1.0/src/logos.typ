// Official University of Copenhagen logos, extracted from the logo sheets by
// tools/extract-logos.py. The logo is the property of the University of
// Copenhagen; see README.md.

#let _dir = "../assets/logos/"

// Natural size of each SVG (pt), so proportions between files are known.
#let _sizes = (
  "seal": (45.859pt, 45.902pt),
  "seal-negative": (68.148pt, 68.184pt),
  "seal-line": (306.605pt, 306.609pt),
  "logo-en": (460.520pt, 85.438pt),
  "logo-da": (429.262pt, 85.438pt),
  "logo-right-en": (255.434pt, 83.043pt),
  "logo-right-da": (240.324pt, 83.043pt),
  "logo-stacked-en": (199.182pt, 148.109pt),
  "logo-stacked-da": (183.585pt, 143.276pt),
  "logo-stacked-negative-en": (252.098pt, 151.588pt),
  "logo-stacked-negative-da": (231.023pt, 152.025pt),
  "wordmark-en": (362.355pt, 12.211pt),
  "wordmark-da": (332.734pt, 13.203pt),
)

/// Names of all available logo variants.
#let variants = _sizes.keys()

/// Natural (width, height) of a variant.
#let natural-size(name) = _sizes.at(name)

/// Insert a logo variant. Extra arguments go to `image` (width, height, ...).
///
/// - name (str): one of `variants`, e.g. "seal", "logo-en", "wordmark-da".
#let logo(name, ..args) = {
  assert(name in _sizes, message: "unknown logo variant: " + name + ". Available: " + variants.join(", "))
  image(_dir + name + ".svg", ..args)
}

/// Dictionary of ready-made logo images (natural size), matching the API of
/// ucph-nielsine-touying's `logos`.
#let logos = (
  seal: logo("seal"),
  seal-negative: logo("seal-negative"),
  seal-line: logo("seal-line"),
  standard: logo("logo-en"),
  standard-dk: logo("logo-da"),
  stacked: logo("logo-stacked-en"),
  stacked-dk: logo("logo-stacked-da"),
  stacked-negative: logo("logo-stacked-negative-en"),
  stacked-negative-dk: logo("logo-stacked-negative-da"),
)
