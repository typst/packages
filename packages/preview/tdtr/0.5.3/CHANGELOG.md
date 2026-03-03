# [0.5.3](https://github.com/Vertsineu/typst-tdtr/compare/v0.5.2...v0.5.3) (2026-02-23)


### Bug Fixes

* **coords:** make sure average spacing do not cause right child on left of the left child ([5fb434c](https://github.com/Vertsineu/typst-tdtr/commit/5fb434c0f2f24d2c30720af1b393107aa0310acd))
* sink down too much produces error ([81c4d87](https://github.com/Vertsineu/typst-tdtr/commit/81c4d87dd10d4383dafa4d8e2d8a99840a4a41b9))
* treat rotated subtree truly as if it's a leaf node ([7e179ca](https://github.com/Vertsineu/typst-tdtr/commit/7e179ca7f7584193d0c7df9b4cd0d4a66ca387b5))


### Features

* **coords:** make sink align to forest macro ([a80e57d](https://github.com/Vertsineu/typst-tdtr/commit/a80e57d88e946494f0217b852766fc5a5be4e83c))
* **draws:** add south north draw edge ([95bee96](https://github.com/Vertsineu/typst-tdtr/commit/95bee9625c2077505d9a24564a7576b61bbbe61e))
* support sink down the subtree as the forest does ([7ddd7c4](https://github.com/Vertsineu/typst-tdtr/commit/7ddd7c4f31e1df9416846063c19e2c905848552c))


### Reverts

* **coords:** make fit option avaiable for leaf nodes ([e8e8d0c](https://github.com/Vertsineu/typst-tdtr/commit/e8e8d0cec56a1ccd457ff32e5c7aa9dfd9f858cc))



## [0.5.2](https://github.com/Vertsineu/typst-tdtr/compare/v0.5.1...v0.5.2) (2026-02-17)


### Bug Fixes

* **draws:** edge label do not work by incorrect label-wrapper ([6ddbd3b](https://github.com/Vertsineu/typst-tdtr/commit/6ddbd3b131cfda0968c14628539c6ff65721f000)), closes [#7](https://github.com/Vertsineu/typst-tdtr/issues/7)



## [0.5.1](https://github.com/Vertsineu/typst-tdtr/compare/v0.5.0...v0.5.1) (2026-02-14)


### Bug Fixes

* do not export all for draws.typ ([75a3c59](https://github.com/Vertsineu/typst-tdtr/commit/75a3c59f23441ead6a2e776aa7df84da566f8b0d))
* edge label with zero width and height will be drawn as a white point ([04ba2bd](https://github.com/Vertsineu/typst-tdtr/commit/04ba2bd07c0b92758485293c0447f197197ebe9e)), closes [#6](https://github.com/Vertsineu/typst-tdtr/issues/6)



# [0.5.0](https://github.com/Vertsineu/typst-tdtr/compare/v0.4.4...v0.5.0) (2026-01-19)


### Bug Fixes

* do not move left when averaging ([5f449a0](https://github.com/Vertsineu/typst-tdtr/commit/5f449a0fe536eb21d542489b45fb9c3edf91372c))
* use panic instead of error ([f39f88b](https://github.com/Vertsineu/typst-tdtr/commit/f39f88bda2e421c1a86e0477c72a2f0aac3b6869))


### Features

* add absolute-draw-node function for absolute coordinates ([b5208e2](https://github.com/Vertsineu/typst-tdtr/commit/b5208e295b6810a646c86758008e7ba5204635b9))
* support append additional drawing functions to pre-defined graph drawing functions ([ef7bbaf](https://github.com/Vertsineu/typst-tdtr/commit/ef7bbaf6783bbe626f77eb9c68864659dd4ffbc3))
* support fit subtree into various manners ([e9cd65e](https://github.com/Vertsineu/typst-tdtr/commit/e9cd65ee0d82cff3100c80b91546b8511c9c19a3))
* support node attributes for layout guidance ([71e6bb3](https://github.com/Vertsineu/typst-tdtr/commit/71e6bb39483b11445bcc7aa99fe7c15e6ccf1ffc))
* support ratio for align-to ([18e73f6](https://github.com/Vertsineu/typst-tdtr/commit/18e73f65e8758b9f65f330b4c0794ef898b42861))
* support rotate a tree at any node ([046eb2f](https://github.com/Vertsineu/typst-tdtr/commit/046eb2f14a44d5a12b20396a171a0842a226e5d8))



## [0.4.4](https://github.com/Vertsineu/typst-tdtr/compare/v0.4.3...v0.4.4) (2026-01-13)


### Bug Fixes

* wrong parse when std.table and std.grid as leaf node ([4f0f8c6](https://github.com/Vertsineu/typst-tdtr/commit/4f0f8c618d00c5dacfd70be715f4240dc83121a9)), closes [#4](https://github.com/Vertsineu/typst-tdtr/issues/4)



## [0.4.3](https://github.com/Vertsineu/typst-tdtr/compare/v0.4.2...v0.4.3) (2025-12-11)


### Features

* add `horizontal-draw-node` function ([a05e967](https://github.com/Vertsineu/typst-tdtr/commit/a05e967f449c422fc5444d2b706d160e20413810))
* add hidden drawing functions ([1b9cc4b](https://github.com/Vertsineu/typst-tdtr/commit/1b9cc4bc5121fb9f74e0c15f1992b17232f3556c))



## [0.4.2](https://github.com/Vertsineu/typst-tdtr/compare/v0.4.1...v0.4.2) (2025-12-04)


### Bug Fixes

* fix wrong function name ([e2699e2](https://github.com/Vertsineu/typst-tdtr/commit/e2699e2771afeb74c51d6aebf37530f90de93588))



## [0.4.1](https://github.com/Vertsineu/typst-tdtr/compare/v0.4.0...v0.4.1) (2025-12-01)


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

* add tidy-tree-normalize before using tree-edges ([78a213b](https://github.com/Vertsineu/typst-tdtr/commit/78a213b9682fd7744d602c136d3e9a23c263b8d7))
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



# [0.2.0](https://github.com/Vertsineu/typst-tdtr/compare/2a14d129a2c8a2bcccf09a6974f0da21016987f1...v0.2.0) (2025-10-27)


### Bug Fixes

* fix comments about yaml ([1dba373](https://github.com/Vertsineu/typst-tdtr/commit/1dba373f6c9c59eaaf0a86834b980eed3f0d9892))
* force node to be a rectangle shape ([5f8518a](https://github.com/Vertsineu/typst-tdtr/commit/5f8518a32ed2411daa4f17b8c95caf63b057adcd))
* import use the package specification, not a relative path ([459a9c0](https://github.com/Vertsineu/typst-tdtr/commit/459a9c0fd9c0a6aec96afab50b4b11eaf419838f))
* overlapping between nodes when some very long nodes are siblings in fractional positions ([cc41cc9](https://github.com/Vertsineu/typst-tdtr/commit/cc41cc9a5aa152cfdea5e1be4b3d63eaf34ef949))
* parameter does not pass to inner function ([996b4c5](https://github.com/Vertsineu/typst-tdtr/commit/996b4c5ef55121b3f14c9c6c2000bf023afa9543))
* restrict dictionary can not exists in array ([2a14d12](https://github.com/Vertsineu/typst-tdtr/commit/2a14d129a2c8a2bcccf09a6974f0da21016987f1))
* update package name in  README.md ([d97265b](https://github.com/Vertsineu/typst-tdtr/commit/d97265b12ef17521586ce674103a8840cae69cfb))
* update reopsitory url ([1c00645](https://github.com/Vertsineu/typst-tdtr/commit/1c00645ac0058a72e079d7c4f09c200735e69367))


### Features

* add circle draw node ([4a6bb23](https://github.com/Vertsineu/typst-tdtr/commit/4a6bb230d7bfc884a86bada474cc2306fc8e7189))
* add reversed draw edge ([c157f42](https://github.com/Vertsineu/typst-tdtr/commit/c157f42b06212424b260250a3009792c30b0c792))
* support edge labels ([b5d6d73](https://github.com/Vertsineu/typst-tdtr/commit/b5d6d7303124b236a870e25c21d3081687be9f45))



