This is a [Typst](https://github.com/typst/typst) package to add cut, bleed, and registration marks to documents.

It's likely that some future version of Typst will obsolete this package.  Until that time, it's nice to have **a** way to achieve this functionality with the current version.


# Demo

![Markly Demo](img.png)

...can be generated with:

```typst
#import "@preview/markly:0.2.0"

#let markly-context = markly.setup(
  stock-width:4in,
  stock-height:3in,

  content-width: 3in,
  content-height:2in,
)

#show: markly.page-setup.with(markly-context)

// Here the local title template uses markly's to-bleed
#let title(body, inset-y:12pt) = {
  markly.to-bleed(text(white, size:2.5em, body), markly-context)
}

#title[Bannar]

- Content
```


For a more detailed example, see [main.typ](template/main.typ) and [main.pdf](main.pdf).

# Notes

Since this is a bit difficult to do there are some limitations to using this package.  Here are a few examples:

* `inside`/`outside` margins don't work on pages
* The `background` field of the `page` can't be used unless there is a wrapper function so that `marks` is called also.


# Installation

Currently, this package has **not yet** been published.  To try it out, you must download it locally.  There are many ways to do this.

## Install via git and typship

```sh
git clone git@github.com:cskeeters/typst-markly.git
cd markly

# Install typship, if not already installed
cargo install typship

typship install preview
```

Answer `y`es, when warned.


## Install via git

First set `$DATA_DIR` [according to your OS](https://github.com/typst/packages/blob/main/README.md#local-packages).  Yes, this sucks.

```sh
mkdir $DATA_DIR/typst/packages/preview/markly
cd $DATA_DIR/typst/packages/preview/markly

git clone git@github.com:cskeeters/typst-markly.git 0.2.0
cd 0.2.0
git checkout -b 0.2 origin/v0.2.0
```

## Install with typship to local namespace

    cargo install typship

    typship download https://github.com/cskeeters/typst-markly/

To use, you have to change 

```typst
#import "@preview/markly:0.2.0"
```

to

```typst
#import "@local/markly:0.2.0"
```

NOTE: `typship` doesn't support downloading to the preview namespace in the `{data-dir}`, otherwise this wouldn't be necessary.


# Usage

Initialize a new project from this template:

```sh
cd
typst init @preview/markly:0.2.0
cd markly
typst compile main.typ
```

## Setup

Use `setup` to create a "context" that other markly methods need.  This is just a dictionary with values it so we don't repeat values.

The *stock* width and height is your *actual* paper size.

| Parameter     | Default Value
| ------------- | --------------
| stock-width   | 8.5in
| stock-height  | 11in

The *content* width and height will be the size of the paper after cutting along the cut marks (black).

| Parameter      | Default Value
| -------------  | --------------
| content-width  | 6in
| content-height | 4in

The *margin* width and height are the amounts between the edge of the cut line and the start of the content.  NOTE: total width consumed by margins equals 2 * margin-width since it's used on both sides of the content.  Same for height.

| Parameter     | Default Value
| ------------- | --------------
| margin-width  | 6in
| margin-height | 4in

Finally, the `bleed` value is the distance between the cut line and bleed line, or the over-print amount that can occur because we have extra paper past the cut line.

| Parameter     | Default Value
| ------------- | --------------
| bleed         | 9pt


```typst
#let markly-context = markly.setup(
  // stock-width:8.5in,
  // stock-height:11in,

  content-width:7in,
  content-height:5in,

  // bleed:9pt,

  // margin-width:.2in,
  // margin-height:.2in
)

// Configure the page to draw marks
#show: markly.page-setup.with(markly-context)

content...

```

## Print to Bleed Templates

Use `to-bleed`, `to-bleed-left`, or `to-bleed-right` to paint a background to the bleed marks.

Use `img-to-bleed` to stretch an image horizontally and vertically to the bleed marks.  The position of the "cursor" is not updated (like in the case of a background image) since it uses the `place` function.


# Design

[Cetz](https://github.com/cetz-package/cetz) is used to draw the marks on the page's background.
