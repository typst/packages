#import "@preview/numera:0.1.0": numera

#show: numera()

// References to elements with `supplement: none` must render the bare
// number like Typst's built-in reference rule, without a leading
// non-breaking space.
#set math.equation(numbering: "1", supplement: none)
#set figure(numbering: "1", supplement: none)

$ E = m c^2 $ <eq-none>

#figure([A result], caption: [Without supplement]) <fig-none>

References without supplements: @eq-none and @fig-none.

#set math.equation(supplement: auto)
#set figure(supplement: auto)

$ E = m c^2 $ <eq-auto>

#figure([A result], caption: [With default supplement]) <fig-auto>

References with default supplements: @eq-auto and @fig-auto.
