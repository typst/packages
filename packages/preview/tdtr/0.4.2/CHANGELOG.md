# [0.4.2](https://github.com/Vertsineu/typst-tdtr/compare/v0.4.1...v0.4.2) (2025-12-04)


### Bug Fixes

* fix wrong function name ([e2699e2](https://github.com/Vertsineu/typst-tdtr/commit/e2699e2771afeb74c51d6aebf37530f90de93588))



# [0.4.1](https://github.com/Vertsineu/typst-tdtr/compare/v0.4.0...v0.4.1) (2025-12-01)


### Bug Fixes

* use shortcut draw function for default ([b9a2f42](https://github.com/Vertsineu/typst-tdtr/commit/b9a2f426c04b3afef76a787cd4860ec9b783fffb))


### Features

* support label match draw node/edge ([2621dba](https://github.com/Vertsineu/typst-tdtr/commit/2621dbafbb271292db376ee9ca8f9f0d36a0505c))



# [0.4.0](https://github.com/Vertsineu/typst-tdtr/compare/v0.3.0...v0.4.0) (2025-11-16)


### Bug Fixes

* limit the export functions from presets ([79bbf59](https://github.com/Vertsineu/typst-tdtr/commit/79bbf5989ba6af62f8b95e984c0db7553085ce17))
* pass dictionary instead of array ([09887f7](https://github.com/Vertsineu/typst-tdtr/commit/09887f7df13d02d36a54f1c0f98d8930ef2329d5))
* use function.with instead for better hint ([d56def7](https://github.com/Vertsineu/typst-tdtr/commit/d56def70f030469bb8cb3b96d636a8ad5a626311))


### Code Refactoring

* replace draw-graph parameter with additional-draw ([27af854](https://github.com/Vertsineu/typst-tdtr/commit/27af8544f03be37334f030a9d95218e7fc148a40))


### Features

* add pre-defined graph drawing function for fibonacci heap ([2c225da](https://github.com/Vertsineu/typst-tdtr/commit/2c225da161671bbb73b5bbb1ccf79d2200a670bd))
* add subtree-levels parameter for situations when you do not want compression in some level ([45d65a9](https://github.com/Vertsineu/typst-tdtr/commit/45d65a944914a26047b30fde09db7ed6578d0f4d))


### BREAKING CHANGES

* From now, you should replace draw-graph with additional-draw which provides much
better experience of customization



# [0.3.0](https://github.com/Vertsineu/typst-tdtr/compare/v0.2.0...v0.3.0) (2025-10-31)


### Bug Fixes

* arguments of pre-defined graph functions can be passed to tidy-tree-graph ([d416c48](https://github.com/Vertsineu/typst-tdtr/commit/d416c4828dbdbfa4a6846c5f41d5ef1ee82a32d5))


### Code Refactoring

* refactor the draw-node and draw-edge functions for better customization ([620bbaf](https://github.com/Vertsineu/typst-tdtr/commit/620bbaf1e475b863a7f506f39ca4c4a2117b43b1))


### Features

* add content tree graph function ([27cb8b5](https://github.com/Vertsineu/typst-tdtr/commit/27cb8b536d9864bce594e68e91117cfba7634928))
* add metadata-match-draw and shortcut-draw for convenience ([341a922](https://github.com/Vertsineu/typst-tdtr/commit/341a9225cb73b162e3b0192c59c14de5ef20f053))
* add pre-defined binary tree graph function ([280be86](https://github.com/Vertsineu/typst-tdtr/commit/280be8690867886772fb454b46f892adf3260df7))
* add pre-defined red black tree support ([0944939](https://github.com/Vertsineu/typst-tdtr/commit/094493904a6b60b9b88d18e95c66cdda871cb21f))
* export preset functions ([093e917](https://github.com/Vertsineu/typst-tdtr/commit/093e91719b8c2b3f553a57e3c44ef901b30b0096))
* support assign width and height to all nodes in tidy-tree-graph ([eb56464](https://github.com/Vertsineu/typst-tdtr/commit/eb56464968c8ac20ddaa34803519e051ff743da5))
* support B-tree graph ([d1ecb0c](https://github.com/Vertsineu/typst-tdtr/commit/d1ecb0cfd61c1f6f1b9b8022bc4d5ddfef335863))
* support customize draw graph function ([a07695c](https://github.com/Vertsineu/typst-tdtr/commit/a07695ca1227e27b14ecd6a0f2084078379747ae))


### BREAKING CHANGES

* The previous draw-node and draw-edge functions are not available now



# [0.2.0](https://github.com/Vertsineu/typst-tdtr/compare/v0.1.0...v0.2.0) (2025-10-28)


### Bug Fixes

* add tidy-tree-normalize before using tree-edges ([78a213b](https://github.com/Vertsineu/typst-tdtr/commit/78a213b9682fd7744d602c136d3e9a23c263b8d7))
* fix comments about yaml ([1dba373](https://github.com/Vertsineu/typst-tdtr/commit/1dba373f6c9c59eaaf0a86834b980eed3f0d9892))
* force node to be a rectangle shape ([5f8518a](https://github.com/Vertsineu/typst-tdtr/commit/5f8518a32ed2411daa4f17b8c95caf63b057adcd))
* parameter does not pass to inner function ([996b4c5](https://github.com/Vertsineu/typst-tdtr/commit/996b4c5ef55121b3f14c9c6c2000bf023afa9543))


### Features

* add circle draw node ([4a6bb23](https://github.com/Vertsineu/typst-tdtr/commit/4a6bb230d7bfc884a86bada474cc2306fc8e7189))
* add reversed draw edge ([c157f42](https://github.com/Vertsineu/typst-tdtr/commit/c157f42b06212424b260250a3009792c30b0c792))
* support edge labels ([b5d6d73](https://github.com/Vertsineu/typst-tdtr/commit/b5d6d7303124b236a870e25c21d3081687be9f45))



# [0.1.0](https://github.com/Vertsineu/typst-tdtr/compare/2a14d129a2c8a2bcccf09a6974f0da21016987f1...v0.1.0) (2025-10-18)


### Bug Fixes

* import use the package specification, not a relative path ([459a9c0](https://github.com/Vertsineu/typst-tdtr/commit/459a9c0fd9c0a6aec96afab50b4b11eaf419838f))
* overlapping between nodes when some very long nodes are siblings in fractional positions ([cc41cc9](https://github.com/Vertsineu/typst-tdtr/commit/cc41cc9a5aa152cfdea5e1be4b3d63eaf34ef949))
* restrict dictionary can not exists in array ([2a14d12](https://github.com/Vertsineu/typst-tdtr/commit/2a14d129a2c8a2bcccf09a6974f0da21016987f1))
* update package name in  README.md ([d97265b](https://github.com/Vertsineu/typst-tdtr/commit/d97265b12ef17521586ce674103a8840cae69cfb))
* update reopsitory url ([1c00645](https://github.com/Vertsineu/typst-tdtr/commit/1c00645ac0058a72e079d7c4f09c200735e69367))



