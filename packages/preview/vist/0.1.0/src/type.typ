#import "util.typ" : *



// separately judge whether a file is a image type(not strict)
#let img_type(img_bytes) = {
  let img_judge_dict = (
    jpeg : is_jpeg,
    png : is_png,
    gif : is_gif,
    webp : is_webp,
    bmp : is_bmp,
    tiff : is_tiff,
    ico : is_ico,
    cur : is_cur
  )
  for pair in img_judge_dict{
    let judge = pair.at(1)
    let img_slice = img_bytes.slice(0,20)
    if judge(img_slice){
      let img_type_name = pair.at(0)
      return img_type_name
    }
  }
  return "unknown"
}


