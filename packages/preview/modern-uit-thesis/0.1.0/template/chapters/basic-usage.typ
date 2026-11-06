#import "global.typ": *
#import "../utils/symbols.typ": *
#import "../utils/todo.typ": *

This chapter will go over the template structure and its basic usage. Users should note that the file structure discussed here is merely a recommended starting point and not required for using the template package.

== Template structure <subsec:template_structure>
As opposed to lightweight and uncomplicated report templates you may be familiar with if you have used typst or #LaTeX before, this template has a slightly more involved _file structure_. Instead of writing all content in one large `thesis.typ` file, each chapter is written into its own file and imported in `thesis.typ` instead. These chapters are placed in their own directory.

@fig:file_structure shows a tree view of the default file structure of this template. In addition to the `chapters` directory, there is also one for figures. Here you can neatly store all your `.svg`, `.png` or `.jpg` files and reference them in the chapters. Alternatively, some students might prefer to organize further with a directory for each chapter for both typst content and figures, when their thesis grows in size.

Another important file to note is `refs.bib`. This is where you put your #BibTeX entries that will produce your bibliography, just like you are used to when working with #LaTeX.

#[
  #figure(caption: [File structure tree view])[
    #local(zebra-fill: none, number-format: none)[
      ```
      template
      ├── chapters
      │   ├── basic-usage.typ
      │   ├── figures.typ
      │   ├── global.typ
      │   ├── introduction.typ
      │   ├── typst-basics.typ
      │   └── utilities.typ
      ├── figures
      │   ├── dining_philosophers.png
      │   ├── philosophers.png
      │   ├── plot_serial.svg
      │   └── uit_aurora.jpg
      ├── refs.bib
      ├── thesis.pdf
      ├── thesis.typ
      └── utils
          ├── caption.typ
          ├── feedback.typ
          ├── form.typ
          ├── subfigure.typ
          ├── symbols.typ
          └── todo.typ
      ```
    ]
  ] <fig:file_structure>
]

== Getting Started <subsec:getting_started>
In order to get started using this template document class for your thesis, you can start off with the template you are reading right now right from the typst webapp #footnote[see #link("https://typst.app")]. Very similar to Overleaf, it is an online editor which conveniently compiles and displays your document as you write, and allows for easy online access for your supervisor. You can also edit the document simultaneously with your co-author if you have one. The typst webapp lets you browse templates and will initialize this template for you when you select it.

If you want to work with typst locally in your favorite text editor instead, make sure you have `typst` installed and run `typst init @preview/modern-uit-thesis:0.1.0 my-thesis` and the template will be initialized into `my-thesis`. Now you can compile the document using `typst compile`, or `typst watch` to automatically reload as you make changes to it.

Starting in `thesis.typ`, we can see a function call to a function `thesis`. This is how the thesis template style is applied to the document. There are a number of parameters that can be sent into this invocation both to provide special content like title, abstract or list of abbreviations as well as additional customization details. The default arguments demonstrated in `thesis.typ` should give you an idea of the usage.

We recommend you follow along in the typst code for each chapter as you read them in order to discover how you can leverage the useful features demonstrated there yourself.

