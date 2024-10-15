#import "@preview/quick-sip:0.1.0": *


#show: QRH.with(title: "Cup of Tea")


#section("Cup of Tea preparation")[
  #step("KETTLE", "Filled to 1 CUP")
  #step([*When* KETTLE boiled:], "")
  #step([*If* sugar required], "")
    //.. Rest of section goes here
]