#import "@preview/showman:0.1.2": runner
// #import "@preview/mitex:0.2.5": mitex

#import "src/lib.typ"
#import lib: *

#show "Instructor:": text.with(fill: color.yellow.darken(33%), weight: "semibold")
#show "Student:": text.with(fill: green.darken(33%), weight: "semibold")

//SOURCE: https://gist.github.com/felsenhower/a975c137732e20273f47a117e0da3fd1
#let LaTeX = {
  let A = (offset: (x: -0.33em, y: -0.3em), size: 0.7em)
  let T = (x_offset: -0.12em)
  let E = (x_offset: -0.2em, y_offset: 0.23em, size: 1em)
  let X = (x_offset: -0.1em)
  [L#h(A.offset.x)#text(size: A.size, baseline: A.offset.y)[A]#h(T.x_offset)T#h(E.x_offset)#text(size: E.size, baseline: E.y_offset)[E]#h(X.x_offset)X]
}
#show "LaTeX": LaTeX

#let get-orientation(dir) = {
  if dir == ltr {
    return (
      dir: ltr,
      cols: (1fr, 1fr),
      align: (x, y) => (right, left).at(calc.rem(x, 2)),
      line: grid.vline,
    )
  } else if dir == ttb {
    return (
      dir: ttb,
      cols: 1,
      align: (x, y) => (bottom, top).at(calc.rem(y, 2)),
      line: grid.hline,
    )
  }
}

#let showcode(code, dir: ltr, wrap: none) = {
  let orientation = get-orientation(dir)
  let prefix = ""
  let suffix = ""
  if code.lang == "typc" {
    prefix = prefix + "\n#{"
    suffix = "}\n" + suffix
  }

  if wrap != none {
    prefix = prefix + "\n" + (if code.lang == "typst" { "#" }) + wrap + "("
    suffix = ")\n" + suffix
  }

  runner.standalone-example(
    code,
    eval-prefix: prefix,
    eval-suffix: suffix,
    scope: dictionary(lib),
    direction: orientation.dir,
    container: (input, output, direction: ltr) => {
      block(
        width: 100%,
        grid(
          columns: orientation.cols,
          align: orientation.align,
          inset: (x: 1em, y: 0.8em),
          grid.cell(input),
          orientation.at("line")(stroke: 0.5pt),
          grid.cell(output),
        ),
      )
    },
  )
}

//START

#show: setup.with(
  config: (
    title: (
      format: text.with(size: 1.5em, weight: "bold"),
    ),
  ),
  title: [
    #text(fill: black.transparentize(67%))[Lacy-UBC]
    Math Group Project Template \ User Manual #toml("typst.toml").package.version
  ],
)

This #link("https://typst.app/docs")[Typst] template initially is to help you write and format #link("https://www.math.ubc.ca/undergraduate/courses")[UBC_V MATH 100&101] group projects. It is based on their existing (2025) LaTeX template. Despite the name, it offers a flexible layout for possibly other types of question-solution documents.

This manual has two specifics: one for "Student:" who consume documents already populated with content, and the other for "Instructor:" (TA's too) who use the template to make projects for the students.

You can skip to the next page if you already know why you are using a Typst template.

#line(length: 100%)

The two popular choices among students for typesetting math content, Word and LaTeX, each has significant drawbacks.

Word, sounds familiar and easy, but...
- the math formatting (MathType) may be uncomfortable;
- you pretty much have to use MS Word/WPS/Google Doc/Pages, the editing experience using "libre" solutions like LibreOffice are subpar;
- many do not really know how to make use of Word, like styles, ruler, tab stops and template, so documents get messy.

LaTeX is a powerful and professional academic typesetting system, plus, you can use your favorite text editor, but...
- the syntax may be cryptic;
- the error messages are cryptic;
- compilation (PDF generation) can be slow;

#block(
  breakable: false,
  grid(
    columns: (1fr, 2fr, 1fr),
    align: center + horizon,
    inset: 8pt,
    [LaTeX],
    ```latex
    \[ e^{-\frac{x^2}{3}} \]
    ```,
    grid.cell(rowspan: 2)[#set text(size: 1.5em); $ e^(-x^2 / 3) $],
    grid.hline(stroke: 0.25pt),
    [Typst],
    ```typst
    $ e^(-x^2 / 3) $
    ```,
  ),
)

Still in development, Typst is more than enough for our use cases:
- simple math typesetting, much like on WebWork;
- no more `\begin{hell} \backslash \end{hell}`;
- fast compilation, typically in milliseconds;
- friendly manual, function signature and error messages;
- yes, a _fully functional_ #link("https://myriad-dreamin.github.io/tinymist")[language server]: completion, preview and many more;
- integration with your favorite text editor;
- a modern, free and collaborative #link("https://typst.app")[online editor];
- easy customization by user, relative to LaTeX.

#counter(page).update(0)
#set page(numbering: "1")

#outline(depth: 2)

= Getting Started <sc:start>
You have two options: working online or local. Since this is a "group project" template, you probably want to work online for collaboration. Here is a step-by-step guide to get you started.

+ #link("https://typst.app")[Sign up] for an account of the Typst web app.
+ Follow guides and explore a bit.
+ (Optional) Assemble a team.
  + Dashboard → (top left) Team → New Team.
  + Team dashboard → (next to big team name) manage team → Add member.

Voilà! You are ready to start your math group project.

== Instructor: Initializing a Group Project
To start a math group project in the web app, simply
+ go to the project dashboard;
+ next to "Empty document", click on "Start from a template";
+ search and select "lacy-ubc-math-project";
+ enter your own project name, create, that easy!

In the project just initialized, you will see two files: `config.typ` and `project-1.typ`.

You will likely focus on editing `project-1.typ` for actual questions.
The `config.typ` file can contain group and theme information that are likely more useful to students. You may also edit and distribute that for reusable theme configuration.

=== `project-1.typ`
A basic start of project looks like
```typst
#import "@preview/lacy-ubc-math-project:0.2.0": *
#import "config.typ": * // Import the config.
#show: setup.with( //...
```

When you create more project files like `project-2.typ`, `project-3.typ`, copy these topmost two ```typc import```'s and ```typc show```.
Below this ```typst #show: setup.with( /*...*/ )``` is your project content.

== Student: Using a Group Project
Given a project file, populated with typed questions, you may simply insert ```typc solution()``` where fit, and start solving.
Do not forget to surround elements of a solution with (), if there are more than one; and insert commas between elements.
#showcode(
  dir: ttb,
  ```typst
  #qns(
    question(
      [What is $1 + 1$?], // ← append a comma, if absent
      solution[It is 2.] // Make sure it is inside the question you are answering to.
    ),
    question(
        [Good, now solve $integral_0^pi sin(x) dd(x)$.],
        solution[
          Ah yes, this is a classic application of the Quantum Turnip Theorem, which tells us that for any integral involving sine, the approach is to first change variables into invisible ducks.
        ]
    )
  )
  ```,
)

If the project is provided with a corresponding `config.typ`, consider if it conflicts with yours, if any.

= Learning Typst
Yes, you do have to learn it, but it is simple (for our purpose).
Consult the #link("https://staging.typst.app/docs")[Typst documentation], maybe the #link("https://sitandr.github.io/typst-examples-book/book/about.html")[Typst Examples Book] even if they say "don't rely on it."

#link("https://typst-doc-cn.github.io/guide/FAQ.html")[There] is a collection of frequently asked, miscellaneous techniques which many find extremely helpful.
That is, if you read Chinese...I guess web translation also works.

= Setup <sc:setup>
In ```typc setup()```, we define the project details, including the title, group name and authors.
```typst
#show: setup.with(
  title: [The Project Title],
  group: [The Group Name],
  // The following are from config.typ, keep reading to find out how.
  jane-doe,
  san-zhang,
  // more authors...
)
```
By default, they are displayed like:
#{
  internal.components.visualize-project-head(
    config: defaults,
    [The Project Title],
    [The Group Name],
    author("Jane", "Doe", 31415926),
    author(
      "San",
      "Zhang",
      27182818,
      config: (author: (name-format: (f, l, ..s) => [*#l*#lower(f)])),
    ),
    //SOURCE: https://en.wikipedia.org/wiki/List_of_placeholder_names
    author("Fulan", "AlFulani", 31415926),
    author(
      "Hanako",
      "Yamada",
      27182818,
      config: (author: (name-format: (f, l, ..s) => [*#l* #f])),
    ),
  )
}
<ex:head>

These title and authors given to ```typc setup()``` are also saved to PDF metadata, which is reflected in the PDF document properties.

/ Caveat: At this point, only one name format, "first last", is in the defaults. Contribution is welcome.
  But, how could Zhangsan and Yamada Hanako work-around their name display? See #link(<sc:custom-name>)[Advanced: Custom Name Format].

== Reusable Content
Since one group can take on multiple projects, it is wise to save common features like the members' information and the group name for multiple uses.

The `config.typ` file is a place to store such data.
After the ```typst #import "config.typ": * ```, every variable in the file will be visible to you.
Looking into the template's `config.typ`, it has
```typst
#let jane-doe = author("Jane", "Doe", 31415926)
```
which is why we could simply type `jane-doe` in the previous example and pass the full author information.

== Student: Author
The `author` function produces an author object, like above.
Give it your first name, given name, as the first argument (```typc "Jane"```), and your last name, family name, surname, as the second argument (```typc "Doe"```); finally, your student number as the third argument (```typc 31415926```).

In MATH 100/101 group projects we will suffix "NP" to a student's name if they are not present.
Assume Jane Doe is absent for the project, simply put
```typst
#show: setup.with(
  // ...
  jane-doe[NP]
)
```

= Math <sc:math>
Formatting math equations is probably the reason you are here.
#(
  (
    "E = m c^2",
    "e^(i pi) = -1",
    "(-b plus.minus sqrt(b^2 - 4a c)) / (2a)",
  )
    .map(eq => [
      #showcode(raw("$" + eq + "$", lang: "typst", block: true))
    ])
    .join()
)
A space is required to display consecutive math letters, like ```typst $m c^2$``` for $m c^2$.

This package has you covered on some common multi-letter operators:
#showcode(```typst
Inline math:
$lim_(x->oo), limm_(x->oo)$
$sum_(i=1)^n, summ_(i=1)^n$

Block/display math:
$
  lim_(x -> oo) \
  sum_(i = 0)^n \
  dd(t), dv(,x), dv(y,x)
$
```)

/ Caution: Though you can, and sometimes want to use block style in inline math, be aware that bigger math expressions occupy more vertical space, separate or overlap with surrounding texts.

For "block" or "display" math, leave a space or newline between _both_ dollar signs and the equations.
#showcode(```typst
$ E = m c^2 $
```)

To break a line in math, use a backslash "\\".
To align expressions in display math, place an "&" on each line where you want them to align to; you may even use multiple "&"s to align equations that are too long to stay in one part.
#showcode(```typst
$
  x + y &= z \
  &= v \
  // place '&'
  // anywhere appropriate
  x = w - y&
$
```)

Documented are the built-in #link("https://staging.typst.app/docs/reference/math/")[math functions] and #link("https://staging.typst.app/docs/reference/symbols/sym/")[symbols]

== Texts In Math
To display normal text in math mode, surround the text with double quotes function.
#showcode(```typst
$x = "We are going to find out!"$
```)

If you are to display units, see #link(<sc:unify>)[Units and Quantities].

For non-unit, single-character normal text, use ```typc upright()```.
#showcode(```typst
$U upright(W) U$
```)

There are other text styles available in math mode.
#showcode(```typst
$serif("Serif") \
sans("Sans-serif") \
frak("Fraktur") \
mono("Monospace") \
bb("Blackboard bold") \
cal("Calligraphic")$
```)

== Numbering and Referencing Equations
Note that you must enable equation numbering to reference equations, which this template does. Attach a ```typm #<label>``` right after the equation you wish to reference.
#showcode(```typst
$
  e^(i pi) = -1 #<eq:euler>
$
@eq:euler is Euler's identity. \
#link(<eq:euler>)[The same reference],
```)

== Extra Math Symbols and Functions
The `physica` package provides additional math symbols and functions.
#showcode(```typst
$A^T, curl vb(E) = - pdv(vb(B), t)$
```)

#showcode(```typst
$tensor(Lambda,+mu,-nu) = dmat(1,RR)$
```)

#showcode(```typst
$f(x,y) dd(x,y)$
```)

It is imported by this template.

== Units and Quantities <sc:unify>
Although no as common as in physics, we do sometimes need to use units and quantities.
Directly typing the 'units' will not result in correct output.
#showcode(```typst
$1 m = 100 c m$
```)
#showcode(```typst
$N = k g m s^(-2)$
```)

This template uses the `unify` package for this purpose.
If you prefer, you can also import and use the `metro` package.
#showcode(```typst
$qty("1", "m") = qty("100", "cm")$
```)
#showcode(```typst
$unit("N") = unit("kg m s^(-2)")$
```)

As you see, the ```typc qty()``` and ```typc unit()``` functions correct the numbers, units and spacing.

/ Caution: `unify` does not support content as arguments, so your math content should be made `str` before passing to the quantity and unit functions. \
  The following will not work:
  #align(
    center,
    ```typst
    $qty(3, Ohm)$
    ```,
  )
  Instead, wrap both the number and the unit in double quotes to make them `str`:
  #showcode(```typst
  $qty("3", "Ohm")$
  ```)


= Question
The `question` function is to create a question object. <ex:qs-block>
#showcode(
  wrap: "qns",
  ```typc
  question(
    [The question.],
    question(
      point: 1,
      label: "special",
      [Sub-question.]
    ),
    question(
      [Another sub-question.],
      question(
        point: 1,
        [Sub-sub-question.],
      ),
      question(
        point: 2,
        [Another sub-sub-question.],
      )
    )
  ),
  ```,
)

The "4 points" and "3 points" question above had no point specified: parent questions get the sum of their children questions' points, if their own `point` is left blank.

== Referencing Questions
The recommended way is as in the #link(<ex:qs-block>)[example above], provide a `label` argument, and then you can refer to it using
#showcode(```typst @qs:special```)
If provided with a `str`, the label created will automatically have a head, "qs:", for clarity.
Otherwise, nothing is added and you will get what you put in.

For alternative reference text, use the `ref` syntax sugar
#showcode(```typst @qs:special[This special one.]```)
or the full syntax
#showcode(```typst
#ref(
  <qs:special>,
  supplement: [This special one.]
)
```)

When a `label` is not provided, this template does attach one for you, based the question number.
However, such numbers can easily vary, set a special label for stability.
#showcode(```typst @qs:1-b-ii```)

= Solution
The `solution` function is to create a solution object.
#showcode(
  dir: ttb,
  wrap: "qns",
  ```typst
  question(
    [Shall I pass MATH 100?],
    solution(
      [You shall #strike[not] pass!],
      // Change target and supplement
      solution(
        target: <qs:special>,
        label: "pass",
        supplement: [*Response to a distant question:*\ ],
        [You can target any question, or even `none`. How cool!]
      )
    ),
  )
  ```,
)

A solution is does not need to be in a question.

== Referencing Solutions
Similar to the questions, you may provide solutions with unique label in order to reference them.
They are not automatically labelled.
#showcode(```typst
@sn:pass \
@sn:pass[Pass.]
```)

Note that, when a solution does have a target question, the default reference text contain a link to the question as well.
Hence, if you click on the part after "to...", it jumps to the question instead of the solution.

However, those with custom supplement refer to only the solution.

= Config
There is a default config, `defaults`, and a `config` that you import from `config.typ`, suppose you followed the template.

For the configs you give, the first to the last and one by one, the latter's entries replaces the former's in case of duplication.
The "zero-th" config is `defaults`.

A set of config is called a theme.
The package has a `theme` module, which of course contains built-in themes; PR is welcome!

To apply a theme, simply put
```typc
setup.with(
  // ...
  config: theme.ubc-light, // Obviously, a UBC package comes with UBC themes.
)
```

To merge your own config with the theme, and let your config take priority,

```typc
setup.with(
  // ...
  config: (
    theme.ubc-light,
    config, // The latter's entries replace the formers!
  )
)
```

Besides, you can pass configs to individual components of this package, such as `author`, `question` and `solution`.
They need the full config, not just their respective entry.
In addition, components in the `qns` wrapper will pass their config down to children components.

== Built-in Themes
Besides the default theme, there are:
#(
  dictionary(theme)
    .keys()
    .zip((
      [
        A small dose of UBC theme colors based on #link("https://assets.brand.ubc.ca/downloads/ubc_brand_identity_rules.pdf")[UBC Brand Identity Rules]
      ],
      [The same idea, but colors are switched for dark mode.],
    ))
    .map(((t, d)) => terms((raw(t), d), tight: false))
    .join()
)

= Drawing
Typically, you would not want to commit time and effort to learn drawing in Typst. Have your graphs done in Desmos, GeoGebra, or whatever, then display images of them.
```typst
#image("template/assets/madeline-math.jpg", width: 6cm)
```
#image("template/assets/madeline-math.jpg", width: 6cm)

Note that Typst cannot reach beyond the project root directory, so put your assets inside the project folder.

== Instructor: Drawing in Typst
Typst has native drawing capability, but quite limited.
There is an ad hoc Typst drawing library, a package actually, called "cetz".

In this template,
```typst
#import drawing: *
```
to make `cetz` and other drawing helpers available.

For data visualization, use #link("https://lilaq.org/")[lilaq].
For generic drawing, use #link("https://cetz-package.github.io/docs/")[cetz].
For generic plotting, use #link("https://github.com/cetz-package/cetz-plot/blob/stable/manual.pdf?raw=true")[cetz-plot].

There are other drawing packages available, but not included in the `drawing` module, here is a brief list:
- #link("https://staging.typst.app/universe/package/fletcher")[fletcher]: nodes & arrows;
- #link("https://staging.typst.app/universe/package/jlyfish")[jlyfish]: Julia integration;
- #link("https://staging.typst.app/universe/package/neoplot")[neoplot]: Gnuplot integration.

Find more visualization packages #link("https://staging.typst.app/universe/search/?category=visualization&kind=packages")[here].

=== Instructor: Template Helpers
The `drawing` module has its own drawing helpers.
For example, the `cylinder()` function draws an upright no-perspective cylinder:
#showcode(```typst
#import drawing: *
#cetz.canvas({
  import cetz.draw: *
  group({
    rotate(30deg)
    cylinder(
      (0, 0), // Center
      (1.618, .6), // Ellipse radius
      2 / 1.618, // Height
      fill-top: gradient.linear(
        black.lighten(50%),
        black.lighten(95%),
        white,
        angle: -60deg
      ), // Top color
      fill-side: blue.transparentize(80%), // Side color
    )
  })
})
```)

== Example
Below is a more elaborate drawing.
#[
  // Import the drawing module for drawing abilities.
  #import drawing: *
  #figure(
    caption: [Adaptive path-position-velocity graph],
    cetz.canvas({
      import cetz.draw: *
      import cetz-plot: *
      // Function to plot
      let fx = x => -calc.root(x, 3)
      // Derivative of the function
      let fdx = x => -calc.pow(calc.root(x, 3), -2) / 3
      // Linear approximation of the function
      let la-fx = (x, a) => fdx(a) * (x - a) + fx(a)
      // plot → canvas transformation
      let ts = (x, y) => (x + 1, y).map(c => c * 2)

      // Plot the function (object path)
      plot.plot(
        size: (4, 4),
        axis-style: none,
        name: "path",
        {
          plot.add-anchor("left", (-1, 0))
          plot.add(
            domain: (-1, 1),
            fx,
            style: (stroke: (paint: red, dash: "dashed", thickness: 1.2pt)),
          )
        },
      )
      // Canvas origin set to (-1, 0),
      // size is 4 * 4, which is 2 times of plot (domain, range) = (2, 2),
      // hence the transformation is (x + 1, y) * 2
      set-origin("path.left")
      // Draw cylinder laying
      group({
        rotate(90deg)
        cylinder((0, 0), (2, 1), 4cm, fill-side: blue.transparentize(90%), fill-top: blue.transparentize(80%))
      })
      // Draw object position and tangent line
      let x = 0.8 // Try changing this!
      let shift = 0.5
      line(
        ts(x, fx(x)),
        ts(x + shift, la-fx(x + shift, x)),
        stroke: purple,
        mark: (end: "straight"),
      )
      circle(
        ts(x, fx(x)),
        radius: 2pt,
        fill: purple,
        stroke: none,
      )
    }),
  )
]


#pagebreak(weak: true)

= Advanced
This part assumes familiarity of Typst.

== Feeder
There is a special component, `feeder`.
Like `question` and `solution`, it is used in `qns` and can contain children components.

However, its also takes a positional argument `proc`.
`proc` is an arbitrary function, the only requirement is that it should be able to take in all its components and named arguments: the components will first be "visualized", meaning converted to visual content, then passed to `proc` positionally; the named arguments of the `feeder` are passed as named arguments.

#showcode(
  wrap: "qns",
  ```typc
  feeder(
    table.with(
      columns: 2,
    ),
    stroke: blue,
    question[What can I know?],
    question[What should I do?],
    [What may I hope?]
  )
  ```,
)

== Internals
The `internal` module allows access to all internal variables---fields and functions that are not of the ordinary user interface.
#showcode(```typst
#repr(dictionary(internal))
```)

You can call all the internal functions, just read the friendly manual, a.k.a. the function signatures, or you would mess up.
#showcode(```typst
#internal.components.target-visualizer(
  <qs:special>,
  t => ref(t, supplement: repr(t))
)
```)

== Config

=== `defaults` Namespace
We already have the `defaults` dictionary, which looks like:
#defaults.pairs().slice(1, 3).to-dict()

The `internal.default` module is not the same, because the apparent `defaults` is just the `config` field of the `defaults` module, taking over the name.

=== Propagating Config
Since only the `config` field is taken when you provide a module as config, the process to make `config` or other variables in the module does not matter.
You are free to do whatever in your config file (then imported as a module) to propagate that config.

== Author

=== Special Name Content
In some (unlikely) cases, one's name cannot be converted to plain text.
Take #underline(text(fill: purple)[Ga])#strike[*_lli_*]#overline($cal("leo")$) as an example. The name is so special that it cannot be converted to plain text. You may provide a `plain` version of it to avoid incomprehensible PDF metadata.
```typc
author(
  [#underline(text(fill: purple)[Ga])#strike[*_lli_*]#overline($cal("leo")$)],
  "Smith",
  12345678,
  plain: "Gallileo Smith"
)
```

=== Custom Name Format <sc:custom-name>
The `author` function accepts a `config`, in which the format of name, affixes, containers and show rules are defined.
Namely, #defaults.author.keys().map(k => raw(k)).join(", ", last: [ and ]).

We are particularly interested in `name-format`, because not all names follow the English style.
```typc
  author(
    "San",
    "Zhang",
    27182818,
    config: (author: (name-format: (f, l, ..s) => [*#l*#lower(f)])),
  ),
```

The `name-format` function is called with a first name and a last name (for now, that is why we leave an `..s` to sink potentially more parameters for compatibility), and is supposed to produce the formatted name.

By default it is ```typst[#first *#last*]```, above we change it to a more conventional Chinese name format, and #link(<ex:head>)[so it looks].
