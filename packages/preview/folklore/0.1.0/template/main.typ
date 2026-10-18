#import "@preview/folklore:0.1.0": setup, author-notes, major-break

#show: setup.with(
  work-title: [example book with some long title],
  work-author: [ex. author],
  copyright-page: [
    Made with love---as per yuʒ.
  ],
  blank-pages-after-toc: 1,
  preface: [
    This is a book! It's made for the physical page, so view with even spreads in your PDF viewer of choice. Each page is half-letter sized by default.

    I hope you like it! :3
  ],
)

= chapter one

#author-notes[
  These boxes are nice if authors have notes at the end or beginning of chapters that you'd like to keep in.

  Notice how chapters start on the recto side of the spread by default.
]

#lorem(200)

#author-notes[
  This is an example of an author's note at the end of a chapter.
]

= chapter two has a really super crazy long title because this is an edge case that pops up every once in a while

#author-notes[
  Alright, super long author's note. Lorem ipsum, go!

  #lorem(100)

  #lorem(100)

  #lorem(100)

  #lorem(100)
]

#lorem(200)

#author-notes[Notice how the header doesn't show up on chapter pages, and does otherwise.]

= chapter three

#lorem(200)

#major-break

#lorem(150)

#lorem(180)

= chapter four

And that's all, folks!
