# Contributing

Thank you for your interest in `scribbling-hm`! Changes to the template often
directly affect the generated layout. Please therefore check the corresponding
visual tests in addition to the Typst code.

## Prerequisites

For development, you need:

- [Typst](https://typst.app/) (CI tests with Typst `0.13.0`, `0.14.0`, and
  `0.15.0`)
- [tytanic](https://github.com/typst-community/tytanic) (`tt`)

The tests use absolute imports such as `/src/...`; run them from the repository
root.

## Running tests

Run the complete test suite with:

```bash
tt run
```

You can run an individual test by its directory name:

```bash
tt run declaration
```

The tests in [`tests/`](./tests/) compile Typst documents and compare the
generated pages with the reference images stored in their respective `ref/`
directories. If a comparison fails, tytanic also stores the current output in
`out/` and the differences in `diff/`. These files help determine whether the
change was intentional.

The examples can be compiled separately:

```bash
make -C examples
```

## Updating reference images

If an intentional change modifies the layout or content of a test, the
reference images must be updated. For example, a change to the declaration may
affect the test in [`tests/declaration/`](./tests/declaration/).

1. First run the affected test and inspect the files in `diff/` and `out/`.
2. If the difference is entirely intentional, update the references for that
   specific test:

   ```bash
   tt update declaration
   ```

   Use `tt update` to update all tests.
3. Run the test again with `tt run declaration`.
4. Review the changes to the PNG files in the pull request. Reference images
   must not be updated merely to make a test pass.

Reference images are part of the test and must be committed together with the
intentional visual change. The temporary `out/` and `diff/` directories should
not be committed.

## Pull requests

A pull request should:

- contain a focused change and explain its motivation,
- cover new or changed functionality with appropriate tests,
- include updated reference images for visual changes,
- pass `tt run` and, where relevant, `make -C examples`,
- not include generated files from `out/` or `diff/`.

GitHub Actions automatically run the tests against multiple Typst versions. If
a change intentionally works only with a specific Typst version, explain this
in the pull request.
