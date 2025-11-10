#import "/src/library.typ": subtype, citation
#import citation: *

#show: grape-suite-citation

#show: subtype.essay.with(
    title: "Lorem ipsum dolor sit",
    university: [University],
    institute: [Institute],
    seminar: [Seminar],
    semester: [Semester],
    docent: [Docent],
    author: [Author],
    date: [1#super[st] January 1970],
)

= Introduction
#lorem(100)

#quote(attribution: [Alfred North Whitehead])[
    The safest general characterization of the European philosophical tradition is that it consists of a series of footnotes to Plato.
]

#lorem(100)

= Long heading: #lorem(10)

#lorem(100)

#quote(attribution: [#ct-full("schlick_wende_2008")[S. 213 ff]])[
    Ich bin nämlich überzeugt, daß wir in einer durchaus endgültigen Wendung der Philosophie mitten darin stehen und daß wir sachlich berechtigt sind, den unfruchtbaren Streit der Systeme als beendigt anzusehen. Die Gegenwart ist, so behaupte ich, bereits im Besitz der Mittel, die jeden derartigen Streit im Prinzip unnötig machen; es kommt nur darauf an, sie entschlossen anzuwenden.

    Diese Mittel sind in aller Stille, unbemerkt von der Mehrzahl der philosophischen Lehrer und Schriftsteller, geschaffen worden, und so hat sich eine Lage gebildet, die mit allen früheren unvergleichbar ist. Daß die Lage wirklich einzigartig und die eingetretene Wendung wirklich endgültig ist, kann nur eingesehen werden, indem man sich mit den neuen Wegen bekannt macht und von dem Standpunkte, zu dem sie führen, auf alle die Bestrebungen zurückschaut, die je als "philosophische" gegolten haben.

    Die Wege gehen von der _Logik_ aus.
]

Moritz Schlick sees predicate logic as a new way of doing philosophy.#cf("schlick_wende_2008")[S. 215] His proposition "Die Wege gehen von der _Logik_ aus."#ct(<schlick_wende_2008>)[S. 215] makes this clear.

= Main Part
#lorem(100)

#lorem(100)

== Subheading 1
#lorem(200)

== Subheading 2
#lorem(100)

== #lorem(20)

#lorem(200)

= Conclusion

#lorem(100)

#lorem(100)

#bibliography("essay01.bib")