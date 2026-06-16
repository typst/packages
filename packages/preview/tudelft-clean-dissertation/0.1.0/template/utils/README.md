# Exporting all Figures

To keep the repository size down, figures are not included in the git history. But they can quickly be exported using the batch script in this directory.

The script will check all repository folders for files called `figure-source.svg` and then export with the settings above to `fig.pdf`, which is then used by Typst as the image files for figures.

# Generating rasterised figures

The thesis uses `.pdf` export of the Inkscape figures as plots. For slides or other quick reuse, it is handy to have all the figures in one place as rasterised images. You can generate `.png` exports that will end up in the [rasterised-figures](../rasterised-figures) directory[^1] using:

```shell
python rasterise-figures.py
```

# Cleaning FreeCAD svg export

It can be useful to use FreeCAD to make 3D sketches. These can then be exported as SVG using the techdraw workbench. Unfortunately, these are in a messy format. A simple python script will convert these into a format that can be dragged and dropped into inkscape.

Note: svg files that are exported by FreeCAD, but have a filename of pattern "schematic*.svg" are ignored. This allows you to include FreeCAD schematics that are not meant to be used as a 3D sketch but an actual techdraw object.

# Checking for Duplicate and Unused references

The typst compiler checks whether all refrenced items exist, but not the other way around. This means we can have items in our .bib that are not referenced by the main text. Not a big problem, but also not very clean. This script finds those items and points them out so you can remove them.

It also checks for duplicate entries, as its perfectly possible to add the same reference under different IDs. This is especially likely if you have your references split across different files. This script will also point those out, based on matching article titles.

[^1]: The `rasterised-figures` directory does not exist when cloning the repository. It is created when the utility python script is run.