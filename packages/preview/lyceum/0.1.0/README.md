# lyceum.typ: academic book template in typst

`lyceum:0.1.0` is a `Typst` template for a simple, single-volume academic book.

The template offers the following named functions to be used as `show` rules in the user
documents: `FRONT-MATTER`, `BODY-MATTER`, `APPENDIX`, and `BACK-MATTER`.

After more than 400 commits, several strategies were implemented in order to cause Typst to properly
format the various book sections (of `FRONT` and `BODY` matters, as well as the `APPENDIX`, and
the `BACK-MATTER`), with little success, and the currently released format is the one deemed as
the _least-worse_ one of them.

The way Typst was though and implemented caused many strategies to fail, including (here, the
list is likely to be non-exhaustive):

- *Template functions* to define how things should be typeset: this goes against the Typst way
  of doing templating, and it fails because Typst code placed inside a function _cannot_ alter
  the caller's environment;
- *Writing metadata to the document* so that itens can dynamically (through `#context
  query(...)`) determine how things should be typeset. Headings were able to work just fine
  according to this strattegy, however, variable page numbering schemes failed to work, since on
  `#set page(...)`, the `numbering` field must be a _hard string literal_ -- not a variable that
  resolves to a string, as the documentation suggests, but a constant, hard, string literal.
  What could be an elegant approach, at the end of the day, was hindered;
- OK, let's do the officially supported template *function to use in the user's show rule*!
  Which was found (to the extent of my research and documentation digging) to be utterly unable
  to produce custom formats for different document sections, which causes me to wonder why
  article templates are plentiful in Typst Universe, but book templates are scarce.
- Finally, it dawned on me to have *multiple show rules* in the user document, each one using a
  different template function, i.e., the `FRONT-MATTER(...)`, `BODY-MATTER(...)`,
  `APPENDIX(...)`, and `BACK-MATTER(...)` ones. A quick test on a _standalone document_ (with no
  template) showed that the approach works like a charm, in having section-specific formattings
  being correctly applied, and settings correctly propagating to the `#outline`, etc...
  _however_, when the strattegy is implemented in a template form, some changes take a while to
  be effective, even though, their corresponding settings commands are issued at the right place
  in the document. I've spent some rounds trying to make it work, but I ran in situations in
  which by fixing one issue, another previously inexistent just appeared. After several rounds
  of fixing, locally releasing, and testing, the configuration deemed as having the least amount
  of bugs is being released, as this `0.1.0`.


## Name

`lyceum` designates "a place where educational talks were given to the public", according to
[the Cambridge Dictionary](https://dictionary.cambridge.org/dictionary/english/lyceum). Thus,
being a non-specific place (or instrument) for educational contents exchange, it seemed fitting
for a non-canonical name for a typst `@preview` academic book package name, since academic books
are primarily meant for educational content exchange.


## Prominent Features

### Metadata Handling

In `lyceum`, book metadata was inspired by the
[Hyagriva](https://typst.app/docs/tutorial/writing-in-typst/#bibliography) bibliography manager.
Book metadata, such as title, author(s), publisher, keywords, date, and etc..., must be fed to
the first user's `#show` rule function, `FRONT-MATTER(...)`, which processes it and saves it to
the document with `#metadata`.

Beyond that, metadata processing done by `lyceum` includes the automatic generation of the
book's _own_ Hayagriva entry. This functionality works in two ways, i.e., (i) the book's own
Haygriva bibliography entry can be either typeset and included in the very document, or (ii) an
`yml` file type can be conveniently generated using the `make` utility, as in `make main.yml` if
the book is written on the `main.typ` file. The template stencil implements these two ways of
obtaining the book's bibliography entry.


## Citing

This package can be cited with the following bibliography database entry:

```yml
lyceum-template:
  type: Web
  author: "Naaktgeboren, C."
  title: "Lyceum: Academic Book Template in Typst"
  url: https://github.com/cnaak/lyceum.typ
  version: 0.1.0
  date: 2024-10
```


