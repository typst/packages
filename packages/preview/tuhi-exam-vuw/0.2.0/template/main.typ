#import "@preview/tuhi-exam-vuw:0.2.0": tuhi-exam-vuw, mark, submark, ending, answer

// use the template
#show: tuhi-exam-vuw.with(
  coursetitle: "scientific basis of murphy's laws", 
  coursecode: "murph101",
  date: datetime(year: 2023, month: 8, day: 3),
  year: "2023", 
  trimester: "2",
  timeallowed: "three hours",
  openorclosed: "open book",
  permitted: "Any materials except communication via electronic devices.",
  instructions: text[Attempt ALL *5* questions
   
   The exam will be marked out of a total of *20* marks.
   
   You can use the formulas listed at the end without rederiving them, unless explicitly requested.],

  logo: image("logo.svg", width: 80mm))


= PART 1

_In multiple-choice questions, briefly justify your answer if unsure. On second thought, scratch that — rewrite the question if you find it makes no sense._ `¯\_(ツ)_/¯`

+ In the context of dermodynamics, point your finger at the true statement(s). #mark(8)

  + The first law of dermodynamics states that fingerprints can only be transferred.
  + The second law of dermodynamics states that fingerprints tend to appear on shiny surfaces.
  + The third law of dermodynamics states that wrinkles always in-crease in a bath tub.
  + The zeroth law of dermodynamics nails down the concept of absolute zero.
  #answer[The finger can only point at the moon, which as far as it knows is shaped like a camembert. Other answers, or none, also acceptable.#submark(8)
  
  Math is also welcome $ 
nabla dot.op bold(A) eq  & 1 / s frac(diff, diff s) lr((s A_s)) plus 1 / s frac(diff A_phi, diff phi) plus frac(diff A_z, diff z)\
nabla times bold(A) eq  & lr((1 / s frac(diff A_z, diff phi) minus frac(diff A_phi, diff z))) bold(hat(s)) plus lr((frac(diff A_s, diff z) minus frac(diff A_z, diff s))) bold(hat(phi)) plus 1 / s lr((frac(diff, diff s) lr((s A_phi)) minus frac(diff A_s, diff phi))) bold(hat(z)) $#submark(0)]
  
+ Explain the concept of quantum tunneling in the context of pub physics. Provide an equation and discuss the factors that influence the probability of quantum tunneling in a half-full / half-empty pint. Would you bet that the pint circumference is greater than $pi$? #mark(5)
 #answer[Don't bet against QM, or the second law, or a combination of both. #submark(5)]

+ What is the _Système International_ unit of cheese ($F$)? #mark(1)

   #grid(columns: (1fr, auto),
   column-gutter: 5mm,
        text[
  + Coulommiers ($C$)
  + Tome ($Omega$)
  + Vieux pané ($V$)
  + Aiguille d'Orcières ($A$)
], image("figures/roquefort.png", width: 3.5in))
  #answer[Non! Mais S.I.! #submark(1)]


+ Describe the _German Specialty_ principle which A. Einstein described in a famous baking textbook, introducing the equation $ E eq m c^2 $ that has revolutionised our understanding of fast food. Provide examples of its applications in the theory of black ovens. Is the cake in the oven when no-one is watching?\ #mark(8) 
 #answer[Imagine eating a tarte tatin in a space elevator, from the perspective of your twin who prefers savoury dishes at high altitude. #submark(1)]
    
  #colbreak() // indentation matters, otherwise numbering restarts  

+ Ray was arrested by Alice and Bob and is trapped under total internal incarceration. Which of the following phenomena is responsible for the change in Ray's trajectory, and ultimate rehabilitation from the darkness whence Ray came? #mark(0.2)

  + Retraction
  + Deflexion
    + Ray's
    + Someone else's
  + Superstition
  + Infraction
  #answer[Cf. the Scat theorem #submark(0.2)]

#ending

#include "appendix.typ"
