#import "/src/library.typ": subtype

#show: subtype.protocol.with(
    title: "Some session's title",
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

#quote(attribution: [Someone])[
    #lorem(20)
]

#lorem(100)

= Long heading: #lorem(10)

#lorem(100)

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