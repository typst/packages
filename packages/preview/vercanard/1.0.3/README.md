# vercanard

A colorful resume template for Typst.

# What does it look like?

The [demo](template/main.typ) file showcases what it is possible to do.
You can see the result in [the corresponding PDF](demo.pdf).

# Quick usage guide

First of all, copy the template to your Typst project, and import it.

```typst
#import "@preview/vercanard:1.0.3": *
```

Then, call the `resume` in a global `show` rule function to use it.
This function takes a few arguments that we explain in comments below:

```typst
#show: resume.with(
  // The title of your resume, generally your name
  name: "Your name",
  // The subtitle, which is the position you are looking for most of the time
  title: "What you are looking for",
  // The accent color to use (here a vibrant yellow)
  accent-color: rgb("f3bc54"),
  // the margins (only used for top and left page margins actually,
  // but the other ones are proportional)
  margin: 2.6cm,
  // The content to put in the right aside block
  aside: [
    = Contact

    // lists in the aside are right aligned
    - #link("mailto:example@example.org")
    - +33 6 66 66 66 66
  ]
)

// And finally the main body of your resume can come here
```

When writing the body, you can use level-1 headings as section titles,
and format an entry with the `entry` function (that takes three content
blocks as arguments, for title, description and details).

```typst
= Personal projects

#entry[Vercanard][A resume template for Typst][2023 — Typst]
```

# A note on the licence

This template is under the GPLv3 licence, but resume built
using it are not considered binary derivatives, only output
from another program, so you can keep full copyright on them
and chose not to licence them under a free licence.
