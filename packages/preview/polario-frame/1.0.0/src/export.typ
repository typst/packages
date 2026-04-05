#import "until.typ": crop
#import "themes/basic/base.typ": *

#let render(size, flipped: false, img: image, theme: str, ext-info: (:)) = {
  import "until.typ": get-size
  let size = get-size(size, flipped: flipped)
  let rendering = eval("import \"themes/" + theme + ".typ\": *; rendering")
  rendering(size: size, img: img, ext-info: ext-info)
}

