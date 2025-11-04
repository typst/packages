#import "until.typ": crop
#import "themes/base.typ": *

#let render(size, flipped: false, img: image, theme: str, ext-info: (:)) = {
  import "until.typ": get-size
  let size = get-size(size, flipped: flipped)
  if theme == "theme1" {
    import "themes/theme.typ": theme1
    theme1(size: size, img: img, ext-info: ext-info)
  } else if theme == "theme2" {
    import "themes/theme.typ": theme2
    theme2(size: size, img: img, ext-info: ext-info)
  } else if theme == "theme3" {
    import "themes/theme.typ": theme3
    theme3(size: size, img: img, ext-info: ext-info)
  } else {
    panic("Theme [" + theme + "] is not existed")
  }
}

