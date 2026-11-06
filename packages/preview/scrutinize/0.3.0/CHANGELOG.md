# [unreleased](https://github.com/SillyFreak/typst-scrutinize/releases/tag/)
## Added

## Removed

## Changed

## Migration Guide from v0.1.X

---

# [v0.3.0](https://github.com/SillyFreak/typst-scrutinize/releases/tag/v0.3.0)
Scrutinize 0.3.0 is a major breaking release and adds compatiblitity checks for Typst 0.12 compatibility (this version was released when 0.12.0-rc1 was available).

## Added
- the README now contains images of an example exam
- the task kinds `free-form.lines()`, `free-form.grid()` and `gap.gap()` were added
- `free-form` and `gap` tasks have additional configuration options:
  - `stretch` resizes the response space relative to the size of the sample solution
  - `placeholder` adds content to show in the answer space in the unsolved exam. This is useful for tasks where something existing needs to be completed.
- tasks can now be fetched in a "scope" of the document, allowing e.g. multiple independent exams

## Changed
- the module stucture was changed
  - the `question` module was renamed to `task` to be shorter and more general
  - `questions` was renamed to `task-kinds` to match, and to be more descriptive
  - from `questions`, the new `solution` module was extracted: `solution` provides facilities for working with the sample solution boolean state, and different task kinds utilize this for displaying different kinds of information
  - `task-kinds` doesn't directly hold the task functions; it holds submodules that group them
- the `q()` function (now `t()`) does not wrap a whole task but instead attaches to the preceding heading
- tasks can now have subtasks, by using nested headings

---

# [v0.2.0](https://github.com/SillyFreak/typst-scrutinize/releases/tag/v0.2.0)
Scrutinize 0.2.0 updates it to Typst 0.11.0, using context to simplify the API and --input to more easily specify if a sample solution is to be generated. Some documentation and metadata errors in the 0.1.0 submission were also corrected.

## Added
- specify solution state via `--input solution=true`

## Changed
- functions that formerly took callback parameters to give access to state now depend on context being provided and simply return a value

---

# [v0.1.0](https://github.com/SillyFreak/typst-scrutinize/releases/tag/v0.1.0)
Initial Release
