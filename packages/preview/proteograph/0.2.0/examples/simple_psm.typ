#import "@preview/proteograph:0.2.0": *

#let complete_psm = json("../examples/data/complete_psm.json")
#ms2spectra-plot(height: 5cm, title: "AIADGSLLDLLR", spectra: complete_psm.spectra)

