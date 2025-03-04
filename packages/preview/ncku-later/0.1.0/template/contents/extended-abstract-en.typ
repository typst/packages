#import "../setup.typ": extended-abstract-en

/*
 * Only the SUMMARY section should be wrapped into extended-abstract-en() function
 * ths reason is that the document should generate a rectangle to wrap the summary section
 */

#show: extended-abstract-en.with(
  summary: [
    #lorem(100)

    #lorem(100)
  ],
  keywords: ("key1", "key2"),
)

= INTRODUCTION

#lorem(50)

= MATERIALS AND METHODS

#lorem(50)

#pagebreak()

