# Research workbook migration

A 71-page LaTeX/KOMA-Script research workbook was used as a real consuming
document to exercise satz's report layout. The active source contains ten
section files, 65 tabular environments, seven TikZ diagrams, and thirteen
existing result plots. Research content and participant data are kept outside
this repository.

## Changes justified by the document

`class.typ` now uses `tables.inset` and `tables.font-size`. Both configuration
keys already existed but were ignored: cell padding was hard-coded and tables
inherited the surrounding text size. Defaults retain 8pt horizontal / 4pt
vertical padding; the documented 10pt table font now takes effect. This can
change table wrapping and pagination. Local table/text rules remain available
for individual tables.

The workbook uses explicit overrides for STIX Two Text/Math, paragraph leading,
heading sizes, white paper, and muted running headers. Its cover, callouts,
repeated table headers, and diagrams use native Typst content. Existing result
PDFs remain vector images. No additional diagram dependency was necessary.

## Keep these decisions at the document level for now

| Requirement | Working solution | Reason to keep it local |
| --- | --- | --- |
| Long explanatory boxes | Breakable `block`, sticky title, a restrained left rule | The public callout variants and configuration need another consuming document. |
| Multi-page result tables | Native `table.header`, explicit text/numeric column widths, attached top caption | A table helper needs to distinguish data tables from complex grouped tables. |
| Small participant tables | Keep each native table together; allow breaks between grouped tables | The appropriate size threshold depends on row height and page geometry. |
| Eleven-stage analysis map | One block per stage, pagination between stages | A giant unbreakable canvas makes the text smaller or pushes it outside the page. |
| Wide estimator comparisons | Vertical steps in two columns | Readable equations matter more than reproducing the original horizontal arrangement. |
| Figure/table identity | Explicit `kind: image` for a diagram implemented with a table | Automatic kind inference otherwise calls the diagram a table and changes references. |

## Verification

The conversion records the active input files and their hashes, every table's
cells, and all seven diagram labels. Validation checks the source/converted
table counts, decimal values, references, document bounds, and header/footer
positions. Rendered pages must also be reviewed: a successful compilation does
not detect a caption left on the previous page or an inconvenient table split.

The table configuration regression is executable with
`python3 examples/latex-parity/check_tables.py`. It checks actual PDF text sizes
and cell padding, an explicit local override, repeated headers, and preservation
of all rows across page breaks. The migrated workbook and the existing report
and journal examples provide consuming-document checks.

## Contents styling controls

The workbook comparison also exposed useful missing controls for a report's
contents page. The `toc` config now has `entry-size`, `leading`, `entry-above`,
`main-entry-above`, and `title-below`. Main-section entries are bold and use
the brand color; the report can tune the title gap and section-group spacing
without replacing Typst's native outline links and page numbers. The workbook
sets these locally to match the source KOMA-Script layout.
