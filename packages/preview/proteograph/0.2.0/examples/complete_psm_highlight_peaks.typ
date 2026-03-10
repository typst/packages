#import "@preview/proteograph:0.2.0": *


#let delta_arr = (
(
    "ion": "y",
    "mz": (401.287,516.313),
    "level": 1,
    "label": "D"
),
(
    "ion": "y",
    "mz": (742.481,829.511),
    "level": 1,
    "label": "S"
),
(
    "ion": "y",
    "mz": (829.511,886.535),
    "level": 1,
    "label": "G"
),
(
    "ion": "y",
    "mz": (886.535,1001.56),
    "level": 1,
    "label": "D"
),
(
    "ion": "y",
    "mz": (742.481,1001.56),
    "level": 2,
    "label": "DGS"
)
)

#let complete_psm = json("../examples/data/complete_psm.json")
#ms2spectra-plot(width: 15cm, height: 7cm, max-intensity: 45, title: "AIADGSLLDLLR", spectra: complete_psm.spectra, ion-series: complete_psm.ion-series, delta: delta_arr)


