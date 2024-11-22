#import "@preview/athena-tu-darmstadt-exercise:0.1.0": tudaexercise, tuda-section, tuda-subsection

#show: tudaexercise.with(
  language: "eng",
  info: (
    title: "Usage of TUDaExercise",
    subtitle: "A small guide.",
    author: "Andreas",
    term: "Summer semester 2042",
    date: datetime.today(),
    sheetnumber: 5
  ),
  logo: image("logos/tuda_logo.svg"),
)

#set enum(spacing: 1em, numbering: "1.", indent: 5pt)

= Most basic usage

The easiest way is by using `typst init` like on this templates universe page. But here is everything broken down:

== Add to typst
+ Import the package: `#import "@preview/athena-tu-darmstadt-exercise:0.1.0": *`

+ Apply the template using `#show: tudaexercise.with(<options>)`

== Fonts
The template requires the following fonts: Roboto and XCharter. Typst right now does not allow fonts to be installed as packages so you will either need to install them locally or configure Typst and co. to use the fonts.

For more info:  \
https://github.com/JeyRunner/tuda-typst-templates?tab=readme-ov-file#logo-and-font-setup

== Logo
Similarly as the logo is protected and Typst does not have a folder for global resources you will need to setup the logo manually. You will need to download the logo and convert it into a pdf. Then pass the `logo: image(<path to logo>)` option to this package. The height of the logo will automatically be set to 22mm.

= Configuring the title
All options of the title can be controlled using the `info` dictionary:

```
info: (
  title: "The big title",
  subtitle: "The smaller title below",
  author: "The author, can also be an array of authors",
  term: "The current term aka. semester",
  date: "The current date, mostly appreciated as typst builtin datetime type",
  sheetnumber: 0 // The current sheetnumber
)
```
The options can also be left empty. Then their corresponding item will not appear.

You might notice that there also is a `header_title` option. This option is not currently used as headlines are not yet implemented.

If you do not want to have a the title block you can also set `show_title` to `false`.

#pagebreak()

= Design

You can control the design using the following options of the `design` dictionary:

```
design: (
  accentcolor: "0b", // either be color code of the TUDa coloring scheme or a typst color object
  colorback: true, // whether the title should have the accent color as background,
  darkmode: false, // If you like a dark background
)
```

Furthermore using the `tud_design` state you get a dictionary with the following colors used by the template: ` text_color, background_color, accent_color, text_on_accent_color`.

Note that changing any of these values will have no effect on the template. See it as read-only.

If you do not like lines around subtasks you can pass `subtask: "plain"` to not show the lines.

= More options

The leftover options are `language` to control the language of certain keywords (can either be `"ger"` or `"eng"`) and `margins` which is a dictionary controlling the page margins. There are also the options `paper` which currently only supports `"a4"` and `headline` which currently is unsupported.

= Creating tasks

Creating tasks is fairly easy. You simply write
```
= Title of your task
```
Similarly subtasks are created using
```
== Title of your subtask
```

#tuda-subsection("Sections")

If you want to create a unnumbered section you can use the `tuda-section` or `tuda-subsection` functions accordingly. Simply pass the section title as a string.
```
#tuda-subsection("Sections")
```

= Currently not supported features from the LaTeX template and the why

+ Points -- This would require a state and make declaring tasks far more complex than just using headings, although technically the points can also be written manually into the function title.

+ Solutions -- The problem here is that enabling whether solutions should be shown form within a template requires states which are pretty costly. However you can implement them rather easily.

+ Headline -- This sadly can't be implemented manually as the core problem here comes from how Typst page margins and context work. There would be a workaround of just placing the title over the headline to mimic the frontpage.
