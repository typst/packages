#import "@preview/proteograph:0.2.0": *

#let complete_psm = json("../examples/data/complete_psm.json")
#ms2spectra-plot(width: 15cm, height: 5cm, title: "AIADGSLLDLLR", spectra: complete_psm.spectra, ion-series: complete_psm.ion-series, mz-range: (450, 950), max-intensity: 30)


