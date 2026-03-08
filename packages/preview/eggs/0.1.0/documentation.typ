#set document(title: "typst eggs documentation")
#import "eggs.typ": abbreviations, example, gloss, judge, subexample, eggs, abbreviation, print-abbreviations, ex-label, ex-ref
#import "eggs.typ": judge as j
#import "@preview/tidy:0.4.3"

#show: eggs

#set heading(numbering: "1.")
#show heading.where(level: 1): set block(above: 2em, below: 1em)
// #show: tidy.render-examples.with(scope: (example: example, gloss: gloss, subexample: subexample, judge: judge,))
#show link: underline

#let code-ex(contents, output: true) = {
    set text(size: 0.9em)
    block(stroke: 1pt + luma(140), inset: (left: 8pt, right: 8pt, top: 10pt, bottom: 12pt), width: 100%, breakable: false, radius: 5pt)[
      #contents
      #if output {[
        #line(length: 100%, stroke: 1pt + luma(140))
        #eval(
          contents.text,
          mode: "markup",
          scope: (eggs: eggs, example: example, gloss: gloss, subexample: subexample, judge: judge, abbreviations: abbreviations, abbreviation: abbreviation, print-abbreviations: print-abbreviations, ex-label: ex-label, ex-ref: ex-ref)
        )
      ]}
    ]
}

#v(6em)
#align(center, par(spacing: 1.5em, text(size: 3em)[Eggs]))
#align(center, text(size: 1.2em)[Linguistic examples with minimalist syntax])
#v(1.5em)
#align(center, text(size: 1.2em)[#datetime.today().display("[month repr:long] [year]")])
#align(center, text(size: 1.2em)[https://github.com/retroflexivity/typst-eggs])
#v(5em)

Eggs (/ɛɡz/ or /ɪɡz/) is a Typst package for typesetting linguistic examples. Its aim is to provide a Typst analogue to LaTeX `gb4e`, `expex`, `linguex`, etc. Additionally, it ships with `leipzig`-style gloss abbreviations.

This is a documentation on Eggs. It begins with a review of features, then provides an extensive list of functions and their arguments.

#pagebreak()

= Initializing

To use Eggs, first import it, and then set its config via a global show rule.
#footnote[
  This package follows Typst's tradition of not abbreviating function names too much. Naturally, to achieve more effortless (or TeX-like) experience, you can set some aliases on import, e.g.

  #code-ex(
    ```typst
    #import "@preview/eggs:0.1.0": example as ex, subexample as subex, judge as j, ex-label as el, ex-ref as er
    ```,
    output: false
  )
]

#code-ex(
  ```typst
  #import "@preview/eggs:0.1.0"
  #show: eggs
  ```,
  output: false
)

This same function is used to configure Eggs' settings. See below.

= Examples

The primary fuction of Eggs is `example`. It acceps any `content` and typesets it as a single top-level linguistic example.

#code-ex(
  ```typst
  The sentence below demonstrates the reading known as specificational.
  #example[
    The primary function of Eggs is `example`.
  ]
  The semantics of the DP to the left of _is_ has been an object of much debate.
  ```
)

Examples are automatically numbered continuously. To override automatic numbering, pass the `number` argument. Examples with a custom number do not increment the counter, so numbering continues where it was left off. Passing things that are not numbers is not supported yet.

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

The counter can also be set explicitly with #raw("#counter(\"example\").update(n)", lang: "typst"). This way, following examples will be numbered starting with $n+1$. See #link("https://typst.app/docs/reference/introspection/counter/")[counter] for more info.

= Subexamples

Numbered lists inside examples (lines that begin with `+ `) are automatically typeset as subexamples.

#code-ex(
  ```typst
  Compare the following two sentences, of which only the former exhibits the Definiteness Effect.
  #example[
    + There is a/\*the subexample.
    + Here is a/the subexample.
  ]
  ```
)

In case you prefer it manual, the function `subexample` is defined. It is intended to only be used inside `example`. Automatic conversion of numbered lists can be toggled off by setting ```typst auto-subexamples: false``` in the config (see @customization). To suspend it for a single example, pass ```typst auto-subexamples: false``` to the subexample directly.

#counter("example").update((..it) => it.at(0) - 1)
#code-ex(
  ```typst
  Compare the following two sentences, of which only the former exhibits the Definiteness Effect.
  #example(auto-subexamples: false)[
    #subexample[There is a/\*the subexample.]
    #subexample[Here is a/the subexample.]
  ]
  ```
)

= Judges

`judge` is a simple function that typesets any text without taking up space. Intended to be used in the beginning of an example or a gloss word.

#code-ex(
  ```typst
  The following pair shows the information-structural rigidity of specificational sentences.
  #example[
    + SMITH is the killer.
    + #judge[\*]THE KILLER is Smith.
  ]
  ```
)

#pagebreak()
= Glosses

Bullet lists in examples (lines that begin with `- `) are automatically treated as gloss lines.

For words to split, you need to ensure that there is a `space` element between. The easiest way to do it is to separate words with *more than one* space (e.g. by pressing #smallcaps[tab] in most editors). There are exceptions, so use `~` (non-breaking space) for spaces you don't want to be treated as separators.

Translations and preambles are written as lines below and above glosses, respectively.

#code-ex(
  ```typst
  The following example presents the Russian _eto_-construction.
  #example[
    Russian
    - Jajca      eto   vkusno.
    - eggs  this            tasty
    'Eggs are tasty.'
  ]
  ```
)

Glosses can by typeset manually with `gloss`. It accepts either a content that it splits automatically or a list. Automatic bullet list conversion can be toggled off by setting ```typst auto-glosses: false``` in the config (see @customization). To suspend it for a single example, pass `auto-glosses: false` to the subexample directly.

#counter("example").update(it => it - 1)
#code-ex(
  ```typst
  The following example presents the Russian _eto_-construction.
  #example(auto-glosses: false)[
    Russian
    #gloss(
      [Jajca      eto   vkusno.],
      ([eggs], [this], [tasty]),
    )
    'Eggs are tasty.'
  ]
  ```
)

= Abbreviations

Eggs provides the whole set of #link("https://www.eva.mpg.de/lingua/resources/glossing-rules.php")[Leipzig Standard Abbreviations] as commands, in the style of TeX's `leipzig`. They are imported from a subpackage `abbreviations`.

All abbreviations are in lowercase. All abbreviations' names are as they appear, except for:
- *1, 2, 3* are `p1`, `p2`, `p3`
- *#smallcaps[n]* (as the non- prefix) is `non`

#code-ex(
  ```typst
  #import abbreviations: ins, pst, n

  Note that the famous temperature examples forbid Instrumental in Russian.
  #example[
    - #judge[\*]Temperatur-oj  byl-o        10~gradusov.
    - weather-#ins             be-#pst\-#n  10~degrees
  ]
  $n$ #n
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

The list of currently used abbreviations is stored as a dictionary of the form `abbr: description` inside the `used-abbreviations` state. The final list of abbreviations can be accessed as #raw("#context state(\"used-abbreviations\").final()", lang: "typst"). Additionally, there is a convenient function to print it as a #link("https://typst.app/docs/reference/model/terms/")[term~list].

#code-ex(
  ```typst
  The list of glossing abbreviations used in this paper:
  #print-abbreviations()
  ```
)

= Labels and refs

There are two ways of labelling an example (or a subexample). The first is passing the `label` argument to `example` (or `subexample`). The second is placing an `ex-ref` anywhere in the body of the example (or a subexample), preferably the beginning or the end. Typst's built-in `ref` does not work for now.

If a subexample doesn't have a label but its parent does, an automatic #link("https://typst.app/universe/package/codly")[codly]-style label of the form `<top-label:subex-letter>` is added automatically.

#code-ex(
  ```typst
  The curious minimal pair in terms of scope in (@pair) is taken Arregi et al. (2021). Only (@pred) has a narrow scope reading of the indefinite.
  #example[
    #ex-label(<pair>)
    + #judge(super[OK])Kim is not one of the judges. #ex-label(<pred>)
    + #judge[\#]One of the judges is not Kim.
  ]
  (@pair:b) is pragmatically odd, but becomes better if Kim is replaced with something that can exist in multiple places at once (@ok). The argument loses in convincibility, though.
  #example(label: <ok>)[
    #judge(super[OK])One of the judges is not "OK".
  ]
  ```
)

Until Typst's reference customization is more powerful (read: existent), Eggs provides a custom function `ex-ref`. It
- accepts from one to two arguments;
- accepts example labels and integers: integers are used for relative references;
- collapses the number of the second argument if it refers to a subexample;
- additionally accepts `left` and `right`, which it prints to the left and to the right of the number;
- encloses this all in parentheses.

#code-ex(
  ```typst
  Recall the discussion concerning examples #ex-ref(<pair>, <ok>). Despite the Russian data, we should not ignore the minimal pair in #ex-ref(<pred>, <pair:b>). There is much more to the story #ex-ref(left: "e.g. ", 1, right: " etc.").

  #example[
    + Only "?" is one of the judges.
    + One of the judges is only "?".
  ]
  ```
)


Thus, modulo parentheses, #raw("#ex-ref(1)", lang: "typst") is #raw("\\nextx", lang: "latex"), #raw("#ex-ref(0)", lang: "typst") is #raw("\\lastx", lang: "latex"), etc.


= Customization <customization>

Eggs offers some layout and styling customization and several behaviour toggles. The complete list is given in @funcs. Customization is done via setting the parameters of `eggs` in a global show rule.

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

To change Eggs' config temporarely, you can also simply pass the content to `eggs`. Note, however, that all parameters not passed are set to default. If you change your config frequently, you may want to store your defaults in a separate variable.

#counter("example").update(it => it - 2)

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
  #example(number: 12)[
    What I am pointing at is a kangaroo.
  ]
  ```
)

#show link: it => it.body
= Complete function documentation <funcs>

#set heading(numbering: none)
#show heading.where(level: 2): set heading(numbering: "1.")
#show v.where(amount: 4.8em): v(2em)


#for file in (
  "src/config.typ",
  "src/examples.typ",
  "src/judge.typ",
  "src/gloss.typ",
  "src/abbreviations.typ",
  "src/ex-label.typ",
  "src/ex-ref.typ",
) {
  tidy.show-module(tidy.parse-module(read(file)), style: tidy.styles.default, show-outline: false, first-heading-level: 1)
}
