#import "@preview/nomos:0.1.0": *

= Nomos package

---

#print-nomenclature(
    title: "Nomenclature",
    depth: 2,
    numbering: none,
    outlined: false,
    symb: "Symbol",
    description: "Description",
    value: "Value",
    unit: "Unit",
    domain: "Domain",
    sections: none
) // Reseting some parameters to default value to expose them all

---

== Newton's Law
The relationship between the Earth and the Moon is governed by Newton's Law of Universal Gravitation. It posits that the gravitational force (#add-ncl($F$, "Gravitational force", unit: $"N"$, domain: $RR$, sec: "Latin")) between two bodies is proportional to the product of their masses and inversely proportional to the square of the distance between them. Since its a force, #ncl($F$) is express in #ncl-u($F$).

=== The Formula
The central equation for this interaction is:
#add-ncl-silent($G$, "Gravitational constant", value: $6.67430 times 10^(-11)$, unit: $"m"^3 "kg"^(-1) "s"^(-2)$, sec: "Latin")
#add-ncl-silent($m_1$, "Mass of \"body 1\"", unit: $"kg"$, domain: $RR^+$, sec: "Latin")
#add-ncl-silent($m_2$, "Mass of \"body 2\"", unit: $"kg"$, domain: $RR^+$, sec: "Latin")
#add-ncl-silent($r$, "Distance between the centers of the masses", unit: $"m"$, domain: $RR^+$, sec: "Latin")

$ #ncl($F$) = #ncl($G$) (#ncl($m_1$) #ncl($m_2$)) / #ncl($r$)^2 $ // Clikable symbole

Where:
- #ncl($F$) is the #ncl-dl($F$) expressed in #ncl-u($F$) in #ncl-dm($F$).
- #ncl($G$) is the #ncl-dl($G$) which is equal to #ncl-vu($G$).
- #ncl($m_1$) is the #ncl-dl($m_1$) expressed in #ncl-u($m_1$) in #ncl-dm($m_1$).
- #ncl($m_2$) is the #ncl-dl($m_2$) expressed in #ncl-u($m_2$) in #ncl-dm($m_2$).
- #ncl($r$) is the #ncl-dl($r$) expressed in #ncl-u($r$) in #ncl-dm($r$).

== Gravity at the Local Level 
The potential energy or the force acting on an object is the gravitational potential (#add-ncl($Phi$, "Gravitational potential", unit: $"J" "kg"^(-1)$, domain: $RR^-$, sec: "Greek")) given by:
#add-ncl-silent($M$, "Mass of the larger body", unit: $"kg"$, domain: $RR^+$, sec: "Latin")

$ #ncl($Phi$) = -frac(#ncl($G$) #ncl($M$), #ncl($r$)) $ // Clikable symbole

Where:
- #ncl($Phi$) is the #ncl-dl($Phi$) expressed in #ncl-u($Phi$) in #ncl-dm($Phi$).
- #ncl($M$) is the #ncl-dl($M$) expressed in #ncl-u($M$) in #ncl-dm($M$).