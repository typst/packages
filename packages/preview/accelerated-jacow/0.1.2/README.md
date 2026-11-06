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

## Licence

Files inside the template folder are licensed under MIT-0. You can use them without restrictions.  
The citation style (CSL) file is based on the IEEE style and licensed under the [CC BY SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) compatible [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html) license.  
All other files are licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html).  
