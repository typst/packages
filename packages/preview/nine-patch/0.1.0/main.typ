// Load the nine-patch WASM plugin
#let nine-patch-plugin = plugin("./nine-patch.wasm")
 
  // Function to scale a nine-patch image
#let scale-9patch(image-data, target-width, target-height, scale: 1pt) = {

  let width-bytes = int(target-width/scale).to-bytes()
  let height-bytes = int(target-height/scale).to-bytes()

  let result = nine-patch-plugin.nine_patch(
    image-data,
    width-bytes,
    height-bytes
  )

  image(result,
    width: target-width,
    height: target-height)
}


#let context-9patch(img, scale: 1pt) = {
  let patch-bytes = nine-patch-plugin.nine_patch_content_info(img)

  // Each u32 is 4 bytes in little-endian format
  let bytes-to-u32(bytes, offset) = {
    let b0 = bytes.at(offset)
    let b1 = bytes.at(offset + 1) 
    let b2 = bytes.at(offset + 2)
    let b3 = bytes.at(offset + 3)
    b0 + b1 * 256 + b2 * 256 * 256 + b3 * 256 * 256 * 256
  }
  
  return (
    content-left: bytes-to-u32(patch-bytes, 0)*scale,
    content-top: bytes-to-u32(patch-bytes, 4)*scale, 
    content-right: bytes-to-u32(patch-bytes, 8)*scale,
    content-bottom: bytes-to-u32(patch-bytes, 12)*scale,
    min-width: bytes-to-u32(patch-bytes, 16)*scale,
    min-height: bytes-to-u32(patch-bytes, 20)*scale
  )
}


#let auto-9patch(img, scale: 1pt, content) = {

  let im-data = context-9patch(img, scale: scale)

  let content-box = box(
    inset: (
      left: im-data.content-left,
      top: im-data.content-top,
      right: im-data.content-right,
      bottom: im-data.content-bottom,
    ),
    content
  )

  let measurements = measure(content-box);

  let w
  let h
  if (measurements.width < im-data.min-width) {
    w = im-data.min_width
  } else {
    w = measurements.width
  }
  if (measurements.height < im-data.min-height) {
    h = im-data.min_height
  } else {
    h = measurements.height
  }

  [
    #place(scale-9patch(img, w, h,scale: scale))
    #content-box
  ]
}