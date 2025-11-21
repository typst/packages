# playwright

Dramatist's Guild guidelines oriented formatting for stageplays.

Playwright is a template for typst that lets you create stageplays formatted according to guidlines laid out
by the [Dramatist's Guild](https://www.dramatistsguild.com/script-formats).

To use playwright, simply call it as follows:

```typst
#show: playwright.with(
    title: "",
    descriptor: ""
)
```

The list of options playwright supports is as follows:

- `title` (string): The title of your play
- `descriptor` (string): The subtitle or descriptor of your play
- `authors` (array of strings): The author(s) of the play
- `contact` (content): The contact details of the authors
- `paper-size` (string): The paper size, for available options see the [Typst documentation](https://typst.app/docs/reference/layout/page/#parameters-paper)
- `font` (string): The font to use for the script. Note: playwright has a graceful decay font stack, this should be set only if you want to override this
stack. For more details see the section below

## Font

playwright sets up the following font stack and will fallthrough to each of them in the order listed:

- User provided font via the `font` option to `playwright`
- Courier Prime
- Courier
- Courier Screenplay
- Courier New
- Times New Roman
- Arial
- DejaVu Sans Mono (Included by default with Typst)

The Typst compiler may issue warning about certain fonts not being found. This is okay and to be expected as not all users will have fonts such as courier or its
variations installed on their computer.

## Structure

All Acts should be marked as level 1 headings, and all scenes should use level 2 headings.

```typst
= Act I
== Scene 1

== Scene 2

= Act II
== Scene 1

== Scene 2

== Scene 3
```

Other headings are not formatted and will fallback to default Typst formatting, it is not recommended you use them.

Page numbers are handled automatically and follow the `Act Number - Scene Number - Page Number` format. This functionality
is provided through the [hydra](https://typst.app/universe/package/hydra/) package.

## Helpers

playwright comes with a few helpers to simpify writing out dialogue.

The `dialogue` function takes a speaker (string) as a positional parameter, an optional `parenthetical` argument and the body which is the dialogue itself.

```typst
#dialogue("rika", parenthetical: "unnervingly")[
    Hey there, got any grapes?
]
```

Parentheticals that are longer than one word will automatically be shifted onto the next line.

playwright also keeps track of dialogue speakers and will automatically insert a `(CONT)` parenthetical next to a speaker's name if they were the last
speaker or an action interrupts their dialogue.

```typst
#dialogue("rika")[Hello there]

#dialogue("rika")[...What was that?] // will automatically have (CONT) inserted
```

The `action` helper marks out stage actions. Outside of a dialogue it is useful for actions or denoting entries and exits. It will automatically format itself to
start at the halfway point of the page and fit within the margin.

Within dialogue, it creates a dialogue stage action parenthetical, and will automatically create a block around itself.

```typst
#action[Enter RIKA, right.]

#dialogue("rika", parenthetical: "angrily")[
    Hello? Ugh.. hello, why does this thing never work?
    #action[into the phone]
    Hello can you hear me?
]
```

This is all you need to create most stageplays! Have fun!

## Contributing

Feel free to raise issues on the GitHub repository for issues or feature requests, and also feel free to open Pull Requests as well!
