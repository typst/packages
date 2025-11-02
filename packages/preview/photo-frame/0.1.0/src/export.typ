#import "until.typ": crop
#import "themes/base.typ": *


#let render(size, flipped: false, img: image, theme: str, ext_info: (:)) = {
  import "until.typ": get_size
  let size = get_size(size, flipped: flipped)
  if theme == "theme1" {
    import "themes/theme.typ": theme1
    theme1(size: size, img: img, ext_info: ext_info)
  } else if theme == "theme2" {
    import "themes/theme.typ": theme2
    theme2(size: size, img: img, ext_info: ext_info)
  } else {
    panic("Theme [" + theme + "] is not existed")
  }
}

