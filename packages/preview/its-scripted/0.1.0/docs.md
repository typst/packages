# `its-scripted` Documentation

## Fonts

Please make sure to download and install either the font `Courier`, `Courier New`, or some other Courier clone, because the builtin mono-spaced fonts on typst are horrific.

`Courier` and `Courier New` are natively supported, but you can use another font by inserting a `set` rule like so:

```typ
#show: screenplay.with()

#set text(font: "another-font")
```

## The `screenplay` Function

A `show` rule to setup your screenplay document.

Usage:

```typ
#show: screenplay.with(
  capitalized-headings: true,
  dir: ltr,
)
```

Named arguments:

- `capitalized-headings: bool`
  
  Determents whether or not to auto-capitalize all of the headings in your document.

  This will mean that all of the scene headings, as well as the character names at the beginning of dialog boxes will get set to upper-case letters.

  **Default:** `true`

- `dir: direction | auto`
  
  The direction of the document. This is mainly used to determine the direction of the text as well as the margins and page number positioning.

  **Effects:** `text.dir` will be set to the value of this argument. This can be overwritten with `set text(dir: new-dir)`.

  **Default:** `text.dir`, or `ltr` if `text.dir` has not been specified.

## The `maketitle` Function

Creates the title page for your screenplay. This automatically inserts a page break after the title, so you don't have to start a new page manually.

Usage:

```typ
#maketitle(
  title: "An Example",
  authors: ("me", "you"),
  date: datetime.today(),
  draft: 5,
  date-format: "[month repr:long] [day padding:none], [year]",
  info: [
    John Harrison Doh \
    john.doh\@email.com \
    2697 Blane Street, Saint Luis, Missouri
  ],
  [
    Some other things you want to appear on the title page.
  ],
)
```

Named arguments:

- `title: string | content | auto | none`

  The name of the movie/TV-show/book¹ you're writing.

  When set to `none` the title won't appear.

  **Effects:** `document.title` will be set to the value of this argument.

  **Default:** `document.title`

  ¹The screenplay for a theater production is called a book.

- `authors: string | string[] | auto | none`

  The author/authors of the screenplay.

  When set to `none` the list of authors won't appear.

  **Effects:** `document.author` will be set to the value of this argument.

  **Default:** `document.author`

- `date: datetime | string | content | auto | none`

  The date the screenplay was written.

  If the `date` is a `datetime` object it will be formatted using `datetime.display`, with the `datetime-format` option as a parameter. Otherwise, it will be displayed as is.

  When set to `none` the date won't appear.

  **Effects:** `document.date` will be set to the value of this argument.

  **Default:** `document.date`

- `draft: int | content | none`

  The number of draft of the screenplay.

  When set to `none` the draft won't appear.

  **Default:** `none`

- `info: int | none`

  Extra information displayed on the bottom end of the page.

  When set to `none` the information won't appear.

  **Default:** `none`

Any additional positional arguments will be added bellow the draft.

## Scene Headings

Scene headings are simply regular document headings. The level of the heading doesn't matter, as all headings are set to the same text size (though you should choose your heading levels consistently for improved code readability and accessibility).

When the `capitalized-headings` option in the `screeplay` function is set to `true`, headings are automatically capitalized.

Usage:

```typ
= INT. COFFEE SHOP - DAY

...
```

## The `dialog` Function

One or more pieces of dialog. When more than one piece of dialog is supplied they are all displayed side by side.

The character name is simply a heading.

Usage:

```typ
#dialog[
  == A Person

  I am currently saying a singular piece of dialog.
]

#dialog[
  == One Peron

  I am speaking simultaneously with the second person.
][
  == Another Peron

  I am speaking simultaneously with the first person.
]
```

The function excepts one or more content positional arguments.

## The `parenthetical` Function

Add a parenthetical to a piece of dialog.

Usage:

```typ
#dialog[
  == A Person

  #parenthetical(parens: true)[Speaking loudly]

  I am currently saying a singular piece of dialog.
]
```

Positional arguments:

- `body: content`

  The body of the parenthetical.

Named arguments:

- `parens: bool`

  Whether or not to surround the parenthetical with parentheses.

  **Default:** `true`

## The `close` Function

A closing statement to a segment of the script.

Usage:

```typ
...

#close(capitalize: true)[The End]
```


Positional arguments:

- `body: content`

  The body of the closing statement.

Named arguments:

- `capitalize: bool`

  Whether or not to capitalize the closing statement.

  **Default:** `true`