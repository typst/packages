# cjk-unbreak

cjk-unbreak is a package that removes spaces around CJK characters caused by
line breaks in the Typst document.

This allows Typst like:

```typst
中文段落中
换行。
```

to be rendered as:

```text
中文段落中换行。
```

## Usage

Add the following code at the beginning of your document:

```typst
#import "@preview/cjk-unbreak:0.1.1": remove-cjk-break-space
#show: remove-cjk-break-space
```

The `remove-cjk-break-space` function transforms the content and removes
spaces between the `text` element such as `[ ]` in
`sequence([中文], [ ], [字符])`.

It will not modify spaces within a single `text` element such as `[中文 字符]` or
between elements that are not both `text` such as
`sequence([中文], [ ], strong(body: [字符]))`.

### Transform

cjk-unbreak use a function called `transform-childs` to modify the AST of the
content.
Unlike `show` in Typst, which applies multiple times until the content
stabilizes, the transform is applid only once.

See the source code of `remove-cjk-break-space` to learn more about how to use
`transform-childs`.

## Other information

This package is a temporary solution to Typst
[Issue#792](https://github.com/typst/typst/issues/792).

Thanks to [admk for providing the idea](https://github.com/typst/typst/issues/792#issuecomment-2310139085)
to remove `[ ]` from the sequence,
and to [touying](https://typst.app/universe/package/touying/), who demonstrated
how to modify the AST of content.
