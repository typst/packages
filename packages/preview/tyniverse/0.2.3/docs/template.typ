#show raw.where(block: true): block.with(
  width: 100%,
  fill: luma(93%),
  inset: 5pt,
  spacing: 0.7em,
  breakable: false,
  radius: 0.35em,
)
#set raw(lang: "typc")

#import "@preview/tyniverse:0.2.3": template, typesetting
#import "../src/styles/basic.typ": patch-enum-item, patch-list-item

#set page(height: auto)
#show: template.with(use-patch: false, title: "Template Examples", author-infos: "Fr4nk1in")

In the following examples, the header of each page is exactly what the template on that page specifies. In practice, the header only displays on the page whose number is greater than one, so the header and the title wouldn't appear on the same page.

We've made the patches for typst's bullet list and numbered list discussed in #link("https://github.com/typst/typst/issues/1204#issuecomment-2447947433", quote[_List and enum markers are not aligned with the baseline of the item's contents_ (\#1204)]) a built-in feature for all the templates in `tyniverse`. To disable it, pass `use-patch: false` as a template's named argument. If you want to enable only one patch, use `use-patch: (list: false)` or `use-patch: (enum: false)`.

Example:

```typ
- This is a very tall equation: $2^2^2^2^2^2^2^2$.

1. This is a very tall equation: $2^2^2^2^2^2^2^2$.

+ This is a very tall equation: $2^2^2^2^2^2^2^2$.
```

Without patches:

- This is a very tall equation: $2^2^2^2^2^2^2^2$.

1. This is a very tall equation: $2^2^2^2^2^2^2^2$.

+ This is a very tall equation: $2^2^2^2^2^2^2^2$.

With patches:

#show list.item: patch-list-item
#show enum.item: patch-enum-item

- This is a very tall equation: $2^2^2^2^2^2^2^2$.

1. This is a very tall equation: $2^2^2^2^2^2^2^2$.

+ This is a very tall equation: $2^2^2^2^2^2^2^2$.

In the following, each page is an example of the template with different configurations.

#show: template.with(
  title: (
    "Documentation of template",
    [Documentation of `template`],
  ),
)

```typ
#import "@preview/tyniverse:0.2.3": template

#show: template.with(
  title: (
    "Documentation of template",
    [Documentation of `template`],
  ),
)
```

```typc
let template(
  lang: "en",
  use-patch: true,
  title: ("Document Title", [Document Title]),
  author-infos: "Author",
  display-author-block: true,
  display-author-header: true,
  make-title: true,
  make-header: true,
  body,
) = content
```

- `lang`: `str`, Language identifier used in `set text(lang: lang)`
- `use-patch`: `bool` | `(list?: bool, enum?: bool)` \
  Whether to use the patch for list and/or enum, default enabled when ignored.
- `title`: `str` | `(str, content)`:
  document title and (optional) style-free content how the title displays
  - If the content is provided, better not setting the font size and font weight in the content, as this content will be used both in the title and the header. The template would handle it for consistency
  - If the content is not provided, the title will be just a text block
- `author-infos`: `str` | `array[str]` | `array[dict[str, any]]` \
  List of authors, together with their information
  - If a single string is provided, it is treated as the name of the only author
  - If an array of strings is provided, it is treated as the names of
    authors
  - If an array of dictionaries is provided, each dictionary should contain the "name" key
- `display-author-block`: `bool` | `dict[str, any] => content` \
  Whether or How to display an author block for a single author, default to a simple text block displaying the name. The author blocks are placed under the title as a up-to-3-column grid
- `display-author-header`: `bool` | `array[dict[str, any]] => content` \
  Whether or How to display the author information in the header. For single author, the default is to display the name of the author. For multiple authors, the default is to not display the author information.
  - For multiple authors, only when this is set to a valid function, the author information will be displayed in the header, otherwise (even if set to `true`), the author information will not be displayed in the header
  - Better not setting the font size in the content, the template would handle the font size
  - Better control the height of the content the same as the title content with the same font size
- `make-title`: `bool`, whether to make the title, default to true
- `make-header`: `bool`, whether to make the header, default to true


#show: template.with(
  title: ("single string author-infos", [single string `author-info`]),
  author-infos: "Author",
)

```typ
#import "@preview/tyniverse:0.2.3": template

#show: template.with(
  title: ("single string author-info", [single string `author-info`]),
  author-infos: "Author",
)
```


#show: template.with(
  title: (
    "multiple author-infos and display-author-block",
    [multiple `author-infos` and `display-author-block`],
  ),
  author-infos: range(1, 6).map(i => (
    name: "Author " + str(i),
    id: "ID " + str(i),
  )),
  display-author-block: info => {
    info.name
    linebreak()
    info.id
  },
)

```typ
#import "@preview/tyniverse:0.2.3": template

#show: template.with(
  title: (
    "multiple author-infos and display-author-block",
    [multiple `author-infos` and `display-author-block`],
  ),
  author-infos: range(1, 6).map(i => (
    name: "Author " + str(i),
    id: "ID " + str(i),
  )),
  display-author-block: info => {
    info.name
    linebreak()
    info.id
  },
)
```


#show: template.with(
  title: "set the header with multiple authors",
  author-infos: range(1, 6).map(i => "Author " + str(i)),
  display-author-header: _ => [ Author Team ],
)

```typ
#import "@preview/tyniverse:0.2.3": template

#show: template.with(
  title: "set the header with multiple authors",
  author-infos: range(1, 6).map(i => "Author " + str(i)),
  display-author-header: _ => [ Author Team ],
)
```


#show: template.with(
  title: "disable author header",
  author-infos: "Author",
  display-author-header: false,
)

```typ
#import "@preview/tyniverse:0.2.3": template

#show: template.with(
  title: "disable author header",
  author-infos: "Author",
  display-author-header: false,
)
```


#show: template.with(
  title: "disable header",
  author-infos: "Author",
  make-header: false,
)

```typ
#import "@preview/tyniverse:0.2.3": template

#show: template.with(
  title: "disable header",
  author-infos: "Author",
  make-header: false,
)
```


#show: template.with(
  title: "disable author blocks",
  author-infos: "Author",
  display-author-block: false,
)

```typ
#import "@preview/tyniverse:0.2.3": template

#show: template.with(
  title: "disable author blocks",
  author-infos: "Author",
  display-author-block: false,
)
```


#show: template.with(
  title: "disable title",
  make-title: false,
)

Disable title

```typ
#import "@preview/tyniverse:0.2.3": template

#show: template.with(
  title: "disable title",
  make-title: false,
)
```
