#import "@preview/simple-unimi-thesis:0.2.0": *
#import "@preview/touying:0.7.4": *
#import "@preview/zebraw:0.6.3": *

#show: zebraw.with(numbering: false, inset: (left: 1.25em))
#show: unimi-presentation.with(
  config-info(
    title: [`unimi-presentation` manual],
    author: [Vittorio Robecchi],
    serial-number: "10851734",
    date: datetime.today(),
  ),
)

#set text(lang: "en")

#title-slide()

= Introduction

== Title

- Compile the following information in ```typ #config-info()``` at the start of the presentation:
  ```typ
  #show: unimi-presentation.with(
    config-info(
      title: [Title of the Presentation],
      course: [Degree course],
      author: [Name Surname],
      serial-number: [123456],
      date: datetime(...),
    ),
  )
  ```

---

- Set the language:
  ```typ
  #set text(lang: "en")
  ```
  #pause

- Both the title slide and the regular ones referecence that data #pause

- The title slide is callable with ```typ #title-slide()``` and usually it's placed after the language setting

== General commands

- The presentation can be split into different sections and slides, respectively using the level 1 (```typ =```) and 2 (```typ ==```) headings  #pause

  - *Warning*: the numbers in the bottom left references respectively to the count of slides _now_ (#context utils.slide-counter.display()) and the _total_ number of slides (#context utils.last-slide-number) -- *NOT* the page number #pause

- In the page header there will always be the title of current slide and the section name #pause

- Once every section change, the table of contents will be invoked with the corresponding title highlighted, whereas the others will be slightly faded (see next slide)

= Writing the presentation

== Lists

- A typical slide is composed of list items that will appear one at a time #pause

- The list items are written as follows:
  ```typ
  - First
  - Second
  ``` #pause

- To make them appear one by one, Touying has the ```typ #pause``` function:
  ```typ
  - First #pause
  - Second #pause
  ``` #pause

- Notice the slide count didn't change (that is #context utils.slide-counter.display())

== Colonne

#columns[
  - Often it's useful to place the content in a specific number of columns depending on needs #pause

  - Typst has the ```typ #columns(n)``` function, that spreads the content on multiple columns based on the specified `n`umber #pause

  #colbreak()

  - There is also ```typ #colbreak()``` for column break #pause

  - Touying however has ```typ #components.adaptive-columns()```, that evenly spreads the content on multiple columns based also on dimensiones (the table of contents works this way)
]

== Split the slides

- Sometimes it's needed to move early to the next slide, without waiting for the content to fill it#pause

- In other words, first show some content...

---

- ...and only then the rest; however when "removing" the first part it's as if the the slide has been refreshed #pause

- This can be achieved by using ```typ ---```, that internally calls ```typ #pagebreak()```

== Conclusion

- The presentations often close with a single slide that contains something along the lines of "Thanks for listening" or similar phrases #pause

- The standard way to do this is by using ```typ #focus-slide(content)```, where `content` is the closing phrase #pause

- The code of the next -- and last -- slide is just

  ```typ
  #focus-slide("Thanks for listening.")
  ```

#focus-slide("Thanks for listening.")
