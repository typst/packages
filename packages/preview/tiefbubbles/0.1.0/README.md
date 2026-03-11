# TiefBubbles


Bubbles! Well. Chat bubbles. But bubbles!

Welcome to TiefBubbles, the one and (probably not) only library to create chat bubbles.
If you are writing chats in block quotes still, you need tiefbubbles! Create beautiful
bubbles that adapt to your vision, not mine.

With features like naming, colored boxes, simple alternating mode, so on, it's possible 
to simply create beautiful chat bubbles!

## Usage

To import the package manually in your Typst project, use:

```typst
#import "@preview/tiefbubbles:0.1.0": bubbles
```

Then simply bubble along like a mad chatter!

```typst
#bubbles(
    [First message],
    [Second message],
    [#lorem(20)],
)
```

## Bubbles Formatting and Creation

Due to the simplicity of the task, there is only one function in TiefBubbles: `bubbles`.

However, bubbles has multiple ways to create and format bubbles. These are described below:

### Simple Mode

Simply add as many contents (messages) as you want to the parameters of `bubbles` to create
an alternating chat. Each message begins on the opposite side of the previous message.

If so desired, the side of the message appearing may be swapped using `swap-sides`.

### Modes

There are two modes in TiefBubbles. `alternating`, which is the above described default,
simply alternating between left and right, and `named`, which allows for naming participants
and defining a primary participant (displayed to the opposite side of other participants).

### Participant Selection

You can use an arbitrary number of participants. A participant for a chat message can be
selected in two ways: You may either pass an array as the message, with the participant being
the first argument and the content the second, or you can use a dictionary with `name` and
`content` keys.

To change which participant appears opposite to the others, use the `primary-participant`
field. Set it to the name (the strings are compared) of the participant you want to use.

You may also show the name of the participant above the message using the `show-name` option.

### Bubble Styling

There are two styling dictionaries that are used for styling the messages:

1. `name-style` gets applied to the name text
2. `box-style` gets applied to the bubble box

These dictionaries can contain keys of the respective built-in function. For example, to set
the text size of names, use:

```typst
#bubbles(
    //...
    name-style: (size: 20pt),
    //...
)
```

Similarly, you can set the bubble style like so:

```typst
#bubbles(
    //...
    box-style: (fill: blue),
    //...
)
```

However, if desired, the bubble style can be different for the left and right messages. This
can be done by providing two dictionaries, one for the left and one for the right bubble, like so:

```typst
#bubbles(
    //...
    box-style: (left: (fill: blue), right: (fill: green)),
    //...
)
```

Both left and right must be populated for this to work.

## Reference

### `bubbles`

```typst
#bubbles(
  mode: "alternating", // The mode to display the bubbles with
  primary-participant: "A", // Participant name appearing on the primary side
  show-name: false, // Whether to display the names of the participants
  name-style: (:), // Styling dictionary of the names
  box-style: (:), // Styling dictionary of the boxes (allows left/right distinction)
  swap-sides: false, // Whether to swap the sides of the bubbles
  ..contents, // Bubble contents
)
```