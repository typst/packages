#import "../imports.typ": *

= Other Sections (Chapters)

*Instructions from the @pfc Coordination:*

A practice that contributes to better text flow is to include an introductory paragraph at the beginning of each chapter, describing the topics that will be addressed and their relationship with the rest of the work. For example, “Section 2.1 presents …”, “The results obtained are analyzed in Section 2.2.” The same can be done at the beginning of major sections, explaining to the reader in one or two sentences what is coming next and why. Another good practice is to connect each chapter to the following one at its end.

Figures, tables, charts, and equations must be introduced and explained in the text; they cannot simply be “thrown” into it without reference or explanation. For example, write: “The designed circuit is shown in Figure 1. Resistor $R_1$ acts as a current limiter, while capacitor $C_2$ together with resistor $R_5$ form a low-pass filter. This circuit has the advantage of …”

Regarding equations, one should not refer to an equation that has not yet been presented. For instance, do not write: “The relationship between voltage and current in a resistor is given by @eq:errado”:

$ V = R I. $ <eq:errado>

#noindent[The correct way is something like “The relationship between voltage and current in a resistor is given by Ohm’s Law,”]

$ V = R I, $ <eq:correto>

#noindent[in which $V$ is the voltage applied to the resistor, $R$ is the resistance, and $I$ is the electric current.”]

It is important to note that equations are part of the text and, therefore, it is often appropriate to insert a comma or period at the end. If the paragraph continues, indentation should be removed from the next line using the command `#noindent[...]`. Furthermore, if the sentence continues, the next line should begin with a lowercase letter. See examples in @eq:errado and @eq:correto.

Below is an equation within a line of text: $hat(y)(t + k | t) = sum_(i=1)^infinity g_i Delta u(t+k-i | t)$. And here is a cross-reference to @fig:elementos-trabalho and @eq:ex1.
