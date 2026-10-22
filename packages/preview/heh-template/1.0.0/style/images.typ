#import "/utils/states.typ": heh-config

#let heh-images-defaults(doc) = context {
  let config = heh-config.get()
  show image: it => {
    if (
      config.print.monochromeimages
        and config.print.monochrome
        and type(it.source) == path
    ) {
      import "@preview/grayness:0.8.0": plg
      let source = read(it.source, encoding: none)

      let is-svg = source.slice(0, 1).at(0) == str.to-unicode("<")

      let graybytes = if is-svg {
        plg.svg-grayscale(source)
      } else {
        plg.grayscale(source)
      }

      image(
        graybytes,
        alt: it.alt,
        width: it.width,
        height: it.height,
        page: it.page,
        fit: it.fit,
        scaling: it.scaling,
        icc: it.icc,
      )
    } else {
      it
    }
  }

  doc
}
