#import "iop-globals.typ": *

// Journal list
#let default-journal = (
  name: "Journal Title",
  abbreviation: "J. Title",
  address: "",
  font: default-font,
  numcol: 2,
  foot-info: [#sym.copyright #datetime.today().year() IOP Publishing Ltd.],
)

#let psst = (
  name: "Plasma Sources Science and Technology",
  abbreviation: "Plasma Sources Sci. Technol.",
  address: "",
  font: default-font,
  numcol: 2,
  foot-info: [#sym.copyright #datetime.today().year() IOP Publishing Ltd. All rights, including for text and data mining, AI traning, and similar technologies, reserved.],
)

#let ppcf = (
  name: "Plasma Physics and Controlled Fusion",
  abbreviation: "Plasma Phys. Control. Fusion",
  address: "",
  font: default-font,
  numcol: 2,
  foot-info: [#sym.copyright #datetime.today().year() The Author(s). Published by IOP Publishing Ltd],
)