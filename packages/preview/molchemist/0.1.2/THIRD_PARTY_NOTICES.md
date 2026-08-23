# Third-Party Notices

This project redistributes and/or modifies third-party open-source software.

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
  - Generated from package examples that use PubChem-derived SDF/SMILES inputs,
    including PubChem CID 93406 and CID 896.
  - Sources: <https://pubchem.ncbi.nlm.nih.gov/compound/93406>,
    <https://pubchem.ncbi.nlm.nih.gov/compound/896>

NCBI states that it places no restrictions on the use or distribution of molecular data in its databases. NCBI also notes that some submitted data may carry third-party rights that NCBI cannot assess or transfer. These example files and derived images are therefore attributed to PubChem/NCBI here, but they are not relicensed as part of the `molchemist` MIT license.

## opensmiles

- Upstream: <https://crates.io/crates/opensmiles>
- Repository: <https://github.com/Peariforme/bigsmiles-rs>
- Copyright: Richard
- License: MIT
- Local status: vendored and locally maintained for `molchemist`'s SMILES parser needs. The local copy includes compatibility and bug-fix changes used by this package.

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
- Local status: vendored in the SMILES layout plugin

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
