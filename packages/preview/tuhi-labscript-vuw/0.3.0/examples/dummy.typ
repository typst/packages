// #import "@local/tuhi-labscript-vuw:0.3.0": labscript-setup, script
#import "@preview/tuhi-labscript-vuw:0.3.0": labscript-setup, script

// override default settings
#let my-palette = (highlight: (base: rgb("#a10a49")))
#let (labscript, fonts, palette, layout) = labscript-setup(palette: my-palette)


#show: labscript.with(
  experiment: text[magnets\ & more physics stuff],
  script: smallcaps[#text(font: "Fira Sans")[pre-lab script]], 
  illustration: align(center)[#image("figures/dummy.jpg", width: 100%)],
  date: datetime(year: 2025,month: 7, day: 3),
  teaching-period: "T1",
  coursetitle: "experiments on murphy's laws", coursecode: "murf101")


== overview

 In this electrifying experiment, you’ll become a master of magnetic forces, navigating the unseen landscapes of magnetic holography and taming rogue dipoles. Imagine yourself at the helm, driving innovation with cutting-edge magnetic manipulation and unlocking the secrets of N-dimensional quantisation.

Prepare for a thrilling journey through the realm of quantum nonlinear topological relativistic magnetodynamics, where creativity meets chaos and opportunity abounds. You’ll turn invisible forces into tangible assets, making the unseen seen and capitalising on the quirky world of magnetism. Imagine the possibilities: magnetic levitation slippers for effortless (magnetic fields do no work!) gliding, or monopolar force fields to keep the dark side at bay.

#pagebreak()

= preamble

== Experimental skills and concepts

- Control and use of magnetic vorticies for experimental chaos management
- Playing ping-pong using quantum entangled magnetic paddles
- Polar Magnet Whispering to subtly influence the behavior of polar magnets with vocal cues
- Magneto-Acoustic Surfing for advanced data transmission
- Invisible Flux Painting of detailed magnetic field maps that double as invisible art pieces
- Schrodinger’s Magnet Sorting: sorting magnets with simultaneously north and south poles
- Ferrofluid choreography for graceful movements of ferrofluids \

== Maths and Physics

- Magnetic Field Mapping
- Dipole Interactions
- Flux Quantization
- Nonlinear Magnetodynamics
- Hysteresis Loops
- Spin Wave Theory

== Health and safety considerations

#include("_safety-dummy.typ")

#pagebreak()

// subsequent pages have numbered sections
#set heading(numbering: "1.")

= Exploration phase 

#lorem(200)

== Code example

In the previous version, `analogRead()` returned a block, which was nonsense. 

```c
// comment or no comment
for (this=1:3) {
  goto 999
  do do this
}

```


#script(title: `script.c`)[
```c
// comment or no comment
for (this=1:3) {
  goto 999
  do do this
}

```
]


