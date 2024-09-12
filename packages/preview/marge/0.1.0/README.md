# marge

A package for easy-to-use but powerful and smart margin notes.

## Usage

The main function provided by this package is `sidenote`, which allows you to create margin notes. The function takes a single positional argument (the text of the note) and several optional keyword arguments for customization:

| Parameter   | Description                                                           | Default               |
| ----------- | --------------------------------------------------------------------- | --------------------- |
| `side`      | The margin where the note should be placed.                           | `auto`                |
| `dy`        | The custom offset by which the note should be moved along the y-axis. | `0pt`                 |
| `padding`   | The space between the note and the page or content border.            | `2em`                 |
| `gap`       | The minimum gap between this and neighboring notes.                   | `0.4em`               |
| `numbering` | How the note should be numbered.                                      | `none`                |
| `counter`   | The counter to use for numbering.                                     | `counter("sidenote")` |
| `format`    | The "show rule" for the note.                                         | `it => it.default`    |

The parameters allow maximum flexibility and often allow values of different types:

- The `side` parameter can be set to `auto`, `"inside"`, `"outside"` or any horizontal `alignment` value. If set to `auto`, the note is placed on the larger of the two margins. If they are equally large, it is placed on the `"outside"` margin.
- If the `dy` parameter has a relative part, it is resolved relative to the height of the note.
- The `padding` parameter can be set either to a single length value or a dictionary. If a dictionary is used, the keys can be any horizontal alignment value, as well as `inside` and `outside`.
- With the `counter` parameter, you can for example combine the numbering of footnotes and sidenotes.

An especially useful feature is the `format` parameter, as it emulates the behavior of a show rule via a function. That function is called with the context of the note and receives a dictionary  with the following keys:

| Key         | Description                                              | Value or type               |
| ----------- | -------------------------------------------------------- | ----------------------------|
| `side`      | The side of the page the note is placed on.              | `left` or `right`           |
| `numbering` | The numbering of the note.                               | `str`, `function` or `none` |
| `counter`   | The counter used for numbering the note.                 | `counter`                   |
| `padding`   | The padding of the note, resolved to `left` and `right`. | `dictionary`                |
| `margin`    | The size of the margin, which the note is placed on.     | `length`                    |
| `source`    | The location in the document where the note is defined.  | `location`                  |
| `body`      | The content of the note.                                 | `str`                       |
| `default`   | The default look of the note.                            | `content`                   |

As the dictionary itself is not an element, you cannot directly use it within the `format` function as you would be able to in a normal show rule. To still be able to build upon the default look of the note without having to reconstruct it, the `default` key is provided. The default style sets the font size to `0.85em` and the paragraph's leading to `0.5em`, matching the default style of footnotes. This can of course be overridden.

Aside from the customizability, the package also provides automatic overlap and overflow protection. If a note would overlap with another note, it is moved further down the page, so that the `gap` parameters of both notes are respected. If a note would overflow the page, it is moved upwards, so that the bottom of the note is aligned with the bottom of the page content. Any previous notes, which would then overlap with the moved note, are also moved accordingly.

### Note about pages with automatic width

If a note is placed in the right margin of a page with width set to `auto`, additional configuration is necessary. As the final width of the page is not known when the note is placed, the note's position cannot be calculated. To place notes on the right margin of such pages, the package provides a `container`, which is supposed to be included in the page's `background` or `foreground`:

```typ
#import "@preview/marge:0.1.0": sidenote, container

#set page(width: auto, background: container)

...
```

The use of the `container` variable is detected automatically by the package, so that an error can be raised when it is required but not set.

### Note about layout convergence and performance

This package makes heavy use of states and contextual blocks, causing Typst to require multiple layout passes to fully resolve the final layout. Usually, the limit imposed by Typst is sufficient, but I cannot guarantee that this will remain true for large documents with a lot of notes. If you happen to run into this limit, you can try using the `container` variable as mentioned above, as it can reduce the number of layout passes required.

As each layout iteration adds to the total compile time, the use of the `container` can also be beneficial for performance reasons. Another performance tip is to keep the size of paragraphs containing margin notes small, as the line breaking algorithm cannot be memoized when the paragraph contains a note.

### Note about how lengths are resolved

When a length is given in a context-dependent way (i.e. in `em` units), it is resolved relative to the font size of the _content_, not the font size of the note (which is smaller by default). This has the unfortunate side effect that a gap set to `0pt` will still have some space due to the content paragraph's leading (which is also larger than default leading of the note). Similarly, if notes are defined in a context with a larger font size, the padding and gap values may unexpectedly be larger than of neighboring notes.

## Example

```typ
#import "@preview/marge:0.1.0": sidenote

#set page(margin: (right: 5cm))
#set par(justify: true)

#let sidenote = sidenote.with(numbering: "1", padding: 1em)

The Simpsons is an iconic animated series that began in 1989
#sidenote[The show holds the record for the most episodes of any
American sitcom.]. The show features the Simpson family: Homer,
Marge, Bart, Lisa, and Maggie. 

Bart is the rebellious son who often gets into trouble, and Lisa
is the intelligent and talented daughter #sidenote[Lisa is known
for her saxophone playing and academic achievements.]. Baby
Maggie, though silent, has had moments of surprising brilliance
#sidenote[Maggie once shot Mr. Burns in a dramatic plot twist.].
```

![Result of example code.](assets/example.svg)
