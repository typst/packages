#import "@preview/proteograph:0.2.0": *

#let complete_psm = json("../examples/data/complete_psm.json")
#ms2spectra-plot(title: "AIADGSLLDLLR", spectra: complete_psm.spectra, ion-series: complete_psm.ion-series)
