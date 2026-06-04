#import "@preview/athena-tu-darmstadt-exercise:0.2.0": tudaexercise, tuda-section, tuda-subsection, tuda-gray-info, title-sub, text-roboto

#show: tudaexercise.with(
  language: "eng",
  info: (
    title: "Usage of TUDaExercise",
    subtitle: "A small guide.",
    author: (("Andreas", "129219"), "Dennis"),
    term: "Summer semester 2042",
    date: datetime.today(),
    sheet: 5,
    group: 1,
    tutor: "Dr. John Smith",
    lecturer: "Prof. Dr. Jane Doe",
  ),
  title-sub: title-sub.exercise(),
  logo: image("logos/tuda_logo_replace.svg"),
  design: (
    accentcolor: "0b",
    colorback: true,
    darkmode: false,
  ),
  task-prefix: none,
)

#set enum(spacing: 1em, numbering: "1.", indent: 5pt)
#set list(marker: [--], indent: 5pt, spacing: 1em)

= Most basic usage

The easiest way is by using `typst init` like on this templates universe page. But here is everything broken down:

== Add to typst
+ Import the package: `#import "@preview/athena-tu-darmstadt-exercise:0.1.0": *`

+ Apply the template using `#show: tudaexercise.with(<options>)`

== Fonts
The template requires the following fonts: Roboto and XCharter. Typst right now does not allow fonts to be installed as packages. So you will either need to install them locally or configure Typst and co. to use the fonts.

#tuda-gray-info(title: "For more info:")[
https://github.com/JeyRunner/tuda-typst-templates?tab=readme-ov-file#logo-and-font-setup
]

== Logo
Similarly as the logo is protected and Typst does not have a folder for global resources you will need to setup the logo manually. You will need to download the logo and convert it into a svg. Then pass the `logo: image(<path to logo>)` option to this package. The height of the logo will automatically be set to 22mm.

= Configuring the title
All options of the title can be controlled using the `info` dictionary:

```
info: (
  title: "The big title",
  subtitle: "The smaller title below",
  author: "The author",
  // author: ("Author 1", "Author 2"), // can also be an array of authors
  // author: (("Author 1", "123456"), "Author 2"), // or the matriculation number can be provided
  term: "The current term aka. semester",
  date: "The current date",
  // date: datetime.today(), // can also be a datetime object
  sheet: 0, // The current sheetnumber

  // submission extras:
  group: "05", // the lecture group you are in
  tutor: "John", // the tutor of your group
  lecturer: "Karpfen", // the lecturer of the module that this assignment is for
)
```
The options can also be left empty. Then their corresponding item will not appear.

Additionally there is the `title-sub` field which controls how the subline of the title looks like. By default this is set to the exercise version. There also is a submission version which also displays the submission extra info fields. Or if both don't fit your needs, you can also pass raw content to the field and control the subline to your will. \
For more info see the exported `title-sub` module of this template. 

If you do not want to have a title card you can also set `show-title` to `false`.

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

Note that changing any of the state's values will have no effect on the template. See the state as read-only.

If you do not like lines around subtasks you can pass `subtask: "plain"` to not show the lines.

= More options

The leftover options are: 
- `language` to control the language of certain keywords (can either be `"ger"` or `"eng"`) 
- `margins` which is a dictionary controlling the page margins 
- `paper` which currently only supports `"a4"` 
- `headline` which currently is unsupported.

= Creating tasks

Creating tasks is fairly easy. You simply write
```
= Title of your task
```
Similarly subtasks are created using
```
== Title of your subtask
```

If you dislike the default task prefix, you can also set your own by changing the `taks-prefix` field of the template.

#pagebreak()

#tuda-subsection("Sections")

If you want to create an unnumbered section you can use the `tuda-section` or `tuda-subsection` functions accordingly. Simply pass the section title as a string.
```
#tuda-subsection("Sections")
```

= Currently not supported features from the LaTeX template and the why

+ Points -- This would require a state and make declaring tasks far more complex than just using headings. Though technically the points can also be written manually into the task title.

+ Solutions -- Enabling whether solutions should be shown or not from within the template would again require a state and is thus rather costly. However you can implement them rather easily as from outside the template a boolean will already do.

+ Headline -- The core problem here comes from how Typst's page margins and context work. There would be a workaround of just placing the title card over the headline of the first page but that is rather hacky. Thus sadly this also can't be implemented manually.
