#import "/src/library.typ": citation, subtype
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
    For I am convinced that we are in the midst of a truly definitive turning point in philosophy, and that we are objectively justified in regarding the fruitless dispute between systems as over. The present, I maintain, already possesses the means that render any such dispute unnecessary in principle; it is only a matter of applying them resolutely.

    These means have been created quietly, unnoticed by the majority of philosophical teachers and writers, and thus a situation has arisen that is incomparable to any previous one. That the situation is truly unique and the turn of events truly definitive can only be understood by familiarizing oneself with the new paths and, from the vantage point to which they lead, looking back upon all the endeavors that have ever been regarded as "philosophical."

    The paths proceed from _logic_.
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
