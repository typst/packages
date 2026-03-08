#let crop = (img-bytes, start: (0.0%, 0.0%), resize: 100%) => context {
  assert(resize <= 100%)
  let img = image(img-bytes)
  // Get dimensions of the source image
  let dims = measure(img)
  layout(size => {
    let (left, top) = start

    let image-height-ratio = float(100% - top) * float(resize)
    let image-width-ratio = float(100% - left) * float(resize)

    let layout-aspect-ratio = size.height / size.width
    let image-aspect-ratio = (dims.height * image-height-ratio) / (dims.width * image-width-ratio)
    let image-layout-ratio = if layout-aspect-ratio >= image-aspect-ratio {
      dims.height * image-height-ratio / size.height
    } else {
      dims.width * image-width-ratio / size.width
    }

    let top-clip = top * dims.height / image-layout-ratio

    box(
      clip: true,
      inset: (
        top: -top * dims.height / image-layout-ratio,
        bottom: -(1 - image-height-ratio - float(top)) * dims.height / image-layout-ratio,
        left: -left * dims.width / image-layout-ratio,
        right: -(1 - image-width-ratio - float(left)) * dims.width / image-layout-ratio,
      ),
      image(img-bytes, height: dims.height / image-layout-ratio, width: dims.width / image-layout-ratio),
    )
  })
}

#let page-size-dict = (
  "a0": (841mm, 1189mm),
  "a1": (594mm, 841mm),
  "a2": (420mm, 594mm),
  "a3": (297mm, 420mm),
  "a4": (210mm, 297mm),
  "a5": (148mm, 210mm),
  "a6": (105mm, 148mm),
  "a7": (74mm, 105mm),
  "a8": (52mm, 74mm),
  "a9": (37mm, 52mm),
  "a10": (26mm, 37mm),
  "a11": (18mm, 26mm),
)

#let get-size(size, flipped: bool) = {
  let s = if type(size) == str {
    page-size-dict.at(lower(size))
  } else {
    size
  }
  return if flipped { (s.at(1), s.at(0)) } else { s }
}
