#import "../format.typ": showcode

= Question
The `question()` function is to create a question block. <ex:qs-block>
#showcode(```typst
#question(4)[
  The question.
  #question(2)[
    Sub-question.
  ]
  #question(0)[
    Another sub-question.
    #question(1)[
      Sub-sub-question.
    ] <ex:qs:that-one>
    #question(1)[
      Another sub-sub-question.
    ]
  ]
]
#question[2 points, -2 if wrong][
  The risky bonus question.
]
You see #link(<ex:qs:that-one>)[that question]?
```)

== Referencing Questions
Questions can be referenced by their automatically assigned labels. For example, question 1.b.ii has label `<qs:1-b-ii>` and can be referenced by `#link(<qs:1-b-ii>)[That question]`. Note that it cannot be referenced by `@qs:1-b-ii`.

If, for some reason, questions with the same numbering occurs multiple times, a number indicating order of occurrence will be appended to the label. For example, the first 1.b will be labeled `<qs:1-b>`, and the second occurrence of numbering will have label `<qs:1-b_2>`.

As you are constructing your project, the numbering automatically assigned to a question may change. If you want a static reference, which will be preferable in most cases, you can assign a custom label to the question.

Just as in the #link(<ex:qs-block>)[example above], adding a ```typc <label-name>``` after the question creates a custom label that would not change with order of questions.
