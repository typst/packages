# Owlbear - Typst Package for Dungeons and Dragons

[![stable version](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fowlbear%2F&query=%2F%2Fspan%5Bcontains(%40class%2C%20'version')%5D&style=for-the-badge&label=version)](https://typst.app/universe/package/owlbear/)
![nightly version](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fgitlab.com%2Fdoggobit%2Ftypst-owlbear%2F-%2Fraw%2Fmain%2Fsrc%2Ftypst.toml%3Fref_type%3Dheads&query=%24.package.version&style=for-the-badge&label=nightly&labelColor=rgb(121%2C%2059%2C%2047)&color=rgb(209%2C%20163%2C%2071))
![minimum typst version](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fgitlab.com%2Fdoggobit%2Ftypst-owlbear%2F-%2Fraw%2Fmain%2Fsrc%2Ftypst.toml%3Fref_type%3Dheads&query=%24.package.compiler&style=for-the-badge&logo=typst&logoColor=white&label=min%20version&color=%23239DAD)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-doggobit-%23212121?style=for-the-badge&logo=buymeacoffee&logoColor=%23212121&labelColor=%23FDDD01)](https://buymeacoffee.com/doggobit)

Create professional D&D homebrew content with this easy-to-use
[Typst](https://typst.app/docs) template. Features print-friendly design,
customizable themes, and specialized D&D components. Perfect for campaign
documents, adventure modules, and game supplements that look great without
expensive printing.

Check out the example [document](https://gitlab.com/doggobit/typst-owlbear/-/blob/main/docs/examples/dnd.typ?ref_type=heads)
and the resulting [PDF file](https://gitlab.com/doggobit/typst-owlbear/-/blob/main/docs/examples/dnd.pdf?ref_type=heads).

While there have been many amazing efforts in the past to replicate the official
Dungeons and Dragons book style, this project has a slightly different aim, best
summarised by the following goals:

- Easy to use: the template is designed to be easy to use; all you need to know
  is the typst syntax. The code will not get in the way of your writing.
- Batteries included, but works out of the box: I hope to make the template as
  extensible as possible, but without exposing any of that complexity onto users
  until the very moment they need it.
- Promote open source projects, where possible: for example, instead of
  replicating the official fonts, this project uses
  [Open Font License](https://opensource.org/licenses/OFL-1.1) fonts that match
  the vibe of the official ones. [^fonts]
- Optimised for home printing: the official books are printed on high-quality
  paper, with a lot of ink and using fancy backgrounds. This project aims to
  look good when printed on a home printer, balancing style with ink usage.
- Customisable: there is a theme parameter that allows you to change the look of
  the document, by overriding different aspects like colours, fonts, sizes, etc.
  In theory, this should allow anyone to create and share themes that match the
  style of their homebrew world.

[^fonts]: Read more about the font choices in this [document](https://gitlab.com/doggobit/typst-owlbear/-/blob/main/docs/fonts.md?ref_type=heads)

## Example

If you are familiar with Markdown or the MediaWiki syntax, typst won't feel too
different. You can check out the
[typst syntax](https://typst.app/docs/tutorial/) for reference. Here is what a
very simple document might look like:

```typst
#import "@preview/owlbear:0.0.1": book-template
#show: book-template  // These two lines simply apply the template

= Shadowlands  // Campaign title

== The Shadowy inn  // Heading

// Paragraph
Deep within the mist-shrouded valleys of the Northern Reach lies the forgotten
township of Shadowfen. Once a thriving trading post, it now stands as a haunting
reminder of prosperity lost to an ancient curse. As adventurers drawn to this
forlorn place, you will uncover secrets long buried and face horrors that lurk
in the perpetual twilight.
```

This would render like this:

![Example render of the sample code](https://gitlab.com/doggobit/typst-owlbear/-/raw/main/docs/assets/render.png?ref_type=heads)

## Usage

To use this template, you need to have
[typst](https://www.github.com/typst/typst) installed. You can check out the
[recommended setup](#recommended-setup) for the set of tools used when
developing this template.

To use the template, simply import it and use it in your typst document:

```typst
#import "@preview/owlbear:0.0.1": book-template

#show: book-template
```

### Recommended Setup

The project was developed using the following stack:

- [Visual Studio Code](https://code.visualstudio.com/download): The editor used
  to write the document.
- [Typst](https://github.com/typst/typst?tab=readme-ov-file#installation):
- [Tinymist VSCode Extension](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist):
  Used to preview the document and export it as a PDF file. [^tinymist]
- [Git](https://github.com/git-guides/install-git) (optional): Even though it
  might seem scary at first, keeping track of how your documents change over
  time can be incredibly powerful, while also enabling collaborative effort.

[^tinymist]: Keep in mind that there can be slight differences between the
preview and the exported PDF. You can read more about
[known limitations](#known-limitations).

#### Alternative options

- [Typst](https://typst.app) has a paid web-based interface you can use to
  compile and view the documents as well if the local setup seems too
  overwhelming. Don't worry, you can always switch back or forth, the syntax is
  the same regardless.

## Models

This is what *typst* calls different *elements* in a document. The project
provides a few useful ones out of the box, documented below. Keep in mind that
the extensive suite of *typst* options are also available, to note are:

- [columns](https://typst.app/docs/reference/layout/columns/): For organising
  your content in columns.
- [figure](https://typst.app/docs/reference/model/figure/): For including
  images.
- [footnote](https://typst.app/docs/reference/model/footnote/): For creating
  footnotes.
- [pagebreak](https://typst.app/docs/reference/layout/pagebreak/): For forcing a
  page split.

### Titled table

If you include a table within a figure, it will render with the figure's caption
as its title:

```typst
 #figure(
    caption: "Random Encounters",
    table(
        columns: (auto, 1fr),
        table.header(
        "1d4",
        "Encounter Description",
        ),
        "1", "A bird lands on your shoulder",
        "2", "It starts raining",
        "3", "Lightning strikes the nearby tree",
        "4", "A rainbow appears overhead",
    )
)
```

![Example render of a table](https://gitlab.com/doggobit/typst-owlbear/-/raw/main/docs/assets/table.png?ref_type=heads)

### Enumeration

The books sometimes present a list of terms arranged over columns, e.g. for
listing locations or conditions. This can be achieved with the `dnd-enum` model:

```typst
#import "@preview/owlbear:0.0.1": dnd-enum

#dnd-enum(
    "Prone",
    "Frightened",
    "Charmed",
    "Blinded",
)
```

![Example render of an enumeration](https://gitlab.com/doggobit/typst-owlbear/-/raw/main/docs/assets/enum.png?ref_type=heads)

### Note box

Sometimes, important rules are presented in a box outside of the normal text
flow. This can be done with `dnd-note`:

```typst
#import "@preview/owlbear:0.0.1": dnd-note

#dnd-note[
    = Dialogue in combat // Note title

    Many players forget that you can try to negotiate with the attackers.
]
```

![Example render of a note](https://gitlab.com/doggobit/typst-owlbear/-/raw/main/docs/assets/note.png?ref_type=heads)

### Definitions

You can list a number of terms and their definitions using `dnd-terms`:

```typst
#import "@preview/owlbear:0.0.1": dnd-terms

#dnd-terms(
    ("Attack Roll", "Roll the d20 to find out if your attack hits. You want your
        score to exceed the enemy's Armour Class."),
    ("Difficulty Class", "The ability check score you need to beat for a
        success")
)
```

![Example render of a list of terms](https://gitlab.com/doggobit/typst-owlbear/-/raw/main/docs/assets/terms.png?ref_type=heads)

### Dialogue

mdformat You can show dialogue using `dnd-dialogue`. However, due to rendering
issues on *typst*'s part, this will not render as intended in PDFs. Check out
the section on [known limitations](#known-limitations).

You can provide a list of people to be highlighted under the respective key:

```typst
#import "@preview/owlbear:0.0.1": dnd-dialogue

#dnd-dialogue(
    highlight: ("Dungeon Master"),
    ("Dungeon Master", "Where did we leave off last time?"),
    ("Player 1", "We slayed the dragon"),
    ("Player 2", "And rescued the prince"),
)
```

![Example render of a dialogue](https://gitlab.com/doggobit/typst-owlbear/-/raw/main/docs/assets/dialogue.png?ref_type=heads)

## Known limitations {#limitations}

### Dialogue background

Currently, *typst* is having issues with gradients that include transparency. I
will try to contribute to the issue in my free time to get it fixed.

### Header discrepancy

If you're using *Tinymist* for previews, strokes and gradients in backgrounds
don't play well together. However, they do render correctly in the exported PDF.
I will also try to contribute to this issue.

## Contributing

Feel free to open an **Issue** to report any bugs, suggest new features, general
comments or help requests. You can share your usage of the package, or provide
tips and tricks via **Snippets**. I am also more than happy to accept
**Merge Requests** if you want to directly contribute to the code.

If you are in the position for it, consider a small donation to help me overcome
my ADHD and focus on this project every now and then via
[Buy Me a Coffee](https://buymeacoffee.com/doggobit).

## License

This project is licensed under the [GNU Affero General Public License](LICENSE).
While I am not a legal expert, this is how it might apply:

- None of the license apply to the actual artistic content you create (i.e.
  images, story, characters, etc.). That is entirely your hard work, and it is
  yours exclusively to decide upon.
- If you are simply creating homebrew content for yourself and friends without
  publicly distributing the software or offering it as a network service, the
  license doesn't require you to share your code modifications. However, I would
  appreciate it if you pointed people to this project.
- If you are using this project in order to build an online D&D platform, run an
  extensive online campaign, or produce wide-reaching projects, some of the
  license may apply. At that point, you might want to check with someone more
  competent than a hobbyist on GitHub :)

## Related work

- [Solbera D&D Fonts](https://www.github.com/jonathonf/solbera-dnd-fonts): A
  collection of fonts that replicate the ones used in the books.
- [Homebrewery](https://homebrewery.naturalcrit.com/): A web-based tool that
  uses the Solbera D&D Fonts.
- Steve Coffman's amazing
  [GitHub Gist](https://gist.github.com/StevenACoffman/e9eacf1c62c15c205e5a7643a10dd8f1):
  I based my work on his choices, but I have diverged where I felt it was
  necessary.
