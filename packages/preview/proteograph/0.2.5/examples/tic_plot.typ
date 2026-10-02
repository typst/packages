#import "@preview/proteograph:0.2.5": *

#let data_json = json("../examples/data/tic.json")

// #let xic0 = data_json.found_list_first_pass.first().xics.first().trace
// #xic0.insert("title", "isotope 0")
// #let xic1 = data_json.found_list_first_pass.first().xics.at(1).trace
// #xic1.insert("title", "isotope 1")

#let xic0 = data_json.at("tic")
#xic0.insert("title", "TIC")

#xic-plot(
  height: 10cm,
  title: "Total Ion Count",
  hist: (
    ("x": data_json.ms2_histogram.rt_bins, "y": data_json.ms2_histogram.ms2_count, "label": "MS2 scans"),
    (
      "x": data_json.ms2_histogram.rt_bins,
      "y": data_json.ms2_histogram.matched_ms2_count,
      "label": "Assigned MS2",
      "fill": yellow.transparentize(20%),
    ),
  ),
  xic0,
)
