# Changelog

All notable changes to this project will be documented in this file.

--------------------------------------------------------------------
Below is the old changelog from the HEI template
--------------------------------------------------------------------

## [0.2.3] - 2025-10-18

### 🐛 Bug Fixes

- (cicd): get latest tag from the typst config file ([737a31f](https://github.com/hei-templates/hei-synd-thesis/commit/737a31fb769b228932323b957f72f6aef713f5ad) - zas)
- _(just)_ Add release recipe and fix copy errors ([08b689a](https://github.com/hei-templates/hei-synd-thesis/commit/08b689a6227c08e51a26a9ca6127721febe50c4f) - zas)
- _(libs)_ Latest version of icu-datetime ([453815f](https://github.com/hei-templates/hei-synd-thesis/commit/453815f6e539b8dfb2374586a30e568db998afd9) - zas)

### ⚙️ Miscellaneous Tasks

- _(libs)_ Bump all libs for proper 0.2.3 release ([8b5df5a](https://github.com/hei-templates/hei-synd-thesis/commit/8b5df5a9cefb45283ee8dfcc36edfd0b6a5f64b3) - zas)
- Pedantic typst release check ([746a3ce](https://github.com/hei-templates/hei-synd-thesis/commit/746a3ced9c5db12e9f2ce8e0689a0b95543c7368) - zas)

**Full Changelog**: [0.2.2...0.2.3](https://github.com/hei-templates/hei-synd-thesis/compare/0.2.2...0.2.3)

## [0.2.2] - 2025-07-31

### 🚀 Features

- _(lib)_ Add datapage feature ([60f59ed](https://github.com/hei-templates/hei-synd-thesis/commit/60f59edf4a69ba7954be7f01dac4bf5a13b5a922) - zas)

### 🐛 Bug Fixes

- _(readme)_ Orthograph for pedantic pr checker ([b7eedc5](https://github.com/hei-templates/hei-synd-thesis/commit/b7eedc5d67e1f93c364f30d08278de7c38a10915) - zas)

### ⚙️ Miscellaneous Tasks

- _(packages)_ Bump package versions ([5f5834c](https://github.com/hei-templates/hei-synd-thesis/commit/5f5834cee047c6aa1baedfd3bdeaed6d906fdcbf) - zas)

**Full Changelog**: [0.2.1...0.2.2](https://github.com/hei-templates/hei-synd-thesis/compare/0.2.1...0.2.2)

## [0.2.1] - 2025-06-20

### 🚀 Features

- _(template)_ Add codly& cheq package, customize codelst ([6393b3c](https://github.com/hei-templates/hei-synd-thesis/commit/6393b3cf3e01a519f9da0a4853084e6a4426b5fb) - zas)
- _(template)_ Add syntax files within helpers ([eb7150b](https://github.com/hei-templates/hei-synd-thesis/commit/eb7150b8b0dd5154e8ef4eb56c8135287df8267e) - zas)

### 🐛 Bug Fixes

- _(ci)_ Remove typst version to use always latest ([da9fc8d](https://github.com/hei-templates/hei-synd-thesis/commit/da9fc8d486e772d4d2deae4a99ec3ec21fb125ef) - Klagarge)
- _(template)_ Sample content ([2641cbe](https://github.com/hei-templates/hei-synd-thesis/commit/2641cbe7a383b591ad55c5c46eb73cae395e9b76) - zas)
- _(just)_ Watch also opens the file ([4296458](https://github.com/hei-templates/hei-synd-thesis/commit/42964589ef57829dbfb3769cab20dfc5c4a9ba04) - zas)
- _(template)_ Option comments ([1327420](https://github.com/hei-templates/hei-synd-thesis/commit/132742064e04b2f37a072919f9f855c550b6dcdb) - zas)

### 💼 Other

- Merge branch fix/typst-version

fix(ci): remove typst version to use always latest ([2c3178b](https://github.com/hei-templates/hei-synd-thesis/commit/2c3178b404e3c26c04eac0496b98abe073919609) - Klagarge)

- Merge remote-tracking branch 'origin/main' into fix/deployment ([1d9bc46](https://github.com/hei-templates/hei-synd-thesis/commit/1d9bc469aea289f405921b2395c957a6093c52ab) - zas)

### 🚜 Refactoring

- _(just)_ Only copy required files ([d4de112](https://github.com/hei-templates/hei-synd-thesis/commit/d4de11274fc352427ea07f0a33fe2189199f20b1) - zas)

### ⚙️ Miscellaneous Tasks

- _(release)_ Update sample images ([bdeba65](https://github.com/hei-templates/hei-synd-thesis/commit/bdeba656d3c6b15aa875ac0c352201bc87a289c5) - zas)

**Full Changelog**: [0.2.0...0.2.1](https://github.com/hei-templates/hei-synd-thesis/compare/0.2.0...0.2.1)

## [0.2.0] - 2025-06-10

### 🚀 Features

- Feat(date): add date in multiple languages thanks to icu-datetime package
  feat(gender): add the possibility to define the gender which adds gender inclusive words for fr, de and en ([4090ea8](https://github.com/hei-templates/hei-synd-thesis/commit/4090ea8aa5e880afc341877505e281f9490790d2) - zas)
- _(just)_ Add typst inputs ([edf815c](https://github.com/hei-templates/hei-synd-thesis/commit/edf815c5eba3536dfef6b931a7720583a9e51fed) - zas)
- _(cliff)_ Add cliff config to support legacy commits ([ac8a9e2](https://github.com/hei-templates/hei-synd-thesis/commit/ac8a9e22d79409e389786008a739ca5a95909c81) - zas)
- _(ignore)_ Add gitignore ([6c16501](https://github.com/hei-templates/hei-synd-thesis/commit/6c165010a524cad63d7f797bca5bd060f4a7cd04) - zas)
- _(just)_ Cliff functionality ([ab8b629](https://github.com/hei-templates/hei-synd-thesis/commit/ab8b6296f4fe4e5ae4284743135de545aca46ae7) - zas)

### 🐛 Bug Fixes

- _(tianji)_ New url for tianji ([d21ecd9](https://github.com/hei-templates/hei-synd-thesis/commit/d21ecd923bc3c2832867a246cd2af86fba42cd0d) - zas)

### 💼 Other

- Merge pull request #9 from hei-templates/fix/2025-zas

feat(date): add date in multiple languages thanks to icu-datetime package
feat(gender): add the possibility to define the gender which adds gender inclusive words for fr, de and en ([f0e05fc](https://github.com/hei-templates/hei-synd-thesis/commit/f0e05fcd328750320a30da57df7e16d2c1c58577) - Klagarge)

- _(links)_ Add link checker workflow with issue reporting ([888b570](https://github.com/hei-templates/hei-synd-thesis/commit/888b570feda71798bbfffdf6820e3d9aa32e5ee7) - Klagarge)
- _(release)_ Add release workflow with build and changelog ([bfedac9](https://github.com/hei-templates/hei-synd-thesis/commit/bfedac90c6016cb6c175d58bf9d109a75dc8c63c) - Klagarge)
- _(release)_ Add build matrix ([2fec06c](https://github.com/hei-templates/hei-synd-thesis/commit/2fec06c5c9bbe24bcb2609e45be46ae65aea8c1e) - Klagarge)
- _(release)_ Fix typo about release version env ([8fd6fc1](https://github.com/hei-templates/hei-synd-thesis/commit/8fd6fc10997e57aaed49691095ab07c4e5863849) - Klagarge)

### 🚜 Refactoring

- _(version)_ Centralise version number in metadata.typ ([9c04cd7](https://github.com/hei-templates/hei-synd-thesis/commit/9c04cd748718e7a42ce8fef5d858019585d20d38) - Klagarge)
- _(config)_ Fix repo URL and change commit splitting behavior ([5024037](https://github.com/hei-templates/hei-synd-thesis/commit/50240372016e0e7a0af5703505685d69ecdab47d) - Klagarge)
- _(lib)_ Remove unused option-scripts ([43fd7df](https://github.com/hei-templates/hei-synd-thesis/commit/43fd7dfe9e4fb1befdd137a32b56fde0f544920a) - zas)

### 📚 Documentation

- _(readme)_ Update with latest features ([335074b](https://github.com/hei-templates/hei-synd-thesis/commit/335074bb705593273ac7f33bb81b272c5887ed15) - zas)

### ⚙️ Miscellaneous Tasks

- _(release)_ Bump version to 0.2.0 ([6292a69](https://github.com/hei-templates/hei-synd-thesis/commit/6292a69d0b21c7709c94e0da9c31a68d330b6781) - zas)

**Full Changelog**: [0.1.1...0.2.0](https://github.com/hei-templates/hei-synd-thesis/compare/0.1.1...0.2.0)

## [0.1.1] - 2025-02-24

### 🚀 Features

- _(telemetry)_ Visitor counter

### 🐛 Bug Fixes

- _(kebab-case)_ Following typst convention
- _(telemetry)_ Visitorlink
- _(tianji)_ Link to tianji
- _(tianji)_ Link to tianji
- _(typst)_ Compatibility with typst 0.13.0
- _(template)_ Update to new template version number
- _(packages)_ Update packages to the latest version glossarium & fracturist
- _(import)_ Wrong package imported hei-synd-report instead of hei-synd-thesis

### ⚙️ Miscellaneous Tasks

- _(changelog)_ Release 0.1.1

## [0.1.0] - 2025-02-03

### 🚀 Features

- _(glossarium)_ Add glossarium for the acronym and glossary function replacing the legacy acr-\* tools
- _(page)_ Summary page
- _(template)_ Additional feature such as add_chapter, new logos ,etc.
- _(lang)_ Add i18n features
- _(lang)_ I18n for all elements found in the template (de, en, fr)
- _(draft)_ Add informations on how to write each section in the draft version of the thesis
- _(metadata)_ All metadata is optional and can be omitted
- _(box)_ Add personnal todo and table of todos
- _(template)_ Change page numbering before toc

### 🐛 Bug Fixes

- Fix justfile
- _(template)_ Compatible with typst 0.12
- _(readme)_ Typos and image placement
- _(bibliography)_ Remove examples
- _(toc)_ Maxdepth of toc
- _(readme)_ Fix some links
- _(glossary)_ Fix heading level for groupes title
- _(image)_ Remove equal salary from the bottom-right logo

### 💼 Other

- Initial commit
- :tada: inital commit
- More information in the readme, better images
- File extension
- Logo positions
- File links
- File download link
- For typst v0.8.0
- Install description in readme
- License change
- Author information
- Fonts
- Proper logos supporting github darkmode
- Readme
- Adapted for typst v0.9.0
- Karnaugh
- Paragraph spacing from 0.55em to 1em
- Sections for Titlepage
- Vhdl code syntax highlighting
- Raw settigns
- Thesis title
- For 2024 edition
- Latest version of guide*to*...
- More detailed instruction for windows (vscode gitbash ps in admin mode)
- Typos
- Merge pull request #4 from Klagarge/typos
- Typo in dean name + fix justfile
- Link typos for guide to typst
- UPD tablex from preview
- CHG use glossarium package
- RM sections
- UPD glossarium to 0.4.2
- FIX path to absolute
- ADD placeholder constant
- ADD specifications + summary
- ADD todo function
- Red callout for writter
- FIX minitoc
- ADD function to add-chapter
- ADD subtitle
- CHG refactor with add-chapter
- FIX subtitle + dates
- ADD midterm title page version
- ADD flexible type of report
- UPD logos to svg
- FIX title page and abstract
- FIX heading indent and TOC
- FIX full-page and add-chapter
- FIX summary
- ADD Todo example
- UPD glossary
- UPD Typst 0.12
- _(template)_ Adapt project for the typst universe

### 🚜 Refactor

- _(template)_ Big refactor to uniform typst code from Remi across all templates
- _(template)_ Move functions to different files where they make more sense
- _(template)_ Page-_ change to one file per templates pages-_
- _(template)_ Move 00-templates into a the subfolder
- _(template)_ Add 03-tails into the 00-global-template also to be distributed automatically
- _(template)_ All path are absolute to the project source
- _(template)_ Remove all tablex uses in the templates
- _(item)_ Items have a body

### ⚙️ Miscellaneous Tasks

- _(font)_ Add new libertinus font
- _(bibliography)_ Remove soa of soa by a own publication
- _(typst)_ Change function and variable names according to conventions
- _(img)_ Add sample and thumbnail images as well as latest version of all logos
- _(release)_ Add changelog
- _(thumbnail)_ Update thumbnail
- _(sample)_ Update sample
- _(readme)_ Add last extentions to the readme
- _(release)_ Add changelog for 0.1.0 release
