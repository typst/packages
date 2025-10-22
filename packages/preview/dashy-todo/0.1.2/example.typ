#import "/lib/todo.typ": todo

#set page(width: 16cm, height: 12cm, margin: (left: 20%, right: 20%), fill: white)
#show link: underline

= Dashy TODOs

#let blue-todo = todo.with(stroke: blue)

TODOs are automatically positioned on the closer#todo[On the right] side to the method call.#blue-todo[On the left] If it doesn't fit, you can manually override it. #todo(position: "inline")[You can also place them in an inline box.]

You can add custom content.#todo(position: right, stroke: (paint: green, thickness: 1pt, dash: "densely-dashed"))[We need to fix the $lim_(x -> oo)$ equation. See #link("https://example.com")[example.com]]

#let small-todo = (..args) => text(size: 0.6em)[#todo(..args)]

We can also control the text #small-todo[This will be in fine print]size if we wrap it in a `text` call.

And finally, you can create a table of all your TODOs:

#outline(title: "TODOs", target: figure.where(kind: "todo"))
