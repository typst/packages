# Contributing

Any improvements and fixes are welcome! If you notice any inconsistencies with the official template, please open an issue.

## Development setup

This project uses [Just](https://just.systems/man/en/) to have some convenience scripts (similar to `make`). You can view those in the [Justfile](./Justfile) and list them with running `just`.

## Testing

We have some visual regression tests using [typst-test](https://github.com/tingerrr/typst-test). They sadly differed between CI and my local setup, so they are not enabled currently.

To run them use `just test`. If a test fails, you will have pictures of the current rendering, the new one and an overlay of those two for comparison. If you want to update the images, use `just update`.