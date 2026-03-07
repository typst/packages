#import "@preview/sleiden-lei:1.0.0": *

#show: slides.with(lang: "en")
#let title = [This is the title of my presentation!]
#set document(title: title)

#title-presentation(
  title: title,
  name: [Firstname Lastname],
  place: [Leiden],
  date: [2026-02-16],
)

#only-text(
  title: [I can change the title of a slide like this],
  body: [The content of the slide goes here],
)

#text-and-image-equal(
  title: [Here's a slide with text and and an image],
  body: [This is the text of the slide],
  image: box(width: 100%, height: 100%, fill: gradient.linear(..color.map.rainbow))[Here's where I would put my image],
)

#index()

#text-dominant()

#image-dominant()

#only-image()

#text-and-4-images()

#text-and-2-images()

#title-closure()