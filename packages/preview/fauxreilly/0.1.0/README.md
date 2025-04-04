# Fauxreilly

<a href="https://forthebadge.com" target="_blank"><img src="https://raw.githubusercontent.com/dei-layborer/o-rly-typst/refs/heads/main/made-with-(2s)-2%2C6-diamino-n-%5B(2s)-1-phenylpropan-2-yl%5Dhexanamide-n-%5B(2s)-1-phenyl-2-propanyl%5D-l-lysinamide.svg"></a>

<a href="https://deilayborer.neocities.org/funding" target="_blank"><img src="https://raw.githubusercontent.com/dei-layborer/o-rly-typst/refs/heads/main/%24%24%24-gimmie.svg" height="30"></a>

A ``typst`` package for creating **O'RLY?**-style cover pages.

## Example

```rust
#import "@preview/o-rly-cover:0.1.0": *

#orly(
    color: rgb("#85144b"),
    title: "Learn to Stop Worrying and Love Metathesis",
    top-text: "Axe nat why (or do)",
    subtitle: "Free yourself from prescriptivism",
    pic: "chomskydoz.png",
    signature: "Dr. N. Supponent"
)
```

![example book cover](example.png)

## Usage

First, import the package at the top of your ``typst`` file: ``#import "@preview/o-rly-cover:0.1.0": *``

Only one function is exposed, ``#orly()``.  This will create its own page in the document at whatever location you call the function.  In other words, any content in the ``typst`` document that appears before ``#orly()`` is called will be before the O'Rly? page in the PDF that ``typst`` renders.  Anything after the function call will be on subsequent page(s).

All content for the title page is passed as options to ``#orly()``.  I included what I figured were the most likely things you'd want to customize without having a million options.  Meanwhile, most of the layout parameters (font sizes, the heights of individual pieces, etc.) are variables within the code, so hopefully aren't too hard to alter if need-be.  None of the options are strictly required, although the text fields are the only ones that can be left empty without potentially breaking the layout.   A few have defaults instead, and those are listed below where applicable.

### Options
The order that the options appear in the table is the order they must be sent to the function, unless you specify the option's key along with its value.

Data types listed are based on ``typst``'s internal types, so are entered the same way as they would be in any other function that takes that data type.  For example, the data type needed for the ``font`` option is the same as what is used for ``typst``'s built-in ``#text()`` function, which is linked in the table below.  (All links go to their specific usage in the ``typst`` documentation.)

Option | Description | Type | Default |
| :----- | :------- | :-------: | :-------: |
| ``font`` | The font for all text except the "publisher" in the bottom-left corner | [``string(s)``](https://typst.app/docs/reference/text/text/#parameters-font) |  Whatever is set in the document context |
| ``color`` | Accent color.  Used for the background of the title block and of the colored bar at the very top. | [``color``](https://typst.app/docs/reference/visualize/color/) | ``blue`` (typst built-in) |
| ``top-text`` | The text at the top, just under the color bar | [``string``](https://typst.app/docs/reference/foundations/str/) | Empty |
| ``pic`` | Image to be used above the title block | [``string``](https://typst.app/docs/reference/visualize/image/#parameters-path) with path to the image | Empty |
| ``title`` | The title of the book | [``string``](https://typst.app/docs/reference/foundations/str/) | Empty |
| ``title-align`` | How the text is aligned (horizontally) in the title block | [``alignment``](https://typst.app/docs/reference/layout/alignment/) | ``left`` |
| ``subtitle`` | Text that appears just below the title block | [``string``](https://typst.app/docs/reference/foundations/str/) | Empty |
| ``publisher`` | The name of the "publisher" in the bottom-left | [``string``](https://typst.app/docs/reference/foundations/str/) | O RLY<sup>?</sup> (see example above) |
| ``publisher-font`` | Font to be used for "publisher" name | [``string(s)``](https://typst.app/docs/reference/text/text/#parameters-font) | Noto Sans, Arial Rounded MT, document context (in that order) |
| ``signature`` | Text in the bottom-right corner | [``string``](https://typst.app/docs/reference/foundations/str/) | Empty |
| ``margin`` | Page margins | [``length`` or ``dictionary``](https://typst.app/docs/reference/layout/page/#parameters-margin) | ``top: 0``, all others will use the document context |

### Usage Notes

There are a couple quirks to data types and the like that may not be obvious.

1. ``string``s typically must be contained in quotation marks.  But note that this will render quotation marks *within* those strings without using [smartquotes](https://typst.app/docs/reference/text/smartquote/).  To avoid this, you may use content mode instead (by enclosing the text in square brackets ``[]``).  For example, ``"Some title"`` → ``[Some title]``
   - Similarly, you can use this to toggle italics (e.g. ``[Italic text, _except_ this one]``) or apply other formatting
2. Other types may look like strings but do **not** take quotes, specifically ``color`` (including when using the built-in color names) and ``alignment``
3. With the ``margin`` type, if a single value is entered (without quotes), that value is applied to all four sides.  All other usage must be done as a dictionary (meaning enclosed in parentheses), even if you're only specifying one side.  For example, the default is written ``(top: 0in)``.
   - If you're going to pass any value other than the top as an option, you'll likely want to add ``top: 0in`` back in to avoid a gap between the top of the page and the color bar
   - Any values passed to the function (or the default value if none are) will override any margin(s) set earlier in the ``typst`` file.  So you can use a ``set`` rule at the beginning of the document without affecting the cover page

### Images

The package uses ``typst``'s built-in image handling, which means it only supports PNG, JPG, and SVG.

The image will be resized to as close to 100% page width (inside the margins) as possible while both maintaining proportions and avoiding any cropping.  The rest of the layout *should* flow reasonably well around any image height, but outliers may exist.

O'Reilly-style animals can be found in the [relevant section](https://etc.usf.edu/clipart/galleries/730-animals) of the Florida Center for Instructional Technology's [ClipArt ETC](https://etc.usf.edu/clipart/) project.  Just be aware that these are provided as GIFs(!), so conversion to one of ``typst``'s supported formats will be required.


## Bugs & Feature Requests

I put this whole thing together in an afternoon when I should've been doing work for my day job.  Granted I'd already done a basic version for a seminary writing assignment (I love to spoof academic writing), but either way, I've gotten this project to a basic level of functionality and no further.  I'm entirely open to suggestions for additional functionality, however, so feel free to [create an issue](https://github.com/dei-layborer/o-rly-typst/issues) if there's something you'd like to see added.

It hopefully goes without saying that the same is true if something breaks!

Tested on ``typst`` versions ``0.11.1`` and ``0.12.0-rc1``.

## Thanks & Shout-Outs

Shout out to Arthur Beaulieu ([@arthurbeaulieu](https://github.com/ArthurBeaulieu)), whose [web-based generator](https://arthurbeaulieu.github.io/ORlyGenerator/) served as both inspiration and reference (I pretty much stole his layout settings).

Significant thanks to the folks in the [typst discord](https://discord.gg/2uDybryKPe) who helped me sort out some layout woes.

Extra double appreciation to Enivex on the discord for the name.