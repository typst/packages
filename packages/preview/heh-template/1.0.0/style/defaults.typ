#import "/style/images.typ": heh-images-defaults
#import "/style/text.typ": (
  heh-headings-defaults, heh-links-defaults, heh-raw-defaults,
)
#import "/style/tables.typ": heh-table-defaults

#let heh-style-defaults(
  doc,
) = {
  show: heh-headings-defaults
  show: heh-links-defaults
  show: heh-raw-defaults

  show: heh-table-defaults
  doc
}
