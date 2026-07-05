# Machiatto

This is a typst package to help develop publications under MoKa Reads Specification.
This contains all necessary graphical components to make a visually stunning book,
to help enhance the reader's experience.

```typst
#import "../lib.typ": *

#show: doc.with(
  author: "Mustafif",
  title: "Machiatto Example",
  paper-size: "a4",
  ack: [
    This will contain all of those who you would like to thank
  ],
  license: [
    #heading("License", outlined: false)
    This will contain licensing and publisher information
  ],
  preface: none,
  toc: true,
  bibliography: none,
)

= Blocks
#def(title: "A Definition", [
  This is a definition of something
])

#note([
  This is something to note
])

#todo([
  What next do I need to do
])

#code_file(
  "example/hello.c",
  "C",
  color.aqua,
)

#terminal(
  title: "Terminal",
  $ sudo rm -rf / # remove french pack from your system
)
```

MoKa Reads Publication Specification: 
1. Title Page
2. License, Copyrights, Publish Dates, ISBN
3. Acknowledgements
4. Preface
5. Table of Contents
6. Chapter
  - Use level 1 heading under centered alignment
  - Contain a summary of the chapter
  - After the summary use `minitoc`
  - The first section (which uses heading level 2) should follow on the following page


This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
