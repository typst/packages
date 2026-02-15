#import "src/akatable.typ": academic-table

// ── Table 1: Simple baseline ────────────────────────────────────────────────

#academic-table(
  [Baseline table with three columns],
  header: ([Name], [Profession], [Lifespan]),
  (
    [Edgar Allan Poe], [Writer], [1809--1849],
    [Albert Einstein], [Physicist], [1879--1955],
    [Marie Curie], [Chemist], [1867--1934],
  ),
  columns: 3,
)

// ── Table 2: Multi-level (nested) headers ───────────────────────────────────

#academic-table(
  [Clinical outcomes by treatment group],
  header: (
    table.cell(rowspan: 2)[Metric],
    table.cell(colspan: 2, align: center)[Treatment A],
    table.cell(colspan: 2, align: center)[Treatment B],
    table.hline(),
    [Before], [After], [Before], [After]
  ),
  (
    [Weight (kg)], [72.1], [68.3], [71.8], [70.2],
    [BMI],         [24.5], [22.1], [24.3], [23.8],
    [BP (mmHg)],   [130],  [120],  [128],  [125],
    [Heart rate],  [78],   [72],   [80],   [74],
  ),
  columns: 5,
)

// ── Table 3: Grouped rows with subtotals ────────────────────────────────────

#academic-table(
  [Research project budget by category],
  header: ([Category], [Item], [Year 1 (\$)], [Year 2 (\$)]),
  (    
    // Personnel group
    [Personnel], [Salaries],       [45,000], [46,000],
    [],          [Benefits],       [12,000], [12,500],
    [],          [Travel],         [5,000],  [6,000],
    table.hline(stroke: 0.5pt),
    table.cell(colspan: 2, align: right)[*Subtotal*], [*62,000*], [*64,500*],
    table.hline(stroke: 0.5pt),

    // Equipment group
    [Equipment], [Hardware],       [8,000],  [2,000],
    [],          [Software],       [3,500],  [3,500],
    table.hline(stroke: 0.5pt),
    table.cell(colspan: 2, align: right)[*Subtotal*], [*11,500*], [*5,500*],
    table.hline(stroke: 0.5pt),

    // Operations group
    [Operations], [Lab supplies],  [4,200],  [4,500],
    [],           [Maintenance],   [2,800],  [3,000],
    table.hline(stroke: 0.5pt),
    table.cell(colspan: 2, align: right)[*Subtotal*], [*7,000*],  [*7,500*],
    // table.hline(stroke: 1pt),
  ),
  footer: (
    table.cell(colspan: 2, align: right)[*Grand Total*], [*80,500*], [*77,500*]
  ),
  columns: (auto, 1fr, auto, auto),
)

// ── Table 4: Rowspan for grouped categories ─────────────────────────────────

#academic-table(
  [GDP and population of selected countries by region],
  header: ([Region], [Country], [GDP (T\$)], [Pop. (M)]),
  (
    table.cell(rowspan: 3)[Europe],
      [Germany], [4.2],  [83],
      [France],  [2.9],  [67],
      [Italy],   [2.1],  [59],
      table.hline(stroke: 1pt),
    table.cell(rowspan: 3)[Asia],
      [China],   [17.7], [1,412],
      [Japan],   [4.2],  [125],
      [India],   [3.7],  [1,408],
      table.hline(stroke: 1pt),
    table.cell(rowspan: 2)[Americas],
      [USA],     [25.5], [331],
      [Brazil],  [1.9],  [214],
  ),
  columns: 4,
)

// ── Table 5: Format preset showcase ─────────────────────────────────────────

#pagebreak()

#for fmt in ("booktabs", "apa", "ieee", "acs", "nature", "elsevier", "chicago", "acm") {
  academic-table(
    [Sample data in *#fmt* format],
    header: ([Year], [Revenue], [Growth]),
    (
      [2022], [1.2M], [--],
      [2023], [1.5M], [25%],
      [2024], [1.8M], [20%],
    ),
    format: fmt,
    columns: 3,
  )
}
