// Load the nine-patch WASM plugin
#let nine_patch_plugin = plugin("./nine_patch.wasm")
 
  // Function to scale a nine-patch image
#let scale-9patch(image_data, target_width, target_height, scale: 1pt) = {

  let width_bytes = int(target_width/scale).to-bytes()
  let height_bytes = int(target_height/scale).to-bytes()

  let result = nine_patch_plugin.nine_patch(
    image_data,
    width_bytes,
    height_bytes
  )

  image(result,
    width: target_width,
    height: target_height)
}


#let context-9patch(img, scale: 1pt) = {
  let patch_bytes = nine_patch_plugin.nine_patch_content_info(img)

  // Each u32 is 4 bytes in little-endian format
  let bytes_to_u32(bytes, offset) = {
    let b0 = bytes.at(offset)
    let b1 = bytes.at(offset + 1) 
    let b2 = bytes.at(offset + 2)
    let b3 = bytes.at(offset + 3)
    b0 + b1 * 256 + b2 * 256 * 256 + b3 * 256 * 256 * 256
  }
  
  return (
    content_left: bytes_to_u32(patch_bytes, 0)*scale,
    content_top: bytes_to_u32(patch_bytes, 4)*scale, 
    content_right: bytes_to_u32(patch_bytes, 8)*scale,
    content_bottom: bytes_to_u32(patch_bytes, 12)*scale,
    min_width: bytes_to_u32(patch_bytes, 16)*scale,
    min_height: bytes_to_u32(patch_bytes, 20)*scale
  )
}


#let auto-9patch(img, scale: 1pt, content) = {

  let im_data = context-9patch(img, scale: scale)

  let content_box = box(
    inset: (
      left: im_data.content_left,
      top: im_data.content_top,
      right: im_data.content_right,
      bottom: im_data.content_bottom,
    ),
    content
  )

  let measurements = measure(content_box);

  let w
  let h
  if (measurements.width < im_data.min_width) {
    w = im_data.min_width
  } else {
    w = measurements.width
  }
  if (measurements.height < im_data.min_height) {
    h = im_data.min_height
  } else {
    h = measurements.height
  }

  [
    #place(scale-9patch(img, w, h,scale: scale))
    #content_box
  ]
}