#import "../utils/global.typ": *
#import "../utils/todo.typ": TODO
#import "../utils/feedback.typ": feedback
#import "../utils/form.typ": form

Now we will take a look at some useful custom utilities included with this template under `utilities/`. If you find yourself needing some other function for your thesis, it's a great idea to implement it here and include it in your chapters in the same manner.

== Figures <subsec:util_figures>
We've already seen the utilities we have implemented for use with figures earlier, refer to @subsec:subfigures.

== TODOs and Feedback <subsec:feedback_todo>
Two functions are available for inserting temporary comments into the document to help you while writing your thesis.

#TODO()[The `#TODO()` function is handy for inserting comments to your future self about your thesis. It has a default yellow color to make it easily visible and prevent you from overseeing it when reviewing the document.]
#TODO(
  color: red,
  title: "FIXME",
)[Alternatively, you can also pass in another color and/or title to distinguish different types of notes from one another]

#feedback(
  feedback: [Another function is `#feedback()`. It lets your advisor easily insert feedback comments into your document...],
  response: [...and also lets you add your own response to the note so that you can discuss it in your next meeting. Also note that #link("https://typst.app") has a comment functionality, however it requires a paid subscription.],
)

== Forms <subsec:forms>
In some cases, you might want to print out your document and leave spots for yourself or others to add data such as signatures to it by hand. This can be achieved using the `#form()` utility function. Leaving the second argument empty, we can leave space for the signature:

#form([Leslie Lamport \ Main supervisor], [])

We can also fill in the content with typst by supplying some content:

#form([Date and location], [#datetime.today().display() -- Tromsø, Norway])

== Abbreviations <subsec:abbreviations>
In order to easily deal with abbreviations in an automatic and consistent manner, the glossarium #footnote()[see #link("https://typst.app/universe/package/glossarium/")] package is used in this template. As an input to the thesis function in `thesis.typ` we can supply a dictionary of glossary entries, giving a short version and a long one. These entries will be displayed at the start of the thesis in the List of Abbreviations.

When we refer to an abbreviation the first time in the document, the long version will be printed: @uit. All subsequent references will instead use the short one: @uit. After we have referred to @cpu the first time, we might also want to refer to it in plural when writing about multiple @cpu:pl.
