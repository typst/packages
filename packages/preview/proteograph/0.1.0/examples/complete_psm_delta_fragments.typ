#import "@local/proteograph:0.1.0": *

#let complete_psm = json("../examples/data/complete_psm.json")
#ms2spectra-plot(width: 15cm, height: 10cm, spectra: complete_psm.spectra, ion-series: complete_psm.ion-series, delta-fragments: true)

