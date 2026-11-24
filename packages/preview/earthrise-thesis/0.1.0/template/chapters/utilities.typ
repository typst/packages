#import "../utils/global.typ": *
#import "../utils/todo.typ": TODO
#import "../utils/feedback.typ": feedback
#import "../utils/form.typ": form

This chapter shows the helpers in `utils/`. Add your own there, and import them into your chapters the same way.

== Figures <subsec:util_figures>
The figure utilities are shown in @subsec:subfigures.

== TODOs and Feedback <subsec:feedback_todo>
Two functions add temporary comments while you write. Remove them before you submit.

#TODO()[`#TODO()` leaves a note for your future self. It is yellow by default so that you do not overlook it when reviewing the document.]
#TODO(
  color: red,
  title: "FIXME",
)[Pass another color or title to tell different kinds of notes apart.]

#feedback(
  feedback: [`#feedback()` lets your supervisor add a comment to the document...],
  response: [...and lets you answer it, ready for your next meeting.],
)

== Forms <subsec:forms>
`#form()` leaves room for handwritten data, such as a signature, on a printed copy. Leave the second argument empty for a blank field:

#form([Jane Doe \ Main supervisor], [])

Fill the field by passing content:

#form([Date and location], [1 June 2025 -- \<city\>])

== Publications <subsec:publications>
The `publications` argument of `thesis` lists the articles the thesis builds on. Each entry has:
- `key`, to refer to it with the `pub:` prefix: @pub:doe2024first and @pub:doe2025second;
- `text`, the formatted reference;
- optionally `group`, the heading it is listed under;
- optionally `status`, such as "Under review", printed before it.

The list follows the lists of contents, figures, tables and listings.

== Abbreviations <subsec:abbreviations>
The glossarium #footnote()[see #link("https://typst.app/universe/package/glossarium/")] package keeps abbreviations consistent. Pass glossary entries to `thesis`, each with a key, a short form and a long form; the Glossary at the start of the thesis lists those you cite.

The first reference prints the long form followed by the short one: @gc. Later references print the short form: @gc. Plurals work too: after a first reference to @cpu, write about several @cpu:pl.
