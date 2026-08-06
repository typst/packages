#set document(title: "typst eggs documentation")
#let version = "0.9.0"

#import "eggs.typ": abbreviations, example, gloss, judge, trailing, subexample, eggs, abbreviation, print-abbreviations, ex-label, ex-ref
#import "@preview/tidy:0.4.3"

#show: eggs

#set heading(numbering: "1.")
#show heading.where(level: 1): set block(above: 2em, below: 1em)
#show heading.where(level: 2): set block(above: 1.7em, below: 1em)
// #show: tidy.render-examples.with(scope: (example: example, gloss: gloss, subexample: subexample, judge: judge,))
#show link: underline

#let code-ex(contents, output: true) = {
  set text(size: 0.9em)

  let kwargs = contents.fields()
  let text = kwargs.remove("text").replace("{version}", version)
  let contents = raw(text, ..kwargs)

  block(stroke: 1pt + luma(140), inset: (left: 8pt, right: 8pt, top: 10pt, bottom: 12pt), width: 100%, breakable: false, radius: 5pt)[
    #contents
    #if output {[
      #line(length: 100%, stroke: 1pt + luma(140))
      #eval(
        text,
        mode: "markup",
        scope: (eggs: eggs, example: example, gloss: gloss, subexample: subexample, judge: judge, trailing: trailing, abbreviations: abbreviations, abbreviation: abbreviation, print-abbreviations: print-abbreviations, ex-label: ex-label, ex-ref: ex-ref)
      )
    ]}
  ]
}

#let nb = it => [
  *N.B.* #it
]

#v(6em)
#align(center, par(spacing: 1.5em, text(size: 3em)[Eggs]))
#align(center, text(size: 1.2em)[Linguistic examples with minimalist syntax])
#align(center, text(size: 1em)[Version #version])
#v(1.5em)
#align(center, text(size: 1.2em)[#datetime.today().display("[month repr:long] [year]")])
#align(center, text(size: 1.2em)[https://github.com/retroflexivity/typst-eggs])
#v(5em)

Eggs is a Typst package for typesetting linguistic examples. Its aim is to provide a Typst analogue to LaTeX `gb4e`, `expex`, `linguex`, etc. Additionally, it ships with `leipzig`-style gloss abbreviations.

This is a documentation on Eggs. It begins with a review of features, then discusses several tips and tricks, and closes with providing an extensive list of functions and their arguments.

#pagebreak()

= Initialization

To use Eggs, first import it, and then set its config via a global show rule.
#footnote[
  This package follows Typst's tradition of not abbreviating function names too much. Naturally, to achieve more effortless (or TeX-like) experience, you can set some aliases on import, e.g.

  #code-ex(
    ```typst
    #import "@preview/eggs:{version}": example as ex, subexample as subex, judge as j, ex-label as el, ex-ref as er
    ```,
    output: false
  )
]

#code-ex(
  ```typst
  #import "@preview/eggs:{version}"
  #show: eggs
  ```,
  output: false
)

This same function is used to configure Eggs' settings. See @customization.

= Examples

The primary function of Eggs is `example`. It accepts any `content` and typesets it as a single top-level linguistic example.

#code-ex(
  ```typst
  The sentence below demonstrates the reading known as specificational.
  #example[
    The primary function of Eggs is `example`.
  ]
  The semantics of the DP to the left of _is_ has been an object of much debate.
  ```
)

Examples are automatically numbered continuously, using a #link("https://typst.app/docs/reference/introspection/counter/")[counter] called "eggsample". The counter's first level numbers examples, the second numbers subexamples. To override automatic numbering, pass the `number` argument to an example or subexample. Examples with a custom number do not increment the counter, so numbering continues where it was left off.
#code-ex(

  ```typst
  The idea of Predicate Inversion stems from the seeming parallelism of the following sentences.
  #example[
    `example` is the primary function of Eggs.
  ]
  #example(number: 1)[
    The primary function of Eggs is `example`.
  ]
  ```
)

The counter can also be set to an absolute value with ```typst #counter("eggsample").update(n)``` or a relative one with ```typst #counter("eggsample").update(it => it + n)```. Within an example, the subexample counter can be set by passing a function that preserves the counter's first value, e.g. ```typst #counter("eggsample").update(it => (it.at(0), n)) ```. Following examples will be numbered starting with the next integer.

By default, examples in each footnote are numbered separately. They also use their own formatting. The following footnote#footnote[
  Examples in footnotes use a separate counter, `fn-eggsample`, which is set to 0 at the beginning of each footnote.
  #code-ex(
    ```typst
    But note the contrast in availability of indefinites.

    #example[
      `example` is the/a function of Eggs.
    ]
    #example[
      The/??a function of Eggs is `example`.
    ]
    ```
  )
] demonstrates this.

= Subexamples <subexamples>

Numbered lists inside examples (lines that begin with `+ `) are automatically typeset as subexamples.

#code-ex(
  ```typst
  Compare the following sentences, of which only the former exhibits the Definiteness Effect.
  #example[
    + There is a/\*the subexample.
    + Here is a/the subexample.
  ]
  ```
)

In case you prefer it manual, the function `subexample` is defined. It is intended to only be used inside an example. It behaves pretty similarly to `example` (e.g. accepts `number`).

Automatic conversion of numbered lists can be toggled off by setting ```typst auto-subexamples: false``` in the config (see @customization). To suspend it for a single example, pass ```typst auto-subexamples: false``` to the example directly.

#counter("eggsample").update((..it) => it.at(0) - 1)
#code-ex(
  ```typst
  Compare the following sentences, of which only the former exhibits the Definiteness Effect.
  #example(auto-subexamples: false)[
    #subexample[There is a/\*the subexample.]
    #subexample[Here is a/the subexample.]
  ]
  ```
)

== Customizing how subexamples are displayed

By default, automatic subexamples are simply placed one after another. This can be changed by passing or setting `subexample-wrapper`. A wrapper is a function that accepts any number of `content` elements and returns `content` constructed from them.

A simple and common use case is to align subexamples horizontally using a #link("https:typst.app/docs/reference/layout/grid")[grid].

#code-ex(
  ```typst
  Unfortunately, according to the conference guidelines, in this abstract, our space is limited to two pages. Consequently, to be able to fit everything included in our agenda, we will try to save as much space as possible by aligning subexamples horizontally instead of, how it is usually done in linguistic papers, vertically.

  #show: eggs.with(subexample-wrapper: grid.with(columns: 5))

  #example[
    + This is also a subexample.
    + This, too, is a subexample.
    + This is a subexample, too.
  ]
  ```
)

= Glosses <glosses>

Bullet lists in examples (lines that begin with `- `) are automatically treated as interlinear gloss lines.

Lines are split into words on simple spaces (any number of them).#footnote[The exception is formatted content (e.g. _emph blocks_): it is never split.] For spaces you don't want to be treated as word separators, use `~` (non-breaking space).

Translations and preambles are written as lines below and above the list, respectively.

#code-ex(
  ```typst
  The following example presents the Russian _eto_-construction.
  #example[
    Russian
    - Jajca eto   vkusno.
    - eggs  this            tasty
    'Eggs are tasty.'
  ]
  ```
)

Glosses can by typeset manually with `gloss`. It accepts either a content, which it splits automatically, or a list. Automatic bullet list conversion can be toggled off by setting ```typst auto-glosses: false``` in the config (see @customization). To suspend it for a single example, pass `auto-glosses: false` to the (sub)example directly.

#counter("eggsample").update(it => it - 1)
#code-ex(
  ```typst
  The following example presents the Russian _eto_-construction.
  #example(auto-glosses: false)[
    Russian
    #gloss(
      [Jajca eto vkusno.],
      ([eggs], [this], [tasty]),
    )
    'Eggs are tasty.'
  ]
  ```
)

= Judges

Certain strings at the beginning of a line or a gloss word (see @glosses) are automatically transformed into left judges. Left judges are negatively padded strings that take up no space.

By default, such strings are `*`, `#`, `?`, `OK`, and all combinations of these. All except the asterisk are also superscripted. Spaces after a judge are omitted for readability.

#code-ex(
  ```typst
  The following pair shows the information-structural rigidity of specificational sentences.
  #example[
    + OK SMITH is the killer.
    +  \*THE KILLER is Smith.
  ]
  ```
)

This can be modified by tweaking `auto-judges` in the config (see @customization) or by passing it to an example directly. `auto-judges` takes a dictionary where keys are the strings to treat as judges and values indicate whether to additionally superscript them. For instance, if you would like to make hashes and question marks non-superscripted, try ```typc auto-judges: ("*": false, "#": false, "?": false, "OK": true)```. Use `auto-judges: (:)` to disable the automatic conversion completely.

Again, a function `judge` is provided to typeset judges manually. These should be superscripted manually, too, and following spaces are not omitted.

#counter("eggsample").update(5)

#code-ex(
  ```typst
  The following pair shows the information-structural rigidity of specificational sentences.
  #example(auto-judges: ())[
    + #judge(super[OK])SMITH is the killer.
    + #judge[\*]THE KILLER is Smith.
  ]
  ```
)

= Abbreviations

Eggs provides the whole set of #link("https://www.eva.mpg.de/lingua/resources/glossing-rules.php")[Leipzig Standard Abbreviations] as commands, in the style of TeX's `leipzig`. They are imported from the `abbreviations` subpackage.

All abbreviations are in lowercase. All abbreviations' names are as they appear, except for:
- *1, 2, 3* are `p1`, `p2`, `p3`;
- *#smallcaps[n]* (as the non- prefix) is `non`;
- *#smallcaps[top]* is `top_`, due to conflicting with Typst's built-in `top` alignment;
- *#smallcaps[int]* is `int_`, due to conflicting with Typst's built-in `int` type.

#code-ex(
  ```typst
  #import abbreviations: ins, pst, n

  Note that the famous temperature examples forbid Instrumental in Russian.
  #example[
    - \*Temperatur-oj  byl-o        10~gradusov.
    - weather-#ins             be-#pst\-#n  10~degrees
  ]
  ```
)

Custom abbreviations can be created by defining a new `abbreviation`.

#code-ex(
  ```typst
  #let eto = abbreviation("eto", "an extremely polysemous expression")

  Due to the polysemy _eto_ exhibits, I will gloss it simply as #eto.
  #example[
    - Eto   čto   za   primer?
    - #eto  what  for  example
    'What's this example?'
  ]
  ```
)

The list of currently used abbreviations is stored as a dictionary of the form `abbr: description` inside the `used-abbreviations` state. Eggs exposes the function `get-abbreviations` to access the final list of abbreviations (must be used inside ```typc context```).

There is also a convenient function to print the list. It is printed as an alphabetically sorted #link("https://typst.app/docs/reference/model/terms/")[term~list] by default.

#code-ex(
  ```typst
  The list of glossing abbreviations used in this paper:
  #print-abbreviations()
  ```
)

The formatting can be completely overriden by passing `sorted-by` (controls how abbreviations are sorted), `wrapper` (controls how every entry is printed), and `separator` (controls what is printed between the entries). The following example demonstrates an inline list, separated by a comma, sorted by the order of use.

#code-ex(
  ```typst
  The list of glossing abbreviations used in this paper:
  #print-abbreviations(
    sorted-by: (_, _) => true,
    wrapper: (abbr, desc) => [#smallcaps(abbr) = #desc],
    separator: ", "
  )
  ```
)

= Labels and refs

There are two ways of labelling an example (or a subexample). The first is passing the `label` argument to `example` (or `subexample`). The second is placing an `ex-label` anywhere in the body of the example (or a subexample), preferably at the beginning or at the end. Typst's built-in `label` does not work for now.

If a subexample doesn't have a label but its parent does, an automatic #link("https://typst.app/universe/package/codly")[codly]-style label of the form `<top-label:subex-letter>` is added automatically.

#code-ex(
  ```typst
  The curious minimal pair in terms of scope in @pair is taken from Arregi et al. (2021). Only @pred has a narrow scope reading of the indefinite.
  #example[
    #ex-label(<pair>)
    + OK Kim is not one of the judges. #ex-label(<pred>)
    + \#One of the judges is not Kim.
  ]
  @pair:b is pragmatically odd, but becomes better if Kim is replaced with something that can exist in multiple places at once @ok. The argument loses in convincibility, though.
  #example(label: <ok>)[
    OK One of the judges is not "OK".
  ]
  ```
)

References to examples are automatically enclosed in parentheses. Citing two examples together is possible by inserting the second reference as the supplement, in square brackets after the first one. When the second reference is to a subexample, the superexample number is collapsed.

#code-ex(
  ```typst
  Recall the discussion concerning examples @pair[@ok]. Despite the Russian data, we should not ignore the minimal pair in @pred[@pair:b].
  ```
)

A dedicated function, `ex-ref`, is also provided. It accepts from 1 to 2 references, but also
- integers for relative numbering, with `0` referring to the last example, `1` to the next, etc.
- `left` and `right` positional arguments for content to appear in the parenthesis before and after example numbers.

#code-ex(
  ```typst
  Despite the Russian data, we should not ignore the minimal pair in #ex-ref(<pred>, <pair:b>). There is much more to the story #ex-ref(left: "e.g. ", 1, right: " etc.").

  #example[
    + Only "?" is one of the judges.
    + One of the judges is only "?".
  ]
  ```
)

`smart-refs: false` can be passed to the configuration to disable automatic reference decoration.

= Trailing citations

A simple function `trailing` allows printing content at the end of a line, moving it to the next line if it does not fit. This is how sources and comments are usually typeset in linguistic examples.

#code-ex(
  ```typst
  #example[
    + Jones is a Jones.#trailing[(Burge 1973)]
    + This entity called 'John J. Jones Jr.' is necessarily an entity called 'John J. Jones Jr.'.\ #trailing[(Burge 1973, adapted to make the line even longer)]
  ]
  ```
)

The function accepts the `gap` parameter for customizing the minimum space allowed between the end of the line and the trailing content. The larger the gap, the more often the content will move to the next line. The default is ```typc 1.5em```.

#nb[The function does not support gloss lines. If you need to align some content to the right of interlinear glosses, please use a grid.]


= HTML output <html>

Eggs has fully custom support for HTML output. Currently, Typst's HTML output is purely semantic (adds no styling); but since there are no semantic primitives in HTML that correspond to linguistic examples, glosses, and everything else, Eggs takes a different approach and provides inline styling for HTML elements that more or less mimics the PDF output in appearance.

The structure of the HTML output is the following:

#[
#set raw(lang: "html")

- An example is a `<li>` (list item) of an `<ol>` (enumerated list). Since Typst does not support collapsing, every example is in its own `<ol>`. The default marker is hidden, and there is a `<span>` inside `<li>` that shows the marker, in order to control spacing. Consequently, the `<li>` is a flexbox and the body is a `<div>`.

- A subexample is almost the same, but with collapsing of the list: there is a single `<ol>` that wraps the whole contents of an example if it has any subexamples.#footnote[As such, it also wraps around everything that goes before or after subexamples in the example. It is a bug.]

- Interlinear glosses are a flexbox of horizontal grids of `<span>`s (words), or tables, depending on the value of `gloss-html-table`.

- Judges are `<span>`s with ```scss position: absolute``` and ```scss transform: translateX(-100%)```.

- Trailings are `<span>`s with `float: right`.#footnote[Ironically, they're much cleaner and easier to implement in HTML than in PDF Typst.]
]

== Controlling the amount of styling

The amount of inline styling applied can be changed using the `html-styling` setting (see @customization). It accepts one of the following:

/ `"full"` (default): All of the styling.

/ `"basic"`: "Contentful" changes only. These are: (sub)example marker formatting (changing the default marker, not adding the new one); flexboxes with grids for glosses; judge padding; trailing citation floating.

/ `"none"`: No use of HTML `style` at all.

Furthermore, as mentioned above, the `gloss-html-table` can be set to ```typc true``` in all styling levels to use a table for glosses.

#nb[Inline styles in HTML cannot be overriden. This is why you might like to decrease the styling level if you are using a comprehensive stylesheet.]

== The state of the feature

HTML support in Typst is experimental, and so it is in Eggs. The known issues are listed below.

- `gloss-hanging-indent` for glosses is not supported and ignored;
- `subexample-spacing` and `gloss-before-spacing` add margins above subexamples and glosses even at the beginning of an example. This makes them misaligned with the example number. This is why you probably do not want to use them;
- Typst vertical spacing and HTML margins are calculated differently. This difference is mitigated by substracting the default leading (```typc 0.65em```) from all vertical spacing when compiling to HTML. This might lead to strange results in some cases.

= Customization <customization>

Eggs offers some layout and styling customization and several behaviour options. The complete list is given in @funcs.

There are several ways of customizing the package options. The primary one is passing arguments to `eggs` in a global show rule.

#code-ex(
  ```typst
  #show: eggs.with(
    indent: 2.5em,
    body-indent: 2.5em,
    sub-indent: -0.3em,
    sub-body-indent: 1.7em
  )

  The examples in this part all imitate Higgins' (1973) original layout.
  #example[
    + What John also is is enviable.
    + What John also is is also enviable.
  ]

  #example[
    What I am pointing at is a kangaroo.
  ]
  ```
)

To change Eggs' config temporarily, you can scope the show rule or simply pass some content to `eggs`. Passed parameters are applied on top of the old configuration, so any parameters set earlier that are not overridden are preserved.

#counter("eggsample").update(it => it - 2)

#code-ex(
  ```typst
  #eggs(indent: 2.5em, body-indent: 2.5em, sub-indent: -0.3em, sub-body-indent: 1.7em)[
    The following examples imitate Higgins' (1973) original layout.
    #example[
      + What John also is is enviable.
      + What John also is is also enviable.
    ]
    #example[
      What I am pointing at is a kangaroo.
    ]
  ] // this ends the scope of eggs
  Compare #ex-ref(0) with itself but in the default layout.
  #counter("eggsample").update(it => it - 1)
  #example[
    What I am pointing at is a kangaroo.
  ]
  ```
)

To override the configuration for a single example, you can also pass the options to it directly. However, note that options are split among Eggs' functions: if you want to customize subexample or gloss options, you have to pass those to the functions directly (without prepending `sub-` or `gloss-`).

#counter("eggsample").update(it => it - 2)

#code-ex(
  ```typst
  The following example imitates Higgins' (1973) original layout.
  #example(indent: 2.5em, body-indent: 2.5em)[
    #subexample(indent: -0.3em, body-indent: 1.7em)[What John also is is enviable.]
  ]
  ```
)

Finally, since Eggs is powered by #link("https://typst.app/universe/package/elembic")[Elembic], you may apply #link("https://pgbiel.github.io/elembic/elements/styling/set-rules.html")[its set rules] to the elements `example`, `subexample`, and `gloss`. #link("https://pgbiel.github.io/elembic/elements/styling/show-rules.html")[Elembic's show rules] can also be used to style example contents in an arbitrary way.

= How-to's

Eggs strives to stay simple, in the sense that it does not convolute the syntax with non-Typst constructs, and does not add marginal functionality that is easy to implement on one's own.

Below is a partly community-maintained#footnote[Feel free to suggest your own!] list of tips that might be useful for typesetting examples, but are not part of Eggs' core functionality.

== Align content between subexamples

Say you want to include some phonological processes, with arrows aligned. An easy way is to define a function that draws a single-line grid, then place it in every subexample.

#code-ex(
  ```typst
  // provide some default width for the left column
  #let phono-grid(ur, sr, ur-width: 4em) = grid(
    columns: (ur-width, auto, auto),
    gutter: 1em,
    ur, $->$, sr
  )

  #example[
    // override the width if UR doesn't fit
    #let phono-grid = phono-grid.with(ur-width: 5em)
    + #phono-grid([/mi-te-iru/], [[miteiru]])
    + #phono-grid([/kiri-te-iru/], [[kitteiru]])
  ]
  ```
)

A more sophisticated function can include splitting the content automatically and measuring the width of an element. You can then use it as a subexample wrapper (see @subexamples).

#code-ex(
  ```typst
  #import "@preview/elembic:1.1.1" as e
  // accept a list of subexamples
  #let phono-grid-wrapper(..args) = {
    // get the first and the last children of every row, insert arrow in between
    let lines-split = args.pos().map(it => {
      // get the elembic element's body
      let children = e.fields(it).body.children
      (children.at(0), $->$, children.at(-1))
    })
    // align the first column by the widest UR
    let ur-width = calc.max(..lines-split.map(it => measure(it.at(0)).width))
    for line-split in lines-split {
      // reassemble the subexample
      subexample(grid(
        columns: (ur-width, auto, auto),
        gutter: 1em,
        ..line-split
      ))
    }
  }

  #example(subexample-wrapper: phono-grid-wrapper)[
    + #[/mi-te-iru/] #[[miteiru]]
    + #[/kiri-te-iru/] #[[kitteiru]]
  ]
  ```
)

== Hide elements and pad under brackets in glosses

When typesetting glosses, it's common that you need to put a bracket next to the following word with no tabulation between them, but align the other lines with the word, not the bracket.#footnote[`expex` uses `@` and `\nogloss` for this.]

A clean way to do this is to add a hidden printed bracket with the built-in #link("https://typst.app/docs/reference/layout/hide/")[hide].

#code-ex(
  ```typst
    #let hb() = hide[\[]
    #example[
      - cet   exemple  a    [un     DP]
      - this  example  has  #hb()a  DP
    ]
  ```
)

In other cases, you may want to skip a word in some gloss line that is present in others. `hide` is good, but a simple non-breaking space (`~`) also suffices.

#code-ex(
  ```typst
    #example[
      - où     est  passé  le   mot   _t_  aujourd’hui
      - where  is   moved  the  word   ~   today
    ]
  ```
)

== Number examples by chapter

Package #link("https://typst.app/universe/package/headcount")[headcount] provides graceful numbering dependent on current chapter.

Unfortunately, using `ex-ref` (and smart refs) with Headcount is currently broken with cross-chapter references. This will probably be fixed when the next release of Elembic is dropped. For now, use \@-refs with `smart-refs` off.

#context {
  show heading: set text(size: 0.8em)
  show heading: set block(above: 1.4em)
  set heading(outlined: false)
  let heading-state = counter(heading).get()
  counter(heading).update(0)
  code-ex(
    ```typst
    #import "@preview/elembic:1.1.1" as e
    #import "@preview/headcount:0.1.1": *

    #show: eggs.with(
      smart-refs: false,
      auto-labels: false,
      // pass `level` if needed
      num-pattern: dependent-numbering("(1.1)"),
      ref-pattern: dependent-numbering("1.1a"),
      body-indent: 3em,
    )
    #show heading: reset-counter(counter("eggsample"))

    = Suppose we have a chapter here

    #example[
      and an example in the chapter #ex-label(<dep-counted>)
    ]

    We can refer to it like this #ex-ref(<dep-counted>) and like this #ex-ref(0).

    = And another here

    We should refer to that example like this (@dep-counted).
    ```
  )
  counter(heading).update(heading-state)
}

== Avoid escaping hyphens after abbreviations by defining a glossary

Typst recognizes hyphens (`-`) as part of a variable name. This requires one to escape hyphens that mark morpheme boundaries if they immediately follow a variable reference, which can be annoying.

It can be convenient to instead define _aliases_ for common morphemes that include the hyphen marker directly. This also has the advantage of working well with autocomplete if you have a large inventory of lexical entries.

#code-ex(
  ```typst
  #import abbreviations: p3, an, dur, pl, pro
  #let ai  = abbreviation("ai",  "animate intransitive")

  #let ann    = [that]
  #let iksi   = [-#p3#pl.#an]
  #let ponoka = [elk]
  #let a_dur  = [#dur\-]
  #let otsi   = [swim.#ai]
  #let yaawa  = [-#p3#pl=#pro]
  #let ohkan  = [#smallcaps[all]-]

  #example[
    + - ann-iksi   ponoka-iksi   á-otsi-yi=aawa
      - #ann#iksi  #ponoka#iksi  #a_dur#otsi#yaawa
      'Those elk are swimming.'

    + - ann-iksi   ponoka-iksi   á-ohkan-otsi-yi=aawa
      - #ann#iksi  #ponoka#iksi  #a_dur#ohkan#otsi#yaawa
      'Those elk are all swimming.'
  ]
  ```
)

== Add line notes within examples with term lists

Eggs overrides auto-numbered lists (`+`) and bulleted lists (`-`), so you can't use them to add notes in examples. However, #link("https://typst.app/docs/reference/model/terms/")[term lists] remain untouched. These are particularly useful when typesetting notes prefixed with the speaker's initials.

The look of term lists can also be modified using show rules.

#code-ex(
  ```typst
  #import "@preview/elembic:1.1.1" as e
  // style term lists inside examples only, with elembic
  #show: e.show_(example, it => {
    // show the term and the description separated by a semicolon
    show terms.item: it => [#it.term: #it.description\ ]
    it
  })

  #example[
    + - anníksi  ponokáíksi̥  #highlight[á]ótsiyaaw̥ḁ.
    / EY: When you talk about swimming, _á-_ is like "being in the moment of"
    / EY: The difference here is between "swimming" vs. "swim"
    / EY: 'Those elk swim' is a statement of fact... doesn't imply any particular time
  ]
  ```
)


= Complete function documentation <funcs>

#set heading(numbering: none)
#show heading.where(level: 2): set heading(numbering: "1.")
// hide "parameters"
#show heading.where(level: 3): none
#show pad: none
#show v.where(amount: 4.8em): v(2em)

#show list: it => {
  set par(spacing: par.leading)
  it
}
#set list(spacing: 1.5em, marker: rotate(90deg, "🥚"))

#show regex("^[a-z\-.]+\s\(([\w\"]+(\s\|\s)?)+\)"): it => {
  set text(font: "DejaVu Sans Mono", size: 0.8em)
  show regex("[\(\)]"): none
  show " ": h(0.3em)
  show regex("\(([\w+\"](\s\|\s)?)+\)"): it => {
    show regex("([\w+\"](\s\|\s)?)+"): it => {
      set text(fill: olive)
      [[#it]]
    }
    it
  }
  it
}

#let show-tidy = file => tidy.show-module(tidy.parse-module(read(file)), style: tidy.styles.default, show-outline: false, first-heading-level: 1, sort-functions: auto)

#show-tidy("src/config.typ")
#show-tidy("src/example.typ")
#show-tidy("src/gloss.typ")
#show-tidy("src/judge.typ")
#show-tidy("src/ex-label.typ")
#show-tidy("src/ex-ref.typ")
#show-tidy("src/abbreviations.typ")
