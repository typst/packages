# Third-Party Notices

This project redistributes and/or modifies third-party open-source software.

## License scope

The package manifest uses the aggregate SPDX expression `MIT AND BSD-3-Clause AND Apache-2.0 AND (Apache-2.0 WITH LLVM-exception)`.

- Molchemist-authored `*.typ` source is MIT-licensed.
- `molchemist_plugin.wasm` combines MIT- and Apache-2.0-licensed components. It also incorporates `wasm-minimal-protocol`, released under the Unlicense.
- `molchemist_smiles_plugin.wasm` combines MIT-, BSD-3-Clause-, and Apache-2.0-with-LLVM-exception components.

`LICENSE` contains the MIT terms for molchemist-authored code. The other license files and the notices below apply only to the corresponding third-party portions. The Unlicense is documented for transparency but omitted from the aggregate manifest expression because it imposes no redistribution conditions.

## PubChem example structure data

- Provider: National Center for Biotechnology Information (NCBI), PubChem
- Policy: NCBI Website and Data Usage Policies and Disclaimers
- Policy URL: <https://www.ncbi.nlm.nih.gov/home/about/policies/>
- Local status: redistributed as example/documentation data and rendered README images

The package includes or derives examples from PubChem molecular records:

- `docs/assets/Structure2D_COMPOUND_CID_241.sdf`
  - PubChem Compound CID 241, benzene
  - Source: <https://pubchem.ncbi.nlm.nih.gov/compound/241>
  - Retrieval: <https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/241/SDF?record_type=2d>
- `docs/assets/Structure2D_COMPOUND_CID_93406.sdf`
  - PubChem Compound CID 93406
  - Source: <https://pubchem.ncbi.nlm.nih.gov/compound/93406>
- `docs/assets/DepositedStructure_SUBSTANCE_SID_93298_Version_3.sdf`
  - PubChem Substance SID 93298
  - Source: <https://pubchem.ncbi.nlm.nih.gov/substance/93298>
- README images in `images/`
  - Generated from package examples that use PubChem-derived SDF/SMILES inputs, including PubChem CID 93406 and CID 896.
  - Sources: <https://pubchem.ncbi.nlm.nih.gov/compound/93406>, <https://pubchem.ncbi.nlm.nih.gov/compound/896>

NCBI states that it places no restrictions on the use or distribution of molecular data in its databases. NCBI also notes that some submitted data may carry third-party rights that NCBI cannot assess or transfer. These example files and derived images are therefore attributed to PubChem/NCBI here, but they are not relicensed as part of the `molchemist` MIT license.

## opensmiles

- Upstream: <https://crates.io/crates/opensmiles>
- Repository: <https://github.com/Peariforme/bigsmiles-rs>
- Copyright: Richard
- License: MIT
- Local status: compiled into `molchemist_plugin.wasm`; source is vendored and locally maintained in the molchemist repository.

MIT License

Copyright (c) 2026 Richard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## CoordgenLibs

- Upstream: <https://github.com/schrodinger/coordgenlibs>
- Copyright: Schrödinger, Inc.
- License: BSD-3-Clause
- Local status: compiled into `molchemist_smiles_plugin.wasm`; source is vendored in the molchemist repository.

BSD 3-Clause License

Copyright (c) 2017, Schrödinger, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Emscripten system runtime

`molchemist_smiles_plugin.wasm` was linked with Emscripten 5.0.5 and may incorporate Emscripten, musl, libc++, and libc++abi runtime code. The exact license texts shipped with that toolchain are redistributed with the package. Emscripten's MIT option and musl's MIT terms are used here; libc++ and libc++abi are used under Apache-2.0 with LLVM-exception:

- `LICENSE-EMSCRIPTEN`
- `LICENSE-MUSL`
- `LICENSE-LIBCXX`
- `LICENSE-LIBCXXABI`

## sdfrust

- Upstream: <https://crates.io/crates/sdfrust>
- Repository: <https://github.com/hfooladi/sdfrust>
- Copyright: 2025-2026 Hosein Fooladi
- License: MIT
- Local status: compiled into `molchemist_plugin.wasm`

MIT License

Copyright (c) 2025-2026 Hosein Fooladi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Embedded Rust support libraries

`molchemist_plugin.wasm` also contains code from `ciborium`, `ciborium-io`, `ciborium-ll`, `half`, `cfg-if`, `zerocopy`, `serde`, `serde_core`, and `thiserror`. `ciborium` is Apache-2.0 licensed; the other listed projects offer Apache-2.0 as one of their license choices. They are redistributed here under those Apache-2.0 terms.

The Rust-built plugin may also contain portions of the Rust standard library, which is available under MIT or Apache-2.0 terms and is used here under Apache-2.0.

- License text: `LICENSE-APACHE-2.0`

## wasm-minimal-protocol

- Upstream: <https://github.com/typst-community/wasm-minimal-protocol>
- License: The Unlicense
- Local status: protocol adapter code is compiled into `molchemist_plugin.wasm`

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
software, either in source code form or as a compiled binary, for any purpose,
commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>.
