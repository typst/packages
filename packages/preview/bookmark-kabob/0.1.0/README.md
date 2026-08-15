# bookmark-kabob
> Bold and italic heading styles in PDF readers' bookmarks.

1. When reading e-books, bookmarks of PDF viewers are more useful than outlines (Tables of Contents), which can't float and are on some constant PDF pages.
2. If too many headings to read, it would be better to style them.
3. However, the bold or italic styles in outlines are not in sync with bookmarks'.

That's the blank this package fills in.

[Usage](#usage) | [Status](#status) | [LICENSE](#license)

## Usage
![bookmark styles](example.png)

```typ
#import "@preview/bookmark-kabob:0.1.0": *

#show: bobak  // take outline and heading back home

#outline()

= #kabob("*Part I: Markup")
= Chapter 1. CommonMark
= #kabob("_Chapter 2. HTML, CSS")

= #kabob("*Part II: Programming")
= Chapter 3. Python
= Chapter 4. #kabob("_POSIX Shell")

= #kabob("*Μερος Γ: ΠΔΦ")
= Κεφαλαιο 5. ΛαΤεΧ
= #kabob("*_Κεφαλαιο 6.") #kabob("*Τγρςτ")
```

## Status
- Tricky math forms used, only English Sans and Greek Serif letters usable.
- The package is font-independent, just pick the fonts you favor.
- Sort of slow? Try `typst compile example.typ --ignore-system-fonts`
- Why "str" rather than \[content\]?
  - Strings don't disturb external functions or show rules.
- Why `= _*Some Heading*_` won't be bold-italic in bookmarks (e.g. Document outline of PDF.js)?
  - Bookmarks are finished before everything, so can't be changed by emph(), strong(), show emph, etc.
- Why `#show: bobak`?
  - Outline and heading, as well as bookmark, be changed by `kabob()`, bobak takes them back home.

| Test | Typst | Trace |
| ---: | :---: | :--- |
| **PASS** | 0.15.1-0.6.0 | --- |
| *import err* | 0.5.0 | file not found: search preview |
| *compile err* | 0.4.0 | function `str` does not contain field `to-unicode` | 
| *compile err* | 0.3.0-0.1.0 | type function has no method `to-unicode` |

## LICENSE
[Apache-2.0](LICENSE)
