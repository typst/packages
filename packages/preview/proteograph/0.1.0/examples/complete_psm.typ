#import "@local/proteograph:0.0.1": *

#let complete_psm = json("../examples/data/complete_psm.json")
#ms2spectra-plot(title: "Whatever", spectra: complete_psm.spectra, ion-series: complete_psm.ion-series)
