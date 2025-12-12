# A Typst Template for _Psychometrika_

Elegant, ergonomic, satisfying, reproducible manuscript preparation for
[_Psychometrika_](https://www.psychometricsociety.org/psychometrika), powered by
[Typst](https://typst.app/home).

## Usage

This template is designed to be as transparent as possible. Just import the
`conf` element, fill in the necessary metadata, and start writing as you
normally do!

```typst
#show: conf.with(
  abstract: ...,
  title: ...,
  authors: (...),
  keywords: (...)
)

= Your First Section
```

## Advanced Usage

You may also import and reuse some of the definitions, such as:

- `color-heading`
- `color-abstract`
- `font-mono`
- `stroke-table`
- `state-after-bib`
- ...

```typst
text(fill: color-heading)[A sentence with the color of a heading!]
```

When in doubt, read `lib.typ`, it's very straightforward! (Much more so than
most LaTeX packages.)

## Known Issues

- The table header color currently only applies to the first row instead of all
  cells wrapped in `table.header`. You will need to import `color-header`
  manually for some advanced coloring.
- Caption note via `/ Note: ...` doesn't stick with the figure when
  `placement: auto` is set. A workaround for this is described in the
  accompanied template file.

## Support

Should you have any questions, feel free to start a discussion. You're also
encouraged to consult the [Typst documentation](https://typst.app/docs).
Questions regarding Typst itself can be asked in Typst
[forum](https://forum.typst.app/) or
[Discord](https://discord.com/invite/2uDybryKPe).

## Contribution

Feel free to create an issue about how this template could be improved. Code
contributions via PRs are always welcomed!
