# [v0.2.0](https://github.com/TGM-HIT/typst-diploma-thesis/releases/tag/v0.2.0)
- fix deprecation warnings and incompatibilities introduced in 0.12, in part by updating codly, glossarium and outrageous
- long chapter titles now look nicer in the header
- **breaking:** glossary entries are now defined differently, see [the diff of the template](https://github.com/TGM-HIT/typst-diploma-thesis/commit/8c4d03a14ac3ddab6718cc7e11341924c66703bd#diff-7c3fcb5c97b51160af4b4a26981b152d6995f8ec0077281456d3f51f4b0e9d84) for an example
- **regression:** if there are no glossary references, an empty glossary section will be shown (glossarium 0.5 hides a couple private functions, see [glossarium#70](https://github.com/typst-community/glossarium/issues/70))

# [v0.1.3](https://github.com/TGM-HIT/typst-diploma-thesis/releases/tag/v0.1.3)
- get rid of more custom outline styling thanks to outrageous:0.2.0

# [v0.1.2](https://github.com/TGM-HIT/typst-diploma-thesis/releases/tag/v0.1.2)
(this version was released in a broken state)

# [v0.1.1](https://github.com/TGM-HIT/typst-diploma-thesis/releases/tag/v0.1.1)
- replaces some custom outline styling with [outrageous](https://typst.app/universe/package/outrageous)
- adds support for highlighting authors of individual pages of the thesis, which is a requirement for the thesis' grading

# [v0.1.0](https://github.com/TGM-HIT/typst-diploma-thesis/releases/tag/v0.1.0)
Initial Release
