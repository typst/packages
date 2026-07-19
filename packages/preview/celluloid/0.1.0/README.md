# celluloid

A template for writing screenplays.

This template targets the fickle "submission script" format for Hollywoood
production companies.

For the uninitiated: the format for screenplays being submitted to studios has
no official standard, but there's a defacto industry standard, and studios have
a reputation for being *extremely* picky about it. Allegedly this is an excuse
to throw out more submissions and cull the massive volume they receive each
year, though that could be a myth.

In fact, there's a lot of unreliable chatter about this format. Since there's no
single recognized body putting out a single authoritative spec for this stuff,
there's often a lot of debate about what formatting quirks are acceptable. Are
scene transitions still done?  Do you need `CONT'D` or can you drop it? Are
montages still done as numbered lists? Are the studios actually way more relaxed
about this stuff than people think and we're all just freaked out over nothing?
Who knows.

With that context in mind, this template is based most heavily on an
[example script](https://www.oscars.org/sites/oscars/files/scriptsample.pdf)
published by The Academy of Motion Picture Arts and Sciences.

This template hews pretty close to what's demonstrated in that example script.
There are features seen in screenplays for doing more complicated things (those
numbered-list montages mentioned before for example), but for now this template
takes AMPAS's failure to include those things in the example script as a
disrecommendation rather than an oversight.

## Usage

You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for celluloid.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/celluloid
```

Typst will create a new directory with all the files needed to get you started.

### Fonts

Pretty much every source on screenplay formats agrees that the entire document
should be written in some form of Courier. There are several Courier variants
available, and there's some debate on the merits of each. There seems to be some
agreement that Courier New is inferior among the variants and should be avoided.
This is the only variant mentioned explicitly in the AMPAS sample and it's a
negative mention.

With that in mind, this template will try to find and use one of the following,
in order of preference:

- Courier Final Draft
- Courier
- Courier Prime
- Courier New

You can also set your own font name, see [Configuration](#configuration).

To make one of these fonts available in the Typst web app, you can simply upload
the font files into the root of the project by clicking the "Explore Files"
icon, then the "Upload Files" icon in the revealed panel.

To make one of these fonts available for the CLI, simply install the font on
your system with whatever mechanism your operating system provides.

Of the fonts mentioned, Courier Prime is [available for free](https://fonts.google.com/specimen/Courier+Prime)
under the [OFL](https://openfontlicense.org/).

## Configuration

This template exports the `screenplay` function which takes a positional
argument for the title of the screenplay, and a positional argument for the body
of the screenplay. It also accepts the following named arguments:

- `font`: The name of a font to use, or a list of names in order of preference.
This template is designed to work with variants of Courier, though it cannot
enforce this restriction.
- `author`: The author's full name, used in the byline.
- `contact`: Contact information. This will appear on the title page. It is
typical to include a name, address, possibly a phone number, and an email.


The template will initialize your package with a sample call to the `screenplay`
function in a show rule. If you, however, want to change an existing project to
use this template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/celluloid:0.1.0": *
#show : screenplay.with(
  [Lorem Ipsum],
  author: [John Doe],
  contact: [
    John Doe\
    123 Hickory Street\
    Chicago, IL 12345\
    john.doe\@example.com
  ])

// Your content goes here. Use the various other functions to include dialogue
// and scene headers.
```

## Formatting functions

In addition to `screenplay`, the following functions are provided:

-`scene`: Header appearing before every scene.
-`dialogue`: A block of dialogue from a single character.
-`more-dialogue`: A continuation of a previous dialogue block after breaking to
insert some description.
-`parenthetical`: A parenthetical description inside a `dialogue` block.
-`intro`: Used to indicate the first time a character's name is mentioned.
*Must* be used before giving that character any `dialogue` blocks.
-`title-over`: A section which contains text shown on screen during the film.
-`transition`: A brief heading indicating how to transition to the next scene.
-`action`: A compact scene heading used for action sequences.
