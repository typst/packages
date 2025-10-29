# arkheion

A Typst template based on popular LateX template used in arXiv and bio-arXiv. Inspired by [arxiv-style](https://github.com/kourgeorge/arxiv-style)

## Usage

**Import**

```
#import "@preview/arkheion:0.1.1": arkheion, arkheion-appendices
```

**Main body**

```
#show: arkheion.with(
  title: "ArXiv Typst Template",
  authors: (
    (name: "Author 1", email: "user@domain.com", affiliation: "Company", orcid: "0000-0000-0000-0000"),
    (name: "Author 2", email: "user@domain.com", affiliation: "Company"),
  ),
  // Insert your abstract after the colon, wrapped in brackets.
  // Example: `abstract: [This is my abstract...]`
  abstract: lorem(55),
  keywords: ("First keyword", "Second keyword", "etc."),
  date: "May 16, 2023",
)
```

**Appendix**

```
#show: arkheion-appendices
=

== Appendix section

#lorem(100)

```

## API

### `arkheion.with`

- `title: String` - Title of the document.
- `authors: List<Author>` - List of authors.
```
Author: {
  name: String,
  email: String,
  affiliation: String,
  orcid: String
}
```
- `custom-authors: Content` - Custom authors content that overrides the default authors content.
Note: The `authors` is still required to be passed in order to generate the metadata, however, only the `name` field is required.
- `abstract: Content` - Abstract of the document.
- `keywords: List<String>` - List of keywords.
- `date: String` - Date of the document.

## License
The MIT License (MIT)

Copyright (c) 2023 Manuel Goulão

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
