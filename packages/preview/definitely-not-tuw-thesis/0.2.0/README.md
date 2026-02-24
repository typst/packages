# Unofficial thesis template for informatics at TU Wien

An example thesis can be viewed here: https://otto-aa.github.io/definitely-not-tuw-thesis/thesis.pdf

## Usage

You can download the template with:

```bash
typst init @preview/definitely-not-tuw-thesis
```

### Template overview

After setting up the template, you will have the following files:

- `thesis.typ`: overall structure and styling, configuration for the cover pages and PDF metadata
- `content/front-matter.typ`: acknowledgments and abstract
- `content/main.typ`: all your chapters
- `content/appendix.typ`: AI tools acknowledgment and other appendices
- `refs.bib`: references

Then copy the values you get from compiling the [official template](https://gitlab.com/ThomasAUZINGER/vutinfth), and paste them in `thesis.typ`. Remove all unused fields and, finally, compare if it is close enough to the official template. If not, please open an issue or PR to fix it.

### Styling

If you want to adapt the styling, you can remove the `show: ...` commands in the `thesis.typ` and replace them with your own, or simply extend them with your own `show: ...` commands.

## Contributing

I guess there are many ways to improve this template, feel free to do so and submit issues and PRs! More information at [CONTRIBUTING.md](https://github.com/Otto-AA/unofficial-tu-wien-thesis-template/blob/main/CONTRIBUTING.md)

## License

The code is licensed under MIT-0. The 'TU Wien Informatics' logo and signet are copyright of the TU Wien.

## Acknowledgments

This work is based on the [official template](https://gitlab.com/ThomasAUZINGER/vutinfth) maintained by Thomas Auzinger. The repository structure is based on [typst-package-template](https://github.com/typst-community/typst-package-template).
