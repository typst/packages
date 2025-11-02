#let crop = (img_bytes, start: (0.0%, 0.0%), resize: 100%) => context {
  assert(resize <= 100%)
  let img = image(img_bytes)
  // Get dimensions of the source image
  let dims = measure(img)
  layout(size => {
    let (left, top) = start

    let image_height_ratio = float(100% - top) * float(resize)
    let image_width_ratio = float(100% - left) * float(resize)

    let layout-aspect-ratio = size.height / size.width
    let image-aspect-ratio = (dims.height * image_height_ratio) / (dims.width * image_width_ratio)
    let image_layout_ratio = if layout-aspect-ratio >= image-aspect-ratio {
      dims.height * image_height_ratio / size.height
    } else {
      dims.width * image_width_ratio / size.width
    }

    let top_clip = top * dims.height / image_layout_ratio

    box(
      clip: true,
      inset: (
        top: -top * dims.height / image_layout_ratio,
        bottom: -(1 - image_height_ratio - float(top)) * dims.height / image_layout_ratio,
        left: -left * dims.width / image_layout_ratio,
        right: -(1 - image_width_ratio - float(left)) * dims.width / image_layout_ratio,
      ),
      image(img_bytes, height: dims.height / image_layout_ratio, width: dims.width / image_layout_ratio),
    )
  })
}

#let page_size_dict = (
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

#let get_size(size, flipped: bool) = {
  let s = if type(size) == str {
    page_size_dict.at(lower(size))
  } else {
    size
  }
  return if flipped { (s.at(1), s.at(0)) } else { s }
}
