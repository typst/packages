# Accelerated JACoW template for typst

[![GitHub Repository](https://img.shields.io/badge/GitHub%20Repo-eltos%2Faccelerated--jacow-lightgray)](https://github.com/eltos/accelerated-jacow)
[![Typst Universe](https://img.shields.io/badge/Typst%20Universe-accelerated--jacow-%23219dac)](https://typst.app/universe/package/accelerated-jacow)


Paper template for conference proceedings in accelerator physics.

Based on the JACoW guide for preparation of papers
available at https://jacow.org/.

## Usage

### Typst web app
In the [typst web app](https://typst.app/app?template=accelerated-jacow) select "start from template" and search for the accelerated-jacow template.
Alternatively, use the "create project" button at the top of the package's [typst universe page](https://typst.app/universe/package/accelerated-jacow).

### Local installation
Run these commands inside your terminal:
```sh
typst init @preview/accelerated-jacow
cd accelerated-jacow
typst watch paper.typ
```

If you don't yet have the *TeX Gyre Termes* font family, you can install it with `sudo apt install tex-gyre`.

![Thumbnail](thumbnail.webp)

### API documentation

```typ
 #import "@preview/accelerated-jacow:0.1.3": jacow, jacow-table
```

To apply the template, use the `jacow` function with a show rule (see [template/paper.typ](template/paper.typ#L14-L45) for a comprehensive example):
```typ
#show: jacow.with(
  title: [ Paper title ],
  authors: (),
  affiliations: (:),
  funding: "Work supported by ...",
  abstract: [ #lorem(20) ],
)
```
It expects the following parameters:
- `title` (content): The paper title
- `authors` (list): The list of authors.
  Each author is specified as a dict with the following keys:
  - `name` (str) or `names` (list of str): The name of the author, or a list of author names with the same affiliations(s)
  - `at` (str or list): The affiliation of the author(s), or a list of affiliations with the first one being the primary affiliation.
    The affiliation is specified as string corresponding to a key in the affiliations dictionary (see below).
    Primary affiliations may alternatively be specified directly in their full form ("Affiliation, City, Country").
  - `email` (str, optional): The email address for the corresponding author(s)
- `affiliations` (dict): Dictionary mapping affiliation keys as used with `at` in the author list to their full form (str or content, e.g. "Affiliation, City, Country").
  It is possible to insert newline characters to manually adjust the layout if required.
- `abstract` (content): The abstract
- `pubmatter` (dict, optional): Pubmatter object with `title`, `author`, `affiliations` and/or `abstract` if not passed explicitly, e.g. `pubmatter.load(yaml("frontmatter.yml"))`
- `funding` (str, optional): The funding note
- `draft-note` (content, optional): A draft note (such as "Version 1") to be displayed in the top right corner
- `page-limit` (int, optional): Generate a warning if the paper (excluding references) exceeds the page limit
- `show-line-numbers` (bool, optional): Switch to enable line numbers
- `show-grid` (bool, optional): Switch to enable a measurement grid for debugging purposes
- `paper-size`: (str, optional): The paper size. One of "a4", "letter" or "jacow" (default), the latter being the intersection of the two former ones.

In accordance with the JACoW style guide, the author list is automatically grouped by affiliation and sorted alphabetically, with the corresponding author preceding other authors.


The `jacow-table` function is a smart wrapper around typst's table that applies the typical jacow style (boldface header and horizontal lines):
```typ
#figure(
  jacow-table("<colspec>", header: top, // top, left, top+left or none
    [Table], [Content], [...],
  ),
  placement: auto, // top, bottom or auto
  caption: [...]
)
```
where
- `<colspec>` (str) is the column specification, a string where each character represents a column (`a` for auto aligned, `c` for center aligned, `l` for left aligned, `r` for right aligned)
- `header` (alignment, optional) is the header position (top and/or left)
- other arguments and cell contents are passed to the [table](https://typst.app/docs/reference/model/table) function 

See [template/paper.typ](template/paper.typ) for a usage example.


## Licence

Files inside the template folder are licensed under MIT-0. You can use them without restrictions.  
The citation style (CSL) file is based on the IEEE style and licensed under the [CC BY SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) compatible [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html) license.  
All other files are licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html).  
