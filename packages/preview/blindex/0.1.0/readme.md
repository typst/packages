# Blindex - An index maker for biblical literature citations in documents

`blindex` is a `typst` package specifically designed for the generation of indices of biblical
literature citations in documents.

## Index Sorting Options

The generated indices are gathered and sorted by biblical literature books, which can be ordered
according to various biblical literature book ordering conventions, including:

- `"LXX"` -- The Septuagint;
- `"Greek-Bible"` -- Septuagint + New Testament (King James);
- `"Hebrew-Tanakh"` -- The Hebrew (Torah + Neviim + Ketuvim);
- `"Hebrew-Bible"` -- The Hebrew Tanakh + New Testament (King James);
- `"Protestant-Bible"` -- The Protestant Old + New Testaments;
- `"Catholic-Bible"` -- The Catholic Old + New Testaments;
- `"Orthodox-Bible"` -- The Orthodox Old + New Testaments;
- `"Oecumenic-Bible"` -- The Jewish Tenakh + Old Testament Deuterocanonical + New Testament;
- `"code"` -- All registered biblical literature books: All Protestant + All Apocripha.

## Minimalistic Examples

`blindex` can be used (i) by "raw" indexing functions `blindex` and `mkindex`, or (ii) by
higher-level typesetting and indexing functions `iQuot` and `bQuot`, respectively for inline and
block quoting of biblical literature, and `mkindex` for index typesetting.

### 

