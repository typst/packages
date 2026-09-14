#import "/src/library.typ": german-dates, seminar-paper
#import seminar-paper: definition, sidenote, todo

#let definition = definition.with(figured: true)

#show: seminar-paper.project.with(
    title: [Intensionality of That-#sym.wj;Clauses],
    subtitle: [Intensional Contexts in Philosophical Arguments],

    university: [Example University],
    faculty: [Example Faculty],
    institute: [Institute for Philosophy],
    instructor: [Dr. phil. Berta Beispielprüferin],
    seminar: [Example Seminar],

    date: [14#super[th] June 2023],
    semester: none,

    author: "John Doe",
    student-number: "0123456789",
    email: "john.doe@university.uni",
    address: [
        12345 Musterstadt \
        Musterstraße 67
    ],
)

= Einleitung
#lorem(100) #todo(lorem(20))

#lorem(100)

#quote(attribution: [@schlick_wende_2008[S. 213 ff.]])[
    #sidenote[Logischer Empirismus] For I am convinced that we are in the midst of a truly definitive turning point in philosophy, and that we are objectively justified in regarding the fruitless dispute between systems as over. The present, I maintain, already possesses the means that render any such dispute unnecessary in principle; it is only a matter of applying them resolutely.

    These means have been created quietly, unnoticed by the majority of philosophical teachers and writers, and thus a situation has arisen that is incomparable to any previous one. That the situation is truly unique and the turn of events truly definitive can only be understood by familiarizing oneself with the new paths and, from the vantage point to which they lead, looking back upon all the endeavors that have ever been regarded as "philosophical."

    The paths proceed from _logic_.
]

#definition[
    #lorem(30)
]<important-definition>

Siehe @important-definition und @second-important-definition.

= Hauptteil
#lorem(100)

#sidenote[#lorem(5)] #lorem(100)

== These
#lorem(200)

== Antithese
#lorem(100) #todo(lorem(20))

#lorem(200)

== Synthese
#lorem(100)

#definition[
    #lorem(20)
]<second-important-definition>

#lorem(200)

== #lorem(20)

= Fazit

#lorem(100)

#lorem(100)

#pagebreak()
#bibliography("seminar-paper01.bib", style: "chicago-author-date")
