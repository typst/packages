#import "/src/library.typ": seminar-paper, german-dates
#import seminar-paper: todo, blockquote, definition, sidenote

#let definition = definition.with(figured: true)

#set text(lang: "de")

#show: seminar-paper.project.with(
    title: "Die Intensionalität von dass-Sätzen",
    subtitle: "Intensionale Kontexte in philosophischen Argumenten",

    university: [Universität Musterstadt],
    faculty: [Exemplarische Fakultät],
    institute: [Institut für Philosophie],
    docent: [Dr. phil. Berta Beispielprüferin],
    seminar: [Beispielseminar],

    submit-to: [Eingereicht bei],
    submit-by: [Eingereicht durch],

    semester: german-dates.semester(datetime.today()),

    author: "Max Muster",
    student-number: "0123456789",
    email: "max.muster@uni-musterstadt.uni",
    address: [
        12345 Musterstadt \
        Musterstraße 67
    ],
)

= Einleitung
#lorem(100) #todo(lorem(20))

#lorem(100)

#blockquote[
    #sidenote[Logischer Empirismus] Ich bin nämlich überzeugt, daß wir in einer durchaus endgültigen Wendung der Philosophie mitten darin stehen und daß wir sachlich berechtigt sind, den unfruchtbaren Streit der Systeme als beendigt anzusehen. Die Gegenwart ist, so behaupte ich, bereits im Besitz der Mittel, die jeden derartigen Streit im Prinzip unnötig machen; es kommt nur darauf an, sie entschlossen anzuwenden.

    Diese Mittel sind in aller Stille, unbemerkt von der Mehrzahl der philosophischen Lehrer und Schriftsteller, geschaffen worden, und so hat sich eine Lage gebildet, die mit allen früheren unvergleichbar ist. Daß die Lage wirklich einzigartig und die eingetretene Wendung wirklich endgültig ist, kann nur eingesehen werden, indem man sich mit den neuen Wegen bekannt macht und von dem Standpunkte, zu dem sie führen, auf alle die Bestrebungen zurückschaut, die je als ”philosophische“ gegolten haben.

    Die Wege gehen von der _Logik_ aus.
][
    @schlick_wende_2008[S. 213 ff.]
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