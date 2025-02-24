#import "/src/library.typ": exercise
#import exercise: project, task, subtask, todo

#show: project.with(
    title: "Lorem ipsum dolor sit",

    university: [University],
    institute: [Institute],
    seminar: [Seminar],

    abstract: lorem(100),
    show-outline: true,

    author: "John Doe",

    show-solutions: false
)

= Introduction
#lorem(100)


#lorem(100)

= Long heading: #lorem(20)

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