#import "../template/template.typ": *

#show: QRH.with(title: "Cup of Tea")

#index()

#section("Cup of Tea Preparation")[
  #condition[
    - Dehydration
    - Fatigue
    - Inability to Concentrate
  ]
  #objective[To replenish fluids.]
  #step("KETTLE", "Filled to 1 CUP")
  #tab(tab("Large mugs may require more water."))
  #step("Teabag", "In MUG")
  #step("KETTLE switch", "ON")
  #caution([HOT WATER #linebreak()Adult supervision required.])
  #step([*When* KETTLE boiled:], "")
  #subStep("MUG", "Fill")
  #step("Steep", "Allow to steep for a few minutes")
  #waitHere()
  #step("Remove teabag", "")

  #note("Stir after each step")

  #chooseOne[
    #option[Black tea *required:*]
    #tab(tab("No sugar here."))

    #endNow()
    #option[Tea with MILK *required:*]
    #tab(goToStep("9"))
  ]
  // #pagebreak()
  #step("Pour milk into MUG", "To desired colour")
  #step([*If* sugar required], "")
  #subStep([Sugar (one #linebreak() teaspoon at a time)], "Add to MUG")

]

#pagebreak()

#section("Another section")[


]