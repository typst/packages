# The `sleek-university-assignment` package

A sleek Typst template for writing university assignments.

## Usage

To use this template, simply import it from the [Typst Universe][typ-uni].

```typ
#import "@preview/sleek-university-assignment:0.1.0": assignment

#show: assignment.with(
  title: "Assignment",
  authors: (
    (
      name: "John Doe",
      email: "john.doe@example.com",
      student-no: "123/XXX",
    ),
  ),
  course: "CSXXXX: Cryptography",

  // NOTE: Optionally specify this for a university logo on the first page.
  // university-logo: image("./images/uni-logo.svg"),
)

<Your content here>
```

For further details, please refer to the [manual](./docs/manual.pdf).

[typ-uni]: https://typst.app/universe/
