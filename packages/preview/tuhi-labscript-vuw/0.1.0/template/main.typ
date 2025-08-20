#import "@preview/tuhi-labscript-vuw:0.1.0": tuhi-labscript-vuw, lightgreen, middlegreen

#let ornament = align(center + horizon,text(font:"Noto Color Emoji", size: 18pt)[🧉])

#show: tuhi-labscript-vuw.with(
  experiment: text[cup of tea\ preparation],
  script: "pre-lab script",
  illustration: align(center)[#image("figures/tea.jpg", width: 100%)],
  coursetitle: "preparation of tea", coursecode: "teas101")

== overview

 In this experiment, you’ll be preparing a cup of tea.
#lorem(50)

#pagebreak()

= preamble

#lorem(30)

== Experimental skills and concepts

- Handling of a gaiwan
- Mastering brewing times
- Water-to-leaf ratio optimisation
- Weighing leaves
- Rinsing leaves

== Maths and Physics

- Temperature
- Diffusion equation
- Catalysis
- Fluid dynamics
- Heat transfer -- conduction, convection, radiation

== Health and safety considerations

#lorem(30)

- Tetsubin handling
- Boiling Water
- Stove, hot plate
- Pu'er knife
- Mycotoxyns
- Addiction

#ornament

#pagebreak()

// subsequent pages have numbered sections
#set heading(numbering: "1.")

= Exploration phase 

#lorem(100)

== first infusion

- teaware heated up with 70º water
- 4.5g leaves
- 100mL water
- 70º 
- 75s


== second infusion

- 70º water
- 20s

== third and subsequent infusions

- 70º
- 50s

== final infusion

- 90º
- 1 minute

#pagebreak()

// subsequent pages have numbered sections
#set heading(numbering: none)

= Appendix: basic theory

#lorem(50)

$ frac(partial c, partial t) = upright(bold(nabla)) dot.op (D upright(bold(nabla)) c - upright(bold(v)) c) + R $

#lorem(30)

$ rho frac(upright(D) upright(bold(u)), upright(D) t) = - nabla p + nabla dot.op bold(tau) + rho thin upright(bold(f)) $

#lorem(10)

#ornament
