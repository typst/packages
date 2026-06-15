# Pillole

Multi-line bi-colored "pills" (GitLab-style scoped labels) for [Typst](https://typst.app).

Compact, breakable two-part labels with a key/value structure, rounded
end-caps, and a square-cornered, breakable middle that flows naturally across
line breaks.

The name "pillole" is Italian for "pills", and is pronounced like "pill-oh-leh".

## Usage

Import from the Typst package registry:

```typ
#import "@preview/illole:0.1.0": pill

A #pill("priority")[critical] item should be done first.

You can also pass the value as a trailing block: #pill("env")[prod].

Change the colors via the `primary` and `secondary` arguments:
#pill("status", primary: rgb("#386641"))[ready].
Pick a fully-rounded shape: #pill("tag", radius: 100%)[round].
```

## Documentation

See [`manual.pdf`](manual.pdf) for the full manual: every option, more
examples, and the current known limitations.

## License

MIT.
