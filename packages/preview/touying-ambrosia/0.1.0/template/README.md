# Start Here

Open `template.typ` in your Typst editor. This starter uses Ambrosia's project
logo; `ambrosia-theme` itself starts unbranded. Edit the metadata, flavor,
palette, `title-layout`, or `ending-layout` in the theme configuration.

The public package's README links to complete examples and configuration guides:
https://github.com/inspiros/touying-ambrosia

## Optional Slide Thumbnails

Clickable slide previews can use an uploaded slide image. Exact automatic
snapshots require a separate local export pass; the Typst web app cannot run
Python or shell commands during compilation.

No repository clone or Python package installation is required: download just
[render-slide-previews.py](https://github.com/inspiros/touying-ambrosia/raw/v0.1.0/scripts/render-slide-previews.py)
from the project repository. It needs Python 3.9+ and the Typst CLI, with no
third-party Python dependencies. See the
[preview workflow](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/slide-previews.md)
for source setup and export commands. Upload the resulting SVGs and manifest
to an online project when authoring in the browser.
