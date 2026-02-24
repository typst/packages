#import "@preview/proteograph:0.2.0": *

#let data_json = json("../examples/data/pepa1b35.json")

#let xic0 = data_json.found_list_first_pass.first().xics.first().trace
#xic0.insert("title","isotope 0")
#let xic1 = data_json.found_list_first_pass.first().xics.at(1).trace
#xic1.insert("title","isotope 1")
#xic1.insert("peak-begin",data_json.found_list_first_pass.first().xics.at(1).peak.rt.first())
#xic1.insert("peak-end",data_json.found_list_first_pass.first().xics.at(1).peak.rt.last())
#let xic2 = data_json.found_list_first_pass.first().xics.at(2).trace
#xic2.insert("title","isotope 2")
#xic2.insert("peak-begin",data_json.found_list_first_pass.first().xics.at(2).peak.rt.first())
#xic2.insert("peak-end",data_json.found_list_first_pass.first().xics.at(2).peak.rt.last())

#xic-plot(height: 10cm, title: "XIC E[MOD:00394]PSHWETISTGGLK z=2", rt-range: (3830, 3900), max-intensity: 10000, xic0,xic1, xic2)


