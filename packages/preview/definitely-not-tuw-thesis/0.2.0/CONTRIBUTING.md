# Contributing

Any improvements and fixes are welcome! If you notice any inconsistencies with the official template, please open an issue.

## Development setup

This project uses [Just](https://just.systems/man/en/) to have some convenience scripts (similar to `make`). You can view those in the [Justfile](./Justfile) and list them with running `just`.

## Testing

We have some visual regression tests using [tytanic](https://github.com/tingerrr/typst-test). They use fonts built into the Typst compiler, such that it is easily reproducible across different systems.

To run them, install it and use `just test` (or `tt run`). If a test fails, you will have pictures of the current rendering, the new one and an overlay of those two for comparison (they are stored next to the test files). If you want to update the images, use `just update` (or `tt update`).