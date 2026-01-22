# FSB Thesis Template - Community Edition

A community-made template for Master's theses at FSB (FPT School of Business and
Technology).

**Note**: This is an unofficial template, created by a student of the institute. This is not endorsed by the FPT School of Business and
Technology.

## Usage

You can use this template in the Typst web app by searching for `fsb-thesis` or
using the CLI:

```bash
typst init @preview/fsb-thesis-community-edition:0.1.0 my-thesis
```

## Configuration

The `project` function takes the following arguments:

- `title`: The title of your thesis.
- `author`: Your name.
- `degree`: Your degree (default: "Master of Software Engineering").
- `supervisors`: A list of supervisor names.
- `abstract`: Content for the abstract.
- `acknowledgments`: Content for acknowledgments.
- `bibliography`: Content for the bibliography (e.g.,
  `bibliography("refs.bib")`).
- `appendix`: Content for appendices (e.g., `include "appendix.typ"`).

## Local Development

1. Clone this repository.
2. Edit `lib.typ` to make changes to the template style.
3. Test with `typst compile template/main.typ`.
   - Note: usage in `template/main.typ` uses the package import format
     `@preview/fsb-thesis-community-edition:0.1.0`. To test locally, you may need to point it to
     `../lib.typ` or use `--root`.
